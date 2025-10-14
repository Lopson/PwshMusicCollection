function Update-AlbumTags {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter(ParameterSetName = "Path")]
        [ValidateScript({ 
                Test-Path -Path (Split-Path -Path $_) -PathType "Container" } ,
            ErrorMessage = "Folder of path `"{0}`" doesn't seem to exist."
        )]
        [string]$Path,
        
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ 
                Test-Path -LiteralPath (Split-Path -LiteralPath $_) -PathType "Container" } ,
            ErrorMessage = "Folder of literal path `"{0}`" doesn't seem to exist."
        )]
        [string]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [string[]]$Genre,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseYear,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateSet([Valid3LetterCountryCodes])]
        [string]$ReleaseCountry,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]$Performer,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string]$Title,
        
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateSet([ValidAudioExtensions])]
        [ValidateNotNullOrEmpty()]
        [string]$Extension = "flac"
    )

    [string]$FolderPath = "";
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            if (-not [string]::IsNullOrWhiteSpace($Path)) {
                $FolderPath = (Get-Item -Path $Path).FullName;
            }
            else {
                $FolderPath = (Get-Location).Path;
            }
        }
        "LiteralPath" {
            $FolderPath = $LiteralPath;
        }
    }

    [string[]]$MusicFiles = (
        Get-ChildItem -LiteralPath $FolderPath -Filter "*.$Extension");
    
    if ($null -eq $MusicFiles -or $MusicFiles.Length -le 0) {
        throw [System.IO.FileNotFoundException] `
            "Path given `"$FolderPath`" has no files of extension `"$Extension`"";
    }

    for ($i = 0; $i -lt $MusicFiles.Length; $i++) {
        $file = $MusicFiles[$i];
        $musicFile = Get-MediaFile -LiteralPath $file;
        
        # Write-Progress -Activity "Updating metadata of file $((Get-Item -LiteralPath $file).BaseName)" `
        #     -Status "$i% Complete:" -PercentComplete (($i / $MusicFiles.Length) * 100);

        # Set the Track Count field.
        Set-MediaFileTag -MediaFile $musicFile -MediaTag "TrackCount" `
            -MediaTagValue $MusicFiles.Length -Save $false;

        # Clear out the ReplayGain fields.
        foreach ($replayTag in @("ReplayGainTrackGain", "ReplayGainTrackPeak",
                "ReplayGainAlbumGain", "ReplayGainAlbumPeak")) {
            $tagValue = Get-MediaFileTag -MediaFile $musicFile `
                -MediaTag $replayTag;
            
            if ($tagValue) {
                Set-MediaFileTag -MediaFile $musicFile -MediaTag $replayTag `
                    -MediaTagValue $null -Save $false;
            }
        }

        # Reformat the disc count and number fields.
        $discCount = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "DiscCount";
        $discNumber = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "Disc";

        if ($discCount -and $discCount -le 0) {
            Set-MediaFileTag -MediaFile $musicFile -MediaTag "DiscCount" `
                -MediaTagValue $null -Save $false;
        }
        elseif ($discNumber -and $discCount -eq 1) {
            Set-MediaFileTag -MediaFile $musicFile -MediaTag "DiscCount" `
                -MediaTagValue $null -Save $false;
            Set-MediaFileTag -MediaFile $musicFile -MediaTag "Disc" `
                -MediaTagValue $null -Save $false;
        }

        # Deal with the standard data fields.
        foreach ($param in `
            @("Genre", "ReleaseYear", "ReleaseCountry", "Performer", "Title") | Where-Object {
                -not [string]::IsNullOrWhiteSpace((Get-Variable -Name $_ -ValueOnly)) }) {
            
            $paramValue = Get-Variable -Name $param -ValueOnly;

            switch ($param) {
                "Genre" {
                    Set-MediaFileTag -MediaFile $musicFile -MediaTag "Genres" `
                        -MediaTagValue $paramValue -Save $false;
                }

                "ReleaseYear" {
                    # NOTE In order to see if a given enum value is in a OR'd
                    # composite value, one must do (thisInstance & flag) == flag
                    # https://learn.microsoft.com/en-us/dotnet/api/system.enum.hasflag?view=net-9.0#remarks
                    
                    if (((Get-MediaTagTypes -MediaFile $musicFile) -band
                            [TagLib.TagTypes]::Xiph) -eq [TagLib.TagTypes]::Xiph) {
                        Set-MediaFileCustomTag -MediaFile $musicFile `
                            -MediaTag "DATE" -MediaTagType "Xiph" `
                            -MediaTagValue $paramValue -Save $false;
                    }
                    Set-MediaFileTag -MediaFile $musicFile -MediaTag "Year" `
                        -MediaTagValue $paramValue -Save $false;
                }

                "ReleaseCountry" {
                    Set-MediaFileTag -MediaFile $musicFile -MediaTag `
                        "MusicBrainzReleaseCountry" -MediaTagValue $paramValue `
                        -Save $false;
                }

                "Performer" {    
                    Set-MediaFileTag -MediaFile $musicFile -MediaTag "AlbumArtists" `
                        -MediaTagValue $paramValue -Save $false;
                }

                "Title" {
                    Set-MediaFileTag -MediaFile $musicFile -MediaTag "Album" `
                        -MediaTagValue $paramValue -Save $false;
                }
            }
        }

        $musicFile.Save();
    }
}

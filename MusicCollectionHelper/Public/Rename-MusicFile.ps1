function Rename-MusicFile {
    # Despite the intended input of the pipeline being System.IO.FileInfo,
    # Powershell does some weird parameter binding magic and turns that
    # into strings. Therefore, we don't need to deal with that type of
    # object and instead we can ask directly for specific properties of
    # that type.
    #
    # Debugging this may be done by executing:
    # Trace-Command -PSHost -Name ParameterBinding `
    #     -Expression {Get-ChildItem | Rename-MusicFile}

    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "LiteralPath")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$LiteralPath
    )
    process {
        # Since the inputs may be arrays of strings, we have to be prepared.
        [System.Collections.ArrayList]$files = [System.Collections.ArrayList]@();

        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                foreach ($file in $Path) {
                    [void]$files.Add((Get-Item -Path $file));
                }
            }
            "LiteralPath" {
                foreach ($file in $LiteralPath) {
                    [void]$files.Add((Get-Item -LiteralPath $file));
                }
            }
        }

        # Process the actual files.
        foreach ($file in $files) {
            if (($file.Extension -replace "\.", "") -notin [ValidExtensions]::ValidValues) {
                continue;
            }

            [TagLib.File]$MusicFile = Get-MediaFile -LiteralPath $file.FullName;

            [string]$TrackNumber = (
                Get-MediaFileTag -MediaFile $MusicFile -MediaTag "Track" | `
                    Out-String).Trim();
            [string]$TrackTitle = (
                Get-MediaFileTag -MediaFile $MusicFile -MediaTag "Title" | `
                    Out-String).Trim();

            if ($TrackNumber -isnot [string] -or `
                    [string]::IsNullOrWhiteSpace($TrackNumber)) {
                throw [System.ArgumentException] `
                    "Track Number tag for $($file.BaseName)$($file.Extension) is empty";
            }
            if ($TrackNumber -isnot [string] -or `
                    [string]::IsNullOrWhiteSpace($TrackTitle)) {
                throw [System.ArgumentException] `
                    "Track Title tag for $($file.BaseName)$($file.Extension) is empty";
            }

            if ($TrackNumber.Length -eq 1) {
                $TrackNumber = "0$TrackNumber";
            }

            [string]$newName = "$TrackNumber. $TrackTitle$($file.Extension)".Split(
                [System.IO.Path]::GetInvalidFileNameChars()) -join "_";
            
            if ((Test-Path -Path $newName) -or
                (Test-Path -LiteralPath $newName)) {
                Write-Warning ("File with name $newName already exists, " +
                    "skipping");
            }
            else {
                $file | Rename-Item -NewName $newName;
            }
        }
    }
}

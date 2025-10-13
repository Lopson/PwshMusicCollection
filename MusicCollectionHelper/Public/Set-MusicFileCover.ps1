function Set-MusicFileCover {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    [OutputType([void])]
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
        [string]$Path,

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
        [string]$LiteralPath
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MediaFile = Get-MediaFile -Path $Path;
                [string]$MediaFileFolder = (Get-Item -Path $Path).DirectoryName;
            }
            "LiteralPath" {
                $MediaFile = Get-MediaFile -Path $LiteralPath;
                [string]$MediaFileFolder = (Get-Item -Path $LiteralPath).DirectoryName;
            }
        }

        [string]$coverFile = "";
        foreach ($imageExtension in [ValidImageExtensions]::new().GetValidValues()) {
            if (Test-Path -LiteralPath (Join-Path $MediaFileFolder `
                        "folder.$imageExtension") -PathType "Leaf") {
                $coverFile = (Join-Path $MediaFileFolder `
                        "folder.$imageExtension");
                break;
            }
            elseif (Test-Path -LiteralPath (Join-Path $MediaFileFolder `
                        "cover.$imageExtension") -PathType "Leaf") {
                $coverFile = (Join-Path $MediaFileFolder `
                        "cover.$imageExtension");
                break;
            }
        }

        if ([string]::IsNullOrWhiteSpace($coverFile)) {
            throw [System.ArgumentNullException] (
                "Couldn't find a `"folder`" or `"cover`" image file in the " +
                "folder containing the given media file");
        }

        [TagLib.Picture]$coverPicture = [TagLib.Picture]::new($coverFile);
        $coverPicture.Type = [TagLib.PictureType]::FrontCover;
        
        Set-MediaFilePicture -MediaFile $MediaFile -Picture $coverPicture;
    }
}

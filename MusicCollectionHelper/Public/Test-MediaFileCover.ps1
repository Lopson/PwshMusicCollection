function Test-MediaFileCover {
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
            }
            "LiteralPath" {
                $MediaFile = Get-MediaFile -Path $LiteralPath;
            }
        }

        $mediaFilePictures = $MediaFile.Tag.Pictures | Where-Object {
            $_.Type -eq [TagLib.PictureType]::FrontCover };
        
        if ((-not $mediaFilePictures) -or $mediaFilePictures.Length -ne 1) {
            Write-Warning ("Incorrect number of front covers for file " +
                "$($MediaFile.Name): $($mediaFilePictures.Length) instead of 1");
            return;
        }

        $frontCover = $MediaFilePictures[0];
        if ($frontCover.Width -lt 1000 -or $frontCover.Height -lt 1000) {
            Write-Warning ("Front cover's size of file $($MediaFile.Name) smaller " +
                "than 1000 x 1000 px!");
            Write-Warning ("Current dimensions: $($frontCover.Width) x " + 
                "$($frontCover.Height) px");
            return;
        }
    }
}
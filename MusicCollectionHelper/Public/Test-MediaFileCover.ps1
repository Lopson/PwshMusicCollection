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
        [string]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateRange(1, [int]::MaxValue)]
        [ValidateNotNull()]
        [int]$MinimumSize = 1000
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MediaFile = Get-MediaFile -Path $Path;
            }
            "LiteralPath" {
                $MediaFile = Get-MediaFile -LiteralPath $LiteralPath;
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
        if ($frontCover.Width -lt $MinimumSize -or `
                $frontCover.Height -lt $MinimumSize) {
            Write-Warning ("Front cover's size of file $($MediaFile.Name) smaller " +
                "than $MinimumSize x $MinimumSize px!");
            Write-Warning ("Current dimensions: $($frontCover.Width) x " + 
                "$($frontCover.Height) px");
            return;
        }
    }
}
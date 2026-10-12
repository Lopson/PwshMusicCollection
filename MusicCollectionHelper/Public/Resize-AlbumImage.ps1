function Resize-AlbumImage {
    param (
    [Parameter(ParameterSetName = "Path")]    
    [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,
        
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet([ValidImageExtensions])]
        [string]$Extension = "jpg",

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TargetSize = 1000,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TargetKiB = 1024,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(0, 1)]
        [double]$Tolerance = 0.25
    )

    # Determine the path of the image file we want to convert.
    # Default file names: folder, cover, albumart.
    [string]$imagePath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            [string]$imagePath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            [string]$imagePath = Get-Item -LiteralPath $LiteralPath;
        }
    }
    if (-not $imagePath) {
        foreach ($imageExtension in [ValidImageExtensions]::new().GetValidValues()) {
            if ("folder.$imageExtension" -in (Get-ChildItem).Name.ToLower()) {
                $imagePath = Get-Item -LiteralPath "folder.$imageExtension";
                break;
            }
            elseif ("cover.$imageExtension" -in (Get-ChildItem).Name.ToLower()) {
                $imagePath = Get-Item -LiteralPath "cover.$imageExtension";
                break;
            }
            elseif ("albumart.$imageExtension" -in (Get-ChildItem).Name.ToLower()) {
                $imagePath = Get-Item -LiteralPath "albumart.$imageExtension";
                break;
            }
        }
    }
    if (-not $imagePath) {
        throw [System.IO.FileNotFoundException] (
            "Album image not found, please specify its path");
    }

    # Load the image file into ImageMagick.
    $imageFile = [ImageMagick.MagickImage]::new($imagePath);
    
    # Set the format of the image output to the one given.
    if (-not ($Extension -in [ImageMagick.MagickFormat].GetEnumNames().ToLower())) {
        throw "Specified file extension doesn't exist in ImageMagick";
    }
    $imageFile.Format = [ImageMagick.MagickFormat]$Extension;

    [bool]$resizeRequired = $false;
    if ($imageFile.BaseHeight -gt 1000 -or $imageFile.BaseWidth -gt 1000) {
        $resizeRequired = $true;
    }
    if ($resizeRequired) {
        [int]$resizeTarget = (
            $imageFile.BaseHeight -gt $imageFile.BaseWidth ? `
            $imageFile.BaseHeight : $imageFile.BaseWidth);
        
        # Calculate the nearest power of 2 for the resizing.
        # We need powers of 2 to perform linear resizings.
        [int]$closest = [int](
            [System.Math]::Ceiling(
                [System.Math]::Log($resizeTarget / $TargetSize) / [System.Math]::Log(2)));

        function Resize-Image {
            param(
                [int]$ResizeFactor,
                [ImageMagick.MagickImage]$Image
            )

            # Define resize percentage.
            $ResizePercent = [ImageMagick.Percentage]::new(
                    ([double](1 / $ResizeFactor)) * 100);
            $Image.Resize(
                    [ImageMagick.MagickGeometry]::new($ResizePercent, $ResizePercent));
            
            # If image we're resizing is JPEG, let's use the target maximum
            # file size argument of this function.
            if ($Image.Format -in @([ImageMagick.MagickFormat]::Jpeg,
                    [ImageMagick.MagickFormat]::Jpg)) {
                # Define maximum file size.
                $jpegOptions = [ImageMagick.Formats.JpegWriteDefines]::new();
                $jpegOptions.Extent = $TargetKiB;

                $Image.Write($Image.FileName, $jpegOptions);
            }
            else {
                $Image.Write($Image.FileName);
            }
        }

        [int]$upperBound = $TargetSize + ($TargetSize * $Tolerance);
        [int]$lowerBound = $TargetSize - ($TargetSize * $Tolerance);

        # Resize result above tolerance.
        if ($closest -gt 1 -and $resizeTarget -gt $upperBound -and
                    ($resizeTarget / ($closest * 2)) -gt $lowerBound -and
                    ($resizeTarget / ($closest * 2)) -lt $upperBound) {
            Resize-Image -ResizeFactor $closest * 2 -Image $imageFile;
        }
        # Resize result below tolerance.
        elseif ($closest -gt 1 -and $resizeTarget -lt $lowerBound -and
                    ($resizeTarget / ($closest / 2)) -gt $lowerBound -and
                    ($resizeTarget / ($closest / 2)) -lt $upperBound) {
            Resize-Image -ResizeFactor $closest / 2 -Image $imageFile;
        }
        # Normal case, resize result within tolerance, OR
        # Resize is necessary but we can't get it within tolerance.
        elseif ($closest -gt 1) {
            Resize-Image -ResizeFactor $closest -Image $imageFile;
        }
    }
}

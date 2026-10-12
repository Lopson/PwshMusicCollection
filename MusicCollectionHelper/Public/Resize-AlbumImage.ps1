[string]$NEW_IMAGE_SUFFIX = "_resized";

function Resize-AlbumImage {
    [CmdletBinding(DefaultParameterSetName = "NoPath")]
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

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet([ValidImageExtensions])]
        [string]$Extension = "jpg",

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TargetSize = 1000,

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$TargetKiB = 1024,

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ValidateRange(0, 1)]
        [double]$Tolerance = 0.25,

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [switch]$Overwrite
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
        "NoPath" {
            foreach ($imageExtension in [ValidImageExtensions]::new().GetValidValues()) {
                if ("folder.$($imageExtension.ToLower())" -in (Get-ChildItem).Name.ToLower()) {
                    $imagePath = Get-Item -LiteralPath "folder.$imageExtension";
                    break;
                }
                elseif ("cover.$($imageExtension.ToLower())" -in (Get-ChildItem).Name.ToLower()) {
                    $imagePath = Get-Item -LiteralPath "cover.$imageExtension";
                    break;
                }
                elseif ("albumart.$($imageExtension.ToLower())" -in (Get-ChildItem).Name.ToLower()) {
                    $imagePath = Get-Item -LiteralPath "albumart.$imageExtension";
                    break;
                }
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
        throw "Specified file extension '$Extension' doesn't exist in ImageMagick";
    }
    $imageFile.Format = [ImageMagick.MagickFormat]$Extension;

    # Calculate some sizes (in px) to be used in processing.
    [int]$resizeTarget = (
        $imageFile.BaseHeight -gt $imageFile.BaseWidth ? `
            $imageFile.BaseHeight : $imageFile.BaseWidth);
    [int]$upperBound = $TargetSize + ($TargetSize * $Tolerance);
    [int]$lowerBound = $TargetSize - ($TargetSize * $Tolerance);
    
    # Check if we need to resize, which we only want to do if the image
    # is larger than our upper size bound (in px).
    [bool]$resizeRequired = $false;
    if ($resizeTarget -gt $upperBound) {
        $resizeRequired = $true;
    }
    
    # Perform resizing if required.
    if ($resizeRequired) {
        # Calculate the nearest power of 2 for the resizing.
        # We need powers of 2 to perform linear resizings.
        # 
        # If no nudging of the resize factor gets us closer to the tolerance
        # range, we'll use the factor calculated here.
        [int]$closest = [int](
            [System.Math]::Ceiling(
                [System.Math]::Log($resizeTarget / $TargetSize) / [System.Math]::Log(2)));

        # If resize result above tolerance, change resize factor value.
        # Here, we're nudging the resize factor by a single power of 2 to see
        # if it gets us closer to the tolerance range.
        if ($resizeTarget -gt $upperBound -and
                [int]([System.Math]::Ceiling($resizeTarget / ($closest * 2))) -gt $lowerBound -and
                [int]([System.Math]::Ceiling($resizeTarget / ($closest * 2))) -lt $upperBound) {
            $closest = $closest * 2;
        }
        
        # Resize only if the resize factor is greater than 1 (obviously).
        if ($closest -gt 1) {
            # We might want to specify format-specific options.
            # This is what this variable is for.
            $writeDefines = $null;
            
            # If image we're resizing is JPEG, let's use the target maximum
            # file size argument of this function.
            if ($Image.Format -in @([ImageMagick.MagickFormat]::Jpeg,
                    [ImageMagick.MagickFormat]::Jpg) -and $TargetKiB) {
                # Define maximum file size.
                $writeDefines = [ImageMagick.Formats.JpegWriteDefines]::new();
                $writeDefines.Extent = $TargetKiB;
            }

            # Do the resizing.
            if ($Overwrite) {
                Resize-Image -ResizeFactor $closest -Image $imageFile `
                    -WriteDefines $writeDefines;
            }
            else {
                Resize-Image -ResizeFactor $closest -Image $imageFile `
                    -WriteDefines $writeDefines `
                    -LiteralPath (
                        Join-Path `
                            (Split-Path $imageFile.FileName) `
                            (
                                (Split-Path $imageFile.FileName -LeafBase) + `
                                $NEW_IMAGE_SUFFIX + `
                                (Split-Path $imageFile.FileName -Extension).ToLower()
                            )
                    );
            }
        }
    }
}

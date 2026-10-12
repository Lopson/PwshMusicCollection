function Resize-Image {
    [CmdletBinding(DefaultParameterSetName = "NoPath")]
    param(
        [Parameter(Mandatory = $true)]
        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$ResizeFactor,

        [Parameter(Mandatory = $true)]
        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [ImageMagick.MagickImage]$Image,

        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        $WriteDefines,
        
        [Parameter(ParameterSetName = "Path")]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,
        
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath
    )

    # Determine output path.
    [string]$OutputPath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            [string]$OutputPath = Join-Path (Get-Item -Path (Split-Path $Path)) `
                (Split-Path $Path -Leaf);
        }
        "LiteralPath" {
            [string]$OutputPath = Join-Path (
                Get-Item -LiteralPath (Split-Path $LiteralPath)) `
                (Split-Path $LiteralPath -Leaf);
        }
        "NoPath" {
            if ($Image.FileName) {
               $OutputPath = Get-Item -LiteralPath $Image.FileName;
            }
        }
    }

    # Validate the output path.
    if (-not $OutputPath) {
        throw [System.ArgumentException](
            "No output path specified as argument or in image object");
    }
    if (-not (Test-Path -LiteralPath (Split-Path $OutputPath) -PathType "Container")) {
        throw [System.ArgumentException](
            "Invalid parent path specified as argument or in image object");
    }

    # Detect misalignments between output path and image's own extension.
    if (((Split-Path $OutputPath -Extension) -replace '\.').ToLower() -ne `
            $Image.Format.ToString().ToLower()) {
        Write-Warning ("Output file extension doesn't match image object's " +
            "file type, changing extension in given path!")

        $OutputPath = Join-Path (Split-Path $OutputPath) `
            "$(Split-Path $OutputPath -LeafBase).$($Image.Format.ToString().ToLower())"
    }

    # Define resize percentage.
    $ResizePercent = [ImageMagick.Percentage]::new(
            ([double](1 / $ResizeFactor)) * 100);
    $Image.Resize(
            [ImageMagick.MagickGeometry]::new($ResizePercent, $ResizePercent));
    
    # Write the image out.
    if ($WriteDefines) {
        $Image.Write($OutputPath, $WriteDefines);
    }
    else {
        $Image.Write($OutputPath);
    }
}

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

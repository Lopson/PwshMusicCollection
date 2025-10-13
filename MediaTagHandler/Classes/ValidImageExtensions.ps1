class ValidImageExtensions : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        "apng", "avif", "bmp", "dng", "gif", "jfif", "jpeg", "jpg", "pbm",
        "pcx", "pgm", "pjp", "pjpeg", "png", "pnm", "ppm", "svg", "tif",
        "tiff", "webp"
    )

    [string[]] GetValidValues() {
        return [ValidImageExtensions]::ValidValues;
    }
}

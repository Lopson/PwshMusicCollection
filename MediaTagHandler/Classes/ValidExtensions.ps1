class ValidExtensions : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        "aa", "aac", "aax", "aiff", "ape", "asf", "avi", "bmp", "dng",
        "dsf", "flac", "gif", "jpeg", "m2v", "m4a", "m4b", "m4p", "m4p",
        "m4v", "mkv", "mp3", "mp4", "mpc", "mpe", "mpeg", "mpg", "mpg",
        "mpp", "mpv", "oga", "ogg", "ogv", "pbm", "pcx", "pgm", "png",
        "pnm", "ppm", "svg", "tiff", "wav", "webm", "wma", "wmv", "wv"
    )

    [string[]] GetValidValues() {
        return [ValidExtensions]::ValidValues;
    }
}

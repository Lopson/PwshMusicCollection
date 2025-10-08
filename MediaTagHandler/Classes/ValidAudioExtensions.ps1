class ValidAudioExtensions : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        "aa", "aax", "aac", "aiff", "ape", "dsf", "flac", "m4a", "m4b",
        "m4p", "mp3", "mpc", "mpp", "ogg", "oga", "wav", "wma", "wv", "webm"
    )

    [string[]] GetValidValues() {
        return [ValidAudioExtensions]::ValidValues;
    }
}

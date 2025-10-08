class ValidTagTypes : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        "None", "Xiph", "Id3v1", "Id3v2", "Ape", "Apple", "Asf", "RiffInfo",
        "MovieId", "DivX", "FlacMetadata", "TiffIFD", "XMP", "JpegComment",
        "GifComment", "Png", "IPTCIIM", "AudibleMetadata", "Matroska", "AllTags"
    )

    [string[]] GetValidValues() {
        return [ValidTagTypes]::ValidValues;
    }
}

function Test-MediaFile {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,

        [bool]$TestWritable = $true
    )
    
    process {
        if ($null -eq $MediaFile) {
            throw [System.ArgumentException] `
                "TagLib file given is null";
        }
        if ($MediaFile.PossiblyCorrupt) {
            throw [System.ArgumentException] `
                "TagLib file given is possibly corrupt: " + $MediaFile.CorruptionReasons -join "; ";
        }
        if ($TestWritable -and -not $MediaFile.Writeable) {
            throw [System.ArgumentException] `
                "TagLib file given is not writable";
        }
    }
}
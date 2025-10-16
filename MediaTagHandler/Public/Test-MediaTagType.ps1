function Test-MediaFileTagType {
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [Parameter(Mandatory = $true)]
        [TagLib.TagTypes]$MediaTagType
    )

    process {
        Test-MediaFile -MediaFile $MediaFile;

        if (($MediaFile.TagTypesOnDisk -band $MediaTagType) -eq $MediaTagType) {
            return $true;
        }
        return $false;
    }
}

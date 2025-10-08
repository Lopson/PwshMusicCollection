function Set-MediaFileCustomTag {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string]$MediaTag,

        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateSet([ValidTagTypes])]
        [ValidateNotNullOrEmpty()]
        [string]$MediaTagType,

        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        $MediaTagValue,

        [bool]$Save = $true,

        [bool]$Force = $false
    )

    process {
        Test-MediaFile -MediaFile $MediaFile;

        $CustomTags = $Tags.GetTag($MediaTagType);

        if ($Force -or ($CustomTags.GetField($MediaTag) -ne $MediaTagValue)) {
            $CustomTags.SetField($MediaTag, $MediaTagValue);

            if ($Save) {
                $Tags.Save();
            }
        }
    }
}

function Set-MediaFileTag {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [ValidateSet([ValidTags])]
        [ValidateNotNullOrEmpty()]
        [string]$MediaTag,

        $MediaTagValue,

        [bool]$Save = $true,
        
        [bool]$Force = $false
    )
    
    process {
        Test-MediaFile -MediaFile $MediaFile;

        if ($Force -or (
                ($MediaFile.Tag.$MediaTag -ne $MediaTagValue) -or
                ($MediaTagValue -is [array] -and (
                    Compare-Object -ReferenceObject (@() + $MediaFile.Tag."$MediaTag") `
                        -DifferenceObject $MediaTagValue).Length -ne 0
                )
            )
        ) {
            if ($MediaTagValue -is [array]) {
                $MediaTagValue = $MediaTagValue | Where-Object { $_ };
            }

            $MediaFile.Tag.$MediaTag = $MediaTagValue;

            if ($Save) {
                $MediaFile.Save();
            }
        }
    }
}

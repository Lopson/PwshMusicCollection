function Get-MediaFileCustomTag {
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$MediaTag,

        [Parameter(Mandatory = $true)]
        [TagLib.TagTypes]$MediaTagType
    )

    begin {
        $result = @();
    }
    process {
        Test-MediaFile -MediaFile $MediaFile;
        $result += $MediaFile.GetTag($MediaTagType).GetField($MediaTag);
    }
    end {
        return $result;
    }
}

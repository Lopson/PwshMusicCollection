function Get-MediaTagTypes {
    [OutputType([TagLib.TagTypes[]])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile
    )

    begin {
        $result = @();
    }
    process {
        Test-MediaFile -MediaFile $MediaFile -TestWritable $false;
        
        $result += @($MediaFile.TagTypesOnDisk);
    }
    end {
        return $result;
    }
}

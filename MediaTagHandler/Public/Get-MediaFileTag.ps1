function Get-MediaFileTag {
    # [OutputType([string, uint, bool, double, datetime])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet([ValidTags])]
        [ValidateNotNullOrEmpty()]
        [string]$MediaTag
    )
    
    begin {
        $result = @();
    }
    process {
        Test-MediaFile -MediaFile $MediaFile -TestWritable $false;
        $result += $MediaFile.Tag."$MediaTag";
    }
    end {
        return $result;
    }
}

function Get-MediaFileTagStringArray {
    [OutputType([string[][]])]
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
        [string[][]]$result = @();
    }
    process {
        Test-MediaFile -MediaFile $MediaFile -TestWritable $false;

        [string[]] $TagValue = (
            Get-MediaFileTag -MediaFile $MediaFile -MediaTag $MediaTag |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { $_.Trim() } |
            Get-Unique
        );

        if ($TagValue -and $TagValue.Length -gt 0) {
            $result += $TagValue;
        }
        else {
            $result += @();
        }
    }
    end {
        return $result;
    }
}

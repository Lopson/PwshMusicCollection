class Valid3LetterCountryCodes : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $3LCountryCodes = [System.Collections.Generic.HashSet[string]]::new();

        [System.Globalization.CultureInfo[]]$cultures = `
            [System.Globalization.CultureInfo]::GetCultures(
            [System.Globalization.CultureTypes]::SpecificCultures);

        foreach ($culture in $cultures) {
            [System.Globalization.RegionInfo]$region = `
                [System.Globalization.RegionInfo]($culture.Name);
            
            if (-not [string]::IsNullOrWhiteSpace($region.ThreeLetterISORegionName)) {
                [void]$3LCountryCodes.Add($region.ThreeLetterISORegionName.ToUpper());
            }
        }

        return [string[]]($3LCountryCodes | Sort-Object);
    }
}

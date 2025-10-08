class ValidTextEncodings : System.Management.Automation.IValidateSetValuesGenerator {
    # NOTE Beginning with PowerShell 6.2, the Encoding parameter also allows
    # numeric IDs of registered code pages (like -Encoding 1251) or string
    # names of registered code pages (like -Encoding "windows-1251").
    #
    # Source: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-content?view=powershell-7.5#-encoding
    
    [string[]] GetValidValues() {
        $Encodings = [System.Text.Encoding]::GetEncodings();
        [string[]]$EncodingNames = $Encodings | Select-Object -ExpandProperty "Name";
        [string[]]$EncodingCodePages = $Encodings | Select-Object -ExpandProperty "CodePage";
        [string[]]$PowershellEncodings = @(
            "ascii", "ansi", "bigendianunicode", "bigendianutf32", "oem",
            "unicode", "utf7", "utf8", "utf8BOM", "utf8NoBOM", "utf32");
        return ($EncodingNames + $EncodingCodePages + $PowershellEncodings  );
    }
}

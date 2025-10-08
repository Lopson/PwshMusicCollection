foreach ($private in (
        Get-ChildItem "$PSScriptRoot\Private" -ErrorAction SilentlyContinue)
) {
    . $private.FullName;
}

foreach ($public in (
        Get-ChildItem "$PSScriptRoot\Public" -ErrorAction SilentlyContinue)
) {
    . $public.FullName;
    Export-ModuleMember -Function $public.BaseName;
}

foreach ($class in (
        Get-ChildItem "$PSScriptRoot\Classes" -ErrorAction SilentlyContinue)
) {
    . $class.FullName;
}

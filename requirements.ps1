$Requirements = @(
    [pscustomobject]@{
        PackageName = "TagLibSharp"
        Version = "*"
        TargetFramework = "*"
        Modules = @("MediaTagHandler")
    },
    [pscustomobject]@{
        PackageName = "PlaylistsNET"
        Version = "*"
        TargetFramework = "*"
        Modules = @("M3UParser")
    }
);

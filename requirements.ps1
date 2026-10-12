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
    },
    [pscustomobject]@{
        PackageName = "Magick.NET.Core"
        Version = "*"
        TargetFramework = "*"
        Modules = @("MusicCollectionHelper")
    },
    [pscustomobject]@{
        PackageName = "Magick.NET-Q8-AnyCPU"
        Version = "*"
        TargetFramework = "*"
        RuntimeId = "*"
        Modules = @("MusicCollectionHelper")
    }
);

$Requirements = @(
    [pscustomobject]@{
        PackageName = "TagLibSharp"
        Version = "2.3.0"
        TargetFramework = "*"
        Modules = @("MediaTagHandler")
    },
    [pscustomobject]@{
        PackageName = "PlaylistsNET"
        Version = "1.4.1"
        TargetFramework = "*"
        Modules = @("M3UParser")
    },
    [pscustomobject]@{
        PackageName = "Magick.NET.Core"
        Version = "15.0.0"
        TargetFramework = "*"
        Modules = @("MusicCollectionHelper")
    },
    [pscustomobject]@{
        PackageName = "Magick.NET-Q8-AnyCPU"
        Version = "15.0.0"
        TargetFramework = "*"
        RuntimeId = "*"
        Modules = @("MusicCollectionHelper")
    }
);

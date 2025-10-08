# AGENTS.md file

## Project Overview

This project is a set of PowerShell modules that enable the user to manage their music collection more efficiently. It relies on both native PowerShell code as well as some .NET assemblies that are leveraged as DLL files directly. It currently targets PowerShell 7.5.

## Dependencies

This project depends on the following .NET assemblies:

- [TagLibSharp](https://www.nuget.org/packages/TagLibSharp)
- [PlaylistsNET](https://www.nuget.org/packages/PlaylistsNET)

## Folder Structure

- `/CueParser`: Contains the source code for the PowerShell module in charge of parsing Cue sheets.
- `/M3UParser`: Contains the source code for the PowerShell module in charge of parsing M3U playlists.
- `/MediaTagHandler`: Contains the source code for the PowerShell module in charge of reading and writing media file metadata tags.
- `/MusicCollectionHelper`: Contains all of the functions that are actually used in the process of managing a music collection. It relies on the three modules present in this repository.

You may be running in the actual "Modules" folder of a user's profile instead of a regular source code repository. This can be determined by checking if the parent folder of the root of the project is named "Powershell". If that's the case, ignore all other folders at the root of the project as they will contain irrelevant PowerShell modules.

## Platform Information

- **Operating System**: Windows.
- **Shell**: PowerShell (not Linux/Mac terminal).
- **Command Style**: Use PowerShell cmdlets; only use Windows commands when no native PowerShell option exists.

## Reference Resources

- [PowerShell Cmdlets Documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/?view=powershell-7.4)
- [Windows Commands Reference](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)
- [PowerShell Community Resources](https://www.pdq.com/powershell/)
- [TagLibSharp Repository](https://github.com/mono/taglib-sharp)
- [PlaylistsNET Repository](https://github.com/tmk907/PlaylistsNET)
- [M3U Specifications on Wikipedia](https://en.wikipedia.org/wiki/M3U)
- [Cue Sheet Specification](https://wyday.com/cuesharp/specification.php)

## Work Instructuions

When working with any user:

1. Always use PowerShell syntax and cmdlets.
2. Prefer native PowerShell commands over Linux equivalents.
3. Use `Get-Help` PowerShell commands to discover available options if necessary.
4. Suggest Windows-native alternatives for Linux tools.
5. Consider WSL when Linux-specific tools are essential.
6. Leverage all of the features available to PowerShell 7.5.
7. Use PowerShell strict mode and proper typing.
8. Prefer native implementations over external dependencies when possible.
9. If native implementations aren't possible, you may suggest .NET dependencies found in NuGet.
10. Don't offer to directly edit whatever files you're analysing.

## Coding Standards

- Use semicolons at the end of each statement whenver possible.
- Use double quotes for strings.

class ValidTags : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        
        # NOTE This doesn't work despite adding the required assembly
        # due to some truly esoteric Powershell awkwardness. Maybe
        # this will be fixed in the future.
        #
        # [Diagnostics.CodeAnalysis.SuppressMessageAttribute("TypeNotFound", "")]
        # return @([TagLib.CombinedTag].GetMembers() | `
        #         Where-Object { $_.MemberType -eq "Property" } | `
        #         Select-Object -ExpandProperty Name);

        return @(
            "Album", "AlbumArtists", "AlbumArtistsSort", "AlbumSort",
            "AmazonId", "Artists", "BeatsPerMinute", "Comment", "Composers",
            "ComposersSort", "Conductor", "Copyright", "DateTagged",
            "Description", "Disc", "DiscCount", "FirstAlbumArtist",
            "FirstAlbumArtistSort", "FirstArtist", "FirstComposer",
            "FirstComposerSort", "FirstGenre", "FirstPerformer",
            "FirstPerformerSort", "Genres", "Grouping", "InitialKey",
            "IsEmpty", "ISRC", "JoinedAlbumArtists", "JoinedArtists",
            "JoinedComposers", "JoinedGenres", "JoinedPerformers",
            "JoinedPerformersSort", "Length", "Lyrics", "MusicBrainzArtistId",
            "MusicBrainzDiscId", "MusicBrainzReleaseArtistId",
            "MusicBrainzReleaseCountry", "MusicBrainzReleaseGroupId",
            "MusicBrainzReleaseId", "MusicBrainzReleaseStatus",
            "MusicBrainzReleaseType", "MusicBrainzTrackId",
            "MusicIpId", "Performers", "PerformersRole", "PerformersSort",
            "Pictures", "Publisher", "RemixedBy", "ReplayGainAlbumGain",
            "ReplayGainAlbumPeak", "ReplayGainTrackGain",
            "ReplayGainTrackPeak", "Subtitle", "Tags", "TagTypes", "Title",
            "TitleSort", "Track", "TrackCount", "Year"
        );
    }
}

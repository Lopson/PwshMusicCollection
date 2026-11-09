class ValidAudioMimeTypes : System.Management.Automation.IValidateSetValuesGenerator {
    static [string[]]$ValidValues = @(
        'application/octet-stream', 'application/ogg',
        'application/vnd.dolby.mlp', 'application/x-aiff',
        'application/x-ape', 'application/x-dff', 'application/x-dsf',
        'application/x-flac', 'application/x-id3', 'application/x-ogg',
        'audio/1d-interleaved-parityfec', 'audio/32kadpcm', 'audio/3gpp',
        'audio/3gpp2', 'audio/8svx', 'audio/aac', 'audio/aacp', 'audio/ac3',
        'audio/adpcm', 'audio/aiff', 'audio/alac', 'audio/amr-wb',
        'audio/amr-wb+', 'audio/amr', 'audio/ape',
        'audio/application/x-pn-realmedia', 'audio/aptx', 'audio/asc',
        'audio/asf', 'audio/atrac-advanced-lossless', 'audio/atrac-x',
        'audio/atrac3', 'audio/audible', 'audio/avi', 'audio/basic',
        'audio/bv16', 'audio/bv32', 'audio/clearmode', 'audio/cn',
        'audio/csound', 'audio/dat12', 'audio/dff', 'audio/dfpwm',
        'audio/dls', 'audio/dsf', 'audio/dsr-es201108', 'audio/dsr-es202050',
        'audio/dsr-es202211', 'audio/dsr-es202212', 'audio/dv', 'audio/dvi4',
        'audio/eac3', 'audio/encaprtp', 'audio/evrc-qcp', 'audio/evrc',
        'audio/evrc0', 'audio/evrc1', 'audio/evrcb', 'audio/evrcb0',
        'audio/evrcb1', 'audio/evrcnw', 'audio/evrcnw0', 'audio/evrcnw1',
        'audio/evrcwb', 'audio/evrcwb0', 'audio/evrcwb1', 'audio/evs',
        'audio/example', 'audio/flac', 'audio/flexfec', 'audio/fwdred',
        'audio/g711-0', 'audio/g711-alaw', 'audio/g711-mlaw', 'audio/g719',
        'audio/g722', 'audio/g7221', 'audio/g723', 'audio/g726-16',
        'audio/g726-24', 'audio/g726-32', 'audio/g726-40', 'audio/g728',
        'audio/g729', 'audio/g7291', 'audio/g729d', 'audio/g729e',
        'audio/gsm-efr', 'audio/gsm-hr-08', 'audio/gsm', 'audio/ilbc',
        'audio/imelody', 'audio/ip-mr_v2.5', 'audio/it', 'audio/l16',
        'audio/l20', 'audio/l24', 'audio/l8', 'audio/lpc', 'audio/m',
        'audio/matroska', 'audio/med', 'audio/melp', 'audio/melp1200',
        'audio/melp2400', 'audio/melp600', 'audio/mhas', 'audio/mid',
        'audio/midi-clip', 'audio/midi', 'audio/mobile-xmf', 'audio/mod',
        'audio/module-xm', 'audio/mp3', 'audio/mp4', 'audio/mp4a-latm',
        'audio/mp4a', 'audio/mpa-robust', 'audio/mpa', 'audio/mpeg-l1',
        'audio/mpeg-l2', 'audio/mpeg', 'audio/mpeg3', 'audio/mpeg4-generic',
        'audio/mpg', 'audio/mpga', 'audio/musepack', 'audio/ogg',
        'audio/opus', 'audio/parityfec', 'audio/pcma-wb', 'audio/pcma',
        'audio/pcmu-wb', 'audio/pcmu', 'audio/prs.sid', 'audio/qcelp',
        'audio/raptorfec', 'audio/raw', 'audio/red', 'audio/rmf',
        'audio/rtp-enc-aescm128', 'audio/rtp-midi', 'audio/rtploopback',
        'audio/rtx', 'audio/s3m', 'audio/scip', 'audio/silk', 'audio/smv-qcp',
        'audio/smv', 'audio/smv0', 'audio/sofa', 'audio/soundfont',
        'audio/sp-midi', 'audio/speex', 'audio/t140c', 'audio/t38',
        'audio/telephone-event', 'audio/tetra_acelp_bb', 'audio/tetra_acelp',
        'audio/tone', 'audio/true-hd', 'audio/tsvcis', 'audio/tta',
        'audio/uemclip', 'audio/ulpfec', 'audio/usac', 'audio/vdvi',
        'audio/vmr-wb', 'audio/vnd.3gpp.iufp', 'audio/vnd.4sb',
        'audio/vnd.adobe.soundbooth', 'audio/vnd.audible.aax',
        'audio/vnd.audible', 'audio/vnd.audiokoz',
        'audio/vnd.blockfact.facta', 'audio/vnd.celp', 'audio/vnd.cisco.nse',
        'audio/vnd.cmles.radio-events', 'audio/vnd.cns.anp1',
        'audio/vnd.cns.inf1', 'audio/vnd.dece.audio',
        'audio/vnd.digital-winds', 'audio/vnd.dlna.adts',
        'audio/vnd.dolby.heaac.1', 'audio/vnd.dolby.heaac.2',
        'audio/vnd.dolby.mlp', 'audio/vnd.dolby.mps', 'audio/vnd.dolby.pl2',
        'audio/vnd.dolby.pl2x', 'audio/vnd.dolby.pl2z',
        'audio/vnd.dolby.pulse.1', 'audio/vnd.dra',
        'audio/vnd.dts.hd;profile=lbr', 'audio/vnd.dts.hd',
        'audio/vnd.dts.uhd', 'audio/vnd.dts', 'audio/vnd.dvb.file',
        'audio/vnd.everad.plj', 'audio/vnd.hns.audio',
        'audio/vnd.lucent.voice', 'audio/vnd.ms-playready.media.pya',
        'audio/vnd.nokia.mobile-xmf', 'audio/vnd.nortel.vbk',
        'audio/vnd.nuera.ecelp4800', 'audio/vnd.nuera.ecelp7470',
        'audio/vnd.nuera.ecelp9600', 'audio/vnd.octel.sbc',
        'audio/vnd.presonus.multitrack', 'audio/vnd.qcelp',
        'audio/vnd.rhetorex.32kadpcm', 'audio/vnd.rip',
        'audio/vnd.rn-realaudio', 'audio/vnd.sealedmedia.softseal.mpeg',
        'audio/vnd.vmx.cvsd', 'audio/vnd.wave', 'audio/vorbis-config',
        'audio/vorbis', 'audio/wav', 'audio/wave', 'audio/webm',
        'audio/x-8svx', 'audio/x-aac', 'audio/x-aiff', 'audio/x-amzxml',
        'audio/x-ape', 'audio/x-audible', 'audio/x-caf', 'audio/x-dff',
        'audio/x-dsf', 'audio/x-flac', 'audio/x-gsm', 'audio/x-ircam',
        'audio/x-m4a', 'audio/x-m4b', 'audio/x-m4p', 'audio/x-matroska',
        'audio/x-midi', 'audio/x-mod', 'audio/x-mp1', 'audio/x-mp2',
        'audio/x-mp3', 'audio/x-mp4a-latm', 'audio/x-mp4a', 'audio/x-mpeg-3',
        'audio/x-mpeg', 'audio/x-mpeg3', 'audio/x-mpegaudio',
        'audio/x-mpegurl', 'audio/x-mpg', 'audio/x-ms-asf', 'audio/x-ms-wax',
        'audio/x-ms-wma', 'audio/x-musepack', 'audio/x-ogg', 'audio/x-opus',
        'audio/x-opus+ogg', 'audio/x-pn-aiff', 'audio/x-pn-audibleaudio',
        'audio/x-pn-realaudio-plugin', 'audio/x-pn-realaudio',
        'audio/x-pn-wav', 'audio/x-psid', 'audio/x-realaudio', 'audio/x-rmf',
        'audio/x-s3m', 'audio/x-scpls', 'audio/x-sid', 'audio/x-speex',
        'audio/x-tak', 'audio/x-tta', 'audio/x-twinvq', 'audio/x-voc',
        'audio/x-vorbis', 'audio/x-vorbis+ogg', 'audio/x-wav',
        'audio/x-wavpack-correction', 'audio/x-wavpack', 'audio/x-wv',
        'audio/x-xi', 'audio/x-xm', 'audio/xm', 'sound/aiff', 'sound/dff',
        'sound/dsf', 'video/ogg', 'video/x-matroska', 'video/x-ms-asf',
        'video/x-ogm+ogg', 'video/x-theora', 'video/x-theora+ogg'
    )

    static [string[]]$DsdValues = @(
        'audio/x-wavpack-correction', 'audio/x-dff', 'audio/dff', 'sound/dff',
        'application/x-dff', 'audio/x-dsf', 'audio/dsf', 'sound/dsf',
        'application/x-dsf'
    )

    static [string[]]$LosslessValues = @(
        'audio/x-flac', 'application/x-flac', 'audio/flac', 'audio/alac',
        'audio/ape', 'application/x-ape', 'audio/x-tak', 'audio/x-tta',
        'audio/x-wavpack', 'audio/x-wv', 'audio/x-wavpack-correction',
        'audio/x-dff', 'audio/dff', 'sound/dff', 'application/x-dff',
        'audio/x-dsf', 'audio/dsf', 'sound/dsf', 'application/x-dsf',
        'audio/x-ms-wma', 'audio/vnd.dts.hd', 'audio/true-hd',
        'audio/vnd.dts.hd;profile=lbr', 'audio/vnd.dolby.mlp',
        'application/vnd.dolby.mlp', 'audio/atrac-advanced-lossless'
    )

    [string[]] GetValidValues() {
        return [ValidAudioMimeTypes]::ValidValues;
    }

    [string[]] GetDsdValues() {
        return [ValidAudioMimeTypes]::DsdValues;
    }

    [string[]] GetLosslessValues() {
        return [ValidAudioMimeTypes]::LosslessValues;
    }

    [string[]] GetPcmValues() {
        # Get all MIME types except DSD ones.
        $valuesSet = [System.Collections.Generic.HashSet[string]]::new(
            [ValidAudioMimeTypes]::ValidValues);
        $valuesSet.ExceptWith([ValidAudioMimeTypes]::DsdValues);

        # Prepare result.
        [string[]]$result = [string[]]::new($valuesSet.Count);
        $valuesSet.CopyTo($result);

        return $result;
    }

    [string[]] GetPcmLosslessValues() {
        # Get all lossless MIME types except DSD ones.
        $valuesSet = [System.Collections.Generic.HashSet[string]]::new(
            [ValidAudioMimeTypes]::LosslessValues);
        $valuesSet.ExceptWith([ValidAudioMimeTypes]::DsdValues);

        # Prepare result.
        [string[]]$result = [string[]]::new($valuesSet.Count);
        $valuesSet.CopyTo($result);

        return $result;
    }

    [string[]] GetFlacValues() {
        return @('audio/x-flac', 'application/x-flac', 'audio/flac');
    }
}

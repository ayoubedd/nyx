{ config, pkgs, ... }: {
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;

    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-desktop-portal
      ];

      config = {
        common = { default = [ "gtk" ]; };
        hyprland = { default = [ "hyprland" "gtk" ]; };
      };

      xdgOpenUsePortal = true;

      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        xdg-desktop-portal
      ];
    };

    mimeApps.enable = true;

    mimeApps.defaultApplications = let
      gen_default_app = app: list:
        builtins.listToAttrs (map (type: {
          name = type;
          value = app;
        }) list);
    in gen_default_app "firefox.desktop" [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/chrome"
      "text/html"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/xhtml+xml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ] // gen_default_app "imv.desktop" [
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/heif"
      "image/jpeg"
      "image/jpg"
      "image/pbm"
      "image/pjpeg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/webp"
      "image/x-bmp"
      "image/x-exr"
      "image/x-png"
      "image/x-portable-anymap"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
    ] // gen_default_app "org.pwmt.zathura.desktop" [
      "application/pdf"
      "application/oxps"
      "application/epub+zip"
      "application/x-fictionbook"
    ] // gen_default_app "mpv.desktop" [
      "application/ogg"
      "application/x-ogg"
      "application/mxf"
      "application/sdp"
      "application/smil"
      "application/x-smil"
      "application/streamingmedia"
      "application/x-streamingmedia"
      "application/vnd.rn-realmedia"
      "application/vnd.rn-realmedia-vbr"
      "audio/aac"
      "audio/x-aac"
      "audio/vnd.dolby.heaac.1"
      "audio/vnd.dolby.heaac.2"
      "audio/aiff"
      "audio/x-aiff"
      "audio/m4a"
      "audio/x-m4a"
      "application/x-extension-m4a"
      "audio/mp1"
      "audio/x-mp1"
      "audio/mp2"
      "audio/x-mp2"
      "audio/mp3"
      "audio/x-mp3"
      "audio/mpeg"
      "audio/mpeg2"
      "audio/mpeg3"
      "audio/mpegurl"
      "audio/x-mpegurl"
      "audio/mpg"
      "audio/x-mpg"
      "audio/rn-mpeg"
      "audio/musepack"
      "audio/x-musepack"
      "audio/ogg"
      "audio/scpls"
      "audio/x-scpls"
      "audio/vnd.rn-realaudio"
      "audio/wav"
      "audio/x-pn-wav"
      "audio/x-pn-windows-pcm"
      "audio/x-realaudio"
      "audio/x-pn-realaudio"
      "audio/x-ms-wma"
      "audio/x-pls"
      "audio/x-wav"
      "video/mpeg"
      "video/x-mpeg2"
      "video/x-mpeg3"
      "video/mp4v-es"
      "video/x-m4v"
      "video/mp4"
      "application/x-extension-mp4"
      "video/divx"
      "video/vnd.divx"
      "video/msvideo"
      "video/x-msvideo"
      "video/ogg"
      "video/quicktime"
      "video/vnd.rn-realvideo"
      "video/x-ms-afs"
      "video/x-ms-asf"
      "audio/x-ms-asf"
      "application/vnd.ms-asf"
      "video/x-ms-wmv"
      "video/x-ms-wmx"
      "video/x-ms-wvxvideo"
      "video/x-avi"
      "video/avi"
      "video/x-flic"
      "video/fli"
      "video/x-flc"
      "video/flv"
      "video/x-flv"
      "video/x-theora"
      "video/x-theora+ogg"
      "video/x-matroska"
      "video/mkv"
      "audio/x-matroska"
      "application/x-matroska"
      "video/webm"
      "audio/webm"
      "audio/vorbis"
      "audio/x-vorbis"
      "audio/x-vorbis+ogg"
      "video/x-ogm"
      "video/x-ogm+ogg"
      "application/x-ogm"
      "application/x-ogm-audio"
      "application/x-ogm-video"
      "application/x-shorten"
      "audio/x-shorten"
      "audio/x-ape"
      "audio/x-wavpack"
      "audio/x-tta"
      "audio/AMR"
      "audio/ac3"
      "audio/eac3"
      "audio/amr-wb"
      "video/mp2t"
      "video/MP2T"
      "audio/flac"
      "audio/mp4"
      "application/x-mpegurl"
      "video/vnd.mpegurl"
      "application/vnd.apple.mpegurl"
      "audio/x-pn-au"
      "video/3gp"
      "video/3gpp"
      "video/3gpp2"
      "audio/3gpp"
      "audio/3gpp2"
      "video/dv"
      "audio/dv"
      "audio/opus"
      "audio/vnd.dts"
      "audio/vnd.dts.hd"
      "audio/x-adpcm"
      "application/x-cue"
      "audio/m3u"
    ];

    userDirs = {
      enable = true;
      createDirectories = true;

      # Define standard XDG user directories
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
    };

    # Define standard XDG base directories
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Set environment variables
  home.sessionVariables = {
    # Base XDG directories
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_STATE_HOME = config.xdg.stateHome;
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";

    # User directories
    XDG_DESKTOP_DIR = config.xdg.userDirs.desktop;
    XDG_DOCUMENTS_DIR = config.xdg.userDirs.documents;
    XDG_DOWNLOAD_DIR = config.xdg.userDirs.download;
    XDG_MUSIC_DIR = config.xdg.userDirs.music;
    XDG_PICTURES_DIR = config.xdg.userDirs.pictures;
    XDG_PUBLICSHARE_DIR = config.xdg.userDirs.publicShare;
    XDG_TEMPLATES_DIR = config.xdg.userDirs.templates;
    XDG_VIDEOS_DIR = config.xdg.userDirs.videos;
  };
}

{ config, lib, ... }:
{
  programs.mpv.enable = true;

  programs.mpv.config = {
    # General
    gpu-api = "vulkan";
    vulkan-async-compute = "yes";
    vulkan-async-transfer = "yes";
    vulkan-queue-count = 1;
    keepaspect = "";
    dither-depth = "auto";

    # Start in fullscreen mode by default.
    fs = "yes";

    # Disable the On Screen Controller (OSC).
    osc = "no";

    # Use a large seekable RAM cache even for local input.
    cache = "yes";

    # Use extra large RAM cache (needs cache=yes to make it useful).
    demuxer-max-bytes = "512M";
    demuxer-max-back-bytes = "128M";

    # Stop the screensaver when playing.
    stop-screensaver = "yes";

    # Uses GPU-accelerated video output by default.
    vo = "gpu-next";

    # Can cause performance problems with some GPU drivers and GPUs.
    profile = "gpu-hq";

    # Enables best HW decoder; turn off for software decoding
    hwdec = "auto-safe";

    # Saves the seekbar position on exit
    save-position-on-quit = "yes";

    # Audio
    volume = 60;
    volume-max = 100;
    alang = "ar,en,eng";

    # Hides the cursor automatically
    cursor-autohide = 100;

    # Subtitle
    sub-visibility = "no";
    sub-auto = "fuzzy";
    sub-font = lib.mkForce "Noto Sans";
    slang = "ar,en,eng";

    # Screenshots
    screenshot-format = "png";
    screenshot-high-bit-depth = "no";
    screenshot-tag-colorspace = "yes";
    screenshot-png-compression = 9;
    screenshot-directory = "~/Pictures/Screenshots/";
    screenshot-template = "mpvsnap-20%ty-%tm-%td-%tHh%tMm%tSs";
  };

  programs.mpv.bindings = {
    "q" = "quit"; # quit
    "ESC" = "set fullscreen no"; # leave fullscreen

    "h" = "no-osd seek -5"; # seek 5 seconds forward
    "l" = "no-osd seek 5"; # seek 5 seconds backward
    "k" = "add volume 5"; # volume up 5
    "j" = "add volume -5"; # volume down 5
    "m" = "no-osd cycle mute"; # toggle mute

    "[" = "multiply speed 1/1.1"; # decrease the playback speed
    "]" = "multiply speed 1.1"; # increase the playback speed
    "0" = "set speed 1.0"; # reset the speed to normal
    "." = "frame-step"; # advance one frame and pause
    "," = "frame-back-step"; # go back by one frame and pause

    "p" = "show-progress"; # "show"; = playback progress
    "s" = "screenshot"; # take a screenshot of the video in its original resolution with subtitles
    "S" = "screenshot video"; # take a screenshot of the video in its original resolution without subtitles

    "Alt+h" = "add video-pan-x  0.1"; # move the video right
    "Alt+l" = "add video-pan-x   -0.1"; # move the video left
    "Alt+k" = "add video-pan-y  0.1"; # move the video down
    "Alt+j" = "add video-pan-y   -0.1"; # move the video up
    "Alt++" = "add video-zoom    0.1"; # zoom in
    "Alt+-" = "add video-zoom   +0.1"; # zoom out
    "Alt+R" = "set video-zoom 0; set video-pan-x 0; set video-pan-y 0 "; # reset zoom and pan settings

    "Shift+j" = "cycle sub"; # switch subtitle track
    "Shift+k" = "cycle audio"; # switch audio track
    "Shift+l" = "cycle video"; # switch video track
  };
}

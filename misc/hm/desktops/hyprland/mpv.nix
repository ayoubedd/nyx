{ config, lib, ... }:
{
  programs.mpv.enable = true;

  programs.mpv.config = {
    gpu-api = "vulkan";
    vulkan-async-compute = "yes";
    vulkan-async-transfer = "yes";
    vulkan-queue-count = 4;
    vo = "gpu-next";
    hwdec = "vaapi";
    vo-vaapi-scaling = "fast";
    profile = "fast";

    # Start in fullscreen mode by default.
    fs = "yes";

    cache = "yes";
    cache-secs = 10;

    # Disable the On Screen Controller (OSC).
    osc = "no";

    # Stop the screensaver when playing.
    stop-screensaver = "yes";

    # Saves the seekbar position on exit
    save-position-on-quit = "yes";

    # Audio
    volume = 60;
    volume-max = 100;
    alang = "ar,en,eng";

    # Hides the cursor automatically
    cursor-autohide = 100;

    # Subtitle
    sub-visibility = "yes";
    sub-auto = "fuzzy";
    sub-font = lib.mkForce "Noto Sans";
    slang = "ar,en,eng";

    # Screenshots
    screenshot-format = "png";
    screenshot-high-bit-depth = "no";
    screenshot-tag-colorspace = "yes";
    screenshot-png-compression = 9;
    screenshot-directory = "~/Pictures/Screenshots/mpv/";
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

  xdg.configFile."mpv/scripts/persistance.lua" = {
    text = /* lua */ ''
      -- Script home: https://github.com/d87/mpv-persist-properties
      local utils = require "mp.utils"
      local msg = require "mp.msg"

      local opts = {
          properties = "volume,sub-scale",
      }
      (require 'mp.options').read_options(opts, "persist_properties")

      local CONFIG_ROOT = (os.getenv('APPDATA') or os.getenv('HOME')..'/.config')..'/mpv/'
      if not utils.file_info(CONFIG_ROOT) then
          -- On Windows if using portable_config dir, APPDATA mpv folder isn't auto-created
          -- In more recent mpv versions there's a mp.get_script_directory function, but i'm not using it for compatiblity
          local mpv_conf_path = mp.find_config_file("scripts") -- finds where the scripts folder is located
          local mpv_conf_dir = utils.split_path(mpv_conf_path)
          CONFIG_ROOT = mpv_conf_dir
      end
      local PCONFIG = CONFIG_ROOT..'persistent_config.json';

      local function split(input)
          local ret = {}
          for str in string.gmatch(input, "([^,]+)") do
              table.insert(ret, str)
          end
          return ret
      end
      local persisted_properties = split(opts.properties)

      local print = function(...)
          -- return msg.log("info", ...)
      end

      -- print("Config Root is "..CONFIG_ROOT)

      local isInitialized = false

      local properties

      local function load_config(file)
          local f = io.open(file, "r")
          if f then
              local jsonString = f:read()
              f:close()

              if jsonString == nil then
                  return {}
              end

              local props = utils.parse_json(jsonString)
              if props then
                  return props
              end
          end
          return {}
      end

      local function save_config(file, properties)
          local serialized_props = utils.format_json(properties)

          local f = io.open(file, 'w+')
          if f then
              f:write(serialized_props)
              f:close()
          else
              msg.log("error", string.format("Couldn't open file: %s", file))
          end
      end

      local save_timer = nil
      local got_unsaved_changed = false

      local function onInitialLoad()
          properties = load_config(PCONFIG)

          for i, property in ipairs(persisted_properties) do
              local name = property
              local value = properties[name]
              if value ~= nil then
                  mp.set_property_native(name, value)
              end
          end

          for i, property in ipairs(persisted_properties) do
              local property_type = nil
              mp.observe_property(property, property_type, function(name)
                  if isInitialized then
                      local value = mp.get_property_native(name)
                      -- print(string.format("%s changed to %s at %s", name, value,  os.time()))

                      properties[name] = value

                      if save_timer then
                          save_timer:kill()
                          save_timer:resume()
                          got_unsaved_changed = true
                      else
                          save_timer = mp.add_timeout(5, function()
                              save_config(PCONFIG, properties)
                              got_unsaved_changed = false
                          end)
                      end
                  end
              end)
          end

          isInitialized = true
      end

      onInitialLoad()
      mp.register_event("shutdown", function()
          if got_unsaved_changed then
              save_config(PCONFIG, properties)
          end
      end)
    '';
  };

}

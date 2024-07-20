{ pkgs, ... }: {
  programs.wofi = {
    enable = true;

    settings = {
      "mode" = "drun";
      "normal_window" = "false";
      "no_actions" = "true";
      "matching" = "contains";
      "gtk_dark" = "true";
      "filter_rate" = "250";
      "allow_images" = "true";
      "allow_markup" = "true";
      "image_size" = "32px";
      "drun-display_generic" = "true";
      "dynamic_lines" = "true";
      "term" = "${pkgs.alacritty}/bin/alacritty";
      "insensitive" = "true";
      "prompt" = "Search";
      "width" = "550";
      "hide_scroll" = "true";
    };

    style = ''
      @define-color clear rgba(0, 0, 0, 0.0);
      @define-color fg #f2f4f8;
      @define-color bg #161616;
      @define-color brd #f2f4f8;
      @define-color ip_bg #353535;
      @define-color slt_bg #484848;

      window {
          border: 1px solid @brd;
          background-color: @bg;
          border-radius: 16px;
          font-family: "Noto Sans";
      }

      #input {
          padding: 4px 6px;
          margin: 4px;
          border: none;
          color: @fg;
          background-color: @ip_bg;
         	outline: none;
      }

      #inner-box {
          margin: 4px;
          border: 0px solid;
          background-color: @clear;
          border-radius: 8px;
      }

      #outer-box {
          margin: 14px;
          border: none;
          border-radius: 8px;
          background-color: @clear;
      }

      #scroll {
          margin: 0px;
          border: none;
      }

      #text {
        margin-left: 8px;
      }

      #text:selected {
          color: @fg;
          border: none;
          border-radius: 8px;
      }

      #entry {
          min-height: 30px;
          margin: 0px 0px;
          border: none;
          border-radius: 0px;
          background-color: transparent;
      }

      #entry:selected {
          margin: 0px 0px;
          border: none;
          border-radius: 8px;
          background-color: @slt_bg;
      }
    '';
  };
}

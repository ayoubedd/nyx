{ ... }: {
  services.mako = {
    enable = true;

    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    progressColor = "over #313244";
    sort = "-time";
    anchor = "top-right";
    font = "Noto Sans 10";
    width = 350;
    margin = "10,10";
    padding = "10";
    defaultTimeout = 5000;
    ignoreTimeout = false;
    groupBy = "summary";
    maxIconSize = 64;
    borderSize = 2;
    borderRadius = 5;

    # [grouped]
    # format=<b>%s</b>\n%b
    #
    # [urgency=high]
    # border-color=#fab387

  };
}

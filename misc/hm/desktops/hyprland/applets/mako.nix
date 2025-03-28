{ ... }: {
  services.mako = {
    enable = true;

    sort = "-time";
    anchor = "top-right";
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

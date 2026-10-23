// Plasma desktop script: run through org.kde.PlasmaShell.evaluateScript (install.sh does this).
// Replaces every panel with the Gruvbox Flat top bar and a left dock.
(function () {
    // knownWidgetTypes is cached when plasmashell starts, so it misses widgets
    // installed just now; addWidget still finds them. Check the result instead.
    function add(panel, type) {
        const widget = panel.addWidget(type);
        if (!widget || widget.type !== type) throw new Error("Could not add widget: " + type);
        return widget;
    }

    panels().forEach(panel => panel.remove());

    function configure(widget, group, settings) {
        widget.currentConfigGroup = [group];
        Object.keys(settings).forEach(key => widget.writeConfig(key, settings[key]));
    }

    // Full-width flat top bar.
    const bar = new Panel("org.kde.panel");
    bar.screen = 0;
    bar.location = "top";
    bar.height = 34;
    bar.lengthMode = "fill";
    bar.floating = false;
    bar.hiding = "none";
    bar.opacity = "translucent";

    const launcher = add(bar, "org.kde.plasma.kickoff");
    configure(launcher, "General", {
        icon: "applications-all-symbolic",
        systemFavorites: "suspend,hibernate,reboot,shutdown",
        favoritesPortedToKAstats: true
    });
    launcher.globalShortcut = "Alt+F1";
    add(bar, "local.gruvbox.workspaces");
    add(bar, "local.gruvbox.windowtitle");
    add(bar, "org.kde.plasma.panelspacer");
    const clock = add(bar, "org.kde.plasma.digitalclock");
    configure(clock, "Appearance", {
        autoFontAndSize: false,
        fontFamily: "JetBrainsMono Nerd Font",
        fontStyleName: "ExtraBold",
        fontWeight: 800,
        fontSize: 7,
        boldText: true,
        showDate: true,
        dateFormat: "custom",
        customDateFormat: "d MMM",
        dateDisplayFormat: 1,
        showSeconds: 1
    });
    add(bar, "org.kde.plasma.panelspacer");
    add(bar, "local.tokyonight.cat");
    [
        "org.kde.plasma.keyboardlayout",
        "org.kde.plasma.networkmanagement",
        "org.kde.plasma.brightness",
        "org.kde.plasma.volume",
        "org.kde.plasma.battery",
        "org.kde.plasma.notifications"
    ].forEach(type => {
        // Optional: brightness and battery are missing on some desktops.
        if (knownWidgetTypes.indexOf(type) >= 0) add(bar, type);
    });

    // Floating dock on the left edge that dodges windows.
    const dock = new Panel("org.kde.panel");
    dock.screen = 0;
    dock.location = "left";
    dock.alignment = "center";
    dock.height = 44;
    dock.lengthMode = "fit";
    dock.floating = true;
    dock.floatingApplets = true;
    dock.hiding = "dodgewindows";
    dock.opacity = "translucent";

    const tasks = add(dock, "org.kde.plasma.icontasks");
    configure(tasks, "General", {
        launchers: "preferred://browser,preferred://filemanager,applications:kitty.desktop",
        fill: false,
        iconSpacing: 1,
        maxStripes: 1
    });

    [bar, dock].forEach(panel => panel.reloadConfig());
    print("Gruvbox Flat layout applied: top bar " + bar.id + ", dock " + dock.id);
})();

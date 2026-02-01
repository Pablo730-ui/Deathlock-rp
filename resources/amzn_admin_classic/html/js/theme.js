AdminPanel.Theme = AdminPanel.Theme || {};

AdminPanel.Theme.init = function() {}

AdminPanel.Theme.setFont = function(fontId) {
    if(fontId == 0) {
        $("body").css("font-family", 'Nunito, sans-serif');
    } else if(fontId == 1) {
        $("body").css("font-family", 'Orbitron');
    } else if(fontId == 2) {
        $("body").css("font-family", 'Oxanium');
    } else if(fontId == 3) {
        $("body").css("font-family", 'Anta');
    } else if (fontId == 4) {
        $("body").css("font-family", 'Electrolize');
    } else if (fontId == 5) {
        $("body").css("font-family", 'Inter, sans-serif');
    } else if (fontId == 6) {
        $("body").css("font-family", 'Poppins, sans-serif');
    } else if (fontId == 7) {
        $("body").css("font-family", 'Roboto, sans-serif');
    } else if (fontId == 8) {
        $("body").css("font-family", 'Montserrat, sans-serif');
    } else if (fontId == 9) {
        $("body").css("font-family", 'Rajdhani, sans-serif');
    }
}

AdminPanel.Theme.setTheme = function(themeId) {
    $("#accordionSidebar").addClass("sidebar-dark");
    $("#accordionSidebar").removeClass("text-black-50");
    var themeName = "primary";
    if(themeId == 0) {
        themeName = "primary";
    } else if(themeId == 1) {
        themeName = "secondary";
    } else if(themeId == 2) {
        themeName = "success";
    } else if(themeId == 3) {
        themeName = "info";
    } else if(themeId == 4) {
        themeName = "danger";
    } else if(themeId == 5) {
        themeName = "dark";
    } else if(themeId == 6) {
        themeName = "yellow";
        $("#accordionSidebar").removeClass("sidebar-dark");
        $("#accordionSidebar").addClass("text-black-50");
    } else if(themeId == 7) {
        themeName = "night";
    } else if(themeId == 8) {
        themeName = "purple";
    } else if(themeId == 9) {
        themeName = "gold";
    } else if(themeId == 10) {
        themeName = "ocean";
    } else if(themeId == 11) {
        themeName = "sunset";
    } else if(themeId == 12) {
        themeName = "forest";
    } else if(themeId == 13) {
        themeName = "royal";
    } else if(themeId == 14) {
        themeName = "rosegold";
    } else if(themeId == 15) {
        themeName = "teal";
    } else if(themeId == 16) {
        themeName = "crimson";
    } else if(themeId == 17) {
        themeName = "slate";
    }
    $("#accordionSidebar").removeClass("bg-gradient-primary bg-gradient-secondary bg-gradient-success bg-gradient-info bg-gradient-warning bg-gradient-danger bg-gradient-yellow bg-gradient-dark bg-gradient-night bg-gradient-purple bg-gradient-gold bg-gradient-ocean bg-gradient-sunset bg-gradient-forest bg-gradient-royal bg-gradient-rosegold bg-gradient-teal bg-gradient-crimson bg-gradient-slate")
        .addClass("bg-gradient-"+themeName);
}

AdminPanel.Theme.toggleDarkMode = function(enabled) {
    if(enabled) {
        Toast.setTheme(TOAST_THEME.DARK);
        AdminPanel.DarkModeEnabled = true;
        $("body").removeClass("bootstrap");
        $("body").addClass("bootstrap-dark");
        $("#content-wrapper").css('background-color', '#333');
        $(".card-header").each(function(i, item) {
            $(item).addClass("text-light");
        });
        AdminPanel.UI.showAlert("success", "<strong>"+AdminPanel.Language.DarkModeTranslation+"</strong> "+AdminPanel.Language.EnabledTranslation);
        AdminPanel.Settings.set('darkMode', enabled);
    } else {
        Toast.setTheme(TOAST_THEME.LIGHT);
        AdminPanel.DarkModeEnabled = false;
        $("body").removeClass("bootstrap-dark");
        $("body").addClass("bootstrap");
        $("#content-wrapper").css('background-color', 'rgb(248, 249, 252)');
        $(".card-header").each(function(i, item) {
            $(item).removeClass("text-light");
        });
        AdminPanel.UI.showAlert("danger", "<strong>"+AdminPanel.Language.DarkModeTranslation+"</strong> "+AdminPanel.Language.DisabledTranslation);
        AdminPanel.Settings.set('darkMode', enabled);
    }
}

AdminPanel.Theme.toggleSeeThroughMode = function(enabled) {
    if(enabled) {
        AdminPanel.SeeThroughModeEnabled = true;
        $("#mainbox").fadeTo('fast', 0.9);
        AdminPanel.UI.showAlert("success", "<strong>"+AdminPanel.Language.SeeModeTranslation+"</strong> "+AdminPanel.Language.EnabledTranslation);
        AdminPanel.Settings.set('seeThrough', enabled);
    } else {
        AdminPanel.SeeThroughModeEnabled = false;
        $("#mainbox").fadeTo('fast', 1);
        AdminPanel.UI.showAlert("danger", "<strong>"+AdminPanel.Language.SeeModeTranslation+"</strong> "+AdminPanel.Language.DisabledTranslation);
        AdminPanel.Settings.set('seeThrough', enabled);
    }
}

AdminPanel.Theme.toggleNotifications = function(enabled) {
    if(enabled) {
        AdminPanel.NotificationsEnabled = true;
        AdminPanel.UI.showAlert("success", "<strong>"+AdminPanel.Language.NotificationsTranslation+":</strong> "+AdminPanel.Language.EnabledTranslation);
        AdminPanel.Settings.set('notifications', enabled);
    } else {
        AdminPanel.NotificationsEnabled = false;
        AdminPanel.UI.showAlert("danger", "<strong>"+AdminPanel.Language.NotificationsTranslation+":</strong> "+AdminPanel.Language.DisabledTranslation);
        AdminPanel.Settings.set('notifications', enabled);
    }
}

AdminPanel.Theme.togglePlayerGraph = function(enabled) {
    if(enabled) {
        AdminPanel.PlayerGraphEnabled = true;
        AdminPanel.UI.showAlert("success", "<strong>"+AdminPanel.Language.ShowPlayerGraphTranslation+":</strong> "+AdminPanel.Language.EnabledTranslation);
        AdminPanel.Settings.set('showPlayerGraph', enabled);
        $("#playercountgraph").show();
    } else {
        AdminPanel.PlayerGraphEnabled = false;
        AdminPanel.UI.showAlert("danger", "<strong>"+AdminPanel.Language.ShowPlayerGraphTranslation+":</strong> "+AdminPanel.Language.DisabledTranslation);
        AdminPanel.Settings.set('showPlayerGraph', enabled);
        $("#playercountgraph").hide();
    }
}

AdminPanel.Theme.toggleSmallMode = function(enabled) {
    if(enabled) {
        AdminPanel.SmallMode = true;
        AdminPanel.UI.showAlert("success", "<strong>"+AdminPanel.Language.SmallModeTranslation+":</strong> "+AdminPanel.Language.EnabledTranslation);
        AdminPanel.Settings.set('smallMode', enabled);
        $("#mainbox").css('width', '35vw');
        $(".sidebar").addClass('toggled');
        
        // Player page layout - vertical layout for small mode
        $("#playerInfoColumn").removeClass('col-lg-6').addClass('col-12').addClass('mb-4');
        $("#playerInteractionColumn").removeClass('col-lg-6').addClass('col-12');

        if(AdminPanel.PosLeft != null && AdminPanel.PosLeft != undefined) {
            $("#mainbox").css("right", "");
    
            $("#mainbox").css("left", AdminPanel.PosLeft);
        } else {
            $("#mainbox").css('left', '');
            $("#mainbox").css('right', '2vw');
        }
        if(AdminPanel.PosTop != null && AdminPanel.PosTop != undefined) {
            $("#mainbox").css("top", AdminPanel.PosTop);
        }
    } else {
        AdminPanel.SmallMode = false;
        AdminPanel.UI.showAlert("danger", "<strong>"+AdminPanel.Language.SmallModeTranslation+":</strong> "+AdminPanel.Language.DisabledTranslation);
        AdminPanel.Settings.set('smallMode', enabled);
        $("#mainbox").css('width', '90vw');
        $(".sidebar").removeClass('toggled');
        
        // Player page layout - side-by-side layout for normal mode
        $("#playerInfoColumn").removeClass('col-12').removeClass('mb-4').addClass('col-lg-6');
        $("#playerInteractionColumn").removeClass('col-12').addClass('col-lg-6');

        if(AdminPanel.PosLeft != null && AdminPanel.PosLeft != undefined) {
            $("#mainbox").css("right", "");
    
            $("#mainbox").css("left", AdminPanel.PosLeft);
        } else {
            $("#mainbox").css('left', '5vw');
            $("#mainbox").css('right', '');
        }
        if(AdminPanel.PosTop != null && AdminPanel.PosTop != undefined) {
            $("#mainbox").css("top", AdminPanel.PosTop);
        }
    }
}

AdminPanel.Theme.setupModes = function() {
    const settings = AdminPanel.Settings.loadAll();
    
    if(settings.darkMode === true) {
        if(!AdminPanel.DarkModeEnabled) {
            Toast.setTheme(TOAST_THEME.DARK);
            AdminPanel.DarkModeEnabled = true;
            $("body").removeClass("bootstrap");
            $("body").addClass("bootstrap-dark");
            $("#content-wrapper").css('background-color', '#333');
            $(".card-header").each(function(i, item) {
                $(item).addClass("text-light");
            });
            $('#darkmode').bootstrapToggle('on', true);
        }
    } else {
        if(AdminPanel.DarkModeEnabled) {
            Toast.setTheme(TOAST_THEME.LIGHT);
            AdminPanel.DarkModeEnabled = false;
            $("body").removeClass("bootstrap-dark");
            $("body").addClass("bootstrap");
            $("#content-wrapper").css('background-color', 'rgb(248, 249, 252)');
            $(".card-header").each(function(i, item) {
                $(item).removeClass("text-light");
            });
            $('#darkmode').bootstrapToggle('off', true);
        }
    }

    if(settings.seeThrough === true) {
        if(!AdminPanel.SeeThroughModeEnabled) {
            AdminPanel.SeeThroughModeEnabled = true;
            setTimeout(function() {
                $("#mainbox").fadeTo('fast', 0.9);
            }, 100);
            $('#seethroughmode').bootstrapToggle('on', true);
        }
    } else {
        if(AdminPanel.SeeThroughModeEnabled) {
            AdminPanel.SeeThroughModeEnabled = false;
            setTimeout(function() {
                $("#mainbox").fadeTo('fast', 1.0);
            }, 100);
            $('#seethroughmode').bootstrapToggle('off', true);
        }
    }

    if(settings.notifications === true) {
        AdminPanel.NotificationsEnabled = true;
        $('#Notifications').bootstrapToggle('on', true);
    } else {
        AdminPanel.NotificationsEnabled = false;
        $('#Notifications').bootstrapToggle('off', true);
    }

    if(settings.showPlayerGraph === true) {
        AdminPanel.PlayerGraphEnabled = true;
        $('#showplayergraph').bootstrapToggle('on', true);
        $("#playercountgraph").show();
    } else {
        AdminPanel.PlayerGraphEnabled = false;
        $('#showplayergraph').bootstrapToggle('off', true);
        $("#playercountgraph").hide();
    }

    if(settings.smallMode === true) {
        AdminPanel.SmallMode = true;
        $('#smallmode').bootstrapToggle('on', true);
        $(".sidebar").addClass('toggled');
        $("#mainbox").css('width', '35vw');
        
        // Player page layout - vertical layout for small mode
        $("#playerInfoColumn").removeClass('col-lg-6').addClass('col-12').addClass('mb-4');
        $("#playerInteractionColumn").removeClass('col-lg-6').addClass('col-12');

        if(settings.posLeft != null && settings.posLeft != undefined) {
            $("#mainbox").css("right", "");
            $("#mainbox").css("left", settings.posLeft);
            AdminPanel.PosLeft = settings.posLeft;
        } else {
            $("#mainbox").css('left', '');
            $("#mainbox").css('right', '2vw');
        }
        if(settings.posTop != null && settings.posTop != undefined) {
            $("#mainbox").css("top", settings.posTop);
            AdminPanel.PosTop = settings.posTop;
        }
    } else {
        AdminPanel.SmallMode = false;
        $('#smallmode').bootstrapToggle('off', true);
        $(".sidebar").removeClass('toggled');
        $("#mainbox").css('width', '90vw');
        
        // Player page layout - side-by-side layout for normal mode
        $("#playerInfoColumn").removeClass('col-12').removeClass('mb-4').addClass('col-lg-6');
        $("#playerInteractionColumn").removeClass('col-12').addClass('col-lg-6');

        if(settings.posLeft != null && settings.posLeft != undefined) {
            $("#mainbox").css("right", "");
            $("#mainbox").css("left", settings.posLeft);
            AdminPanel.PosLeft = settings.posLeft;
        } else {
            $("#mainbox").css('left', '5vw');
            $("#mainbox").css('right', '');
        }
        if(settings.posTop != null && settings.posTop != undefined) {
            $("#mainbox").css("top", settings.posTop);
            AdminPanel.PosTop = settings.posTop;
        }
    }

    AdminPanel.Theme.setTheme(settings.theme);
    AdminPanel.Theme.setFont(settings.font);
} 
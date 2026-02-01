AdminPanel = {
    Role: null,
    Permissions: null,
    Framework: null,
    MaxPlayers: 48,
    IsOpen: false,
    PlayerList: null,
    Language: null,
    ServerInformation: null,
    Version: "Unknown Version",
    Map: null,
    
    ConfirmingAction: null,
    ModalOpen: false,
    EditingPlayerInfo: null,
    EditingPlayerId: null,
    FiringCitizenId: null,
    FiringPlayerName: null,
    BackTo: "playerlist",
    CurrentAlertClass: null,
    NavDisabled: false,
    ReportScreenOpen: false,
    
    JobPageInfo: null,
    ResourcePageInfo: null,
    GangPageInfo: null,
    
    DarkModeEnabled: false,
    NotificationsEnabled: true,
    SeeThroughModeEnabled: false,
    ShowPlayerGraph: true,
    WarningShown: false,
    
    ServerLogs: null,
    ServerMetrics: null,
    BansList: null,
    ReportsList: null,
    AdminChat: null,
    CharactersList: null,
    ItemsList: null,
    VehiclesList: null,
    TeleportLocations: null,
    
    AdminChatOpen: false,
    LoadingAdminChat: false,
    
    PosLeft: null,
    PosTop: null,
    
    RoleColors: {
        god: "red",
        admin: "orange",
        mod: "blue"
    },
    
    $cache: {}
};

let hasAdded = false;

AdminPanel.$ = function(selector) {
    if (!AdminPanel.$cache[selector]) {
        AdminPanel.$cache[selector] = $(selector);
    }
    return AdminPanel.$cache[selector];
};

AdminPanel.clearCache = function() {
    AdminPanel.$cache = {};
};

AdminPanel.Init = function() {
    $(document).ready(function(){
        $(".btn").mouseup(function(){
            $(this).blur();
        });
        Toast.setMaxCount(6);
        Toast.enableTimers(true);
        Toast.setTheme(TOAST_THEME.LIGHT);
        Toast.setPlacement(TOAST_PLACEMENT.BOTTOM_RIGHT);
        $('[data-toggle-second="tooltip"]').tooltip();

        AdminPanel.Settings.init();
        AdminPanel.Events.init();
        AdminPanel.Map.init();
        AdminPanel.Theme.init();
    });
}

AdminPanel.ResetNav = function() {
    $('[data-toggle="tooltip"], .tooltip').tooltip("hide");
    
    const navButtons = [
        "gangpagebtn", "resourcelistpagebtn", "characterspagebtn", "dashboardpagebtn",
        "serverpagebtn", "logviewerpagebtn", "banpagebtn", "jobpagebtn", "adminchatbtn",
        "reportspagebtn", "mappagebtn", "playerlistpagebtn", "vehspagebtn", "itemspagebtn",
        "adminchatpagebtn", "leaderboardpagebtn"
    ];
    
    const pages = [
        "logviewerpage", "banpage", "adminchatpage", "reportspage", "gangpage",
        "itemspage", "playermappage", "vehiclespage", "serverpage", "dashboardpage",
        "playerpage", "jobpage", "playerlistpage", "resourcelistpage", "characterspage",
        "leaderboardPage"
    ];
    
    const $navElements = navButtons.map(id => `#${id}`).join(', ');
    const $pageElements = pages.map(id => `#${id}`).join(', ');
    
    $($navElements).removeClass("active");
    $($pageElements).hide();
    
    AdminPanel.$('#characterslisttbody').empty();
    AdminPanel.AdminChatOpen = false;
}

AdminPanel.DisableNav = function() {
    AdminPanel.NavDisabled = true;
}

AdminPanel.EnableNav = function() {
    AdminPanel.NavDisabled = false;
}

AdminPanel.Open = function(data) {
    const $loading = AdminPanel.$('#loading');
    const $mainBox = AdminPanel.$('#mainbox');
    const $contentWrapper = AdminPanel.$('#content-wrapper');
    
    $loading.hide();
    AdminPanel.Language = JSON.parse(data.Translation);
    AdminPanel.UI.translate();
    AdminPanel.EnableNav();

    AdminPanel.Settings.init();
    AdminPanel.Theme.setupModes();

    Object.assign(AdminPanel, {
        Role: data.Role,
        Permissions: data.Permissions || [], // Ensure it's always an array
        TeleportLocations: data.TeleportLocations,
        Framework: data.Framework,
        PlayerList: JSON.parse(data.playerlist),
        ServerInformation: data.serverData,
        MaxPlayers: data.maxplayers,
        Version: data.version,
        RoleColors: data.rolecolors || AdminPanel.RoleColors // Fallback to default colors
    });

    const updates = {
        '#919adminversion': AdminPanel.Version,
        '#adminname': data.name,
        '#playersonline': `${AdminPanel.PlayerList.length} / ${AdminPanel.MaxPlayers}`,
        '#staffcount': AdminPanel.ServerInformation.StaffCount
    };
    
    Object.entries(updates).forEach(([selector, value]) => {
        $(selector).html(value);
    });

    const progressPercent = (AdminPanel.PlayerList.length / AdminPanel.MaxPlayers) * 100;
    AdminPanel.$('#playersonlinebar').css({"width": `${progressPercent}%`});

    AdminPanel.$('#mainplayerlist2').empty();
    AdminPanel.$('#leaderboardPage').hide();

    AdminPanel.Charts.refreshPlayerChart();
    AdminPanel.Data.populatePlayerList();

    $mainBox.show();
    $contentWrapper.show();

    const frameworkElements = "#jobbossdisplay, #relieveStress, #setGangButton, #fireGangButton, #gangpagebtn, #savePlayer, #setWeatherButton, #setTimeButton";
    const $frameworkEls = $(frameworkElements);
    
    if (AdminPanel.Framework === "esx" || AdminPanel.Framework === "ESX") {
        $frameworkEls.hide();
    } else {
        $frameworkEls.show();
    }

    AdminPanel.IsOpen = true;
    AdminPanel.$('#dashboardpagebtn').click();
    
    $('.copyright').html('<span>919ADMIN <span id="919adminversion"></span><br />Copyright &copy; 2021-2025 919DESIGN <img src="assets/img/ca.png" class="mb-1" /></span>');
    $('#919adminversion').html(AdminPanel.Version);
    
    const settings = AdminPanel.Settings.current;
    AdminPanel.$('#themesel').val(settings.theme);
    AdminPanel.$('#fontsel').val(settings.font);

    // Setup permissions BEFORE setting up teleport locations
    AdminPanel.setupPermissions();
    AdminPanel.setupTeleportLocations();
}

AdminPanel.Close = function() {
    $('[data-toggle="tooltip"], .tooltip').tooltip("hide");
    AdminPanel.$('#mainbox').hide();
    AdminPanel.$('#content-wrapper').hide();
    $.post(`https://${GetParentResourceName()}/close`);
    AdminPanel.IsOpen = false;
}

AdminPanel.setupPermissions = function() {
    $(".action").each(function(i, item) {
        const $item = $(item);
        const action = $item.data("action");
        
        if (action && !AdminPanel.Permissions.includes(action)) {
            $item.hide();
        } else if (action) {
            $item.show(); // Ensure visible actions are shown
        }
    });

    // Check and hide empty action groups
    const actionGroups = [
        "selfactionsgroup", "serveractionsgroup", "vehicleactionsgroup",
        "devactionsgroup", "entityactionsgroup", "managementgroup"
    ];
    
    actionGroups.forEach(groupId => {
        AdminPanel.checkAndHideGroup(groupId);
    });

    // Navigation permissions mapping
    const navigationPermissions = {
        "characterspagebtn": "characterspage",
        "resourcelistpagebtn": "resourcepage", 
        "logviewerpagebtn": "serverlogs",
        "serverpagebtn": "servermetrics",
        "jobpagebtn": "jobpage",
        "gangpagebtn": "gangpage",
        "banpagebtn": "banspage",
        "vehspagebtn": "vehiclesinfo",
        "itemspagebtn": "itemsinfo",
        "adminchatpagebtn": "adminchat",
        "leaderboardpagebtn": "leaderboardinfo",
        "mappagebtn": "mapinfo",
        "reportspagebtn": "viewreports"
    };

    // Hide navigation buttons user doesn't have permission for
    Object.entries(navigationPermissions).forEach(([buttonId, permission]) => {
        const $button = AdminPanel.$(`#${buttonId}`);
        if (!AdminPanel.Permissions.includes(permission)) {
            $button.hide();
        } else {
            $button.show();
        }
    });

    // Special handling for report-related elements
    if (!AdminPanel.Permissions.includes("viewreports")) {
        AdminPanel.$('#reportspagebtn').hide();
        AdminPanel.$('#reportspage').hide();
    }

    // Special handling for admin chat
    if (!AdminPanel.Permissions.includes("adminchat")) {
        AdminPanel.$('#adminchatpagebtn').hide();
        AdminPanel.$('#adminchatpage').hide();
        AdminPanel.$('#adminchatbtn').hide();
    }

    // Update role display with color coding
    AdminPanel.updateRoleDisplay();
}

// New function to update role display with proper styling
AdminPanel.updateRoleDisplay = function() {
    const roleColor = AdminPanel.RoleColors[AdminPanel.Role] || 'gray';
    const $roleName = AdminPanel.$('#roleName');
    
    $roleName.css('color', roleColor);
    $roleName.html(`<i class="fas fa-shield-alt mr-1"></i>${AdminPanel.Role.toUpperCase()} (${AdminPanel.Framework})`);
    
    // Add role badge to indicate permission level
    let roleBadge = '';
    const permissionCount = AdminPanel.Permissions ? AdminPanel.Permissions.length : 0;
    
    switch(AdminPanel.Role) {
        case 'god':
            roleBadge = `<span class="badge badge-danger ml-2">${permissionCount} permissions</span>`;
            break;
        case 'admin':
            roleBadge = `<span class="badge badge-warning ml-2">${permissionCount} permissions</span>`;
            break;
        case 'mod':
            roleBadge = `<span class="badge badge-info ml-2">${permissionCount} permissions</span>`;
            break;
        default:
            roleBadge = `<span class="badge badge-secondary ml-2">${permissionCount} permissions</span>`;
    }
    
    $roleName.append(roleBadge);
}

// Enhanced function to check if user has a specific permission
AdminPanel.hasPermission = function(permission) {
    if (!AdminPanel.Permissions || !Array.isArray(AdminPanel.Permissions)) {
        return false;
    }
    
    const hasPermission = AdminPanel.Permissions.includes(permission);
    return hasPermission;
}

// Enhanced function to check and hide empty groups
AdminPanel.checkAndHideGroup = function(groupId) {
    const $group = AdminPanel.$(`#${groupId}`);
    if ($group.length === 0) return;
    
    let visibleActions = 0;
    
    $group.find('.action').each(function() {
        if ($(this).is(":visible")) {
            visibleActions++;
        }
    });
    
    if (visibleActions === 0) {
        $group.hide();
    } else {
        $group.show();
    }
}

AdminPanel.setupTeleportLocations = function() {
    const $locationDropdown = AdminPanel.$('#locationdropdown');
    $locationDropdown.empty();
    
    const dropdownItems = AdminPanel.TeleportLocations.map(item => 
        `<a class="dropdown-item action" href="#" data-action="sendto${item.id}">${item.label}</a>`
    ).join('');
    
    $locationDropdown.html(dropdownItems);

    if (AdminPanel.hasPermission("teleport")) {
        const $teleportsGroup = AdminPanel.$('#teleportsgroup');
        $teleportsGroup.empty();
        
        const teleportButtons = AdminPanel.TeleportLocations.map(item => {
            const label = `GOTO ${item.label.toUpperCase()}`;
            return `<button class="btn btn-primary btn-sm action mb-2 mr-2" data-action="gotolocation${item.id}">
                        <i class="fas fa-map-marker-alt mr-1"></i>
                        <span>${label}</span>
                    </button>`;
        }).join('');
        
        const cardHtml = `
            <div class="card h-100 shadow-sm">
                <div class="card-header bg-gradient-dark text-white">
                    <h6 class="mb-0 font-weight-bold">
                        <i class="fas fa-location-arrow mr-2"></i>
                        Teleport Actions
                    </h6>
                </div>
                <div class="card-body">
                    ${teleportButtons}
                </div>
            </div>
        `;
        
        $teleportsGroup.append(cardHtml);
    }
}

// Utility function to check multiple permissions (OR logic)
AdminPanel.hasAnyPermission = function(...permissions) {
    return permissions.some(permission => AdminPanel.hasPermission(permission));
}

// Utility function to check multiple permissions (AND logic)  
AdminPanel.hasAllPermissions = function(...permissions) {
    return permissions.every(permission => AdminPanel.hasPermission(permission));
}

// Utility function to get permission level for display
AdminPanel.getPermissionLevel = function() {
    const permissionCount = AdminPanel.Permissions ? AdminPanel.Permissions.length : 0;
    
    if (AdminPanel.Role === 'god') {
        return { level: 'God Admin', count: permissionCount, color: 'danger' };
    } else if (AdminPanel.Role === 'admin') {
        return { level: 'Administrator', count: permissionCount, color: 'warning' };
    } else if (AdminPanel.Role === 'mod') {
        return { level: 'Moderator', count: permissionCount, color: 'info' };
    } else {
        return { level: 'Custom Role', count: permissionCount, color: 'secondary' };
    }
}

// Function to refresh permissions (useful if permissions change during session)
AdminPanel.refreshPermissions = function() {
    AdminPanel.setupPermissions();
    AdminPanel.setupTeleportLocations();
}

AdminPanel.PreparePage = function(pageName) {
    const pageConfigs = {
        gangpage: { endpoint: 'LoadGangInfo', hideElement: '#ganglist' },
        jobpage: { endpoint: 'LoadJobInfo', hideElement: '#joblist' },
        resourcelistpage: { endpoint: 'LoadResourcesInfo', hideElement: '#resourcelist' },
        servermetricspage: { endpoint: 'LoadServerMetrics', hideElement: '#serverpage' },
        banpage: { endpoint: 'LoadBansInfo', hideElement: '#banpage' },
        reportspage: { endpoint: 'LoadReportsInfo', hideElement: '#reportspage' },
        adminchat: { 
            endpoint: 'LoadAdminChat', 
            hideElement: '#adminchatpage',
            extraAction: () => { AdminPanel.LoadingAdminChat = true; }
        },
        logviewer: { endpoint: 'LoadLogs', hideElement: '#logspage' },
        characters: { endpoint: 'LoadCharacters', hideElement: '#characterspage' },
        items: { endpoint: 'LoadItemsInfo', hideElement: '#itemspage' },
        vehicles: { endpoint: 'LoadVehiclesInfo', hideElement: '#vehiclespage' },
        leaderboard: { endpoint: 'LoadLeaderboardInfo', hideElement: '#leaderboardpage' },
        playermappage: { endpoint: 'LoadPlayerMap', hideElement: '#playermappage' }
    };
    
    const config = pageConfigs[pageName];
    if (config) {
        $.post(`https://${GetParentResourceName()}/${config.endpoint}`);
        AdminPanel.$(config.hideElement).hide();
        AdminPanel.$('#loading').show();
        AdminPanel.DisableNav();
        
        if (config.extraAction) {
            config.extraAction();
        }
    }
}

AdminPanel.Init(); 
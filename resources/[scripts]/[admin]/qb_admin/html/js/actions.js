AdminPanel.Actions = AdminPanel.Actions || {};

AdminPanel.Actions.resetIdentifiersToHidden = function() {
    const $identifiers = AdminPanel.$('#identifiers');
    const $eyeIcon = AdminPanel.$('.fa-eye');
    
    // Reset to hidden state with dots
    $identifiers.html('••••••••••••••••••••');
    
    // Reset eye icon to show state (not revealed)
    $eyeIcon.removeClass('fa-eye-slash').addClass('fa-eye').attr('title', 'Click to reveal identifiers');
};

AdminPanel.Actions.viewOnlinePlayer = function(playerId) {
    const player = AdminPanel.PlayerList.find((item, index) => {
        if (item.id == playerId) {
            editingplayerindex = index;
            return true;
        }
        return false;
    });
    
    if (player) {
        AdminPanel.EditingPlayerId = playerId;
        AdminPanel.EditingPlayerInfo = AdminPanel.PlayerList[parseInt(editingplayerindex)];
        AdminPanel.Actions.setupPlayerInfo();
    }
}

AdminPanel.Actions.viewOfflinePlayer = function(playerData) {
    editingplayerindex = -1;
    AdminPanel.EditingPlayerId = -1;
    AdminPanel.EditingPlayerInfo = playerData;
    AdminPanel.Actions.setupPlayerInfo();
}

AdminPanel.Actions.formatGender = function(gender) {
    const genderMap = {
        'm': `<span style="color:aqua"><i class="fas fa-mars"></i> ${AdminPanel.Language.maleTranslation}</span>`,
        'f': `<span style="color:deeppink"><i class="fas fa-venus"></i> ${AdminPanel.Language.femaleTranslation}</span>`
    };
    
    return genderMap[gender] || (gender ? 
        `<span style="color:deeppink"><i class="fas fa-venus"></i> ${AdminPanel.Language.femaleTranslation}</span>` :
        `<span style="color:aqua"><i class="fas fa-mars"></i> ${AdminPanel.Language.maleTranslation}</span>`
    );
}

AdminPanel.Actions.formatDateTime = function(timestamp) {
    const date = new Date(timestamp);
    return {
        date: date.toLocaleDateString("en-US"),
        time: date.toLocaleTimeString("en-US")
    };
}

AdminPanel.Actions.formatProgressStat = function(value, precision = 2) {
    const percent = parseFloat(value).toFixed(precision);
    return {
        display: `${percent}%`,
        width: `${percent}%`
    };
}

AdminPanel.Actions.formatPlayerStatus = function(playerId) {
    return playerId === -1 ? 
        '<span class="badge badge-danger">OFFLINE</span>' :
        `<span class="badge badge-success">${playerId}</span>`;
}

AdminPanel.Actions.formatJailStatus = function(inJail) {
    return inJail ? 
        `${AdminPanel.Language.yesTranslation}` :
        `${AdminPanel.Language.noTranslation}`;
}

AdminPanel.Actions.setupPlayerInfo = function() {
    const $cached = AdminPanel.$ || $;
    
    $("#loading").show();
    AdminPanel.ResetNav();
    
    if (!AdminPanel.EditingPlayerInfo) {
        $("#loading").hide();
        return;
    }
    
    const playerInfo = AdminPanel.EditingPlayerInfo;
    const isOnline = AdminPanel.EditingPlayerId !== -1;
    
    const dateTime = AdminPanel.Actions.formatDateTime(playerInfo.lastonline);
    const gender = AdminPanel.Actions.formatGender(playerInfo.gender);
    const injail = AdminPanel.Actions.formatJailStatus(playerInfo.injail);
    const playerStatus = AdminPanel.Actions.formatPlayerStatus(AdminPanel.EditingPlayerId);
    
    const hunger = AdminPanel.Actions.formatProgressStat(playerInfo.hunger);
    const thirst = AdminPanel.Actions.formatProgressStat(playerInfo.thirst);
    const health = AdminPanel.Actions.formatProgressStat(playerInfo.health);
    const armor = AdminPanel.Actions.formatProgressStat(playerInfo.armor);
    
    const basicUpdates = {
        '#heading': `${playerInfo.name} (${playerInfo.charname}) ${playerStatus}`,
        '#steamid': playerInfo.steamid,
        '#identifiers-real': (() => {
            try {
                const identifiers = JSON.parse(playerInfo.identifiers);
                return Array.isArray(identifiers) ? identifiers.join(', ') : playerInfo.identifiers;
            } catch (e) {
                return playerInfo.identifiers;
            }
        })(),
        '#role': playerInfo.role,
        '#cash': playerInfo.cash,
        '#bank': playerInfo.bank,
        '#job': playerInfo.job,
        '#jobboss': playerInfo.jobboss,
        '#citizenid': playerInfo.citizenid,
        '#gender': gender,
        '#nationality': playerInfo.nationality,
        '#phoneno': playerInfo.phone,
        '#injail': injail,
        '#lastOnline': `${dateTime.date} ${dateTime.time}`,
        '#amountofVehicles': playerInfo.amountofVehicles,
        '#rank': playerInfo.rank,
        '#duty': playerInfo.duty,
        '#gang': playerInfo.gang,
        '#gangrank': playerInfo.gangrank,
        '#gangboss': playerInfo.gangboss,
        '#charname': playerInfo.charname,
        '#playerid': isOnline ? AdminPanel.EditingPlayerId : "OFFLINE",
        '#playerstatus': isOnline ? `<span class="badge badge-success badge-pill px-3 py-2"><i class="fas fa-circle mr-1"></i>Online</span>` : `<span class="badge badge-danger badge-pill px-3 py-2"><i class="fas fa-circle mr-1"></i>Offline</span>`
    };
    
    Object.entries(basicUpdates).forEach(([selector, value]) => {
        $cached(selector).html(value);
    });
    
    // Reset identifiers to hidden state whenever player info is loaded
    AdminPanel.Actions.resetIdentifiersToHidden();
    
    const progressUpdates = [
        { stat: '#hunger', progress: '#foodprogress', data: hunger },
        { stat: '#thirst', progress: '#waterprogress', data: thirst },
        { stat: '#health', progress: '#healthprogress', data: health },
        { stat: '#armour', progress: '#armourprogress', data: armor }
    ];
    
    progressUpdates.forEach(({ stat, progress, data }) => {
        $cached(stat).html(data.display);
        $cached(progress).css('width', data.width);
    });
    
    editingplayer = AdminPanel.EditingPlayerId;
    
    const $onlineActions = $(".onlineactions");
    const $offlineActions = $(".offlineactions");
    const $playerPage = $("#playerpage");
    const $loading = $("#loading");
    
    $playerPage.show();
    $loading.hide();
    
    if (isOnline) {
        $onlineActions.show();
        $offlineActions.show();
    } else {
        $onlineActions.hide();
        $offlineActions.show();
    }
    
    AdminPanel.Actions.checkActionGroupsVisibility();
}

AdminPanel.Actions.checkActionGroupsVisibility = function() {
    const isOnline = AdminPanel.EditingPlayerId !== -1;
    
    const onlineGroups = [
        "#playergeneralactions",
        "#playerteleportactions", 
        "#playersurveillanceactions",
        "#playermonetaryactions",
        "#playerjobgangactions",
        "#playerinventoryactions",
        "#playerpunishmentactions"
    ];
    
    const offlineGroups = [
        "#playerofflineactions"
    ];
    
    // Show/hide online-specific groups based on player status
    onlineGroups.forEach(groupId => {
        const $group = $(groupId);
        if (isOnline) {
            $group.show();
        } else {
            $group.hide();
        }
    });
    
    // Offline groups (moderation actions) are always shown
    offlineGroups.forEach(groupId => {
        $(groupId).show();
    });
}

AdminPanel.Actions.handleAction = function($element) {
    const action = $element[0].getAttribute('data-action');
    const text = $element.text().toLowerCase();
    
    if (!action || action.length < 2) { 
        console.log('Action invalid or too short, returning');
        return; 
    }
    
    const actionData = {
        action: action, 
        id: AdminPanel.EditingPlayerInfo ? AdminPanel.EditingPlayerInfo.id : 0, 
        text: text
    };
    
    AdminPanel.ConfirmingAction = actionData;
    
    const actionHandlers = {
        'clearinv': AdminPanel.Actions.handleClearInventory,
        'kick': AdminPanel.Actions.handleKick,
        'warn': AdminPanel.Actions.handleWarn,
        'ban': AdminPanel.Actions.handleBan,
        'checkwarns': AdminPanel.Actions.handleCheckWarnings,
        'givecash': AdminPanel.Actions.handleGiveCash,
        'removecash': AdminPanel.Actions.handleRemoveCash,
        'givebank': AdminPanel.Actions.handleGiveBank,
        'removebank': AdminPanel.Actions.handleRemoveBank,
        'setpedmodel': AdminPanel.Actions.handleSetPedModel,
        'setjob': AdminPanel.Actions.handleSetJob,
        'setgang': AdminPanel.Actions.handleSetGang,
        'giveitem': AdminPanel.Actions.handleGiveItem,
        'loadipl': AdminPanel.Actions.handleLoadIpl,
        'setViewDistance': AdminPanel.Actions.handleSetViewDistance,
        'unloadipl': AdminPanel.Actions.handleUnloadIpl,
        'firegang': AdminPanel.Actions.handleFireGang,
        'firejob': AdminPanel.Actions.handleFireJob,
        'massdv': AdminPanel.Actions.handleMassDv,
        'massdp': AdminPanel.Actions.handleMassDp,
        'massdo': AdminPanel.Actions.handleMassDo,
        'setcolor': AdminPanel.Actions.handleSetColor,
        'setlivery': AdminPanel.Actions.handleSetLivery,
        'spawncar': AdminPanel.Actions.handleSpawnCar,
        'messageall': AdminPanel.Actions.handleMessageAll,
        'reviveall': AdminPanel.Actions.handleReviveAll,
        'setweather': AdminPanel.Actions.handleSetWeather,
        'settime': AdminPanel.Actions.handleSetTime
    };
    
    const handler = actionHandlers[action];
    if (handler) {
        handler();
    } else {
        $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(actionData));
    }
}

AdminPanel.Actions.handleClearInventory = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: `${lang.ClearInventoryOfPlayerTranslation}<strong>${playerName}</strong>`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.clearInventoryConfirmTranslation,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleKick = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>KICK</strong> ${playerName}? ${lang.reasonTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: `Kick ${lang.playerTranslation}`,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.reason = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleWarn = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    AdminPanel.ConfirmingAction.citizenid = AdminPanel.EditingPlayerInfo.citizenid;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.warnTranslation}</strong> ${playerName}? ${lang.reasonTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: `Warn ${lang.playerTranslation}`,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.reason = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleBan = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    const $cached = AdminPanel.$ || $;
    
    AdminPanel.ConfirmingAction.citizenid = AdminPanel.EditingPlayerInfo.citizenid;
    
    const banOptions = [
        { value: "1", text: `1 ${lang.hourTranslation}` },
        { value: "2", text: `2 ${lang.hourTranslation}` },
        { value: "4", text: `4 ${lang.hourTranslation}` },
        { value: "8", text: `8 ${lang.hourTranslation}` },
        { value: "12", text: `12 ${lang.hourTranslation}` },
        { value: "24", text: `1 ${lang.dayTranslation}` },
        { value: "48", text: `2 ${lang.dayTranslation}` },
        { value: "96", text: `4 ${lang.dayTranslation}` },
        { value: "168", text: `1 ${lang.weekTranslation}` },
        { value: "9999999", text: lang.permanentTranslation, style: "color:red" }
    ];
    
    const optionsHtml = banOptions.map(option => 
        `<option value="${option.value}" ${option.style ? `style="${option.style}"` : ''}>${option.text}</option>`
    ).join('');
    
    const modalContent = `
        <strong>BAN</strong> ${playerName}?<br/><br/>
        <select class="custom-select" name="timeamt" id="timeamt">
            ${optionsHtml}
        </select><br/>
        <input type="text" class="form-control" id="reason" placeholder="Reason">
    `;
    
    $cached('#confirm-body').html(modalContent);
    $cached('#confirm').modal('show');
    AdminPanel.ModalOpen = true;
}

AdminPanel.Actions.handleCheckWarnings = function() {
    AdminPanel.ConfirmingAction.citizenid = AdminPanel.EditingPlayerInfo.citizenid;
    $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
}

AdminPanel.Actions.handleConfirmAction = function() {
    const action = AdminPanel.ConfirmingAction.action;
    const lang = AdminPanel.Language;
    
    const validationRules = {
        ban: {
            fields: { timeamt: '#timeamt :selected', reason: '#reason' },
            validate: (values) => {
                if (!values.reason || values.reason.length <= 5) {
                    AdminPanel.UI.showAlert("danger", lang.EnterReasonLonger5Translation);
                    return false;
                }
                return true;
            },
            process: (values) => {
                AdminPanel.ConfirmingAction.timeamt = values.timeamt;
                AdminPanel.ConfirmingAction.reason = values.reason;
            }
        },
        setgang: {
            fields: { gangname: '#gangname', ganggrade: '#ganggrade' },
            validate: (values) => {
                if (values.gangname.length < 1 || values.ganggrade.length < 1) {
                    AdminPanel.UI.showAlert("danger", `<strong>ERROR:</strong>${lang.enterGangGradeTranslation}`);
                    return false;
                }
                return true;
            },
            process: (values) => {
                AdminPanel.ConfirmingAction.gangname = values.gangname;
                AdminPanel.ConfirmingAction.ganggrade = values.ganggrade;
            }
        },
        setjob: {
            fields: { jobname: '#jobname', jobgrade: '#jobgrade' },
            validate: (values) => {
                if (values.jobname.length < 1 || values.jobgrade.length < 1) {
                    AdminPanel.UI.showAlert("danger", `<strong>ERROR:</strong>${lang.enterJobGradeTranslation}`);
                    return false;
                }
                return true;
            },
            process: (values) => {
                AdminPanel.ConfirmingAction.jobname = values.jobname;
                AdminPanel.ConfirmingAction.jobgrade = values.jobgrade;
            }
        },
        giveitem: {
            fields: { itemname: '#itemname', itemamount: '#itemamount' },
            validate: (values) => {
                if (values.itemname.length < 1 || values.itemamount.length < 1) {
                    AdminPanel.UI.showAlert("danger", `<strong>ERROR:</strong>${lang.enterItemAmountTranslation}`);
                    return false;
                }
                return true;
            },
            process: (values) => {
                AdminPanel.ConfirmingAction.itemname = values.itemname;
                AdminPanel.ConfirmingAction.itemamount = values.itemamount;
            }
        },
        setcolor: {
            fields: { rgb1: '#rgb1', rgb2: '#rgb2' },
            validate: () => true,
            process: (values) => {
                AdminPanel.ConfirmingAction.primarycolor = $('#rgb1').minicolors('rgbObject');
                AdminPanel.ConfirmingAction.secondarycolor = $('#rgb2').minicolors('rgbObject');
            }
        }
    };
    
    const rule = validationRules[action];
    if (rule) {
        const values = {};
        Object.entries(rule.fields).forEach(([key, selector]) => {
            const $element = $(selector);
            values[key] = selector.includes(':selected') ? $element.val() : $element.val();
        });
        
        if (rule.validate(values)) {
            rule.process(values);
        } else {
            return;
        }
    }
    
    $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
    
    const $modal = $('#confirm');
    $modal.modal('hide');
    AdminPanel.ModalOpen = false;
    AdminPanel.ConfirmingAction = null;
}

AdminPanel.Actions.performResourceAction = function(resourceName, action) {
    $('[data-toggle="tooltip"], .tooltip').tooltip("hide");
    
    const elementsToHide = ['#resourcelistpage', '#resourcelist'];
    const elementsToShow = ['#loading'];
    
    elementsToHide.forEach(selector => $(selector).hide());
    elementsToShow.forEach(selector => $(selector).show());
    
    $.post(`https://${GetParentResourceName()}/ResourceAction`, JSON.stringify({
        resource: resourceName, 
        action: action
    }));
}

AdminPanel.Actions.handleGiveCash = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.giveCashTranslation}</strong> to ${playerName}?<br/><br/>${lang.amountTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.giveCashTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.amount = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleRemoveCash = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.removeCashTranslation}</strong> from ${playerName}?<br/><br/>${lang.amountTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.removeCashTranslation,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.amount = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleGiveBank = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.giveBankMoneyTranslation}</strong> to ${playerName}?<br/><br/>${lang.amountTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.giveBankMoneyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.amount = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleRemoveBank = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.removeBankMoneyTranslation}</strong> from ${playerName}?<br/><br/>${lang.amountTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.removeBankMoneyTranslation,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.amount = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetPedModel = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: `${lang.setPedModelForTranslation}${playerName}`,
        message: `<strong>${lang.modelName}</strong> (eg. a_c_chop, a_c_deer, mp_m_freemode_01)`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.setPedModelTranslation,
                className: 'btn-primary'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.model = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetJob = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    const modalContent = `
        <strong>${lang.setJobTranslation}</strong> of ${playerName}?<br/>
        <input type="text" class="form-control" id="jobname" placeholder="Job" style="margin-bottom:5px">
        <input type="text" class="form-control" id="jobgrade" placeholder="Grade">
    `;
    
    $('#confirm-body').html(modalContent);
    $('#confirm').modal('show');
    AdminPanel.ModalOpen = true;
    
    setTimeout(() => {
        document.getElementById('jobname').focus();
    }, 500);
}

AdminPanel.Actions.handleSetGang = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    const modalContent = `
        <strong>${lang.setGangTranslation}</strong> of ${playerName}?<br/>
        <input type="text" class="form-control" id="gangname" placeholder="Gang" style="margin-bottom:5px">
        <input type="text" class="form-control" id="ganggrade" placeholder="Grade">
    `;
    
    $('#confirm-body').html(modalContent);
    $('#confirm').modal('show');
    AdminPanel.ModalOpen = true;
    
    setTimeout(() => {
        document.getElementById('gangname').focus();
    }, 500);
}

AdminPanel.Actions.handleFireGang = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.removeTranslation}</strong> ${playerName} ${lang.FireFromTheirGangTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.FirePlayerTranslation,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleFireJob = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.removeTranslation}</strong> ${playerName} ${lang.FireFromTheirJobTranslation}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.FirePlayerTranslation,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));

                
            }
        }
    });
}

AdminPanel.Actions.handleGiveItem = function() {
    const playerName = AdminPanel.EditingPlayerInfo.name;
    const lang = AdminPanel.Language;
    
    const modalContent = `
        <strong>${lang.giveItemTranslation}</strong> to ${playerName}?<br/>
        <input type="text" class="form-control" id="itemname" placeholder="Item" style="margin-bottom:5px" autofocus>
        <input type="number" class="form-control" id="itemamount" placeholder="${lang.amountTranslation}">
    `;
    
    $('#confirm-body').html(modalContent);
    $('#confirm').modal('show');
    AdminPanel.ModalOpen = true;
    
    setTimeout(() => {
        document.getElementById('itemname').focus();
    }, 500);
}

AdminPanel.Actions.handleLoadIpl = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.loadiplTranslate,
        message: `<strong>${lang.iplNameTranslation}</strong> (eg. xm_siloentranceclosed_x17)`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.loadiplTranslate,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.ipl = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleUnloadIpl = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.unloadiplTranslate,
        message: `<strong>${lang.iplNameTranslation}</strong> (eg. xm_siloentranceclosed_x17)`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.unloadiplTranslate,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.ipl = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetViewDistance = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: '<strong>Set View Distance</strong>',
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.applyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.Distance = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleMassDv = function() {
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: lang.massdvTranslate,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.massdvTranslate,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleMassDp = function() {
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: lang.massdpTranslate,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.massdpTranslate,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleMassDo = function() {
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: lang.massdoTranslate,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.massdoTranslate,
                className: 'btn-danger'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetColor = function() {
    const lang = AdminPanel.Language;
    
    const modalContent = `
        <strong>${lang.setcolorTranslate}</strong><br/>
        <br/>
        <span><strong>RGB Primary</strong></span>
        <input type="text" id="rgb1" value="rgb(0, 0, 0)"><br/>
        <span><strong>RGB Secondary</strong></span>
        <input type="text" id="rgb2" value="rgb(0, 0, 0)">
    `;
    
    $('#confirm-body').html(modalContent);
    $('#rgb1').minicolors({format:'rgb'});
    $('#rgb2').minicolors({format:'rgb'});
    $('#confirm').modal('show');
    AdminPanel.ModalOpen = true;
    
    setTimeout(() => {
        document.getElementById('rgb1').focus();
    }, 500);
}

AdminPanel.Actions.handleSetLivery = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.setliveryTranslate}</strong><br/><span><strong>Livery #</strong></span>`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.applyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.livery = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSpawnCar = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.spawnvehicleTranslate}</strong><br/><span><strong>${lang.modelName}</strong></span>`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.applyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.model = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleMessageAll = function() {
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.messageallTranslate}</strong><br/><span><strong>${lang.messageTranslation}</strong></span>`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.sendTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.message = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleReviveAll = function() {
    const lang = AdminPanel.Language;
    
    bootbox.confirm({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.reviveallTranslate}</strong>`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.reviveallTranslate,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result) {
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetWeather = function() {
    const lang = AdminPanel.Language;
    
    const weatherOptions = [
        { text: lang.ChoseOneTranslation, value: '' },
        { text: lang.EXTRASUNNYTranslation, value: 'EXTRASUNNY' },
        { text: lang.CLEARTranslation, value: 'CLEAR' },
        { text: lang.NEUTRALTranslation, value: 'NEUTRAL' },
        { text: lang.SMOGTranslation, value: 'SMOG' },
        { text: lang.FOGGYTranslation, value: 'FOGGY' },
        { text: lang.OVERCASTTranslation, value: 'OVERCAST' },
        { text: lang.CLOUDSTranslation, value: 'CLOUDS' },
        { text: lang.CLEARINGTranslation, value: 'CLEARING' },
        { text: lang.RAINTranslation, value: 'RAIN' },
        { text: lang.THUNDERTranslation, value: 'THUNDER' },
        { text: lang.SNOWTranslation, value: 'SNOW' },
        { text: lang.BLIZZARDTranslation, value: 'BLIZZARD' },
        { text: lang.SNOWLIGHTTranslation, value: 'SNOWLIGHT' },
        { text: lang.XMASTranslation, value: 'XMAS' },
        { text: lang.HALLOWEENTranslate, value: 'HALLOWEEN' }
    ];
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.setweatherTranslate}</strong><br/><span><strong>${lang.WeatherTypeTranslation}</strong></span>`,
        inputType: 'select',
        inputOptions: weatherOptions,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.applyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.weather = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleSetTime = function() {
    const lang = AdminPanel.Language;
    
    const timeOptions = [
        { text: lang.ChoseOneTranslation, value: '' },
        { text: '0100', value: '1' }, { text: '0200', value: '2' }, { text: '0300', value: '3' },
        { text: '0400', value: '4' }, { text: '0500', value: '5' }, { text: '0600', value: '6' },
        { text: '0700', value: '7' }, { text: '0800', value: '8' }, { text: '0900', value: '9' },
        { text: '1000', value: '10' }, { text: '1100', value: '11' }, { text: '1200', value: '12' },
        { text: '1300', value: '13' }, { text: '1400', value: '14' }, { text: '1500', value: '15' },
        { text: '1600', value: '16' }, { text: '1700', value: '17' }, { text: '1800', value: '18' },
        { text: '1900', value: '19' }, { text: '2000', value: '20' }, { text: '2100', value: '21' },
        { text: '2200', value: '22' }, { text: '2300', value: '23' }, { text: '2400', value: '24' }
    ];
    
    bootbox.prompt({ 
        title: lang.AreYouSureTranslation,
        message: `<strong>${lang.settimeTranslate}</strong><br/><span><strong>${lang.hourTranslation}</strong></span>`,
        inputType: 'select',
        inputOptions: timeOptions,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.applyTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                AdminPanel.ConfirmingAction.time = result;
                $.post(`https://${GetParentResourceName()}/Action`, JSON.stringify(AdminPanel.ConfirmingAction));
            }
        }
    });
}

AdminPanel.Actions.handleJobListSetRank = function($element) {
    const citizenId = $element.data('player');
    const playerName = $element.data('name');
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: `${lang.setJobGradeTranslation} ${playerName}`,
        message: `${lang.JobGradeAssignedTranslation} ${playerName}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.SetGradeTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                $.post(`https://${GetParentResourceName()}/SetJobGrade`, JSON.stringify({ 
                    citizenid: citizenId, 
                    grade: result 
                }));

                setTimeout(() => {
                    AdminPanel.Events.Utils.showLoadingAndPreparePage("jobpage");
                }, 50);
            }
        }
    });
}

AdminPanel.Actions.handleGangListSetRank = function($element) {
    const citizenId = $element.data('player');
    const playerName = $element.data('name');
    const lang = AdminPanel.Language;
    
    bootbox.prompt({ 
        title: `${lang.setGangGradeTranslation} ${playerName}`,
        message: `${lang.GangGradeAssignedTranslation} ${playerName}`,
        centerVertical: true,
        buttons: {
            confirm: {
                label: lang.SetGradeTranslation,
                className: 'btn-success'
            },
            cancel: {
                label: lang.CancelTranslation,
                className: 'btn-secondary'
            }
        },
        swapButtonOrder: true,
        callback: function(result){ 
            if (result != null) {
                $.post(`https://${GetParentResourceName()}/SetGangGrade`, JSON.stringify({ 
                    citizenid: citizenId, 
                    grade: result 
                }));
            }
        }
    });
}

AdminPanel.Actions.initializeListRankHandlers = function() {
    $(document).on('click', '#joblistsetrank', function(e) {
        AdminPanel.Actions.handleJobListSetRank($(this));
    });

    $(document).on('click', '#ganglistsetrank', function(e) {
        AdminPanel.Actions.handleGangListSetRank($(this));
    });
}

$(document).ready(function() {
    AdminPanel.Actions.initializeListRankHandlers();
}); 
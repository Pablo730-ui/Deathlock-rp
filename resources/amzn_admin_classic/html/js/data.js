AdminPanel.Data = AdminPanel.Data || {};

AdminPanel.Data.CONSTANTS = {
    DEFAULT_PER_PAGE: 20,
    LEADERBOARD_PER_PAGE: 15,
    TOOLTIP_CONFIG: {
        selector: true,
        placement: "top",
        classes: {
            "ui-tooltip": "float-right"
        },
        title: function() {
            return this.getAttribute('title');
        }
    },
    FANCY_TABLE_CONFIG: {
        sortColumn: 0,
        pagination: true,
        perPage: 20,
        globalSearch: true
    }
};

AdminPanel.Data.Helpers = {
    setupFancyTable: function(tableSelector, config = {}) {
        const tableConfig = { 
            ...AdminPanel.Data.CONSTANTS.FANCY_TABLE_CONFIG, 
            ...config,
            onUpdate: function(table) {
                AdminPanel.Data.Helpers.setupTooltips();
                if (config.onUpdate && typeof config.onUpdate === 'function') {
                    config.onUpdate.call(this, table);
                }
            }
        };

        const $table = AdminPanel.$(tableSelector);
        $table.siblings('.fancySearchRow').remove();
        $table.parent().find('.fancySearchRow').remove();
        
        AdminPanel.$(tableSelector).fancyTable(tableConfig);
        AdminPanel.Utils.doFancyTableSearchClear();
    },

    setupPaginationHandler: function(perPageSelector, tableSelector, config = {}) {
        const tableConfig = { 
            ...AdminPanel.Data.CONSTANTS.FANCY_TABLE_CONFIG, 
            ...config,
            onUpdate: function(table) {
                AdminPanel.Data.Helpers.setupTooltips();
                if (config.onUpdate && typeof config.onUpdate === 'function') {
                    config.onUpdate.call(this, table);
                }
            }
        };
        AdminPanel.$(perPageSelector).off("change").on("change", function () {
            const newPerPage = parseInt(AdminPanel.$(this).val());
            
            const $table = AdminPanel.$(tableSelector);
            $table.siblings('.fancySearchRow').remove();
            $table.parent().find('.fancySearchRow').remove();
            
            AdminPanel.$(tableSelector).fancyTable({
                ...tableConfig,
                perPage: newPerPage
            });
            AdminPanel.Utils.doFancyTableSearchClear();
        });
    },

    setupTooltips: function() {
        $('[data-toggle="tooltip"]').tooltip('dispose');
        $('[data-toggle="tooltip"]').tooltip(AdminPanel.Data.CONSTANTS.TOOLTIP_CONFIG);
    },

    showPageAndEnableNav: function(pageSelector, listSelector) {
        AdminPanel.$("#loading").hide();
        AdminPanel.$(pageSelector).show();
        AdminPanel.$(listSelector).show();
        AdminPanel.EnableNav();
    },

    buildActionButtons: function(buttons) {
        return buttons.map(button => 
            `<a href="#" id="${button.id}" ${button.dataAttrs} data-toggle="tooltip" title="${button.title}" class="${button.classes}"><i class="${button.icon}"></i></a>`
        ).join(' ');
    },

    setupCompleteTable: function(tableSelector, perPageSelector, config = {}) {
        this.setupFancyTable(tableSelector, config);
        this.setupPaginationHandler(perPageSelector, tableSelector, config);
        this.setupTooltips();
    }
};

AdminPanel.Data.refresh = function(data) {
    AdminPanel.PlayerList = $.parseJSON(data.playerlist);
    AdminPanel.ServerInformation = data.serverData;
    const playerCount = AdminPanel.PlayerList.length;
    const playerCountText = `${playerCount} / ${AdminPanel.MaxPlayers}`;
    
    AdminPanel.$("#playersonline").html(playerCountText);
    AdminPanel.$("#numplayers").html(`${playerCountText} Players Online`);
    AdminPanel.$("#playersonlinebar").css({"width": (playerCount / AdminPanel.MaxPlayers) * 100});
    AdminPanel.$("#charactercount").html(AdminPanel.ServerInformation.CharacterCount);
    AdminPanel.$("#staffcount").html(AdminPanel.ServerInformation.StaffCount);
    AdminPanel.$("#banscount").html(AdminPanel.ServerInformation.BansCount);
    AdminPanel.$("#mainplayerlist2").empty();
    
    AdminPanel.Data.populatePlayerList();

    if(AdminPanel.EditingPlayerInfo && AdminPanel.EditingPlayerId) {
        $.post(`https://${GetParentResourceName()}/RequestViewPlayer`, JSON.stringify(AdminPanel.EditingPlayerInfo.citizenid));
        AdminPanel.$("#loading").show();
        AdminPanel.ResetNav();
    }
}

AdminPanel.Data.populatePlayerList = function() {
    AdminPanel.PlayerList.forEach(function (item, index) { 
        const color = AdminPanel.RoleColors[item.role] || "";
        const css = color ? `style="color:${color}"` : "";
        AdminPanel.$("#mainplayerlist2").append(
            `<tr class="player" ${css} data-playerindex="${index}" data-id="${item.id}"><td>${item.id}</td><td>${item.name}</td><td>${item.charname}</td></tr>`
        );
    });
}

AdminPanel.Data.resetJobList = function() {
    AdminPanel.$("#joblist").empty();
    for (const [key, value] of Object.entries(AdminPanel.JobPageInfo)) {
        if(key == "unemployed") { continue; }
        
        AdminPanel.$("#joblist").append(`
            <a href="#jobinfo${key}" class="list-group-item" data-toggle="collapse">
                <i class="fas fa-chevron-right"></i> Job: <strong>${key}</strong> - ${AdminPanel.Language.employeesTranslation} <strong>${value.length}</strong>
            </a>
        `);
        
        let string = `<ul class="list-group collapse" id="jobinfo${key}">`;
        value.forEach(function(item, index) {
            const actionButtons = AdminPanel.Data.Helpers.buildActionButtons([
                {
                    id: "joblistgotoplayer",
                    dataAttrs: `data-player="${item.CitizenId}" data-name="${item.Name} (${item.CharName})"`,
                    title: "View Player",
                    classes: "float-right h4",
                    icon: "fas fa-external-link-square-alt"
                },
                {
                    id: "joblistsetrank",
                    dataAttrs: `data-player="${item.CitizenId}" data-name="${item.Name} (${item.CharName})"`,
                    title: "Set Grade",
                    classes: "float-right h4",
                    icon: "fas fa-user-edit"
                },
                {
                    id: "joblistfireplayer",
                    dataAttrs: `data-name="${item.Name} (${item.CharName})" data-player="${item.CitizenId}"`,
                    title: "Fire Player",
                    classes: "float-right h4",
                    icon: "fas fa-times-circle"
                }
            ]);
            
            string += `
            <li href="#" class="list-group-item"><strong>${item.CharName}</strong> ${item.IsOnline} (CitizenId: <strong>${item.CitizenId}</strong> - Steam: <strong>${item.Name}</strong> - Grade: <strong>${item.Grade.name} - ${item.Grade.level}</strong> - Boss: <strong>${item.IsBoss}</strong>)
            ${actionButtons}
            </li>`;
        });
        string += `</ul>`;
        AdminPanel.$("#joblist").append(string);
    }
    AdminPanel.Data.Helpers.setupTooltips();
    AdminPanel.Data.Helpers.showPageAndEnableNav("#jobpage", "#joblist");
}

AdminPanel.Data.resetGangList = function() {
    AdminPanel.$("#ganglist").empty();
    if(typeof AdminPanel.GangPageInfo === 'object' && !Array.isArray(AdminPanel.GangPageInfo) && AdminPanel.GangPageInfo !== null) {
        for (const [key, value] of Object.entries(AdminPanel.GangPageInfo)) {
            if(key == "none") { continue; }
            
            AdminPanel.$("#ganglist").append(`
                <a href="#ganginfo${key}" class="list-group-item" data-toggle="collapse">
                    <i class="fas fa-chevron-right"></i> Gang: <strong>${key}</strong> - ${AdminPanel.Language.membersTranslation} <strong>${value.length}</strong>
                </a>
            `);

            let string = `<ul class="list-group collapse" id="ganginfo${key}">`;
            value.forEach(function(item, index) {
                const actionButtons = AdminPanel.Data.Helpers.buildActionButtons([
                    {
                        id: "ganglistgotoplayer",
                        dataAttrs: `data-player="${item.CitizenId}" data-name="${item.Name} (${item.CharName})"`,
                        title: "View Player",
                        classes: "float-right h4",
                        icon: "fas fa-external-link-square-alt"
                    },
                    {
                        id: "ganglistsetrank",
                        dataAttrs: `data-player="${item.CitizenId}" data-name="${item.Name} (${item.CharName})"`,
                        title: "Set Grade",
                        classes: "float-right h4",
                        icon: "fas fa-user-edit"
                    },
                    {
                        id: "ganglistfireplayer",
                        dataAttrs: `data-name="${item.Name} (${item.CharName})" data-player="${item.CitizenId}"`,
                        title: "Fire Player",
                        classes: "float-right h4",
                        icon: "fas fa-times-circle"
                    }
                ]);
                
                string += `
                    <li href="#" class="list-group-item"><strong>${item.CharName}</strong> ${item.IsOnline} (CitizenId: <strong>${item.CitizenId}</strong> - Steam: <strong>${item.Name}</strong> - Grade: <strong>${item.Grade.name} - ${item.Grade.level}</strong> - Boss: <strong>${item.IsBoss}</strong>)
                    ${actionButtons}
                    </li>`;
            });
            string += `</ul>`;
            AdminPanel.$("#ganglist").append(string);
        }
    } else {
        AdminPanel.$("#ganglist").append(`No gangs.`);
    }
    AdminPanel.Data.Helpers.setupTooltips();
    AdminPanel.Data.Helpers.showPageAndEnableNav("#gangpage", "#ganglist");
}

AdminPanel.Data.resetBansList = function() {
    AdminPanel.$("#banslisttbody").empty();
    AdminPanel.BansList.forEach(function(item, index) {
        AdminPanel.$("#banslisttbody").append(`
            <tr data-license="${item.License}">
            <th scope="row">${item.ID}</th>
            <td>${item.Name}</td>
            <td>${item.License}</td>
            <td>${item.IP}</td>
            <td>${item.Reason}</td>
            <td>${item.BannedBy}</td>
            <td>${AdminPanel.Utils.getReadableTime(item.Expire)}</td>
            <td>
            <a href="#" id="banlistunban" data-name="${item.Name}" data-license="${item.License}" data-toggle="tooltip" title="Unban Player" class="h4"><i class="fas fa-gavel"></i></a> 
            <td>
            </tr>
        `);
    });
    
    AdminPanel.Data.Helpers.setupCompleteTable("#banslisttable", "#perPageBans");
    AdminPanel.Data.Helpers.showPageAndEnableNav("#banpage", "#banslist");
}

AdminPanel.Data.resetReportsList = function() {
    AdminPanel.$("#reportslistthead").empty();
    AdminPanel.$("#reportslisttbody").empty();

    const headers = AdminPanel.SmallMode ? [
        AdminPanel.Language.ReportIdTranslation,
        AdminPanel.Language.ReportReporterTranslation,
        AdminPanel.Language.ReportTimeTranslation,
        AdminPanel.Language.ReportSubjectTranslation,
        AdminPanel.Language.ReportActionsTranslation
    ] : [
        AdminPanel.Language.ReportIdTranslation,
        AdminPanel.Language.ReportReporterTranslation,
        AdminPanel.Language.ReportTimeTranslation,
        AdminPanel.Language.ReportClaimedTranslation,
        AdminPanel.Language.ReportTypeTranslation,
        AdminPanel.Language.ReportSubjectTranslation,
        AdminPanel.Language.ReportInfoTranslation,
        AdminPanel.Language.ReportActionsTranslation
    ];

    const headerRow = headers.map(header => `<th scope="col" data-sortas="${header.includes('Id') || header.includes('Time') ? 'numeric' : 'none'}"><span>${header}</span></th>`).join('');
    AdminPanel.$("#reportslistthead").append(`<tr>${headerRow}</tr>`);

    Object.keys(AdminPanel.ReportsList).forEach(key => {
        const item = AdminPanel.ReportsList[key];
        if(item) {
            const actionButtons = AdminPanel.Data.Helpers.buildActionButtons([
                {
                    id: "reportlistviewplayer",
                    dataAttrs: `data-player="${item.SenderCitizenID}"`,
                    title: "View Player Info",
                    classes: "h4",
                    icon: "fas fa-external-link-square-alt"
                },
                {
                    id: "reportlistviewreport",
                    dataAttrs: `data-id="${key}"`,
                    title: "View Report Info",
                    classes: "h4",
                    icon: "fas fa-clipboard-list"
                },
                {
                    id: "reportlistclaimreport",
                    dataAttrs: `data-id="${key}"`,
                    title: "Claim Report",
                    classes: "h4",
                    icon: "fas fa-check-circle"
                },
                {
                    id: "reportlistdeletereport",
                    dataAttrs: `data-id="${key}"`,
                    title: "Delete Report",
                    classes: "h4",
                    icon: "fas fa-times-circle"
                }
            ]);

            if(AdminPanel.SmallMode) {
                AdminPanel.$("#reportslisttbody").append(`
                    <tr data-reportid="${key}" ${item.Claimed ? 'style="color:lime"' : 'style="color:red"'}>
                    <th scope="row">${item.SenderID}</th>
                    <td>${item.SenderName}</td>
                    <td data-sortvalue="${item.ReportTime}">${AdminPanel.Utils.timeSince(parseInt(item.ReportTime))}</td>
                    <td>${item.Subject}</td>
                    <td>${actionButtons}<td>
                    </tr>
                `);
            } else {
                AdminPanel.$("#reportslisttbody").append(`
                    <tr data-reportid="${key}" ${item.Claimed ? 'style="color:lime"' : 'style="color:red"'}>
                    <th scope="row">${item.SenderID}</th>
                    <td>${item.SenderName}</td>
                    <td data-sortvalue="${item.ReportTime}">${AdminPanel.Utils.timeSince(parseInt(item.ReportTime))}</td>
                    <td>${item.Claimed ? item.Claimed : "Not Claimed"}</td>
                    <td>${item.Type}</td>
                    <td>${item.Subject}</td>
                    <td>${AdminPanel.Utils.truncateLongString(item.Info, 45, true)}</td>
                    <td>${actionButtons}<td>
                    </tr>
                `);
            }
        }
    });
    
    AdminPanel.Data.Helpers.setupCompleteTable("#reportslisttable", "#perPageReports");
    AdminPanel.Data.Helpers.showPageAndEnableNav("#reportspage", "#reportslist");
}

AdminPanel.Data.resetAdminChat = function() {
    AdminPanel.$("#adminchatboxul").empty();
    AdminPanel.AdminChat.forEach(function(item, index) {
        AdminPanel.$("#adminchatboxul").append(`
            <li>
                <strong>${item.Sender}</strong> (${AdminPanel.Utils.timeSince(item.TimeStamp)}): ${item.Message}
            </li>
        `);
    });
    AdminPanel.$("#loading").hide();
    AdminPanel.$("#adminchatpage").show();
    AdminPanel.$("#adminchattext").focus();
    AdminPanel.EnableNav();
    AdminPanel.LoadingAdminChat = false;
    AdminPanel.AdminChatOpen = true;
    AdminPanel.$("#adminchatboxul").animate({ scrollTop: AdminPanel.$("#adminchatboxul")[0].scrollHeight }, 500);
}

AdminPanel.Data.resetItemsList = function() {
    AdminPanel.$("#itemslistthead").empty();
    AdminPanel.$("#itemslisttbody").empty();
    
    const headers = [
        AdminPanel.Language.itemNameTranslation,
        AdminPanel.Language.itemSpawnTranslation,
        AdminPanel.Language.itemWeightTranslation
    ];
    const headerRow = headers.map((header, index) => {
        const sortas = index === 2 ? 'data-sortas="numeric"' : '';
        return `<th scope="col" ${sortas}><span>${header}</span></th>`;
    }).join('');
    AdminPanel.$("#itemslistthead").append(`<tr>${headerRow}</tr>`);
    
    if (!AdminPanel.ItemsList || typeof AdminPanel.ItemsList !== 'object') {
        console.warn("AdminPanel.ItemsList is not available or not an object");
        AdminPanel.Data.Helpers.setupCompleteTable("#itemslisttable", "#perPageItems");
        AdminPanel.Data.Helpers.showPageAndEnableNav("#itemspage", "#itemslist");
        return;
    }
    
    for(const Item in AdminPanel.ItemsList) {
        const itemData = AdminPanel.ItemsList[Item];
        
        if (!itemData || typeof itemData !== 'object') {
            console.warn(`Item data for ${Item} is null or invalid`);
            continue;
        }
        
        let weight = 0;
        if (itemData.weight != null) {
            weight = AdminPanel.Framework !== "esx" ? 
                itemData.weight / 1000 : 
                itemData.weight;
        }

        const label = itemData.label || "Unknown Item";
        
        AdminPanel.$("#itemslisttbody").append(`
            <tr>
            <td>${label}</td>
            <td style="cursor: pointer" id="${Item}" class="ItemDblC">${Item}</td>
            <td data-sortvalue="${weight}">${weight} KG</td>
            </tr>
        `);
    }
    
    AdminPanel.Data.Helpers.setupCompleteTable("#itemslisttable", "#perPageItems");
    AdminPanel.Data.Helpers.showPageAndEnableNav("#itemspage", "#itemslist");
}

AdminPanel.Data.resetVehiclesList = function() {
    AdminPanel.$("#vehicleslistthead").empty();
    AdminPanel.$("#vehicleslisttbody").empty();
    
    const headers = [
        AdminPanel.Language.vehspawnNameTranslation,
        AdminPanel.Language.vehmakeTranslation,
        AdminPanel.Language.vehCategoryTranslation,
        AdminPanel.Language.vehPriceTranslation
    ];
    const headerRow = headers.map((header, index) => {
        const sortas = index === 3 ? 'data-sortas="numeric"' : '';
        return `<th scope="col" ${sortas}><span>${header}</span></th>`;
    }).join('');
    AdminPanel.$("#vehicleslistthead").append(`<tr>${headerRow}</tr>`);

    if (!AdminPanel.VehiclesList || typeof AdminPanel.VehiclesList !== 'object') {
        console.warn("AdminPanel.VehiclesList is not available or not an object");
        AdminPanel.Data.Helpers.setupCompleteTable("#vehicleslisttable", "#perPageVehicles");
        AdminPanel.Data.Helpers.showPageAndEnableNav("#vehiclespage", "#vehicleslist");
        return;
    }
    
    for(const Vehicle in AdminPanel.VehiclesList) {
        const vehicleData = AdminPanel.VehiclesList[Vehicle];
        
        if (!vehicleData || typeof vehicleData !== 'object') {
            console.warn(`Vehicle data for ${Vehicle} is null or invalid`);
            continue;
        }

        let make = "";
        if (AdminPanel.Framework === "esx") {
            make = vehicleData.name || "Unknown";
        } else {
            const brand = vehicleData.brand || "";
            const name = vehicleData.name || "Unknown";
            make = brand ? `${brand} ${name}` : name;
        }

        const category = vehicleData.category || "Unknown";
        const price = vehicleData.price != null ? vehicleData.price : 0;
        const formattedPrice = AdminPanel.Utils?.numberWithCommas ? 
            AdminPanel.Utils.numberWithCommas(price) : 
            price.toString();
        
        AdminPanel.$("#vehicleslisttbody").append(`
            <tr>
                <td style="cursor: pointer" id="${Vehicle}" class="VehicleDblC">${Vehicle}</td>
                <td>${make}</td>
                <td>${category}</td>
                <td data-sortvalue="${price}">$${formattedPrice}</td>
            </tr>
        `);
    }
    
    AdminPanel.Data.Helpers.setupCompleteTable("#vehicleslisttable", "#perPageVehicles");
    AdminPanel.Data.Helpers.showPageAndEnableNav("#vehiclespage", "#vehicleslist");
}

AdminPanel.Data.resetCharactersList = function() {
    AdminPanel.$("#characterslisttbody").empty();
    AdminPanel.CharactersList.forEach(function(item, index) {
        let rowData;
        if (item.identifier !== undefined) {
            rowData = {
                playerId: 'N/A',
                charName: `${item.firstname} ${item.lastname}`,
                citizenId: item.identifier,
                playerName: item.identifier,
                license: item.identifier
            };
        } else {
            const charInfo = JSON.parse(item.charinfo);
            rowData = {
                playerId: item.name,
                charName: `${charInfo.firstname} ${charInfo.lastname}`,
                citizenId: item.citizenid,
                playerName: item.name,
                license: item.license
            };
        }

        const actionButtons = AdminPanel.Data.Helpers.buildActionButtons([
            {
                id: "characterslistdelete",
                dataAttrs: `data-player="${rowData.citizenId}" data-name="${rowData.playerName}'s character '${rowData.charName}'"`,
                title: "Delete Character",
                classes: "h4",
                icon: "fas fa-user-times"
            },
            {
                id: "characterslistgotoplayer",
                dataAttrs: `data-player="${rowData.citizenId}" data-license="${rowData.license}"`,
                title: "View Player",
                classes: "h4",
                icon: "fas fa-external-link-square-alt"
            }
        ]);

        const playerIdCell = item.identifier !== undefined ? 
            `<td><a href="#" data-toggle="tooltip" title="Not available from database on ESX">N/A</a></td>` :
            `<td>${rowData.playerId}</td>`;

        AdminPanel.$("#characterslisttbody").append(`
            <tr data-citizenid="${rowData.citizenId}">
            ${playerIdCell}
            <td>${rowData.charName}</td>
            <th scope="row">${rowData.citizenId}</th>
            <td>${actionButtons}<td>
            </tr>
        `);
    });
    
    AdminPanel.Data.Helpers.setupCompleteTable("#characterslisttable", "#perPageCharacters");
    AdminPanel.Data.Helpers.showPageAndEnableNav("#characterspage", "#characterslist");
}

AdminPanel.Data.resetLogViewer = function() {
    AdminPanel.$("#logslisttbody").empty();
    let count = 0;
    Array.from(AdminPanel.ServerLogs).forEach(function(item, index) {
        AdminPanel.$("#logslisttbody").append(`<tr><td>${AdminPanel.Utils.getReadableTime(item.time)}</td><td>${item.from}</td><td>${AdminPanel.Utils.mdToHtml(item.message)}</td></tr>`);
        count++;
    });
    
    if(count === 0) {
        AdminPanel.$("#logslisttbody").append("<tr><td colspan='3'>No logs found.</td></tr>");
    }
    
    AdminPanel.Data.Helpers.setupCompleteTable("#logslisttable", "#perPageLogs", { sortOrder: 'descending' });
    AdminPanel.Data.Helpers.showPageAndEnableNav("#logviewerpage", "#logslist");
}

AdminPanel.Data.resetResourceList = function() {
    AdminPanel.$("#resourcethead").empty();
    AdminPanel.$("#resourcetbody").empty();
    
    const headers = [
        AdminPanel.Language.resourceNameTranslation,
        AdminPanel.Language.resourceRunningTranslation, 
        AdminPanel.Language.resourceActionsTranslation
    ];
    const headerRow = headers.map(header => `<th scope="col"><span>${header}</span></th>`).join('');
    AdminPanel.$("#resourcethead").append(`<tr>${headerRow}</tr>`);
    
    AdminPanel.ResourcePageInfo.forEach(function(item, index) {
        const isStarted = item[1] === "started" ? 
            `<span class="badge bg-success text-light">STARTED</span>` :
            `<span class="badge bg-danger text-light">STOPPED</span>`;
        
        const actionButtons = AdminPanel.Data.Helpers.buildActionButtons([
            {
                id: "startresource",
                dataAttrs: `data-resource="${item[0]}"`,
                title: "Start Resource",
                classes: "float-left listactionbutton",
                icon: "fas fa-play-circle"
            },
            {
                id: "stopresource",
                dataAttrs: `data-resource="${item[0]}"`,
                title: "Stop Resource",
                classes: "float-left listactionbutton",
                icon: "fas fa-stop-circle"
            },
            {
                id: "restartresource",
                dataAttrs: `data-resource="${item[0]}"`,
                title: "Restart Resource",
                classes: "float-left listactionbutton",
                icon: "fas fa-sync-alt"
            }
        ]);
        
        AdminPanel.$("#resourcetbody").append(`
            <tr style="border-bottom:1px solid grey;">
                <td><strong>${item[0]}</strong></td>
                <td>${isStarted}</td>
                <td>${actionButtons}</td>
            </tr>
        `);
    });
    
    AdminPanel.Data.Helpers.setupCompleteTable("#resourceinfo", "#perPageResources", { sortColumn: 1 });
    AdminPanel.Data.Helpers.showPageAndEnableNav("#resourcelistpage", "#resourcelist");
}

AdminPanel.Data.resetLeaderboardList = function() {
    const leaderboardElements = ["#maincashleaderboard2", "#mainbankleaderboard2", "#maincryptoleaderboard2", "#maincoinleaderboard2", "#mainlastseenleaderboard2"];
    leaderboardElements.forEach(element => AdminPanel.$(element).empty());
    
    AdminPanel.MoneyLeaderboard.sort((a, b) => parseFloat(b.cash) - parseFloat(a.cash));
    AdminPanel.MoneyLeaderboard.forEach(function(player) {
        AdminPanel.$("#maincashleaderboard2").append(`
            <tr>
            <td>${player.citizenid}</td>
            <td>${player.firstname} ${player.lastname}</td>
            <td data-sortvalue="${player.cash}">$${AdminPanel.Utils.numberWithCommas(player.cash)}</td>
            </tr>
        `);
        
        const date = new Date(player.lastseen).toLocaleDateString("en-US");
        AdminPanel.$("#mainlastseenleaderboard2").append(`
            <tr>
            <td>${player.citizenid}</td>
            <td>${player.firstname} ${player.lastname}</td>
            <td data-sortvalue="${player.lastseen}">${date}</td>
            </tr>
        `);
    });
    
    AdminPanel.MoneyLeaderboard.sort((a, b) => parseFloat(b.bank) - parseFloat(a.bank));
    AdminPanel.MoneyLeaderboard.forEach(function(player) {
        AdminPanel.$("#mainbankleaderboard2").append(`
            <tr>
            <td>${player.citizenid}</td>
            <td>${player.firstname} ${player.lastname}</td>
            <td data-sortvalue="${player.bank}">$${AdminPanel.Utils.numberWithCommas(player.bank)}</td>
            </tr>
        `);
    });
    
    AdminPanel.MoneyLeaderboard.sort((a, b) => parseFloat(b.crypto) - parseFloat(a.crypto));
    AdminPanel.MoneyLeaderboard.forEach(function(player) {
        if (player.crypto !== undefined) {
            AdminPanel.$("#maincryptoleaderboard2").append(`
                <tr>
                <td>${player.citizenid}</td>
                <td>${player.firstname} ${player.lastname}</td>
                <td data-sortvalue="${player.crypto}">${player.crypto}</td>
                </tr>
            `);
        }
    });
    
    if (AdminPanel.MoneyLeaderboard[0]?.coin !== undefined) {
        AdminPanel.$('.coinHidden').removeAttr('hidden');
        AdminPanel.MoneyLeaderboard.sort((a, b) => parseFloat(b.coin) - parseFloat(a.coin));
        AdminPanel.MoneyLeaderboard.forEach(function(player) {
            AdminPanel.$("#maincoinleaderboard2").append(`
                <tr>
                <td>${player.citizenid}</td>
                <td>${player.firstname} ${player.lastname}</td>
                <td data-sortvalue="${player.coin}">${player.coin}</td>
                </tr>
            `);
        });
    } else {
        AdminPanel.$('.coinHidden').attr('hidden', true);
    }
    
    if (!hasAdded) {
        const leaderboardConfig = {
            sortColumn: 2,
            pagination: true,
            perPage: AdminPanel.Data.CONSTANTS.LEADERBOARD_PER_PAGE,
            searchable: false,
            onUpdate: function(table) {
                AdminPanel.Data.Helpers.setupTooltips();
            }
        };
        
        const leaderboardTables = ["#cashLeaderboardtable", "#bankLeaderboardtable", "#cryptoLeaderboardtable", "#coinLeaderboardtable", "#lastseenLeaderboardtable"];
        leaderboardTables.forEach(table => AdminPanel.$(table).fancyTable(leaderboardConfig));
        hasAdded = true;
    }
    
    AdminPanel.Data.Helpers.showPageAndEnableNav("#leaderboardPage", "#mainleaderboard");
}
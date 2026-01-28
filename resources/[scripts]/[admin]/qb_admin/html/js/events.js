AdminPanel.Events = AdminPanel.Events || {};

AdminPanel.Events.CONSTANTS = {
    KEYS: {
        ESCAPE: "Escape",
        SPACE: " ",
        ENTER: 13
    },
    TIMEOUTS: {
        WARNING_DELAY: 5000,
        TOOLTIP_HIDE_DELAY: 100
    },
    SELECTORS: {
        TOOLTIP: '[data-toggle="tooltip"]',
        LOADING: '#loading',
        HEADING: '#heading'
    }
};

AdminPanel.Events.Elements = {
    $document: $(document),
    $loading: null,
    $heading: null,
    
    init: function() {
        this.$loading = $(AdminPanel.Events.CONSTANTS.SELECTORS.LOADING);
        this.$heading = $(AdminPanel.Events.CONSTANTS.SELECTORS.HEADING);
    }
};

AdminPanel.Events.Utils = {
    postToResource: function(endpoint, data = {}) {
        return $.post(`https://${GetParentResourceName()}/${endpoint}`, JSON.stringify(data));
    },
    
    showConfirmDialog: function(options) {
        const defaults = {
            size: "small",
            centerVertical: true,
            swapButtonOrder: true,
            buttons: {
                confirm: { className: 'btn-danger' },
                cancel: {
                    label: AdminPanel.Language?.CancelTranslation || 'Cancel',
                    className: 'btn-secondary'
                }
            }
        };
        return bootbox.confirm({ ...defaults, ...options });
    },
    
    showPromptDialog: function(options) {
        const defaults = {
            centerVertical: true,
            swapButtonOrder: true,
            buttons: {
                confirm: {
                    label: AdminPanel.Language?.ContinueTranslation || 'Continue',
                    className: 'btn-success'
                },
                cancel: {
                    label: AdminPanel.Language?.CancelTranslation || 'Cancel',
                    className: 'btn-secondary'
                }
            }
        };
        return bootbox.prompt({ ...defaults, ...options });
    },
    
    resetNavAndSetActive: function(heading, activeBtn) {
        AdminPanel.ResetNav();
        AdminPanel.Events.Elements.$heading.html(heading);
        AdminPanel.$(activeBtn).addClass("active");
    },
    
    showLoadingAndPreparePage: function(page) {
        AdminPanel.Events.Elements.$loading.show();
        AdminPanel.PreparePage(page);
    },
    
    hidePageAndShowLoading: function(pageSelector) {
        AdminPanel.$(pageSelector).hide();
        AdminPanel.Events.Elements.$loading.show();
    }
};

AdminPanel.Events.NavigationConfig = {
    'gangpagebtn': {
        heading: () => AdminPanel.Language?.gangListTranslation || 'Gang List',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("gangpage")
    },
    'dashboardpagebtn': {
        heading: () => AdminPanel.Language?.DashboardTranslation || 'Dashboard',
        action: () => {
            AdminPanel.Events.Elements.$loading.hide();
            AdminPanel.$("#dashboardpage").show();
        }
    },
    'jobpagebtn': {
        heading: () => AdminPanel.Language?.jobListTranslate || 'Job List',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("jobpage")
    },
    'serverpagebtn': {
        heading: () => AdminPanel.Language?.ServerMetricsTranslation2 || 'Server Metrics',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("servermetricspage")
    },
    'banpagebtn': {
        heading: () => AdminPanel.Language?.BanListTranslation || 'Ban List',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("banpage")
    },
    'reportspagebtn': {
        heading: () => AdminPanel.Language?.ReportsTranslation || 'Reports',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("reportspage")
    },
    'mappagebtn': {
        heading: () => AdminPanel.Language?.MapTranslation || 'Map',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("playermappage")
    },
    'adminchatbtn': {
        heading: () => AdminPanel.Language?.adminChatTranslation2 || 'Admin Chat',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("adminchat")
    },
    'characterspagebtn': {
        heading: () => AdminPanel.Language?.allCharactersTranslation || 'All Characters',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("characters")
    },
    'vehspagebtn': {
        heading: () => AdminPanel.Language?.allVehiclesTranslation || 'All Vehicles',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("vehicles")
    },
    'itemspagebtn': {
        heading: () => AdminPanel.Language?.allItemsTranslation || 'All Items',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("items")
    },
    'logviewerpagebtn': {
        heading: () => AdminPanel.Language?.LogViewerTranslation || 'Log Viewer',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("logviewer")
    },
    'leaderboardpagebtn': {
        heading: () => AdminPanel.Language?.LeaderboardsTranslation2 || 'Leaderboards',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("leaderboard")
    },
    'resourcelistpagebtn': {
        heading: () => AdminPanel.Language?.resourceListTranslation || 'Resource List',
        action: () => AdminPanel.Events.Utils.showLoadingAndPreparePage("resourcelistpage")
    }
};

AdminPanel.Events.RefreshConfig = {
    'refresh': () => AdminPanel.Events.Utils.postToResource('Refresh'),
    'refreshbtn': () => AdminPanel.Events.Utils.postToResource('Refresh'),
    'refreshbansbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#banpage");
        AdminPanel.PreparePage("banpage");
    },
    'refreshjobbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#jobpage");
        AdminPanel.PreparePage("jobpage");
    },
    'refreshreportsbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#reportspage");
        AdminPanel.PreparePage("reportspage");
    },
    'maprefreshbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#playermappage");
        AdminPanel.PreparePage("playermappage");
    },
    'refreshdbbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#serverpage");
        AdminPanel.PreparePage("servermetricspage");
    },
    'refreshlogsbtn': () => {
        AdminPanel.Events.Utils.hidePageAndShowLoading("#logviewerpage");
        AdminPanel.PreparePage("logviewer");
    }
};

AdminPanel.Events.init = function() {
    AdminPanel.Events.Elements.init();
    AdminPanel.Events.initMessageListener();
    AdminPanel.Events.initTooltips();
    AdminPanel.Events.initNavigation();
    AdminPanel.Events.initPlayerActions();
    AdminPanel.Events.initModals();
    AdminPanel.Events.initSettings();
    AdminPanel.Events.initKeyboardEvents();
    AdminPanel.Events.initDragAndDrop();
    AdminPanel.Events.initItemVehicleActions();
    AdminPanel.Events.initResourceActions();

    var entityMap = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
        '/': '&#x2F;',
        '`': '&#x60;',
        '=': '&#x3D;'
    };
      
    function escapeHtml (string) {
        return String(string).replace(/[&<>"'`=\/]/g, function (s) {
            return entityMap[s];
        });
    }

    AdminPanel.Events.Elements.$document.on('click', '#adminchatsend', function(e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
        const message = AdminPanel.$("#adminchattext").val();
        if (message) {
            AdminPanel.Events.Utils.postToResource('AdminChatSend', { message });
            AdminPanel.$("#adminchattext").val("");
            setTimeout(() => {
                AdminPanel.Events.Utils.showLoadingAndPreparePage("adminchat");
            }, 50);
        }
    });

    AdminPanel.Events.Elements.$document.on('click', '#reportsubmit', function(e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
        if ($("#inputSubject").val() == "") {
            AdminPanel.UI.showAlert("danger", AdminPanel.Language.ChoseOneTranslation);
            return;
        } if ($("#inputSubject").val().length <= 5) {
            AdminPanel.UI.showAlert("danger", AdminPanel.Language.EnterSubjectLonger5Translation);
            return;
        }else {
            var reportType = $('input[name=typeoption]:checked', '#reportform').val();
            $.post(`https://${GetParentResourceName()}/SendReport`, JSON.stringify({subject: escapeHtml($("#inputSubject").val()), info:escapeHtml($("#inputInfo").val()), type:reportType}));
            AdminPanel.CloseReportScreen();
        }
    });

    // Identifiers click to reveal/hide functionality
    AdminPanel.Events.Elements.$document.on('click', '#identifiers, .identifiers-toggle-eye', function(e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
        
        const $identifiers = AdminPanel.$('#identifiers');
        const $identifiersReal = AdminPanel.$('#identifiers-real');
        const $eyeIcon = AdminPanel.$('.identifiers-toggle-eye');
        
        // Check if currently showing dots (hidden state)
        if ($identifiers.html().includes('••••')) {
            // Currently showing dots, switch to real data
            const realData = $identifiersReal.html();
            $identifiers.html(realData);
            $eyeIcon.removeClass('fa-eye').addClass('fa-eye-slash').attr('title', 'Click to hide identifiers');
        } else {
            // Currently showing real data, switch to hidden
            $identifiers.html('••••••••••••••••••••');
            $eyeIcon.removeClass('fa-eye-slash').addClass('fa-eye').attr('title', 'Click to reveal identifiers');
        }
    });
}

AdminPanel.Events.initMessageListener = function() {
    const messageHandlers = {
        open: (data) => AdminPanel.Open(data),
        close: () => {
            AdminPanel.Close();
            AdminPanel.CloseReportScreen();
        },
        refresh: (data) => AdminPanel.Data.refresh(data),
        jobinfo: (data) => {
            AdminPanel.JobPageInfo = data.jobinfo;
            AdminPanel.Data.resetJobList();
        },
        resourceinfo: (data) => {
            AdminPanel.ResourcePageInfo = data.resourceinfo;
            AdminPanel.Data.resetResourceList();
        },
        ganginfo: (data) => {
            AdminPanel.GangPageInfo = data.ganginfo;
            AdminPanel.Data.resetGangList();
        },
        bansinfo: (data) => {
            AdminPanel.BansList = data.bansinfo;
            AdminPanel.Data.resetBansList();
        },
        reportsinfo: (data) => {
            AdminPanel.ReportsList = data.reportsinfo;
            AdminPanel.Data.resetReportsList();
        },
        adminchat: (data) => {
            AdminPanel.AdminChat = data.adminchat;
            if (AdminPanel.IsOpen && (AdminPanel.LoadingAdminChat || AdminPanel.AdminChatOpen)) {
                AdminPanel.Data.resetAdminChat();
            } else {
                const newMsg = AdminPanel.AdminChat[AdminPanel.AdminChat.length - 1];
                AdminPanel.UI.showAdminChatAlert(`<strong>${newMsg.Sender}</strong>: ${newMsg.Message}`);
            }
        },
        vehiclesinfo: (data) => {
            AdminPanel.VehiclesList = data.vehiclesinfo;
            AdminPanel.Data.resetVehiclesList();
        },
        leaderboardinfo: (data) => {
            AdminPanel.MoneyLeaderboard = data.money;
            AdminPanel.Data.resetLeaderboardList();
        },
        playermap: (data) => {
            AdminPanel.MapInfo = data.playermap;
            AdminPanel.Map.reset();
        },
        itemsinfo: (data) => {
            AdminPanel.ItemsList = data.itemsinfo;
            AdminPanel.Data.resetItemsList();
        },
        characterslist: (data) => {
            AdminPanel.CharactersList = data.characters;
            AdminPanel.Data.resetCharactersList();
        },
        logslist: (data) => {
            AdminPanel.ServerLogs = data.logs;
            AdminPanel.Data.resetLogViewer();
        },
        noperms: () => {
            AdminPanel.NavDisabled = false;
            AdminPanel.ResetNav();
            AdminPanel.Events.Elements.$heading.html("Dashboard");
            AdminPanel.$("#dashboardpagebtn").addClass("active");
            AdminPanel.Events.Elements.$loading.hide();
            AdminPanel.$("#dashboardpage").show();
        },
        servermetrics: (data) => {
            AdminPanel.ServerMetrics = data.metrics;
            const metrics = AdminPanel.ServerMetrics;
            const updates = {
                '#metricsvehiclescount': AdminPanel.Utils.numberWithCommas(metrics.VehicleCount),
                '#metricscharactercount': AdminPanel.Utils.numberWithCommas(metrics.CharacterCount),
                '#metricsstaffcount': AdminPanel.Utils.numberWithCommas(metrics.StaffCount),
                '#metricsbanscount': AdminPanel.Utils.numberWithCommas(metrics.BansCount),
                '#metricsunique': AdminPanel.Utils.numberWithCommas(metrics.UniquePlayers),
                '#metricscash': '$' + AdminPanel.Utils.numberWithCommas(Math.trunc(metrics.TotalCash)),
                '#metricsbank': '$' + AdminPanel.Utils.numberWithCommas(Math.trunc(metrics.TotalBank)),
                '#metricsitems': AdminPanel.Utils.numberWithCommas(metrics.TotalItems)
            };
            Object.entries(updates).forEach(([selector, value]) => AdminPanel.$(selector).html(value));
            AdminPanel.Events.Elements.$loading.hide();
            AdminPanel.EnableNav();
            AdminPanel.$("#serverpage").show();
        },
        clipboard: (data) => AdminPanel.Utils.clipboard(data.string),
        viewonlineplayer: (data) => AdminPanel.Actions.viewOnlinePlayer(data.playerid),
        viewofflineplayer: (data) => AdminPanel.Actions.viewOfflinePlayer(data.playerdata),
        showalert: (data) => AdminPanel.UI.showAlert(data.type, data.text),
        showreportalert: (data) => AdminPanel.UI.showReportAlert(data.title, data.text),
        showwarning: (data) => AdminPanel.UI.showWarning(data.by, data.reason, data.Translation),
        viewwarnings: (data) => AdminPanel.UI.viewWarnings(data.warnings),
        reportscreen: (data) => AdminPanel.UI.showReportScreen(data),
        resetPosition: () => {
            if (AdminPanel.Settings && AdminPanel.Settings.resetPosition) {
                AdminPanel.Settings.resetPosition();
                AdminPanel.PosLeft = null;
                AdminPanel.PosTop = null;
                const mainBox = document.querySelector("#mainbox");
                if (mainBox) {
                    mainBox.style.left = '';
                    mainBox.style.top = '';
                    mainBox.style.right = '';
                }
            }
        }
    };

    window.addEventListener('message', function(event) {
        const handler = messageHandlers[event.data.action];
        if (handler) {
            handler(event.data);
        }
    });
}

AdminPanel.Events.initTooltips = function() {
    $(document).ready(function() {
        $(AdminPanel.Events.CONSTANTS.SELECTORS.TOOLTIP).tooltip({
            selector: true,
            placement: "top",
            classes: { "ui-tooltip": "float-right" },
            title: function() { return this.getAttribute('title'); }
        });
    });
}

AdminPanel.Events.initNavigation = function() {
    Object.entries(AdminPanel.Events.NavigationConfig).forEach(([btnId, config]) => {
        AdminPanel.Events.Elements.$document.on('click', `#${btnId}`, function(e) {
            if (!AdminPanel.NavDisabled) {
                AdminPanel.Events.Utils.resetNavAndSetActive(config.heading(), `#${btnId}`);
                config.action();
            }
        });
    });

    AdminPanel.Events.Elements.$document.on('click', '#playerlistpagebtn', function(e) {
        if (!AdminPanel.NavDisabled) {
            AdminPanel.Events.Utils.resetNavAndSetActive(AdminPanel.Language?.playerListTranslation || 'Player List', "#playerlistpagebtn");
            AdminPanel.$("#numplayers").html(`${AdminPanel.PlayerList.length} / ${AdminPanel.MaxPlayers} ${AdminPanel.Language?.PlayersOnlineTranslation || 'Players Online'}`);

            AdminPanel.EditingPlayerInfo = null;
            AdminPanel.EditingPlayerId = null;

            AdminPanel.Data.Helpers.setupCompleteTable("#playerlisttable", "#perPagePlayers");
            AdminPanel.$(".pag").prop({ colspan: 4 });

            AdminPanel.Events.Elements.$loading.hide();
            AdminPanel.$("#playerlistpage").show();
        }
    });

    Object.entries(AdminPanel.Events.RefreshConfig).forEach(([btnId, handler]) => {
        AdminPanel.Events.Elements.$document.on('click', `#${btnId}`, handler);
    });

    AdminPanel.Events.Elements.$document.on('click', '#goback', function(e) {
        const backToConfig = {
            playerlist: {
                heading: AdminPanel.Language?.playerListTranslation || 'Player List',
                btn: "#playerlistpagebtn",
                page: "#playerlistpage"
            },
            joblist: {
                heading: AdminPanel.Language?.jobListTranslate || 'Job List',
                btn: "#jobpagebtn",
                page: "#jobpage"
            },
            ganglist: {
                heading: AdminPanel.Language?.gangListTranslation || 'Gang List',
                btn: "#gangpagebtn",
                page: "#gangpage"
            },
            characterslist: {
                heading: AdminPanel.Language?.allCharactersTranslation || 'All Characters',
                btn: "#characterspagebtn",
                action: () => AdminPanel.PreparePage("characters")
            },
            reports: {
                heading: AdminPanel.Language?.ReportsTranslate || 'Reports',
                btn: "#reportspagebtn",
                action: () => AdminPanel.PreparePage("reportspage")
            }
        };

        const config = backToConfig[AdminPanel.BackTo];
        if (config) {
            AdminPanel.ResetNav();
            AdminPanel.Events.Elements.$heading.html(config.heading);
            AdminPanel.$(config.btn).addClass("active");
            
            if (config.action) {
                config.action();
            } else if (config.page) {
                AdminPanel.$(config.page).show();
            }
        }

        AdminPanel.EditingPlayerId = null;
        AdminPanel.EditingPlayerInfo = null;
    });

    const simpleHandlers = {
        '#closePanelBtn': AdminPanel.Close,
        '#settingsPanelBtn': AdminPanel.UI.openSettings,
        '#reportscreenclose': AdminPanel.CloseReportScreen
    };

    Object.entries(simpleHandlers).forEach(([selector, handler]) => {
        AdminPanel.Events.Elements.$document.on('click', selector, handler);
    });
}

AdminPanel.Events.initPlayerActions = function() {
    AdminPanel.Events.Elements.$document.on('click', '.player', function(e) {
        AdminPanel.EditingPlayerId = $(this).data('id');
        const editingPlayerIndex = $(this).data('playerindex');
        AdminPanel.EditingPlayerInfo = AdminPanel.PlayerList[parseInt(editingPlayerIndex)];
        AdminPanel.Actions.setupPlayerInfo();
        AdminPanel.BackTo = "playerlist";
    });

    const firePlayerHandlers = {
        '#joblistfireplayer': {
            endpoint: 'FirePlayerFromJob',
            message: (name) => `${AdminPanel.Language?.fireTranslation || 'Fire'} <strong>${name}</strong> ${AdminPanel.Language?.FireFromTheirJobTranslation || 'from their job'}`,
            confirmLabel: () => AdminPanel.Language?.FirePlayerTranslation || 'Fire Player'
        },
        '#ganglistfireplayer': {
            endpoint: 'FirePlayerFromGang',
            message: (name) => `Remove <strong>${name}</strong> from their gang?`,
            confirmLabel: () => 'Remove Player'
        }
    };

    Object.entries(firePlayerHandlers).forEach(([selector, config]) => {
        AdminPanel.Events.Elements.$document.on('click', selector, function(e) {
            AdminPanel.FiringCitizenId = $(this).data('player');
            AdminPanel.Events.Utils.showConfirmDialog({
                title: AdminPanel.Language?.AreYouSureTranslation || 'Are you sure?',
                message: config.message($(this).data('name')),
                buttons: {
                    confirm: {
                        label: typeof config.confirmLabel === 'function' ? config.confirmLabel() : config.confirmLabel,
                        className: 'btn-danger'
                    },
                    cancel: {
                        label: AdminPanel.Language?.CancelTranslation || 'Cancel',
                        className: 'btn-secondary'
                    }
                },
                callback: function(result) {
                    if (result) {
                        AdminPanel.Events.Utils.postToResource(config.endpoint, AdminPanel.FiringCitizenId);

                        setTimeout(() => {
                            if(config.endpoint === "FirePlayerFromJob") {
                                AdminPanel.Events.Utils.showLoadingAndPreparePage("jobpage");
                            } else if(config.endpoint === "FirePlayerFromGang") {
                                AdminPanel.Events.Utils.showLoadingAndPreparePage("gangpage");
                            }
                        }, 50);
                    }
                }
            });
        });
    });

    AdminPanel.Events.Elements.$document.on('click', '#banlistunban', function(e) {
        const unbanLicense = $(this).data('license');
        const playerName = $(this).data('name');
        AdminPanel.Events.Utils.showConfirmDialog({
            title: `${AdminPanel.Language?.unbanTranslation || 'Unban'} ${playerName}?`,
            message: `${AdminPanel.Language?.confirmUnbanTranslation || 'Confirm unban'} ${playerName}?`,
            buttons: {
                confirm: {
                    label: AdminPanel.Language?.unbanTranslation || 'Unban',
                    className: 'btn-danger'
                }
            },
            callback: function(result) {
                if (result) {
                    AdminPanel.Events.Utils.postToResource('UnbanPlayer', { license: unbanLicense });
                }
            }
        });
    });

    const reportActions = {
        '#reportlistdeletereport': {
            endpoint: 'DeleteReport',
            titleKey: 'deleteReportTranslation',
            messageKey: 'confirmDeleteReportTranslation',
            labelKey: 'deleteReportTranslationC'
        },
        '#reportlistclaimreport': {
            endpoint: 'ClaimReport',
            titleKey: 'claimReportIdTranslation',
            messageKey: 'confirmClaimReport',
            labelKey: 'confirmClaimReport2',
            className: 'btn-success'
        }
    };

    Object.entries(reportActions).forEach(([selector, config]) => {
        AdminPanel.Events.Elements.$document.on('click', selector, function(e) {
            const reportId = $(this).data('id');
            AdminPanel.Events.Utils.showConfirmDialog({
                title: `${AdminPanel.Language[config.titleKey]} ${reportId}?`,
                message: `${AdminPanel.Language[config.messageKey]} ${reportId}?`,
                buttons: {
                    confirm: {
                        label: AdminPanel.Language[config.labelKey],
                        className: config.className || 'btn-danger'
                    }
                },
                callback: function(result) {
                    if (result) {
                        AdminPanel.Events.Utils.postToResource(config.endpoint, { id: reportId });
                    }
                }
            });
        });
    });

    AdminPanel.Events.Elements.$document.on('click', '#reportlistviewreport', function(e) {
        if (!AdminPanel.IsOpen) return;
        
        const reportId = $(this).data('id');
        const report = AdminPanel.ReportsList[reportId];
        
        if (!report) return;

        const lang = AdminPanel.Language;
        AdminPanel.$("#reportinfobox").empty().append(`
            <strong>${lang.ReportReporterTranslation}</strong> ${report.SenderName}<br/>
            <strong>${lang.ReportTypeTranslation}</strong> ${report.Type}<br/>
            <strong>${lang.ReportSubjectTranslation}</strong> ${report.Subject}<br/>
            <strong>${lang.ReportInfoTranslation}</strong> ${report.Info}<br/>
        `);
        
        AdminPanel.$("#reportsFooter").empty().append(`
            <button type="button" class="btn btn-secondary reportReply" cname="${report.SenderName}" id="${report.SenderCitizenID}" data-dismiss="modal">
                <span id="ReportReplyTranslation">${lang.ReportReplyTranslation}</span>
            </button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">${lang.CloseTranslation}</button>
        `);
        
        AdminPanel.ModalOpen = true;
        AdminPanel.$("#reportmodal").modal('show');
    });

    AdminPanel.Events.Elements.$document.on('click', '.reportReply', function(e) {
        const playerId = $(this).attr("id");
        const playerName = $(this).attr("cname");

        AdminPanel.Events.Utils.showPromptDialog({
            title: `${AdminPanel.Language?.replyToTranslation || 'Reply to'} ${playerName}`,
            message: `${AdminPanel.Language?.replyToConfirmTranslation || 'Reply to'} ${playerName}`,
            buttons: {
                confirm: {
                    label: AdminPanel.Language?.ReportReplyTranslation || 'Reply',
                    className: 'btn-success'
                }
            },
            callback: function(result) {
                if (result) {
                    AdminPanel.Events.Utils.postToResource('ReportReply', { name: playerId, message: result });
                }
            }
        });
    });

    const gotoPlayerActions = {
        '#joblistgotoplayer': 'joblist',
        '#characterslistgotoplayer': 'characterslist',
        '#ganglistgotoplayer': 'ganglist',
        '#reportlistviewplayer': 'reports'
    };

    Object.entries(gotoPlayerActions).forEach(([selector, backTo]) => {
        AdminPanel.Events.Elements.$document.on('click', selector, function(e) {
            if (backTo === 'characterslist') {
                AdminPanel.$("#characterspage").hide();
            }
            AdminPanel.BackTo = backTo;
            AdminPanel.Events.Utils.postToResource('RequestViewPlayer', $(this).data('player'));
            AdminPanel.Events.Elements.$loading.show();
            AdminPanel.ResetNav();
        });
    });

    AdminPanel.Events.Elements.$document.on('click', '#characterslistdelete', function(e) {
        const deletingChar = AdminPanel.$(this).data('player');
        AdminPanel.Events.Utils.showConfirmDialog({
            title: AdminPanel.Language?.AreYouSureTranslation || 'Are you sure?',
            message: `${AdminPanel.Language?.deleteTranslation || 'Delete'} ${AdminPanel.$(this).data('name')}?`,
            buttons: {
                confirm: {
                    label: AdminPanel.Language?.RemoveCharacterTranslation || 'Remove Character',
                    className: 'btn-danger'
                }
            },
            callback: function(result) {
                if (result) {
                    AdminPanel.Events.Utils.postToResource('DeleteCharacter', deletingChar);
                }
            }
        });
    });
}

AdminPanel.Events.initItemVehicleActions = function() {
    AdminPanel.Events.Elements.$document.on('dblclick', '.ItemDblC', function(e) {
        const item = $(this).attr('id');
        const lang = AdminPanel.Language;
        
        AdminPanel.Events.Utils.showPromptDialog({
            title: lang.PlayerIdTranslation,
            message: lang.itemWhoToGiveTranslation,
            callback: function(playerId) {                
                AdminPanel.Events.Utils.showPromptDialog({
                    title: lang.amountTranslation,
                    message: `${lang.howManyDoYouWantTranslation} ${item}`,
                    callback: function(amount) {
                        if (amount) {
                            AdminPanel.Events.Utils.postToResource('GiveItem', {
                                Item: item,
                                Amount: amount,
                                Id: playerId
                            });
                        }
                    }
                });
            }
        });
    });

    AdminPanel.Events.Elements.$document.on('dblclick', '.VehicleDblC', function(e) {
        AdminPanel.Events.Utils.postToResource('SpawnVehicle', { Vehicle: $(this).attr('id') });
    });
}

AdminPanel.Events.initModals = function() {
    const modalCloseHandlers = {
        '#confirm': () => {
            AdminPanel.ModalOpen = false;
            AdminPanel.ConfirmingAction = null;
        },
        '#settings': () => AdminPanel.ModalOpen = false,
        '#warningsmodal': () => {
            AdminPanel.ModalOpen = false;
            setTimeout(() => AdminPanel.$('.reportbox').css('display', 'none'), AdminPanel.Events.CONSTANTS.TIMEOUTS.TOOLTIP_HIDE_DELAY);
        },
        '#reportmodal': () => AdminPanel.ModalOpen = false
    };

    Object.entries(modalCloseHandlers).forEach(([selector, handler]) => {
        AdminPanel.$(selector).on('hidden.bs.modal', handler);
    });

    const buttonHandlers = {
        '.confirm-yes': AdminPanel.Actions.handleConfirmAction,
        '.confirm-no': () => {
            AdminPanel.$("#confirm").modal('hide');
            AdminPanel.ModalOpen = false;
            AdminPanel.ConfirmingAction = null;
        },
        '.action': function(e) { 
            e.preventDefault();
            e.stopPropagation();
            AdminPanel.Actions.handleAction($(this)); 
        },
        '#hidealert': () => AdminPanel.$("#pagealert").hide()
    };

    Object.entries(buttonHandlers).forEach(([selector, handler]) => {
        AdminPanel.Events.Elements.$document.on('click', selector, handler);
    });

    AdminPanel.$('.list-group-item').on('click', function() {
        AdminPanel.$('.fas', this).toggleClass('fa-chevron-right fa-chevron-down');
    });
}

AdminPanel.Events.initSettings = function() {
    const settingsConfig = {
        '#darkmode': { 
            handler: AdminPanel.Theme.toggleDarkMode,
            getValue: (element) => element.prop('checked')
        },
        '#seethroughmode': { 
            handler: AdminPanel.Theme.toggleSeeThroughMode,
            getValue: (element) => element.prop('checked')
        },
        '#Notifications': { 
            handler: AdminPanel.Theme.toggleNotifications,
            getValue: (element) => element.prop('checked')
        },
        '#showplayergraph': { 
            handler: AdminPanel.Theme.togglePlayerGraph,
            getValue: (element) => element.prop('checked')
        },
        '#smallmode': { 
            handler: AdminPanel.Theme.toggleSmallMode,
            getValue: (element) => element.prop('checked')
        }
    };

    Object.entries(settingsConfig).forEach(([selector, config]) => {
        $(selector).change(function() {
            config.handler(config.getValue($(this)));
        });
    });

    $('#themesel').change(function() {
        const value = parseInt($(this).val());
        AdminPanel.UI.showAlert("danger", `<strong>${AdminPanel.Language?.ThemeTranslation || 'Theme'}:</strong> ${AdminPanel.Language?.ChangedTranslation || 'Changed'}`);
        AdminPanel.Settings.set('theme', value);
        AdminPanel.Theme.setTheme(value);
    });

    $('#fontsel').change(function() {
        const value = parseInt($(this).val());
        AdminPanel.UI.showAlert("danger", `<strong>${AdminPanel.Language?.FontTranslation || 'Font'}:</strong> ${AdminPanel.Language?.ChangedTranslation || 'Changed'}`);
        AdminPanel.Settings.set('font', value);
        AdminPanel.Theme.setFont(value);
    });
}

AdminPanel.Events.initKeyboardEvents = function() {
    let lastKeyUpAt = 0;

    AdminPanel.Events.Elements.$document.on('keyup', function(e) {
        if (e.key === AdminPanel.Events.CONSTANTS.KEYS.ESCAPE) {
            if (AdminPanel.IsOpen && !AdminPanel.ModalOpen) {
                AdminPanel.Close();
            } else if (AdminPanel.ReportScreenOpen && !AdminPanel.ModalOpen) {
                AdminPanel.CloseReportScreen();
            }
        }
    });

    AdminPanel.Events.Elements.$document.on('keydown', function(e) {
        if (AdminPanel.WarningShown && e.key === AdminPanel.Events.CONSTANTS.KEYS.SPACE) {
            const keyDownAt = new Date();
            setTimeout(function() {
                if (+keyDownAt > +lastKeyUpAt) {
                    AdminPanel.$('#playerwarning').hide();
                    AdminPanel.WarningShown = false;
                    AdminPanel.Events.Utils.postToResource('ExitWarn');
                }
            }, AdminPanel.Events.CONSTANTS.TIMEOUTS.WARNING_DELAY);
        }
    });

    AdminPanel.Events.Elements.$document.on('keyup', function() {
        lastKeyUpAt = new Date();
    });

    AdminPanel.$("#adminchattext").keyup(function(event) {
        if (event.keyCode === AdminPanel.Events.CONSTANTS.KEYS.ENTER) {
            AdminPanel.$("#adminchatsend").click();
        }
    });
}

AdminPanel.Events.initDragAndDrop = function() {
    const container = document.querySelector("#mainbox");
    const dragPad = document.querySelector(".draggable");
    
    if (!container || !dragPad) return;
    
    function onMouseDrag({ movementX, movementY }) {
        const getContainerStyle = window.getComputedStyle(container);
        const leftValue = parseInt(getContainerStyle.left);
        const topValue = parseInt(getContainerStyle.top);
        container.style.left = `${leftValue + movementX}px`;
        container.style.top = `${topValue + movementY}px`;
    }
    
    dragPad.addEventListener("mousedown", () => {
        dragPad.addEventListener("mousemove", onMouseDrag);
    });
    
    document.addEventListener("mouseup", () => {
        dragPad.removeEventListener("mousemove", onMouseDrag);
        const { left, top } = container.style;
        AdminPanel.Settings.set('posLeft', left);
        AdminPanel.Settings.set('posTop', top);
        AdminPanel.PosLeft = left;
        AdminPanel.PosTop = top;
    });
}

AdminPanel.Events.initResourceActions = function() {
    function performResourceAction(resourceName, action) {
        AdminPanel.$('[data-toggle="tooltip"], .tooltip').tooltip("hide");
        AdminPanel.Events.Elements.$loading.show();
        AdminPanel.$("#resourcelistpage, #resourcelist").hide();
        AdminPanel.Events.Utils.postToResource('ResourceAction', { resource: resourceName, action });
    }

    const resourceActions = ['start', 'stop', 'restart'];
    resourceActions.forEach(action => {
        AdminPanel.Events.Elements.$document.on('click', `#${action}resource`, function(e) {
            performResourceAction($(this).data('resource'), action);
        });
    });
}
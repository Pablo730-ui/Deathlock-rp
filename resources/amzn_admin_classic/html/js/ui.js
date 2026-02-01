AdminPanel.UI = AdminPanel.UI || {};

AdminPanel.UI.translate = function() {
    Object.keys(AdminPanel.Language).forEach(key => {
        $('#'+key).html(AdminPanel.Language[key]);
    });
}

AdminPanel.UI.showAlert = function(type, alertText) {
    if (!AdminPanel.NotificationsEnabled) return
    if(type == "error") { type = TOAST_STATUS.DANGER; }
    else if(type == "danger") { type = TOAST_STATUS.DANGER; }
    else if(type == "success") { type = TOAST_STATUS.SUCCESS; }
    else {
        type = TOAST_STATUS.INFO;
    }
    
    Toast.create("919 ADMIN", alertText, type, 3000);
}

AdminPanel.UI.showAdminChatAlert = function(msgText) {
    if (!AdminPanel.NotificationsEnabled) return
    var type = TOAST_STATUS.SUCCESS;
    Toast.create("ADMIN CHAT", msgText, type, 3000);
}

AdminPanel.UI.showReportAlert = function(title, msgText) {
    if (!AdminPanel.NotificationsEnabled) return
    var type = TOAST_STATUS.SUCCESS;
    Toast.create(title, msgText, type, 8000);
}

AdminPanel.UI.openSettings = function() {
    $("#settings").modal('show');
    AdminPanel.ModalOpen = true;
}

AdminPanel.UI.showReportScreen = function(data) {
    AdminPanel.Language = JSON.parse(data.Translation)
    AdminPanel.UI.translate()
    AdminPanel.ReportScreenOpen = true;
    $("#reportbox").fadeIn(350);
    $('#inputSubject').val("")
    $('#inputInfo').val("")
}

AdminPanel.CloseReportScreen = function() {
    $("#reportbox").fadeOut(350);
    $.post(`https://${GetParentResourceName()}/close`);
    AdminPanel.ReportScreenOpen = false;
}

AdminPanel.UI.showWarning = function(warnedBy, reason, translations) {
    // If translations are provided (for players who haven't opened admin menu), set them
    if (translations && !AdminPanel.Language) {
        AdminPanel.Language = JSON.parse(translations);
        AdminPanel.UI.translate();
    }
    
    if(AdminPanel.IsOpen) {
        $('[data-toggle="tooltip"], .tooltip').tooltip("hide");
        $("#mainbox").hide();
        $("#content-wrapper").hide();
        AdminPanel.IsOpen = false;
    }
    $("#warnadmin").html(warnedBy);
    $("#warnreason").html(reason);
    $("#playerwarning").fadeIn(500);
    AdminPanel.WarningShown = true;
}

AdminPanel.UI.viewWarnings = function(warnings) {
    if(AdminPanel.IsOpen) {
        $("#warninglistbody").empty();
        warnings.forEach(function (item, index) {
            $("#warninglistbody").append(`
                <tr>
                <th>${index+1}</th>
                <td>${item.reason}</td>
                <td>${item.warnedby}</td>
                <td>${AdminPanel.Utils.getReadableTime(item.warnedtime)}</td>
                </tr>
            `);
        });
        AdminPanel.ModalOpen = true;
        $("#warningsmodal").modal('show');
        setTimeout(() => {
            $('.reportbox').css('display', 'none'); 
        }, 100);
    }
} 
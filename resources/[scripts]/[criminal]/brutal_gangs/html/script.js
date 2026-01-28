Language = 'en' // "en", "es", "fr", "de", "pt", "it", "pl", "nl", "ru", "tr", "hu", "ro", "cs", "sv", "ar"

let MapLoaded = false
MarkerColor = '#ffffff'
previewmarker = null
ChoosedRank = 'member'
Blips = []
Poligons = []
SelectedGang = ''
OpenedMapGang = false
LoadingMap = false
GangTable = undefined
ChangedCurrencies = [0, 0]
AdminGang = null
AdminHQ = null
CurrentPage = "home"
AdminChoosedGang = 0
DrugMarkers = []
PlayerIcon = null

let translations = {};

async function loadTranslations(lang) {
    try {
        const response = await fetch(`../locales/${lang}.json`);
        translations = await response.json();
        updateText()
    } catch (error) {
        console.error("Error loading translation:", error);
    }
}

function updateText() {
    document.querySelectorAll("[data-i18n]").forEach(element => {
        const key = element.getAttribute("data-i18n");

        if (element.hasAttribute("placeholder")) {
            element.setAttribute("placeholder", translations[key]);
        } else {
            element.innerHTML = translations[key]; 
        }
    });
}

loadTranslations(Language)

function t(key) {
    return translations[key] || key; 
}

window.addEventListener('message', function(event) {
    let data = event.data

    if (data.action === "OpenGangMenu") {
        if (GangTable != undefined) {
            ChangedCurrencies = [0, 0]
            if (GangTable.datas.balance < data.gangtable.datas.balance) {
                ChangedCurrencies[0] = data.gangtable.datas.balance - GangTable.datas.balance
            }
            if (GangTable.datas.rep < data.gangtable.datas.rep) {
                ChangedCurrencies[1] = data.gangtable.datas.rep - GangTable.datas.rep
            }
        }

        ExternalTasks = data.externaltasks
        PlayerCoords = data.player_coords
        CayoPericoMap = data.cayo_perico
        MyPerms = data.mypermissions
        PlayerJob = data.myjob
        GangTable = data.gangtable
        Levels = data.levels
        MapTable = data.maptable
        Currency = data.currencyforms
        Locales = data.locales
        RaidPrices = data.raidprices
        GraffitiIcons = data.graffitiicons
        CleanDatas = [data.clean_timer, data.clean_timer2, data.clean_rep]
        GraffitiDatas = [data.graffiti_timer, data.graffiti_timer2, data.place_rep]
        Tasks = data.tasks
        GangTable.onlinemembers = []
        for (let index = 0; index < GangTable.members.length; index++) {
            if (GangTable.members[index].online) {
                GangTable.onlinemembers.push(GangTable.members[index])
            }
        }

        CreateSubMenus()

        if (data.type == "open"){
            SwitchPage('home')
        }
        else{
            SwitchPage(CurrentPage, true)
        }

        show('gang_menu')
    } 
    else if (data.action === "OpenGarageMenu") {
        show('garage_menu')
        $(".available").html(`<span class="text-white">${data.maxvehicles}/${data.storedvehicles}</span><br>${t('used_place')}`)
        $(".vehicle_container").html("")
        VehcileTable = data.table
        VehTypes = ['<i class="fa-solid fa-car"></i>', '<i class="fa-solid fa-motorcycle"></i>', '<i class="fa-solid fa-helicopter"></i>', '<i class="fa-solid fa-sailboat"></i>']
        if (VehcileTable.length > 0) {
            for (let index = 0; index < data.table.length; index++) {
                $(".vehicle_container").append(`
                    <button class="vehicle_element" ${data.table[index].out?`disabled`:""} onclick="SpawnVehicle(${index})">
                        <div class="name">${data.table[index].name}</div>
                        <div class="plate">${data.table[index].vehicleProps.plate} ${VehTypes[data.table[index].type-1]}</div>
                        <div class="arrows"></div>
                    </button>
                `)
            }
        } else {
            $(".vehicle_container").html(t('no_available_vehicle'))
        }
        BackgroundBlur("plugin2", 'panel_garage')

    } 
    else if (data.action === "OpenRaidMenu") {
        Currency = data.currencyforms
        Points1 = data.points1
        Points2 = data.points2
        show('raid_panel')
        $('.time').html(data.time + " min<br><span>"+t('time_left')+"</span>")
        $('.gang').html(data.label1)
        $('.gang.sec').html(data.label2)
        $('.gang_per').html(Points1 + "%")
        $('.gang_per.sec').html(Points2 + "%")
        $('#raid_percen').css("width", Points1 + "%")
        $('#raid_percen2').css("width", Points2 + "%")
        if (Points1 < Points2){
            document.getElementById("raid_panel").classList.add("raid_anim")
        }
        else{
            document.getElementById("raid_panel").classList.remove("raid_anim")
        }
    } 
    else if (data.action === "HideRaidMenu") {
        hide('raid_panel')
    }
    else if (data.action === "OpenScoutingMenu") {
        show('scout_panel')
        $('.time').html(data.time + " min<br><span>"+t('time_left')+"</span>")
        $('.players').html(t('players')+': ' + data.members)
        $('.percentage').html(data.points + '%')
        $('#scout_per').css("width", data.points + '%')
    } 
    else if (data.action === "HideScoutingMenu") {
        hide('scout_panel')
    } 
    else if (data.action === "OpenBalanceMenu") {
        Currency = data.currencyforms
        show('balance_menu')
        $(".balance_menu .balance").html(data.balance.toLocaleString() + ' ' + Currency.balance)
        BackgroundBlur("plugin4", 'panel_balance')
    } 
    else if (data.action === "OpenCloakroomMenu") {
        show('clothe_menu')
        $(".clothe_conatiner").html("")
        Clothe = data.table
        if (Clothe.length > 0) {
            for (let index = 0; index < Clothe.length; index++) {
                $(".clothe_conatiner").append(`
                    <button class="clothe_element" onclick="SendClothe(${index})">
                        <div class="name">${Clothe[index].label}</div>
                        <div class="arrows"></div>
                    </button>
                `)
            }
        } else {
            $(".clothe_conatiner").html(t("no_available_clothes"))
        }
        BackgroundBlur("plugin3", 'panel_clothe')
    } 
    else if (data.action === "OpenEditGangsMenu") {
        AdminTable = data.table
        show('admin_menu')
        CreateAdminPanel()
        BackgroundBlur("plugin7", 'panel_admin')
    }
    else if (data.action === "OpenTaskPanel") {
        show('task_next_menu')
        $(".task_next_menu .title").html(t(data.title))
        $(".task_next_menu .next_des").html(t(data.description))
        setTimeout(() => {
            BackgroundBlur("plugin6", 'panel_task_next')
        }, 1);
        setTimeout(() => {
            hide('task_next_menu')
        }, 10000);
    }
    else if (data.action === "HideTaskPanel") {
        hide('task_next_menu')
    }
    else if (data.action === "OpenTaskEndPanel") {
        Currency = data.currencyforms
        show('task_completed_menu')
        $(".task_completed_menu .title").html(t(data.title))
        $(".task_completed_menu .task_label").html(t(data.description))
        $(".task_completed_menu .task_plus_money").html(data.money == 0?"":"+"+data.money.toLocaleString()+" "+Currency.balance)
        $(".task_completed_menu .task_plus_rep").html(data.reputation  == 0?"":"+"+data.reputation.toLocaleString() +" "+Currency.rep)
        BackgroundBlur("plugin5", 'panel_task_completed')
        setTimeout(() => {
            hide('task_completed_menu')
        }, 10000);
    }
    else if (data.action === "OpenTimerMenu") {
        $('.timer').css("display", 'block')
        document.getElementById("timer").style.animation = "plus_currencies_anim 0.8s ease-in-out both";
        $('.timer .title').html(t(data.title))
        $('.timer .des').html(t(data.description))
        $('.timer .time_left').html(fancyTimeFormat(data.time))
        let percentage = data.time/data.maxtime*100
        $('.timer').css("background-image", `linear-gradient(90deg, #C337FB ${percentage}%, transparent ${percentage}%)`)
    } 
    else if (data.action === "HideTimerMenu") {
        document.getElementById("timer").style.animation = "plus_currencies_anim_reverse 0.8s ease-in-out both";
        setTimeout(() => {
            $('.timer').css("display", 'none')
        }, 500);
    } 
    else if (data.action === "OpenInvitationPanel") {
       show('invitation_menu')
       $("#panel_invitation .des").html(t('got_invitation')+" <span>"+data.job+" </span>")
       BackgroundBlur("plugin8", 'panel_invitation')
    } 
    else if (data.action === "HideInvitationPanel") {
       hide('invitation_menu')
    } 
    else if (data.action === "close") {
        Close()
    }
})

document.onkeydown = function(data) {
    if (event.key == 'Escape') {
        Close()
    }
}

BackgroundBlur("plugin7", 'panel_admin')

function Close() {
    hide('gang_menu')
    hide('garage_menu')
    hide('balance_menu')
    hide('clothe_menu')
    hide('admin_menu')
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "close"
    }))
}

function CreateHomePage() {
    $('.gang_pic').css("background-image", 'url(assets/gang_icons/'+GangTable.datas.graffiti_icon+')')

    if (GangTable.datas.balance.toString().length > 9) {
        $(".money_con .main_money").css("font-size", "34px")
    } else {
        $(".money_con .main_money").css("font-size", "41px")
    }

    if (GangTable.level != 0) {
        $(".progress").css("width", 50 * (GangTable.level - 1) + '%')
        if (GangTable.level != 3) {
            if (GangTable.datas.rep > Levels[GangTable.level + 1].price.rep){
                progval = GangTable.level * 50
            }
            else{
                progval = GangTable.datas.rep / Levels[GangTable.level + 1].price.rep * 50 + ((GangTable.level - 1) * 50)
            }

            $(".progress2").css("width", ((progval > 100) ? 100 : progval) + '%')
        }
        document.getElementById("level_1").classList.remove("current")
        document.getElementById("level_2").classList.remove("current")
        document.getElementById("level_3").classList.remove("current")
        document.getElementById("level_" + GangTable.level).classList.add("current")
    }

    for (let index = 1; index < 4; index++) {
        $(".level_price#level_price_" + index).html(`
      ${Levels[index].price.money} ${Currency.balance}<br><div class="rep">${Levels[index].price.rep} ${Currency.rep}</div>
      `)
    }
    $(".center_popup .price").html(RaidPrices.money > 0 ? RaidPrices.rep > 0 ? RaidPrices.money.toLocaleString() + ' ' + Currency.balance + '<br><span>' + RaidPrices.rep.toLocaleString() + ' ' + Currency.rep + '</span>' : RaidPrices.money.toLocaleString() + ' ' + Currency.balance : '<span>' + RaidPrices.rep.toLocaleString() + ' ' + Currency.rep + '</span>')

    
    let Runtimes = 0
    for (const key in Tasks) {
        Runtimes++
        if (Runtimes < 3){
            $(".home_con#tasks").append(`
                <div class="home_task_element">
                    <div class="label">${Tasks[key].Label}</div>
                    <div class="des">${Tasks[key].Description}</div>
                    <div class="arrows"></div>
                </div>
            `)
        }
    }
    
    if (GangTable.datas.upgrades.length > 1){
        for (let index = 0; index < 2; index++) {
            $(".home_con#settings_con").append(`
            <div class="home_task_element">
                <div class="label">${t(GangTable.datas.upgrades[index].label)}</div>
                <div class="des">${t(GangTable.datas.upgrades[index].description)}</div>
                <div class="arrows"></div>
            </div>
        `)
        }
    }
    else{
        $(".home_con#settings_con").append(`<dotlottie-player src="https://lottie.host/2dc70e52-0103-4042-b0fa-d59dca5407ba/quK7SLQ319.json" background="transparent" speed="0.7" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 250px; height: 250px;" autoplay></dotlottie-player>`)
    }

    if (ChangedCurrencies[0] > 0 || ChangedCurrencies[1] > 0) {
        $("#plus_currencies").css("display", "block")
        document.getElementById("plus_currencies").style.animation = "plus_currencies_anim 0.8s ease-in-out 0.5s both, plus_currencies_anim2 3s infinite";
        $(".plus_currencies .added_plus").html(ChangedCurrencies[0] > 0 ? ChangedCurrencies[1] > 0 ? '+' + ChangedCurrencies[0].toLocaleString() + ' ' + Currency.balance + '<br><span>+' + ChangedCurrencies[1].toLocaleString() + ' ' + Currency.rep + '</span>' : '+' + ChangedCurrencies[0].toLocaleString() + ' ' + Currency.balance : '<span>+' + ChangedCurrencies[1].toLocaleString() + ' ' + Currency.rep + '</span>')
        ChangedCurrencies = [0, 0]
        setTimeout(() => {
            document.getElementById("plus_currencies").style.animation = "plus_currencies_anim_reverse 0.8s ease-in-out both";
            setTimeout(() => {
                $("#plus_currencies").css("display", "none")
            }, 500);
        }, 5000);
    }
}

function CreateSettingsPage() {
    $("#player_container").html("")
    for (let index = 0; index < GangTable.members.length; index++) {
        $("#player_container").append(`
            <div class="player_element" id="player_el${index}">
                <div class="row h-100 mx-2">
                    <div class="col-5">
                        <div class="player_name">${GangTable.members[index].name.length>13?GangTable.members[index].name.slice(0, 13)+'...':GangTable.members[index].name}</div>
                    </div>
                    <div class="col px-0">
                        <div class="dropdown">
                            <button class="rank_change_btn px-3" id="change_perm_btn_${index}" type="button" data-bs-toggle="dropdown" aria-expanded="false">${GangTable.members[index].rank.label.length>7?GangTable.members[index].rank.label.slice(0, 7)+'...':GangTable.members[index].rank.label}</button>
                            <ul class="dropdown-menu">    
                            </ul>
                        </div>
                    </div>
                    <div class="col px-0">
                        <button class="top_opener_btn red float-end" id="kick_${index}" onclick="SendKick('${GangTable.members[index].identifier}', id)">${t("kick")}</button>
                    </div>
                </div>
            </div>      
        `)
        for (let i = 0; i < GangTable.datas.ranks.length; i++) {
            $("#player_container #player_el" + index + " ul").append(`<li><button class="dropdown-item" id="rank_el${i}" onclick="ChangePlayerPer(id, 'change_perm_btn_${index}', ${i}, '${GangTable.members[index].identifier}', true)">${GangTable.datas.ranks[i].label.length>7?GangTable.datas.ranks[i].label.slice(0, 7)+'...':GangTable.datas.ranks[i].label}</button></li>`)
        }
    }

    let UpgradesTable = []
    for (let index = 0; index < GangTable.datas.upgrades.length; index++) {
        if (UpgradesTable[GangTable.datas.upgrades[index].type] == undefined) {
            UpgradesTable[GangTable.datas.upgrades[index].type] = GangTable.datas.upgrades[index].level
        }
    }


    if (GangTable.datas.upgrades.length > 0) {
        $(".upgrades_container").html(``)
        for (let index = 0; index < GangTable.datas.upgrades.length; index++) {
            if (UpgradesTable[GangTable.datas.upgrades[index].type] == GangTable.datas.upgrades[index].level) {
                $(".upgrades_container").append(`
          <div class="task_element">
              <div class="label">${t(GangTable.datas.upgrades[index].label)} <span>${t('level')} ${UpgradesTable[GangTable.datas.upgrades[index].type]}</span></div>
              <div class="des">${t(GangTable.datas.upgrades[index].description)}</div>
              <div class="reward">${GangTable.datas.upgrades[index].price.money > 0?GangTable.datas.upgrades[index].price.rep > 0?('<span class="green_text">'+GangTable.datas.upgrades[index].price.money+' '+Currency.balance+'</span><br><span class="small_max">'+t('and')+' </span><span class="purple_text">'+GangTable.datas.upgrades[index].price.rep+' '+Currency.rep+'</span>'):'<span class="green_text">'+GangTable.datas.upgrades[index].price.money+' '+Currency.balance+'</span>':'<span class="purple_text">'+GangTable.datas.upgrades[index].price.rep+' '+Currency.rep+'</span>'}</div>
              <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                  <button class="start_task_btn me-2" onclick="SendUpgradeBuy('${index}')">${t('buy')}</button>
              </div>
          </div>
        `)
            }
        }
    } else {
        $(".upgrades_container").html(`<dotlottie-player src="https://lottie.host/2dc70e52-0103-4042-b0fa-d59dca5407ba/quK7SLQ319.json" background="transparent" speed="0.7" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 250px; height: 250px;" autoplay></dotlottie-player>`)
    }


    $(".settings_container").html(``)
    for (const key in GangTable.datas.coords) {
        for (let index = 0; index < GangTable.datas.coords[key].length; index++) {
            $(".settings_container").append(`
                <div class="settings_element">
                <div class="row mx-2 mt-2">
                    <div class="col-7">
                        <div class="name">${t(Locales[key])}</div>
                    </div>
                    <div class="col">
                        <button class="settings_btn red float-end" onclick="SendSettings('delete', '${key}', ${index})"><i class="bi bi-trash"></i></button>
                    </div>
                    <div class="col">
                        <button class="settings_btn white float-end" onclick="SendSettings('edit', '${key}', ${index})"><i class="bi bi-pencil-square"></i></button>
                    </div>
                    <div class="col">
                        <button class="settings_btn float-end" onclick="SendSettings('create', '${key}', ${index})"><i class="bi bi-plus-square"></i></button>
                    </div>
                </div>
                </div>
            `)
        }
    }

    if (GangTable.datas.capacity.safe.size != "") {
        $(".settings_container").append(`
      <div class="settings_element">
          <div class="row mx-2 mt-2">
            <div class="col-7">
                <div class="name">${t(Locales['safe'])}</div>
            </div>
            <div class="col">
                <button class="settings_btn white float-end" onclick="SendSettings('edit', 'Safe', '')"><i class="bi bi-pencil-square"></i></button>
            </div>
          </div>
        </div>
      `)
    }

}

function SendUpgradeBuy(index) {
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "upgrade",
        upgradeTable: GangTable.datas.upgrades[index]
    }))
}

function SendSettings(type, key, index) {
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "marker",
        type,
        key,
        index: index + 1
    }))
}

function PinMarker(coords) {
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "marker",
        type: "pin",
        coords
    }))
}

function CreateTasksPage(){
    $("#task_container").html("")
    for (const key in Tasks) {
        if (Tasks[key].resettime.current <= 0){
            $("#task_container").append(`
                <div class="task_element can_start">
                    <div class="label">${Tasks[key].Label}</div>
                    <div class="des">${Tasks[key].Description}</div>
                    <div class="reward">${Tasks[key].Reward.money.max > 0?`<span class="small_max">MAX </span><span class="green_text">${Tasks[key].Reward.money.max}  ${Currency.balance}</span>`:''}<br>${Tasks[key].Reward.rep.max > 0?`<span class="small_max">MAX </span><span class="purple_text">${Tasks[key].Reward.rep.max}  ${Currency.rep}</span>`:''}</div>
                    <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                        <button class="start_task_btn" id="${key}" onclick="StartTask('${Tasks[key].task}', id)">${t('start')}<img src="assets/arrows.svg"></button>
                    </div>
                </div>
            `)
        }
        else{
            $("#task_container").append(`
                <div class="task_element">
                    <div class="label">${Tasks[key].Label}</div>
                    <div class="des">${Tasks[key].Description}</div>
                    <div class="reward">${Tasks[key].Reward.money.max > 0?`<span class="small_max">MAX </span><span class="green_text">${Tasks[key].Reward.money.max}  ${Currency.balance}</span>`:''}<br>${Tasks[key].Reward.rep.max > 0?`<span class="small_max">MAX </span><span class="purple_text">${Tasks[key].Reward.rep.max}  ${Currency.rep}</span>`:''}</div>
                    <div class="action_part" style="position: absolute; bottom: -5px; right: -30px; height: 40px; width: 300px; scale: 0.8;">
                            <div class="status_text">${t('remained')}:</div>
                            <div class="status_text right_side">${fancyTimeFormat2(Tasks[key].resettime.current)}</div>
                            <div class="progress_line">
                                <div class="progress" style="width: ${(Tasks[key].resettime.max-Tasks[key].resettime.current)/Tasks[key].resettime.max*100}%"></div>
                            </div>
                    </div>
                </div>
            `)
        }
    }

    for (const key in ExternalTasks) {
        if (ExternalTasks[key].resettime.current <= 0){
            $("#task_container").append(`
                <div class="task_element can_start">
                    <div class="label">${ExternalTasks[key].Label}</div>
                    <div class="des">${ExternalTasks[key].Description}</div>
                    <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                        <button class="start_task_btn" id="external_${key}" onclick="StartExternalTask(id, '${ExternalTasks[key].event}', '${ExternalTasks[key].task}')">${t('start')}<img src="assets/arrows.svg"></button>
                    </div>
                </div>
            `)
        }
        else{
            $("#task_container").append(`
                <div class="task_element">
                    <div class="label">${ExternalTasks[key].Label}</div>
                    <div class="des">${ExternalTasks[key].Description}</div>
                    <div class="action_part" style="position: absolute; bottom: -5px; right: -30px; height: 40px; width: 300px; scale: 0.8;">
                            <div class="status_text">${t('remained')}:</div>
                            <div class="status_text right_side">${fancyTimeFormat2(ExternalTasks[key].resettime.current)}</div>
                            <div class="progress_line">
                                <div class="progress" style="width: ${(ExternalTasks[key].resettime.max-ExternalTasks[key].resettime.current)/ExternalTasks[key].resettime.max*100}%"></div>
                            </div>
                    </div>
                </div>
            `)
        }
    }

    $('.disabled_text').css("display", 'none')
    $('.disabled_lock').css("display", 'none')
    document.getElementById('player_kills').classList.remove("disabled")

    TriggerCallbackExecutions('getdata', {}).done((cb) => {
        ExecutionsTable = cb.table
        ExecutionsTable2 = cb.executions
        LocalTime = cb.currenttime
        MaxTime = cb.repeatable
        PreparationStarted = cb.preparation

        $(".player_kills .task_container").html("")
        for (const key in ExecutionsTable) {
            if (ExecutionsTable[key].previous == 0 || (LocalTime-ExecutionsTable[key].previous)/MaxTime >= 1){
                if (ExecutionsTable[key].preparation){
                    $(".player_kills .task_container").append(`
                        <div class="task_element can_start">
                            <div class="label">${ExecutionsTable2[ExecutionsTable[key].key].Label}</div>
                            <div class="des">${ExecutionsTable2[ExecutionsTable[key].key].Description}</div>
                            <div class="reward ready">${t('ready')+'<br><span class="green_text">'+ExecutionsTable2[ExecutionsTable[key].key].Price.toLocaleString()+' '+Currency.balance+'</span>'}</div>
                            <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                                <button class="start_task_btn" id="${ExecutionsTable[key].key}" onclick="StartExecution(id)">${t('start')}<img src="assets/arrows.svg"></button>
                            </div>
                        </div>
                    `)
                }
                else{
                    $(".player_kills .task_container").append(`
                        <div class="task_element">
                            <div class="label">${ExecutionsTable2[ExecutionsTable[key].key].Label}</div>
                            <div class="des">${ExecutionsTable2[ExecutionsTable[key].key].Description}</div>
                            <div class="reward">${t('preparation')+'<br><span class="green_text">'+ExecutionsTable2[ExecutionsTable[key].key].Price.toLocaleString()+' '+Currency.balance+'</span>'}</div>
                            <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                                <button class="start_task_btn" id="${ExecutionsTable[key].key}" onclick="StartExecution(id)">${t('start')}<img src="assets/arrows.svg"></button>
                            </div>
                        </div>
                    `)
                }
            }
            else{
                $(".player_kills .task_container").append(`
                    <div class="task_element">
                        <div class="label">${ExecutionsTable2[ExecutionsTable[key].key].Label}</div>
                        <div class="des">${ExecutionsTable2[ExecutionsTable[key].key].Description}</div>
                        <div class="reward">t('preparation')</div>
                        <div class="action_part" style="position: absolute; bottom: -5px; right: -30px; height: 40px; width: 300px; scale: 0.8;">
                                <div class="status_text">${t('remained')}:</div>
                                <div class="status_text right_side">${fancyTimeFormat3(MaxTime-(LocalTime-ExecutionsTable[key].previous))}</div>
                                <div class="progress_line">
                                    <div class="progress" style="width: ${(LocalTime-ExecutionsTable[key].previous)/MaxTime*100}%"></div>
                                </div>
                        </div>
                    </div>
                `)
            }
        }
        if (PreparationStarted != null){
            document.getElementById(PreparationStarted).disabled = true
        }
    }).catch((error) => {
        $('.disabled_text').css("display", 'block')
        $('.disabled_lock').css("display", 'block')
        document.getElementById('player_kills').classList.add("disabled")
    });;
}

function StartExecution(id){
    Close()
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "execution",
        key: id
    }))
}

function StartTask(task, id){
    if (!MyPerms.tasks){
        WrongAnim(id)
        return
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "starttask",
        task
    }))
}

function StartExternalTask(id, event, task){
    if (!MyPerms.tasks){
        WrongAnim(id)
        return
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "startexternaltask",
        event,
        task
    }))
}

function SwitchPage(id, noanim) {
    if (id == 'settings' && !MyPerms.settings) {
        return
    }

    if (LoadingMap) {
        return
    }
    
    let NavBTNs = document.getElementsByClassName("nav_btn")
    for (let index = 0; index < NavBTNs.length; index++) {
        NavBTNs[index].classList.remove("choosed")
    }
    document.getElementById(id).classList.add("choosed")
    CurrentPage = id
    if (id == 'map') {
        show('top_bar')
        CreateTopBar()
        if (!MapLoaded){
            LoadingMap = true
        }
        $(".gang_menu .container").css("display", "none")
        $(".gang_menu .map_container").css("display", "block")
        hide2("current_gang")
        hide2("marker_placer")
        hide2("drug_zone")
        setTimeout(() => {
            LoadMap(noanim)
        }, 2000);
    } else if (id == 'tasks') {
        show('top_bar')
        CreateTopBar()
        $(".gang_menu .map_container").css("display", "none")
        $(".gang_menu .container").css("display", "block")
        $(".gang_menu .container").html(`
            <div class="row" style="position: absolute; bottom: 20px; left: 20px;">
                <div class="col">
                    <div class="big_sub_con home_con">
                        <div class="basic_label">${t('tasks')}</div>
                        <div class="task_container" id="task_container">

                        </div>
                    </div>
                </div>
                <div class="col px-1">
                    <div class="row" style="margin: 0; margin-bottom: 16px; ">
                        <div class="col p-0">
                            <div class="side_task_con actbtn home_con ${GraffitiDatas[1] <= 0?'can_start':''}" onclick="SendStartGraffiti()">
                                <div class="sec_label">${t('spray')}</div>
                                <div class="reward">${GraffitiDatas[2]} ${Currency.rep}</div>
                                <div class="des">${t('spray_des')}</div>
                                ${GraffitiDatas[1] <= 0?`
                                    <div class="action_part" style="position: absolute; bottom: -7px; left: 0px; height: 40px; width: 250px; scale: 1;">
                                        <div class="ready_text">${t('ready')}</div>
                                    </div>
                                    `:`
                                    <div class="action_part" style="position: absolute; bottom: -7px; left: -25px; height: 40px; width: 300px; scale: 0.85;">
                                        <div class="status_text">${t('remained')}:</div>
                                        <div class="status_text right_side">${fancyTimeFormat(GraffitiDatas[1])}</div>
                                        <div class="progress_line">
                                            <div class="progress" style="width: ${(GraffitiDatas[0]-GraffitiDatas[1])/GraffitiDatas[0]*100}%"></div>
                                        </div>
                                    </div>
                                `}
                            </div>
                        </div>
                        <div class="col p-0">
                            <div class="side_task_con actbtn float-end ${CleanDatas[1] <= 0?'can_start':''} home_con" onclick="SendCleanGraffiti()">
                                <div class="sec_label">${t('cleaning')}</div>
                                <div class="reward">${CleanDatas[2]} ${Currency.rep}</div>
                                <div class="des">${t('clean_des')}</div>
                                ${CleanDatas[1] <= 0?`
                                    <div class="action_part" style="position: absolute; bottom: -7px; left: 0px; height: 40px; width: 250px; scale: 1;">
                                        <div class="ready_text">${t('ready')}</div>
                                    </div>
                                    `:`
                                    <div class="action_part" style="position: absolute; bottom: -7px; left: -25px; height: 40px; width: 300px; scale: 0.85;">
                                        <div class="status_text">${t('remained')}:</div>
                                        <div class="status_text right_side">${fancyTimeFormat(CleanDatas[1])}</div>
                                        <div class="progress_line">
                                            <div class="progress" style="width: ${(CleanDatas[0]-CleanDatas[1])/CleanDatas[0]*100}%"></div>
                                        </div>
                                    </div>
                                `}
                            </div>
                        </div>
                    </div>
                    
                    <div class="player_kills home_con" id="player_kills">
                        <div class="disabled_text">AVAILABLE!<br><a onclick="window.invokeNative('openUrl', 'https://store.brutalscripts.com/product/6551508')" href="https://store.brutalscripts.com/product/6551508" rel="noopener noreferrer" target="_blank">store.brutalscripts.com</a></div>
                        <i class="fa-solid fa-lock disabled_lock"></i>
                        <div class="basic_label">PLAYER EXECUTION</div>
                        <div class="task_container">

                            <div class="task_element can_start">
                                <div class="label">TRAIN HIT EXECUTION</div>
                                <div class="des">Tie up the target and place them on the train tracks. Watch as the train takes care of the rest.</div>
                                <div class="reward"><span class="green_text">READY</span></div>
                                <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                                    <button class="start_task_btn">START<img src="assets/arrows.svg"></button>
                                </div>
                            </div>
                            <div class="task_element">
                                <div class="label">CAR BOMB SETUP</div>
                                <div class="des">Place the target inside a vehicle, rig it with explosives, and detonate the car remotely.</div>
                                <div class="reward">PREPARATION</div>
                                <div class="action_part" style="position: absolute; bottom: -5px; right: -30px; height: 40px; width: 300px; scale: 0.8;">
                                    <div class="status_text">REMAINED:</div>
                                    <div class="status_text right_side">12h 06m</div>
                                    <div class="progress_line">
                                        <div class="progress"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="task_element can_start">
                                <div class="label">THROWING OVERBOARD</div>
                                <div class="des">Bind the target with ropes and throw them overboard. Watch as the water ensures they won’t resurface.</div>
                                <div class="reward"><span class="green_text">READY</span></div>
                                <div class="action_part" style="position: absolute; bottom: 5px; right: -5px;">
                                    <button class="start_task_btn">START<img src="assets/arrows.svg"></button>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        `)
    CreateTasksPage()
    } else if (id == 'settings') {
        show('top_bar')
        CreateTopBar()
        $(".gang_menu .map_container").css("display", "none")
        $(".gang_menu .container").css("display", "block")
        $(".gang_menu .container").html(`
      <div class="row" style="position: absolute; bottom: 20px; left: 20px;">
        <div class="col">
            <div class="big_sub_con home_con">
                <div class="basic_label">${t('members')}</div>
                <div class="scroll_effect"></div>
                <div class="row float-end" style="position: absolute; top: 10px; right: 10px;">
                    <div class="col px-0">
                        <button class="top_opener_btn" id="invite_btn" onclick="ShowInviteMenu()">${t('invite')}</button>
                    </div>
                    <div class="col">
                        <button class="top_opener_btn" id="ranks" onclick="OpenRanksContainer('ranks_container')">${t('ranks')}</button>
                    </div>
                </div>
                
                <div class="task_container" id="player_container">

                </div>
            </div>
        </div>
        <div class="col px-1">
            
            <div class="upgrades_con home_con">
                <div class="basic_label">${t('upgrades')}</div>
                <div class="scroll_effect"></div>
                <div class="upgrades_container">

                    
                </div>
            </div>

            <div class="settings_con home_con">
                <div class="basic_label mb-1">${t('settings')}</div>
                <div class="scroll_effect"></div>
                <div class="settings_container">
                  
                </div>
            </div>

        </div>
    </div>
    `)
        CreateSettingsPage()
    }
    else if (id == 'home') {
        $(".gang_menu .map_container").css("display", "none")
        $(".gang_menu .container").css("display", "block")
        $(".gang_menu .container").html(`
      <div class="level_unlock_panel" id="level_unlock_panel">
        <div class="level_title"></div>
        <div class="level_money"></div>
        <div class="level_rep"></div>
        <div class="unlockable_con">
        </div>
        <button class="unlock_btn" id="unlock_btn" onclick='SendUnlockLevel()'>${t('unlock')}</button>
    </div>

    <div class="row mt-4 mx-0">
        <div class="col px-2">
            <div class="level_con home_con">
                <div class="gang_name">${GangTable.label.length>10?GangTable.label.slice(0, 10)+'...':GangTable.label}</div>
                <div class="levels_des">${t('level_des')}</div>
                <div class="level_line_con">
                    <div class="row mt-2">
                        <div class="col d-flex flex-column align-items-center" style="position: relative;">
                            <div class="hover_area" id="hover_1"></div>
                            <div class="level_text" id="level_1">1<br>${t('level')}</div>
                            <div class="indicator"></div>
                            <div class="level_price" id="level_price_1"></div>
                        </div>
                        <div class="col-8 d-flex flex-column align-items-center">
                            <div class="hover_area" id="hover_2"></div>
                            <div class="level_text" id="level_2">2<br>${t('level')}</div>
                            <div class="indicator"></div>
                            <div class="level_price" id="level_price_2"><br><div class="rep"></div></div>
                        </div>
                        <div class="col d-flex flex-column align-items-center" style="position: relative;">
                            <div class="hover_area" id="hover_3"></div>
                            <div class="level_text" id="level_3">3<br>${t('level')}</div>
                            <div class="indicator"></div>
                            <div class="level_price" id="level_price_3"></div>
                        </div>
                    </div>
                    <div class="level_line">
                        <div class="progress"></div>
                        <div class="progress2"></div>
                    </div>
                </div>
                
            </div>
        </div>
        <div class="col px-2">
            <div class="money_con home_con">
                <button class="gang_pic" id="gang_pic1" onclick="OpenPicReplacer('picture_replacer')"></button>
                <div class="main_money">${GangTable.datas.balance.toLocaleString()} ${Currency.balance}</div>
                <div class="rep_money">${GangTable.datas.rep.toLocaleString()} ${Currency.rep}</div>
                <div class="members"><span class="text-white">${GangTable.datas.capacity.members}/${GangTable.members.length}</span><br>${t('members')}</div>
                <div class="online"><span class="text-white">${GangTable.members.length}/${GangTable.onlinemembers.length}</span><br>${t('online')}</div>
            </div>
        </div>
    </div>

    <div class="row mt-3 mx-0">
        <div class="col px-2">
            <div class="map home_con" id="map" onclick="SwitchPage(id)"></div>
        </div>
        <div class="col px-2">
            <div class="task_con home_con" id="tasks" onclick="SwitchPage(id)">
                <div class="basic_label">${t('tasks')}</div>
                
            </div>
            <div class="spray_con mt-3 home_con ${GraffitiDatas[1] <= 0?'can_start':''}" id="spray" onclick="SwitchPage('tasks')">
                <div class="basic_label">${t('spray')}</div>
                <div class="reward">${GraffitiDatas[2]} ${Currency.rep}</div>
                <div class="des">${t('spray_des')}</div>
                ${GraffitiDatas[1] <= 0?`
                    <div class="action_part" style="position: absolute; bottom: 5px; left: -5px; height: 40px; width: 338px; scale: 1;">
                        <div class="ready_text">${t('ready')}</div>
                    </div>
                    `:`
                    <div class="action_part" style="position: absolute; bottom: -3px; left: 0px; height: 40px; width: 338px; scale: 1;">
                        <div class="status_text">${t('remained')}:</div>
                        <div class="status_text right_side">${fancyTimeFormat(GraffitiDatas[1])}</div>
                        <div class="progress_line">
                            <div class="progress" style="width: ${(GraffitiDatas[0]-GraffitiDatas[1])/GraffitiDatas[0]*100}%"></div>
                        </div>
                    </div>
                `}
            </div>
        </div>
        <div class="col px-2">
            <div class="invite_con home_con">
                <div class="basic_label">${t('invite')}</div>
                <div class="des">${t('invite_des')}</div>
                <button class="invite_btn" id="invite_btn" onclick="ShowInviteMenu()">${t('invite')}</button>
            </div>
            <div class="upgrade_con mt-3 home_con" id="settings_con" onclick="SwitchPage('settings')">
                <div class="basic_label">${t('settings')}</div>
                
            </div>
        </div>
    </div>
    `)
        LevelUnlockShowing()
        hide('top_bar')
        CreateHomePage()
    }

    let HomeCons = document.getElementsByClassName("home_con")
    for (let index = 0; index < HomeCons.length; index++) {
        HomeCons[index].style.animation = 'none'
        if (!noanim){
            HomeCons[index].offsetHeight
            HomeCons[index].style.animation = "Home_cons 0.4s ease both " + (index / 40) + "s"
        }
    }
    
}

function CreateTopBar() {
    $('.gang_pic').css("background-image", 'url(assets/gang_icons/'+GangTable.datas.graffiti_icon+')')
    if (GangTable.datas.balance.toString().length > 9) {
        $(".info_bar .main_money").css("font-size", "18px")
    } else {
        $(".info_bar .main_money").css("font-size", "23px")
    }
    if (GangTable.level != 3) {
        $(`.percent svg circle:nth-child(2)`).css("stroke-dashoffset", 440 - 130 * (GangTable.datas.rep < Levels[GangTable.level + 1].price.rep ? GangTable.datas.rep / Levels[GangTable.level + 1].price.rep : 1));
    } else {
        $(`.percent svg circle:nth-child(2)`).css("stroke-dashoffset", 440 - 130 * (1));
    }
    $(".gang_label").html(GangTable.label.length>10?GangTable.label.slice(0, 10)+'...':GangTable.label)
    $(".info_bar .level_num").html(GangTable.level)
    $(".info_bar .main_money").html(GangTable.datas.balance.toLocaleString() + ' ' + Currency.balance)
    $(".info_bar .rep_money").html(GangTable.datas.rep.toLocaleString() + ' ' + Currency.rep)
    $(".info_bar .online").html('<i class="fa-solid fa-earth-americas"></i> ' + GangTable.members.length + '/' + GangTable.onlinemembers.length)
    $(".info_bar .members").html('<i class="fa-solid fa-user-group fa-flip-horizontal"></i> ' + GangTable.datas.capacity.members + '/' + GangTable.members.length)
}

function ChangePlayerPer(id, btn_id, rank_num, player_id, value, bypass) {
    if (btn_id == 'inv_rank_btn') {
        ChoosedRank = GangTable.datas.ranks[rank_num].name
    }
    if (value) {
        if (!bypass){
            if (!MyPerms.edit_ranks){
                WrongAnim(btn_id)
                return
            }
        }
        let rankname
        if (typeof rank_num === "string"){
            rankname = rank_num
        }
        else{
            rankname = GangTable.datas.ranks[rank_num].name
        }
        $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
            action: "setmemberrank",
            id: player_id,
            rankname
        }))
    }

    if (btn_id == 'pic_btn') {
        ChoosedPic = rank_num
    }
    document.getElementById(btn_id).innerHTML = document.getElementById(id).innerHTML
}

function SendStartGraffiti(){
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "place_graffiti",
    }))
    Close()
}

function SendCleanGraffiti(){
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "clean_graffiti",
    }))
    Close()
}

function ReplacePicSend() {
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "changegangpic",
        id: ChoosedPic+1,
    }))
}

function CreateSubMenus() {
    $("#ranks_container_del ul").html("")
    for (let i = 0; i < GangTable.datas.ranks.length; i++) {
        $("#ranks_container_del ul").append(`<li><button class="dropdown-item" id="rank_el_del${i}" onclick="ChangePlayerPer(id, 'del_rank_btn')">${GangTable.datas.ranks[i].label}</button></li>`)
    }
    ChangePlayerPer('rank_el_del0', 'del_rank_btn')

    $("#picture_replacer ul").html("")
    for (let i = 0; i < GraffitiIcons.length; i++) {
        $("#picture_replacer ul").append(`<li><button class="dropdown-item" id="pic_${i}" onclick="ChangePlayerPer(id, 'pic_btn', ${i})"><img src='assets/gang_icons/${GraffitiIcons[i].png}'> ${GraffitiIcons[i].name}</button></li>`)
    }
    ChangePlayerPer('pic_0', 'pic_btn', 0)
}

function TriggerCallback(event, data) {
    data.name = event;
    return $.post('https://' + GetParentResourceName() + '/TriggerCallback', JSON.stringify(data)).promise();
}

function TriggerCallbackExecutions(event, data) {
    data.action = event;
    return $.post('https://brutal_executions/UseButton', JSON.stringify(data)).promise();
}

function TriggerCallbackDrugs(event, data) {
    data.action = event;
    return $.post('https://brutal_drugs/UseButton', JSON.stringify(data)).promise();
}

function OpenPicReplacer(id){
    if (!MyPerms.settings){
        return
    }
    show2(id)
}

function OpenRanksContainer(id){
    if (!MyPerms.edit_ranks){
        WrongAnim('ranks')
        return
    }
    show2(id)
}

function WrongAnim(btn_id){
    document.getElementById(btn_id).classList.add("nopermission")
    setTimeout(() => {
        document.getElementById(btn_id).classList.remove("nopermission")
    }, 500);
}

function ShowInviteMenu() {
    if (!MyPerms.invite){
        
        WrongAnim('invite_btn')
        return
    }
    TriggerCallback('brutal_gangs:callback:GetClosestPlayer', {}).done((cb) => {
        ClosestPlayers = cb
        ChoosedPlayer = null
        $("#invite_container .players_con .row").html("")
        if (ClosestPlayers.length > 0) {
            for (let i = 0; i < ClosestPlayers.length; i++) {
                if (i < 4) {
                    $("#invite_container .players_con .row").append(`
                    <div class="col px-0 d-flex flex-column align-items-center">
                        <button class="player_btn" id="player_${i}" onclick="ChoosePlayer(id)"><span>${ClosestPlayers[i].name}</span><div class="id">${ClosestPlayers[i].id}</div></button>
                    </div>
                    `)
                }
            }
        } else {
            $("#invite_container .players_con .row").append(`
            <div class="no_players">${t('no_one_is_near')}</div>
            `)
        }

        show2('invite_container')
    });
}

function ChoosePlayer(id) {
    for (let i = 0; i < ClosestPlayers.length; i++) {
        if (i < 4) {
            document.getElementById("player_" + i).classList.remove("choosed_player")
        }
    }
    document.getElementById(id).classList.add("choosed_player")
    ChoosedPlayer = $(`#${id} .id`).html()
}

function SendClothe(skin) {
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "cloakroom",
        skin
    }))
}

function SendDeposite() {
    let amount = document.getElementById('balance_input').value
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "balance",
        type: "deposit",
        amount
    }))
    document.getElementById('balance_input').value = ''
}

function SendWithdraw() {
    let amount = document.getElementById('balance_input').value
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "balance",
        type: "withdraw",
        amount
    }))
    document.getElementById('balance_input').value = ''
}

function SendInvite() {
    let id = ChoosedPlayer
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "invite",
        id,
        rankname: ChoosedRank
    }))
    ChoosedPlayer = null
    ChoosedRank = 'member'
    hide2('invite_container')
}

function SendKick(id, btn_id, bypass) {
    if (!bypass){
        if (!MyPerms.edit_ranks){
            WrongAnim(btn_id)
            return
        }
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "kick",
        id
    }))
}

function AllPerm() {
    let PermTable = document.getElementById('ranks_container').getElementsByClassName('form-check-input')
    for (let index = 0; index < PermTable.length; index++) {
        PermTable[index].checked = true
    }
}

function SendCreateRank() {
    if (!MyPerms.edit_ranks){
        return
    }
    let PermTable = document.getElementById('ranks_container').getElementsByClassName('form-check-input')
    let permtable = []
    for (let index = 0; index < PermTable.length; index++) {
        permtable.push(PermTable[index].checked)
    }
    let ranklabel = document.getElementById('rank_name').value
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "createrank",
        table: permtable,
        ranklabel
    }))
    document.getElementById('rank_name').value = ''
    for (let index = 0; index < PermTable.length; index++) {
        PermTable[index].checked = false
    }
}

function SendDeleteRank() {
    if (!MyPerms.edit_ranks){
        return
    }
    let rankname = document.getElementById('del_rank_btn').innerHTML
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "deleterank",
        rankname
    }))
}

function SendUnlockLevel() {
    if (!MyPerms.invite){
        WrongAnim('unlock_btn')
        return
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "unlock"
    }))
}

function OpenCenterPopup(id){
    if (!MyPerms.scoutandraid){
        WrongAnim('raid')
        return
    }
    show2(id)
}

function SendScout() {
    if (!MyPerms.scoutandraid){
        WrongAnim('scout')
        return
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "scout",
        targetgang: SelectedGang
    }))
}

function SendRaid() {
    let capture = document.getElementById('capture').checked
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "raid",
        targetgang: SelectedGang,
        capture
    }))
}

function SendFriend(data) {
    if (!MyPerms.scoutandraid){
        WrongAnim('friend_btn')
        return
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "friend",
        targetgang: SelectedGang,
        status: data
    }))
}

function LevelUnlockShowing() {
    let InIt = false
    let el2 = document.getElementById('level_unlock_panel')

    for (let index = 1; index < 4; index++) {
        let el = document.getElementById('hover_' + index)
        let $el = $("#hover_" + index)
        el.addEventListener("mouseenter", (event) => {

            if (index == 1) {
                $(".level_unlock_panel").css("left", ($el.offset().left + $el.width()) - (window.innerWidth - 1088) / 2)
            } else {
                $(".level_unlock_panel").css("left", ($el.offset().left + $el.width() / 2) - (window.innerWidth - 1088) / 2)
            }
            $(".level_title").html(t('level')+" " + index)
            $(".level_money").html(Levels[index].price.money + " " + Currency.balance)
            $(".level_rep").html(Levels[index].price.rep + " " + Currency.rep)
            $(".unlockable_con").html(`
        <div class="unlockable_element">${t('max_members')}: ${Levels[index].maxMembersCount}</div>
        <div class="unlockable_element">${t('max_vehicles')}: ${Levels[index].vehicles.amount}</div>
        <div class="unlockable_element">${t('max_stash')}: ${Levels[index].stash.size}</div>
        <div class="unlockable_element">${t('max_ranks')}: ${Levels[index].ranks.amount}</div>
        ${Levels[index].raid.available?'<div class="unlockable_element">'+t('raid_others')+'</div>':''}
      `)

            $(".unlock_btn").css("display", "none")
            if (+GangTable.level + 1 == index) {
                $(".unlock_btn").css("display", "block")
            }

            if (InIt == false) {
                $("#level_unlock_panel").css("display", "block")
            }
        });

        el.addEventListener("mouseleave", (event) => {
            setTimeout(() => {
                if (InIt == false) {
                    $("#level_unlock_panel").css("display", "none")
                }
            }, 10);
        });
    }

    el2.addEventListener("mouseenter", (event) => {
        InIt = true
    });

    el2.addEventListener("mouseleave", (event) => {
        InIt = false
        $("#level_unlock_panel").css("display", "none")
    });
}

function SpawnVehicle(ID) {
    Close()
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "spawnvehicle",
        plate: VehcileTable[ID].vehicleProps.plate
    }))
}

function CreateAdminPanel(){
    $("#admin_menu #gang_place_chooser ul").html("")
    for (let i = 0; i < AdminTable.length; i++) {
        $("#admin_menu #gang_place_chooser ul").append(`<li><button class="dropdown-item" id="admin_hq_${i}" onclick="SetAdminDatas(id, ${i})">${AdminTable[i].name == ""?t('empty'):AdminTable[i].name}<br><span>${AdminTable[i].hq} | Pos: ${Math.round(AdminTable[i].pos.x)}, ${Math.round(AdminTable[i].pos.y)}, ${Math.round(AdminTable[i].pos.z)}</span></button></li>`)
    }
    SetAdminDatas('admin_hq_'+AdminChoosedGang, AdminChoosedGang)
}

function SetAdminDatas(id, i){
    document.getElementById('main_admin_btn').innerHTML = document.getElementById(id).innerHTML
    AdminGang = AdminTable[i].name
    AdminHQ = AdminTable[i].hq

    AdminChoosedGang = i

    if (AdminTable[i].name == ""){
        document.getElementById('admin_gang_name').disabled = false
    }
    else{
        document.getElementById('admin_gang_name').disabled = true
    }

    document.getElementById('admin_gang_name').value = AdminTable[i].name
    document.getElementById('admin_gang_label').value = AdminTable[i].label
    document.getElementById('admin_gang_money').value = AdminTable[i].balance
    document.getElementById('admin_gang_rep').value = AdminTable[i].rep

    if (AdminTable[i].members != undefined){
        if (AdminTable[i].members.length > 0){
            $(".admin_menu .player_container").html("")
            for (let index = 0; index < AdminTable[i].members.length; index++) {
                $(".admin_menu .player_container").append(`
                    <div class="player_element" id="player_el${index}">
                        <div class="row h-100 mx-2">
                            <div class="col-5">
                                <div class="player_name">${AdminTable[i].members[index].name.length>13?AdminTable[i].members[index].name.slice(0, 13)+'...':AdminTable[i].members[index].name}</div>
                            </div>
                            <div class="col px-0">
                                <div class="dropdown">
                                    <button class="rank_change_btn px-3" id="change_perm_btn_${index}" type="button" data-bs-toggle="dropdown" aria-expanded="false">${AdminTable[i].members[index].rank.label.length>7?AdminTable[i].members[index].rank.label.slice(0, 7)+'...':AdminTable[i].members[index].rank.label}</button>
                                    <ul class="dropdown-menu">    
                                    </ul>
                                </div>
                            </div>
                            <div class="col px-0">
                                <button class="top_opener_btn red float-end" id="kick_${index}" onclick="SendKick('${AdminTable[i].members[index].identifier}', id, true), ReopenAdminPanel()">${t("kick")}</button>
                            </div>
                        </div>
                    </div>      
                `)
                for (let _i = 0; _i < AdminTable[i].ranks.length; _i++) {
                    $(".admin_menu .player_container #player_el" + index + " ul").append(`<li><button class="dropdown-item" id="rank_el${_i}" onclick="ChangePlayerPer(id, 'change_perm_btn_${index}', '${AdminTable[i].ranks[_i].name}', '${AdminTable[i].members[index].identifier}', true, true), ReopenAdminPanel()">${AdminTable[i].ranks[_i].label.length>7?AdminTable[i].ranks[_i].label.slice(0, 7)+'...':AdminTable[i].ranks[_i].label}</button></li>`)
                }
            }
        }
        else{
            $(".admin_menu .player_container").html('<div class="text">There are no players in this gang.</div>')
        }
        $('.admin_menu #green_admin_btn').html(t('save'))
        document.getElementById('add_player_btn').disabled = false
    }
    else{
        $(".admin_menu .player_container").html('<div class="text">This gang hq is not is use. Create a gang to use it!</div>')
        $('.admin_menu #green_admin_btn').html(t('create'))
        document.getElementById('add_player_btn').disabled = true
    }
}

function SendAddPlayer(){
    let id = document.getElementById('in_add_player').value
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({action: "addplayer", id, job:AdminGang}))
    document.getElementById('in_add_player').value = ''
}

function ReopenAdminPanel(){
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({action: "reopen_admin_panel"}))
}

function DeleteGang(){
    Close()
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "deletegang",
        job_name:AdminGang
    }))
}

function SaveGang(){
    Close()
    if (AdminGang == ""){
        action = "creategang"
    }
    else{
        action = "savegang"
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action,
        hq:AdminHQ,
        job_name:document.getElementById('admin_gang_name').value,
        job_label:document.getElementById('admin_gang_label').value,
        balance:document.getElementById('admin_gang_money').value,
        reputation:document.getElementById('admin_gang_rep').value
    }))
    document.getElementById('admin_gang_name').value = ''
    document.getElementById('admin_gang_label').value = ''
    document.getElementById('admin_gang_money').value = ''
    document.getElementById('admin_gang_rep').value = ''
}

/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

function LoadMap(noanim) {
    if (MapLoaded == false) {
        MapLoaded = true
        customcrs = L.extend({}, L.CRS.Simple, {
            projection: L.Projection.LonLat,
            scale: function(zoom) {

                return Math.pow(2, zoom);
            },
            zoom: function(sc) {

                return Math.log(sc) / 0.6931471805599453;
            },
            distance: function(pos1, pos2) {
                var x_difference = pos2.lng - pos1.lng;
                var y_difference = pos2.lat - pos1.lat;
                return Math.sqrt(x_difference * x_difference + y_difference * y_difference);
            },
            transformation: new L.Transformation(0.02072, 117.3, -0.0205, 172.8),
            infinite: true
        });

        map = L.map("main_map", {
            crs: customcrs,
            minZoom: 3,
            maxZoom: 6,
            zoom: 5,
            cursor: true,

            zoomControl: false,
            noWrap: true,
            continuousWorld: false,
            preferCanvas: true,

            center: [0, -1024],
            maxBoundsViscosity: 2.0
        });

        var customImageUrl = 'https://www.bragitoff.com/wp-content/uploads/2015/11/GTAV-HD-MAP-satellite.jpg';
        let centercoord = 1024

        if (CayoPericoMap){
            customImageUrl = 'https://i.ibb.co/27RB5pTr/GTAV-HD-MAP-satellite-Cayo.jpg';
            centercoord = 1250
        }

        var sw = map.unproject([0, centercoord], 3 - 1);
        var ne = map.unproject([centercoord, 0], 3 - 1);
        var mapbounds = new L.LatLngBounds(sw, ne);
        map.setView([PlayerCoords[1], PlayerCoords[0]], 5);
        map.setMaxBounds(mapbounds);


        map.attributionControl.setPrefix(false)

        L.imageOverlay(customImageUrl, mapbounds).addTo(map);

        map.on('dragend', function() {
            if (!mapbounds.contains(map.getCenter())) {
                map.panTo(mapbounds.getCenter(), {
                    animate: false
                });
            }
        });

        map.addEventListener('contextmenu', (event) => {
            if (previewmarker != null) {
                map.removeLayer(previewmarker);
            }
            previewmarker = L.marker([event.latlng.lat, event.latlng.lng]).addTo(map);
    
            CurrentMarkerPos = [event.latlng.lat, event.latlng.lng]
            let Icons = document.getElementsByClassName("icon_element")
            for (let index = 0; index < Icons.length; index++) {
                Icons[index].classList.remove("choosed_icon")
            }
            document.getElementById("icon_1").classList.add("choosed_icon")
            document.getElementById("marker_pin").disabled = true
            document.getElementById("map_marker_name").value = ''
            show2("marker_placer")
            $(".marker_btn_con").html(`
            <div class="row">
                <div class="col">
                </div>
                <div class="col">
                    <button class="marker_btn" onclick="AddMarker(true)">${t('create')}</button>
                </div>
            </div>
            `)
        })
        map.addEventListener('click', (event) => {
            if (previewmarker != null) {
                map.removeLayer(previewmarker);
            }
            if (OpenedMapGang == true) {
                hide2("current_gang")
                OpenedMapGang = false
            }
            hide2("marker_placer")
            hide2("drug_zone")
        })
    }

    hide2("current_gang")
    OpenedMapGang = false

    for (let index = 0; index < Poligons.length; index++) {
        if (Poligons[index] != null) {
            map.removeLayer(Poligons[index]);
        }
    }

    Poligons = []
    for (let index = 0; index < MapTable.length; index++) {
        let position = []
        let Policolor
        if (PlayerJob == MapTable[index].job_name){
            Policolor = '#C337FB'
        }
        else{
            Policolor = MapTable[index].friend ? '#98DC92' : MapTable[index].friend != null ? '#FB5C5C' : '#E0E0E0'
        }
        
        for (let i = 0; i < MapTable[index].map.length; i++) {
            position.push([MapTable[index].map[i].y, MapTable[index].map[i].x])
        }
        Poligons[index] = L.polygon(position, {
            color: Policolor
        }).addTo(map);

        if (MapTable[index].scoutdata != null) {
            Poligons[index].bindTooltip(`<div>${MapTable[index].scoutdata.job_label}</div>`, {
                direction: 'top',
                permanent: false,
                offset: [0, -10],
                opacity: 1,
                interactive: true,
                className: 'leaflet-tooltip-own',
            });
        }

        Poligons[index].on('click', function(event) {
            SelectedGang = MapTable[index].job_name
            if (PlayerJob == MapTable[index].job_name && !OpenedMapGang){
                $('.friend_btn').css("display", "none")
                $(".current_gang_name").html(MapTable[index].job_label.length>10?MapTable[index].job_label.slice(0, 10)+'...':MapTable[index].job_label)
                document.getElementById('current_gang_name').classList.remove("faded")
                document.getElementById('current_gang').classList.remove("green")
                $(".scout_date").html('')
                $(".info_con").html(`
                    <div class="gang_info" id="member">Members: ${GangTable.members.length}</div>
                    <div class="gang_info" id="level">Level: ${GangTable.level}</div>
                    <div class="gang_info" id="safe">Safe: ${GangTable.datas.capacity.safe.size}</div>
                `)
                $("#raid").css("display", "none")
                $("#scout").css("display", "none")
            }
            else if(!OpenedMapGang){
                $('.friend_btn').css("display", "block")
                $('#raid').css("display", "block")
                if (MapTable[index].friend) {
                    $(".friend_btn").html(t('remove_friend'))
                    document.getElementById('friend_btn').classList.add("red")
                    document.getElementById("friend_btn").onclick = function() { SendFriend(false) }
                    document.getElementById('current_gang').classList.add("green")
                } else {
                    $(".friend_btn").html(t('add_friend'))
                    document.getElementById('friend_btn').classList.remove("red")
                    document.getElementById("friend_btn").onclick = function() { SendFriend(true) }
                    document.getElementById('current_gang').classList.remove("green")
                }
    
                if (MapTable[index].scoutdata != null) {
                    $(".current_gang_name").html(MapTable[index].scoutdata.job_label.length>10?MapTable[index].scoutdata.job_label.slice(0, 10)+'...':MapTable[index].scoutdata.job_label)
                    document.getElementById('current_gang_name').classList.remove("faded")
                    $(".scout_date").html(MapTable[index].scoutdata.date)
                    $(".info_con").html(`
                        <div class="gang_info" id="member">${t('members')}: ${MapTable[index].scoutdata.members}</div>
                        <div class="gang_info" id="level">${t('level')}: ${MapTable[index].scoutdata.level}</div>
                        <div class="gang_info" id="safe">${t('safe')}: ${MapTable[index].scoutdata.safe}</div>
                    `)
                } else {
                    $(".current_gang_name").html('GANG NAME')
                    document.getElementById('current_gang_name').classList.add("faded")
                    $(".scout_date").html('')
                    $(".info_con").html(`
                        <div class="gang_info faded" id="member">${t('members')}: </div>
                        <div class="gang_info faded" id="level">${t('level')}: </div>
                        <div class="gang_info faded" id="safe">${t('safe')}: </div>
                    `)
                    $("#scout").css("display", "block")
                }
            }
            

            if (MapTable[index].job_name) {
                if (!OpenedMapGang){
                    show2("current_gang")
                    setTimeout(() => {
                        OpenedMapGang = true
                    }, 100);
                }
            } else {
                hide2("current_gang")
                OpenedMapGang = false
            }
        });
        
    }

    for (let index = 0; index < Blips.length; index++) {
        if (Blips[index] != null && Blips[index].marker != '') {
            map.removeLayer(Blips[index].marker);
        }
    }

    Blips = GangTable.datas.mapdata
    if (Blips.length > 0) {
        for (let index = 0; index < Blips.length; index++) {
            if (Blips[index].iconclass != undefined) {
                var IconSettings = L.divIcon({
                    html: `<i class="${Blips[index].iconclass}" style="color: ${Blips[index].color}"></i>`,
                    iconSize: [30, 30],
                    className: 'icon',
                });

                Blips[index].marker = L.marker(Blips[index].coords, {
                    icon: IconSettings
                });
                Blips[index].marker.addTo(map);

                Blips[index].marker.bindTooltip(`<div>${Blips[index].name}</div>`, {
                    direction: 'top',
                    permanent: false,
                    offset: [0, -10],
                    opacity: 1,
                    interactive: true,
                    className: 'leaflet-tooltip-own',
                });

                Blips[index].marker.on('click', function(event) {
                    if (previewmarker != null) {
                        map.removeLayer(previewmarker);
                    }
                    CurrentMarkerPos = [event.latlng.lat, event.latlng.lng]
                    let Icons = document.getElementsByClassName("icon_element")
                    for (let index = 0; index < Icons.length; index++) {
                        Icons[index].classList.remove("choosed_icon")
                    }
                    document.getElementById(Blips[index].icon).classList.add("choosed_icon")
                    document.getElementById("marker_pin").disabled = false
                    document.getElementById("marker_pin").onclick = function() {
                        PinMarker(Blips[index].coords);
                    }

                    document.getElementById("map_marker_name").value = Blips[index].name
                    $(".marker_btn_con").html(`
                    <div class="row">
                        <div class="col px-0">
                            <button class="marker_btn red" onclick="DeleteMarker(${index})">${t('delete')}</button>
                        </div>
                        <div class="col">
                            <button class="marker_btn" onclick="SaveMarker(${index})">${t('save')}</button>
                        </div>
                    </div>
                    `)

                    MarkerColor = Blips[index].color
                    $("#color-picker").css("color", Blips[index].color)
                    show2("marker_placer")
                });
            }
        }
    }

    for (let index = 0; index < DrugMarkers.length; index++) {
        if (DrugMarkers[index] != null && DrugMarkers[index].marker != '') {
            map.removeLayer(DrugMarkers[index].marker);
        }
    }

    DrugMarkers = [];

    TriggerCallbackDrugs('getdata', {}).done((cb) => {
        DrugMarkers = cb

        if (DrugMarkers.length > 0) {
            for (let index = 0; index < DrugMarkers.length; index++) {
                const markerData = DrugMarkers[index];
                const zoom = map.getZoom();
                const icon = createScaledIcon(zoom, markerData.size, markerData.color1, markerData.color2, markerData.icon);

                markerData.marker = L.marker([markerData.coords[1], markerData.coords[0]], { icon }).addTo(map);

                markerData.marker.on('click', function () {
                    $('.drug_zone .basic_label').html(markerData.name)
                    $('.drug_zone .drug_container').html('')
                    if (markerData.leaderboard.length > 0){
                        for (let i = 0; i < 8; i++) {
                            if (markerData.leaderboard[i] != undefined){
                                if (0.1 > markerData.leaderboard[i].percent){
                                    markerData.leaderboard[i].percent = 0.1
                                }
                                $('.drug_zone .drug_container').append(`
                                    <div class="gang_element">
                                        <div class="progress_con">
                                            <div class="progress" style='height: ${94*markerData.leaderboard[i].percent}px; background-color:${markerData.leaderboard[i].name == PlayerJob?'#C337FB':'#FFFFFF'};'></div>
                                        </div>
                                        <div class="label">${markerData.leaderboard[i].label}</div>
                                    </div>
                                `)
                            }
                        }
                    }
                    else{
                        $('.drug_zone .drug_container').append(`
                           <div class="text">${t('no_active_gangs')}</div>
                        `)
                    }
                    
                    show2("drug_zone");
                });
            }

            map.on('zoomend', () => {
                const zoom = map.getZoom();

                for (let i = 0; i < DrugMarkers.length; i++) {
                    const markerData = DrugMarkers[i];
                    const icon = createScaledIcon(zoom, markerData.size, markerData.color1, markerData.color2, markerData.icon);
                    markerData.marker.setIcon(icon);
                }
            });
        }
    }).catch((error) => {
        DrugMarkers = [];
    });

    if (PlayerIcon != null) {
        map.removeLayer(PlayerIcon);
    }

    var IconSettings = L.divIcon({
        html: `<i class="fa-solid fa-location-arrow fa-rotate-by" style="color: #ffffffff; --fa-rotate-angle: ${PlayerCoords[2]*(-1)-45}deg;"></i>`,
        iconSize: [30, 30],
        className: 'icon',
    });

    PlayerIcon = L.marker([PlayerCoords[1], PlayerCoords[0]], {
        icon: IconSettings
    });
    PlayerIcon.addTo(map);

    LoadingMap = false
}
const baseZoom = 5;  

function createScaledIcon(zoom, Size, Color, Color2, Icon) {
    const scale = getIconScale(zoom);
    const size = Size * scale * 1.15;

    return L.divIcon({
        html: `<div class="drug_marker" style="width: ${size}px; height: ${size}px; background-color: ${Color}; border-color: ${Color2};">
                   <img src="${Icon}">
               </div>`,
        iconSize: [size, size],
        iconAnchor: [size / 2, size / 2],
        className: 'icon'
    });
}

function getIconScale(zoom) {
    return Math.pow(2, zoom - baseZoom);
}

function AddMarker(val, number) {
    let Icon = document.querySelector(".choosed_icon").getElementsByTagName('i')[0].className
    let MarkerName = document.getElementById("map_marker_name").value

    var CODE = Blips.length

    if (val) {
        Blips.push({
            marker: '',
            coords: '',
            name: '',
            icon: '',
            iconclass: '',
            color: ''
        })
    } else {
        CODE = number
        Blips[CODE] = {
            marker: '',
            coords: '',
            name: '',
            icon: '',
            iconclass: '',
            color: ''
        }
    }

    var IconSettings = L.divIcon({
        html: `<i class="${Icon}" style="color: ${MarkerColor}"></i>`,
        iconSize: [30, 30],
        className: 'icon',
    });

    Blips[CODE].marker = L.marker([CurrentMarkerPos[0] + (val ? +15 : 0), CurrentMarkerPos[1]], {
        icon: IconSettings
    });
    Blips[CODE].marker.addTo(map);

    Blips[CODE].coords = [CurrentMarkerPos[0] + (val ? +15 : 0), CurrentMarkerPos[1]]
    Blips[CODE].name = MarkerName
    Blips[CODE].iconclass = Icon
    Blips[CODE].icon = document.querySelector('.choosed_icon').id
    Blips[CODE].color = MarkerColor

    Blips[CODE].marker.bindTooltip(`<div>${MarkerName}</div>`, {
        direction: 'top',
        permanent: false,
        offset: [0, -10],
        opacity: 1,
        interactive: true,
        className: 'leaflet-tooltip-own',
    });

    Blips[CODE].marker.on('click', function(event) {
        if (previewmarker != null) {
            map.removeLayer(previewmarker);
        }
        CurrentMarkerPos = [event.latlng.lat, event.latlng.lng]
        let Icons = document.getElementsByClassName("icon_element")
        for (let index = 0; index < Icons.length; index++) {
            Icons[index].classList.remove("choosed_icon")
        }
        document.getElementById(Blips[CODE].icon).classList.add("choosed_icon")
        document.getElementById("marker_pin").disabled = false
        document.getElementById("marker_pin").onclick = function() {
            PinMarker(Blips[CODE].coords);
        }

        document.getElementById("map_marker_name").value = Blips[CODE].name
        $(".marker_btn_con").html(`
      <div class="row">
          <div class="col px-0">
              <button class="marker_btn red" onclick="DeleteMarker(${CODE})">${t('delete')}</button>
          </div>
          <div class="col">
              <button class="marker_btn" onclick="SaveMarker(${CODE})">${t('save')}</button>
          </div>
      </div>
      `)

        $("#color-picker").css("color", Blips[CODE].color)
        show2("marker_placer")
    });


    if (previewmarker != null) {
        map.removeLayer(previewmarker);
    }
    hide2("marker_placer")

    let mapdata = Blips.map(u => Object.assign({}, u, {
        approved: true
    }));
    for (let index = 0; index < Blips.length; index++) {
        mapdata[index].marker = ''
    }

    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "mapdata",
        mapdata
    }))
}

function ChooseIcon(id) {
    let Icons = document.getElementsByClassName("icon_element")
    for (let index = 0; index < Icons.length; index++) {
        Icons[index].classList.remove("choosed_icon")
    }
    document.getElementById(id).classList.add("choosed_icon")
}

function DeleteMarker(id) {
    if (Blips[id].marker != '') {
        map.removeLayer(Blips[id].marker)
    }
    Blips[id] = null
    let mapdata = Blips.map(u => Object.assign({}, u, {
        approved: true
    }));
    for (let index = 0; index < Blips.length; index++) {
        mapdata[index].marker = ''
    }
    $.post('https://' + GetParentResourceName() + '/UseButton', JSON.stringify({
        action: "mapdata",
        mapdata
    }))
    hide2("marker_placer")
}

function SaveMarker(id) {
    if (Blips[id].marker != '') {
        map.removeLayer(Blips[id].marker)
    }
    AddMarker(false, id)
}

jSuites.color(document.getElementById('color-picker'), {
    fullscreen: true,
    onchange: function(el, val) {
        el.style.color = val;
        MarkerColor = val
        $("#color-picker").css("color", val)
    },
    placeholder: 'COLOR',
    closeOnChange: false,
});


function BackgroundBlur(element, target) {
    var bodyRect = document.body.getBoundingClientRect()
    let elemRect = document.getElementById(target).getBoundingClientRect()
    offset = []
    offset.push(elemRect.top - bodyRect.top, (elemRect.right - bodyRect.right) * (-1), elemRect.bottom - bodyRect.bottom, elemRect.left - bodyRect.left)
    $('#' + element).css('clip-path', `inset(${offset[0]}px ${offset[1]}px calc(100% - ${offset[2]}px) ${offset[3]}px)`)
}

function show(element) {
    $("#" + element).css("display", "block")
    document.getElementById(element).style.animation = "showmenu 0.35s ease";
}

function hide(element) {
    document.getElementById(element).style.animation = "hidemenu 0.3s ease";
    setTimeout(function() {
        $("#" + element).css("display", "none")
    }, 300)
}

function show2(element) {
    $("#" + element).css("display", "block")
    document.getElementById(element).style.animation = "Home_cons 0.3s ease";
}

function hide2(element) {
    document.getElementById(element).style.animation = "reverse_Home_cons 0.2s ease";
    setTimeout(function() {
        $("#" + element).css("display", "none")
    }, 200)
}


function isNumber(evt) {
    evt = (evt) ? evt : window.event
    var charCode = (evt.which) ? evt.which : evt.keyCode
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false
    }
    return true
}

function fancyTimeFormat(duration)
{   
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;

    var ret = "";

    if (hrs > 0) {
        ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + ":" + (secs < 10 ? "0" : "");
    ret += "" + secs;
    return ret;
}

function fancyTimeFormat2(duration)
{   
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;

    var ret = "";

    if (hrs > 0) {
        ret += "" + hrs + "d " + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + "h " + (secs < 10 ? "0" : "");
    ret += "" + secs + 'm';
    return ret;
}

function fancyTimeFormat3(duration)
{   
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;

    var ret = "";

    if (hrs > 0) {
        ret += "" + hrs + "h " + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + "m "// + (secs < 10 ? "0" : "");
    //ret += "" + secs + "s";
    return ret;
}
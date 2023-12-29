

/*var testFuncs = {}
var Events = {}

Events.Subscribe = function(name, func) {
    testFuncs[name] = function(...Args) {
        return func(...Args)
    }
}
Events.Call = function(event_name, ...Args) {
    console.log("Event Call", event_name, Args)
}*/



function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

const ammo_text = document.getElementById("ammo_text");

Events.Subscribe("SetAmmoText", function(ammo_in_mag, ammo_without_mag) {
    ammo_text.innerHTML = ammo_in_mag.concat(" / ", ammo_without_mag);
})
//testFuncs.SetAmmoText("30", "270")

const weapon_name = document.getElementById("weapon_name");

Events.Subscribe("SetWeaponNameText", function(weap_name) {
    if (weap_name != null && weap_name != "nil") {
        weapon_name.innerHTML = weap_name;
    } else {
        weapon_name.innerHTML = "";
    }
})

const players_money = document.getElementById("players_money");
let money_players_count = 0

Events.Subscribe("AddPlayerMoney", function(money, is_self) {
    money_players_count = money_players_count + 1
    players_money.style.setProperty('--players', money_players_count);
    let cell = document.createElement("div");
    cell.innerText = (money);
    players_money.appendChild(cell).className = "player_money";
    if (is_self) {
        cell.classList.add("self_money");
    }
})

Events.Subscribe("SetPlayerMoney", function(id, money, added_money) {
    let i;
    let players_money_elements = document.getElementsByClassName("player_money");
    for (i = 0; i < players_money_elements.length; i++) {
        if (i == id) {
            let parsed = parseInt(added_money, 10);
            if (parsed != 0) {
                players_money_elements[i].innerText = (money);
                let money_won = document.createElement("div");
                if (parsed >= 0) {
                    money_won.innerText = (added_money);
                } else {
                    money_won.innerText = ((parsed * -1).toString());
                }
                let r_int = getRandomInt(41)
                // console.log(r_int)
                // console.log(parsed >= 0);
                money_won.style.setProperty('--player_win_money_top', r_int);
                money_won.style.setProperty('--player_win_money_player', id);
                let append_element = players_money_elements[i].appendChild(money_won);
                if (parsed >= 0) {
                    append_element.className = "player_money_won"
                } else {
                    append_element.className = "player_money_lost"
                }
                setTimeout(() => {  if (players_money_elements[i] && money_won && players_money_elements[i].contains(money_won)) { players_money_elements[i].removeChild(money_won); } }, 2000);
            }
            break;
        }
    }
})


Events.Subscribe("RemovePlayerMoney", function(id) {
    let i;
    let players_money_elements = document.getElementsByClassName("player_money");
    for (i = 0; i < players_money_elements.length; i++) {
        if (i == id) {
            players_money.removeChild(players_money_elements[i]);
            money_players_count = money_players_count - 1
            players_money.style.setProperty('--players', money_players_count);
            break;
        }
    }
})

const waves_text = document.getElementById("waves_text");

Events.Subscribe("NewWave", function(wave_text) {
    waves_text.innerHTML = wave_text
    waves_text.classList.add("waves_animation")
    setTimeout(() => {  waves_text.classList.remove("waves_animation"); }, 4000);
})

Events.Subscribe("SetWave", function(wave_text) {
    waves_text.innerHTML = wave_text
})
// SetWave("2")

const player_perks = document.getElementById("player_perks");

Events.Subscribe("AddPerk", function(perk_src) {
    let img = document.createElement('img');
    img.src = perk_src;
    img.width = "95";
    img.height = "95";
    player_perks.appendChild(img).className = "player_perk";
})

Events.Subscribe("ResetPerks", function() {
    while (player_perks.firstChild) {
        player_perks.removeChild(player_perks.lastChild);
    }
})

const revive_div = document.getElementById("revive_bar_container");

function RemoveBarFromDiv() {
    while (revive_div.firstChild) {
        revive_div.removeChild(revive_div.lastChild);
    }
}

var revive_interval = false;

Events.Subscribe("StartRevive", function(revive_time) {
    revive_time = parseInt(revive_time, 10);
    let progress = document.createElement('progress');
    let value = 1;
    progress.max = "100";
    progress.value = "1";
    revive_div.appendChild(progress).className = "revive_progress";
    revive_interval = setInterval(frame, revive_time / 100);
    let startTime = new Date().getTime();
    function frame() {
        let endTime = new Date().getTime();
        if (value >= 100) {
            clearInterval(revive_interval);
            revive_interval = false;
            RemoveBarFromDiv();
        } else {
            value = value + 1 * ((endTime - startTime) / (revive_time / 100));
            progress.value = value;
            // progress.style.width = width + '%';
        }
        startTime = endTime;
    }
})

Events.Subscribe("StopRevive", function() {
    RemoveBarFromDiv();
    if (revive_interval) {
        clearInterval(revive_interval);
        revive_interval = false;
    }
})

const powerups_div = document.getElementById("powerups");

Events.Subscribe("AddPowerup", function(powerup_src) {
    let img = document.createElement('img');
    img.src = powerup_src;
    img.powerup = powerup_src
    img.width = "95";
    img.height = "95";
    powerups_div.appendChild(img).className = "powerup";
})

Events.Subscribe("RemovePowerup", function(powerup_src) {
    let i;
    let powerups_elements = document.getElementsByClassName("powerup");
    for (i = 0; i < powerups_elements.length; i++) {
        // console.log(powerups_elements[i].powerup)
        if (powerups_elements[i].powerup == powerup_src) {
            powerups_div.removeChild(powerups_elements[i]);
            break;
        }
    }
})

const tab_container = document.getElementById("tab_container");
const tab_top = document.getElementById("tab_top");

Events.Subscribe("ShowTab", function(players) {
    players = JSON.parse(players);
    for (let i = 0; i < players.length; i++) {
        let div_line = document.createElement("div");
        div_line.classList.add("tab_line");

        for (let i2 = 0; i2 < players[i].length; i2++) {
            if (players[i][i2] != "nil") {
                let div_item = document.createElement("div");
                div_item.classList.add("tab_item");
                div_item.innerText = players[i][i2];

                div_line.appendChild(div_item);
            }
        }

        tab_container.appendChild(div_line);
    }
    tab_container.classList.remove("hidden");
})

Events.Subscribe("HideTab", function() {
    while (tab_container.lastChild != tab_top) {
        tab_container.removeChild(tab_container.lastChild);
    }
    tab_container.classList.add("hidden");
})

Events.Subscribe("AddTabTopCategory", function(category) {
    let div_item = document.createElement("div");
    div_item.classList.add("tab_item");
    div_item.innerText = category;
    tab_top.appendChild(div_item);
})


const grenades_container = document.getElementById("grenades_container");

Events.Subscribe("SetGrenadesNB", function(nb) {
    while (grenades_container.firstChild) {
        grenades_container.removeChild(grenades_container.lastChild);
    }
    for (let i = 0; i < nb; i++) {
        let img = new Image(35, 35);
        img.src = "images/grenade2.png"
        img.classList.add("grenade");

        grenades_container.appendChild(img);
    }
})

const htp_frame = document.getElementById("HTP_frame");

Events.Subscribe("ShowHTPFrame", function() {
    htp_frame.classList.remove("hidden");
})

Events.Subscribe("HideHTPFrame", function() {
    htp_frame.classList.add("hidden");
})

const hBar = document.getElementById("health-bar-container"),
    bar = document.getElementById("health-bar"),
    hit = document.getElementById("hit-health");

var CurrentHealth = null;

Events.Subscribe("UpdateGUIHealth", function(max_health, new_health) {
    if (CurrentHealth == null) {
        CurrentHealth = max_health;
    }
    hBar.classList.remove("hidden");

    if (new_health < 0) {
        new_health = 0;
    }

    var barWidth = (new_health / max_health) * 100 + "%";
    //console.log(barWidth);

    if (CurrentHealth > 0 && CurrentHealth - new_health > 0) {
        let hitWidth = ((CurrentHealth - new_health) / max_health) * 100 + "%";
        //console.log(hitWidth);
    
        hit.style.width = hitWidth;
    }

    setTimeout(function(){
        hit.style.width = "0";
        bar.style.width = barWidth;
    }, 300);

    CurrentHealth = new_health;
})

Events.Subscribe("HideGUIHealth", function() {
    hBar.classList.add("hidden");
    CurrentHealth = null;
})

let Bot_Order_Wheel = null;
const Bot_Order_Wheel_Container = document.getElementById("orders-wheel-container");

function HideBotOrderWheel() {
    if (Bot_Order_Wheel) {
        Bot_Order_Wheel.remove();
        Bot_Order_Wheel = null;
    }
}

Events.Subscribe("HideBotOrderWheel", HideBotOrderWheel)

Events.Subscribe("ShowBotOrderWheel", function(orders) {
    Bot_Order_Wheel = new BloomingMenu({
        itemsNum: orders,
        fatherElement: Bot_Order_Wheel_Container,
        startAngle: 0,
        endAngle: 30 * orders,
    })
    Bot_Order_Wheel.render()
    Bot_Order_Wheel.open()

    Bot_Order_Wheel.props.elements.main.remove()

    Bot_Order_Wheel.props.elements.items.forEach(function (item, index) {
        item.addEventListener('click', function () {
           //console.log('Item # ' + index + ' was clicked')
           Events.Call("BotOrderSelect", index);
           HideBotOrderWheel();
        })
    })
})


const players_voip_container = document.getElementById("VOIP-container");
let voip_players_count = 0

let destroying_timeouts = {}

Events.Subscribe("PlayerStartedVOIP", function(player_name, player_id) {
    let exists = false;
    for (let i = 0; i < players_voip_container.children.length; i++) {
        if (players_voip_container.children[i].dataset.player_id == player_id) {
            exists = true;
            players_voip_container.children[i].classList.remove("voip_disappear_anim");
            if (destroying_timeouts[player_id]) {
                clearTimeout(destroying_timeouts[player_id]);
            }
            destroying_timeouts[player_id] = null;
            break;
        }
    }
    if (!exists) {
        voip_players_count = voip_players_count + 1
        players_voip_container.style.setProperty('--players_voip', voip_players_count);
        let cell = document.createElement("div");
        cell.innerText = "🎙️ " + player_name;
        cell.dataset.player_id = player_id;
        players_voip_container.appendChild(cell).className = "player_voip";
    }
})

Events.Subscribe("PlayerStoppedVOIP", function(player_id) {
    for (let i = 0; i < players_voip_container.children.length; i++) {
        if (players_voip_container.children[i].dataset.player_id == player_id) {
            players_voip_container.children[i].classList.add("voip_disappear_anim");
            destroying_timeouts[player_id] = setTimeout(function() {
                for (let i = 0; i < players_voip_container.children.length; i++) {
                    if (players_voip_container.children[i].dataset.player_id == player_id) {
                        players_voip_container.removeChild(players_voip_container.children[i]);
                        destroying_timeouts[player_id] = null;
                        voip_players_count = voip_players_count - 1
                        players_voip_container.style.setProperty('--players_voip', voip_players_count);
                        break;
                    }
                }
            }, 700);
            break;
        }
    }
})


function ShowElementByID(id, show) {
    let elt = document.getElementById(id)
    if (elt) {
        if (show) {
            elt.classList.remove("hidden")
        } else {
            elt.classList.add("hidden")
        }
    }
}
Events.Subscribe("ShowElementByID", ShowElementByID)

Events.Subscribe("ClearFrameTab", function(frame_id, tab_id) {
    if (VZ_Frames[frame_id]) {
        if (VZ_Frames[frame_id].Items_Containers[tab_id]) {
            let c_length = VZ_Frames[frame_id].Items_Containers[tab_id].children.length
            for (let i = 0; i < c_length; i++) {
                VZ_Frames[frame_id].Items_Containers[tab_id].removeChild(VZ_Frames[frame_id].Items_Containers[tab_id].children[0])
            }
        }
    }
})

const Help_Default_Keys_container = document.getElementById("Default_Keys_Container")
Events.Subscribe("HelpMenuDefaultKeys", function(tbl) {
    
    for (let i = 0; i < tbl.length; i++) {
        let dk_div = document.createElement("div")
        dk_div.classList.add("HTP_text")
        dk_div.innerText = "- " + tbl[i][1] + " : " + tbl[i][0]

        Help_Default_Keys_container.appendChild(dk_div)
    }
})

let levels_container
let levels_bar_bg
let levels_bar
let levels_text
let bar_percentage = 10

let bar_update_last = new Date().getTime();
let bar_update_anim_time = 0
let bar_update_old_old_width = 0
let bar_update_target_width = 0

Events.Subscribe("EnableVZLevels", function() {
    levels_container = document.createElement("div")
    levels_container.classList.add("lvls_container")
    levels_container.id = "lvls_container"

    levels_bar_bg = document.createElement("div")
    levels_bar_bg.classList.add("lvls_bar_bg")

    levels_bar = document.createElement("div")
    levels_bar.classList.add("lvls_bar")

    levels_text = document.createElement("div")
    levels_text.classList.add("lvls_text")

    levels_bar_bg.appendChild(levels_bar)

    levels_container.appendChild(levels_bar_bg)

    levels_container.appendChild(levels_text)

    document.body.appendChild(levels_container)

    /*tab_levels = document.createElement("div")
    tab_levels.classList.add("tab_item")
    tab_levels.innerText = "Level"

    levels_container.appendChild(tab_levels)*/
})

Events.Subscribe("SetBarPercentage", function(new_perc) {
    if (levels_bar) {
        levels_bar.classList.remove("lvlbar_up_anim")
        levels_bar.classList.remove("lvlbar_down_anim")

        let curTime = new Date().getTime();
        let old_bar_percentage = bar_percentage

        // delta | bar_update_anim_time    | bar_update_last
        //       | bar_update_target_width - bar_update_old_old_width | bar_update_old_old_width
        if (curTime - bar_update_last > 0 && curTime - bar_update_last < bar_update_anim_time) {
            old_bar_percentage = ((curTime - bar_update_last) * (bar_update_target_width - bar_update_old_old_width) / bar_update_anim_time) + bar_update_old_old_width
            //console.log(old_bar_percentage)
        }
        
        levels_bar.style.setProperty('--bar-target-width', new_perc + "%");
        levels_bar.style.setProperty('--bar-target-width-old', old_bar_percentage + "%")
        levels_bar.style.setProperty('--won-blur-px', Math.floor(Math.abs(new_perc - old_bar_percentage) * 7 / 10));
        levels_bar.style.setProperty('--won-spread-px', Math.floor(Math.abs(new_perc - old_bar_percentage) / 10));
        levels_bar.style.setProperty('--bar-anim-time', Math.floor(Math.abs(new_perc - old_bar_percentage) * 20) + "ms");
        levels_bar.offsetHeight;

        bar_update_last = new Date().getTime()
        bar_update_anim_time = Math.floor(Math.abs(new_perc - old_bar_percentage) * 20)
        bar_update_old_old_width = old_bar_percentage
        bar_update_target_width = new_perc

        //console.log(new_perc, bar_update_anim_time)

        if (new_perc <= old_bar_percentage) {
            //levels_bar.style.width = new_perc + "%"
            levels_bar.classList.add("lvlbar_down_anim")
        } else {
            levels_bar.classList.add("lvlbar_up_anim")
        }
        bar_percentage = new_perc
    }
})

Events.Subscribe("SetLvlText", function(text) {
    if (levels_text) {
        levels_text.innerText = text
    }
})



const Notifs_Container = document.getElementById("Notifications-container")

Events.Subscribe("AddNotification", function(text, time) {
    let notification = document.createElement("div")
    notification.classList.add("Notification")
    notification.style.setProperty('--notif-anim-time', Math.floor(time) + "ms")
    notification.style.setProperty('--notif-font-px', Math.floor(100 / Math.log(text.length * 15)))
    notification.innerText = text

    let notif_progress = document.createElement("div")
    notif_progress.classList.add("Notification_Progress")
    notif_progress.style.setProperty('--notif-anim-time', Math.floor(time) + "ms")
    
    notification.appendChild(notif_progress)

    Notifs_Container.appendChild(notification)
    setTimeout(function() {
        Notifs_Container.removeChild(notification)
    }, time)
})



const repack_container = document.getElementById("Repack-container")
let repack_img

Events.Subscribe("ShowRepackIcon", function(image) {
    if (repack_img) {
        repack_container.removeChild(repack_img)
        repack_img = null
    }
    if (image) {
        repack_img = document.createElement('img');
        repack_img.src = image;
        repack_img.width = "80";
        repack_img.height = "80";
        //repack_img.classList.add("repack_img")
        repack_container.appendChild(repack_img)
    }
})


/*testFuncs.ShowRepackIcon("images/blast_furnace_icon.png")
testFuncs.ShowRepackIcon("images/electric_icon.png")
testFuncs.ShowRepackIcon()*/



/*testFuncs.AddNotification("test1", 10000)
testFuncs.AddNotification("test2", 12000)
testFuncs.AddNotification("You levelled Up !", 12000)*/



/*testFuncs.EnableVZLevels()
testFuncs.SetBarPercentage(0);
for (let i = 1; i < 101; i++) {
    setTimeout(function() {
        if (bar_percentage <= 95) {
            testFuncs.SetBarPercentage((i*5) % 100);
        } else {
            testFuncs.SetBarPercentage(0);
        }
    }, 400*i)
}
testFuncs.SetBarPercentage(0);
testFuncs.SetLvlText("200")*/


/*
testFuncs.PlayerStartedVOIP("Voltaism", 1)
testFuncs.PlayerStartedVOIP("Syed", 2)
testFuncs.PlayerStartedVOIP("Timmy", 3)
testFuncs.PlayerStartedVOIP("NegativeName", 4)

setTimeout(function() {
    testFuncs.PlayerStoppedVOIP(2);
}, 2500)

setTimeout(function() {
    testFuncs.PlayerStoppedVOIP(3);
    testFuncs.PlayerStartedVOIP("Syed", 2)
}, 3000)

setTimeout(function() {
    testFuncs.PlayerStoppedVOIP(2);
}, 3500)

*/







//testFuncs.ShowBotOrderWheel(3);

/*setTimeout(() => {  testFuncs.UpdateGUIHealth(100, 80); }, 500);
setTimeout(() => {  testFuncs.UpdateGUIHealth(100, 20); }, 2000);
setTimeout(() => {  testFuncs.UpdateGUIHealth(100, 100); }, 4000);*/


//testFuncs.ShowHTPFrame()

/*testFuncs.AddPowerup("images/instakill_icon.png")
testFuncs.AddPowerup("images/x2_icon.png")
testFuncs.RemovePowerup("images/x2_icon.png")
testFuncs.RemovePowerup("images/instakill_icon.png")*/


/*setTimeout(() => {  testFuncs.ReviveStart("5000"); }, 500);
setTimeout(() => {  testFuncs.StopRevive(); }, 2000);*/



/*testFuncs.AddPerk("images/Quick_Revive_icon.png")
testFuncs.AddPerk("images/Juggernog_icon.png")
testFuncs.AddPerk("images/Doubletap_icon.png")
testFuncs.AddPerk("images/three_gun_icon.png")*/


// testFuncs.ResetPerks()

/*NewWave("2")
setTimeout(() => { testFuncs. NewWave("3"); }, 5000);*/

/*testFuncs.AddPlayerMoney("500")

testFuncs.AddPlayerMoney("1000")
testFuncs.AddPlayerMoney("1111")

testFuncs.AddPlayerMoney("11111")

testFuncs.RemovePlayerMoney("1")

testFuncs.RemovePlayerMoney("1")

testFuncs.SetPlayerMoney(0, "666", "50")
testFuncs.SetPlayerMoney(1, "6666", "100")
setTimeout(() => {  testFuncs.SetPlayerMoney(0, "666", "10"); }, 500);
setTimeout(() => {  testFuncs.SetPlayerMoney(1, "200", "100"); }, 500);

setTimeout(() => {  testFuncs.SetPlayerMoney(0, "0", "10"); }, 1500);
setTimeout(() => {  testFuncs.SetPlayerMoney(1, "1", "100"); }, 1500);

setTimeout(() => {  testFuncs.SetPlayerMoney(0, "66666", "10"); }, 2500);
setTimeout(() => {  testFuncs.SetPlayerMoney(1, "666666", "100"); }, 2500);*/

/*testFuncs.AddPlayerMoney("500")
testFuncs.SetPlayerMoney(0, "400", "-100")*/

//testFuncs.HideTab();

//testFuncs.ShowTab('[["Volta", "35", "-666", "5626526", "30"], ["Syed", "256", "33", "1243", "999"], ["Lighter", "223", "300", "123553", "102"], ["Derpius", "42", "400", "356353", "40"], ["Timmy", "253", "450", "2453536", "60"], ["Olivato", "232", "500", "355236", "70"]]');

/*testFuncs.SetGrenadesNB(2);
testFuncs.SetGrenadesNB(4);*/
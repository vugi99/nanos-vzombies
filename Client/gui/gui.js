

/*var testFuncs = {}
var Events = {}

Events.Subscribe = function(name, func) {
    testFuncs[name] = function(...Args) {
        return func(...Args)
    }
}*/

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

const ammo_text = document.getElementById("ammo_text");

Events.Subscribe("SetAmmoText", function(ammo_in_mag, ammo_without_mag) {
    ammo_text.innerHTML = ammo_in_mag.concat(" / ", ammo_without_mag);
})
//testFuncs.SetAmmoText("30", "270")

const players_money = document.getElementById("players_money");
let money_players_count = 0

Events.Subscribe("AddPlayerMoney", function(money) {
    money_players_count = money_players_count + 1
    players_money.style.setProperty('--players', money_players_count);
    let cell = document.createElement("div");
    cell.innerText = (money);
    players_money.appendChild(cell).className = "player_money";
})

Events.Subscribe("SetPlayerMoney", function(id, money, added_money) {
    let i;
    let players_money_elements = document.getElementsByClassName("player_money");
    for (i = 0; i < players_money_elements.length; i++) {
        if (i == id) {
            players_money_elements[i].innerText = (money);
            let money_won = document.createElement("div");
            let parsed = parseInt(added_money, 10);
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
    waves_text.className = "waves_animation"
    setTimeout(() => {  waves_text.className = ""; }, 4000);
})

Events.Subscribe("SetWave", function(wave_text) {
    waves_text.innerHTML = wave_text
})
// SetWave("2")

const player_perks = document.getElementById("player_perks");

Events.Subscribe("AddPerk", function(perk_src) {
    let img = document.createElement('img');
    img.src = perk_src;
    img.width = "50";
    img.height = "50";
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
    function frame() {
        if (value >= 100) {
            clearInterval(revive_interval);
            revive_interval = false;
            RemoveBarFromDiv();
        } else {
            value++;
            progress.value = value;
            // progress.style.width = width + '%';
        }
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
    img.width = "50";
    img.height = "50";
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
            let div_item = document.createElement("div");
            div_item.classList.add("tab_item");
            div_item.innerText = players[i][i2];

            div_line.appendChild(div_item);
        }

        tab_container.appendChild(div_line);
    }
    tab_container.classList.remove("tab_hidden");
})

Events.Subscribe("HideTab", function() {
    while (tab_container.lastChild != tab_top) {
        tab_container.removeChild(tab_container.lastChild);
    }
    tab_container.classList.add("tab_hidden");
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

/*AddPlayerMoney("500")

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

/*testFuncs.ShowTab(
    [
        [
            "Error",
            "nil",
            "NON",
            "NON"
        ],
    ]
);

testFuncs.HideTab();

testFuncs.ShowTab(
    [
        [
            "Volta",
            "35",
            "5626526",
            "30"
        ],
        [
            "Syed",
            "256",
            "1243",
            "999"
        ],
        [
            "Lighter",
            "223",
            "123553",
            "102"
        ],
        [
            "Derpius",
            "42",
            "356353",
            "40"
        ],
        [
            "Timmy",
            "253",
            "2453536",
            "60"
        ],
        [
            "Olivato",
            "232",
            "355236",
            "70"
        ],
    ]
);*/

/*testFuncs.SetGrenadesNB(2);
testFuncs.SetGrenadesNB(4);*/
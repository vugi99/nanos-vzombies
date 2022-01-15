
function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

const ammo_text = document.getElementById("ammo_text");

Events.Subscribe("SetAmmoText", function(ammo_in_mag, ammo_without_mag) {
    ammo_text.innerHTML = ammo_in_mag.concat(" / ", ammo_without_mag);
})
//SetAmmoText("30", "270")

const players_money = document.getElementById("players_money");
let players_count = 0

Events.Subscribe("AddPlayerMoney", function(money) {
    players_count = players_count + 1
    players_money.style.setProperty('--players', players_count);
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
            setTimeout(() => {  if (players_money_elements[i].contains(money_won)) { players_money_elements[i].removeChild(money_won); } }, 2000);
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
            players_count = players_count - 1
            players_money.style.setProperty('--players', players_count);
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
/*AddPowerup("images/instakill_icon.png")
AddPowerup("images/x2_icon.png")
RemovePowerup("images/x2_icon.png")
RemovePowerup("images/instakill_icon.png")*/


/*setTimeout(() => {  ReviveStart("5000"); }, 500);
setTimeout(() => {  StopRevive(); }, 2000);*/



/*AddPerk("images/Quick_Revive_icon.png")
AddPerk("images/Juggernog_icon.png")
AddPerk("images/Doubletap_icon.png")
AddPerk("images/three_gun_icon.png")*/


// ResetPerks()

/*NewWave("2")
setTimeout(() => {  NewWave("3"); }, 5000);*/

/*AddPlayerMoney("500")

AddPlayerMoney("1000")
AddPlayerMoney("1111")

AddPlayerMoney("11111")

RemovePlayerMoney("1")

RemovePlayerMoney("1")

SetPlayerMoney(0, "666", "50")
SetPlayerMoney(1, "6666", "100")
setTimeout(() => {  SetPlayerMoney(0, "666", "10"); }, 500);
setTimeout(() => {  SetPlayerMoney(1, "200", "100"); }, 500);

setTimeout(() => {  SetPlayerMoney(0, "0", "10"); }, 1500);
setTimeout(() => {  SetPlayerMoney(1, "1", "100"); }, 1500);

setTimeout(() => {  SetPlayerMoney(0, "66666", "10"); }, 2500);
setTimeout(() => {  SetPlayerMoney(1, "666666", "100"); }, 2500);*/

/*AddPlayerMoney("500")
SetPlayerMoney(0, "400", "-100")*/
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


const background = document.getElementById("background");


const imposter_image_container = document.getElementById("imposter_image_container");

Events.Subscribe("ImposterImageShow", function(duration, dark_bg) {
    if (duration >= 0) {
        imposter_image_container.classList.remove("hidden");
        imposter_image_container.style.setProperty('--imposter-show-duration', duration + "ms");
        imposter_image_container.classList.add("ppg_artwork_disappear");

        if (dark_bg) {
            background.classList.remove("hidden");
            background.style.setProperty('--imposter-show-duration', duration + "ms");
            background.classList.add("background_to_transparent");
        }

        setTimeout(function () {
            imposter_image_container.classList.add("hidden");
            imposter_image_container.classList.remove("ppg_artwork_disappear");

            if (dark_bg) {
                background.classList.add("hidden");
                background.classList.remove("background_to_transparent");
            }
        }, duration);
    }
})

/*
testFuncs.ImposterImageShow(1000, true);
setTimeout(function () {
    testFuncs.ImposterImageShow(5000);
}, 3000);*/





// internal state
const state = {
    players: [], // {id, name, alive:true}
    votes: {},   // voterId -> targetId
    votingActive: false,
    discussActive: false,
    resultActive: false,
    duration: 30,
    timer: null,
    remaining: 0,
    listeners: {},
    LocalId: null,
};

// helpers
const uid = (()=>{let n=1; return ()=> ("p"+ (n++)) })();

// DOM refs
const playersGrid = document.getElementById('playersGrid');
const voteList = document.getElementById('voteList');
const phaseText = document.getElementById('phaseText');
const timerText = document.getElementById('timerText');
const resultText = document.getElementById('resultText');

// UI Buttons
/*document.getElementById('addPlayerBtn').addEventListener('click', ()=>{
const name = document.getElementById('newName').value.trim();
if(name) VotingAPI.addPlayer(name);
document.getElementById('newName').value = '';
});*/
/*
document.getElementById('startBtn').addEventListener('click', ()=> VotingAPI.startVoting());
document.getElementById('endBtn').addEventListener('click', ()=> VotingAPI.endVoting());
document.getElementById('resetBtn').addEventListener('click', ()=> VotingAPI.reset());*/
document.getElementById('skipBtn').addEventListener('click', ()=> VotingAPI.castVote(state.LocalId,'skip'));

// render
function renderPlayers(){
    playersGrid.innerHTML = '';

    const localselectedid = state.votes[state.LocalId];

    state.players.forEach(p=>{
        const div = document.createElement('button');
        div.className = 'player' + (p.alive? '':' dead');
        if (!p.alive) {
            div.classList.add("ppg_voting_player_dead_button");
        } else if (p.id === localselectedid) {
            div.classList.add("ppg_voting_player_local_selected");
        } else {
            div.classList.add("ppg_voting_player_alive_button");
        }
        
        div.id = 'player-'+p.id;
        div.tabIndex = 0;
        //div.setAttribute('role','button');
        div.innerHTML = `
        <div class="avatar">${escapeHTML(p.name.slice(0,2)).toUpperCase()}</div>
        <div class="name">${escapeHTML(p.name)}</div>
        <div class="alive">${p.alive? 'Alive':'Dead'}</div>
        <div class="voteBadge" id="voteBadgePlayer_${p.id}">${countVotesFor(p.id)}</div>
        `;

        // click to cast vote as if admin (useful for demo): clicking sets admin as voter and target
        div.addEventListener('click', ()=>{
            if(!state.votingActive) return;
            // open small confirmation; minimal: cast vote as 'local' voter
            //const localVoter = state.players.find(x=>x.alive) && state.players[0] && state.players[0].id; // naive
            // If user wants feel free to call VotingAPI.castVote
            //const localVoter = state.LocalId;
            VotingAPI.castVote('local', p.id);
        });

        playersGrid.appendChild(div);
    });
    updateVoteList();
}

function updateVoteList(){
    voteList.innerHTML = '';
    const lines = [];
    Object.entries(state.votes).forEach(([voter,target])=>{
        const voterName = getPlayerName(voter) || voter;
        const targetName = (target==='skip')? 'Skip' : (getPlayerName(target) || target || '—');
        const el = document.createElement('div'); el.className='voteItem';
        el.innerHTML = `<div>${escapeHTML(voterName)}</div><div style="opacity:0.9">→ ${escapeHTML(targetName)}</div>`;
        voteList.appendChild(el);
    });
}

function getPlayerName(id){
    const p = state.players.find(x=>x.id===id);
    return p? p.name : null;
}

function countVotesFor(id){
    let n=0; Object.values(state.votes).forEach(v=>{ if(v===id) n++ }); return n;
}

function escapeHTML(s){ return String(s).replace(/[&<>"']/g, function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":"&#39;"}[c]}); }

function notify(eventName, payload){
    (state.listeners[eventName]||[]).forEach(fn=>{ try{ fn(payload) }catch(e){console.error(e)} });
}

// voting logic
function startTimer(seconds){
stopTimer();
state.remaining = seconds;
timerText.textContent = `${state.remaining}s`;
state.timer = setInterval(()=>{
    state.remaining -= 1;
    timerText.textContent = `${state.remaining}s`;
    if(state.remaining<=0){
        //endVoting();
        stopTimer();
    }
}, 1000);
}
function stopTimer(){ if(state.timer) { clearInterval(state.timer); state.timer=null } }

function computeResult(){
    // tally
    const tally = {};
    let skip = 0;
    Object.values(state.votes).forEach(t=>{ if(t==='skip') skip++; else tally[t]=(tally[t]||0)+1 });
    // find max
    let max = -1; let winners = [];
    Object.entries(tally).forEach(([id,c])=>{
        if(c>max){ max=c; winners=[id] } else if(c===max){ winners.push(id) }
    });
    // decide
    if(winners.length===0){ return {type:'no_votes'} }
    if(winners.length>1){ return {type:'tie', winners, tally} }
    // single winner; check skip
    const winner = winners[0];
    const winnerCount = tally[winner];
    if(skip>winnerCount) return {type:'skip_wins', winner:null, tally}
    return {type:'eject', winner, tally, count:winnerCount}
}

function applyResult(res){
    if(res.type==='no_votes'){
        resultText.textContent = 'No votes';
    } else if(res.type==='tie'){
        resultText.textContent = `Equal between ${res.ties.map(getPlayerName).join(', ')}`;
    } else if(res.type==='skip_wins'){
        resultText.textContent = `Skip wins`;
    } else if (res.type === 'no_one_eliminated'){
        resultText.textContent = `No one eliminated`;
    } else if(res.type==='eliminate'){
        const p = state.players.find(x=>x.id===res.eliminated);
        if(p){ p.alive = false; }
        resultText.textContent = `${p? p.name : res.eliminated} eliminated (${res.count} votes)`;
    }
    renderPlayers();
    notify('result', res);
}

// API
const VotingAPI = {
    init(config={}, keep_votes=false){
        // config: players: [names], duration: seconds
        state.players = [];
        if (!keep_votes) {
            state.votes = {};
        }
        state.votingActive = false;
        state.discussActive = false;
        state.resultActive = false;
        state.LocalId = config.LocalId;
        if(Array.isArray(config.players)){
            config.players.forEach(n=> this.addPlayer(n.id, n.name, n.alive));
        }
        if(typeof config.duration === 'number') state.duration = config.duration;
        phaseText.textContent = 'Discuss';
        timerText.textContent = '—';
        resultText.textContent = "No result yet";
        renderPlayers();
        notify('change', {state});
        return true;
    },
    setVotes(votes={}){
        state.votes = votes;
        renderPlayers();
        notify('change', {state});
        return true;
    },
    addPlayer(id, name, alive=true){
        const p = {id: id, name: String(name||'Joueur'), alive:alive};
        state.players.push(p);
        renderPlayers();
        notify('change', {action:'add', player:p});
        return p.id;
    },
    setPlayers(players={}){
        state.players = players;
        renderPlayers();
        notify('change', {state});
        return true;
    },
    removePlayer(id){
        const idx = state.players.findIndex(x=>x.id===id);
        if(idx>=0) state.players.splice(idx,1);
        delete state.votes[id];
        renderPlayers();
        notify('change', {action:'remove', id});
    },
    startDiscuss(durationSeconds) {
        if(state.votingActive) return;
        if(state.discussActive) return;
        if(state.resultActive) return;
        state.discussActive = true;
        state.votes = {};
        phaseText.textContent = 'Discussion';
        startTimer(durationSeconds || state.duration);
        resultText.textContent = 'Discussing...';
        notify('discuss',{duration:durationSeconds||state.duration});
    },
    startVoting(durationSeconds){
        if (state.resultActive) return;
        if(state.votingActive) return;
        state.discussActive = false;
        state.votingActive = true;
        state.votes = {}; // reset votes at start
        phaseText.textContent = 'Voting in progress';
        startTimer(durationSeconds || state.duration);
        resultText.textContent = 'Voting in progress...';
        notify('start',{duration:durationSeconds||state.duration});
    },
    castVote(voterId, targetId){
        if(!state.votingActive){ console.warn('Voting not active'); return }

        if(voterId==='local'){
            /*const firstAlive = state.players.find(p=>p.alive);
            if(!firstAlive){ console.warn('No alive players'); return }
            voterId = firstAlive.id;*/
            voterId = state.LocalId;
        }

        if (voterId === null) { return }

        // Cannot vote as spectator
        if (voterId === state.LocalId && state.LocalId === 'spectator') { return }

        // Cannot vote yourself
        //if (voterId === state.LocalId && targetId === state.LocalId) { return }

        // Cannot vote a dead player
        if (voterId === state.LocalId) {
            if (targetId) {
                const p = state.players.find(x=>x.id===targetId);
                if(p && (p.alive === false)){ 
                    return
                }
            }
        }

        // if voter is not a known player, add ephemeral
        if(!state.players.find(p=>p.id===voterId) && voterId!=='admin_skip' && voterId!=='local'){
            // allow casting by custom ids (e.g., spectator inputs)
            // but we don't show them in players grid
        }

        // allow skip or null
        //if(targetId===null) targetId = 'skip';

        const oldVote = state.votes[voterId];

        if (targetId === null) {
            delete state.votes[voterId];
        } else {
            state.votes[voterId] = targetId;
        }
        renderPlayers();

        // Optimized votes (prevent rendering again the Players section)
        /*
        if (oldVote) {
            let elt_badge_oldVote = document.getElementById(`voteBadgePlayer_${oldVote}`);
            if (elt_badge_oldVote) {
                elt_badge_oldVote.innerText = countVotesFor(oldVote);
            }
        }

        if (targetId) {
            let elt_badge_newVote = document.getElementById(`voteBadgePlayer_${targetId}`);
            if (elt_badge_newVote) {
                elt_badge_newVote.innerText = countVotesFor(targetId);
            }
        }
            
        updateVoteList();*/

        if (voterId === state.LocalId) {
            Events.Call("LocalPlayerVote", targetId);
        }

        notify('vote',{voter:voterId,target:targetId});
    },
    endVoting(res={}, durationSeconds){
        /*if(!state.votingActive) return;
        state.votingActive = false;
        stopTimer();
        phaseText.textContent = 'Résultats';
        const res = computeResult();
        applyResult(res);
        notify('end',res);*/

        /*if(!state.votingActive) return;*/
        if (state.resultActive) return;
        state.discussActive = false;
        state.votingActive = false;
        state.resultActive = true;
        startTimer(durationSeconds || state.duration);
        phaseText.textContent = 'Results';
        //const res = computeResult();
        applyResult(res);
        notify('end',res);
    },
    reset(){
        stopTimer();
        state.votes = {};
        state.players.forEach(p=> p.alive = true);
        state.votingActive = false;
        state.discussActive = false;
        state.resultActive = false;
        phaseText.textContent = 'Discuss';
        timerText.textContent = '—';
        resultText.textContent = "No result yet";
        renderPlayers();
        notify('change',{action:'reset'});
        return true;
    },
    setLocalId(lid="spectator") {
        state.LocalId = lid;
    },
    getVotes(){ return Object.assign({}, state.votes) },
    getPlayers(){ return JSON.parse(JSON.stringify(state.players)) },
    on(eventName, cb){ (state.listeners[eventName]||(state.listeners[eventName]=[])).push(cb) },
    off(eventName, cb){ if(!state.listeners[eventName]) return; state.listeners[eventName]=state.listeners[eventName].filter(f=>f!==cb) }
};

// expose globally
window.VotingAPI = VotingAPI;

const VotingWrap = document.getElementById("VotingWrap");
function ShowVotingWrap(show) {
    if (show) {
        VotingWrap.classList.remove("hidden");
    } else {
        VotingWrap.classList.add("hidden");
        
    }
}

const votingclosebtn = document.getElementById("ppgvotingclosebtn");
if (votingclosebtn) {
    votingclosebtn.addEventListener('click', function() { ShowVotingWrap(false); Events.Call("VotingUIClosed") });
}

// accessibility: keyboard shortcuts for demo
/*document.addEventListener('keydown', (e)=>{
if(e.key==='v'){ VotingAPI.startVoting(); }
if(e.key==='e'){ VotingAPI.endVoting(); }
if(e.key==='r'){ VotingAPI.reset(); }
});*/

Events.Subscribe("VotingUICall", function(func_name, ...Args) {
    if (VotingAPI[func_name]) {
        return VotingAPI[func_name](...Args);
    }
})

Events.Subscribe("VotingUIInit", function(config, keep_votes) {
    if (typeof config === 'string' || config instanceof String) {
        return VotingAPI.init(JSON.parse(config), keep_votes);
    } else {
        return false;
    }
})

Events.Subscribe("VotingUIShowResults", function(res, durationSeconds) {
    if (typeof res === 'string' || res instanceof String) {
        return VotingAPI.endVoting(JSON.parse(res), durationSeconds);
    } else {
        return false;
    }
})

Events.Subscribe("VotingUISetVotes", function(votes) {
    if (typeof votes === 'string' || votes instanceof String) {
        return VotingAPI.setVotes(JSON.parse(votes));
    } else {
        return false;
    }
})

Events.Subscribe("VotingUISetPlayers", function(players) {
    if (typeof players === 'string' || players instanceof String) {
        return VotingAPI.setPlayers(JSON.parse(players));
    } else {
        return false;
    }
})


Events.Subscribe("ShowVotingWrap", ShowVotingWrap);

/*testFuncs.ShowVotingWrap(true);

//VotingAPI.init({players:[{id:"1", name: 'Red'},{id:"2", name: 'Blue'},{id:"3", name: 'Green', alive:false},{id:"4", name: 'Yellow'},{id:"5", name: 'Pink'},{id:"6", name: 'Black'}]});

//VotingAPI.startVoting(30);*/
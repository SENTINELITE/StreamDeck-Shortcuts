
//Someone with more knowledge of JS would be able to make this better. 😉
//Shoutout to GitHub CoPilot for the assistance!

//import { greet, message } from './newFile.js';

let websocket = null,
uuid = null,
actionInfo = {};

//

const SdsEvents = {
filteredFolder: Symbol("filteredFolder")
}

listOfCuts = ['Placeholder', '2'];
var listOfShortcutsVersionTwo = {};

function ClearTempData() {
    console.log('clearing temp data')
    listOfCuts.length = 0;
    listOfShortcutsVersionTwo.length = 0;
}

function connectElgatoStreamDeckSocket(inPort, inUUID, inRegisterEvent, inInfo, inActionInfo) {
    uuid = inUUID;
    
    actionInfo = JSON5.parse(inActionInfo);
    websocket = new WebSocket('ws://localhost:' + inPort);
    
    websocket.onopen = function () {
        const json = {
        event: inRegisterEvent,
        uuid: inUUID
        };
        websocket.send(JSON.stringify(json));
        console.log("onopen : Payload: ", JSON.stringify(json));
        requestSettings('requestSettings');
    };
    
    websocket.onmessage = function (evt) { //From Backend to PI!
        // Received message from Stream Deck
        const jsonObj = JSON5.parse(evt.data);
        console.log("JSON DATA IMPORTANT READ!", jsonObj)
        hasResent = true; //This is required due to the Swift Websocket not loading fast enough. This prevent's requesting the settings numerous times.
        if (jsonObj.event === 'sendToPropertyInspector') {
            const payload = jsonObj.payload;
            //            shortcutsFolder = payload.voices
            
            console.log("ZYX Payload -> ", payload)
            
            switch (payload.sdsEvt) {
                case "initialPayload":
                    var sentAt = payload.sentAt
                    var totalShortcuts = payload.totalShortcuts
                    var totalListOfShortcuts = payload.totalListOfShortcuts
                    var totalFolders = payload.totalFolders
                    var processShortcutsSwift = payload.processShortcutsSwift
                    
                    let payloadSize = logSizeInKilobytes('initPayload', payload)
                    console.log("📦🚀 payload Size", payloadSize)
                    console.log("📦 processShortcutsSwift", processShortcutsSwift)
                    console.log("📦 shortcuts #", totalShortcuts)
                    console.log("📦 totalListOfShortcuts #", totalListOfShortcuts)
                    console.log("📦 folders #", totalFolders)
                    console.log("📦 initialPayload")
                    shortcutsFolder = payload.folders
                    console.log("XYZ: ", shortcutsFolder)
                    initPayload(sentAt, processShortcutsSwift, payloadSize)
                    refreshListOfShortcutsFolders()
                    break;
                case "filteredFolder": //This needs to get removed
                    console.log("📦 filteredFolder")
                    console.log("Parsing new Payload Data")
                    console.log("New X -> ", payload)
                    console.log("New Filted Array -> ", payload.filteredShortcuts)
                    console.log("New SdsEvnt -> ", payload.sdsEvt)
                    
                    shortcutsFrontend = document.getElementById("shortcuts_list");
                    shortcutsFrontend.length = 0;
                    listOfShortcutsVersionTwo.length = 0;
                    
                    while(shortcutsFrontend.firstChild) {
                        shortcutsFrontend.firstChild.remove();
                    }
                    
                    while(listOfShortcutsVersionTwo.firstChild) {
                        listOfShortcutsVersionTwo.firstChild.remove();
                    }
                    
                    
                    
                    listOfShortcutsVersionTwo = payload.filteredShortcuts
                    
                    var loopNum = 0;
                    for (var val of listOfShortcutsVersionTwo) {
                        console.log('  ⭕ Gen Option ', val)
                        var ID = loopNum;
                        option = genOption(val, ID); //ID = loop num...
                        shortcutsFrontend.appendChild(option);
                        loopNum++;
                    }
                    
                    shortcutsFrontend.value = 0
                    
                    if (payload.isShortcutInFolder && listOfShortcutsVersionTwo.length > 0) {
                        const defaultSelection = payload.shortcutToRun;
                        const index = listOfShortcutsVersionTwo.indexOf(defaultSelection);
                        //Convert string to id in the array
                        shortcutsFrontend.value = index;
                    }
                    
                    break;
                case "filteredShortcuts":
                    console.log("⏰ ⏰ ⏰ filteredShortcuts -> ")
                    break;
                default:
                    console.log("Unknown case of type: ", payload.sdsEvt);
                    
            }
            
            if (payload["sds-evt"] === "filteredShortcuts") {
                console.log("ZYX Payload 1222 -> ", payload)
            }
        }
        //            console.log("Payload recieved, we've sent to the PI!!!!!");
        
        //            if (payload.error) {
        //                Sentry.captureException(payload.error);
        //                // printToConsole('Error: ' + payload.error);
        //                return;
        //            }
        //
        //            // const errorText2 = document.getElementById('errorPatch');
        //            // errorText2.value = "Looking for error...";
        //            debugText(`Looking for error...`, true);
        //
        //            console.log("Payload: ", payload);
        //
        //            usersSelectedShortcut = payload.shortcutName;
        //
        //            const el = document.querySelector('.sdpi-wrapper');
        //
        //            // mappedDataFromBackend = outNewTest;
        //
        //            refreshListOfShortcutsFolders();
        //
        //            if (usersSelectedShortcut.value == "undefined") {
        //                shortcutName.value = "";
        //                shortcut_list.value = "";
        //            }
        //            else {
        //                // shortcut_list.value = shortcutName.value;
        //            }
        //
        //            // el && el.classList.remove('hidden');
        //        }
        
        console.log('THE EVENTS!, ', evt);
        
        //    console.log(greet('Alice'))
    };
    
}

function initPayload(sentAt, swift, payloadSize) {
    console.log("👋👋👋🏼sentAT: ", sentAt)
    let beDate = new Date(sentAt + "-00:00");
    let now = new Date();
    let diff = now - beDate
    console.log("SwiftDate ", beDate);
    console.log("js Date ", now);
    console.log("Diff: ", diff);
    
    select = document.getElementById("initPayloadText");
    select.innerHTML = `Payload: ${diff}ms<br>Process Shortcuts: ${swift}s<br>Payload Size ${payloadSize} kb`
}

function refreshListOfShortcutsFolders() {
    // debugText("", false);
    
    select = document.getElementById("shortcuts_folder_list");
    
    // preShortcut = select.value;
    
    //    console.log("PreSelect ", shortcutFromBackend);
    
    
    //Show/Hide if the user has shortcuts or not...
    // if (shortcutsFolder.length > 1) {
    //     console.log("___testAlert: ", shortcutsFolder.length);
    // } else {
    //     folderID = document.getElementById("isFolder");
    //     folderID.style.display = "none";
    //     console.log("We should only have 1 id, aka All: ", shortcutsFolder.length);
    // }
    
    //select.remove(select[0])
    
    //  console.log('L of folders: ', listOfCuts.length)
    
    console.log('⭕ dropDown Length ', select.length)
    console.log('⭕ Shortucts Folder: ', shortcutsFolder.length)
    select.length = 0;
    
    if (select.length != shortcutsFolder.length) {
        select.length = 0;
        
        var loopNum = 0;
        for (var val of shortcutsFolder) {
            console.log('  ⭕ Gen Option ', val)
            var ID = loopNum;
            option = genOption(val, ID); //ID = loop num...
            select.appendChild(option);
            loopNum++;
        }
    } else {
        console.log("Already have options, no need to add more!")
    }
    select.value = 0
    
}

function parseJSONSafely(str) {
    try {
        return JSON5.parse(str);
    } catch (error) {
        //        Sentry.captureException(error);
        console.log('This is the error: ', error);
        debugTextToPass = `⚠️ Error Code: 'Section-Six' \ JSON Failure! \nJSON: ${error}`, error;
        debugText(debugTextToPass, true)
        // Return a default object, or null based on use case.
        return {}
    }
}

function requestSettings(requestType, passIntoPayload) {
    if (websocket) {
        let payload = {}; //Append to payload with our passIntoPayload value
        payload.type = requestType;
        const json = {
            "action": actionInfo['action'],
            "event": "sendToPlugin",
            "context": uuid,
            "payload": payload,
        };
        websocket.send(JSON.stringify(json));
        console.log("👻 requestSettings", json);
        // dealWithBug();
        dealWithBug();
    }
}

//Helper delay
const delay = ms => new Promise(res => setTimeout(res, ms));

var resentCount = 0;

//This function waits a second & if we haven't recieved the payload, then we re-request after a second
const dealWithBug = async () => {
    await delay(500);
    
    if (resentCount < 10) {
        resentCount++;
        if (hasResent === false) {
            requestSettings('requestSettings');
            console.log("Swift WebSocket is still loading. We've re-requested the settings.");
        }
    } else {
        // const textArea = document.getElementById('mytextarea');//Shortcut nameofElement
        //         const PI_Shortcuts = document.getElementById('PI_Shortcuts');//Shortcut nameofElement
        //         // textArea.value = "⚠️ Error Code: 'Kilo-One' \ Please restart the StreamDeck Software.";
        //         console.log('10 requests have been sent. WebSocket is not responding. We will not be re-requesting.');
        //         PI_Shortcuts.style.display = "none";
        //
        //         valToPass = "⚠️ Error Code: 'Kilo-One' \ Please restart the StreamDeck Software.";
        //         debugText(valToPass, true);
        //Change the status of something to X
    }
};

///WERAWERAWEA REMOVE
//   dealWithBug();

function updateSettings() {
    if (websocket) {
        let payload = {};
        
        payload.type = "updateSettings";
        
        
        //🚨 ReWrite
        const shortcutName = document.getElementById('shortcut_list');//Shortcut Name
        payload.shortcutName = shortcutName.value;
        
        const forcedTitle = document.getElementById('forcedTitle');
        payload.isForcedTitle = isForcedTitle.toString();
        
        const sayvoice_holdtime = document.getElementById('sayvoice_holdtime');
        payload.sayHoldTime = sayvoice_holdtime.value; //Need to check if this is a valid number & set min/max
        if (sayvoice_holdtime.value == "") {
            payload.sayHoldTime = "0";
        }
        
        // console.log("Type: ", typeof sayvoice_holdtime);
        
        // const sayvoice = document.getElementById('sayvoice');
        // if (sayvoice.value === "undefined") {
        //     payload.sayvoice = "Samantha";
        // }
        // payload.sayvoice = sayvoice.value;
        
        // // console.log('sayVoice: ', typeof sayvoice.value);
        // if(sayvoice.value) {
        //     console.log('sayVoice IS TRUE: ', sayvoice.value);
        // }
        // else {
        //     console.log('sayVoice IS FALSE: ', sayvoice.value, 'global: ', globalSayVoice);
        
        // }
        // if(globalSayVoice == false) {
        //     payload.sayvoice = "Samantha";
        // }
        
        console.log("1234: before", testGlobalVoice);
        payload.sayvoice = testGlobalVoice;
        console.log("1234 after: ", testGlobalVoice);
        
        payload.isSayvoice = isSayvoice.toString();
        
        payload.refType = refType;
        console.log("refType: ", refType);
        
        //isVoiceOn?
        
        // const sayvoice = document.getElementById('sayvoice');
        // payload.sayvoice = sayvoice.value;
        
        console.log(payload);
        const json = {
            "action": actionInfo['action'],
            "event": "sendToPlugin",
            "context": uuid,
            "payload": payload,
        };
        websocket.send(JSON.stringify(json));
        console.log("updateSettings : Payload: ", JSON.stringify(json));
        logSizeInBytes('payload sent', json);
        logSizeInKilobytes('payload sent', json);
    }
}

function debugSDPI() {
    let select = document.getElementById("shortcuts_folder_list");
    
    let lastValue = select.value;
    
    setInterval(() => {
        let currentValue = select.value;
        if (currentValue !== lastValue) {
            let newVal = select.value
            console.log('🎉 sdpi debug .value: ', newVal);
            selectedNewIndex(newVal, 'shortcutFolder', newVal);
            lastValue = currentValue;
        }
    }, 100);
}

//selectedNewIndex

function findFolder(shortcut) {
    
    if (listOfCuts.includes(shortcut)) {
        console.log('Found Shortcut!')
        //Change Folder/Shortcut group!
    }
    
}


// ❄️ --------------------------------------------------------------------------------------------------------------|
//  | Split Break                                                                                                |
//  ----------------------------------------------------------------------------------------------------------------|


// function changedShortcutInput() {

//     const shortcutName = document.getElementById('shortcutName');//Shortcut Name

//     const shortcutList = document.getElementById('shortcut_list');//shortcut_list's user-facing text. We want to change this to the value of the TextField, if it's valid.


//     //Handle if the user has entered an invalid shortcut.
//     if (listOfCuts.includes(shortcutName.value)) {
//         shortcutList.value = shortcutName.value;
//         console.log("🦑 shortcut Value X: : ", typeof (shortcut_list.value));

//             //Set ref type & update the settings.
//     refType = "textFieldRefs";
//     updateSettings();
//     }
//     else {
//         //TODO: We should change the color of the box to red, and show an error message. When the user clicks on the box, We should get rid of the "error" text, allowing them to conitnue were they left off.
//         var nullError = "Not valid shortcut:  ";
//         var cutNameX = shortcutName.value;
//         shortcutName.value = nullError + cutNameX;
//     }
// }

function debugText(errorText, showDebug) {
    const textArea2 = document.getElementById('mytextarea');
    const debugTextParent = document.getElementById('message_only');
    const PI_Shortcuts = document.getElementById('PI_Shortcuts');//Shortcut nameofElement
    // const errorTextDebug = document.getElementById('errorPatch');
    // const errorTextNew = document.getElementById('errorPatch');
    
    // errorTextDebug.value = errorText;
    
    // errorTextNew.value = errorText;
    // showDebug = false
    
    if (showDebug === true) {
        // if errorText == 'Looking for error...' {
        // } else {
        Sentry.captureException(errorText);
        // }
        PI_Shortcuts.style.display = "none";
        textArea2.style.display = "block";
        textArea2.value = errorText;
    } else {
        PI_Shortcuts.style.display = "block";
        textArea2.value = "";
        debugTextParent.style.display = "none";
    }
    
    console.log("🚨debugText", errorText);
    console.log("show", showDebug);
    console.log("🚨textArea2", textArea2);
}


function refreshListOfVoices(sayvoice) {
    select = document.getElementById("sayvoice");
    
    console.log("🔈 Sayvoice: ", sayvoice);
    console.log("🔈 Sayvoice DropDn Value: ", select.value);
    
    if (select.length != listOfVoices.length) {
        select.length = 0;
        
        for (var val of listOfVoices) {
            option = genOption(val);
            select.appendChild(option);
        }
    }
    
    select.value = sayvoice;
    // if (sayvoice) {
    //     select.value = sayvoice;
    //     globalSayVoice = sayvoice;
    //     console.log("🔈 Defined SayVoice: ", sayvoice);
    // }
    // else {
    //     // globalSayVoice = 'Samantha';
    //     select.value = globalSayVoice;
    //     console.log("🔈 Undefined");
    // }
    
    console.log("🧿 UUID 1245366987: ", select);
}


function checkIfShortcutExists(shortcutToVerify) {
    for (const i of listOfCuts) {
        if (shortcutToVerify == i) {
            console.log('Shortcut founD!')
            //Change Folder/Shortcut group!
        } else {
            console.log('short not found')
            //Throw an error/Change title to error?
        }
    }
}

//shortcuts_folder_list

//The event types we can send to the Swift back-end.
const SdsEventSend = {
newFolderSelected: "newFolderSelected",
newShortcutSelected: "newShortcutSelected",
voiceHover: "voiceHover"
};


function sendNewPayload(event, data) {
    
    let payload = {};
    payload.type = event; //Enum Type
    payload.data = data
    const payloadJson = {
        "action": actionInfo['action'],
        "event": "sendToPlugin",
        "context": uuid,
        "payload": payload,
    };
    websocket.send(JSON.stringify(payloadJson));
    console.log("📧 Payload: ", payloadJson);
    console.log("New Shortcut Folder Selected", data);
    
}

function selectedNewIndex(selected_id, selected_type, selectedNew) {
    console.log("👏🏼 selectedNewIndex", selected_id);
    if (selected_type === "shortcutFolder") {
        
        pay = shortcutsFolder[selected_id]
        
        if (selectedNew) {
            sendNewPayload(SdsEventSend.newFolderSelected, selected_id)
        } else {
            sendNewPayload(SdsEventSend.newFolderSelected, pay)
        }
        
        console.log("New Shortcut Folder Selected | Sending Payload: ", shortcutsFolder[selected_id]);
        console.log("New Shortcut Folder Selected | Sending Payload: ", pay, selected_id, selected_type);
        
    }
    //🚨 ReWrite
    else if (selected_type == "shortcut") {
        //If We've selected a new Shortcut, hold onto the value until we update the settings?
        //We must bind this to the label above as well!!!
        // const shortcutName = document.getElementById('shortcutName');
        // shortcutName.value = listOfCuts[selected_id];
        //TODO: Send message about ref type 🟥
        shortcutFromBackend = listOfCuts[selected_id];
        console.log("        🟥  🚨  🟥  🚨   🟥  🚨  SIGNAL!?");
        refType = "dropdownRefs";
        // updateSettings();
        
    } else if (selected_type === "shortcutSelected") {
        console.log("New Shortcut selected from the dropdown menu! 👀")
        let data = listOfShortcutsVersionTwo[selected_id]
        sendNewPayload(SdsEventSend.newShortcutSelected, data)
    } else if (selected_id === -1) {
    } else if (selected_type == "sayvoice") {
        saySelect = document.getElementById("sayvoice");
        console.log("XIOP", saySelect.value);
        // saySelect.value = "Siri";
        // saySelect.selectedIndex =
        testGlobalVoice = saySelect.value;
        console.log("The voice is off!");
    } else {
        console.log("New X X Selected", selected_id);
        //TODO: Send message about ref type 🟥
    }
    //    updateSettings();
}

function openPage(site) {
    websocket && (websocket.readyState === 1) &&
    websocket.send(JSON.stringify({
    event: 'openUrl',
    payload: {
    url: 'https://' + site
    }
    }))
}

//   function tooggleAccessibility() {
//     var x = document.getElementById("isAccessibility");
//     if (x.style.display === "block" && isSayvoice == true) {
//       x.style.display = "none"; //on
//       isSayvoice = false;
//     } else {
//       x.style.display = "block"; //off
//       isSayvoice = true;
//     }
//   }

function toggleAccessNew() {
    var x = document.getElementById("isAccessibility");
    var buttonState = document.getElementById("save_the_settings");
    buttonState.textContent = 'newText'
    
    if (isSayvoice == false) {
        buttonState.textContent = 'Toggle Off'
        x.style.display = "block"; //off
        isSayvoice = true
    } else {
        buttonState.textContent = 'Toggle On'
        x.style.display = "none"; //off
        isSayvoice = false
    }
    
    //Change Access Bool & save settings!
    updateSettings();
    console.log("🔈 isSayvoice: Shouldb e updating voics ");
    
}

function setToggleState() {
    var x = document.getElementById("isAccessibility");
    var buttonState = document.getElementById("save_the_settings");
    
    if (isSayvoice == true) {
        buttonState.textContent = 'Toggle Off'
        x.style.display = "block"; //off
    } else {
        buttonState.textContent = 'Toggle On'
        x.style.display = "none"; //off
    }
}

function setForcedTitleState() {
    var x = document.getElementById("forced_title");
    console.log("setForcedTitleState", isForcedTitle)
    
    if (isForcedTitle == true) {
        x.textContent = 'Override Title: Toggle Off'
        console.log("state was 1", isForcedTitle)
    } else {
        x.textContent = 'Override Title: Toggle On'
        console.log("state was 2", isForcedTitle)
    }
}

function changeForcedTitle() {
    var x = document.getElementById("forced_title");
    
    console.log("Pre", isForcedTitle)
    
    if (isForcedTitle == true) {
        x.textContent = 'Override Title: Toggle On'
        isForcedTitle = false;
    } else {
        x.textContent = 'Override Title: Toggle Off'
        isForcedTitle = true;
    }
    
    console.log("Post", isForcedTitle)
    updateSettings();
}

//Toggle the custom search list view.
function toggleMenu() {
    searchMenu = document.getElementById("searchMenu")
    searchBar = document.getElementById("searchBar")
    
    if (searchMenu.style.display === "none") {
        searchMenu.style.display = "block";
        searchBar.focus();
        searchBar.value = "";
        // fillSearchBarList();
        fillCustomList();
    } else {
        searchMenu.style.display = "none";
    }
    
}

function filterSearchResults() {
    var input, filter, ul, li, option, i;
    input = document.getElementById("searchBar");
    filter = input.value.toUpperCase();
    div = document.getElementById("search_list_id");
    option = div.getElementsByTagName("option");
    for (i = 0; i < option.length; i++) {
        txtValue = option[i].textContent || option[i].innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
            option[i].style.display = "";
        } else {
            option[i].style.display = "none";
        }
    }
}

function fillSearchBarList() {
    list = document.getElementById("search_list_id") //Fetch the list
    list.innerHTML = ''; //Clear the list
    
    //Refill the list with the new options
    for (var val of listOfCuts) {
        option = genOption(val)
        option.onclick = function () {
            testPrint(this.value)
        };
        list.appendChild(option);
    }
}

//Fill the customList full of the animals array.
function fillCustomList() {
    list = document.getElementById("myDropdown")
    // list.length = 0;
    
    for (var val of listOfCuts) {
        option = genOption(val)
        option.onclick = function () {
            testPrint(this.value)
        };
        try {
            list.appendChild(option);
        } catch (e) {
            Sentry.captureException(e);
            //WARING: This is suppressing the errors, I believe. For whatever reason, this. is allowing the list to be filled...
            // list.appendChild(option);
        }
    }
}


// ❄️ --------------------------------------------------------------------------------------------------------------|
//  | Helper Functions                                                                                                |
//  ----------------------------------------------------------------------------------------------------------------|


//Helper function to generate an option element.
function genOption(val, id) {
    
    console.log(val, id)
    val = val.replace(/"/g, "'")
    
    var option = document.createElement("option");
    option.value = id;
    option.text = val.charAt(0).toUpperCase() + val.slice(1);
    
    // option.onclick = function () { testPrint(this.value) };
    option.tagName
    return option
}

// Hides the dropdown menu when the user selects an option. Also prints the value of the selected option.
function testPrint(nameofElement) {
    console.log("test: ", nameofElement);
    // div = document.getElementById("myDropdown");
    // div.style.display = "none";
    
    // btn = document.getElementById("customButton");
    // btn.innerHTML = nameofElement;
    
    // shortcutName = document.getElementById("shortcutName");
    // shortcutName.value = nameofElement;
    
    // selectedInputName = shortcutName.value;
    
    // onchange="selectedNewIndex(this.selectedIndex, 'shortcut');">
    
    // const shortcutName = document.getElementById('shortcutName');
    // shortcutName.value = nameofElement;
    
    shortcut_list = document.getElementById('shortcut_list');
    shortcut_list.value = nameofElement;
    
    console.log("__Name_OF_ELEMETN:", nameofElement)
    refType = "searchRefs"
    
    updateSettings();
    
    toggleMenu();
}

const getSizeInBytes = obj => {
    let str = null;
    if (typeof obj === 'string') {
        // If obj is a string, then use it
        str = obj;
    } else {
        // Else, make obj into a string
        str = JSON.stringify(obj);
    }
    // Get the length of the Uint8Array
    const bytes = new TextEncoder().encode(str).length;
    return bytes;
};

const logSizeInBytes = (description, obj) => {
    const bytes = getSizeInBytes(obj);
    console.log(`${description} is approximately ${bytes} B`);
    return bytes
};

const logSizeInKilobytes = (description, obj) => {
    const bytes = getSizeInBytes(obj);
    const kb = (bytes / 1000).toFixed(2);
    console.log(`${description} is approximately ${kb} kB`);
    return kb
};

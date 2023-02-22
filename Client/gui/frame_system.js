

let VZ_Frames = {}

Events.Subscribe("CreateVZFrame", function(id, width, height, header_text) {
    let div = document.createElement("div")
    div.classList.add("hidden")
    div.classList.add("Frame_Container")

    div.style.width = width
    div.style.height = height

    let frame_header = document.createElement("div")
    frame_header.innerText = header_text
    frame_header.classList.add("Frame_Header")

    div.appendChild(frame_header)

    let th = document.createElement("div")
    th.classList.add("Tabs_Header")
    div.appendChild(th)

    VZ_Frames[id] = {
        Frame: div,
        Curtab: null,
        Tabs_Header: th,
        Tabs: {},
        Items_Containers: {},
    }
    document.body.appendChild(div)
})

Events.Subscribe("ShowVZFrame", function(id, show) {
    if (VZ_Frames[id]) {
        if (show) {
            VZ_Frames[id].Frame.classList.remove("hidden")
        } else {
            VZ_Frames[id].Frame.classList.add("hidden")
        }
    }
})

Events.Subscribe("AddVZFrameTab", function(frame_id, tab_id, tab_name) {
    if (VZ_Frames[frame_id]) {
        let tab = document.createElement("button")
        tab.classList.add("FrameTab")
        tab.innerText = tab_name

        let isc = document.createElement("div")
        isc.classList.add("Items_Container")
        VZ_Frames[frame_id].Frame.appendChild(isc)

        VZ_Frames[frame_id].Items_Containers[tab_id] = isc

        if (VZ_Frames[frame_id].Curtab == null) {
            VZ_Frames[frame_id].Curtab = tab
            tab.classList.add("FTSelectedTab")
        } else {
            isc.classList.add("hidden")
        }

        VZ_Frames[frame_id].Tabs[tab_id] = tab
        VZ_Frames[frame_id].Tabs_Header.appendChild(tab)

        tab.onclick = function() {
            for (let k in VZ_Frames[frame_id].Tabs) {
                if (k != tab_id) {
                    VZ_Frames[frame_id].Tabs[k].classList.remove("FTSelectedTab")
                    VZ_Frames[frame_id].Items_Containers[k].classList.add("hidden")
                }
            }
            tab.classList.add("FTSelectedTab")
            isc.classList.remove("hidden")
        }
    }
})

function AddFrameItem(frame_id, tab_id, item_name) {
    if (VZ_Frames[frame_id]) {
        if (VZ_Frames[frame_id].Items_Containers[tab_id]) {
            let item_container = document.createElement("div")
            item_container.classList.add("Item_Container")

            let item_text = document.createElement("div")
            item_text.classList.add("Item_Text")
            item_text.innerText = item_name
            
            item_container.appendChild(item_text)

            VZ_Frames[frame_id].Items_Containers[tab_id].appendChild(item_container)

            return item_container
        }
    }
}

Events.Subscribe("AddTabCheckbox", function(frame_id, tab_id, item_name, event_name, checked) {
    if (VZ_Frames[frame_id]) {
        let item_container = AddFrameItem(frame_id, tab_id, item_name)

        let checkbox = document.createElement("input")
        checkbox.classList.add("Item_Checkbox")
        checkbox.type = "checkbox"
        checkbox.checked = checked

        checkbox.onchange = function() {
            Events.Call(event_name, checkbox.checked)
        }

        item_container.appendChild(checkbox)
    }
})

Events.Subscribe("AddTabTextInput", function(frame_id, tab_id, item_name, event_name, placeholder, value) {
    if (VZ_Frames[frame_id]) {
        let item_container = AddFrameItem(frame_id, tab_id, item_name)

        let textinput = document.createElement("input")
        textinput.classList.add("Item_TextInput")
        textinput.type = "text"
        textinput.placeholder = placeholder
        textinput.value = value

        textinput.onchange = function() {
            Events.Call(event_name, textinput.value)
        }

        item_container.appendChild(textinput)
    }
})

Events.Subscribe("AddTabSelect", function(frame_id, tab_id, item_name, event_name, options, selected_option) {
    if (VZ_Frames[frame_id]) {
        let item_container = AddFrameItem(frame_id, tab_id, item_name)

        let select = document.createElement("select")
        select.classList.add("Item_Select")

        for (let i = 0; i < options.length; i++) {
            let option_elt = document.createElement("option")
            option_elt.innerText = options[i]
            option_elt.value = options[i]
            select.appendChild(option_elt)
        }

        if (selected_option) {
            select.value = selected_option
        }

        select.onchange = function() {
            Events.Call(event_name, select.value)
        }

        item_container.appendChild(select)
    }
})

Events.Subscribe("AddTabButton", function(frame_id, tab_id, item_name, event_name, button_text) {
    if (VZ_Frames[frame_id]) {
        let item_container = AddFrameItem(frame_id, tab_id, item_name)

        let button = document.createElement("button")
        button.classList.add("Item_Button")
        button.innerText = button_text

        button.onclick = function() {
            Events.Call(event_name)
        }

        item_container.appendChild(button)
    }
})

Events.Subscribe("AddTabText", function(frame_id, tab_id, text, bottom_disabled) {
    if (VZ_Frames[frame_id]) {
        if (VZ_Frames[frame_id].Items_Containers[tab_id]) {
            let item_text = document.createElement("div")
            item_text.classList.add("Item_Text_Solo")
            if (!bottom_disabled) {
                item_text.classList.add("Item_Text_Solo_Bottom")
            }
            item_text.innerText = text

            VZ_Frames[frame_id].Items_Containers[tab_id].appendChild(item_text)
        }
    }
})

Events.Subscribe("AddTabImage", function(frame_id, tab_id, image, width, height) {
    if (VZ_Frames[frame_id]) {
        if (VZ_Frames[frame_id].Items_Containers[tab_id]) {
            let item_image = document.createElement("img")
            item_image.classList.add("Item_Image")
            item_image.src = image
            item_image.style.setProperty('width', width)
            item_image.style.setProperty('height', height)
            //item_image.width = width
            //item_image.height = height

            VZ_Frames[frame_id].Items_Containers[tab_id].appendChild(item_image)
        }
    }
})


/*testFuncs.CreateVZFrame("Settings", "50%", "55%", "Settings")
testFuncs.ShowVZFrame("Settings", true)
testFuncs.AddVZFrameTab("Settings", "HUD", "HUD")
testFuncs.AddVZFrameTab("Settings", "d", "d")
testFuncs.AddVZFrameTab("Settings", "dd", "dd")
testFuncs.AddVZFrameTab("Settings", "ddd", "ddd")
testFuncs.AddVZFrameTab("Settings", "dddd", "dddd")

testFuncs.AddTabCheckbox("Settings", "HUD", "Test Checkbox", "CheckBoxEvent", false)
testFuncs.AddTabTextInput("Settings", "HUD", "Test TextInput", "TextInputEvent", "placeholder")
testFuncs.AddTabSelect("Settings", "HUD", "Test Dropdown", "DropDownEvent", ["O1", "O2", "O3", "O4", "O5", "O6"], "O3")
testFuncs.AddTabButton("Settings", "HUD", "Test Button", "ButtonEvent", "text")
testFuncs.AddTabImage("Settings", "HUD", "images/electric_icon.png", "50%", "150px")
testFuncs.AddTabText("Settings", "HUD", "Test Solo Text")
testFuncs.AddTabButton("Settings", "HUD", "Test Button2", "ButtonEvent2", "text2")
testFuncs.AddTabText("Settings", "HUD", "", true)
testFuncs.AddTabText("Settings", "HUD", "Test Solo Text2")*/
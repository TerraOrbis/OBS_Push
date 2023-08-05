-- OBS_Push a vlc plugin
--
-- pushes the current playing track info to a file
-- OBS will read from the file updating the stream overlay
--
-- Installation: extensions folder
--     Windows: C:\Program Files (x86)\VideoLAN\VLC\lua\extensions
--     Linux: ~/.local/share/vlc/lua/extensions
--     OS X: VLC.app/Mac OS/share/lua/extensions (I think)
--
-- OBS_Push should be under the View menu
--

--output file path--
--A dialog box will pop up when activating the extension
file_path = "%UserProfile%/desktop/current_song.txt"

--[VLC extension stuff]--

function descriptor()
    return {
        title = "OBS Push - v0.2",
	version = "0.2",
	author = "dvkirn",
	url = 'http://github.com/TerraOrbis/OBS_Push',
	shortdesc = "OBS_Push",
	description = "desc",
	capabilities = {"menu", "meta-listener", "input-listener", "playing-listener"}
    }
end

function activate()
    vlc.msg.dbg("OBS_Push activated")
    create_dialog()
    meta_changed() --update file on startup
end

function deactivate()
    vlc.msg.dbg("Deactivating OBS_Push")
    write_string_to_file("No Music ")
end

function meta_changed()
    input_item = vlc.input.item()
    local meta_table = input_item.metas(input_item)
    
    write_string_to_file(meta_table.title.." | Artist: "..meta_table.artist.." | ")
end

function input_changed()
    vlc.msg.dbg("INPUT CHANGED!!!!!")
    write_string_to_file("No Music ")
    collectgarbage()
end

function playing_changed()
    local media_status = vlc.playlist.status()

    --Handle play/pause transition
    if media_status == "playing" then
        meta_changed()
    else
        write_string_to_file("No Music ")
    end
end

function menu()
    return {"Set output file"}
end

--write current song info to file
function write_string_to_file(string)
    local fd = io.open(file_path, "w+")
    fd:write(string)
    fd:close()
end

-- Function triggered when an element from the menu is selected
function trigger_menu(id)
   if(id == 1) then
      create_dialog()
   end
end

--[Enter file path dialog]--

function create_dialog()
    w = vlc.dialog("OBS_Push")
    label = w:add_label("Set output file path", 1, 1, 3, 1)
    w1 = w:add_text_input(file_path, 1, 2, 10, 1)
    w2 = w:add_button("Accept",click_Accept, 10, 3, 1, 1)
end

function click_Accept()
    file_path = w1:get_text()
    vlc.msg.dbg("File path is: "..file_path)
    w:delete()
end

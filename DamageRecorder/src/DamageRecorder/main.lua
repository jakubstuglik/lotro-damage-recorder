-- Damage Recorder LOTRO plugin
-- written by Jakub Stuglik
-- Main program file

import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";

_G.DR = {};
AppDir = "JSPlugins.DamageRecorder.";
Write = Turbine.Shell.WriteLine;
Version = Plugins["DamageRecorder"]:GetVersion();
Player = Turbine.Gameplay.LocalPlayer.GetInstance();
PN = Player:GetName();

Locale = "en";
if Turbine.Shell.IsCommand("hilfe") then
	Locale = "de";
elseif Turbine.Shell.IsCommand("aide") then
	Locale = "fr";
end
import (AppDir..Locale);

screenWidth, screenHeight = Turbine.UI.Display.GetSize();

-- Counters
DR["dmgVal"] = 0;
-- ********

Turbine.Plugin.Load = function(self, sender, args)
	Write("Damage Recorder plugin load.");
end;

DamageRecorderCommand = Turbine.ShellCommand()
function DamageRecorderCommand:Execute(command, arguments)
	if (arguments == L["cmdToggleVisibility"]) then
		toggleMainFrameVisibility();
	end;
end;
Turbine.Shell.AddCommand("dr", DamageRecorderCommand);

import (AppDir.."frame");
initMainFrame();

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

function RemoveCallback(object, event, callback)
    if (object[event] == calalback) then
        object[event] = nil;
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event]);
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i);
                    break;
                end
            end
        end
    end
end

AddCallback(Turbine.Chat, "Received", function(sender, args)
	if args.ChatType == 34 then
		--Write("DEBUG: combat chat message");
		combatChatReceived(sender, args);
	end;
end);

import (AppDir.."logic");
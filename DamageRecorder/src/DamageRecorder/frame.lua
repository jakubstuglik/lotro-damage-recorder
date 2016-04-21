-- Damage Recorder LOTRO plugin
-- written by Jakub Stuglik
-- Main frame definition

import "Turbine.UI";
import "Turbine.UI.Lotro";
import (AppDir.."color");
import (AppDir.."logic");

-- FIXME JS Set component sizes based on width of the text within with some upper border
function initMainFrame()
	DR["win"] = Turbine.UI.Lotro.Window();
	DR["win"]:SetPosition(screenWidth / 2 - 100, screenHeight / 2 - 50);
	DR["win"]:SetSize(300, 75);
	--DR["win"]:SetOpacity(0.5);
	
	DR["win"]:SetWantsKeyEvents(true);
	DR["win"]:SetText(L["winText"].." "..PN);
	DR["win"].Closing = function( sender, args )
		toggleMainFrameVisibility();
	end;
	DR["win"]:SetVisible(true);
	DR["win"]:Activate();
		
	DR["dmgValLbl"] = Turbine.UI.Label();
	DR["dmgValLbl"]:SetParent(DR["win"]);
	DR["dmgValLbl"]:SetPosition(10, 40);
	DR["dmgValLbl"]:SetWidth(DR["win"]:GetWidth() - 10);
	DR["dmgValLbl"]:SetText(L["dmgValLblText"].." "..DR["dmgVal"]);
	DR["dmgValLbl"]:SetForeColor(Color["nicegreen"]);
	DR["dmgValLbl"]:SetTextAlignment(Turbine.UI.ContentAlignment.Left);	
	
	DR["dmgResetBtn"] = Turbine.UI.Lotro.Button();
	DR["dmgResetBtn"]:SetParent(DR["win"]);
	DR["dmgResetBtn"]:SetPosition(100, 55);
	DR["dmgResetBtn"]:SetWidth(100);
	DR["dmgResetBtn"]:SetText(L["dmgResetButtonText"]);
	DR["dmgResetBtn"].Click = function( sender, args )
		updateDmgVal(0);
	end;
	
	DR["win"]:SetVisible(true);
end;

function toggleMainFrameVisibility()
	DR["win"]:SetVisible(not DR["win"]:IsVisible());
end;

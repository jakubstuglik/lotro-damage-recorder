-- Main frame definition

import "Turbine.UI";
import "Turbine.UI.Lotro";
import (AppDir.."color");

function initMainFrame()
	DR["win"] = Turbine.UI.Window();
	DR["win"]:SetPosition(screenWidth / 2 - 100, screenHeight / 2 - 50);
	DR["win"]:SetSize(250, 75);
	DR["win"]:SetBackColor(Color["black"]);
	DR["win"]:SetWantsKeyEvents(true);
	DR["win"]:SetVisible(true);
	DR["win"]:Activate();
	
	DR["titleLbl"] = Turbine.UI.Label();
	DR["titleLbl"]:SetParent(DR["win"]);
	DR["titleLbl"]:SetPosition(1, 1);
	DR["titleLbl"]:SetWidth(DR["win"]:GetWidth() - 10);
	DR["titleLbl"]:SetText(L["winText"].." "..PN);
	DR["titleLbl"]:SetForeColor(Color["rustedgold"]);
	DR["titleLbl"]:SetTextAlignment(Turbine.UI.ContentAlignment.TopCenter);
	
	
	DR["dmgValLbl"] = Turbine.UI.Label();
	DR["dmgValLbl"]:SetParent(DR["win"]);
	DR["dmgValLbl"]:SetPosition(1, 12);
	DR["dmgValLbl"]:SetWidth(DR["win"]:GetWidth() - 10);
	DR["dmgValLbl"]:SetText(L["dmgValLblText"].." "..DR["dmgVal"]);
	DR["dmgValLbl"]:SetForeColor(Color["nicegreen"]);
	DR["dmgValLbl"]:SetTextAlignment(Turbine.UI.ContentAlignment.Left);
	
	DR["win"]:SetVisible(true);
end;

function toggleMainFrameVisibility()
	DR["win"]:SetVisible(not DR["win"]:IsVisible());
end;
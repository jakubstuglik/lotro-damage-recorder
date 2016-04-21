-- Logic file

--[name] scored a critical hit with [skill/attack] on [creature] for 1,946 [Westernesse/Beleriand] damage to Morale
-- FIXME JS Internationalization

function combatChatReceived(sender, args)
	local rpMess = args.Message;
	if rpMess ~= nil then
		local numberIdxS, numberIdxE = string.find(rpMess,"%sfor%s%d+,?%d+");
		if numberIdxS ~= nil then
			numberIdxS = numberIdxS + 5;
			local dmg = string.sub(rpMess,numberIdxS,numberIdxE);
			dmg = string.gsub(dmg,",","");
			
			local dmgN = tonumber(dmg);
			updateDmgVal(DR["dmgVal"] + dmgN);			
		end
		-- FIXME Locale	21.04.2016			
	end;
end;

function updateDmgVal(newVal)
	DR["dmgVal"] = newVal;
	DR["dmgValLbl"]:SetText(L["dmgValLblText"].." "..DR["dmgVal"]);
end;

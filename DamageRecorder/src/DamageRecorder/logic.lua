-- Logic file

--[name] scored a critical hit with [skill/attack] on [creature] for 1,946 [Westernesse/Beleriand] damage to Morale

function combatChatReceived(sender, args)
	local rpMess = args.Message;
	if rpMess ~= nil then
		local numberIdxS, numberIdxE = string.find(rpMess,"%sfor%s%d+,?%d+");
		if numberIdxS ~= nil then
			numberIdxS = numberIdxS + 5;
			local dmg = string.sub(rpMess,numberIdxS,numberIdxE);
			dmg = string.gsub(dmg,",","");
			local dmgN = tonumber(dmg);
			DR["dmgVal"] = DR["dmgVal"] + dmgN;
			DR["dmgValLbl"]:SetText(L["dmgValLblText"].." "..DR["dmgVal"]);
		end
		-- FIXME Locale				
	end;
end;
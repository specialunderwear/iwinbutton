
-- IwinButton was developed 2006 (c) 3b0n3\/\/0rx for Fo SHizzle, Tha guizzle

local ILooseCuzIdodged = false;
local IwantToBePummelled = false;
local TooMuchRage = false;
local spellName = "";
local PummelId = 0;
local ActionGlobalSlot = 0;

-- Special abilities default to sitting

local Mortal_Strike = "Sit";
local Execute = "Sit";
local Hamstring = "Sit"; 
local Battle_Shout = "Sit"; 
local Demoralising_Shout = "Sit"; 
local Overpower = "Sit";
local Rend = "Sit";
local Pummel = "Sit";
local Sunder = "sit";

-- Get item by name from inventory

function getItemByName(name)

   for a = 0,4
   do 
      b = 1;
      while true  do
	 local linkstring = GetContainerItemLink(a,b);
	 if (linkstring) then
	    local _, _, itemCode = strfind(linkstring, "(%d+):");
	    if (GetItemInfo(itemCode) == name)
	    then 
	       return a,b;
	    end
	    b=b+1;
	 else break 
	 end
      end
   end
   
end

-- LookUp SpellId by name

function getSpellIdByName(name)

   local index = 1;

   while true do

      local spellName, spellRank = GetSpellName(index, BOOKTYPE_SPELL);

      if(not spellName) then 
	 return "not found";
      else
	 if (string.find(spellName,name)) then
	    return index;	 
	 end
      end
      index = index + 1;
   end

end

-- Lookup rank of spell

function lookupRank(name)

   local index = 1;

   while true do
      local spellName, spellRank = GetSpellName(index, BOOKTYPE_SPELL)
      if (not spellName) then 
	 return "not found";
      else
	 if (string.find(spellName,name)) then
	    return spellName .. '(' .. spellRank .. ')';	 
	 end
      end      
      index = index +1;
   end
end

-- Loops through active buffs looking for a string match

function isUnitBuffUp(sUnitname, sBuffname) 

   local iIterator = 1

   while (UnitBuff(sUnitname, iIterator)) do
      if (string.find(UnitBuff(sUnitname, iIterator), sBuffname)) then
	 return true
      end
      iIterator = iIterator + 1
   end

   return false

end

--Loops through active debuffs looking for a string match

function isUnitDebuffUp(sUnitname, sBuffname) 

   local iIterator = 1;

   while (UnitDebuff(sUnitname, iIterator)) do
      if (string.find(UnitDebuff(sUnitname, iIterator), sBuffname)) then
	 return true
      end
      iIterator = iIterator + 1
   end

   return false

end

-- check if player benefits from attackpower

function usesAttackpower(target)

   local class = UnitClass(target);

   if ( class == "Mage" or class == "Priest" or class == "Warlock" )
   then return false;
   else return true;
   end

end

-- Event handler

function onIwinButtonEvent()
   
   if (event == "VARIABLES_LOADED")
   then IwinButton_initialize();
   elseif (event == "UNIT_COMBAT")then 
      if(arg1 == "target" and arg2 == "DODGE") then
	 ILooseCuzIdodged = true;
      end   
   elseif (event == "PLAYER_ENTERING_WORLD")
   then       
      IwinButton_LoadAbilities();
      if(UnitClass("player") == "Warlock") then
	 SlashCmdList["IWIN"] = IwinButton_warlock_attack;
      end
      if(UnitClass("player") == "Warrior") then
	 SlashCmdList["IWIN"] = IwinButton_warrior_attack;
      end
      if(UnitClass("player") == "Priest") then
	 SlashCmdList["IWIN"] = IwinButton_priest_attack;
      end
   elseif (event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE"
	   or event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF"
	      or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF"
	      or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF"
	      or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")   
   then
      local targetname = UnitName("target");
      if (targetname) then
	 if(string.find(arg1,targetname))
	 then
	    if(string.find(arg1,"begins to cast"))
	    then 	       
	       IwantToBePummelled = targetname;
	       spellName = string.gsub(arg1,targetname .. " begins to cast","");
	       if(ShowEnemyCast)
	       then
		  IwinButtonThingy:AddMessage(targetname .. " is casting " .. spellName, 1.0, 0.0, 0.0, 1.0, 3.0);
	       end
	    end
	 end
      end
   end

end

-- function triggered on update

function onIwinUpdate()
   if isUnitBuffUp("target","Spell_Nature_Rejuvenation") then	 
      RejuvUp:Show();
   else
      RejuvUp:Hide();
   end

   if isUnitBuffUp("target","Spell_Nature_ResistNature") then	 
      RegrowthUp:Show();
   else
      RegrowthUp:Hide();
   end
end

-- initialise all the variables

function IwinButton_initialize()

   -- register slash command

   SlashCmdList["IWIN"] = IwinButton_attack;
   SLASH_IWIN1 = "/iwin";   
   
   SlashCmdList["IWINWARN"] = IwinButton_toggleWarning;
   SLASH_IWINWARN1 = "/iwinwarn";

   SlashCmdList["IWINTALK"] = function() IwinButtonThingy:AddMessage("Bladie bla bla bla", 0.0, 1.0, 0.0, 1.0, 3.0); end;
   SLASH_IWINTALK1 = "/iwintalk";

   -- Print loading message

   DEFAULT_CHAT_FRAME:AddMessage("IwinButton loaded, use /iwin to win the battle", 0.0, 1.0, 0.0);       

end

-- initialise stuff

function IwinButton_LoadAbilities()

   --Determine Ranks of special abilities

   Mortal_Strike = lookupRank("Mortal Strike");
   Execute = lookupRank("Execute");
   Hamstring = lookupRank("Hamstring");
   Battle_Shout = lookupRank("Battle Shout");
   Demoralising_Shout = lookupRank("Demoralizing Shout");
   Overpower = lookupRank("Overpower");
   Rend = lookupRank("Rend");
   Pummel = lookupRank("Pummel");
   Sunder = lookupRank("Sunder Armor");
   PummelId = getSpellIdByName("Pummel");
   -- DEFAULT_CHAT_FRAME:AddMessage(Mortal_Strike, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Execute, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Hamstring, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Battle_Shout, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Demoralising_Shout, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Overpower, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Rend, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Pummel, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(Sunder, 0.0, 1.0, 0.0);
   -- DEFAULT_CHAT_FRAME:AddMessage(PummelId, 0.0, 1.0, 0.0);

   -- find the actionbarslot that contains an action that triggers global cooldown
   -- but does NOT have a cooldown of itself
   
   local action_label;
   for actionId = 1,72 do
      action_label = GetActionTexture(actionId);
      if(action_label ~= nil) then
	 -- DEFAULT_CHAT_FRAME:AddMessage(actionId .. " " .. action_label , 0.0, 1.0, 0.0); 
	 if (string.find(action_label,"Warrior_BattleShout") or  string.find(action_label,"Warrior_WarCry"))
	 then
	    ActionGlobalSlot = actionId;
	    DEFAULT_CHAT_FRAME:AddMessage("Found " .. action_label .. " in slot " .. ActionGlobalSlot .. ", watching this slot for global cooldown", 0.0, 1.0, 0.0); 
	    break;
	 end
      end
   end

   if (not ActionGlobalSlot) then
      DEFAULT_CHAT_FRAME:AddMessage("Pls put either Battle Shout or Demoralizing Shout on your actionbar for detectiong global cooldown", 1.0, 0.0, 0.0); 
   end

end

-- Toggle spell warning display

function IwinButton_toggleWarning()

   ShowEnemyCast = not ShowEnemyCast;
   if(ShowEnemyCast) then
      IwinButtonThingy:AddMessage("Show enemy casting ON", 0.0, 1.0, 0.0, 1.0, 3.0);
   else
      DEFAULT_CHAT_FRAME:AddMessage("Enemy cast warning turned off", 1.0, 0.0, 0.0);  
   end

end

-- I win Button main function

function IwinButton_attack()
   
   if(UnitClass("player") == "Warlock")
   then
      IwinButton_warlock_attack()
   end
   if(UnitClass("player") == "Warrior")
   then
      IwinButton_warrior_attack()
   end
   if(UnitClass("player") == "Priest")
   then
      IwinButton_priest_attack()
   end
   
end

-- I win Button Warrior main function

function IwinButton_warrior_attack()   

   -- Demount if mounted

   if (isUnitBuffUp("player","Ability_Mount_WhiteDireWolf"))
   then
      local bag,slot = getItemByName("Horn of the Frostwolf Howler");
      UseContainerItem(bag,slot);
   end

   -- remove delay from Charge or Bloodrage effects

   SpellStopCasting();

   -- check if we suffer from global cooldowns before trying any pummels

   local start, duration, enable = GetActionCooldown(ActionGlobalSlot);
   
   if ((not ( start > 0 and duration > 0 and enable > 0)) or ActionGlobalSlot == 0 )
   then      

      -- Casters get pummeled

      if(IwantToBePummelled == UnitName("target"))
      then 
	 local texture,name,isActive,isCastable = GetShapeshiftFormInfo(3);
	 if ((UnitMana("player") >= 10) and isActive)
	 then
	    local startTime,duration,spellready = GetSpellCooldown(PummelId, 1);
	    if (startTime == 0)
	    then
	       CastSpellByName(Pummel);
	       if(ShowEnemyCast)
	       then
		  IwinButtonThingy:AddMessage(IwantToBePummelled .. "'s " .. spellName .. " got pummelled", 0.0, 1.0, 0.0, 1.0, 3.0);
	       end
	       IwantToBePummelled = false;
	    elseif ((duration - ( GetTime() - startTime)) > 2.5)
	    then
	       IwantToBePummelled = false;
	    else
	       if(ShowEnemyCast)
	       then
		  IwinButtonThingy:AddMessage(string.format("%.2f", ((duration - ( GetTime() - startTime)))) .. " sec cooldown left for " .. IwantToBePummelled .. "'s " .. spellName  .. " to be pummelled", 0.0, 0.0, 1.0, 1.0, 3.0);
	       end
	    end
	 elseif ((not isActive) and (not ILooseCuzIdodged))
	 then
	    CastShapeshiftForm(3);
	 end
      else
	 IwantToBePummelled = false;
      end
   end

   -- If pvp-ing keep Hamstring up and keep rogues rended

   if(UnitIsPVP("target"))
   then
      
      -- Everyone gets Hamstringed

      if(not isUnitDebuffUp("target", "Ability_ShockWave")) 
      then
	 CastSpellByName(Hamstring);
	 return true;
      end

      -- Rogues get rended

      if(not isUnitDebuffUp("target", "Ability_Gouge") 
	 and UnitClass("target") == "Rogue") 
      then
	 CastSpellByName(Rend);
	 return true;
      end

   end

   -- If someone dodges, switch to battle stance and own them

   if(ILooseCuzIdodged)
   then 
      
      local texture,name,isActive,isCastable = GetShapeshiftFormInfo(1);

      if (isActive)
      then
	 ILooseCuzIdodged = false;  
      else -- if we can switch stances without waisting rage, do it
	 
	 if (UnitMana("player") <= 25) 
	 then	 
	    CastShapeshiftForm(1);
	    ILooseCuzIdodged = false;
	 else
	    TooMuchRage = true;
	 end
      end
      
   end

   
   -- do abilities till 20% then start executing
   
   if(UnitName("target") and (UnitHealth("target") > 20))
   then 
      CastSpellByName(Overpower);
      if(not isUnitBuffUp("player", "Warrior_BattleShout"))
      then
	 CastSpellByName(Battle_Shout); 
      end
      CastSpellByName(Mortal_Strike); 
      CastSpellByName("Whirlwind");
      if(
	 (not isUnitDebuffUp("target", "Warrior_WarCry")) 
	    and 
	    usesAttackpower("target")
      )
      then
	 CastSpellByName(Demoralising_Shout);
      end
   elseif (UnitName("target"))  
   then
      CastSpellByName(Overpower);
      if (UnitMana("player") < 15)
      then
	 CastSpellByName("Bloodrage");
	 SpellStopCasting();
	 CastSpellByName(Execute);
      else
	 CastSpellByName(Execute);
      end
   end

   --If we are at this point we need to dump some rage, otherwise it's waisted in a stance switch

   if(TooMuchRage)
   then
      CastSpellByName(Sunder);
      TooMuchRage = false;     
   end

   -- dead enemy           
   
   

end

local LastImmolationTime = -1

function IwinButton_warlock_attack()

   local th = UnitHealth("target")/UnitHealthMax("target") -- target health
   local pm = UnitMana("player")   -- player mana

   if (
       (LastImmolationTime ~= -1) 
	  and ((time() - LastImmolationTime) > 12) 
	  and isUnitDebuffUp("target", "Spell_Fire_Immolation")
    )
   then
      SpellStopCasting();
      CastSpellByName("Conflagrate");
      LastImmolationTime = -1;
   elseif ((not isUnitDebuffUp("target", "Spell_Fire_Immolation")) and (th > 0.2))
   then
      CastSpellByName("Immolate");
      LastImmolationTime = time();
   elseif ((not isUnitDebuffUp("target", "Spell_Shadow_AbominationExplosion")) and (th > 0.1))  
   then
      CastSpellByName("Corruption");
   elseif ((not isUnitDebuffUp("target", "Spell_Shadow_Requiem")) and (th > 0.1))  
   then
      CastSpellByName("Siphon Life");
   elseif ((not isUnitDebuffUp("target", "Spell_Shadow_CurseOfSargeras")) and (th > 0.1))  
   then
      CastSpellByName("Curse of Agony");
   else 
      if (pm > 369) then CastSpellByName("Shadow Bolt") else CastSpellByName("Shoot") end
   end   
end

function IwinButton_priest_attack()
   
end
--   /script DEFAULT_CHAT_FRAME:AddMessage(UnitDebuff("target",1));
-- /script DEFAULT_CHAT_FRAME:AddMessage(UnitBuff("player",1));
-- /script if(UnitName("target") and (UnitHealth("target") > 20))then CastSpellByName("Overpower(Rank 2)");   CastSpellByName("Mortal Strike(Rank 4)"); CastSpellByName("Whirlwind");else CastSpellByName("Bloodrage"); CastSpellByName("Execute(Rank 5)"); end

-- /script DEFAULT_CHAT_FRAME:AddMessage(GetSpellName(1, BOOKTYPE_SPELL));
-- /script CastSpellByName("Battle Shout"); 

-- /script if(UnitName("target") and (UnitHealth("target") > 20))then CastSpellByName("Defensive Stance()");elseif (UnitMana("player")>= 15) then CastSpellByName("Execute(Rank 5)"); elseif (UnitName("target")) then CastSpellByName("Bloodrage"); end 
-- /script local startTime,duration,spellready = GetSpellCooldown(41, 1);message(GetTime().." "..startTime.." "..duration.." "..spellready);

-- /script DEFAULT_CHAT_FRAME:AddMessage(GetActionText(20),1);
-- /script DEFAULT_CHAT_FRAME:AddMessage(UnitIsDead("target"),1);
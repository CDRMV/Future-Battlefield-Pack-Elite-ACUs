local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function
	LOG('Future Battlefield Pack Elite ACUs: [gamecommon.lua '..debug.getinfo(1).currentline..'] - Gameversion is older then 3652. Hooking "GetUnitIconFileNames" to add our own unit icons')

local MyUnitIdTable = {
   -- ACU HQ's --

	UAB0305=true, -- Origin of the Way - (Aeon: ACU-HQ)
	UEB0305=true, -- Command Hangar - (UEF: ACU-HQ)
	URB0305=true, -- Master-Hub - (Cybran: ACU-HQ)
	XSB0305=true, -- Am-Sayasta - (Seraphim: ACU-HQ)
	XNB0305=true, -- Command Yard300 - (Nomads: ACU-HQ)
   
   -- Combat ACU's --
   
	UEL0002=true, -- UEF Combat ACU
	URL0002=true, -- Cybran Combat ACU
	UAL0002=true, -- Aeon Combat ACU
	XSL0002=true, -- Seraphim Combat ACU
	XNL0002=true, -- Nomads Combat ACU
	
	-- Nomads regular ACU --
	
	XNL0001b=true, -- Nomads ACU
}

	local IconPath = "/mods/Future Battlefield Pack Elite ACUs FAF Edition"
	-- Adds icons to the unitselectionwindow
	local oldGetUnitIconFileNames = GetUnitIconFileNames
	function GetUnitIconFileNames(blueprint)
		if MyUnitIdTable[blueprint.Display.IconName] then
			local iconName = IconPath .. "/icons/units/" .. blueprint.Display.IconName .. "_icon.dds"
			local upIconName = IconPath .. "/icons/units/" .. blueprint.Display.IconName .. "_icon.dds"
			local downIconName = IconPath .. "/icons/units/" .. blueprint.Display.IconName .. "_icon.dds"
			local overIconName = IconPath .. "/icons/units/" .. blueprint.Display.IconName .. "_icon.dds"
			return iconName, upIconName, downIconName, overIconName
		else
			return oldGetUnitIconFileNames(blueprint)
		end
	end

else
	LOG('Future Battlefield Pack Elite ACUs: [gamecommon.lua '..debug.getinfo(1).currentline..'] - Gameversion is 3652 or newer. No need to insert the unit icons by our own function.')
end -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function
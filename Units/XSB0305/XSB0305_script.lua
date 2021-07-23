#****************************************************************************
#**
#**  File     :  /cdimage/units/UAB0101/UAB0101_script.lua
#**  Author(s):  David Tomandl, Gordon Duclos
#**
#**  Summary  :  Aeon Land Factory Tier 1 Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local SQuantumGateUnit = import('/lua/seraphimunits.lua').SQuantumGateUnit
local SSeraphimSubCommanderGateway01 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway01
local SSeraphimSubCommanderGateway02 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway02
local SSeraphimSubCommanderGateway03 = import('/lua/EffectTemplates.lua').SeraphimSubCommanderGateway03

XSB0305 = Class(SQuantumGateUnit) {

	OnStopBeingBuilt = function(self,builder,layer)
        ###Place emitters at the center of the gateway.
        for k, v in SSeraphimSubCommanderGateway02 do
            CreateAttachedEmitter(self, 'Effect', self:GetArmy(), v)
        end
        SQuantumGateUnit.OnStopBeingBuilt(self, builder, layer)
    end,

}

TypeClass = XSB0305
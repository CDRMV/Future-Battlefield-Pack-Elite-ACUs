-- T3 radar

local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit

XNB0305 = Class(NLandFactoryUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        NLandFactoryUnit.OnStopBeingBuilt(self,builder,layer)
        self.Rotator1 = CreateRotator(self, 'rotator_main', 'y', nil, 60, 0, 0)
		self.Trash:Add(self.Rotator1)
    end,

}

TypeClass = XNB0305
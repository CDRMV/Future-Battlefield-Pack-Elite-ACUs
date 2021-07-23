#****************************************************************************
#**
#**  File     :  /cdimage/units/UAL0001/UAL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  Aeon Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local AWeapons = import('/lua/aeonweapons.lua')
local ADFDisruptorCannonWeapon = AWeapons.ADFDisruptorCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local ADFOverchargeWeapon = AWeapons.ADFOverchargeWeapon
local ADFChronoDampener = AWeapons.ADFChronoDampener
local ADFLaserLightWeapon = AWeapons.ADFLaserLightWeapon
local ADFCannonOblivionWeapon = AWeapons.ADFCannonOblivionWeapon
local ADFCannonQuantumWeapon = AWeapons.ADFCannonQuantumWeapon
local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon
local Buff = import('/lua/sim/Buff.lua')

local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then

local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit
local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon

UAL0002 = Class(AHoverLandUnit) {

    DeathThreadDestructionWaitTime = 2,

    Weapons = {
	    ObliGun = Class(ADFCannonOblivionWeapon) {},
		R_ObliGun = Class(ADFCannonOblivionWeapon) {},
		L_ObliGun = Class(ADFCannonOblivionWeapon) {},
		Missile = Class(AAAZealotMissileWeapon) {},
		R_Missile = Class(AAAZealotMissileWeapon) {},
		L_Missile = Class(AAAZealotMissileWeapon) {},
		Laser = Class(ADFLaserLightWeapon) {},
		R_Laser = Class(ADFLaserLightWeapon) {},
		L_Laser = Class(ADFLaserLightWeapon) {},
		QRailGun = Class(ADFCannonQuantumWeapon) {},
		R_QRailGun = Class(ADFCannonQuantumWeapon) {},
		L_QRailGun = Class(ADFCannonQuantumWeapon) {},
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
        RightDisruptor = Class(ADFDisruptorCannonWeapon) {},
        ChronoDampener = Class(ADFChronoDampener) {},
        OverCharge = Class(ADFOverchargeWeapon) {

            OnCreate = function(self)
                ADFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                ADFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                ADFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
            end,
            
            PauseOvercharge = function(self)
                if not self.unit:IsOverchargePaused() then
                    self.unit:SetOverchargePaused(true)
                    WaitSeconds(1/self:GetBlueprint().RateOfFire)
                    self.unit:SetOverchargePaused(false)
                end
            end,
            
            OnFire = function(self)
                if not self.unit:IsOverchargePaused() then
                    ADFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(ADFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(ADFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },              
        },
    },


    OnCreate = function(self)
        AHoverLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetWeaponEnabledByLabel('ChronoDampener', false)
        self:SetupBuildBones()
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade1', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Back_Upgrade3', true)
		self:HideBone('Back_Upgrade4', true)
        self:HideBone('Right_Upgrade', true) 
        self:HideBone('Right_Upgrade2', true) 
        self:HideBone('Right_Upgrade3', true)   		
        self:HideBone('Left_Upgrade', true) 
        self:HideBone('Left_Upgrade2', true) 
        self:HideBone('Left_Upgrade3', true)   		
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        AHoverLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightDisruptor', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        AHoverLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        AHoverLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        AHoverLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        AHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
        self.Trash:Add(self.Rotator1)
		self.Rotator2 = CreateRotator(self, 'Engine_Spinner', 'y', nil, -10, -5, -10)
        self.Trash:Add(self.Rotator2)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
		self:SetWeaponEnabledByLabel('ObliGun', false)
		self:SetWeaponEnabledByLabel('Laser', false)
		self:SetWeaponEnabledByLabel('R_Laser', false)
		self:SetWeaponEnabledByLabel('L_Laser', false)
		self:SetWeaponEnabledByLabel('Missile', false)
		self:SetWeaponEnabledByLabel('R_Missile', false)
		self:SetWeaponEnabledByLabel('L_Missile', false)
		self:SetWeaponEnabledByLabel('QRailGun', false)
		self:SetWeaponEnabledByLabel('R_ObliGun', false)
		self:SetWeaponEnabledByLabel('L_ObliGun', false)
		self:SetWeaponEnabledByLabel('R_QRailGun', false)
		self:SetWeaponEnabledByLabel('L_QRailGun', false)
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        AHoverLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AHoverLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        AHoverLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    PlayCommanderWarpInEffect = function(self)
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:SetMesh('/units/ual0002/UAL0002_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade1', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Back_Upgrade3', true)
		self:HideBone('Back_Upgrade4', true)
        self:HideBone('Right_Upgrade', true)        
        self:HideBone('Left_Upgrade', true)          
        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
    end,

    CreateEnhancement = function(self, enh)
        AHoverLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        #Resource Allocation
        if enh == 'ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        #Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldHeavy' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:ForkThread(self.CreateHeavyShield, bp)
        elseif enh == 'ShieldHeavyRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        #Teleporter
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        #Chrono Dampener
        elseif enh == 'ChronoDampener' then
            self:SetWeaponEnabledByLabel('ChronoDampener', true)
        elseif enh == 'ChronoDampenerRemove' then
            self:SetWeaponEnabledByLabel('ChronoDampener', false)
        #Crysalis Beam
        elseif enh == 'CrysalisBeam' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'CrysalisBeamRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
        #Heat Sink Augmentation
        elseif enh == 'Right_HeatSink' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
        elseif enh == 'Right_HeatSinkRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
		elseif enh == 'Left_HeatSink' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
        elseif enh == 'Left_HeatSinkRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
        elseif enh == 'EnhancedSensorsRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
		elseif enh == 'Oblivion' then
            self:SetWeaponEnabledByLabel('ObliGun', true)
        elseif enh == 'OblivionRemove' then
            self:SetWeaponEnabledByLabel('ObliGun', false)
		elseif enh == 'Left_Oblivion' then
            self:SetWeaponEnabledByLabel('L_ObliGun', true)
        elseif enh == 'Left_OblivionRemove' then
            self:SetWeaponEnabledByLabel('L_ObliGun', false)
		elseif enh == 'Right_Oblivion' then
            self:SetWeaponEnabledByLabel('R_ObliGun', true)
        elseif enh == 'Right_OblivionRemove' then
            self:SetWeaponEnabledByLabel('R_ObliGun', false)
		elseif enh == 'Railgun' then
            self:SetWeaponEnabledByLabel('QRailGun', true)
        elseif enh == 'RailgunRemove' then
            self:SetWeaponEnabledByLabel('QRailGun', false)
		elseif enh == 'Left_Railgun' then
            self:SetWeaponEnabledByLabel('L_QRailGun', true)
        elseif enh == 'Left_RailgunRemove' then
            self:SetWeaponEnabledByLabel('L_QRailGun', false)
		elseif enh == 'Right_Railgun' then
            self:SetWeaponEnabledByLabel('R_QRailGun', true)
        elseif enh == 'Right_RailgunRemove' then
            self:SetWeaponEnabledByLabel('R_QRailGun', false)
		elseif enh == 'Laser_System' then
            self:SetWeaponEnabledByLabel('Laser', true)
        elseif enh == 'Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('Laser', false)
		elseif enh == 'Right_Laser_System' then
            self:SetWeaponEnabledByLabel('R_Laser', true)
        elseif enh == 'Right_Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('R_Laser', false)
		elseif enh == 'Left_Laser_System' then
            self:SetWeaponEnabledByLabel('L_Laser', true)
        elseif enh == 'Left_Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('L_Laser', false)
		elseif enh == 'Laser_System2' then
            self:SetWeaponEnabledByLabel('Laser', true)
        elseif enh == 'Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('Laser', false)
		elseif enh == 'Right_Laser_System2' then
            self:SetWeaponEnabledByLabel('R_Laser', true)
        elseif enh == 'Right_Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('R_Laser', false)
		elseif enh == 'Left_Laser_System2' then
            self:SetWeaponEnabledByLabel('L_Laser', true)
        elseif enh == 'Left_Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('L_Laser', false)
		elseif enh == 'Missilepod' then
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissilepodRemove' then
            self:SetWeaponEnabledByLabel('Missile', false)
		elseif enh == 'Left_Missilepod' then
            self:SetWeaponEnabledByLabel('L_Missile', true)
        elseif enh == 'Left_MissilepodRemove' then
            self:SetWeaponEnabledByLabel('L_Missile', false)
		elseif enh == 'Right_Missilepod' then
            self:SetWeaponEnabledByLabel('R_Missile', true)
        elseif enh == 'Right_MissilepodRemove' then
            self:SetWeaponEnabledByLabel('R_Missile', false)
        end
    end,

    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
        self:SetMaintenanceConsumptionActive()
    end,
    
    OnPaused = function(self)
        AHoverLandUnit.OnPaused(self)
        if self.BuildingUnit then
            AHoverLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            AHoverLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        AHoverLandUnit.OnUnpaused(self)
    end,     

}

TypeClass = UAL0002

else

local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon

UAL0002 = Class(ACUUnit) {

    DeathThreadDestructionWaitTime = 2,

    Weapons = {
	    ObliGun = Class(ADFCannonOblivionWeapon) {},
		R_ObliGun = Class(ADFCannonOblivionWeapon) {},
		L_ObliGun = Class(ADFCannonOblivionWeapon) {},
		Missile = Class(AAAZealotMissileWeapon) {},
		R_Missile = Class(AAAZealotMissileWeapon) {},
		L_Missile = Class(AAAZealotMissileWeapon) {},
		Laser = Class(ADFLaserLightWeapon) {},
		R_Laser = Class(ADFLaserLightWeapon) {},
		L_Laser = Class(ADFLaserLightWeapon) {},
		QRailGun = Class(ADFCannonQuantumWeapon) {},
		R_QRailGun = Class(ADFCannonQuantumWeapon) {},
		L_QRailGun = Class(ADFCannonQuantumWeapon) {},
        DeathWeapon = Class(DeathNukeWeapon) {},
        RightDisruptor = Class(ADFDisruptorCannonWeapon) {},
        ChronoDampener = Class(ADFChronoDampener) {},
        OverCharge = Class(ADFOverchargeWeapon) {

            OnCreate = function(self)
                ADFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                ADFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                ADFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
            end,
            
            PauseOvercharge = function(self)
                if not self.unit:IsOverchargePaused() then
                    self.unit:SetOverchargePaused(true)
                    WaitSeconds(1/self:GetBlueprint().RateOfFire)
                    self.unit:SetOverchargePaused(false)
                end
            end,
            
            OnFire = function(self)
                if not self.unit:IsOverchargePaused() then
                    ADFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(ADFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(ADFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },              
        },
    },


    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade1', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Back_Upgrade3', true)
		self:HideBone('Back_Upgrade4', true)
        self:HideBone('Right_Upgrade', true) 
        self:HideBone('Right_Upgrade2', true) 
        self:HideBone('Right_Upgrade3', true)   		
        self:HideBone('Left_Upgrade', true) 
        self:HideBone('Left_Upgrade2', true) 
        self:HideBone('Left_Upgrade3', true)   		
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        ACUUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightDisruptor', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        ACUUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        ACUUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        ACUUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ACUUnit.OnStopBeingBuilt(self,builder,layer)
		self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
        self.Trash:Add(self.Rotator1)
		self.Rotator2 = CreateRotator(self, 'Engine_Spinner', 'y', nil, -10, -5, -10)
        self.Trash:Add(self.Rotator2)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
		self:SetWeaponEnabledByLabel('ObliGun', false)
		self:SetWeaponEnabledByLabel('Laser', false)
		self:SetWeaponEnabledByLabel('R_Laser', false)
		self:SetWeaponEnabledByLabel('L_Laser', false)
		self:SetWeaponEnabledByLabel('Missile', false)
		self:SetWeaponEnabledByLabel('R_Missile', false)
		self:SetWeaponEnabledByLabel('L_Missile', false)
		self:SetWeaponEnabledByLabel('QRailGun', false)
		self:SetWeaponEnabledByLabel('R_ObliGun', false)
		self:SetWeaponEnabledByLabel('L_ObliGun', false)
		self:SetWeaponEnabledByLabel('R_QRailGun', false)
		self:SetWeaponEnabledByLabel('L_QRailGun', false)
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        ACUUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        ACUUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        ACUUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisruptor', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    PlayCommanderWarpInEffect = function(self)
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:SetMesh('/units/ual0002/UAL0002_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade1', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Back_Upgrade3', true)
		self:HideBone('Back_Upgrade4', true)
        self:HideBone('Right_Upgrade', true)        
        self:HideBone('Left_Upgrade', true)          
        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        #Resource Allocation
        if enh == 'ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationAdvanced' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        #Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self:CreateShield(bp)
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldHeavy' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:ForkThread(self.CreateHeavyShield, bp)
        elseif enh == 'ShieldHeavyRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        #Teleporter
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        #Chrono Dampener
        elseif enh == 'ChronoDampener' then
            self:SetWeaponEnabledByLabel('ChronoDampener', true)
        elseif enh == 'ChronoDampenerRemove' then
            self:SetWeaponEnabledByLabel('ChronoDampener', false)
        #Crysalis Beam
        elseif enh == 'CrysalisBeam' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'CrysalisBeamRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)
        #Heat Sink Augmentation
        elseif enh == 'Right_HeatSink' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
        elseif enh == 'Right_HeatSinkRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
		elseif enh == 'Left_HeatSink' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
        elseif enh == 'Left_HeatSinkRemove' then
            local wep = self:GetWeaponByLabel('RightDisruptor')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
        #Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
        elseif enh == 'EnhancedSensorsRemove' then
            local bpIntel = self:GetBlueprint().Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 26)
		elseif enh == 'Oblivion' then
            self:SetWeaponEnabledByLabel('ObliGun', true)
        elseif enh == 'OblivionRemove' then
            self:SetWeaponEnabledByLabel('ObliGun', false)
		elseif enh == 'Left_Oblivion' then
            self:SetWeaponEnabledByLabel('L_ObliGun', true)
        elseif enh == 'Left_OblivionRemove' then
            self:SetWeaponEnabledByLabel('L_ObliGun', false)
		elseif enh == 'Right_Oblivion' then
            self:SetWeaponEnabledByLabel('R_ObliGun', true)
        elseif enh == 'Right_OblivionRemove' then
            self:SetWeaponEnabledByLabel('R_ObliGun', false)
		elseif enh == 'Railgun' then
            self:SetWeaponEnabledByLabel('QRailGun', true)
        elseif enh == 'RailgunRemove' then
            self:SetWeaponEnabledByLabel('QRailGun', false)
		elseif enh == 'Left_Railgun' then
            self:SetWeaponEnabledByLabel('L_QRailGun', true)
        elseif enh == 'Left_RailgunRemove' then
            self:SetWeaponEnabledByLabel('L_QRailGun', false)
		elseif enh == 'Right_Railgun' then
            self:SetWeaponEnabledByLabel('R_QRailGun', true)
        elseif enh == 'Right_RailgunRemove' then
            self:SetWeaponEnabledByLabel('R_QRailGun', false)
		elseif enh == 'Laser_System' then
            self:SetWeaponEnabledByLabel('Laser', true)
        elseif enh == 'Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('Laser', false)
		elseif enh == 'Right_Laser_System' then
            self:SetWeaponEnabledByLabel('R_Laser', true)
        elseif enh == 'Right_Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('R_Laser', false)
		elseif enh == 'Left_Laser_System' then
            self:SetWeaponEnabledByLabel('L_Laser', true)
        elseif enh == 'Left_Laser_SystemRemove' then
            self:SetWeaponEnabledByLabel('L_Laser', false)
		elseif enh == 'Laser_System2' then
            self:SetWeaponEnabledByLabel('Laser', true)
        elseif enh == 'Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('Laser', false)
		elseif enh == 'Right_Laser_System2' then
            self:SetWeaponEnabledByLabel('R_Laser', true)
        elseif enh == 'Right_Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('R_Laser', false)
		elseif enh == 'Left_Laser_System2' then
            self:SetWeaponEnabledByLabel('L_Laser', true)
        elseif enh == 'Left_Laser_System2Remove' then
            self:SetWeaponEnabledByLabel('L_Laser', false)
		elseif enh == 'Missilepod' then
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissilepodRemove' then
            self:SetWeaponEnabledByLabel('Missile', false)
		elseif enh == 'Left_Missilepod' then
            self:SetWeaponEnabledByLabel('L_Missile', true)
        elseif enh == 'Left_MissilepodRemove' then
            self:SetWeaponEnabledByLabel('L_Missile', false)
		elseif enh == 'Right_Missilepod' then
            self:SetWeaponEnabledByLabel('R_Missile', true)
        elseif enh == 'Right_MissilepodRemove' then
            self:SetWeaponEnabledByLabel('R_Missile', false)
        end
    end,

    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
        self:SetMaintenanceConsumptionActive()
    end,
    
    OnPaused = function(self)
        ACUUnit.OnPaused(self)
        if self.BuildingUnit then
            ACUUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            ACUUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        ACUUnit.OnUnpaused(self)
    end,     

}

TypeClass = UAL0002

end

#****************************************************************************
#**
#**  File     :  /cdimage/units/URL0001/URL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix, Gordon Duclos, Andres Mendez
#**
#**  Summary  :  Cybran Commander Unit Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

#local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CCannonMolecularWeapon = CWeapons.CCannonMolecularWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local CDFHeavyMicrowaveLaserGeneratorCom = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local CDFOverchargeWeapon = CWeapons.CDFOverchargeWeapon
local CDFParticleCannonWeapon = CWeapons.CDFParticleCannonWeapon
local CDFLaserHeavyWeapon = CWeapons.CDFLaserHeavyWeapon
local CANTorpedoLauncherWeapon = CWeapons.CANTorpedoLauncherWeapon
local Entity = import('/lua/sim/Entity.lua').Entity
local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CIFMissileLoaWeapon = CWeapons.CIFMissileLoaWeapon
local CDFElectronBolterWeapon = CWeapons.CDFElectronBolterWeapon
local CIFArtilleryWeapon = CWeapons.CIFArtilleryWeapon

local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon

URL0002 = Class(CWalkingLandUnit) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
		R_LaserCannons = Class(CDFLaserHeavyWeapon) {},
		L_LaserCannons = Class(CDFLaserHeavyWeapon) {},
	    R_Laserbeam = Class(CDFParticleCannonWeapon) {},
		L_Laserbeam = Class(CDFParticleCannonWeapon) {},
		Nanite_Missile = Class(CAAMissileNaniteWeapon) {},
		R_ElectBolter = Class(CDFElectronBolterWeapon) {},
		L_ElectBolter = Class(CDFElectronBolterWeapon) {},
		R_MArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		L_MArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		HArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		Missile = Class(CIFMissileLoaWeapon) {},
	    LaserArms = Class(CDFLaserHeavyWeapon) {},
        RightRipper = Class(CCannonMolecularWeapon) {},
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
        MLG = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
            DisabledFiringBones = {'Turret_Muzzle_03'},
            
            SetOnTransport = function(self, transportstate)
                CDFHeavyMicrowaveLaserGeneratorCom.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,          
        },

        OverCharge = Class(CDFOverchargeWeapon) {
            OnCreate = function(self)
                CDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                CDFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightRipper', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                CDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightRipper', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    CDFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(CDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(CDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },    
        },
    },

    OnCreate = function(self)
        CWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
		self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade4', true)
		self:HideBone('Back_Upgrade5', true)
        self:HideBone('Back_Upgrade6', true)
		self:HideBone('Back_Upgrade7', true)
		self:HideBone('L_L_Barrel2', true)
		self:HideBone('R_L_Barrel2', true)
		self:HideBone('Back_Upgrade8', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
		self:HideBone('Right_Upgrade3', true)
		self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
		self:HideBone('Left_Upgrade3', true)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,


    OnPrepareArmToBuild = function(self)
        CWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightRipper', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        CWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        CWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        CWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('MLG', false)
		self:SetWeaponEnabledByLabel('R_Laserbeam', false)
		self:SetWeaponEnabledByLabel('L_Laserbeam', false)
		self:SetWeaponEnabledByLabel('R_LaserCannons', false)
		self:SetWeaponEnabledByLabel('L_LaserCannons', false)
		self:SetWeaponEnabledByLabel('R_ElectBolter', false)
		self:SetWeaponEnabledByLabel('L_ElectBolter', false)
		self:SetWeaponEnabledByLabel('Nanite_Missile', false)
		self:SetWeaponEnabledByLabel('Missile', false)
		self:SetWeaponEnabledByLabel('R_MArtillery', false)
		self:SetWeaponEnabledByLabel('L_MArtillery', false)
		self:SetWeaponEnabledByLabel('HArtillery', false)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('Sonar')
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        CWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)    
        CWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        CWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
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
        self:SetMesh('/units/url0001/URL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
		self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade4', true)
		self:HideBone('Back_Upgrade5', true)
        self:HideBone('Back_Upgrade6', true)
		self:HideBone('Back_Upgrade7', true)
		self:HideBone('L_L_Barrel2', true)
		self:HideBone('R_L_Barrel2', true)
		self:HideBone('Back_Upgrade8', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
		self:HideBone('Right_Upgrade3', true)
		self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
		self:HideBone('Left_Upgrade3', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)

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

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    


    OnScriptBitSet = function(self, bit)
        if bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,
	
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 5, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    CreateEnhancement = function(self, enh)
        CWalkingLandUnit.CreateEnhancement(self, enh)
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            RemoveUnitEnhancement(self, 'Teleporter')
            RemoveUnitEnhancement(self, 'TeleporterRemove')
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')           
            self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false     
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
            self.CloakEnh = true
            self:EnableUnitIntel('Enhancement', 'Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')               		
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Enhancement', 'Cloak')
            self.CloakEnh = false
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end           
        elseif enh =='CoolingUpgrade' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'CoolingUpgradeRemove' then
            local wep = self:GetWeaponByLabel('RightRipper')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)            
        elseif enh == 'AdvancedLaserSystem' then
			self:SetWeaponEnabledByLabel('R_Laserbeam', true)
			self:SetWeaponEnabledByLabel('L_Laserbeam', true)
        elseif enh == 'AdvancedLaserSystemRemove' then
			self:SetWeaponEnabledByLabel('R_Laserbeam', false)
			self:SetWeaponEnabledByLabel('L_Laserbeam', false)
		elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG', true)
        elseif enh == 'MicrowaveLaserGeneratorRemove' then
            self:SetWeaponEnabledByLabel('MLG', false)
		elseif enh == 'LeftLaserGun' then
            self:SetWeaponEnabledByLabel('L_LaserCannons', true)
        elseif enh == 'LeftLaserGunRemove' then
            self:SetWeaponEnabledByLabel('L_LaserCannons', false)
		elseif enh == 'RightLaserGun' then
            self:SetWeaponEnabledByLabel('R_LaserCannons', true)
        elseif enh == 'RightLaserGunRemove' then
            self:SetWeaponEnabledByLabel('R_LaserCannons', false)
		elseif enh == 'TML' then
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'TMLRemove' then
            self:SetWeaponEnabledByLabel('Missile', false)  
		elseif enh == 'NaniteMissileRack' then
            self:SetWeaponEnabledByLabel('Nanite_Missile', true)
        elseif enh == 'NaniteMissileRackRemove' then
            self:SetWeaponEnabledByLabel('Nanite_Missile', false)
		elseif enh == 'RightEB' then
            self:SetWeaponEnabledByLabel('R_ElectBolter', true)
        elseif enh == 'RightEBRemove' then
            self:SetWeaponEnabledByLabel('R_ElectBolter', false)
		elseif enh == 'LeftEB' then
            self:SetWeaponEnabledByLabel('L_ElectBolter', true)
        elseif enh == 'LeftEBRemove' then
            self:SetWeaponEnabledByLabel('L_ElectBolter', false)
		elseif enh == 'Artillery' then
            self:SetWeaponEnabledByLabel('R_MArtillery', true)
			self:SetWeaponEnabledByLabel('L_MArtillery', true)
        elseif enh == 'ArtilleryRemove' then
            self:SetWeaponEnabledByLabel('R_MArtillery', false)
			self:SetWeaponEnabledByLabel('L_MArtillery', false)
					elseif enh == 'HArtillery' then
            self:SetWeaponEnabledByLabel('HArtillery', true)
        elseif enh == 'HArtilleryRemove' then
            self:SetWeaponEnabledByLabel('HArtillery', false)
        end            
    end,
    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Torso',
				    'R_Barrel',
				    'L_Barrel',
					'R_L_Barrel',
				    'L_L_Barrel',
				    'Center_Turret',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Torso',
				    'R_Barrel',
				    'L_Barrel',
					'R_L_Barrel',
				    'L_L_Barrel',
				    'Center_Turret',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
        CWalkingLandUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        end
    end,

    OnIntelDisabled = function(self)
        CWalkingLandUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self, 'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end
    end,
        
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end 
        #if we could find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
            #Apply Buff
			self:AddBuff(bp)
        end
        #otherwise, we should finish killing the unit
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    OnPaused = function(self)
        CWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            CWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CWalkingLandUnit.OnUnpaused(self)
    end,     
}   


else

local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local CCommandUnit = import('/lua/cybranunits.lua').CCommandUnit
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon

URL0002 = Class(ACUUnit, CCommandUnit) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
	    DeathWeapon = Class(DeathNukeWeapon) {},
		R_LaserCannons = Class(CDFLaserHeavyWeapon) {},
		L_LaserCannons = Class(CDFLaserHeavyWeapon) {},
	    R_Laserbeam = Class(CDFParticleCannonWeapon) {},
		L_Laserbeam = Class(CDFParticleCannonWeapon) {},
		Nanite_Missile = Class(CAAMissileNaniteWeapon) {},
		R_ElectBolter = Class(CDFElectronBolterWeapon) {},
		L_ElectBolter = Class(CDFElectronBolterWeapon) {},
		R_MArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		L_MArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		HArtillery = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        },
		Missile = Class(CIFMissileLoaWeapon) {},
	    LaserArms = Class(CDFLaserHeavyWeapon) {},
        RightRipper = Class(CCannonMolecularWeapon) {},
        Torpedo = Class(CANTorpedoLauncherWeapon) {},
        MLG = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
            DisabledFiringBones = {'Turret_Muzzle_03'},
            
            SetOnTransport = function(self, transportstate)
                CDFHeavyMicrowaveLaserGeneratorCom.SetOnTransport(self, transportstate)
                self:ForkThread(self.OnTransportWatch)
            end,
            
            OnTransportWatch = function(self)
                while self:GetOnTransport() do
                    self:PlayFxBeamEnd()
                    self:SetWeaponEnabled(false)
                    WaitSeconds(0.3)
                end
            end,          
        },

        OverCharge = Class(CDFOverchargeWeapon) {
            OnCreate = function(self)
                CDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                CDFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightRipper', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                CDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightRipper', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    CDFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(CDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(CDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        CDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },    
        },
    },

    # ********
    # Creation
    # ********
    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
		self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade4', true)
		self:HideBone('Back_Upgrade5', true)
        self:HideBone('Back_Upgrade6', true)
		self:HideBone('Back_Upgrade7', true)
		self:HideBone('L_L_Barrel2', true)
		self:HideBone('R_L_Barrel2', true)
		self:HideBone('Back_Upgrade8', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
		self:HideBone('Right_Upgrade3', true)
		self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
		self:HideBone('Left_Upgrade3', true)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,


    OnPrepareArmToBuild = function(self)
        ACUUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightRipper', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightRipper'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        ACUUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        ACUUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        ACUUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ACUUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('MLG', false)
		self:SetWeaponEnabledByLabel('R_Laserbeam', false)
		self:SetWeaponEnabledByLabel('L_Laserbeam', false)
		self:SetWeaponEnabledByLabel('R_LaserCannons', false)
		self:SetWeaponEnabledByLabel('L_LaserCannons', false)
		self:SetWeaponEnabledByLabel('R_ElectBolter', false)
		self:SetWeaponEnabledByLabel('L_ElectBolter', false)
		self:SetWeaponEnabledByLabel('Nanite_Missile', false)
		self:SetWeaponEnabledByLabel('Missile', false)
		self:SetWeaponEnabledByLabel('R_MArtillery', false)
		self:SetWeaponEnabledByLabel('L_MArtillery', false)
		self:SetWeaponEnabledByLabel('HArtillery', false)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self:DisableUnitIntel('Sonar')
        self:ForkThread(self.GiveInitialResources)
    end,

    OnFailedToBuild = function(self)
        ACUUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
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
        self:SetWeaponEnabledByLabel('RightRipper', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('RightRipper'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
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
        self:SetMesh('/units/url0001/URL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
		self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade4', true)
		self:HideBone('Back_Upgrade5', true)
        self:HideBone('Back_Upgrade6', true)
		self:HideBone('Back_Upgrade7', true)
		self:HideBone('L_L_Barrel2', true)
		self:HideBone('R_L_Barrel2', true)
		self:HideBone('Back_Upgrade8', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
		self:HideBone('Right_Upgrade3', true)
		self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
		self:HideBone('Left_Upgrade3', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)

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

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    


    OnScriptBitSet = function(self, bit)
        if bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,

    

    # *************
    # Build/Upgrade
    # *************
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 5, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            RemoveUnitEnhancement(self, 'Teleporter')
            RemoveUnitEnhancement(self, 'TeleporterRemove')
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')           
            self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false     
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
            self.CloakEnh = true
            self:EnableUnitIntel('Enhancement', 'Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')               		
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Enhancement', 'Cloak')
            self.CloakEnh = false
            if Buff.HasBuff(self, 'CybranACUCloakBonus') then
                Buff.RemoveBuff(self, 'CybranACUCloakBonus')
            end           
        elseif enh =='CoolingUpgrade' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local wep = self:GetWeaponByLabel('RightRipper')
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)
        elseif enh == 'CoolingUpgradeRemove' then
            local wep = self:GetWeaponByLabel('RightRipper')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local microwave = self:GetWeaponByLabel('MLG')
            microwave:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)            
        elseif enh == 'AdvancedLaserSystem' then
			self:SetWeaponEnabledByLabel('R_Laserbeam', true)
			self:SetWeaponEnabledByLabel('L_Laserbeam', true)
        elseif enh == 'AdvancedLaserSystemRemove' then
			self:SetWeaponEnabledByLabel('R_Laserbeam', false)
			self:SetWeaponEnabledByLabel('L_Laserbeam', false)
		elseif enh == 'MicrowaveLaserGenerator' then
            self:SetWeaponEnabledByLabel('MLG', true)
        elseif enh == 'MicrowaveLaserGeneratorRemove' then
            self:SetWeaponEnabledByLabel('MLG', false)
		elseif enh == 'LeftLaserGun' then
            self:SetWeaponEnabledByLabel('L_LaserCannons', true)
        elseif enh == 'LeftLaserGunRemove' then
            self:SetWeaponEnabledByLabel('L_LaserCannons', false)
		elseif enh == 'RightLaserGun' then
            self:SetWeaponEnabledByLabel('R_LaserCannons', true)
        elseif enh == 'RightLaserGunRemove' then
            self:SetWeaponEnabledByLabel('R_LaserCannons', false)
		elseif enh == 'TML' then
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'TMLRemove' then
            self:SetWeaponEnabledByLabel('Missile', false)  
		elseif enh == 'NaniteMissileRack' then
            self:SetWeaponEnabledByLabel('Nanite_Missile', true)
        elseif enh == 'NaniteMissileRackRemove' then
            self:SetWeaponEnabledByLabel('Nanite_Missile', false)
		elseif enh == 'RightEB' then
            self:SetWeaponEnabledByLabel('R_ElectBolter', true)
        elseif enh == 'RightEBRemove' then
            self:SetWeaponEnabledByLabel('R_ElectBolter', false)
		elseif enh == 'LeftEB' then
            self:SetWeaponEnabledByLabel('L_ElectBolter', true)
        elseif enh == 'LeftEBRemove' then
            self:SetWeaponEnabledByLabel('L_ElectBolter', false)
		elseif enh == 'Artillery' then
            self:SetWeaponEnabledByLabel('R_MArtillery', true)
			self:SetWeaponEnabledByLabel('L_MArtillery', true)
        elseif enh == 'ArtilleryRemove' then
            self:SetWeaponEnabledByLabel('R_MArtillery', false)
			self:SetWeaponEnabledByLabel('L_MArtillery', false)
					elseif enh == 'HArtillery' then
            self:SetWeaponEnabledByLabel('HArtillery', true)
        elseif enh == 'HArtilleryRemove' then
            self:SetWeaponEnabledByLabel('HArtillery', false)
        end            
    end,
    
    # **********
    # Intel
    # **********    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Torso',
				    'R_Barrel',
				    'L_Barrel',
					'R_L_Barrel',
				    'L_L_Barrel',
				    'Center_Turret',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Torso',
				    'R_Barrel',
				    'L_Barrel',
					'R_L_Barrel',
				    'L_L_Barrel',
				    'Center_Turret',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Left_Foot_B01',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
				    'Right_Foot_B01',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
        ACUUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects(self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag)
            end
        end
    end,

    OnIntelDisabled = function(self)
        ACUUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self, 'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end
    end,
        
    # *****
    # Death
    # *****
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end 
        #if we could find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
            #Apply Buff
			self:AddBuff(bp)
        end
        #otherwise, we should finish killing the unit
        ACUUnit.OnKilled(self, instigator, type, overkillRatio)
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

end  
    
TypeClass = URL0002

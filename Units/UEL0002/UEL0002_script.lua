#****************************************************************************
#**
#**  File     :  /cdimage/units/UEL0001/UEL0001_script.lua
#**  Author(s):  John Comes, David Tomandl, Jessica St. Croix
#**
#**  Summary  :  UEF Commander Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local Shield = import('/lua/shield.lua').Shield

local TerranWeaponFile = import('/lua/terranweapons.lua')
local TDFZephyrCannonWeapon = TerranWeaponFile.TDFZephyrCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TIFCruiseMissileLauncher = TerranWeaponFile.TIFCruiseMissileLauncher
local TDFOverchargeWeapon = TerranWeaponFile.TDFOverchargeWeapon
local TDFGaussCannonWeapon = TerranWeaponFile.TDFGaussCannonWeapon
local TSAMLauncher = TerranWeaponFile.TSAMLauncher
local TIFHighBallisticMortarWeapon = TerranWeaponFile.TIFHighBallisticMortarWeapon
local TDFRiotWeapon = TerranWeaponFile.TDFRiotWeapon
local TIFArtilleryWeapon = TerranWeaponFile.TIFArtilleryWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then

local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TIFCommanderDeathWeapon = TerranWeaponFile.TIFCommanderDeathWeapon

UEL0002 = Class(TWalkingLandUnit) {    
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
		WeaponEnabled = {},
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
        Zephyr = Class(TDFZephyrCannonWeapon) {},
		Missile_Pod = Class(TSAMLauncher) {}, 
		Med_Artillery = Class(TIFArtilleryWeapon) {},
		H_Artillery = Class(TIFArtilleryWeapon) {},
		R_Light_Artillery = Class(TIFHighBallisticMortarWeapon) {  
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TIFHighBallisticMortarWeapon.CreateProjectileAtMuzzle(self, muzzle)
                local data = {
                        Radius = self:GetBlueprint().CameraVisionRadius or 5,
                        Lifetime = self:GetBlueprint().CameraLifetime or 5,
                        Army = self.unit:GetArmy(),
                }
                if proj and not proj:BeenDestroyed() then
                        proj:PassData(data)
                end
            end,
        },
		L_Light_Artillery = Class(TIFHighBallisticMortarWeapon) {  
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TIFHighBallisticMortarWeapon.CreateProjectileAtMuzzle(self, muzzle)
                local data = {
                        Radius = self:GetBlueprint().CameraVisionRadius or 5,
                        Lifetime = self:GetBlueprint().CameraLifetime or 5,
                        Army = self.unit:GetArmy(),
                }
                if proj and not proj:BeenDestroyed() then
                        proj:PassData(data)
                end
            end,
        },
		Missile_Pod_Left = Class(TSAMLauncher) {}, 
		Missile_Pod_Right = Class(TSAMLauncher) {}, 
		GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'L_Barrel_Rotate', 'z', nil, -270, -180, -60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'R_Barrel_Rotate', 'z', nil, 270, 180, 60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		L_GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'L_Gatling_Rotate1', 'z', nil, -270, -180, -60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'L_Gatling_Rotate2', 'z', nil, -270, -180, -60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		R_GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'R_Gatling_Rotate1', 'z', nil, 270, 180, 60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'R_Gatling_Rotate2', 'z', nil, 270, 180, 60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		Heavy_Gauss_Left = Class(TDFGaussCannonWeapon) {},
		Heavy_Gauss_Right = Class(TDFGaussCannonWeapon) {},
		R_Gauss = Class(TDFGaussCannonWeapon) {},
		L_Gauss = Class(TDFGaussCannonWeapon) {},
		Light_Gauss = Class(TDFGaussCannonWeapon) {},
        OverCharge = Class(TDFOverchargeWeapon) {

            OnCreate = function(self)
                TDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('Zephyr', false)
                self.unit:ResetWeaponByLabel('Zephyr')
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightZephyr'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                TDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('Zephyr', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    TDFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(TDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(TDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },            
            
        },
        TacMissile = Class(TIFCruiseMissileLauncher) {
        },
        TacNukeMissile = Class(TIFCruiseMissileLauncher) {
        },
    },

    OnCreate = function(self)
        TWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('L_G_Upgrade', true)
		self:HideBone('L_Gatling_Upgrade', true)
		self:HideBone('R_Gatling_Upgrade', true)
		self:HideBone('Art_Turret_Upgrade', true)
		self:HideBone('G_Turret_Upgrade', true)
        self:HideBone('R_G_Upgrade', true)
		self:HideBone('TML_Upgrade', true)
		self:HideBone('Back_Upgrade_B01', true)
        self:HideBone('Back_Upgrade_B02', true)
		self:HideBone('Back_Upgrade_B03', true)
        self:HideBone('Back_Upgrade_B04', true)
        self:SetupBuildBones()
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        TWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('Zephyr', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('Zephyr'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        TWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        TWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        TWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:BuildManipulatorSetEnabled(false)
		self:SetWeaponEnabledByLabel('GatlingGun', true)
		self:SetWeaponEnabledByLabel('Light_Gauss', true)
        self:SetWeaponEnabledByLabel('Zephyr', true)
		self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', false)
		self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', false)
		self:SetWeaponEnabledByLabel('L_Gauss', false)
		self:SetWeaponEnabledByLabel('R_Gauss', false)
		self:SetWeaponEnabledByLabel('L_GatlingGun', false)
		self:SetWeaponEnabledByLabel('R_GatlingGun', false)
		self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
		self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		self:SetWeaponEnabledByLabel('Med_Artillery', false)
		self:SetWeaponEnabledByLabel('H_Artillery', false)
		self:SetWeaponEnabledByLabel('Missile_Pod_Left', false)
		self:SetWeaponEnabledByLabel('Missile_Pod_Right', false)
		self:SetWeaponEnabledByLabel('Missile_Pod', false)
        self:SetWeaponEnabledByLabel('TacMissile', false)
        self:ForkThread(self.GiveInitialResources)
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
        self:SetMesh('/units/uel0001/UEL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('L_G_Upgrade', true)
		self:HideBone('L_Gatling_Upgrade', true)
		self:HideBone('R_Gatling_Upgrade', true)
		self:HideBone('Art_Turret_Upgrade', true)
		self:HideBone('G_Turret_Upgrade', true)
        self:HideBone('R_G_Upgrade', true)
		self:HideBone('TML_Upgrade', true)
		self:HideBone('Back_Upgrade_B01', true)
        self:HideBone('Back_Upgrade_B02', true)
		self:HideBone('Back_Upgrade_B03', true)
        self:HideBone('Back_Upgrade_B04', true)
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

    OnStartBuild = function(self, unitBeingBuilt, order)
        TWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnFailedToBuild = function(self)
        TWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        end           
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        TWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    CreateEnhancement = function(self, enh)
        TWalkingLandUnit.CreateEnhancement(self, enh)
         local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreateShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'AdvancedShield' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'AdvancedShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh =='DamageStablization' then
            self:SetRegenRate(bp.NewRegenRate)
        elseif enh =='DamageStablizationRemove' then
            self:RevertRegenRate()
        elseif enh =='HeavyGaussCannonLeft' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', true)
        elseif enh =='HeavyGaussCannonLeftRemove' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', false)
            oc:ChangeMaxRadius(bpDisrupt or 22)  
		elseif enh =='HeavyGaussCannonRight' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', true)
        elseif enh =='HeavyGaussCannonRightRemove' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', false)
		elseif enh =='MissileLauncherLeft' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Left', true)
        elseif enh =='MissileLauncherLeftRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Left', false)
		elseif enh =='MissileLauncherRight' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Right', true)
        elseif enh =='MissileLauncherRightRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Right', false)
		elseif enh =='MissileBattery' then
            self:SetWeaponEnabledByLabel('Missile_Pod', true)
        elseif enh =='MissileBatteryRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod', false)
		elseif enh =='Art_Mortar' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', true)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', true)
        elseif enh =='Art_MortarRemove' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		elseif enh =='H_Art_Mortar' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', true)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', true)
        elseif enh =='H_Art_MortarRemove' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		elseif enh =='Artillery' then
            self:SetWeaponEnabledByLabel('Med_Artillery', true)
        elseif enh =='ArtilleryRemove' then
            self:SetWeaponEnabledByLabel('Med_Artillery', false)
		elseif enh =='HeavyArtillery' then
            self:SetWeaponEnabledByLabel('H_Artillery', true)
        elseif enh =='HeavyArtilleryRemove' then
            self:SetWeaponEnabledByLabel('H_Artillery', false)
		elseif enh =='GatlingLeft' then
            self:SetWeaponEnabledByLabel('L_GatlingGun', true)
        elseif enh =='GatlingLeftRemove' then
            self:SetWeaponEnabledByLabel('L_GatlingGun', false)
		elseif enh =='GatlingRight' then
            self:SetWeaponEnabledByLabel('R_GatlingGun', true)
        elseif enh =='GatlingRightRemove' then
            self:SetWeaponEnabledByLabel('R_GatlingGun', false)
		elseif enh =='Gauss_Turrets' then
            self:SetWeaponEnabledByLabel('L_Gauss', true)
			self:SetWeaponEnabledByLabel('R_Gauss', true)
        elseif enh =='Gauss_TurretsRemove' then
            self:SetWeaponEnabledByLabel('L_Gauss', false)   
            self:SetWeaponEnabledByLabel('R_Gauss', false)  			
        elseif enh =='TacticalMissile' then
            self:SetWeaponEnabledByLabel('TacMissile', true)
        elseif enh == 'TacticalMissileRemove' then
            self:SetWeaponEnabledByLabel('TacMissile', false)
        end
    end,
    
    OnPaused = function(self)
        TWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            TWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        TWalkingLandUnit.OnUnpaused(self)
    end,  

}

else

local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon

UEL0002 = Class(ACUUnit) {    
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
		WeaponEnabled = {},
        DeathWeapon = Class(DeathNukeWeapon) {},
        Zephyr = Class(TDFZephyrCannonWeapon) {},
		Missile_Pod = Class(TSAMLauncher) {}, 
		Med_Artillery = Class(TIFArtilleryWeapon) {},
		H_Artillery = Class(TIFArtilleryWeapon) {},
		R_Light_Artillery = Class(TIFHighBallisticMortarWeapon) {  
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TIFHighBallisticMortarWeapon.CreateProjectileAtMuzzle(self, muzzle)
                local data = {
                        Radius = self:GetBlueprint().CameraVisionRadius or 5,
                        Lifetime = self:GetBlueprint().CameraLifetime or 5,
                        Army = self.unit:GetArmy(),
                }
                if proj and not proj:BeenDestroyed() then
                        proj:PassData(data)
                end
            end,
        },
		L_Light_Artillery = Class(TIFHighBallisticMortarWeapon) {  
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TIFHighBallisticMortarWeapon.CreateProjectileAtMuzzle(self, muzzle)
                local data = {
                        Radius = self:GetBlueprint().CameraVisionRadius or 5,
                        Lifetime = self:GetBlueprint().CameraLifetime or 5,
                        Army = self.unit:GetArmy(),
                }
                if proj and not proj:BeenDestroyed() then
                        proj:PassData(data)
                end
            end,
        },
		Missile_Pod_Left = Class(TSAMLauncher) {}, 
		Missile_Pod_Right = Class(TSAMLauncher) {}, 
		GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'L_Barrel_Rotate', 'z', nil, -270, -180, -60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'R_Barrel_Rotate', 'z', nil, 270, 180, 60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		L_GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'L_Gatling_Rotate1', 'z', nil, -270, -180, -60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'L_Gatling_Rotate2', 'z', nil, -270, -180, -60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		R_GatlingGun = Class(TDFRiotWeapon) {
                PlayFxWeaponUnpackSequence = function(self)
                    if not self.SpinManip then 
                        self.SpinManip = CreateRotator(self.unit, 'R_Gatling_Rotate1', 'z', nil, 270, 180, 60)
                        self.unit.Trash:Add(self.SpinManip)
						self.SpinManip2 = CreateRotator(self.unit, 'R_Gatling_Rotate2', 'z', nil, 270, 180, 60)
						self.unit.Trash:Add(self.SpinManip2)
                    end
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(270)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(270)
                    end
                    TDFRiotWeapon.PlayFxWeaponUnpackSequence(self)
                end,

                PlayFxWeaponPackSequence = function(self)
                    if self.SpinManip then
                        self.SpinManip:SetTargetSpeed(0)
                    end
					if self.SpinManip2 then
                        self.SpinManip2:SetTargetSpeed(0)
                    end
                    TDFRiotWeapon.PlayFxWeaponPackSequence(self)
                end,
		},
		Heavy_Gauss_Left = Class(TDFGaussCannonWeapon) {},
		Heavy_Gauss_Right = Class(TDFGaussCannonWeapon) {},
		R_Gauss = Class(TDFGaussCannonWeapon) {},
		L_Gauss = Class(TDFGaussCannonWeapon) {},
		Light_Gauss = Class(TDFGaussCannonWeapon) {},
        OverCharge = Class(TDFOverchargeWeapon) {

            OnCreate = function(self)
                TDFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('Zephyr', false)
                self.unit:ResetWeaponByLabel('Zephyr')
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightZephyr'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                TDFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('Zephyr', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    TDFOverchargeWeapon.OnFire(self)
                end
            end,
            IdleState = State(TDFOverchargeWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(TDFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        TDFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },            
            
        },
        TacMissile = Class(TIFCruiseMissileLauncher) {
        },
        TacNukeMissile = Class(TIFCruiseMissileLauncher) {
        },
    },

    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('L_G_Upgrade', true)
		self:HideBone('L_Gatling_Upgrade', true)
		self:HideBone('R_Gatling_Upgrade', true)
		self:HideBone('Art_Turret_Upgrade', true)
		self:HideBone('G_Turret_Upgrade', true)
        self:HideBone('R_G_Upgrade', true)
		self:HideBone('TML_Upgrade', true)
		self:HideBone('Back_Upgrade_B01', true)
        self:HideBone('Back_Upgrade_B02', true)
		self:HideBone('Back_Upgrade_B03', true)
        self:HideBone('Back_Upgrade_B04', true)
        self:SetupBuildBones()
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        ACUUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('Zephyr', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('Zephyr'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        ACUUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        ACUUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        ACUUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    GiveInitialResources = function(self)
        WaitTicks(5)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ACUUnit.OnStopBeingBuilt(self,builder,layer)
        if self:BeenDestroyed() then return end
        self.Animator = CreateAnimator(self)
        self.Animator:SetPrecedence(0)
        if self.IdleAnim then
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true)
            for k, v in self.DisabledBones do
                self.Animator:SetBoneEnabled(v, false)
            end
        end
        self:BuildManipulatorSetEnabled(false)
		self:SetWeaponEnabledByLabel('GatlingGun', true)
		self:SetWeaponEnabledByLabel('Light_Gauss', true)
        self:SetWeaponEnabledByLabel('Zephyr', true)
		self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', false)
		self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', false)
		self:SetWeaponEnabledByLabel('L_Gauss', false)
		self:SetWeaponEnabledByLabel('R_Gauss', false)
		self:SetWeaponEnabledByLabel('L_GatlingGun', false)
		self:SetWeaponEnabledByLabel('R_GatlingGun', false)
		self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
		self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		self:SetWeaponEnabledByLabel('Med_Artillery', false)
		self:SetWeaponEnabledByLabel('H_Artillery', false)
		self:SetWeaponEnabledByLabel('Missile_Pod_Left', false)
		self:SetWeaponEnabledByLabel('Missile_Pod_Right', false)
		self:SetWeaponEnabledByLabel('Missile_Pod', false)
        self:SetWeaponEnabledByLabel('TacMissile', false)
        self:ForkThread(self.GiveInitialResources)
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
        self:SetMesh('/units/uel0001/UEL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
        self:HideBone('Right_Upgrade', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('L_G_Upgrade', true)
		self:HideBone('L_Gatling_Upgrade', true)
		self:HideBone('R_Gatling_Upgrade', true)
		self:HideBone('Art_Turret_Upgrade', true)
		self:HideBone('G_Turret_Upgrade', true)
        self:HideBone('R_G_Upgrade', true)
		self:HideBone('TML_Upgrade', true)
		self:HideBone('Back_Upgrade_B01', true)
        self:HideBone('Back_Upgrade_B02', true)
		self:HideBone('Back_Upgrade_B03', true)
        self:HideBone('Back_Upgrade_B04', true)
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

    OnStartBuild = function(self, unitBeingBuilt, order)
        ACUUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.Animator then
            self.Animator:SetRate(0)
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,

    OnFailedToBuild = function(self)
        ACUUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        # If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            EffectUtil.CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            EffectUtil.CreateUEFCommanderBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        end           
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        ACUUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        if (self.IdleAnim and not self:IsDead()) then
            self.Animator:PlayAnim(self.IdleAnim, true)
        end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('Zephyr', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('Zephyr'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreateShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'AdvancedShield' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'AdvancedShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh =='DamageStablization' then
            self:SetRegenRate(bp.NewRegenRate)
        elseif enh =='DamageStablizationRemove' then
            self:RevertRegenRate()
        elseif enh =='HeavyGaussCannonLeft' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', true)
        elseif enh =='HeavyGaussCannonLeftRemove' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Left', false)
            oc:ChangeMaxRadius(bpDisrupt or 22)  
		elseif enh =='HeavyGaussCannonRight' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', true)
        elseif enh =='HeavyGaussCannonRightRemove' then
            self:SetWeaponEnabledByLabel('Heavy_Gauss_Right', false)
		elseif enh =='MissileLauncherLeft' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Left', true)
        elseif enh =='MissileLauncherLeftRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Left', false)
		elseif enh =='MissileLauncherRight' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Right', true)
        elseif enh =='MissileLauncherRightRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod_Right', false)
		elseif enh =='MissileBattery' then
            self:SetWeaponEnabledByLabel('Missile_Pod', true)
        elseif enh =='MissileBatteryRemove' then
            self:SetWeaponEnabledByLabel('Missile_Pod', false)
		elseif enh =='Art_Mortar' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', true)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', true)
        elseif enh =='Art_MortarRemove' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		elseif enh =='H_Art_Mortar' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', true)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', true)
        elseif enh =='H_Art_MortarRemove' then
            self:SetWeaponEnabledByLabel('R_Light_Artillery', false)
			self:SetWeaponEnabledByLabel('L_Light_Artillery', false)
		elseif enh =='Artillery' then
            self:SetWeaponEnabledByLabel('Med_Artillery', true)
        elseif enh =='ArtilleryRemove' then
            self:SetWeaponEnabledByLabel('Med_Artillery', false)
		elseif enh =='HeavyArtillery' then
            self:SetWeaponEnabledByLabel('H_Artillery', true)
        elseif enh =='HeavyArtilleryRemove' then
            self:SetWeaponEnabledByLabel('H_Artillery', false)
		elseif enh =='GatlingLeft' then
            self:SetWeaponEnabledByLabel('L_GatlingGun', true)
        elseif enh =='GatlingLeftRemove' then
            self:SetWeaponEnabledByLabel('L_GatlingGun', false)
		elseif enh =='GatlingRight' then
            self:SetWeaponEnabledByLabel('R_GatlingGun', true)
        elseif enh =='GatlingRightRemove' then
            self:SetWeaponEnabledByLabel('R_GatlingGun', false)
		elseif enh =='Gauss_Turrets' then
            self:SetWeaponEnabledByLabel('L_Gauss', true)
			self:SetWeaponEnabledByLabel('R_Gauss', true)
        elseif enh =='Gauss_TurretsRemove' then
            self:SetWeaponEnabledByLabel('L_Gauss', false)   
            self:SetWeaponEnabledByLabel('R_Gauss', false)  			
        elseif enh =='TacticalMissile' then
            self:SetWeaponEnabledByLabel('TacMissile', true)
        elseif enh == 'TacticalMissileRemove' then
            self:SetWeaponEnabledByLabel('TacMissile', false)
        end
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

TypeClass = UEL0002
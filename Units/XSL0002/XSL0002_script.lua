#****************************************************************************
#**
#**  File     :  /cdimage/units/XSL0001/XSL0001_script.lua
#**  Author(s):  Drew Staltman, Jessica St. Croix, Gordon Duclos
#**
#**  Summary  :  Seraphim Commander Script
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

local SWeapons = import('/lua/seraphimweapons.lua')
local SDFChronotronCannonWeapon = SWeapons.SDFChronotronCannonWeapon
local SDFChronotronOverChargeCannonWeapon = SWeapons.SDFChronotronCannonOverChargeWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher
local SDFOhCannon = SWeapons.SDFOhCannon
local SIFZthuthaamArtilleryCannon = SWeapons.SIFZthuthaamArtilleryCannon
local SDFAireauBolterWeapon = SWeapons.SDFAireauBolterWeapon02
local AIUtils = import('/lua/ai/aiutilities.lua')

local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon

XSL0002 = Class( SWalkingLandUnit ) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
		L_OhCannon = Class(SDFOhCannon) {},
		R_OhCannon = Class(SDFOhCannon) {},
		AireauBolter = Class(SDFAireauBolterWeapon) {},
		L_AireauBolter = Class(SDFAireauBolterWeapon) {},
		R_AireauBolter = Class(SDFAireauBolterWeapon) {},
		R_ZthuthaamArt = Class(SIFZthuthaamArtilleryCannon) {},
		L_ZthuthaamArt = Class(SIFZthuthaamArtilleryCannon) {},
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
        OverCharge = Class(SDFChronotronOverChargeCannonWeapon) {

            OnCreate = function(self)
                SDFChronotronOverChargeCannonWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                SDFChronotronOverChargeCannonWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
            end,
            
            OnWeaponFired = function(self)
                SDFChronotronOverChargeCannonWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    SDFChronotronOverChargeCannonWeapon.OnFire(self)
                end
            end,
            IdleState = State(SDFChronotronOverChargeCannonWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },  
        },
    },


    OnCreate = function(self)
        SWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
		self:HideBone('Art_Upgrade', true)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Missile_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Body_Gun_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        SWalkingLandUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('ChronotronCannon', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        SWalkingLandUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        SWalkingLandUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        SWalkingLandUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
		self:SetWeaponEnabledByLabel('L_OhCannon', true)
		self:SetWeaponEnabledByLabel('R_OhCannon', true)
		self:SetWeaponEnabledByLabel('AireauBolter', false)
		self:SetWeaponEnabledByLabel('L_AireauBolter', false)
		self:SetWeaponEnabledByLabel('R_AireauBolter', false)
		self:SetWeaponEnabledByLabel('R_ZthuthaamArt', false)
		self:SetWeaponEnabledByLabel('L_ZthuthaamArt', false)
		self:SetWeaponEnabledByLabel('Missile', false)
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
    end,

    OnFailedToBuild = function(self)
        SWalkingLandUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        local bp = self:GetBlueprint()
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            self.Upgrading = true
            self.BuildingUnit = false        
            unitBeingBuilt.DisallowCollisions = true
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,  

    OnStopBuild = function(self, unitBeingBuilt)
        SWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
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
        self:ShowBone(0, true)
		self:HideBone('Art_Upgrade', true)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Missile_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Body_Gun_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
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
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    RegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.RegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,
       
    AdvancedRegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.AdvancedRegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

    CreateEnhancement = function(self, enh)
        SWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        
        # Regenerative Aura
        if enh == 'RegenAura' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura',
                    DisplayName = 'SeraphimACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
                
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread)
                        
        elseif enh == 'RegenAuraRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.RegenThreadHandle)
            
        elseif enh == 'AdvancedRegenAura' then
            if self.RegenThreadHandle then
                if self.ShieldEffectsBag then
                    for k, v in self.ShieldEffectsBag do
                        v:Destroy()
                    end
		            self.ShieldEffectsBag = {}
		        end
                KillThread(self.RegenThreadHandle)
                
            end
            
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimAdvancedACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura',
                    DisplayName = 'SeraphimAdvancedACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                        MaxHealth = {
                            Add = 0,
                            Mult = bp.MaxHealthFactor or 1.0,
                            DoNoFill = true,
                        },                        
                    },
                }
            end
            
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.AdvancedRegenThreadHandle = self:ForkThread(self.AdvancedRegenBuffThread)
            
        elseif enh == 'AdvancedRegenAuraRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.AdvancedRegenThreadHandle)
            
        #Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimACUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilization',
                    DisplayName = 'SeraphimACUDamageStabilization',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilization')    
      	elseif enh == 'DamageStabilizationAdvanced' then
            if not Buffs['SeraphimACUDamageStabilizationAdv'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilizationAdv',
                    DisplayName = 'SeraphimACUDamageStabilizationAdv',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilizationAdv')     	    
        elseif enh == 'DamageStabilizationAdvancedRemove' then
            # since there's no way to just remove an upgrade anymore, if we're remove adv, we're removing both
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end         
        elseif enh == 'DamageStabilizationRemove' then
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end           
        #Teleporter
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        # Tactical Missile
        elseif enh == 'Missile' then     
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissileRemove' then    
            self:SetWeaponEnabledByLabel('Missile', false)
        #Blast Attack
        elseif enh == 'R_BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'R_BlastAttackRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        #Heat Sink Augmentation
        elseif enh == 'R_RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)            
        elseif enh == 'R_RateOfFireRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)     
        elseif enh == 'L_BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'L_BlastAttackRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        #Heat Sink Augmentation
        elseif enh == 'L_RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)            
        elseif enh == 'L_RateOfFireRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22) 
        elseif enh == 'Artillery' then    
            self:SetWeaponEnabledByLabel('R_ZthuthaamArt', true)
			self:SetWeaponEnabledByLabel('L_ZthuthaamArt', true)
        elseif enh == 'ArtilleryRemove' then     
            self:SetWeaponEnabledByLabel('R_ZthuthaamArt', false) 
			self:SetWeaponEnabledByLabel('L_ZthuthaamArt', false) 
        elseif enh == 'BodyBolterGun' then    
            self:SetWeaponEnabledByLabel('AireauBolter', true)
        elseif enh == 'BodyBolterGunRemove' then     
            self:SetWeaponEnabledByLabel('AireauBolter', false) 
        elseif enh == 'L_BolterGun' then    
            self:SetWeaponEnabledByLabel('L_AireauBolter', true)
        elseif enh == 'L_BolterGunRemove' then     
            self:SetWeaponEnabledByLabel('L_AireauBolter', false) 
        elseif enh == 'R_BolterGun' then    
            self:SetWeaponEnabledByLabel('R_AireauBolter', true)
        elseif enh == 'R_BolterGunRemove' then     
            self:SetWeaponEnabledByLabel('R_AireauBolter', false) 			
        end
    end,

    OnPaused = function(self)
        SWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            SWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        SWalkingLandUnit.OnUnpaused(self)
    end,

}

TypeClass = XSL0002

else

local ACUUnit = import('/lua/defaultunits.lua').ACUUnit
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon

XSL0002 = Class(ACUUnit) {
    DeathThreadDestructionWaitTime = 2,

    Weapons = {
        DeathWeapon = Class(DeathNukeWeapon) {},
        ChronotronCannon = Class(SDFChronotronCannonWeapon) {},
		L_OhCannon = Class(SDFOhCannon) {},
		R_OhCannon = Class(SDFOhCannon) {},
		AireauBolter = Class(SDFAireauBolterWeapon) {},
		L_AireauBolter = Class(SDFAireauBolterWeapon) {},
		R_AireauBolter = Class(SDFAireauBolterWeapon) {},
		R_ZthuthaamArt = Class(SIFZthuthaamArtilleryCannon) {},
		L_ZthuthaamArt = Class(SIFZthuthaamArtilleryCannon) {},
        Missile = Class(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
        OverCharge = Class(SDFChronotronOverChargeCannonWeapon) {

            OnCreate = function(self)
                SDFChronotronOverChargeCannonWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                SDFChronotronOverChargeCannonWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
            end,
            
            OnWeaponFired = function(self)
                SDFChronotronOverChargeCannonWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('ChronotronCannon', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
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
                    SDFChronotronOverChargeCannonWeapon.OnFire(self)
                end
            end,
            IdleState = State(SDFChronotronOverChargeCannonWeapon.IdleState) {
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
            },
            RackSalvoFireReadyState = State(SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        SDFChronotronOverChargeCannonWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },  
        },
    },


    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetupBuildBones()
		self:HideBone('Art_Upgrade', true)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Missile_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Body_Gun_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
        # Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.SERAPHIM * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
    end,

    OnPrepareArmToBuild = function(self)
        ACUUnit.OnPrepareArmToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('ChronotronCannon', false)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('ChronotronCannon'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        ACUUnit.OnStopCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        ACUUnit.OnFailedCapture(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        ACUUnit.OnStopReclaim(self, target)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        ACUUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
		self:SetWeaponEnabledByLabel('L_OhCannon', true)
		self:SetWeaponEnabledByLabel('R_OhCannon', true)
		self:SetWeaponEnabledByLabel('AireauBolter', false)
		self:SetWeaponEnabledByLabel('L_AireauBolter', false)
		self:SetWeaponEnabledByLabel('R_AireauBolter', false)
		self:SetWeaponEnabledByLabel('R_ZthuthaamArt', false)
		self:SetWeaponEnabledByLabel('L_ZthuthaamArt', false)
		self:SetWeaponEnabledByLabel('Missile', false)
        self:ForkThread(self.GiveInitialResources)
        self.ShieldEffectsBag = {}
    end,

    OnFailedToBuild = function(self)
        ACUUnit.OnFailedToBuild(self)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        local bp = self:GetBlueprint()
        if order != 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then
            self:StartBuildingEffects(unitBeingBuilt, order)
        end
        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            self.Upgrading = true
            self.BuildingUnit = false        
            unitBeingBuilt.DisallowCollisions = true
        end
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,  

    OnStopBuild = function(self, unitBeingBuilt)
        ACUUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('ChronotronCannon', true)
        self:SetWeaponEnabledByLabel('OverCharge', false)
        self:GetWeaponManipulatorByLabel('ChronotronCannon'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
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
        self:ShowBone(0, true)
		self:HideBone('Art_Upgrade', true)
        self:HideBone('Back_Upgrade', true)
		self:HideBone('Back_Upgrade2', true)
		self:HideBone('Missile_Upgrade', true)
        self:HideBone('Right_Upgrade', true)
		self:HideBone('Body_Gun_Upgrade', true)
		self:HideBone('Right_Upgrade2', true)
        self:HideBone('Left_Upgrade', true)
		self:HideBone('Left_Upgrade2', true)
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
    end,

    GiveInitialResources = function(self)
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    RegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.RegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,
       
    AdvancedRegenBuffThread = function(self)
        while not self:IsDead() do
            #Get friendly units in the area (including self)
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.BUILTBYTIER3FACTORY + categories.BUILTBYQUANTUMGATE + categories.NEEDMOBILEBUILD, self:GetPosition(), self:GetBlueprint().Enhancements.AdvancedRegenAura.Radius)
            
            #Give them a 5 second regen buff
            for _,unit in units do
                Buff.ApplyBuff(unit, 'SeraphimAdvancedACURegenAura')
            end
            
            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,

    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        
        # Regenerative Aura
        if enh == 'RegenAura' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura',
                    DisplayName = 'SeraphimACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
                
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread)
                        
        elseif enh == 'RegenAuraRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.RegenThreadHandle)
            
        elseif enh == 'AdvancedRegenAura' then
            if self.RegenThreadHandle then
                if self.ShieldEffectsBag then
                    for k, v in self.ShieldEffectsBag do
                        v:Destroy()
                    end
		            self.ShieldEffectsBag = {}
		        end
                KillThread(self.RegenThreadHandle)
                
            end
            
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimAdvancedACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura',
                    DisplayName = 'SeraphimAdvancedACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'REPLACE',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                        MaxHealth = {
                            Add = 0,
                            Mult = bp.MaxHealthFactor or 1.0,
                            DoNoFill = true,
                        },                        
                    },
                }
            end
            
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.AdvancedRegenThreadHandle = self:ForkThread(self.AdvancedRegenBuffThread)
            
        elseif enh == 'AdvancedRegenAuraRemove' then
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.AdvancedRegenThreadHandle)
            
        #Damage Stabilization
        elseif enh == 'DamageStabilization' then
            if not Buffs['SeraphimACUDamageStabilization'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilization',
                    DisplayName = 'SeraphimACUDamageStabilization',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilization')    
      	elseif enh == 'DamageStabilizationAdvanced' then
            if not Buffs['SeraphimACUDamageStabilizationAdv'] then
               BuffBlueprint {
                    Name = 'SeraphimACUDamageStabilizationAdv',
                    DisplayName = 'SeraphimACUDamageStabilizationAdv',
                    BuffType = 'ACUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end  
            Buff.ApplyBuff(self, 'SeraphimACUDamageStabilizationAdv')     	    
        elseif enh == 'DamageStabilizationAdvancedRemove' then
            # since there's no way to just remove an upgrade anymore, if we're remove adv, we're removing both
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilizationAdv' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilizationAdv' )
            end
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end         
        elseif enh == 'DamageStabilizationRemove' then
            if Buff.HasBuff( self, 'SeraphimACUDamageStabilization' ) then
                Buff.RemoveBuff( self, 'SeraphimACUDamageStabilization' )
            end           
        #Teleporter
        elseif enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        # Tactical Missile
        elseif enh == 'Missile' then     
            self:SetWeaponEnabledByLabel('Missile', true)
        elseif enh == 'MissileRemove' then    
            self:SetWeaponEnabledByLabel('Missile', false)
        #Blast Attack
        elseif enh == 'R_BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'R_BlastAttackRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        #Heat Sink Augmentation
        elseif enh == 'R_RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)            
        elseif enh == 'R_RateOfFireRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22)     
        elseif enh == 'L_BlastAttack' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(bp.AdditionalDamage)
        elseif enh == 'L_BlastAttackRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 5)
            wep:AddDamageMod(-self:GetBlueprint().Enhancements['BlastAttack'].AdditionalDamage)
        #Heat Sink Augmentation
        elseif enh == 'L_RateOfFire' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            wep:ChangeRateOfFire(bp.NewRateOfFire or 2)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 44)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bp.NewMaxRadius or 44)            
        elseif enh == 'L_RateOfFireRemove' then
            local wep = self:GetWeaponByLabel('ChronotronCannon')
            local bpDisrupt = self:GetBlueprint().Weapon[1].RateOfFire
            wep:ChangeRateOfFire(bpDisrupt or 1)
            bpDisrupt = self:GetBlueprint().Weapon[1].MaxRadius            
            wep:ChangeMaxRadius(bpDisrupt or 22)
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius(bpDisrupt or 22) 
        elseif enh == 'Artillery' then    
            self:SetWeaponEnabledByLabel('R_ZthuthaamArt', true)
			self:SetWeaponEnabledByLabel('L_ZthuthaamArt', true)
        elseif enh == 'ArtilleryRemove' then     
            self:SetWeaponEnabledByLabel('R_ZthuthaamArt', false) 
			self:SetWeaponEnabledByLabel('L_ZthuthaamArt', false) 
        elseif enh == 'BodyBolterGun' then    
            self:SetWeaponEnabledByLabel('AireauBolter', true)
        elseif enh == 'BodyBolterGunRemove' then     
            self:SetWeaponEnabledByLabel('AireauBolter', false) 
        elseif enh == 'L_BolterGun' then    
            self:SetWeaponEnabledByLabel('L_AireauBolter', true)
        elseif enh == 'L_BolterGunRemove' then     
            self:SetWeaponEnabledByLabel('L_AireauBolter', false) 
        elseif enh == 'R_BolterGun' then    
            self:SetWeaponEnabledByLabel('R_AireauBolter', true)
        elseif enh == 'R_BolterGunRemove' then     
            self:SetWeaponEnabledByLabel('R_AireauBolter', false) 			
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

TypeClass = XSL0002

end
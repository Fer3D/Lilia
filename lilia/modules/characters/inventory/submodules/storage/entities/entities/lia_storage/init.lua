﻿---
include("shared.lua")
---
AddCSLuaFile("cl_init.lua")
---
AddCSLuaFile("shared.lua")
---
function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.receivers = {}
    if isfunction(self.PostInitialize) then self:PostInitialize() end
    self:PhysicsInit(SOLID_VPHYSICS)
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end
end

---
function ENT:setInventory(inventory)
    assert(inventory, "Storage setInventory called without an inventory!")
    self:setNetVar("id", inventory:getID())
    hook.Run("StorageInventorySet", self, inventory, false)
end

---
function ENT:deleteInventory()
    local inventory = self:getInv()
    if inventory then
        inventory:delete()
        if not self.liaForceDelete then hook.Run("StorageEntityRemoved", self, inventory) end
        self:setNetVar("id", nil)
    end
end

---
function ENT:OnRemove()
    if not self.liaForceDelete then
        if not lia.entityDataLoaded or not LiliaStorage.loadedData then return end
        if self.liaIsSafe then return end
        if lia.shuttingDown then return end
    end

    self:deleteInventory()
    LiliaStorage:SaveData()
end

---
function ENT:openInv(activator)
    local inventory = self:getInv()
    local storage = self:getStorageInfo()
    if isfunction(storage.onOpen) then storage.onOpen(self, activator) end
    activator:setAction(
        L("Opening...", activator),
        LiliaStorage.StorageOpenTime,
        function()
            if activator:GetPos():Distance(self:GetPos()) > 96 then
                activator.liaStorageEntity = nil
                return
            end

            self.receivers[activator] = true
            inventory:sync(activator)
            net.Start("liaStorageOpen")
            net.WriteEntity(self)
            net.Send(activator)
            local openSound = self:getStorageInfo().openSound
            self:EmitSound(openSound or "items/ammocrate_open.wav")
        end
    )
end

---
function ENT:Use(activator)
    if not activator:getChar() then return end
    if (activator.liaNextOpen or 0) > CurTime() then return end
    if IsValid(activator.liaStorageEntity) and (activator.liaNextOpen or 0) <= CurTime() then activator.liaStorageEntity = nil end
    local inventory = self:getInv()
    if not inventory then return end
    activator.liaStorageEntity = self
    if self:getNetVar("locked") then
        local lockSound = self:getStorageInfo().lockSound
        self:EmitSound(lockSound or "doors/default_locked.wav")
        if self.keypad then
            client.liaStorageEntity = nil
        else
            net.Start("liaStorageUnlock")
            net.WriteEntity(self)
            net.Send(activator)
        end
    else
        self:openInv(activator)
    end

    activator.liaNextOpen = CurTime() + LiliaStorage.StorageOpenTime * 1.5
end
---

local WorldData = {}

WorldData.Rarities = {
    Common = 60,
    Rare = 25,
    Epic = 10,
    Legendary = 4,
    Mythic = 1,
}

WorldData.Clans = {
    { Name = "Freecss", Rarity = "Epic", Buffs = { Intelligence = 1.15, Aura = 1.1 } },
    { Name = "Zoldyck", Rarity = "Legendary", Buffs = { Agility = 1.2, Strength = 1.1 }, Passive = "PoisonResist" },
    { Name = "Kurta", Rarity = "Legendary", Buffs = { Intelligence = 1.25, Aura = 1.15 }, Passive = "ScarletFocus" },
    { Name = "Nostrade", Rarity = "Rare", Buffs = { Intelligence = 1.1 } },
    { Name = "Hazama", Rarity = "Common", Buffs = { Strength = 1.05 } },
    { Name = "No Clan", Rarity = "Common", Buffs = { } },
}

WorldData.Races = {
    { Name = "Human", Rarity = "Common", Buffs = { Intelligence = 1.05, Aura = 1.05 } },
    { Name = "Beast-Human", Rarity = "Rare", Buffs = { Agility = 1.1, Strength = 1.1 } },
    { Name = "Chimera Ant", Rarity = "Mythic", Buffs = { Strength = 1.3, Aura = 1.25 }, Passive = "PredatorInstinct" },
    { Name = "Kurta", Rarity = "Epic", Buffs = { Intelligence = 1.15, Aura = 1.15 } },
}

WorldData.Powers = {
    {
        Name = "Enhancement",
        Rarity = "Common",
        NenAffinity = "Enhancer",
        Moves = {
            { Name = "Ko Strike", DamageScale = 1.2, Cost = 8 },
            { Name = "Ren Burst", DamageScale = 1.5, Cost = 16 },
        },
    },
    {
        Name = "Transmutation",
        Rarity = "Rare",
        NenAffinity = "Transmuter",
        Moves = {
            { Name = "Lightning Palm", DamageScale = 1.4, Cost = 12, Effect = "Stun" },
            { Name = "Godspeed Flash", DamageScale = 1.9, Cost = 20, Effect = "DodgeUp" },
        },
    },
    {
        Name = "Conjuration",
        Rarity = "Rare",
        NenAffinity = "Conjurer",
        Moves = {
            { Name = "Chain Bind", DamageScale = 1.3, Cost = 10, Effect = "Root" },
            { Name = "Judgement Chain", DamageScale = 2.1, Cost = 24, Effect = "Execute" },
        },
    },
    {
        Name = "Emission",
        Rarity = "Common",
        NenAffinity = "Emitter",
        Moves = {
            { Name = "Aura Shot", DamageScale = 1.35, Cost = 10 },
            { Name = "Remote Barrage", DamageScale = 1.7, Cost = 18 },
        },
    },
    {
        Name = "Manipulation",
        Rarity = "Epic",
        NenAffinity = "Manipulator",
        Moves = {
            { Name = "Puppet Command", DamageScale = 1.0, Cost = 10, Effect = "DefenseDown" },
            { Name = "Forced Obedience", DamageScale = 1.8, Cost = 22, Effect = "Confuse" },
        },
    },
    {
        Name = "Specialization",
        Rarity = "Legendary",
        NenAffinity = "Specialist",
        Moves = {
            { Name = "Skill Hunter", DamageScale = 2.0, Cost = 22, Effect = "StealBuff" },
            { Name = "Emperor Time", DamageScale = 2.2, Cost = 26, Effect = "AllStatsUp" },
        },
    },
}

WorldData.Missions = {
    {
        Id = "hunter_exam_trial",
        Name = "Hunter Exam Trial",
        MinPower = 10,
        Duration = 45,
        Rewards = { Jenny = 250, XP = 120, Item = "ExamToken" },
    },
    {
        Id = "heavens_arena_floor",
        Name = "Heavens Arena Floor Rush",
        MinPower = 40,
        Duration = 90,
        Rewards = { Jenny = 650, XP = 300, Item = "ArenaBadge" },
    },
    {
        Id = "phantom_pursuit",
        Name = "Phantom Troupe Pursuit",
        MinPower = 85,
        Duration = 150,
        Rewards = { Jenny = 1400, XP = 700, Item = "ScarletFragment" },
    },
}

return WorldData

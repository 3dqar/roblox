return {
    StageCount = 50,
    MusicAssetIds = {Lava=0, Ice=0, Candy=0, Space=0, Cyber=0}, -- paste permitted audio IDs; zero plays silence
    StudioDataStores = false, -- Set true only for published test place with API enabled
    SkipStageProductId = 0, -- Creator Dashboard Developer Product
    VipPassId = 0, -- Creator Dashboard Game Pass
    DonationProductIds = {0, 0, 0}, -- 5, 15, 30 Robux donation Developer Products
    SkipPrice = 9,
    AbilityPasses = {DoubleJump = 0, Glide = 0}, -- 19 and 29 Robux permanent game passes
    AbilityPrices = {DoubleJump = 19, Glide = 29},
    EffectPasses = {Aura = 0, Crown = 0, Bomz = 0}, -- Game Pass IDs: 10, 20, 40 Robux
    EffectPrices = {Aura = 10, Crown = 20, Bomz = 40},
    TrailCoinPrices = {Fire = 500, Ice = 1100, Rainbow = 2500},
    TrailPasses = {Galaxy = 0, Lightning = 0, Royal = 0}, -- Game Pass IDs, set in Creator Dashboard
    TrailRobuxPrices = {Galaxy = 15, Lightning = 25, Royal = 40},
    VipPrice = 39,
    DonationPrices = {5, 15, 30},
    Missions = {
        {stages = 3, title = "Reach Stage 3"},
        {stages = 10, title = "Beat 10 stages"},
        {stages = 20, title = "Reach Stage 20"},
        {stages = 35, title = "Reach Stage 35"},
        {stages = 51, title = "Finish the Obby"},
    },
}

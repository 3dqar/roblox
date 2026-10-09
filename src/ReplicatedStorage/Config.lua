return {
    StageCount = 30,
    StudioDataStores = false, -- Set true only for published test place with API enabled
    SkipStageProductId = 0, -- Creator Dashboard Developer Product
    VipPassId = 0, -- Creator Dashboard Game Pass
    DonationProductIds = {0, 0, 0}, -- 5, 15, 30 Robux donation Developer Products
    SkipPrice = 9,
    EffectPasses = {Aura = 0, Crown = 0, Bomz = 0}, -- Game Pass IDs: 10, 20, 40 Robux
    EffectPrices = {Aura = 10, Crown = 20, Bomz = 40},
    VipPrice = 39,
    DonationPrices = {5, 15, 30},
    Missions = {
        {stages = 3, title = "Reach Stage 3"},
        {stages = 10, title = "Beat 10 stages"},
        {stages = 20, title = "Reach Stage 20"},
        {stages = 31, title = "Finish the Obby"},
    },
}

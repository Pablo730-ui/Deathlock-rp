SDC = {}

---------------------------------------------------------------------------------
-------------------------------Important Configs---------------------------------
---------------------------------------------------------------------------------
SDC.Target = "qb-target" --Can be one of these (If "none" is selected it will use TextUi): ["qb-target","ox_target","none"]

SDC.MenuPosition = "top-right" --Where you want the main food truck menu to show up: ['top-left', 'top-right', 'bottom-left', 'bottom-right']

SDC.DispatchResource = "none" --If you are using a dispatch script, options below!
--[[
    SDC.DispatchResource Options:

    "none" - Will use default notifications made by me
    "ps-dispatch" - Will use ps-dispatch exports (MUST BE PS-DISPATCH V2)

]]

SDC.PoliceJobs = { --All Police Jobs
    --EX: ["job_name"] = true
    ["police"] = true
}
---------------------------------------------------------------------------------
-------------------------------Keybind Configs-----------------------------------
---------------------------------------------------------------------------------

SDC.PlaceKeys = { --Keybinds for placing down barrels/stills
    Exit = {Input = "INPUT_DETONATE", InputNum = 47}, --Keybind For Exiting
    Place = {Input = "INPUT_PICKUP", InputNum = 38}, --Keybind For Placing The Object
}

SDC.PourKeys = { --Keybinds for pouring a barrel
    Exit = {Input = "INPUT_DETONATE", InputNum = 47}, --Keybind For Exiting
    Pour = {Input = "INPUT_PICKUP", InputNum = 38} --Keybind For Placing The Object
}

SDC.CollectKeybind = {Input = 38, Label = "E"} --Keybind for collecting 
SDC.SellKeybind = {Input = 38, Label = "E"} --Keybind for selling moonshine 
SDC.StealKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 

--These are only in effect if you have SDC.Target set to "none"
SDC.StoreKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 
SDC.OldmanKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 
SDC.BarrelKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 
SDC.StillKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 
SDC.BottleKeybind = {Input = 38, Label = "E"} --Keybind for stealing parts 

---------------------------------------------------------------------------------
-------------------------------Barrel Configs------------------------------------
---------------------------------------------------------------------------------
SDC.BarrelModel = "prop_barrel_02a" --This is the prop used for the barrels portion
SDC.BarrelOffset = {vec3(0.0, 1.5, -0.5)} --Offset of the barrel being placed in front of ped (DONT TOUCH UNLESS YOU KNOW WHAT YOURE DOING!)
SDC.BarrelItem = "sdam_ebarrel" --This is the name of barrel item (The one provided is default)
SDC.MaxBarrelsSomeoneCanPlace = 20 --This is how many barrels a single player can place at a time
SDC.SpawnBarrelDist = 50 --How close/far you have to be for it to spawn the barrel
SDC.Barrel_HighlightedColor = {r = 3, g = 165, b = 252, a = 200} --The color that highlights the barrel when you open the menu for it

---------------------------------------------------------------------------------
-------------------------------Still Configs-------------------------------------
---------------------------------------------------------------------------------
SDC.WaterItem = {Name = "sdam_watergallon", PrecentageAdded = 15} --Water Item. Also how much it adds to the still
SDC.FuelItem = {Name = "sdam_firewood", PrecentageAdded = 15} --Fuel Item. Also how much it adds to the still
SDC.FWUsage = { --How much water/fuel is used per 5 seconds
    Water = 0.5, 
    Fuel = 1
}
SDC.MaxStillSomeoneCanPlace = 5 --How many still a single player can place at a time
SDC.SpawnStillDist = 75 --Distance for it to spawn/despawn in the still prop
SDC.Still_HighlightedColor = {r = 156, g = 111, b = 50, a = 200} --The color that highlights the still when you open the menu for it
SDC.Bottle_HighlightedColor = {r = 63, g = 143, b = 79, a = 200} --The color that highlights the bottle when you open the menu for it
SDC.EmptyBottleItem = "sdam_ejug" --The item name for the empty bottle used to collect shine when done
SDC.StillItem = { --All items used for the still parts
    StillMain = "sdam_stillpart1",
    StillPart2 = "sdam_stillpart2",
    StillPart3 = "sdam_stillpart3",
    StillCoil = "sdam_coil"
}
SDC.StillModel = { --All model names used for still parts
    StillMain = "prop_brum_sdc_stillpart_01",
    StillPart2 = "prop_brum_sdc_stillpart_02",
    StillPart3 = "prop_brum_sdc_stillpart_03",
    StillBottle = "brum_sdc_shine",
    StillFire = "prop_beach_fire"
}
SDC.StillOffsetFromPerson = {vec3(0.0, 1.5, -0.5)} --Offset used when placing a still down in front of ped (DONT TOUCH UNLESS YOU KNOW WHAT YOURE DOING!)
SDC.StillRotationFromPerson = vec3(0.0, 0.0, 0.0) --Rotation used when placing a still down in front of ped (DONT TOUCH UNLESS YOU KNOW WHAT YOURE DOING!)
SDC.StillOffsets = { --These are the offsets of the other parts (DONT TOUCH UNLESS YOU KNOW WHAT YOURE DOING!)
    Part2OffOfMain = {vec3(1.0, 0.1, 0.3)},
    Part3OffOfPart2 = {vec3(0.8, 0.0, 0.0)},
    BottleOffOfPart3 = {vec3(0.65, 0.0, -0.5)},
    FireOffMain = {vec3(0.0, 0.0, -0.33)},

    PedToggleOnOff = {vec3(0.0, -1.4, -0.5)},
    PedAddFuel = {vec3(0.0, -1.4, -0.5)},
    PedAddWater = {vec3(0.0, -0.8, -0.5)},
}

SDC.StillBreakOnPickup = { --If the still breaks when you pick it up (In percentage 0-100, SET TO 0 TO DISABLE)
    StillMain = 50, --If the main part of the still breaks when you pick it up (In percentage 0-100)
    StillPart2 = 30, --If the second part of the still breaks when you pick it up (In percentage 0-100)
    StillPart3 = 30, --If the third part of the still breaks when you pick it up (In percentage 0-100)
    StillCoil = 15, --If the coil part of the still breaks when you pick it up (In percentage 0-100)
}

SDC.CreateStillSmoke = { --All smoke particle configs
    Enabled = true, --If you want smoke to come out of still when turned on
    fxDict = "core", --Particile Dictionary Name
    fxName = "ent_amb_smoke_general", --Particile Name
    Scale = 0.5, --Scale of the particle
    DistToDraw = 150 --How close/far you have to be for it to create/delete the smoke particle
}
---------------------------------------------------------------------------------
-------------------------------Animation Configs---------------------------------
---------------------------------------------------------------------------------
SDC.AnimationTimes = { --All Animation Time Configs (All Of These Are In Seconds)
    ToggleStillOnOff = 5,
    AddingFuel = 5,
    AddingWater = 5,
    CreatingMash = 7,
    PickingFruit = 10,
    StealingPart = 10,
    CollectingBottles = 3,
    SellBottles = 15,
    DrinkingShine = 10,
}

---------------------------------------------------------------------------------
-------------------------------Icon Configs--------------------------------------
---------------------------------------------------------------------------------
SDC.Icons = { --All Icon Configs (Draw = true -Shows Icon | Draw = false -Doesnt Show Icon)
    Barrel_Empty = {Draw = true, DistanceToDraw = 5},
    Barrel_TimeLeft = {Draw = true, DistanceToDraw = 5},
    Barrel_Done = {Draw = true, DistanceToDraw = 5},
    Grab_Fruit = {Draw = true, DistanceToDraw = 10},
    Grab_Still = {Draw = true, DistanceToDraw = 7},
    Grab_Bottle = {Draw = true, DistanceToDraw = 5},
    Low_Water = {Draw = true, DistanceToDraw = 5},
    Low_Fuel = {Draw = true, DistanceToDraw = 5},
    Search_Truck = {Draw = true, DistanceToDraw = 5},
    Sell_Shine = {Draw = true, DistanceToDraw = 5},
    Chat = {Draw = true, DistanceToDraw = 5},
    Store = {Draw = true, DistanceToDraw = 5},
}

---------------------------------------------------------------------------------
-------------------------------Moonshine Configs---------------------------------
---------------------------------------------------------------------------------
SDC.EnableUseableItems = true --If you want the bottles of finished shine to be useable within this resource!
SDC.ShineEffectTime = 5 --How long the drunk effect lasts (In Mins)
SDC.AllMoonshines = { --All moonshine related configs
    --[[
        --New Shine Example/Template

        ["unique_id"] = {
            Label = "", --Label Of Shine
            ProductItem = "", --Item Name Of Final Product Out Of Still
            MashInfo = { --All Mash Configs for this shine
                ItemsNeeded = { --All Items Needed To Make Mash
                    --EX: {Name = "item_name", Label = "label_of_item", Amount = 0},
                },
                FermentTime = 0, --Time It Takes To Fully Ferment The Mash(In Minutes)
                CookTime = 0, --Time It Takes The Still To Fully Distill This Shine(In Minutes)
                ProductPerBarrel = 0, --How Many Of The Product Item Are Given When Fully Distilled
            },
        },
    ]]

    ["apple"] = {
        Label = "Apple Pie",
        ProductItem = "sdam_shine_apple",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_apple", Label = "Apple", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["pear"] = {
        Label = "Pear",
        ProductItem = "sdam_shine_pear",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_pear", Label = "Pear", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["peach"] = {
        Label = "Peach",
        ProductItem = "sdam_shine_peach",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_peach", Label = "Peach", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["cherries"] = {
        Label = "Cherry",
        ProductItem = "sdam_shine_cherries",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_cherries", Label = "Cherries", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["plum"] = {
        Label = "Plum",
        ProductItem = "sdam_shine_plum",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_plum", Label = "Plum", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["banana"] = {
        Label = "Banana Split",
        ProductItem = "sdam_shine_banana",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_banana", Label = "Banana", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["apricot"] = {
        Label = "Apricot",
        ProductItem = "sdam_shine_apricot",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_apricot", Label = "Apricot", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["mango"] = {
        Label = "Mango",
        ProductItem = "sdam_shine_mango",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_mango", Label = "Mango", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["strawberry"] = {
        Label = "Strawberry",
        ProductItem = "sdam_shine_strawberry",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_strawberry", Label = "Strawberry", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["blueberry"] = {
        Label = "Blueberry",
        ProductItem = "sdam_shine_blueberry",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_blueberry", Label = "Blueberry", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["grape"] = {
        Label = "Grape",
        ProductItem = "sdam_shine_grape",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_grape", Label = "Grape", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["pineapple"] = {
        Label = "Pineapple",
        ProductItem = "sdam_shine_pineapple",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_pineapple", Label = "Pineapple", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["orange"] = {
        Label = "Orange",
        ProductItem = "sdam_shine_orange",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_orange", Label = "Orange", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["raspberry"] = {
        Label = "Raspberry",
        ProductItem = "sdam_shine_raspberry",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_raspberry", Label = "Raspberry", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["blackberry"] = {
        Label = "Blackberry",
        ProductItem = "sdam_shine_blackberry",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_blackberry", Label = "Blackberry", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    },
    ["kiwi"] = {
        Label = "Kiwi",
        ProductItem = "sdam_shine_kiwi",
        MashInfo = {
            ItemsNeeded = {
                {Name = "sdam_kiwi", Label = "Kiwi", Amount = 10},
                {Name = "sdam_bagofcorn", Label = "Bag Of Corn", Amount = 1},
                {Name = "sdam_bagofsugar", Label = "Bag Of Sugar", Amount = 1},
                {Name = "sdam_bagofyeast", Label = "Bag Of Yeast", Amount = 1},
            },
            FermentTime = 30, --(In Minutes)
            CookTime = 10, --(In Minutes)
            ProductPerBarrel = 8,
        },
    }
}


---------------------------------------------------------------------------------
-------------------------------Fruit Plants Configs------------------------------
---------------------------------------------------------------------------------
SDC.SpawnFruitPlantDist = 50 --How close/far you have to be for it to spawn/delete the fruit plants
SDC.ShowTextDist = 1.5 --How close you have to be for it to show the text for a plant!
SDC.Plant_HighlightedColor = {r = 0, g = 255, b = 0, a = 200} --The color that highlights the bottle when you open the menu for it
SDC.PlantBlips = {Enabled = true, MinimapOnly = false, Sprite = 469, Color = 11, Size = 0.5} --Old man blip Configs
SDC.FruitPlants = { --All Fruit Plant Configs
    --[[
        --Example/Template Of A New Fruit Plant Entry

        ["unique_id"] = { --ID MUST MATCH THE ID IN SDC.MOONSHINES!
            Label = "", --Label Of The Fruit
            PlantModel = "", --Model Of The Plant
            PlantType = "", --Can be "bush" or "tree"
            PickIconOffset = {vec3(0.0, 0.0, 0.0)}, --Offset From Model To Draw Icon
            Harvest = {Item = "", Amount = 0}, --Harvest Item Configs (Item - Item Name, Amount - Amount Given Per Harvest)
            HarvestCooldownTime = 0, --Cooldown For Harvesting From That Specific Spawned Plant(In Minutes)
            PlantSpawns = { --All Plant Spawns For This Fruit
                --EX: vec4(0.0, 0.0, 0.0, 0.0),
            }
        },
    ]]

    ["apple"] = {
        Label = "Apple",
        PlantModel = "prop_tree_birch_05",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_apple", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(1436.7574, 923.2712, 100.9673, 147.9648),
            vec4(1442.0115, 921.2325, 99.8078, 35.5042),
            vec4(1437.1619, 916.7465, 100.7638, 126.2015),
            vec4(1431.0348, 921.3540, 102.1275, 347.2460),
            vec4(1436.3113, 929.2314, 101.0709, 316.9282),
        }
    },
    ["pear"] = {
        Label = "Pear",
        PlantModel = "prop_tree_maple_02",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_pear", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(1825.5361, 1824.8533, 67.8772, 51.3423),
            vec4(1823.0090, 1834.6877, 67.0022, 338.2083),
            vec4(1834.8138, 1827.1920, 66.8366, 214.8433),
            vec4(1830.6241, 1814.6328, 68.2772, 135.0412),
            vec4(1815.4633, 1824.0820, 68.8272, 25.8323),
        }
    },
    ["peach"] = {
        Label = "Peach",
        PlantModel = "prop_tree_birch_05",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_peach", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(2516.8538, 2441.3728, 47.8215, 297.5116),
            vec4(2521.3320, 2443.4827, 47.9396, 187.8882),
            vec4(2519.4934, 2435.3391, 48.7336, 145.9651),
            vec4(2512.3054, 2436.5957, 47.0299, 62.4948),
            vec4(2509.6670, 2447.2368, 46.0065, 348.9056),
        }
    },
    ["cherries"] = {
        Label = "Cherries",
        PlantModel = "prop_tree_maple_02",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_cherries", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(2962.4207, 3359.1895, 74.4897, 16.1629),
            vec4(2955.6343, 3352.2493, 77.7973, 158.9583),
            vec4(2967.8748, 3351.4143, 74.8039, 254.7588),
            vec4(2970.7263, 3364.4333, 70.9974, 30.9921),
            vec4(2954.9507, 3368.7661, 73.1226, 102.6347),
        }
    },
    ["plum"] = {
        Label = "Plum",
        PlantModel = "prop_tree_lficus_02",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_plum", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(3035.1399, 3765.3975, 71.0490, 17.2842),
            vec4(3045.7070, 3758.3516, 72.4875, 197.0002),
            vec4(3029.8892, 3755.1064, 70.9308, 68.8510),
            vec4(3023.5952, 3771.3899, 69.4770, 347.3902),
            vec4(3037.6489, 3775.5059, 70.8297, 256.1208),
        }
    },
    ["banana"] = {
        Label = "Banana",
        PlantModel = "prop_tree_lficus_02",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_banana", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(2665.5693, 4044.7441, 52.1182, 80.8206),
            vec4(2672.6792, 4033.0271, 53.3154, 182.4207),
            vec4(2652.6504, 4039.5027, 51.0895, 27.0548),
            vec4(2652.9844, 4058.2832, 47.7619, 350.0412),
            vec4(2675.0527, 4062.0674, 48.6107, 275.1107),
        }
    },
    ["apricot"] = {
        Label = "Apricot",
        PlantModel = "prop_tree_olive_cr2",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_apricot", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(2683.2458, 4587.6606, 41.2059, 28.4039),
            vec4(2692.5022, 4576.5083, 41.3919, 177.5840),
            vec4(2693.9817, 4558.0200, 41.3358, 164.7284),
            vec4(2709.1121, 4567.8647, 41.4412, 313.2038),
            vec4(2705.8025, 4590.3193, 41.4987, 348.5663),
        }
    },
    ["mango"] = {
        Label = "Mango",
        PlantModel = "prop_tree_birch_05",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_mango", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(1752.2069, 4757.9502, 41.5774, 121.4543),
            vec4(1750.1720, 4752.3843, 41.5631, 112.2798),
            vec4(1746.3944, 4759.2275, 41.6604, 23.6285),
            vec4(1753.9573, 4764.6353, 41.5638, 288.1976),
            vec4(1757.7295, 4756.5332, 41.4917, 178.4185),
        }
    },
    ["orange"] = {
        Label = "Orange",
        PlantModel = "prop_tree_birch_05",
        PlantType = "tree", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_orange", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(1563.0088, 4525.6572, 52.8116, 143.3948),
            vec4(1562.9558, 4519.4917, 53.1498, 144.1335),
            vec4(1556.7439, 4525.0112, 54.4241, 32.2910),
            vec4(1561.1399, 4531.2744, 52.7924, 310.2680),
            vec4(1568.6331, 4527.3896, 50.9837, 217.1041),
        }
    },
    ["strawberry"] = {
        Label = "Strawberry",
        PlantModel = "prop_bush_neat_07",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_strawberry", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(1196.8280, 4354.6997, 44.5251, 64.9384),
            vec4(1192.3762, 4352.5771, 43.9564, 19.7735),
            vec4(1193.9186, 4358.8296, 44.8400, 321.8188),
            vec4(1199.4567, 4358.9419, 45.1326, 238.0778),
            vec4(1201.0590, 4352.2871, 44.4141, 172.6236),
        }
    },
    ["blueberry"] = {
        Label = "Blueberry",
        PlantModel = "prop_bush_lrg_01b",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_blueberry", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(767.3455, 4385.4844, 96.5908, 33.4477),
            vec4(764.5537, 4390.6704, 98.8673, 41.1530),
            vec4(761.7530, 4383.7642, 94.0870, 232.2007),
            vec4(771.3297, 4378.6235, 94.2352, 263.9149),
            vec4(773.2363, 4390.6138, 94.4147, 93.1830),
        }
    },
    ["pineapple"] = {
        Label = "Pineapple",
        PlantModel = "h4_prop_palmeto_sap_ac",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 0.5)},
        Harvest = {Item = "sdam_pineapple", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(734.7170, 3335.9519, 50.9485, 156.6151),
            vec4(732.7744, 3330.9871, 51.3285, 329.0120),
            vec4(739.2589, 3334.6721, 48.5336, 19.9054),
            vec4(735.0052, 3341.2437, 51.6200, 87.0733),
            vec4(730.8478, 3337.3411, 54.0226, 156.5994),
        }
    },
    ["raspberry"] = {
        Label = "Raspberry",
        PlantModel = "prop_bush_neat_06",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_raspberry", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(-62.4306, 2698.4365, 71.2712, 96.7378),
            vec4(-59.9356, 2694.1494, 71.7103, 219.6507),
            vec4(-57.6726, 2700.4937, 72.1372, 15.8079),
            vec4(-63.6882, 2704.1150, 71.0120, 89.3706),
            vec4(-68.3838, 2697.1436, 70.1629, 192.3309),
        }
    },
    ["blackberry"] = {
        Label = "Blackberry",
        PlantModel = "prop_bush_neat_06",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_blackberry", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(-714.9193, 2139.3035, 111.6180, 165.8680),
            vec4(-719.1316, 2139.6509, 109.8001, 248.6990),
            vec4(-712.1302, 2143.9043, 112.5945, 12.1118),
            vec4(-709.3371, 2137.8511, 114.2433, 191.1599),
            vec4(-714.8113, 2133.8792, 111.9791, 86.5853),
        }
    },
    ["kiwi"] = {
        Label = "Kiwi",
        PlantModel = "prop_bush_neat_01",
        PlantType = "bush", --Can be "bush" or "tree"
        PickIconOffset = {vec3(0.0, 0.0, 1.0)},
        Harvest = {Item = "sdam_kiwi", Amount = 5},
        HarvestCooldownTime = 5, --(In Minutes)
        PlantSpawns = {
            vec4(-958.6483, 1495.6476, 263.9010, 194.4915),
            vec4(-954.7008, 1493.8037, 266.0304, 141.5432),
            vec4(-960.7670, 1491.2383, 262.1305, 73.8650),
            vec4(-962.8837, 1499.4365, 262.6989, 295.5804),
            vec4(-956.8438, 1500.1666, 265.5044, 242.9818),
        }
    },
}

---------------------------------------------------------------------------------
-------------------------------Selling Configs-----------------------------------
---------------------------------------------------------------------------------
SDC.SellingEnabled = true --If you want the selling portion of this resource to be enabled
SDC.MinMaxSellAmount = {1, 10} --The Minimum/Maximum amount of moonshine that can be sold at a time
SDC.BuyerBuysRandomAmount = true --IF you set this to true the buyer will buy a random amount of the sell amount input
SDC.ChancesTheBuyerIsFake = 50 --Chance that the buyer is a fake and sets up the seller (Must Be Within 0-100)
SDC.MaxSellMissionTime = 20 --The max amount of time a Sell Mission can last before it auto ends (In Minutes)
SDC.SellingCooldown = 15 --The cooldown for selling moonshine (In Minutes)
SDC.PreWarnCopsAboutSale = true --If you want it to warn cops of a possible sale (only works if the buyer is a fake)
SDC.SpawnBuyerDist = 75 --How close you have to be for it to spawn the buyer ped in (MUST keep this a lower distance then SDC.EndSaleDist)
SDC.SellToBuyerDist = 1.5 --How close you have to be to sell to the buyer
SDC.EndSaleDist = 110 --How far you have to get from the buyer before it cancels the mission (Note this only goes into effect after the ped is spawned)
SDC.BuyerBlip = {Sprite = 108, Color = 25, Size = 1.0} --Blip Configs for the buyer

SDC.SortSaleDemandsTimer = 10 --How often the server will resort all the moonshines for their respective demands (Keep between 10-30)(In Seconds)
SDC.SalePricesPerDemand = { --This is amount per bottle for the respective demand
    High = 5000,
    Medium = 3000,
    Low = 1000
}

SDC.SaleNotificationForCops = { --Sale Notification Configs
    Enabled = true, --If you want it to use the notification configs from my resource
    PreWarnBlip = {Enabled = true, Color = 1, Radius = 75.0}, --Pre warn alert blip for cops  
    SaleBlip = {Enabled = true, Sprite = 108, Color = 1, Size = 1.0},  --Sale alert blip for cops
}

SDC.PossibleBuyerLocs = { --All possible buyer locations
    --EX: vec4(0.0, 0.0, 0.0, 0.0)
    vec4(794.0751, 2163.1501, 53.0929, 154.7812),
    vec4(-1100.4097, 2722.3452, 18.8000, 39.9376),
    vec4(-35.5071, 2871.6375, 59.6102, 161.6640),
    vec4(635.4007, 2774.8286, 42.0053, 273.8944),
    vec4(1400.7546, 2169.9919, 97.8905, 267.9627),
    vec4(1915.7527, 3909.3450, 33.4416, 236.0293),
    vec4(-85.1943, 6402.3945, 31.6405, 227.8958),
    vec4(58.6548, 6332.8120, 31.3767, 303.1148),
    vec4(9.6368, 6506.2305, 31.5276, 228.5297),
    vec4(-769.0606, 5597.2764, 33.6119, 170.1512),
    vec4(-2173.8784, 4282.2012, 49.1228, 243.0573),
    vec4(-3155.6404, 1125.3228, 20.8582, 65.1742),
    vec4(-3047.4915, 589.9048, 7.7894, 21.2684),
    vec4(-2213.4890, -371.2492, 13.3203, 47.1522),
    vec4(-1480.4763, -335.0989, 45.9100, 136.6989),
    vec4(-663.4866, -172.2405, 37.6765, 124.2109),
    vec4(-560.1180, -872.1201, 27.0483, 182.9012),
    vec4(-1083.2435, -1262.1439, 5.5925, 300.1996),
    vec4(-1346.1741, -961.7969, 9.7028, 206.0063),
    vec4(38.2977, -1026.5983, 29.5682, 84.5664),
    vec4(494.0270, -729.5840, 24.8849, 262.5582),
    vec4(888.9669, -1028.2263, 35.1137, 5.1740),
    vec4(814.9784, -109.4921, 80.6024, 61.8345)
}
SDC.BuyerPeds = { --All buyer ped models
    "a_m_m_farmer_01",
    "a_f_o_soucent_02",
    "a_f_y_tourist_02",
    "a_m_m_hillbilly_01",
    "a_m_m_business_01",
    "a_m_y_hippy_01"
}
---------------------------------------------------------------------------------
-------------------------------Old Man Configs-----------------------------------
---------------------------------------------------------------------------------
SDC.OldManModel = "cs_old_man2" --Old Man Ped Model
SDC.OldManBlip = {Enabled = true, Sprite = 387, Color = 13, Size = 0.7} --Old man blip Configs
SDC.SpawnOldManDist = 50 --How close/far you have to be for it spawn/despawn the old man ped
SDC.OldManSpawns = { --All old man spawn locations (will select random location out of table on every server restart)
    --EX: vec4(0.0, 0.0, 0.0, 0.0)
    vec4(281.7625, 6789.2139, 15.6951, 258.4687),
    vec4(1657.9058, -55.7143, 167.1683, 134.3444),
    vec4(1525.5000, 1710.6536, 110.0028, 352.1483),
    vec4(-3188.7153, 1071.8101, 20.8407, 51.9629),
    vec4(-2079.8516, 2609.9280, 3.0840, 93.7193)
}

---------------------------------------------------------------------------------
----------------------------Part Collecting Configs------------------------------
---------------------------------------------------------------------------------
SDC.PartCollectionPed = "a_m_m_hillbilly_02" --Ped Model used for the peds protecting the truck
SDC.PartCollectionWeapons = { --All possible weapons that can be given to the peds protecting the truck
    "weapon_revolver",
    "weapon_pistol",
    "weapon_pumpshotgun",
    "weapon_sawnoffshotgun"
} 
SDC.PartCollectionVehicle = { --Part Collection Vehicle Configs 
    Model = "ratloader", --Model Of Vehicle
    SearchOffset = {vec3(0.0, -3.5, 0.0)} --Offset for searching vehicle for the part
}
SDC.CollectPartDist = 1.5 --How close you have to be to the searching vehicle offset to search for part
SDC.SpawnPCVehicleDist = 110 --How close you have to be for it to spawn the vehicle (KEEP DISTANCE BELOW SDC.EndMissionDist)
SDC.SpawnPCPedDist = 45 --How close you have to be for it to spawn the peds (KEEP DISTANCE BELOW SDC.SpawnPCVehicleDist)
SDC.EndMissionDist = 160 --How far you have to get for it to forcefully end the mission
SDC.MaxPCMissionTime = 15 --The max amount of time a Part Collection Mission can last before it auto ends (In Minutes)
SDC.PCMissionCooldown = 15 --The cooldown time for a Part Collection Mission (In Minutes)
SDC.PCBlip = {Sprite = 119, Color = 1, Size = 1.0} --Blip Configs For Part Collection
SDC.PartCollectionSpawns = { --All possible Part Collection Mission spawns
    --[[
        --Example/Template for new entry

        {
            VehicleSpawn = vec4(0.0, 0.0, 0.0, 0.0), --Coords for the spawned vehicle
            PedSpawns = { --All Ped Spawns (Add as many as you want)
                --EX: vec4(0.0, 0.0, 0.0, 0.0),
                vec4(0.0, 0.0, 0.0, 0.0),
            }
        }
    ]]

    {
        VehicleSpawn = vec4(990.7823, 4345.9067, 44.2117, 323.0181),
        PedSpawns = {
            vec4(983.4960, 4352.0161, 44.3529, 51.1592),
            vec4(992.1171, 4361.8862, 46.0535, 313.9588),
            vec4(1017.7629, 4354.1973, 42.1975, 236.4679),
            vec4(1016.5353, 4333.1001, 41.8113, 164.3900)
        }
    },
    {
        VehicleSpawn = vec4(-2699.2312, 2383.5212, 2.9444, 199.7338),
        PedSpawns = {
            vec4(-2688.9478, 2386.5273, 3.6803, 286.0581),
            vec4(-2692.1204, 2373.0837, 5.1692, 112.9364),
            vec4(-2708.8855, 2373.0918, 2.7115, 52.2665),
            vec4(-2711.6960, 2387.8296, 1.4140, 327.9015),
        }
    },
    {
        VehicleSpawn = vec4(-3065.1494, 3396.1602, 6.4890, 266.8820),
        PedSpawns = {
            vec4(-3053.9490, 3392.6614, 8.3309, 254.4406),
            vec4(-3057.5359, 3405.5706, 6.4310, 31.0826),
            vec4(-3079.4539, 3404.7339, 5.2122, 126.5601),
            vec4(-3072.3147, 3390.5356, 6.4580, 233.0540),
        }
    },
    {
        VehicleSpawn = vec4(-1647.3499, 4594.8413, 44.2359, 314.1386),
        PedSpawns = {
            vec4(-1637.6295, 4605.4526, 44.8076, 319.0470),
            vec4(-1652.9236, 4605.3433, 46.1069, 115.9065),
            vec4(-1660.3104, 4588.8208, 44.6638, 187.4906),
            vec4(-1646.7340, 4580.9761, 42.6063, 280.3236),
        }
    },
    {
        VehicleSpawn = vec4(745.5210, 2803.4419, 65.4537, 119.6735),
        PedSpawns = {
            vec4(733.4387, 2797.1023, 64.6474, 117.7506),
            vec4(745.5410, 2792.6716, 66.7679, 226.2430),
            vec4(760.1598, 2805.2271, 64.6862, 317.9216),
            vec4(750.8424, 2814.8259, 62.5669, 53.8600),
        }
    },
    {
        VehicleSpawn = vec4(1819.8549, 1393.4535, 119.1252, 208.1368),
        PedSpawns = {
            vec4(1825.8718, 1377.5205, 117.8474, 204.7197),
            vec4(1838.5427, 1385.0885, 116.4078, 299.6308),
            vec4(1830.2844, 1404.7946, 116.4814, 45.8975),
            vec4(1816.4927, 1398.1180, 118.8560, 151.8836),
        }
    },
}


---------------------------------------------------------------------------------
-------------------------------Stores Configs------------------------------------
---------------------------------------------------------------------------------
SDC.SpawnStorePedDist = 50 --How close/far you have to be for it to spawn/despawn the Store Ped
SDC.EnableStores = true --If you want the stores that come with resource to be enabled
SDC.Stores = { --All Store configs
    --[[
        --Exmaple/Template For New Entry

        {
            Label = "", --Label Of Store
            PedModel = "", --Model Of Ped For Store
            Coords = vec4(0.0, 0.0, 0.0, 0.0), --Coords For The Store Ped
            Blip = {Enabled = false, Sprite = 59, Color = 10, Size = 0.7}, --Blip Configs For Stores
            Products = { --All Product Configs
                --EX: {Label = "item_label", Item = "item_name", Price = 0}, 
            }
        }
    ]]

    {
        Label = "Farmers Market",
        PedModel = "a_m_m_eastsa_01",
        Coords = vec4(418.0383, 6470.7705, 28.8122, 47.9667),
        Blip = {Enabled = true, Sprite = 59, Color = 23, Size = 0.7},
        Products = {
            {Label = "Bag of Corn", Item = "sdam_bagofcorn", Price = 10},
            {Label = "Bag of Sugar", Item = "sdam_bagofsugar", Price = 10},
            {Label = "Bag of Yeast", Item = "sdam_bagofyeast", Price = 10},
            {Label = "Gallon of Water", Item = "sdam_watergallon", Price = 5},
            {Label = "Empty Barrel", Item = "sdam_ebarrel", Price = 100},
            {Label = "Empty Jug", Item = "sdam_ejug", Price = 50},
        }
    },
    {
        Label = "Log Market",
        PedModel = "a_m_m_farmer_01",
        Coords = vec4(-579.6486, 5368.4819, 70.2837, 346.6604),
        Blip = {Enabled = true, Sprite = 59, Color = 10, Size = 0.7},
        Products = {
            {Label = "Firewood", Item = "sdam_firewood", Price = 10},
        }
    }
}
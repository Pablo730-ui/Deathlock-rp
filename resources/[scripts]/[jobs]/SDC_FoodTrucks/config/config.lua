SDC = {}

---------------------------------------------------------------------------------
-------------------------------Important Configs---------------------------------
---------------------------------------------------------------------------------
SDC.Target = "qb-target" --Can be one of these (If "none" is selected it will use TextUi): ["qb-target","ox_target","none"]
SDC.FoodTruckMenu = "F2" --This is the default keybind to open the menu
SDC.HighlightFoodTruckInMenu = { --Highlight Food Truck While In Menu Configs
    Enabled = true, --If you want this Enabled
    Color = {r = 255, g = 255, b = 255, a = 200} --Color for the highlight
}

SDC.MenuPosition = "top-right" --Where you want the main food truck menu to show up: ['top-left', 'top-right', 'bottom-left', 'bottom-right']

SDC.MaxTrucksPerPerson = 3 --How many food trucks one player can own at a time!

SDC.AllowAnyoneToAccessManagementStuff = false --Enabled this only if you want everyone to have access to everything for job tied trucks

---------------------------------------------------------------------------------
-------------------------------Keybind Configs-----------------------------------
---------------------------------------------------------------------------------
SDC.StationKeys = { --Keybinds for the stations in the truck
    Exit = {Input = "INPUT_DETONATE", InputNum = 47},
    ChangeStationNext = {Input = "INPUT_CELLPHONE_RIGHT", InputNum = 175},
    ChangeStationPrev = {Input = "INPUT_CELLPHONE_LEFT", InputNum = 174},
    OpenCookingMenu = {Input = "INPUT_PICKUP", InputNum = 38},
    OpenFoodPrepMenu = {Input = "INPUT_PICKUP", InputNum = 38},
    OpenDrinkPrepMenu = {Input = "INPUT_PICKUP", InputNum = 38},
    OpenRegisterMenu = {Input = "INPUT_PICKUP", InputNum = 38},
    OpenAICustomerOrder = {Input = "INPUT_VEH_HEADLIGHT", InputNum = 74},
}

SDC.PlaceTableKeys = { --Keys for placing tables
    Exit = {Input = "INPUT_DETONATE", InputNum = 47},
    Place = {Input = "INPUT_PICKUP", InputNum = 38},
}


SDC.RegisterInteractDist = 1.5 --How close you have to be to interact with register (Only for TEXTUI)
SDC.RegisterKeybind = {Input = 38, Label = "E"} --Keybind for opening a register

SDC.TableInteractDist = 2.2 --How close you have to be to interact with tables (Only for TEXTUI)
SDC.TableKeybind = {Input = 38, Label = "E"} --Keybind for sitting at a table

SDC.DealershipInteractDist = 1.5 --How close you have to be to interact with dealership (Only for TEXTUI)
SDC.DealershipKeybind = {Input = 38, Label = "E"} --Keybind for talking to the dealership person

SDC.StoreInteractDist = 1.5 --How close you have to be to interact with a store ped (Only for TEXTUI)
SDC.StoreKeybind = {Input = 38, Label = "E"} --Keybind for talking to a store ped
---------------------------------------------------------------------------------
-------------------------------Truck Type Configs--------------------------------
---------------------------------------------------------------------------------
SDC.DefaultGarage = "pillboxgarage" --This is for QBCore
SDC.FTruckTypes = {
    --[[ Example

    !!!!!!!!!!!!! NOTE: If you are adding a new model to the config make sure you also add that model to SDC.FTFoodExtras & SDC.TruckAddons

    ["model_name"] = { --Truck Model
        TruckLabel = "LABEL_FOR_TRUCK", --Label For The Truck Model
        TableProp = {AmountPerTruck = 2, Model = "prop_model"}, --Table Prop Settings For This Specific Model
        GrillProp = {Enabled = true, Model = "prop_model", Offset = {vec3(0.0, 0.0, 0.0)}, Rotation = vec3(0.0, 0.0, 0.0)}, --Grill Prop Settings For This Specific Model
        RegisterProp = {Enabled = true, Model = "prop_model", Offset = {vec3(0.0, 0.0, 0.0)}, Rotation = vec3(0.0, 0.0, 0.0)}, --Register Prop Settings For This Specific Model
        DoorIDs = {2, 3, 5}, --All Door IDs Opened/Closed when pulling Handbrake!
        VentParticles = {Enabled = true, DistanceToSee = 45, Offset = {vec3(0.0, 0.0,, 0.0)}}, --All Vent Particle Settings
        AIPedPlacement = {Offset = {vec3(0.0, 0.0, 0.0)}}, --AI Ped Placement Offset
        StationOffsets = { --All Offsets For Stations And Entering Truck
            EnterStations = {Offset = {vec3(0.0, -5.5, 0.0)}}, --Offset For Entering Truck Coords
            Grill = {Offset = {vec3(-0.5, -5.5, 0.05)}, Rotation = vec3(0.0, 0.0, 140.0)}, --Grill Station Offset For Ped
            FoodPrep = {Offset = {vec3(-0.2, -0.8, 0.7)}, Rotation = vec3(0.0, 0.0, 90.0)}, --Food Prep Station Offset For Ped
            DrinkPrep = {Offset = {vec3(-0.2, -2.6, 0.7)}, Rotation = vec3(0.0, 0.0, 90.0)}, --Drink Prep Station Offset For Ped
            Register = {Offset = {vec3(0.25, -0.5, 0.7)}, Rotation = vec3(0.0, 0.0, -90.0)} --Register Station Offset For Ped
        },
        Liveries = { --All livery setups for this model
            ["0"]  = { --Livery Number
                Label = "LABEL_FOR_LIVERY",
                Price = 0 -- Price of truck's livery at dealer
                JobRestricted = { --If you want the truck to be locked down by a job (Leave table empty for non job locked)
                    --EX: {Job = "job_name", GradeNeeded = 0}, --Any grade that is this grade and higher has access to the truck/buying
                    
                },
                AllowedAddons = { --List of all allowed addons
                    --EX: "addon_identifier" --You Can find the identifiers in SDC.TruckAddons
                    
                },
            },
        }
    },
    ]]

    ["taco2"] = {
        TruckLabel = "Bravado Food Truck",
        TableProp = {AmountPerTruck = 2, Model = "prop_picnictable_01", Offset = {vec3(-0.8, 1.2, 0.0)}, Rotation = vec3(0.0, 90.0, 90.0)},
        GrillProp = {Enabled = true, Model = "prop_bbq_1", Offset = {vec3(-0.9, -6.0, 0.0)}, Rotation = vec3(0.0, 0.0, 140.0)},
        RegisterProp = {Enabled = true, Model = "prop_till_02", Offset = {vec3(0.7, -0.5, 0.6)}, Rotation = vec3(0.0, 0.0, -90.0)},
        DoorIDs = {2, 3, 5},
        VentParticles = {Enabled = true, DistanceToSee = 45, Offset = {vec3(-1.0, -1.7, 0.8)}},
        AIPedPlacement = {Offset = {vec3(1.5, -1.4, -0.8)}},
        StationOffsets = {
            EnterStations = {Offset = {vec3(0.0, -5.5, 0.0)}},
            Grill = {Offset = {vec3(-0.5, -5.5, 0.05)}, Rotation = vec3(0.0, 0.0, 140.0)},
            FoodPrep = {Offset = {vec3(-0.2, -0.8, 0.7)}, Rotation = vec3(0.0, 0.0, 90.0)},
            DrinkPrep = {Offset = {vec3(-0.2, -2.6, 0.7)}, Rotation = vec3(0.0, 0.0, 90.0)},
            Register = {Offset = {vec3(0.25, -0.5, 0.7)}, Rotation = vec3(0.0, 0.0, -90.0)}
        },
        Liveries = {
            ["0"]  = {
                Label = "Burgershot",
                Price = 150000,
                AllowAISales = true,
                JobRestricted = {
                    {Job = "burgershot", GradeNeeded = 0}
                },
                AllowedAddons = {"tv", "outlight", "outlight2", "outlight3", "outlight4", "flagpole", "americanflag", "dartboard"},
            },
            ["1"]  = {
                Label = "Chihuahua Hotdog",
                Price = 75000,
                AllowAISales = true,
                JobRestricted = {},
                AllowedAddons = {"tv", "outlight", "outlight2", "outlight3", "outlight4", "flagpole", "americanflag", "dartboard"},
            },
            ["2"]  = {
                Label = "Beefy Bills",
                Price = 75000,
                AllowAISales = true,
                JobRestricted = {},
                AllowedAddons = {"tv", "outlight", "outlight2", "outlight3", "outlight4", "flagpole", "americanflag", "dartboard"},
            },
            ["3"]  = {
                Label = "Shark Bites",
                Price = 75000,
                AllowAISales = true,
                JobRestricted = {},
                AllowedAddons = {"tv", "outlight", "outlight2", "outlight3", "outlight4", "flagpole", "americanflag", "dartboard"},
            },
            ["4"]  = {
                Label = "Taco Libre",
                Price = 75000,
                AllowAISales = true,
                JobRestricted = {},
                AllowedAddons = {"tv", "outlight", "outlight2", "outlight3", "outlight4", "flagpole", "americanflag", "dartboard"},
            }
        }
    },
}

--This below is for all the food entries you would like for each truck (it goes by livery)
--
--Anything in the "Grill" section does not need to be a real item, FoodPrep & DrinkPrep need to be real items so it gives the real item when done
--(All time configs are done in seconds)
SDC.FTFoodExtras = {
    --[[EXAMPLE
        ["model_name"] = { --Name of truck model listed above
            [0] = { --Livery Number
                ColdItems = {
                    --EX: ["item_name"] = {Label = "ITEM_LABEL"},

                },
                Grill = {--All Food That Can Be Made On Grill
                    --Ex: ["item_name"] = {Label = "UNCOOKED_ITEM_LABEL", Cooked = {Label = "COOKED_ITEM_LABEL", Item = "item_name"}, CookTime = 10}, --CookTime Is In Seconds, Cooked.Label is the label of the cooked item, Cooked.Item is the item name of the cooked version

                },
                FoodPrep = { --All Food That Can Be Made At Food Prep
                    --EX: ["item_name"] = {Label = "ITEM_LABEL", MakeTime = 5, Category = "entree", SellPrice = 30, NeededToMake = {["item_name"] = 1}, --SellPrice is how much the item sells for in register, MakeTime Is In Seconds, Category Can Be "entree" or "side", NeededToMake Is all grill items needed to make
                
                },
                DrinkPrep = { --All Drinks That Can Be Made At Drink Prep
                    --Ex: ["item_name"] = {Label = "ITEM_LABEL", SellPrice = 5, PourTime = 10, NeededInStorage = false}, --SellPrice is how much the item sells for in register, PourTime Is In Seconds, NeededInStorage Is if the item is required to be in storage (use if you want them to buy ther drink from store)
                
                }
            },
        },

    ]]


    ["taco2"] = {
        ["0"] = {
            ColdItems = {
                ["sdft_lettuce"] = {Label = "Lettuce"},
                ["sdft_cheese"] = {Label = "Cheese"},
                ["sdft_tomato"] = {Label = "Tomato"},
            },
            Grill = {
                ["sdft_patty"] = {Label = "Raw Patty", Cooked = {Label = "Cooked Patty", Item = "sdft_patty_cooked"}, CookTime = 10},
                ["sdft_vpatty"] = {Label = "Raw Veggie Patty", Cooked = {Label = "Cooked Veggie Patt", Item = "sdft_vpatty_cooked"}, CookTime = 10},
                ["sdft_rawfries"] = {Label = "Raw Fries", Cooked = {Label = "Cooked Fries", Item = "sdft_fries_cooked"}, CookTime = 5},
                ["sdft_bun"] = {Label = "Burger Bun", Cooked = {Label = "Toasted Bun", Item = "sdft_bun_cooked"}, CookTime = 3},
                ["sdft_hoagie"] = {Label = "Hoagie Buns", Cooked = {Label = "Toasted Hoagie", Item = "sdft_hoagie_cooked"}, CookTime = 4},
            },
            FoodPrep = {
                ["sdft_meatfree"] = {Label = "Meat Free Burger", MakeTime = 5, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_vpatty_cooked"] = 1, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1}},
                ["sdft_heartstopper"] = {Label = "Heartstopper Burger", MakeTime = 8, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 4, ["sdft_bun_cooked"] = 2, ["sdft_cheese"] = 3}},
                ["sdft_bleeder"] = {Label = "Bleeder Burger", MakeTime = 4, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 1, ["sdft_bun_cooked"] = 2, ["sdft_cheese"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1}},
                ["sdft_moneyshot"] = {Label = "Moneyshot Burger", MakeTime = 4, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_cheese"] = 1, ["sdft_lettuce"] = 2, ["sdft_tomato"] = 1}},
                ["sdft_torpedo"] = {Label = "Torpedo Burger", MakeTime = 5, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_hoagie_cooked"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_fries"] = {Label = "Fries", MakeTime = 5, Category = "side", SellPrice = 10, NeededToMake = {["sdft_fries_cooked"] = 1}},
            },
            DrinkPrep = {
                ["ecola"] = {Label = "eCola", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sprunk"] = {Label = "Sprunk", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sdft_milkshake"] = {Label = "Milkshake", SellPrice = 10, PourTime = 7, NeededInStorage = false},
                ["water_bottle"] = {Label = "Bottled Water", SellPrice = 5, PourTime = 3, NeededInStorage = true},
            }
        },
        ["1"] = {
            ColdItems = {
                ["sdft_cheesesauce"] = {Label = "Cheese Sauce"}
            },
            Grill = {
                ["sdft_dog"] = {Label = "Raw Dog", Cooked = {Label = "Cooked Dog", Item = "sdft_dog_cooked"}, CookTime = 10},
                ["sdft_sausage"] = {Label = "Raw Sausage", Cooked = {Label = "Cooked Sausage", Item = "sdft_sausage_cooked"}, CookTime = 10},
                ["sdft_rawpretzel"] = {Label = "Raw Pretzel", Cooked = {Label = "Cooked Pretzel", Item = "sdft_pretzel_cooked"}, CookTime = 7},
                ["sdft_minipretzel"] = {Label = "Raw Mini Pretzel", Cooked = {Label = "Cooked Mini Pretzel", Item = "sdft_minipretzel_cooked"}, CookTime = 5},
                ["sdft_nuts"] = {Label = "Nuts", Cooked = {Label = "Roasted Nuts", Item = "sdft_nuts_cooked"}, CookTime = 5},
                ["sdft_hotdogbun"] = {Label = "Hotdog Bun", Cooked = {Label = "Toasted Hotdog Bun", Item = "sdft_hotdogbun_cooked"}, CookTime = 3},
            },
            FoodPrep = {
                ["sdft_hotdog"] = {Label = "Hotdog", MakeTime = 8, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_dog_cooked"] = 1, ["sdft_hotdogbun_cooked"] = 1}},
                ["sdft_sausagedog"] = {Label = "Sausage Dog", MakeTime = 8, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_sausage_cooked"] = 1, ["sdft_hotdogbun_cooked"] = 1}},
                ["sdft_pretzel"] = {Label = "Salted Pretzel", MakeTime = 6, Category = "entree", SellPrice = 10, NeededToMake = {["sdft_pretzel_cooked"] = 1}},
                ["sdft_minipretzels"] = {Label = "3 Mini Pretzels", MakeTime = 4, Category = "entree", SellPrice = 7, NeededToMake = {["sdft_minipretzel_cooked"] = 3}},
                ["sdft_roastednuts"] = {Label = "Roasted Nuts", MakeTime = 4, Category = "entree", SellPrice = 10, NeededToMake = {["sdft_nuts_cooked"] = 2}},
            },
            DrinkPrep = {
                ["ecola"] = {Label = "eCola", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sprunk"] = {Label = "Sprunk", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["water_bottle"] = {Label = "Bottled Water", SellPrice = 5, PourTime = 3, NeededInStorage = true},
            }
        },
        ["2"] = {
            ColdItems = {
                ["sdft_lettuce"] = {Label = "Lettuce"},
                ["sdft_cheese"] = {Label = "Cheese"},
                ["sdft_tomato"] = {Label = "Tomato"},
            },
            Grill = {
                ["sdft_patty"] = {Label = "Raw Patty", Cooked = {Label = "Cooked Patty", Item = "sdft_patty_cooked"}, CookTime = 10},
                ["sdft_bacon"] = {Label = "Raw Bacon", Cooked = {Label = "Cooked Bacon", Item = "sdft_bacon_cooked"}, CookTime = 10},
                ["sdft_rawfries"] = {Label = "Raw Fries", Cooked = {Label = "Cooked Fries", Item = "sdft_fries_cooked"}, CookTime = 5},
                ["sdft_bun"] = {Label = "Burger Bun", Cooked = {Label = "Toasted Bun", Item = "sdft_bun_cooked"}, CookTime = 3},
            },
            FoodPrep = {
                ["sdft_burger"] = {Label = "Burger", MakeTime = 8, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_patty_cooked"] = 1, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 1}},
                ["sdft_megacheese"] = {Label = "Megacheese", MakeTime = 8, Category = "entree", SellPrice = 25, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_cheese"] = 4}},
                ["sdft_doubleburger"] = {Label = "Double Burger", MakeTime = 8, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 2}},
                ["sdft_kingsizeburger"] = {Label = "Kingsize Burger", MakeTime = 9, Category = "entree", SellPrice = 35, NeededToMake = {["sdft_patty_cooked"] = 3, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 2, ["sdft_tomato"] = 1, ["sdft_cheese"] = 3}},
                ["sdft_baconburger"] = {Label = "Bacon Burger", MakeTime = 8, Category = "entree", SellPrice = 35, NeededToMake = {["sdft_patty_cooked"] = 2, ["bacon"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 1}},
                ["sdft_fries"] = {Label = "Fries", MakeTime = 5, Category = "side", SellPrice = 10, NeededToMake = {["sdft_fries_cooked"] = 1}},
            },
            DrinkPrep = {
                ["ecola"] = {Label = "eCola", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sprunk"] = {Label = "Sprunk", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["water_bottle"] = {Label = "Bottled Water", SellPrice = 5, PourTime = 3, NeededInStorage = true},
            }
        },
        ["3"] = {
            ColdItems = {
                ["sdft_lettuce"] = {Label = "Lettuce"},
                ["sdft_cheese"] = {Label = "Cheese"},
                ["sdft_tomato"] = {Label = "Tomato"},
            },
            Grill = {
                ["sdft_patty"] = {Label = "Raw Patty", Cooked = {Label = "Cooked Patty", Item = "sdft_patty_cooked"}, CookTime = 10},
                ["sdft_bacon"] = {Label = "Raw Bacon", Cooked = {Label = "Cooked Bacon", Item = "sdft_bacon_cooked"}, CookTime = 10},
                ["sdft_rawfries"] = {Label = "Raw Fries", Cooked = {Label = "Cooked Fries", Item = "sdft_fries_cooked"}, CookTime = 5},
                ["sdft_bun"] = {Label = "Burger Bun", Cooked = {Label = "Toasted Bun", Item = "sdft_bun_cooked"}, CookTime = 3},
                ["sdft_pizza"] = {Label = "Raw Pizza", Cooked = {Label = "Cooked Pizza", Item = "sdft_pizza_cooked"}, CookTime = 7},
                ["sdft_rawdonut"] = {Label = "Donut Dough", Cooked = {Label = "Donut", Item = "sdft_donut_cooked"}, CookedLabel = "Donut", CookTime = 5},
            },
            FoodPrep = {
                ["sdft_burger"] = {Label = "Burger", MakeTime = 8, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_patty_cooked"] = 1, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 1}},
                ["sdft_megacheese"] = {Label = "Megacheese", MakeTime = 8, Category = "entree", SellPrice = 25, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_cheese"] = 4}},
                ["sdft_doubleburger"] = {Label = "Double Burger", MakeTime = 8, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_patty_cooked"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 2}},
                ["sdft_kingsizeburger"] = {Label = "Kingsize Burger", MakeTime = 9, Category = "entree", SellPrice = 35, NeededToMake = {["sdft_patty_cooked"] = 3, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 2, ["sdft_tomato"] = 1, ["sdft_cheese"] = 3}},
                ["sdft_baconburger"] = {Label = "Bacon Burger", MakeTime = 8, Category = "entree", SellPrice = 35, NeededToMake = {["sdft_patty_cooked"] = 2, ["bacon"] = 2, ["sdft_bun_cooked"] = 2, ["sdft_lettuce"] = 1, ["sdft_tomato"] = 1, ["sdft_cheese"] = 1}},
                ["sdft_pizzaslice"] = {Label = "Pizza Slice", MakeTime = 5, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_pizza_cooked"] = 1}},
                ["sdft_fries"] = {Label = "Fries", MakeTime = 5, Category = "side", SellPrice = 10, NeededToMake = {["sdft_fries_cooked"] = 1}},
                ["sdft_donut"] = {Label = "Donut", MakeTime = 5, Category = "side", SellPrice = 8, NeededToMake = {["sdft_donut_cooked"] = 1}},
            },
            DrinkPrep = {
                ["ecola"] = {Label = "eCola", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sprunk"] = {Label = "Sprunk", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["water_bottle"] = {Label = "Bottled Water", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sdft_smoothie"] = {Label = "Smoothie", SellPrice = 10, PourTime = 8, NeededInStorage = false},
            }
        },
        ["4"] = {
            ColdItems = {
                ["sdft_shreddedcheese"] = {Label = "Shredded Cheese"},
                ["sdft_lettuce"] = {Label = "Lettuce"}
            },
            Grill = {
                ["sdft_carneasada"] = {Label = "Raw Carne Asada", Cooked = {Label = "Cooked Carne Asada", Item = "sdft_carneasada_cooked"}, CookTime = 7},
                ["sdft_elpastor"] = {Label = "Raw El Pastor", Cooked = {Label = "Cooked El Pastor", Item = "sdft_elpastor_cooked"}, CookTime = 7},
                ["sdft_torilla"] = {Label = "Tortilla", Cooked = {Label = "Toasted Tortilla", Item = "sdft_torilla_cooked"}, CookTime = 3},
            },
            FoodPrep = {
                ["sdft_taco_carneasada"] = {Label = "Carne Asada Taco", MakeTime = 6, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_carneasada_cooked"] = 1, ["sdft_torilla_cooked"] = 1, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_taco_elpastor"] = {Label = "El Pastor Taco", MakeTime = 6, Category = "entree", SellPrice = 20, NeededToMake = {["sdft_elpastor_cooked"] = 1, ["sdft_torilla_cooked"] = 1, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_burrito_carneasada"] = {Label = "Carne Asada Burrito", MakeTime = 8, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_carneasada_cooked"] = 1, ["sdft_torilla_cooked"] = 1, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_burrito_elpastor"] = {Label = "El Pastor Burrito", MakeTime = 8, Category = "entree", SellPrice = 30, NeededToMake = {["sdft_elpastor_cooked"] = 1, ["sdft_torilla_cooked"] = 1, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_torta_carneasada"] = {Label = "Carne Asada Torta", MakeTime = 10, Category = "entree", SellPrice = 40, NeededToMake = {["sdft_carneasada_cooked"] = 1, ["sdft_torilla_cooked"] = 2, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_torta_elpastor"] = {Label = "El Pastor Torta", MakeTime = 10, Category = "entree", SellPrice = 40, NeededToMake = {["sdft_elpastor_cooked"] = 1, ["sdft_torilla_cooked"] = 2, ["sdft_shreddedcheese"] = 1, ["sdft_lettuce"] = 1}},
                ["sdft_quesadilla"] = {Label = "Quesadilla", MakeTime = 4, Category = "entree", SellPrice = 15, NeededToMake = {["sdft_torilla_cooked"] = 2, ["sdft_shreddedcheese"] = 2}},
                ["sdft_tostada"] = {Label = "Tostada", MakeTime = 4, Category = "side", SellPrice = 5, NeededToMake = {["sdft_torilla_cooked"] = 1}},
            },
            DrinkPrep = {
                ["ecola"] = {Label = "eCola", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["sprunk"] = {Label = "Sprunk", SellPrice = 5, PourTime = 3, NeededInStorage = true},
                ["water_bottle"] = {Label = "Bottled Water", SellPrice = 5, PourTime = 3, NeededInStorage = true},
            }
        }
    },
}
---------------------------------------------------------------------------------
-------------------------------Dealership Configs--------------------------------
---------------------------------------------------------------------------------
SDC.Dealership = { --Main Config For The Food Truck Dealership
    Ped = {
        Model = "a_m_y_business_03", --Ped Model For Dealer
        Coords = vec4(1224.6443, 2728.7444, 38.0051, 190.7177) --Coords Of Dealer Ped
    },
    Blip = { --Blip Configs for dealer
        Enabled = true, --If you want the blip enabled
        Sprite = 513, --Sprite of the blip
        Color = 31, --Color of the blip
        Size = 0.5 --Size of the blip
    },
    SpawnAreas = { --Vehicle Spawn Areas After Purchase
        --EX: vec4(0.0, 0.0, 0.0, 0.0),

        vec4(1246.8069, 2713.0732, 38.0058, 184.2564),
        vec4(1210.2847, 2706.7102, 38.0054, 168.7180),
        vec4(1211.9470, 2723.1653, 38.0042, 266.1554)
    }
}

---------------------------------------------------------------------------------
-------------------------------Truck Addon Configs-------------------------------
---------------------------------------------------------------------------------
SDC.SpawnAddonDist = 75 --How close/far you have to be for it to show/hide the props from the food truck

SDC.TruckAddons = { --All Truck addons
    --[[
    Example of a new addon

    {
        Label = "Addon_Label", --A Label for the addon
        Identifier = "unique_identifier", --A unqiue identifer (can't match any others below)
        Price = 0, --Price Of the addon
        Prop = "addon_prop", --Prop of the addon
        Offset = { --Offset of the prop from the truck
            --EX: ["model_name"] = {vec3(0.0, 0.0, 0.0)},
        },
        Rotation = { --Rotation of the prop
            --EX: ["model_name"] = vec3(0.0, 0.0, 0.0),
        },
    },

    ]]

    {
        Label = "TV",
        Identifier = "tv",
        Price = 10000,
        Prop = "prop_tv_flat_03b",
        Offset = {
            ["taco2"] = {vec3(1.0, -4.0, 1.2)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 0.0, 90.0),
        }
    },
    {
        Label = "Outside Light #1",
        Identifier = "outlight",
        Price = 100,
        Prop = "prop_wall_light_02a",
        Offset = {
            ["taco2"] = {vec3(1.0, 0.0, 1.1)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 50.0, 90.0),
        }
    },
    {
        Label = "Outside Light #2",
        Identifier = "outlight2",
        Price = 100,
        Prop = "prop_wall_light_02a",
        Offset = {
            ["taco2"] = {vec3(1.0, -1.5, 1.1)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 50.0, 90.0),
        }
    },
    {
        Label = "Outside Light #3",
        Identifier = "outlight3",
        Price = 100,
        Prop = "prop_wall_light_02a",
        Offset = {
            ["taco2"] = {vec3(1.0, -3.0, 1.1)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 50.0, 90.0),
        }
    },
    {
        Label = "Outside Light #4",
        Identifier = "outlight4",
        Price = 100,
        Prop = "prop_wall_light_02a",
        Offset = {
            ["taco2"] = {vec3(0.0, -4.3, 1.5)},
        },
        Rotation = {
            ["taco2"] = vec3(25.0, 0.0, 0.0),
        }
    },
    {
        Label = "Flag Pole",
        Identifier = "flagpole",
        Price = 100,
        Prop = "prop_flagpole_1a",
        Offset = {
            ["taco2"] = {vec3(0.8, -4.0, -2.0)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 0.0, 0.0),
        }
    },
    {
        Label = "American Flag",
        Identifier = "americanflag",
        Price = 100,
        Prop = "prop_flag_us",
        Offset = {
            ["taco2"] = {vec3(0.85, -3.9, 3.4)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 0.0, -90.0),
        }
    },
    {
        Label = "Dart Board",
        Identifier = "dartboard",
        Price = 500,
        Prop = "prop_dart_bd_01",
        Offset = {
            ["taco2"] = {vec3(-0.98, 0.0, 0.6)},
        },
        Rotation = {
            ["taco2"] = vec3(0.0, 0.0, -90.0),
        }
    }
}


---------------------------------------------------------------------------------
-------------------------------AI Ped Configs------------------------------------
---------------------------------------------------------------------------------
SDC.RandomOrderMatrix = { --Random Order Configs
    Entrees = {Min = 0, Max = 4}, --Random entree amount selection
    Sides = {Min = 0, Max = 2}, --Random side amount selection
    Drinks = {Min = 0, Max = 0}, --Random drink amount selection
}

SDC.AICooldown = {Min = 30, Max = 60} --How long the cooldown is for ai sales (IN SECONDS)

SDC.AIPedModels = { --All AI Ped Models
    --EX: "ped_model",

    "a_f_m_fatwhite_01",
}

---------------------------------------------------------------------------------
-------------------------------Minigame Configs----------------------------------
---------------------------------------------------------------------------------
SDC.Minigames = {
    Grill = { --Minigame configs for the GRILL
        Enabled = true, --If you want there to be a minigame for cooking things on the grill
        Checks = 2, --How many key press checks there are
        Difficulty = "easy", -- Options: ["easy", "medium", "hard"]
        Keys = {"w", "a", "s", "d"} --All keys used in keypress check
    },
    FoodPrep = { --Minigame configs for the FOOD PREP
        Enabled = true, --If you want there to be a minigame for cooking things on the grill
        Checks = 2, --How many key press checks there are
        Difficulty = "easy", -- Options: ["easy", "medium", "hard"]
        Keys = {"w", "a", "s", "d"} --All keys used in keypress check
    },
    DrinkPrep = { --Minigame configs for the DRINK PREP
        Enabled = true, --If you want there to be a minigame for cooking things on the grill
        Checks = 2, --How many key press checks there are
        Difficulty = "easy", -- Options: ["easy", "medium", "hard"]
        Keys = {"w", "a", "s", "d"} --All keys used in keypress check
    }
}

---------------------------------------------------------------------------------
-------------------------------Blip Configs--------------------------------------
---------------------------------------------------------------------------------
SDC.DefaultBlipSize = 0.7 --Size for all food truck blips
SDC.BlipOptions = { --All Blip Sprite Options
    --EX: {Sprite = 1, Label = "BLIP_LABEL"},

    {Sprite = 477, Label = "Truck"},
    {Sprite = 479, Label = "Trailer"},
    {Sprite = 276, Label = "Money Sign"},
    {Sprite = 176, Label = "Castle"}
}
SDC.BlipColors = { --All Blip Color Options
    --EX: {Color = 1, Label = "COLOR_LABEL"},

    {Color = 1, Label = "Red"},
    {Color = 69, Label = "Green"},
    {Color = 3, Label = "Blue"},
    {Color = 5, Label = "Yellow"},
    {Color = 8, Label = "Pink"},
    {Color = 7, Label = "Violet"},
    {Color = 81, Label = "Orange"},
    {Color = 37, Label = "White"},
    {Color = 56, Label = "Brown"}
}

---------------------------------------------------------------------------------
-------------------------------Icons Configs-------------------------------------
---------------------------------------------------------------------------------
SDC.Icons = { --All Icon Configs
    FTSalesmen = {Enabled = true, DistToDraw = 7}, --Icon For Food Truck Salesmen
    StorePeds = {Enabled = true, DistToDraw = 7}, --Icon For Food Store Peds
    Register = {Enabled = true, DistToDraw = 7}, --Icon For Nearest Food Truck Register
    Table = {Enabled = true, DistToDraw = 7}, --Icon For Nearest Food Truck Table
}


---------------------------------------------------------------------------------
-------------------------------Store Configs-------------------------------------
---------------------------------------------------------------------------------
SDC.EnableStores = true --If you want the built in stores to be enabled
SDC.Stores = {--All Store Configs
    --[[
        Example Below:


    
        {
            Label = "STORE_LABEL", --Label for the store
            Ped = { --All Store Ped Configs
                Model = "ped_model", --Ped Model For The Store
                SpawnCoords = vec4(0.0, 0.0, 0.0, 0.0), --Spawn Coords For Store
                SpawnDist = 50 --How close/far you have to be for it to load/unload the ped
            },
            Blip = {Enabled = true, Sprite = 59, Color = 1, Size = 0.7}, --All Blip Configs For This Store
            Products = { --All Products For This Store
                --EX: {Item = "item_name", Label = "ITEM_LABEL", Price = 1, Icon = "carrot"},

            }
        }
    ]]

    {
        Label = "Local Food Market",
        Ped = {
            Model = "a_f_y_eastsa_02", 
            SpawnCoords = vec4(462.1544, -697.1375, 27.4088, 83.4268), 
            SpawnDist = 50
        },
        Blip = {Enabled = true, Sprite = 59, Color = 14, Size = 0.7},
        Products = {
            {Item = "sdft_lettuce", Label = "Lettuce", Price = 10, Icon = "carrot"},
            {Item = "sdft_tomato", Label = "Tomato", Price = 10, Icon = "carrot"},
            {Item = "sdft_cheese", Label = "Cheese Slice", Price = 10, Icon = "carrot"},
            {Item = "sdft_shreddedcheese", Label = "Shredded Cheese", Price = 10, Icon = "carrot"},
            {Item = "sdft_cheesesauce", Label = "Cheese Sauce", Price = 20, Icon = "carrot"},
            {Item = "sdft_patty", Label = "Raw Patty", Price = 50, Icon = "bacon"},
            {Item = "sdft_vpatty", Label = "Raw Veggie Patty", Price = 50, Icon = "bacon"},
            {Item = "sdft_dog", Label = "Raw Dog", Price = 50, Icon = "bacon"},
            {Item = "sdft_sausage", Label = "Raw Sausage", Price = 50, Icon = "bacon"},
            {Item = "sdft_bacon", Label = "Raw Bacon", Price = 50, Icon = "bacon"},
            {Item = "sdft_carneasada", Label = "Raw Carne Asada", Price = 50, Icon = "bacon"},
            {Item = "sdft_elpastor", Label = "Raw El Pastor", Price = 50, Icon = "bacon"},
            {Item = "sdft_rawfries", Label = "Raw Fries", Price = 10, Icon = "bowl-rice"},
            {Item = "sdft_pizza", Label = "Frozen Pizza", Price = 20, Icon = "bowl-rice"},
            {Item = "sdft_rawdonut", Label = "Donut Dough", Price = 10, Icon = "wheat-awn"},
            {Item = "sdft_nuts", Label = "Nuts", Price = 5, Icon = "wheat-awn"},
            {Item = "sdft_minipretzel", Label = "Raw Mini Pretzels", Price = 10, Icon = "wheat-awn"},
            {Item = "sdft_rawpretzel", Label = "Raw Pretzel Dough", Price = 50, Icon = "wheat-awn"},
            {Item = "sdft_bun", Label = "Burger Bun", Price = 10, Icon = "wheat-awn"},
            {Item = "sdft_hoagie", Label = "Hoagie", Price = 10, Icon = "wheat-awn"},
            {Item = "sdft_hotdogbun", Label = "Hot Dog Bun", Price = 10, Icon = "wheat-awn"},
            {Item = "sdft_torilla", Label = "Tortilla", Price = 5, Icon = "wheat-awn"},
        }
    }
}
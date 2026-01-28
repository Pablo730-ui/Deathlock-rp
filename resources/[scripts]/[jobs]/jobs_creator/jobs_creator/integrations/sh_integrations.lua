--[[
    This is the plate format that will be used to create random plates
    Configure the plate format using # for fixed characters

    Examples:
    "#LSPD#123" -> LSPD920, LSPD945, LSPD984   (as you can see, LSPD doesn't change)
    "AB123CD"   -> XC111EW, SI849TW, YS364KD
    "CBZ 629"   -> EGP 015, VHS 687, SXN 296
    "72 QT 15"  -> 63 VD 85, 27 AC 66, 63 HR 75
]]
EXAMPLE_PLATE = "AB123CD"

--[[
    The shared object of the framework will refresh each X seconds. If for any reason you don't want it to refresh, set to nil
]] 
SECONDS_TO_REFRESH_SHARED_OBJECT = nil

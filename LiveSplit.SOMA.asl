state("soma")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma_nosteam")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "GOG 1.00")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "Steam 1.00")
{
    bool loading : 0x00802A00, 0xB20, 0x27D8, 0x60;
    string50 map : 0x007FCD80, 0x118, 0x168, 0x0;
}

state("soma_nosteam", "NoSteam 1.00")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "GOG 1.51")
{
    bool loading : 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

state("soma", "Steam 1.51")
{
    bool loading : 0x0080D740, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 map : 0x0080D740, 0x130, 0x168, 0x0;
}

state("soma", "Discord 1.51")
{
    bool loading : 0x0078D560, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

state("soma_nosteam", "NoSteam 1.51")
{
    bool loading : 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

init
{
    var name = modules.First().ModuleName.ToLower();
    var size = modules.First().ModuleMemorySize;

    print("Module Size: " + size);

    switch(size)
    {
        case 8679424:
            version = name == "soma.exe" ? "GOG 1.00" : "NoSteam 1.00";
            break;
        case 8871936:
            version = name == "soma.exe" ? "GOG 1.51" : "NoSteam 1.51";
            break;
        case 8876032:
            version = "Discord 1.51";
            break;
        case 9183232:
            version = "Steam 1.00";
            break;
        case 9383936:
            version = "Steam 1.51";
            break;
        default:
            break;
    }
}

isLoading
{
    return current.loading;
}

start
{
    return old.map != "00_01_apartment.hpm" && current.map == "00_01_apartment.hpm";
}

split
{
    return old.map != "main_menu.hpm" &&
        current.map != "main_menu.hpm" &&
        current.map != "00_00_intro" &&
        old.map != current.map;
}

reset
{
    return current.map == "00_00_intro.hpm";
}

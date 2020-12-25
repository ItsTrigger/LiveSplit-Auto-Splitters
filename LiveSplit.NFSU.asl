state("speed", "EU")
{
    bool fmvActive : 0x00333F74;
	string8 fmvName : 0x0038EF70;

    int trackId : 0x0038A2E0;
    byte trackLaps : 0x0038A30C;
    float trackProgress : 0x00336194, 0x44;

    int gameState : 0x00335784, 0x8, 0xF4, 0x4, 0x4;
}

state("speed", "US")
{
    bool fmvActive : 0x00333F74;
	string8 fmvName : 0x0038EF80;

    int trackId : 0x0038A2F0;
    byte trackLaps : 0x0038A31C;
    float trackProgress : 0x0033619C, 0x44;

    int gameState : 0x0033578C, 0x8, 0xF4, 0x4, 0x4;
}

init
{
    var size = modules.First().ModuleMemorySize;
    print("Module Size: " + size);

    switch(size)
    {
        case 3752776:
            version = "EU";
            break;
        case 3752808:
            version = "US";
            break;
        default:
            break;
    }
}

start
{
	return (current.fmvName == "01_DAY" && current.fmvActive && !old.fmvActive);
}

split
{
    if (current.gameState == 0 || current.trackId == 11) { return false; }

    if ((current.trackId >= 1001 && current.trackId <= 1008) || (current.trackId >= 1301 && current.trackId <= 1308))
    {
        return current.trackProgress > old.trackProgress && current.trackProgress >= current.trackLaps;
    }

    return current.trackProgress > old.trackProgress && current.trackProgress >= 1;
}

isLoading
{
    return current.gameState == 0;
}

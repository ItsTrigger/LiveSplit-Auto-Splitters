state("speed")
{
    bool fmvActive : 0x00333F74;
	string8 fmvName : 0x0038EF80;

    int trackId : 0x0038A2F0;
    byte trackLaps : 0x0038A31C;
    float trackProgress : 0x0033619C, 0x44;

    int gameState : 0x00336220, 0x4C, 0x360;
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

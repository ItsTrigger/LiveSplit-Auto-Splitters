state("BurnoutParadise")
{
    bool loading : 0x00D007B8;
    bool windowFocused : 0x00CF8344;

    byte carState : 0x00BBFA5C;

    byte raceWins : 0x002631CC, 0x44, 0x180;
    byte markedManWins : 0x002631CC, 0x44, 0x1A0;
    byte roadRageWins : 0x002631CC, 0x44, 0x18C;
    byte stuntRunWins : 0x002631CC, 0x44, 0x19C;
    byte burningRouteWins : 0x002631CC, 0x44, 0x194;
}

start
{
    return old.carState == 0 && current.carState == 1;
}

split
{
    var previousWins = old.raceWins + old.markedManWins + old.roadRageWins + old.stuntRunWins + old.burningRouteWins;
    var currentWins = current.raceWins + current.markedManWins + current.roadRageWins + current.stuntRunWins + current.burningRouteWins;

    return current.windowFocused && currentWins > previousWins;
}

isLoading
{
    return current.loading;
}

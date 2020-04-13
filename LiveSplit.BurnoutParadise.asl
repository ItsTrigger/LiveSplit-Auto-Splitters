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

state("BurnoutPR")
{
    bool loading : 0x01096A1C;
    bool windowFocused : 0x00F45D8C;

    byte carState : 0x00EFE7E8;

    byte raceWins : 0x04408D74, 0xFC, 0x20, 0x180;
    byte markedManWins : 0x04408D74, 0xFC, 0x20, 0x1A0;
    byte roadRageWins : 0x04408D74, 0xFC, 0x20, 0x18C;
    byte stuntRunWins : 0x04408D74, 0xFC, 0x20, 0x19C;
    byte burningRouteWins : 0x04408D74, 0xFC, 0x20, 0x194;
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

state("BurnoutParadise")
{
    bool loading : 0x00D007B8;
    byte carState : 0x00BBFA5C;
    byte victoryState : 0x0019D554, 0x150, 0x6C, 0x130, 0x5540;
}

state("BurnoutPR")
{
    bool loading : 0x01096A1C;
    byte carState : 0x00EFE7E8;
    byte victoryState : 0x00F98134, 0x3C, 0x40, 0xD060;
}

start
{
    return old.carState == 0 && current.carState == 1;
}

split
{
    return old.victoryState != current.victoryState && current.victoryState == 1;
}

isLoading
{
    return current.loading;
}

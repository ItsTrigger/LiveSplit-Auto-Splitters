state("Kholat-Win64-Shipping")
{
    bool loading : 0x01FC0B08, 0x70, 0x40, 0x70, 0x680;
    bool introPlaying : 0x01FCE5B8, 0x4A0, 0x8, 0x250;
}

start
{
    return current.introPlaying;
}

isLoading
{
    return current.loading;
}

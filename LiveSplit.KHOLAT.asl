state("Kholat-Win64-Shipping")
{
    bool loading : 0x01FC0B08, 0x70, 0x40, 0x70, 0x680;
}

isLoading
{
    return current.loading;
}

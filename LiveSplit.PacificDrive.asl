state("PenDriverPro-Win64-Shipping") {}

startup
{
    settings.Add("MISSIONS", true, "Missions");

    settings.Add("WB.Missions.QD_Q00_Intro_Mission_A",  true, "Delivery Window",                "MISSIONS");
    settings.Add("WB.Missions.QD_Q00_Intro_Mission_B",  true, "Get to Safety",                  "MISSIONS");
    settings.Add("WB.Missions.QD_Q00_Mission_B2",       true, "Oppy's Auto Shop",               "MISSIONS");
    settings.Add("WB.Missions.QD_Q00_Mission_C3",       true, "Fix the Car",                    "MISSIONS");
    settings.Add("WB.Missions.QD_Q00_Mission_H",        true, "Zone Preparation",               "MISSIONS");
    settings.Add("WB.Missions.QD_Q01_Mission_C",        true, "Into the Wilderness",            "MISSIONS");
    settings.Add("WB.Missions.QD_Q01_Mission_D",        true, "Build the Antenna",              "MISSIONS");
    settings.Add("WB.Missions.QD_Q015_Mission_B",       true, "Investigate the Zone",           "MISSIONS");
    settings.Add("WB.Missions.QD_Q02_Mission_C",        true, "The Remnant Experiment",         "MISSIONS");
    settings.Add("WB.Missions.QD_Q025_Mission_A",       true, "Explore the Zone",               "MISSIONS");
    settings.Add("WB.Missions.QD_Q03_Mission_G",        true, "Stabilizing a Way Through",      "MISSIONS");
    settings.Add("WB.Missions.QD_Q05_Mission_D",        true, "The Mid-Zone Crossing",          "MISSIONS");
    settings.Add("WB.Missions.QD_Q06_Mission_A",        true, "A Little Favor",                 "MISSIONS");
    settings.Add("WB.Missions.QD_Q06_Mission_G",        true, "The Visions",                    "MISSIONS");
    settings.Add("WB.Missions.QD_Q07_Mission_H",        true, "Red Meadow Research Facility",   "MISSIONS");
    settings.Add("WB.Missions.QD_Q08_Mission_F",        true, "The Deep Zone Crossing",         "MISSIONS");
    settings.Add("WB.Missions.QD_Q09_Mission_A",        true, "Explore the Deep Zone",          "MISSIONS");
    settings.Add("WB.Missions.QD_Q10_Mission_E",        true, "The Anomaly Barricade",          "MISSIONS");
    settings.Add("CREDITS",                             true, "The End of the Road",            "MISSIONS");

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Pacific Drive",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    vars.completedMissionTags = new HashSet<string>();
    vars.creditsSplitCheck = false;
    vars.creditsSplitComplete = false;
}

init
{
    var scan = new SignatureScanner(game, game.MainModule.BaseAddress, game.MainModule.ModuleMemorySize);
    var syncLoadTarget = new SigScanTarget(5, "89 43 60 8B 05 ?? ?? ?? ??") { OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr) };
    var syncLoadCount = scan.Scan(syncLoadTarget);
    var gameEngineTarget = new SigScanTarget(3, "48 39 35 ?? ?? ?? ?? 0F 85 ?? ?? ?? ?? 48 8B 0D") { OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr) };
    var gameEngine = scan.Scan(gameEngineTarget);
    var fNamePoolTarget = new SigScanTarget(13, "89 5C 24 ?? 89 44 24 ?? 74 ?? 48 8D 15") { OnFound = (p, s, ptr) => ptr + 0x4 + game.ReadValue<int>(ptr) };
    var fNamePool = scan.Scan(fNamePoolTarget);

    if(syncLoadCount == IntPtr.Zero || gameEngine == IntPtr.Zero || fNamePool == IntPtr.Zero)
    {
        throw new Exception("One or more base pointers not found, retrying...");
    }

	vars.Watchers = new MemoryWatcherList
    {
        new MemoryWatcher<int>(new DeepPointer(syncLoadCount)) { Name = "SyncLoadCount" },
        new MemoryWatcher<int>(new DeepPointer(gameEngine, 0xDE8, 0x40C)) { Name = "StateFlags" },
        new MemoryWatcher<long>(new DeepPointer(gameEngine, 0xDE8, 0x330, 0xA0, 0x118)) { Name = "CompletedMissions" },
        new MemoryWatcher<int>(new DeepPointer(gameEngine, 0xDE8, 0x330, 0xA0, 0x120)) { Name = "CompletedMissionsCount" },
        new MemoryWatcher<byte>(new DeepPointer(gameEngine, 0xDE8, 0x38, 0x0, 0x30, 0x2B0, 0x390, 0x2F9)) { Name = "MenuOpen" },
        new MemoryWatcher<byte>(new DeepPointer(gameEngine, 0xDE8, 0x38, 0x0, 0x30, 0x2B0, 0x390, 0x2FA)) { Name = "FullscreenWidgetsVisible" }
    };
    
    vars.FNameToString = (Func<ulong, string>)(fName =>
    {
        var number   = (fName & 0xFFFFFFFF00000000) >> 0x20;
        var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
        var nameIdx  = (fName & 0x000000000000FFFF) >> 0x00;
        var chunk = game.ReadPointer(fNamePool + 0x10 + (int)chunkIdx * 0x8);
        var nameEntry = chunk + (int)nameIdx * 0x2;
        var length = game.ReadValue<short>(nameEntry) >> 6;
        var name = game.ReadString(nameEntry + 0x2, length);
        return number == 0 ? name : name;
    });

    vars.Watchers.UpdateAll(game);
}

start
{
    return vars.Watchers["StateFlags"].Current == 12 && vars.Watchers["StateFlags"].Old == 2;
}

onStart
{
    vars.completedMissionTags.Clear();
    vars.creditsSplitCheck = false;
    vars.creditsSplitComplete = false;
}

update
{
    vars.shouldSplit = false;

    vars.Watchers.UpdateAll(game);

    if (vars.Watchers["CompletedMissions"].Current != null && vars.Watchers["CompletedMissionsCount"].Current > vars.Watchers["CompletedMissionsCount"].Old)
    {
        long lastMissionAddr = game.ReadValue<long>(new IntPtr(vars.Watchers["CompletedMissions"].Current + ((vars.Watchers["CompletedMissionsCount"].Current - 1) * 0x8)));
        string lastMissionTag = vars.FNameToString(game.ReadValue<ulong>(new IntPtr(lastMissionAddr + 0x16C)));

        if (settings[lastMissionTag] && !vars.completedMissionTags.Contains(lastMissionTag))
        {
            vars.completedMissionTags.Add(lastMissionTag);
            vars.shouldSplit = true;
        }

        if(settings["CREDITS"] && lastMissionTag == "WB.Missions.QD_Q11_Mission_B")
        {
            vars.creditsSplitCheck = true;
        }
    }

    if (vars.creditsSplitCheck && !vars.creditsSplitComplete && vars.Watchers["MenuOpen"].Current != null && vars.Watchers["FullscreenWidgetsVisible"].Current != null)
    {
        if (vars.Watchers["FullscreenWidgetsVisible"].Current == 1 && vars.Watchers["MenuOpen"].Current == 0)
        {
            vars.creditsSplitComplete = true;
            vars.shouldSplit = true;
        }
    }

}

split
{
    return vars.shouldSplit;
}

isLoading
{
    return vars.Watchers["SyncLoadCount"].Current > 0;
}

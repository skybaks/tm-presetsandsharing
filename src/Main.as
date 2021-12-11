#if !UNIT_TEST

Interface::ManagePresets@ g_interface;
Interface::PluginPreset@[] g_presets;
Interface::PresetLoadout@[] g_loadouts;

void RenderMenu()
{
    if (g_interface !is null)
    {
        g_interface.RenderMenu();
    }
}

void RenderInterface()
{
    if (g_interface !is null)
    {
        g_interface.RenderWindow();
    }
}

void Main()
{
    @g_interface = Interface::ManagePresets();

    if (g_interface !is null)
    {
        g_interface.Load();
    }

    int dt = 0;
    int prevFrameTime = Time::Now;
    while (true)
    {
        sleep(50);
        dt = Time::Now - prevFrameTime;
        Interface::Tooltip::Update(dt);
        prevFrameTime = Time::Now;
    }
}

#endif
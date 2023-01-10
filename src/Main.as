
Interface::PluginPreset@[] g_presets;
Interface::PresetLoadout@[] g_loadouts;
bool g_hotkeyCombokeyDown = false;

Interface::ManagePresets@ g_interface;

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

void OnKeyPress(bool down, VirtualKey key)
{
    if (!g_hotkeyCombokeyDown
        && down
        && key == Setting_General_LoadoutHotkeyCombo)
    {
        g_hotkeyCombokeyDown = true;
    }
    else if (g_hotkeyCombokeyDown
        && !down)
    {
        if (key == Setting_General_LoadoutHotkeyCombo)
        {
            g_hotkeyCombokeyDown = false;
        }
        else
        {
            for (uint i = 0; i < g_loadouts.Length; i++)
            {
                if (g_loadouts[i].HotkeyActive
                    && g_loadouts[i].Hotkey == key)
                {
                    UI::ShowNotification("Presets and Sharing", "Activated loadout: " + g_loadouts[i].Name, 5000);
                    g_loadouts[i].ActivatePresets();
                    break;
                }
            }
        }
    }
}

void OnDestroyed()
{
    if (g_interface !is null)
    {
        g_interface.Save();
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

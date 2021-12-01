#if UNIT_TEST
namespace Test
{
    void Test_PresetDashboard()
    {
        Verification::TestBegin("Test_PresetDashboard");
        Interface::PluginPreset@ preset = Interface::PluginPreset();
        preset.PluginID = Meta::GetPluginFromSiteID(103).ID;
        preset.Name = "UnitTest";
        preset.ReadSettings();
        Verification::Condition(preset.Valid, "Preset is not valid");
        Verification::TestEnd();
    }

    void Test_PresetTmxMenu()
    {
        Verification::TestBegin("Test_PresetTmxMenu");
        Interface::PluginPreset@ preset = Interface::PluginPreset();
        preset.PluginID = "Plugin_TmxMenu";
        preset.Name = "UnitTest";
        preset.ReadSettings();
        Verification::Condition(preset.Valid, "Preset is not valid");
        Verification::TestEnd();
    }
}
#endif
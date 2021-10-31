

void Main()
{

    //auto dashSettings = Meta::GetPluginFromID('Dashboard-Dev').GetSettings();
    auto plugin = Meta::GetPluginFromID('Dashboard-Dev');

    auto serial = Serialization::SettingsInterface();
    serial.SetPlugin(plugin);
    serial.WriteCurrentToBinary();

}

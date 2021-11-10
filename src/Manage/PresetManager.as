
namespace Manage
{
    class PresetManager
    {
        // Format: string, PluginPreset
        private dictionary m_presets;
        private Serialization::SettingsInterface m_serial;
        private Meta::Plugin@ m_plugin;

        PresetManager(const string&in pluginName)
        {
            @m_plugin = Meta::GetPluginFromID(pluginName);
        }

        void AddOrUpdatePreset(const string&in presetName, string[] categories)
        {
            m_presets[presetName] = PluginPreset(categories);
            auto currPreset = cast<PluginPreset>(m_presets[presetName]);
            m_serial.Initialize(m_plugin, currPreset.Categories);
            bool success = m_serial.WriteCurrentToBinary(currPreset.Binary);
        }

        void RemovePreset(const string&in presetName)
        {
            if (m_presets.Exists(presetName))
            {
                m_presets.Delete(presetName);
            }
        }
    }
}

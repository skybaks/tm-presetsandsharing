
namespace Serialization
{
    class SettingsInterface
    {
        private Meta::Plugin@ m_plugin;
        private Serialization::SettingsSerializer m_serializer;
        // Dictionary Format: string, Meta::PluginSetting@
        private dictionary m_settingsFromPlugin;
        // Dictionary Format: string, Serialization::SettingsDataItem@
        private dictionary m_settingsFromBinary;

        SettingsInterface()
        {
        }

        void SetPlugin(Meta::Plugin@ plugin)
        {
            @m_plugin = plugin;

            ReadPluginSettings();
        }

        void ReadAndValidateBinary(const string&in inputBase64String)
        {
            bool success = m_serializer.ReadFromBinary(inputBase64String, m_settingsFromBinary);
        }

        void WriteCurrentToBinary()
        {
            string result = "";
            bool success = m_serializer.WriteToBinary(m_settingsFromPlugin, m_plugin.ID, result);

            // TODO: Do something with the result?
            //print(result);
        }

        private void ReadPluginSettings()
        {
            m_settingsFromPlugin.DeleteAll();

            auto pluginSettings = m_plugin.GetSettings();
            for (uint i = 0; i < pluginSettings.Length; i++)
            {
                @m_settingsFromPlugin[tostring(Hash16(pluginSettings[i].VarName))] = pluginSettings[i];
            }

            if (m_settingsFromPlugin.GetSize() != pluginSettings.Length)
            {
                // TODO: Handle this case?
                error("Serialization::SettingsInterface::PopulateHashedDictionary(): Hash not good enough. Duplication detected!");
            }
        }
    }
}

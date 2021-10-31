
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

            string[]@ keys = m_settingsFromBinary.GetKeys();
            for (uint i = 0; i < keys.Length; i++)
            {
                auto bin = cast<Serialization::SettingsDataItem>(m_settingsFromBinary[keys[i]]);
                if (m_settingsFromPlugin.Exists(keys[i])
                    && cast<Meta::PluginSetting>(m_settingsFromPlugin[keys[i]]).Type == bin.m_SettingType)
                {
                    auto plg = cast<Meta::PluginSetting>(m_settingsFromPlugin[keys[i]]);
                    if (bin.m_SettingType == Meta::PluginSettingType::Bool)
                    {
                        bool binValue = Text::ParseInt(bin.m_ValueStringified) != 0;
                        // TODO: This is testing logic
                        if (binValue != plg.ReadBool())
                        {
                            warn("id: " + keys[i] + " bin: " + tostring(binValue) + " plg: " + tostring(plg.ReadBool()));
                        }
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::Enum
                        || bin.m_SettingType == Meta::PluginSettingType::Int8
                        || bin.m_SettingType == Meta::PluginSettingType::Int16
                        || bin.m_SettingType == Meta::PluginSettingType::Int32)
                    {
                        int binValue = Text::ParseInt(bin.m_ValueStringified);
                        int plgValue = 0;

                        if (bin.m_SettingType == Meta::PluginSettingType::Enum)
                        {
                            plgValue = plg.ReadEnum();
                        }
                        else if (bin.m_SettingType == Meta::PluginSettingType::Int8)
                        {
                            plgValue = plg.ReadInt8();
                        }
                        else if (bin.m_SettingType == Meta::PluginSettingType::Int16)
                        {
                            plgValue = plg.ReadInt16();
                        }
                        else if (bin.m_SettingType == Meta::PluginSettingType::Int32)
                        {
                            plgValue = plg.ReadInt32();
                        }

                        // TODO: This is testing logic
                        if (binValue != plgValue)
                        {
                            warn("id: " + keys[i] + " bin: " + tostring(binValue) + " plg: " + tostring(plgValue));
                        }
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::Float)
                    {
                        // TODO
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::String)
                    {
                        // TODO
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::Vec2)
                    {
                        // TODO
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::Vec3)
                    {
                        // TODO
                    }
                    else if (bin.m_SettingType == Meta::PluginSettingType::Vec4)
                    {
                        // TODO
                    }
                }
                else
                {
                    error("Non matching setting ID: " + keys[i]);
                }
            }
        }

        void WriteCurrentToBinary()
        {
            string result = "";
            bool success = m_serializer.WriteToBinary(m_settingsFromPlugin, m_plugin.ID, result);

            // TODO: Do something with the result?
            print(result);
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

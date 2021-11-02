
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

        bool ReadAndValidateBinary(const string&in inputBase64String)
        {
            bool success = true;
            uint8 pluginIdFromBinary;
            bool readSuccess = m_serializer.ReadFromBinary(inputBase64String, pluginIdFromBinary, m_settingsFromBinary);

            bool pluginIdMatch = pluginIdFromBinary == Hash8(m_plugin.Name);
            if (!pluginIdMatch)
            {
                error("Error unpacking binary. Plugin ID mismatch.");
            }

            bool validationSuccess = true;
            if (readSuccess)
            {
                string[]@ keys = m_settingsFromBinary.GetKeys();
                for (uint i = 0; i < keys.Length; i++)
                {
                    auto bin = cast<Serialization::SettingsDataItem>(m_settingsFromBinary[keys[i]]);
                    if (!m_settingsFromPlugin.Exists(keys[i])
                        || cast<Meta::PluginSetting>(m_settingsFromPlugin[keys[i]]).Type != bin.m_SettingType)
                    {
                        validationSuccess = false;
                        error("Non matching setting ID: " + keys[i]);
                    }
                }
            }

            if (!readSuccess || !pluginIdMatch || !validationSuccess)
            {
                m_settingsFromBinary.DeleteAll();
                success = false;
                error("Issue detected during read and validation. Unable to safely deserialize.");
            }
            return success;
        }

        bool WriteCurrentToBinary(string&out result)
        {
            return m_serializer.WriteToBinary(m_settingsFromPlugin, m_plugin.Name, result);
        }

        bool ApplyBinaryToSettings()
        {
            bool success = true;

            if (m_settingsFromBinary.GetKeys().Length <= 0)
            {
                error("Unable to apply settings, binary deserialized data is empty.");
                success = false;
                return success;
            }

            string[]@ keys = m_settingsFromBinary.GetKeys();
            for (uint i = 0; i < keys.Length; i++)
            {
                auto bin = cast<Serialization::SettingsDataItem>(m_settingsFromBinary[keys[i]]);
                if (m_settingsFromPlugin.Exists(keys[i]))
                {
                    auto plg = cast<Meta::PluginSetting>(m_settingsFromPlugin[keys[i]]);
                    if (plg.Type == bin.m_SettingType)
                    {
                        switch (bin.m_SettingType)
                        {
                        case Meta::PluginSettingType::Bool:
                            plg.WriteBool(bin.ReadBool());
                            break;
                        case Meta::PluginSettingType::Enum:
                            plg.WriteEnum(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::Float:
                            plg.WriteFloat(bin.ReadFloat());
                            break;
                        case Meta::PluginSettingType::Int8:
                            plg.WriteInt8(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::Int16:
                            plg.WriteInt16(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::Int32:
                            plg.WriteInt32(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::String:
                            plg.WriteString(bin.ReadString());
                            break;
                        case Meta::PluginSettingType::Vec2:
                            plg.WriteVec2(bin.ReadVec2());
                            break;
                        case Meta::PluginSettingType::Vec3:
                            plg.WriteVec3(bin.ReadVec3());
                            break;
                        case Meta::PluginSettingType::Vec4:
                            plg.WriteVec4(bin.ReadVec4());
                            break;
                        default:
                            error("Unexpected setting type \"" + tostring(bin.m_SettingType) + "\", aborting");
                            success = false;
                            return success;
                        }
                    }
                }
            }

            return success;
        }

        // TODO: Ability to filter read by setting category
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

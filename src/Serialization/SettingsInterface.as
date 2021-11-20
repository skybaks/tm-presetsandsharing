
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

        void Initialize(Meta::Plugin@ plugin, Serialization::SettingsSerializationValidation@ validation, const string[]@ settingCategories = {})
        {
            @m_plugin = plugin;
            validation.ResetSerialization();
            validation.ValidPluginObject = m_plugin !is null;
            m_settingsFromPlugin.DeleteAll();
            m_settingsFromBinary.DeleteAll();
            ReadPluginSettings(settingCategories);
        }

        bool ReadAndValidateBinary(const string&in inputBase64String, Serialization::SettingsSerializationValidation@ validation)
        {
            validation.ResetSerialization();
            validation.ValidPluginObject = m_plugin !is null;

            uint8 pluginIdFromBinary;
            bool readSuccess = m_serializer.ReadFromBinary(inputBase64String, pluginIdFromBinary, m_settingsFromBinary, validation);

            validation.ValidPluginID = pluginIdFromBinary == Hash8(m_plugin.Name);

            if (readSuccess && validation.ValidPluginID)
            {
                validation.ValidSettingIdMatch = true;
                string[]@ keys = m_settingsFromBinary.GetKeys();
                for (uint i = 0; i < keys.Length; i++)
                {
                    auto bin = cast<Serialization::SettingsDataItem>(m_settingsFromBinary[keys[i]]);
                    if (!m_settingsFromPlugin.Exists(keys[i])
                        || cast<Meta::PluginSetting>(m_settingsFromPlugin[keys[i]]).Type != bin.m_SettingType)
                    {
                        validation.ValidSettingIdMatch = false;
                        break;
                    }
                }
            }

            if (!readSuccess || !validation.ValidPluginID || !validation.ValidSettingIdMatch)
            {
                m_settingsFromBinary.DeleteAll();
                return false;
            }
            return true;
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

        private void ReadPluginSettings(const string[]@ categories = {})
        {
            m_settingsFromPlugin.DeleteAll();
            auto pluginSettings = m_plugin.GetSettings();
            for (uint i = 0; i < pluginSettings.Length; i++)
            {
                if (categories.IsEmpty() || categories.Find(pluginSettings[i].Category) >= 0)
                {
                    @m_settingsFromPlugin[tostring(Hash16(pluginSettings[i].VarName))] = pluginSettings[i];
                }
            }
        }
    }
}

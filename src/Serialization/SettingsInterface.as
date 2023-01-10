
namespace Serialization
{
    class SettingsInterface
    {
        private string m_pluginId;
        private Serialization::SettingsSerializer m_serializer;
        // Dictionary Format: string, Serialization::SettingsDataItem@
        private dictionary m_settingsFromBinary;
        private string[] m_settingCategories;

        SettingsInterface()
        {
        }

        void Initialize(const string&in pluginId, Serialization::SettingsSerializationValidation@ validation, const string[] settingCategories = {})
        {
            m_pluginId = pluginId;
            validation.ResetSerialization();
            validation.ValidPluginObject = Meta::GetPluginFromID(m_pluginId) !is null;
            m_settingsFromBinary.DeleteAll();
            m_settingCategories = settingCategories;
        }

        bool ReadAndValidateBinary(const string&in inputBase64String, Serialization::SettingsSerializationValidation@ validation)
        {
            validation.ResetSerialization();
            Meta::Plugin@ pluginObject = Meta::GetPluginFromID(m_pluginId);
            validation.ValidPluginObject = pluginObject !is null;
            if (!validation.ValidPluginObject) { return false; }

            dictionary settingsFromPlugin;
            ReadPluginSettings(pluginObject, settingsFromPlugin);

            uint8 pluginIdFromBinary;
            bool readSuccess = m_serializer.ReadFromBinary(inputBase64String, pluginIdFromBinary, m_settingsFromBinary, validation);

            validation.ValidPluginID = pluginIdFromBinary == Hash8(pluginObject.Name);

            if (readSuccess && validation.ValidPluginID)
            {
                validation.ValidSettingIdMatch = true;
                string[]@ keys = m_settingsFromBinary.GetKeys();
                for (uint i = 0; i < keys.Length; i++)
                {
                    auto bin = cast<Serialization::SettingsDataItem>(m_settingsFromBinary[keys[i]]);
                    if (!settingsFromPlugin.Exists(keys[i])
                        || cast<Meta::PluginSetting>(settingsFromPlugin[keys[i]]).Type != bin.m_SettingType)
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

        bool WriteCurrentToBinary(string&out result, Serialization::SettingsSerializationValidation@ validation)
        {
            Meta::Plugin@ pluginObject = Meta::GetPluginFromID(m_pluginId);
            validation.ValidPluginObject = pluginObject !is null;
            if (!validation.ValidPluginObject) { return false; }

            dictionary settingsFromPlugin;
            ReadPluginSettings(pluginObject, settingsFromPlugin);

            return m_serializer.WriteToBinary(settingsFromPlugin, pluginObject.Name, result);
        }

        bool ApplyBinaryToSettings(Serialization::SettingsSerializationValidation@ validation)
        {
            bool success = true;

            Meta::Plugin@ pluginObject = Meta::GetPluginFromID(m_pluginId);
            validation.ValidPluginObject = pluginObject !is null;
            if (!validation.ValidPluginObject) { return false; }

            dictionary settingsFromPlugin;
            ReadPluginSettings(pluginObject, settingsFromPlugin);

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
                if (settingsFromPlugin.Exists(keys[i]))
                {
                    auto plg = cast<Meta::PluginSetting>(settingsFromPlugin[keys[i]]);
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
                        case Meta::PluginSettingType::Uint8:
                            plg.WriteUint8(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::Uint16:
                            plg.WriteUint16(bin.ReadInt());
                            break;
                        case Meta::PluginSettingType::Uint32:
                            plg.WriteUint32(bin.ReadInt());
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

        // Dictionary Format: string, Meta::PluginSetting@
        private void ReadPluginSettings(Meta::Plugin@ pluginObject, dictionary@ settingsFromPlugin)
        {
            auto pluginSettings = pluginObject.GetSettings();
            for (uint i = 0; i < pluginSettings.Length; i++)
            {
                if (m_settingCategories.IsEmpty() || m_settingCategories.Find(pluginSettings[i].Category) >= 0)
                {
                    @settingsFromPlugin[tostring(Hash16(pluginSettings[i].VarName))] = pluginSettings[i];
                }
            }
#if VERBOSE_SERIALIZATION
            trace("SettingsInterface::ReadPluginSettings - dict:" + tostring(settingsFromPlugin.GetSize()) + " api:" + tostring(pluginSettings.Length));
#endif
        }
    }
}


namespace Interface
{
    class PluginPreset
    {
        private int m_id;
        private string m_binary;
        private string m_name;
        private string m_pluginId;
        private Serialization::SettingsInterface m_serializer;
        private Serialization::SettingsSerializationValidation m_validation;

        int PresetID { get { return m_id; } }

        string Name
        {
            get
            {
                return m_name;
            }
            set
            {
                if (m_name != value)
                {
                    m_name = value;
                    m_validation.ValidPresetName = m_name != "";
                }
            }
        }

        string Binary
        {
            get
            {
                return m_binary;
            }
            set
            {
                if (m_binary != value)
                {
                    m_binary = value;
                    m_serializer.ReadAndValidateBinary(value, m_validation);
                }
            }
        }

        string PluginID
        {
            get
            {
                return m_pluginId;
            }
            set
            {
                if (m_pluginId != value)
                {
                    m_pluginId = value;
                    m_serializer.Initialize(m_pluginId, m_validation);
                }
            }
        }

        string PluginName
        {
            get
            {
                return Meta::GetPluginFromID(PluginID) !is null ? Meta::GetPluginFromID(PluginID).Name : PluginID;
            }
        }

        bool Valid
        {
            get
            {
                return PluginID != "" && Name != "" && Binary != "" && m_validation.Valid;
            }
        }

        PluginPreset()
        {
            m_id = -1;
        }

        PluginPreset(const PluginPreset@[]@ existingPresets)
        {
            m_id = GetNewPresetID(existingPresets);
        }

        int opCmp(PluginPreset@ other)
        {
            return PluginID.opCmp(other.PluginID);
        }

        void ApplySettings()
        {
            bool success = m_serializer.ReadAndValidateBinary(Binary, m_validation);
            if (success)
            {
                m_serializer.ApplyBinaryToSettings(m_validation);
            }
        }

        void ReadSettings()
        {
            bool success = m_serializer.WriteCurrentToBinary(Binary, m_validation);
        }

        void Load(Json::Value object)
        {
            m_id = object["PresetID"];
            Name = object["Name"];
            PluginID = object["PluginID"];
            Binary = object["Binary"];
        }

        Json::Value Save()
        {
            auto object = Json::Object();
            object["PresetID"] = m_id;
            object["Name"] = Name;
            object["PluginID"] = PluginID;
            object["Binary"] = Binary;
            return object;
        }

        void RenderPreset()
        {
            m_validation.RenderValidationStatus();
        }
    }

    int GetNewPresetID(const PluginPreset@[]@ existingPresets)
    {
        int newId = 0;
        while (newId < Serialization::INT32_MAX)
        {
            bool exists = false;

            for (uint i = 0; i < existingPresets.Length; i++)
            {
                if (existingPresets[i].PresetID == newId) { exists = true; break; }
            }

            if (!exists) { break; }

            newId++;
        }
        return newId;
    }
}

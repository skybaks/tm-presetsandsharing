
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

        string get_Name()
        {
            return m_name;
        }
        void set_Name(const string&in value)
        {
            if (m_name != value)
            {
                m_name = value;
                m_validation.ValidPresetName = m_name != "";
            }
        }

        string get_Binary()
        {
            return m_binary;
        }
        void set_Binary(const string&in value)
        {
            if (m_binary != value)
            {
                m_binary = value;
                m_serializer.ReadAndValidateBinary(value, m_validation);
            }
        }

        string get_PluginID()
        {
            return m_pluginId;
        }
        void set_PluginID(const string&in value)
        {
            if (m_pluginId != value)
            {
                m_pluginId = value;
                m_serializer.Initialize(m_pluginId, m_validation);
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
            m_id = GetNewPresetID();
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

    int GetNewPresetID()
    {
        int newId = 0;
        while (newId < Serialization::INT32_MAX)
        {
            bool exists = false;
            for (uint i = 0; i < g_presets.Length; i++)
            {
                if (g_presets[i].PresetID == newId) { exists = true; break; }
            }
            if (!exists) { break; }
            newId++;
        }
        return newId;
    }

    PluginPreset@ GetPresetFromID(const int id)
    {
        PluginPreset@ preset = null;
        for (uint i = 0; i < g_presets.Length; i++)
        {
            if (id == g_presets[i].PresetID)
            {
                @preset = g_presets[i];
                break;
            }
        }
        return preset;
    }
}

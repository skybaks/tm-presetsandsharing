
namespace Interface
{
    class PluginPreset
    {
        private string m_binary;
        private string m_name;
        private Meta::Plugin@ m_plugin;
        private Serialization::SettingsInterface m_serializer;

        string Name { get { return m_name; } set { m_name = value; } }

        string Binary
        {
            get const
            {
                return m_binary;
            }
            set
            {
                if (m_binary != value && m_serializer.ReadAndValidateBinary(value))
                {
                    m_binary = value;
                }
            }
        }

        string PluginID
        {
            get
            {
                return m_plugin !is null ? m_plugin.ID : "";
            }
            set
            {
                if (m_plugin is null)
                {
                    @m_plugin = Meta::GetPluginFromID(value);
                    m_serializer.Initialize(m_plugin);
                }
            }
        }

        bool Valid
        {
            get
            {
                return m_plugin !is null && Name != "" && Binary != "";
            }
        }

        PluginPreset()
        {
        }

        int opCmp(PluginPreset@ other)
        {
            return PluginID.opCmp(other.PluginID);
        }

        void ApplySettings()
        {
            bool success = m_serializer.ReadAndValidateBinary(Binary);
            if (success)
            {
                m_serializer.ApplyBinaryToSettings();
            }
        }

        void ReadSettings()
        {
            m_serializer.Initialize(m_plugin);
            bool success = m_serializer.WriteCurrentToBinary(Binary);
        }

        void Load(Json::Value object)
        {
            Name = object["Name"];
            PluginID = object["PluginID"];
            Binary = object["Binary"];
        }

        Json::Value Save()
        {
            auto object = Json::Object();
            object["Name"] = Name;
            object["PluginID"] = PluginID;
            object["Binary"] = Binary;
            return object;
        }
    }
}

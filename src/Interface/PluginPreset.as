
namespace Interface
{
    class PluginPreset
    {
        private string m_binary;
        private string m_name;
        private Meta::Plugin@ m_plugin;
        private Serialization::SettingsInterface m_serializer;

        string Binary { get const { return m_binary; } set { m_binary = value; } }
        string Name { get { return m_name; } set { m_name = value; } }

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
                return m_plugin !is null && Name != "" && Binary != "" && m_serializer.ReadAndValidateBinary(Binary);
            }
        }

        PluginPreset()
        {
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

        // TODO: Read From/Write To Json

    }
}

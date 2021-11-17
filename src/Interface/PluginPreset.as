
namespace Interface
{
    class PluginPreset
    {
        dictionary Categories;  // string:bool

        private string m_binary;
        private string m_name;
        private Meta::Plugin@ m_plugin;
        private Serialization::SettingsInterface m_serializer;

        string Binary { get const { return m_binary; } set { m_binary = value; } }
        string Name { get { return m_name; } set { m_name = value; } }

        PluginPreset(const string&in pluginId)
        {
            SetPlugin(pluginId);
        }

        void SetPlugin(const string&in pluginId)
        {
            @m_plugin = Meta::GetPluginFromID(pluginId);
            UpdateSettingCategories();
        }

        void ApplySettings()
        {
            m_serializer.Initialize(m_plugin, GetSelectedCategories());
            bool success = m_serializer.ReadAndValidateBinary(Binary);
            if (success)
            {
                m_serializer.ApplyBinaryToSettings();
            }
        }

        void ReadSettings()
        {
            m_serializer.Initialize(m_plugin, GetSelectedCategories());
            bool success = m_serializer.WriteCurrentToBinary(Binary);
        }

        // TODO: Read From/Write To Json

        private void UpdateSettingCategories()
        {
            Categories.DeleteAll();
            auto settings = m_plugin.GetSettings();
            if (settings.Length > 1)
            {
                for (uint i = 0; i < settings.Length; i++)
                {
                    Categories[settings[i].Category] = false;
                }
            }
        }

        private string[] GetSelectedCategories()
        {
            string[] selected = {};
            if (Categories.GetSize() > 1)
            {
                auto keys = Categories.GetKeys();
                for (uint i = 0; i < keys.Length; i++)
                {
                    if (bool(Categories[keys[i]]))
                    {
                        selected.InsertLast(keys[i]);
                    }
                }
            }
            return selected;
        }
    }
}

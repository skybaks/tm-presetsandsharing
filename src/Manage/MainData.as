
namespace Manage
{
    class MainData
    {
        // Format: string, PresetManager@
        private dictionary m_presetManagers;
        private string m_selectedPluginName;

        MainData()
        {
            UpdateAvailablePlugins();
        }

        string GetSelectedPluginName()
        {
            return m_selectedPluginName;
        }

        void SetSelectedPluginName(const string&in pluginName)
        {
            m_selectedPluginName = pluginName;
        }

        string[]@ GetPluginNames()
        {
            return m_presetManagers.GetKeys();
        }

        PresetManager@ GetSelectedManager()
        {
            PresetManager@ manager = null;
            if (m_presetManagers.Exists(m_selectedPluginName))
            {
                @manager = cast<PresetManager>(m_presetManagers[m_selectedPluginName]);
            }
            return manager;
        }

        private void UpdateAvailablePlugins()
        {
            auto allPlugins = Meta::AllPlugins();
            for (uint i = 0; i < allPlugins.Length; i++)
            {
                if (!m_presetManagers.Exists(allPlugins[i].Name)
                    && allPlugins[i] !is Meta::ExecutingPlugin()
                    && allPlugins[i].GetSettings().Length > 0)
                {
                    @m_presetManagers[allPlugins[i].Name] = PresetManager(allPlugins[i]);
                }
            }
        }
    }
}

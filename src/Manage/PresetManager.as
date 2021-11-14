
namespace Manage
{
    class PresetManager
    {
        // Format: string, PluginPreset@
        private dictionary m_presets;
        private Serialization::SettingsInterface m_serial;
        private Meta::Plugin@ m_plugin;
        // Format: string, bool
        private dictionary m_selectedPluginSettingCategories;
        private string m_selectedPreset;

        string m_workingPresetName;

        PresetManager(Meta::Plugin@ plugin)
        {
            @m_plugin = plugin;
            UpdateSettingCategories();
        }

        string[]@ GetPresetNames()
        {
            return m_presets.GetKeys();
        }

        string[]@ GetSettingCategoryNames()
        {
            return m_selectedPluginSettingCategories.GetKeys();
        }

        string GetSelectedPresetName()
        {
            return m_selectedPreset;
        }

        void SetSelectedPresetName(const string&in presetName)
        {
            m_selectedPreset = presetName;
            m_workingPresetName = presetName;
        }

        PluginPreset@ GetSelectedPreset()
        {
            PluginPreset@ currPreset = null;
            if (m_presets.Exists(m_selectedPreset))
            {
                @currPreset = cast<PluginPreset>(m_presets[m_selectedPreset]);
            }
            return currPreset;
        }

        bool GetCategorySelected(const string&in categoryName)
        {
            bool selected = false;
            if (m_selectedPluginSettingCategories.Exists(categoryName))
            {
                selected = bool(m_selectedPluginSettingCategories[categoryName]);
            }
            return selected;
        }

        void SetCategorySelected(const string&in categoryName, bool selected)
        {
            if (m_selectedPluginSettingCategories.Exists(categoryName))
            {
                m_selectedPluginSettingCategories[categoryName] = selected;
            }
        }

        void AddOrUpdatePreset(const string&in presetName)
        {
            m_selectedPreset = presetName;
            string[] categories = {};
            if (m_selectedPluginSettingCategories.GetSize() > 1)
            {
                for (uint i = 0; i < m_selectedPluginSettingCategories.GetKeys().Length; i++)
                {
                    if (bool(m_selectedPluginSettingCategories[m_selectedPluginSettingCategories.GetKeys()[i]]))
                    {
                        categories.InsertLast(m_selectedPluginSettingCategories.GetKeys()[i]);
                    }
                }
            }
            @m_presets[presetName] = PluginPreset(categories);
            auto currPreset = cast<PluginPreset>(m_presets[presetName]);
            m_serial.Initialize(m_plugin, currPreset.Categories);
            bool success = m_serial.WriteCurrentToBinary(currPreset.Binary);
        }

        void RemovePreset(const string&in presetName)
        {
            if (m_presets.Exists(presetName))
            {
                m_presets.Delete(presetName);
            }
        }

        private void UpdateSettingCategories()
        {
            m_selectedPluginSettingCategories.DeleteAll();
            auto settings = m_plugin.GetSettings();
            for (uint i = 0; i < settings.Length; i++)
            {
                m_selectedPluginSettingCategories[settings[i].Category] = false;
            }
        }
    }
}

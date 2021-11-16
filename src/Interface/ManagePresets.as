
namespace Interface
{
    class ManagePresets
    {
        // TODO: default false after done debugging
        private bool m_windowVisible = true;
        private string m_menuName = "\\$9cf" + Icons::Sliders + "\\$fff Presets";
        private string m_windowName = Icons::Sliders + " Manage Presets";
        private PluginPreset@[] m_presets;
        private string m_selectedPluginId = "";
        private PluginPreset@ m_workingPreset = null;

        private string SelectedPluginId
        {
            get
            {
                return m_selectedPluginId;
            }
            set
            {
                if (value != m_selectedPluginId)
                {
                    m_selectedPluginId = value;
                    @m_workingPreset = PluginPreset(m_selectedPluginId);
                }
            }
        }

        ManagePresets()
        {
        }

        void RenderWindow()
        {
            if (m_windowVisible)
            {
                UI::Begin(m_windowName, m_windowVisible);

                UI::BeginTabBar("##OverallTabBar.ManagePresets.RenderWindow");
                if (UI::BeginTabItem("Preset"))
                {
                    RenderPresetTab();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Sharing"))
                {
                    RenderSharingTab();
                    UI::EndTabItem();
                }
                UI::EndTabBar();

                UI::End();
            }
        }

        void RenderMenu()
        {
            if (UI::BeginMenu(m_menuName))
            {
                if (m_presets.Length > 0)
                {
                    for (uint i = 0; i < m_presets.Length; i++)
                    {
                        if (UI::MenuItem(m_presets[i].Name))
                        {
                            m_presets[i].ApplySettings();
                        }
                    }
                }
                else
                {
                    UI::MenuItem("No Presets", enabled: false);
                }

                UI::Separator();

                if (UI::MenuItem(Icons::Cog + " Manage Presets"))
                {
                    m_windowVisible = true;
                }
                UI::EndMenu();
            }
        }

        private void RenderPresetTab()
        {
            auto plugins = Meta::AllPlugins();
            if (UI::BeginCombo("Plugin##ManagePresets.RenderWindow", SelectedPluginId))
            {
                for (uint i = 0; i < plugins.Length; i++)
                {
                    if (plugins[i] !is Meta::ExecutingPlugin() && plugins[i].GetSettings().Length > 0)
                    {
                        if (UI::Selectable(plugins[i].ID + "##Plugin.ID." + tostring(i), false))
                        {
                            SelectedPluginId = plugins[i].ID;
                        }
                    }
                }
                UI::EndCombo();
            }

            if (m_workingPreset !is null)
            {
                m_workingPreset.Name = UI::InputText("Preset Name##ManagePresets.RenderWindow", m_workingPreset.Name);

                if (m_workingPreset.Categories.GetSize() > 0)
                {
                    UI::Text("Selected Categories:");
                    auto catKeys = m_workingPreset.Categories.GetKeys();
                    for (uint i = 0; i < catKeys.Length; i++)
                    {
                        bool selected = bool(m_workingPreset.Categories[catKeys[i]]);
                        selected = UI::Checkbox(catKeys[i] + "##ManagePresets.RenderWindow", selected);
                        m_workingPreset.Categories[catKeys[i]] = selected;
                    }
                }
                if (UI::Button(Icons::PencilSquare + " Create/Update"))
                {
                    int searchIndex = m_presets.FindByRef(m_workingPreset);
                    if (searchIndex < 0)
                    {
                        m_presets.InsertLast(m_workingPreset);
                    }

                    m_workingPreset.ReadSettings();
                }
                UI::SameLine();
                if (UI::Button(Icons::Trash + " Remove"))
                {
                    int searchIndex = m_presets.FindByRef(m_workingPreset);
                    if (searchIndex >= 0)
                    {
                        m_presets.RemoveAt(searchIndex);
                    }
                }
                UI::Text("Serialized:");
                UI::InputText("##Preset:ManagePresets.RenderWindow", m_workingPreset.Binary, UI::InputTextFlags(UI::InputTextFlags::ReadOnly | UI::InputTextFlags::NoHorizontalScroll));
                UI::SameLine();
                if (UI::Button(Icons::FilesO))
                {
                    IO::SetClipboard(m_workingPreset.Binary);
                }
            }
        }

        private void RenderSharingTab()
        {
        }
    }
}

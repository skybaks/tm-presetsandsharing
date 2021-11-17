
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
        private bool m_jumpToTabEdit = false;

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
                    if (m_workingPreset !is null)
                    {
                        m_workingPreset.SetPlugin(m_selectedPluginId);
                    }
                    else
                    {
                        @m_workingPreset = PluginPreset(m_selectedPluginId);
                    }
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
                if (UI::BeginTabItem("Presets"))
                {
                    RenderPresetTab();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Edit", m_jumpToTabEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                {
                    m_jumpToTabEdit = false;
                    RenderPresetEditTab();
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
            if (UI::BeginTable("PresetsTabTable", 3 /* col */))
            {
                UI::TableSetupColumn("Preset", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Edit", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableSetupColumn("Delete", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);

                for (uint i = 0; i < m_presets.Length; i++)
                {
                    UI::TableNextColumn();
                    UI::Text(m_presets[i].Name);

                    UI::TableNextColumn();
                    if (UI::Button(Icons::PencilSquareO))
                    {
                        @m_workingPreset = m_presets[i];
                        m_jumpToTabEdit = true;
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash))
                    {
                    }

                    UI::TableNextRow();
                }
                UI::EndTable();
            }
        }

        private void RenderPresetEditTab()
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

                if (UI::Button(Icons::PencilSquare + " Create/Update"))
                {
                    int searchIndex = m_presets.FindByRef(m_workingPreset);
                    if (searchIndex < 0)
                    {
                        m_presets.InsertLast(m_workingPreset);
                    }

                    m_workingPreset.ReadSettings();
                }
                UI::InputText("##Preset:ManagePresets.RenderWindow", m_workingPreset.Binary, UI::InputTextFlags(UI::InputTextFlags::ReadOnly | UI::InputTextFlags::NoHorizontalScroll));
                UI::SameLine();
                if (UI::Button(Icons::FilesO))
                {
                    IO::SetClipboard(m_workingPreset.Binary);
                }
            }
        }
    }
}

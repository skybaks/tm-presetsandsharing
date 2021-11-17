
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
        private string m_importBinaryString = "";

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
                if (m_workingPreset !is null && UI::BeginTabItem("Edit", m_jumpToTabEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
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
                        if (UI::MenuItem(m_presets[i].Name + "##PresetMenuItem." + tostring(i)))
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
            if (UI::Button(Icons::Plus))
            {
                @m_workingPreset = PluginPreset();
                m_selectedPluginId = "";
                m_jumpToTabEdit = true;
            }
            UI::SameLine();
            UI::Text("Create New");

            if (UI::BeginTable("PresetsTabTable", 3 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings)))
            {
                UI::TableSetupColumn("Preset", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Edit", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableSetupColumn("Delete", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);

                for (uint i = 0; i < m_presets.Length; i++)
                {
                    UI::TableNextColumn();
                    UI::Text(m_presets[i].Name);

                    UI::TableNextColumn();
                    if (UI::Button(Icons::PencilSquareO + "##PresetsTabTable.Edit." + tostring(i)))
                    {
                        @m_workingPreset = m_presets[i];
                        m_selectedPluginId = m_workingPreset.PluginID;
                        m_jumpToTabEdit = true;
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash + "##PresetsTabTable.Delete." + tostring(i)))
                    {
                        if (m_presets[i] is m_workingPreset)
                        {
                            @m_workingPreset = null;
                        }
                        m_presets.RemoveAt(i);
                    }

                    UI::TableNextRow();
                }
                UI::EndTable();
            }
        }

        private void RenderPresetEditTab()
        {
            UI::BeginDisabled(SelectedPluginId != "");

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

            UI::EndDisabled();
            UI::BeginDisabled(SelectedPluginId == "");

            m_workingPreset.Name = UI::InputText("Preset Name##ManagePresets.RenderWindow", m_workingPreset.Name);

            if (UI::BeginTable("PresetSavingTable", 2 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings)))
            {
                UI::TableSetupColumn("Save from Existing", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Import from External", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableHeadersRow();

                UI::TableNextColumn();
                if (UI::Button(Icons::FilesO))
                {
                    IO::SetClipboard(m_workingPreset.Binary);
                }
                UI::SameLine();
                UI::InputText("##Preset:ManagePresets.RenderWindow", m_workingPreset.Binary, UI::InputTextFlags(UI::InputTextFlags::ReadOnly | UI::InputTextFlags::NoHorizontalScroll));
                if (UI::Button(Icons::FloppyO))
                {
                    int searchIndex = m_presets.FindByRef(m_workingPreset);
                    if (searchIndex < 0)
                    {
                        m_presets.InsertLast(m_workingPreset);
                    }
                    m_workingPreset.ReadSettings();
                }

                UI::TableNextColumn();
                // TODO: icon
                if (UI::Button("Import") && m_importBinaryString != "")
                {
                    m_workingPreset.Binary = m_importBinaryString;
                    m_workingPreset.ApplySettings();
                }
                UI::SameLine();
                m_importBinaryString = UI::InputText("##Import:ManagePresets.RenderWindow", m_importBinaryString, UI::InputTextFlags(UI::InputTextFlags::NoHorizontalScroll));

                UI::EndTable();
            }

            UI::EndDisabled();
        }
    }
}

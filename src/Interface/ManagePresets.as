
namespace Interface
{
    class ManagePresets
    {
        private bool m_windowVisible = false;
        private string m_menuName = "\\$9cf" + Icons::Sliders + "\\$fff Presets";
        private string m_windowName = Icons::Sliders + " Manage Presets";
        private PluginPreset@[] m_presets;
        private PluginPreset@ m_workingPreset = null;
        private bool m_jumpToTabEdit = false;
        private string m_importBinaryString = "";

        ManagePresets()
        {
        }

        void RenderWindow()
        {
            if (m_windowVisible)
            {
                UI::SetNextWindowSize(500, 400, UI::Cond::Once);
                UI::Begin(m_windowName, m_windowVisible);

                if (!m_windowVisible)
                {
                    Save();
                }

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
                int presetsVisible = 0;
                switch (Setting_General_PresetListType)
                {
                    case PresetListType::Uncategorized:
                        presetsVisible = RenderPresetMenuUncategorized();
                        break;
                    case PresetListType::Categorized:
                        presetsVisible = RenderPresetMenuCategorized();
                        break;
                    default:
                        break;
                }
                if (presetsVisible <= 0)
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

        private int RenderPresetMenuUncategorized()
        {
            int presetsShown = 0;
            for (uint i = 0; i < m_presets.Length; i++)
            {
                if (m_presets[i].Valid)
                {
                    presetsShown++;
                    if (UI::MenuItem(m_presets[i].Name + "##PresetMenuItem." + tostring(i)))
                    {
                        m_presets[i].ApplySettings();
                    }
                }
            }
            return presetsShown;
        }

        private int RenderPresetMenuCategorized()
        {
            int presetsShown = 0;
            string currPluginId = "";
            for (uint i = 0; i < m_presets.Length; i++)
            {
                if (m_presets[i].Valid)
                {
                    if (m_presets[i].PluginID != currPluginId)
                    {
                        currPluginId = m_presets[i].PluginID;
                        UI::Separator();
                        UI::MenuItem(Icons::Sliders + " " + currPluginId + "##PluginHeader", enabled:false);
                    }
                    presetsShown++;
                    if (UI::MenuItem(m_presets[i].Name + "##PresetMenuItem." + tostring(i)))
                    {
                        m_presets[i].ApplySettings();
                    }
                }
            }
            return presetsShown;
        }

        private void RenderPresetTab()
        {
            if (UI::Button(Icons::Plus + " Create New"))
            {
                @m_workingPreset = PluginPreset();
                m_presets.InsertLast(m_workingPreset);
                m_importBinaryString = "";
                m_jumpToTabEdit = true;
            }

            UI::Separator();

            if (UI::BeginTable("PresetsTabTable", 4 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings)))
            {
                UI::TableSetupColumn("##Valid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 15);
                UI::TableSetupColumn("##Preset", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("##Edit", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableSetupColumn("##Delete", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);

                for (uint i = 0; i < m_presets.Length; i++)
                {
                    UI::TableNextColumn();
                    UI::Text(m_presets[i].Valid ? "\\$0b0" + Icons::Kenney::Check : "\\$b00" + Icons::Kenney::Times);

                    UI::TableNextColumn();
                    UI::Text(m_presets[i].Name + "\\$aaa - " + m_presets[i].PluginID);

                    UI::TableNextColumn();
                    if (UI::Button(Icons::PencilSquareO + "##PresetsTabTable.Edit." + tostring(i)))
                    {
                        @m_workingPreset = m_presets[i];
                        m_importBinaryString = "";
                        m_jumpToTabEdit = true;
                        if (m_workingPreset.Valid)
                        {
                            m_workingPreset.ApplySettings();
                        }
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash + "##PresetsTabTable.Delete." + tostring(i)))
                    {
                        if (m_presets[i] is m_workingPreset)
                        {
                            @m_workingPreset = null;
                            m_importBinaryString = "";
                        }
                        m_presets.RemoveAt(i);
                        m_presets.SortAsc();
                    }

                    UI::TableNextRow();
                }
                UI::EndTable();
            }
        }

        private void RenderPresetEditTab()
        {
            UI::BeginDisabled(m_workingPreset.PluginID != "");

            auto plugins = Meta::AllPlugins();
            if (UI::BeginCombo("Plugin##ManagePresets.RenderWindow", m_workingPreset.PluginID))
            {
                for (uint i = 0; i < plugins.Length; i++)
                {
                    if (plugins[i] !is Meta::ExecutingPlugin()
                        && plugins[i].GetSettings().Length > 0
                        && plugins[i].Enabled)
                    {
                        if (UI::Selectable(plugins[i].ID + "##Plugin.ID." + tostring(i), false))
                        {
                            m_workingPreset.PluginID = plugins[i].ID;
                            m_presets.SortAsc();
                        }
                    }
                }
                UI::EndCombo();
            }

            UI::EndDisabled();
            UI::BeginDisabled(m_workingPreset.PluginID == "");

            m_workingPreset.Name = UI::InputText("Preset Name##ManagePresets.RenderWindow", m_workingPreset.Name);

            if (UI::BeginTable("PresetSavingTable", 2 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings)))
            {
                UI::TableSetupColumn("Save Current Settings", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Import from External", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));

                UI::TableNextColumn();
                Tooltip::Show("Save your current pluing settings to text. Then copy the text and send it to you friends!", true);
                UI::SameLine();
                UI::Text("Save Current Settings");

                UI::TableNextColumn();
                Tooltip::Show("Import and apply settings from your friends! Paste settings text in the box and click \"Import\".", true);
                UI::SameLine();
                UI::Text("Import Shared Settings");

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::InputText("##Preset:ManagePresets.RenderWindow", m_workingPreset.Binary, UI::InputTextFlags(UI::InputTextFlags::ReadOnly | UI::InputTextFlags::NoHorizontalScroll));
                UI::SameLine();
                if (UI::Button(Icons::Clipboard + "##PresetExport"))
                {
                    IO::SetClipboard(m_workingPreset.Binary);
                }
                if (UI::Button("Update"))
                {
                    m_workingPreset.ReadSettings();
                }

                UI::TableNextColumn();
                m_importBinaryString = UI::InputText("##Import:ManagePresets.RenderWindow", m_importBinaryString, UI::InputTextFlags(UI::InputTextFlags::NoHorizontalScroll));
                if (UI::Button("Import") && m_importBinaryString != "")
                {
                    m_workingPreset.Binary = m_importBinaryString;
                    m_workingPreset.ApplySettings();
                    m_importBinaryString = "";
                }

                UI::EndTable();
            }

            UI::Separator();

            m_workingPreset.RenderPreset();

            UI::EndDisabled();
        }

        void Save()
        {
            trace("Saving presets");

            auto value = Json::Object();
            value["Settings"] = "PresetsAndSharing";
            value["Version"] = Meta::ExecutingPlugin().Version;
            value["Presets"] = Json::Array();
            for (uint i = 0; i < m_presets.Length; i++)
            {
                if (m_presets[i].Valid)
                {
                    value["Presets"].Add(m_presets[i].Save());
                }
            }
            Json::ToFile(IO::FromDataFolder("PresetsAndSharing.json"), value);
        }

        void Load()
        {
            if (IO::FileExists(IO::FromDataFolder("PresetsAndSharing.json")))
            {
                auto value = Json::FromFile(IO::FromDataFolder("PresetsAndSharing.json"));
                if (value.HasKey("Settings")
                    && string(value["Settings"]) == "PresetsAndSharing"
                    && value.HasKey("Presets"))
                {
                    for (uint i = 0; i < value["Presets"].Length; i++)
                    {
                        auto newPreset = PluginPreset();
                        newPreset.Load(value["Presets"][i]);
                        m_presets.InsertLast(newPreset);
                    }
                }
            }
        }
    }
}

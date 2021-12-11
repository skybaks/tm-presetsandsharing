#if !UNIT_TEST

namespace Interface
{
    class ManagePresets
    {
        private bool m_windowVisible = false;
        private string m_menuName = "\\$9cf" + Icons::Sliders + "\\$fff Presets";
        private string m_windowName = Icons::Sliders + " Manage Presets And Loadouts";
        private PluginPreset@ m_workingPreset = null;
        private PresetLoadout@ m_workingLoadout = null;
        private bool m_jumpToTabPresetEdit = false;
        private bool m_jumpToTabLoadoutEdit = false;
        private string m_importBinaryString = "";

        ManagePresets()
        {
#if DEV_MODE
            m_windowVisible = true;
#endif
        }

        void RenderWindow()
        {
            if (m_windowVisible)
            {
                UI::SetNextWindowSize(500, 600, UI::Cond::Once);
                UI::Begin(m_windowName, m_windowVisible);

                if (!m_windowVisible)
                {
                    Save();
                }

                UI::BeginTabBar("##OverallTabBar.ManagePresets.RenderWindow");
                if (UI::BeginTabItem("Loadouts"))
                {
                    RenderLoadoutTab();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Presets"))
                {
                    RenderPresetTab();
                    UI::EndTabItem();
                }
                bool loadoutEditTabVisible = m_workingLoadout !is null;
                if (m_workingLoadout !is null)
                {
                    if (UI::BeginTabItem("Edit Loadout", loadoutEditTabVisible, m_jumpToTabLoadoutEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                    {
                        m_jumpToTabLoadoutEdit = false;
                        if (loadoutEditTabVisible)
                        {
                            RenderLoadoutEditTab();
                        }
                        UI::EndTabItem();
                    }
                    if (!loadoutEditTabVisible)
                    {
                        @m_workingLoadout = null;
                    }
                }
                bool presetEditTabVisible = m_workingPreset !is null;
                if (m_workingPreset !is null)
                {
                    if (UI::BeginTabItem("Edit Preset", presetEditTabVisible, m_jumpToTabPresetEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                    {
                        m_jumpToTabPresetEdit = false;
                        if (presetEditTabVisible)
                        {
                            RenderPresetEditTab();
                        }
                        UI::EndTabItem();
                    }
                    if (!presetEditTabVisible)
                    {
                        @m_workingPreset = null;
                    }
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
            for (uint i = 0; i < g_presets.Length; i++)
            {
                if (g_presets[i].Valid)
                {
                    presetsShown++;
                    if (UI::MenuItem(g_presets[i].Name + "##PresetMenuItem." + tostring(i)))
                    {
                        g_presets[i].ApplySettings();
                    }
                }
            }
            return presetsShown;
        }

        private int RenderPresetMenuCategorized()
        {
            int presetsShown = 0;
            string currPluginId = "";
            for (uint i = 0; i < g_presets.Length; i++)
            {
                if (g_presets[i].Valid)
                {
                    if (g_presets[i].PluginName != currPluginId)
                    {
                        currPluginId = g_presets[i].PluginName;
                        UI::Separator();
                        UI::MenuItem(Icons::Sliders + " " + currPluginId + "##PluginHeader", enabled:false);
                    }
                    presetsShown++;
                    if (UI::MenuItem(g_presets[i].Name + "##PresetMenuItem." + tostring(i)))
                    {
                        g_presets[i].ApplySettings();
                    }
                }
            }
            return presetsShown;
        }

        private void RenderLoadoutTab()
        {
            if (!Setting_General_HideVerboseHelp)
            {
                Tooltip::Show(Help::g_verboseHelpTooltip, postfix: "LoadoutTab_HelpText_Overall");
                UI::SameLine();
                UI::TextWrapped(Help::g_LoadoutCreationHelpText);
                UI::Separator();
            }

            if (UI::Button(Icons::Plus + " Create New##RenderLoadoutTab.NewLoadout"))
            {
                @m_workingLoadout = PresetLoadout();
                g_loadouts.InsertLast(m_workingLoadout);
                m_jumpToTabLoadoutEdit = true;
            }

            UI::Text("\\$f00TODO: Loadout table goes here");
        }

        private void RenderLoadoutEditTab()
        {
            if (!Setting_General_HideVerboseHelp)
            {
                Tooltip::Show(Help::g_verboseHelpTooltip, postfix: "LoadoutEditTab_HelpText_Overall");
                UI::SameLine();
                UI::TextWrapped(Help::g_LoadoutEditHelpText);
                UI::Separator();
            }
        }

        private void RenderPresetTab()
        {
            if (!Setting_General_HideVerboseHelp)
            {
                Tooltip::Show(Help::g_verboseHelpTooltip, postfix: "PresetTab_HelpText_Overall");
                UI::SameLine();
                UI::TextWrapped(Help::g_PresetCreationHelpText);
                UI::Separator();
            }

            if (UI::Button(Icons::Plus + " Create New##RenderPresetTab.NewPreset"))
            {
                @m_workingPreset = PluginPreset();
                g_presets.InsertLast(m_workingPreset);
                m_importBinaryString = "";
                m_jumpToTabPresetEdit = true;
            }

            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0, 0.0, 0.0, 0.3));
            if (UI::BeginTable("PresetsTabTable", 5 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings | UI::TableFlags::ScrollY | UI::TableFlags::RowBg)))
            {
                UI::TableSetupColumn("##Valid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 15);
                UI::TableSetupColumn("Preset##Preset", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Plugin##Plugin", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 100);
                UI::TableSetupColumn("##Edit", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableSetupColumn("##Delete", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableHeadersRow();

                for (uint i = 0; i < g_presets.Length; i++)
                {
                    UI::TableNextColumn();
                    UI::Text(g_presets[i].Valid ? "\\$0b0" + Icons::Kenney::Check : "\\$b00" + Icons::Kenney::Times);

                    UI::TableNextColumn();
                    UI::Text(g_presets[i].Name);

                    UI::TableNextColumn();
                    UI::Text("\\$aaa" + g_presets[i].PluginName);

                    UI::TableNextColumn();
                    if (UI::Button(Icons::PencilSquareO + "##PresetsTabTable.Edit." + tostring(i)))
                    {
                        @m_workingPreset = g_presets[i];
                        m_importBinaryString = "";
                        m_jumpToTabPresetEdit = true;
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash + "##PresetsTabTable.Delete." + tostring(i)))
                    {
                        if (g_presets[i] is m_workingPreset)
                        {
                            @m_workingPreset = null;
                            m_importBinaryString = "";
                        }
                        g_presets.RemoveAt(i);
                        g_presets.SortAsc();
                    }

                    UI::TableNextRow();
                }
                UI::EndTable();
            }
            UI::PopStyleColor();
        }

        private void RenderPresetEditTab()
        {
            if (!Setting_General_HideVerboseHelp)
            {
                Tooltip::Show(Help::g_verboseHelpTooltip, postfix: "PresetEditTab_HelpText_Overall");
                UI::SameLine();
                UI::TextWrapped(Help::g_PresetEditHelpText);
                UI::Separator();
            }

            UI::BeginDisabled(m_workingPreset.PluginID != "");

            auto plugins = Meta::AllPlugins();
            if (UI::BeginCombo("Plugin##ManagePresets.RenderWindow", m_workingPreset.PluginName))
            {
                for (uint i = 0; i < plugins.Length; i++)
                {
                    if (plugins[i] !is Meta::ExecutingPlugin()
                        && plugins[i].GetSettings().Length > 0
                        && plugins[i].Enabled)
                    {
                        if (UI::Selectable(plugins[i].Name + "##Plugin.ID." + tostring(i), false))
                        {
                            m_workingPreset.PluginID = plugins[i].ID;
                            g_presets.SortAsc();
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
            UI::EndDisabled();

            UI::Separator();

            m_workingPreset.RenderPreset();

            Tooltip::Show("Applies this preset to the plugin's settings.");
            UI::SameLine();
            UI::BeginDisabled(!m_workingPreset.Valid);
            if (UI::Button("Apply Preset"))
            {
                m_workingPreset.ApplySettings();
            }
            UI::EndDisabled();

        }

        void Save()
        {
            trace("Saving presets");

            auto value = Json::Object();
            value["Settings"] = "PresetsAndSharing";
            value["Version"] = Meta::ExecutingPlugin().Version;
            value["Presets"] = Json::Array();
            for (uint i = 0; i < g_presets.Length; i++)
            {
                value["Presets"].Add(g_presets[i].Save());
            }
            value["Loadouts"] = Json::Array();
            for (uint i = 0; i < g_loadouts.Length; i++)
            {
                value["Loadouts"].Add(g_loadouts[i].Save());
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
                    && value.HasKey("Presets")
                    && value.HasKey("Loadouts"))
                {
                    while (g_presets.Length > 0) { g_presets.RemoveAt(0); }
                    for (uint i = 0; i < value["Presets"].Length; i++)
                    {
                        auto newPreset = PluginPreset();
                        newPreset.Load(value["Presets"][i]);
                        g_presets.InsertLast(newPreset);
                    }

                    while (g_loadouts.Length > 0) { g_loadouts.RemoveAt(0); }
                    for (uint i = 0; i < value["Loadouts"].Length; i++)
                    {
                        auto newLoadout = PresetLoadout();
                        newLoadout.Load(value["Loadouts"][i]);
                        g_loadouts.InsertLast(newLoadout);
                    }
                }
            }
        }
    }
}

#endif
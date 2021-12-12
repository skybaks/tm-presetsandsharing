#if !UNIT_TEST

namespace Interface
{
    enum WindowTabs { None, Preset, Loadout, PresetEdit, LoadoutEdit }

    class ManagePresets
    {
        private bool m_windowVisible = false;
        private string m_presetsMenuName = "\\$9cf" + Icons::Sliders + "\\$fff Presets";
        private string m_loadoutsMenuName = "\\$9cf" + Icons::Sliders + "\\$fff Loadouts";
        private string m_windowName = Icons::Sliders + " Presets and Sharing";
        private PluginPreset@ m_workingPreset = null;
        private PresetLoadout@ m_workingLoadout = null;
        private WindowTabs m_jumpToTab = WindowTabs::None;
        private string m_importBinaryString = "";
        private bool m_globalDisabled = false;
        private bool m_showDialog = false;
        private DialogMessageData m_dialogData;

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
                m_globalDisabled = m_showDialog;
                if (m_globalDisabled) { UI::BeginDisabled(true); }
                UI::SetNextWindowSize(500, 600, UI::Cond::Once);
                UI::WindowFlags mainWindowFlags = UI::WindowFlags::NoCollapse;
                if (m_globalDisabled)
                {
                    mainWindowFlags = UI::WindowFlags(mainWindowFlags | UI::WindowFlags::NoBringToFrontOnFocus);
                }
                UI::Begin(m_windowName, m_windowVisible, mainWindowFlags);

                if (!m_windowVisible)
                {
                    Save();
                }

                UI::BeginTabBar("##OverallTabBar.ManagePresets.RenderWindow");
                if (UI::BeginTabItem("Loadouts", m_jumpToTab == WindowTabs::Loadout ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                {
                    if (m_jumpToTab == WindowTabs::Loadout)
                    {
                        m_jumpToTab = WindowTabs::None;
                    }

                    RenderLoadoutTab();
                    UI::EndTabItem();
                }
                if (UI::BeginTabItem("Presets", m_jumpToTab == WindowTabs::Preset ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                {
                    if (m_jumpToTab == WindowTabs::Preset)
                    {
                        m_jumpToTab = WindowTabs::None;
                    }

                    RenderPresetTab();
                    UI::EndTabItem();
                }
                bool loadoutEditTabVisible = m_workingLoadout !is null;
                if (m_workingLoadout !is null)
                {
                    if (UI::BeginTabItem("Edit Loadout", loadoutEditTabVisible, m_jumpToTab == WindowTabs::LoadoutEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                    {
                        if (m_jumpToTab == WindowTabs::LoadoutEdit)
                        {
                            m_jumpToTab = WindowTabs::None;
                        }

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
                    if (UI::BeginTabItem("Edit Preset", presetEditTabVisible, m_jumpToTab == WindowTabs::PresetEdit ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
                    {
                        if (m_jumpToTab == WindowTabs::PresetEdit)
                        {
                            m_jumpToTab = WindowTabs::None;
                        }

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

                vec2 size = UI::GetWindowSize();
                vec2 pos = UI::GetWindowPos();

                UI::End();
                if (m_globalDisabled) { UI::EndDisabled(); }

                if (m_showDialog)
                {
                    DialogResultType result = RenderShowDialog(m_dialogData.Title, m_dialogData.Body, size, pos);

                    if (result != DialogResultType::Undetermined)
                    {
                        m_showDialog = false;

                        if (result == DialogResultType::Yes)
                        {
                            if (m_dialogData.Target == DialogType::PresetDelete
                                && m_dialogData.TargetIndex >= 0
                                && uint(m_dialogData.TargetIndex) < g_presets.Length)
                            {
                                if (g_presets[m_dialogData.TargetIndex] is m_workingPreset)
                                {
                                    @m_workingPreset = null;
                                    m_importBinaryString = "";
                                }
                                g_presets.RemoveAt(m_dialogData.TargetIndex);
                                g_presets.SortAsc();
                            }
                            else if (m_dialogData.Target == DialogType::LoadoutDelete
                                && m_dialogData.TargetIndex >= 0
                                && uint(m_dialogData.TargetIndex) < g_loadouts.Length)
                            {
                                if (g_loadouts[m_dialogData.TargetIndex] is m_workingLoadout)
                                {
                                    @m_workingLoadout = null;
                                }
                                g_loadouts.RemoveAt(m_dialogData.TargetIndex);
                            }
                        }

                        m_dialogData = DialogMessageData();
                    }
                }
            }
        }

        void RenderMenu()
        {
            if (!Setting_General_PresetListHide && UI::BeginMenu(m_presetsMenuName))
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
                    m_jumpToTab = WindowTabs::Preset;
                    m_windowVisible = true;
                }
                UI::EndMenu();
            }

            if (!Setting_General_LoadoutListHide && UI::BeginMenu(m_loadoutsMenuName))
            {
                int loadoutsVisible = 0;
                for (uint i = 0; i < g_loadouts.Length; i++)
                {
                    loadoutsVisible++;
                    if (UI::MenuItem(g_loadouts[i].Name + "##LoadoutMenuItem." + tostring(i), shortcut: g_loadouts[i].GetHotkeyString()))
                    {
                        g_loadouts[i].ActivatePresets();
                    }
                }
                if (loadoutsVisible <= 0)
                {
                    UI::MenuItem("No Loadouts", enabled: false);
                }

                UI::Separator();

                if (UI::MenuItem(Icons::Cog + " Manage Loadouts"))
                {
                    m_jumpToTab = WindowTabs::Loadout;
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
                m_jumpToTab = WindowTabs::LoadoutEdit;
            }

            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0, 0.0, 0.0, 0.3));
            if (UI::BeginTable("LoadoutsTabTable", 5 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings | UI::TableFlags::ScrollY | UI::TableFlags::RowBg)))
            {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("##Valid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 15);
                UI::TableSetupColumn("Loadout##Loadout", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Hotkey##Hotkey", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 100);
                UI::TableSetupColumn("##Edit", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableSetupColumn("##Delete", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableHeadersRow();

                for (uint i = 0; i < g_loadouts.Length; i++)
                {
                    UI::TableNextColumn();
                    UI::Text("");

                    UI::TableNextColumn();
                    UI::Text(g_loadouts[i].Name);

                    UI::TableNextColumn();
                    UI::TextDisabled(g_loadouts[i].GetHotkeyString());

                    UI::TableNextColumn();
                    if (UI::Button(Icons::PencilSquareO + "##LoadoutsTabTable.Edit." + tostring(i)))
                    {
                        @m_workingLoadout = g_loadouts[i];
                        m_jumpToTab = WindowTabs::LoadoutEdit;
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash + "##LoadoutsTabTable.Delete." + tostring(i)))
                    {
                        m_dialogData.Title = "Delete Loadout";
                        m_dialogData.Body = "\\$fffThis will permanently delete the loadout \\$9cf" + g_loadouts[i].Name + "\\$fff\n\nAre you sure?\n ";
                        m_dialogData.Target = DialogType::LoadoutDelete;
                        m_dialogData.TargetIndex = i;
                        m_showDialog = true;
                    }
                    UI::TableNextRow();
                }
                UI::EndTable();
            }
            UI::PopStyleColor();
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

            m_workingLoadout.Name = UI::InputText("Loadout Name##RenderLoadoutEditTab.LoadoutName", m_workingLoadout.Name);

            if (!m_globalDisabled) { UI::BeginDisabled(!m_workingLoadout.HotkeyActive); }
            if (UI::BeginCombo("##LoadoutHotkeyCombobox", tostring(m_workingLoadout.Hotkey)))
            {
                VirtualKey result = ComboboxVirtualKey();
                if (int(result) != 0)
                {
                    m_workingLoadout.Hotkey = result;
                }
                UI::EndCombo();
            }
            if (!m_globalDisabled) { UI::EndDisabled(); }

            UI::SameLine();
            m_workingLoadout.HotkeyActive = UI::Checkbox("Hotkey Enabled##EnableLoadoutHotkey", m_workingLoadout.HotkeyActive);

            if (UI::BeginCombo("Add Preset##RenderLoadoutEditTab.PresetCombo", "Add a Preset"))
            {
                int[] presetIds = m_workingLoadout.PresetIDs;
                for (uint i = 0; i < g_presets.Length; i++)
                {
                    bool alreadySelected = false;
                    for (uint selPresetIndex = 0; selPresetIndex < presetIds.Length; selPresetIndex++)
                    {
                        if (presetIds[selPresetIndex] == g_presets[i].PresetID)
                        {
                            alreadySelected = true;
                            break;
                        }
                    }

                    if (!alreadySelected)
                    {
                        if (UI::Selectable("\\$aaa" + g_presets[i].PluginName + "\\$fff - " + g_presets[i].Name + "##" + tostring(i), false))
                        {
                            m_workingLoadout.AddPresetID(g_presets[i].PresetID);
                        }
                    }
                }
                UI::EndCombo();
            }

            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0, 0.0, 0.0, 0.3));
            if (UI::BeginTable("LoadoutTableEditCurrentPresetsTable", 4 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings | UI::TableFlags::ScrollY | UI::TableFlags::RowBg)))
            {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("##Valid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 15);
                UI::TableSetupColumn("Preset##PresetName", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));
                UI::TableSetupColumn("Plugin##PresetPlugin", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 100);
                UI::TableSetupColumn("##RemovePreset", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed), 30);
                UI::TableHeadersRow();

                int[] presetIds = m_workingLoadout.PresetIDs;
                for (uint i = 0; i < presetIds.Length; i++)
                {
                    PluginPreset@ preset = GetPresetFromID(presetIds[i]);
                    if (preset is null)
                    {
                        continue;
                    }

                    UI::TableNextColumn();
                    UI::Text(preset.Valid ? "\\$0b0" + Icons::Kenney::Check : "\\$b00" + Icons::Kenney::Times);

                    UI::TableNextColumn();
                    UI::Text(preset.Name);

                    UI::TableNextColumn();
                    UI::Text("\\$aaa" + preset.PluginName);

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Times + "##LoadoutTableEditCurrentPresetsTable.Remove." + tostring(i)))
                    {
                        m_workingLoadout.RemovePresetID(presetIds[i]);
                    }

                }

                UI::EndTable();
            }
            UI::PopStyleColor();
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
                m_jumpToTab = WindowTabs::PresetEdit;
            }

            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0, 0.0, 0.0, 0.3));
            if (UI::BeginTable("PresetsTabTable", 5 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings | UI::TableFlags::ScrollY | UI::TableFlags::RowBg)))
            {
                UI::TableSetupScrollFreeze(0, 1);
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
                        m_jumpToTab = WindowTabs::PresetEdit;
                    }

                    UI::TableNextColumn();
                    if (UI::Button(Icons::Trash + "##PresetsTabTable.Delete." + tostring(i)))
                    {
                        m_dialogData.Title = "Delete Preset";
                        m_dialogData.Body = "\\$fffThis will permanently delete the preset \\$9cf" + g_presets[i].Name + "\\$fff\n\nAre you sure?\n ";
                        m_dialogData.Target = DialogType::PresetDelete;
                        m_dialogData.TargetIndex = i;
                        m_showDialog = true;
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

            if (!m_globalDisabled) { UI::BeginDisabled(m_workingPreset.PluginID != ""); }

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

            if (!m_globalDisabled) { UI::EndDisabled(); }
            if (!m_globalDisabled) { UI::BeginDisabled(m_workingPreset.PluginID == ""); }

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
            if (!m_globalDisabled) { UI::EndDisabled(); }

            UI::Separator();

            m_workingPreset.RenderPreset();

            Tooltip::Show("Applies this preset to the plugin's settings.");
            UI::SameLine();
            if (!m_globalDisabled) { UI::BeginDisabled(!m_workingPreset.Valid); }
            if (UI::Button("Apply Preset"))
            {
                m_workingPreset.ApplySettings();
            }
            if (!m_globalDisabled) { UI::EndDisabled(); }

        }

        void Save()
        {
            print("\\$9cf" + Icons::Sliders + "\\$fff Saving presets");

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
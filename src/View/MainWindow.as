
namespace View
{
    // TODO: default false after done debugging
    bool g_mainWindowVisible = true;

    void RenderInterfaceMainWindow()
    {
        if (g_mainWindowVisible)
        {
            UI::Begin(Icons::Sliders + " Manage Presets", g_mainWindowVisible);

            auto pluginNames = g_data.GetPluginNames();
            if (UI::BeginCombo("Loaded Plugins##OperatingPluginCombo", g_data.GetSelectedPluginName()))
            {
                for (uint i = 0; i < pluginNames.Length; i++)
                {
                    if (UI::Selectable(pluginNames[i] + "##PluginNames" + tostring(i), false))
                    {
                        g_data.SetSelectedPluginName(pluginNames[i]);
                    }
                }
                UI::EndCombo();
            }

            auto currManager = g_data.GetSelectedManager();
            if (currManager !is null)
            {
                auto presetNames = currManager.GetPresetNames();
                if (UI::BeginCombo("Plugin Preset##LoadedPluginPresetCombo", currManager.GetSelectedPresetName()))
                {
                    for (uint i = 0; i < presetNames.Length; i++)
                    {
                        if (UI::Selectable(presetNames[i] + "##PluginPreset" + g_data.GetSelectedPluginName() + tostring(i), false))
                        {
                            currManager.SetSelectedPresetName(presetNames[i]);
                        }
                    }
                    UI::EndCombo();
                }

                string[]@ catNames = currManager.GetSettingCategoryNames();
                if (catNames.Length > 1)
                {
                    UI::Markdown("**Categories:**");
                    for (uint i = 0; i < catNames.Length; i++)
                    {
                        bool isSelected = currManager.GetCategorySelected(catNames[i]);
                        if (UI::Selectable("\t" + (isSelected ? Icons::Kenney::CheckboxChecked : Icons::Kenney::Checkbox) + " " + catNames[i] + "##PluginCategory" + g_data.GetSelectedPluginName() + tostring(i), isSelected))
                        {
                            currManager.SetCategorySelected(catNames[i], !isSelected);
                        }
                    }
                }

                currManager.m_workingPresetName = UI::InputText("Preset Name##PresetNameEditable", currManager.m_workingPresetName);

                if (UI::Button(Icons::File + " Create"))
                {
                    currManager.AddOrUpdatePreset(currManager.m_workingPresetName);
                }
                UI::SameLine();
                if (UI::Button(Icons::PencilSquare + " Rename"))
                {
                }
                UI::SameLine();
                if (UI::Button(Icons::Trash + " Remove"))
                {
                    currManager.RemovePreset(currManager.m_workingPresetName);
                }

                auto currPreset = currManager.GetSelectedPreset();
                if (currPreset !is null)
                {
                    UI::Markdown("**Result:**");
                    UI::InputText("##Preset", currPreset.Binary, UI::InputTextFlags(UI::InputTextFlags::ReadOnly | UI::InputTextFlags::NoHorizontalScroll));
                }
            }

            UI::End();
        }
    }
}

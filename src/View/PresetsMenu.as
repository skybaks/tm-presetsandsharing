
namespace View
{
    void RenderPresetsMenu()
    {
        if (UI::BeginMenu("\\$9cf" + Icons::Sliders + "\\$fff Presets"))
        {
            // TODO: loop through enabled plugins and their defined presets
            if (UI::BeginMenu("Plugin_1"))
            {
                if (UI::MenuItem("Preset 1"))
                {
                }
                if (UI::MenuItem("Preset 2"))
                {
                }
                UI::EndMenu();
            }
            if (UI::BeginMenu("Plugin_2"))
            {
                if (UI::MenuItem("Preset 3"))
                {
                }
                if (UI::MenuItem("Preset 4"))
                {
                }
                UI::EndMenu();
            }
            UI::EndMenu();
        }
    }
}

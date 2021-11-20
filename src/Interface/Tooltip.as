namespace Interface
{
    namespace Tooltip
    {
        const int g_tooltipHoverTimeMs = 500;
        int g_currentHoverTimeMs = 0;
        string g_lastHoverTooltipText = "";

        void Update(int dt)
        {
            g_currentHoverTimeMs += dt;
        }

        void Show(const string&in text, const bool&in includeHelpMarker = true)
        {
            if (includeHelpMarker)
            {
                UI::TextDisabled(Icons::Kenney::QuestionCircle);
            }
            if (UI::IsItemHovered())
            {
                if (text != g_lastHoverTooltipText)
                {
                    g_currentHoverTimeMs = 0;
                    g_lastHoverTooltipText = text;
                }
                else if (g_currentHoverTimeMs >= g_tooltipHoverTimeMs)
                {
                    UI::SetNextWindowSize(300, 10);
                    UI::BeginTooltip();
                    UI::TextWrapped(text);
                    UI::EndTooltip();
                }
            }
            else if (text == g_lastHoverTooltipText)
            {
                g_lastHoverTooltipText = "";
            }
        }
    }
}
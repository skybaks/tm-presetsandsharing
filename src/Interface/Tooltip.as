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

        void Show(const string&in text, const bool&in includeHelpMarker = true, const string&in postfix = "")
        {
            if (includeHelpMarker)
            {
                UI::TextDisabled(Icons::Kenney::QuestionCircle);
            }
            string textPlus = text + postfix;
            if (UI::IsItemHovered())
            {
                if (textPlus != g_lastHoverTooltipText)
                {
                    g_currentHoverTimeMs = 0;
                    g_lastHoverTooltipText = textPlus;
                }
                else if (g_currentHoverTimeMs >= g_tooltipHoverTimeMs)
                {
                    UI::SetNextWindowSize(275, 10);
                    UI::BeginTooltip();
                    UI::TextWrapped(text);
                    UI::EndTooltip();
                }
            }
            else if (textPlus == g_lastHoverTooltipText)
            {
                g_lastHoverTooltipText = "";
            }
        }
    }
}

namespace Serialization
{
    class SettingsSerializationValidation
    {
        private string m_colorValid;
        private string m_colorInvalid;

        private bool m_validPluginObject;
        private bool m_validPresetName;
        private bool m_validParityCheck;
        private bool m_validPluginId;
        private bool m_validSettingTypes;
        private bool m_validSettingIdMatch;
        private bool m_validBinaryDeserialization;

        bool ValidPluginObject { get { return m_validPluginObject; } set { m_validPluginObject = value; } }
        bool ValidPresetName { get { return m_validPresetName; } set { m_validPresetName = value; } }
        bool ValidParityCheck { get { return m_validParityCheck; } set { m_validParityCheck = value; } }
        bool ValidPluginID { get { return m_validPluginId; } set { m_validPluginId = value; } }
        bool ValidSettingTypes { get { return m_validSettingTypes; } set { m_validSettingTypes = value; } }
        bool ValidSettingIdMatch { get { return m_validSettingIdMatch; } set { m_validSettingIdMatch = value; } }
        bool ValidBinaryDeserialization { get { return m_validBinaryDeserialization; } set { m_validBinaryDeserialization = value; } }

        bool Valid
        {
            get
            {
                return
                       ValidPluginObject
                    && ValidPresetName
                    && ValidParityCheck
                    && ValidPluginID
                    && ValidSettingTypes
                    && ValidSettingIdMatch
                    && ValidBinaryDeserialization;
            }
        }

        SettingsSerializationValidation()
        {
            m_colorValid = "\\$0b0";
            m_colorInvalid = "\\$b00";
        }

        void ResetAll()
        {
            ValidPluginObject = false;
            ValidPresetName = false;
            ValidParityCheck = false;
            ValidPluginID = false;
            ValidSettingTypes = false;
            ValidSettingIdMatch = false;
            ValidBinaryDeserialization = false;
        }

        void ResetSerialization()
        {
            ValidPluginObject = false;
            ValidParityCheck = false;
            ValidPluginID = false;
            ValidSettingTypes = false;
            ValidSettingIdMatch = false;
            ValidBinaryDeserialization = false;
        }

        void RenderValidationStatus()
        {
            if (UI::BeginTable("SerializationValidationResultTable", 2 /* col */, UI::TableFlags(UI::TableFlags::NoSavedSettings)))
            {
                UI::TableSetupColumn("##Valid", UI::TableColumnFlags(UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::DefaultSort), 15);
                UI::TableSetupColumn("##CheckName", UI::TableColumnFlags(UI::TableColumnFlags::WidthStretch));

                RenderValidationTableLine(ValidPluginObject, "Plugin set", "Plugin not set or invalid");
                RenderValidationTableLine(ValidPresetName, "Preset name set", "Preset name not set or invalid");
                RenderValidationTableLine(ValidParityCheck, "Parity check passed", "Parity check failed");
                RenderValidationTableLine(ValidPluginID, "Plugin ID matches", "Plugin ID mismatch");
                RenderValidationTableLine(ValidSettingTypes, "Setting types valid", "Invalid setting types");
                RenderValidationTableLine(ValidSettingIdMatch, "Setting IDs match", "Setting ID mismatch");
                RenderValidationTableLine(ValidBinaryDeserialization, "Success reading binary settings", "Error reading binary settings");

                UI::EndTable();
            }
        }

        private void RenderValidationTableLine(const bool&in valid, const string&in textValid, const string&in textInvalid)
        {
            UI::TableNextColumn();
            UI::Text(valid ? "\\$0b0" + Icons::Kenney::Check : "\\$b00" + Icons::Kenney::Times);

            UI::TableNextColumn();
            UI::Text(valid ? textValid : textInvalid);

            UI::TableNextRow();
        }
    }
}

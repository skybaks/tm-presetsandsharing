#if !UNIT_TEST

enum PresetListType
{
    Uncategorized,
    Categorized
}

[Setting category="General" name="Preset List Type" description="How the presets are displayed in the script menu"]
PresetListType Setting_General_PresetListType = PresetListType::Categorized;

[Setting category="General" name="Hide extra help information"]
bool Setting_General_HideVerboseHelp = false;

#endif
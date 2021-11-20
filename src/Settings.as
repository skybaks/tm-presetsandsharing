#if !UNIT_TEST

enum PresetListType
{
    Uncategorized,
    Categorized
}

[Setting category="General" name="Preset List Type" description="How the presets are displayed in the script menu"]
PresetListType Setting_General_PresetListType = PresetListType::Categorized;

#endif
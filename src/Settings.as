
[Setting category="General" name="Hide extra help information"]
bool Setting_General_HideVerboseHelp = false;

[Setting category="General" name="Hide Loadout Script Menu" description="Hide loadouts on the plugin script menu"]
bool Setting_General_LoadoutListHide = false;

[Setting category="General" name="Hide Preset Script Menu" description="Hide presets on the plugin script menu"]
bool Setting_General_PresetListHide = false;

enum PresetListType
{
    Uncategorized,
    Categorized
}

[Setting category="General" name="Preset List Type" description="How the presets are displayed in the script menu"]
PresetListType Setting_General_PresetListType = PresetListType::Categorized;

[Setting category="General" name="Loadout Hotkey Combo" description="This is the first key in the combination used to activate a loadout"]
VirtualKey Setting_General_LoadoutHotkeyCombo = VirtualKey::Control;

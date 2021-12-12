
namespace Interface
{
    enum DialogResultType { Yes, Cancel, Undetermined }
    enum DialogType { Invalid, PresetDelete, LoadoutDelete }

    class DialogMessageData
    {
        string Title = "";
        string Body = "";
        DialogType Target = DialogType::Invalid;
        int TargetIndex = -1;
    }

    DialogResultType RenderShowDialog(const string&in title, const string&in body, const vec2&in parentSize, const vec2&in parentPos)
    {
        DialogResultType result = DialogResultType::Undetermined;

        vec2 dialogSize = vec2(350, 100);
        vec2 dialogPos = vec2(parentPos.x + (parentSize.x / 2.0) - (dialogSize.x / 2.0), parentPos.y + (parentSize.y / 2.0) - (dialogSize.y / 2.0));

        UI::SetNextWindowSize(int(dialogSize.x), int(dialogSize.y), UI::Cond::Appearing);
        UI::SetNextWindowPos(int(dialogPos.x), int(dialogPos.y), UI::Cond::Always);

        UI::WindowFlags dialogFlags = UI::WindowFlags(UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoMove | UI::WindowFlags::NoCollapse | UI::WindowFlags::NoSavedSettings | UI::WindowFlags::NoDocking);
        UI::Begin(title, dialogFlags);

        UI::Text(body);

        if (UI::Button("    Yes    "))
        {
            result = DialogResultType::Yes;
        }
        UI::SameLine();
        if (UI::Button("  Cancel  "))
        {
            result = DialogResultType::Cancel;
        }

        UI::End();

        return result;
    }
}

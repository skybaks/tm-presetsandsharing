
namespace Interface
{
    class PresetLoadout
    {
        private int m_id;
        private string m_name;
        private int[] m_presetIds;
        private bool m_hotkeyActive;
        private VirtualKey m_hotkey = VirtualKey::F5;

        int LoadoutID { get { return m_id; } }

        int[] PresetIDs { get { return m_presetIds; } }

        string Name
        {
            get
            {
                return m_name;
            }
            set
            {
                if (m_name != value)
                {
                    m_name = value;
                }
            }
        }

        bool HotkeyActive
        {
            get
            {
                return m_hotkeyActive;
            }
            set
            {
                m_hotkeyActive = value;
            }
        }

        VirtualKey Hotkey
        {
            get
            {
                return m_hotkey;
            }
            set
            {
                m_hotkey = value;
            }
        }

        PresetLoadout()
        {
            m_id = GetNewLoadoutID();
        }

        void AddPresetID(const int id)
        {
            m_presetIds.InsertLast(id);
        }

        void RemovePresetID(const int id)
        {
            int removeIndex = -1;
            for (uint i = 0; i < m_presetIds.Length; i++)
            {
                if (m_presetIds[i] == id)
                {
                    removeIndex = i;
                    break;
                }
            }
            if (removeIndex >= 0)
            {
                m_presetIds.RemoveAt(removeIndex);
            }
        }

        void ActivatePresets()
        {
            for (uint i = 0; i < m_presetIds.Length; i++)
            {
                PluginPreset@ preset = GetPresetFromID(m_presetIds[i]);
                if (preset !is null)
                {
                    preset.ApplySettings();
                }
            }
        }

        string GetHotkeyString()
        {
            return HotkeyActive ? tostring(Setting_General_LoadoutHotkeyCombo) + "+" + tostring(m_hotkey) : "";
        }

        bool CheckHotkeyMatch(const VirtualKey key)
        {
            return HotkeyActive && key == m_hotkey;
        }

        void Load(Json::Value object)
        {
            m_id = object["LoadoutID"];
            Name = object["Name"];
            for (uint i = 0; i < object["PresetIDs"].Length; i++)
            {
                m_presetIds.InsertLast(int(object["PresetIDs"][i]));
            }
            HotkeyActive = object["HotkeyActive"];
            Hotkey = VirtualKey(int(object["Hotkey"]));
        }

        Json::Value Save()
        {
            auto object = Json::Object();
            object["LoadoutID"] = m_id;
            object["Name"] = Name;
            object["PresetIDs"] = Json::Array();
            for (uint i = 0; i < m_presetIds.Length; i++)
            {
                object["PresetIDs"].Add(m_presetIds[i]);
            }
            object["HotkeyActive"] = HotkeyActive;
            object["Hotkey"] = int(Hotkey);
            return object;
        }
    }

    int GetNewLoadoutID()
    {
        int newId = 0;
        while (newId < Serialization::INT32_MAX)
        {
            bool exists = false;
            for (uint i = 0; i < g_loadouts.Length; i++)
            {
                if (g_loadouts[i].LoadoutID == newId) { exists = true; break; }
            }
            if (!exists) { break; }
            newId++;
        }
        return newId;
    }
}

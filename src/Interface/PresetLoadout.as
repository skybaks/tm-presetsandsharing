
namespace Interface
{
    class PresetLoadout
    {
        private int m_id;
        private string m_name;
        private int[] m_presetIds;

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

        void Load(Json::Value object)
        {
            m_id = object["LoadoutID"];
            Name = object["Name"];
            for (uint i = 0; i < object["PresetIDs"].Length; i++)
            {
                m_presetIds.InsertLast(int(object["PresetIDs"][i]));
            }
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

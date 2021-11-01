
namespace Serialization
{
    class SettingsDataItem
    {
        SettingsDataItem()
        {
        }

        Meta::PluginSettingType m_SettingType;
        string m_ValueStringified;

        bool ReadBool()
        {
            return m_ValueStringified == "true" || m_ValueStringified == "1";
        }

        uint ReadUint()
        {
            return Text::ParseUInt(m_ValueStringified);
        }

        int ReadInt()
        {
            return Text::ParseInt(m_ValueStringified);
        }

        float ReadFloat()
        {
            return Text::ParseFloat(m_ValueStringified);
        }

        string ReadString()
        {
            return m_ValueStringified;
        }

        vec2 ReadVec2()
        {
            string[]@ splitValue = m_ValueStringified.Split(";");
            if (splitValue.Length == 2)
            {
                return vec2(Text::ParseFloat(splitValue[0]), Text::ParseFloat(splitValue[1]));
            }
            else
            {
                return vec2();
            }
        }

        vec3 ReadVec3()
        {
            string[]@ splitValue = m_ValueStringified.Split(";");
            if (splitValue.Length == 3)
            {
                return vec3(Text::ParseFloat(splitValue[0]), Text::ParseFloat(splitValue[1]), Text::ParseFloat(splitValue[2]));
            }
            else
            {
                return vec3();
            }
        }

        vec4 ReadVec4()
        {
            string[]@ splitValue = m_ValueStringified.Split(";");
            if (splitValue.Length == 4)
            {
                return vec4(Text::ParseFloat(splitValue[0]), Text::ParseFloat(splitValue[1]), Text::ParseFloat(splitValue[2]), Text::ParseFloat(splitValue[2]));
            }
            else
            {
                return vec4();
            }
        }
    }
}

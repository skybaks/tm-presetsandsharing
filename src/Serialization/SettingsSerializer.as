
namespace Serialization
{
    class SettingsSerializer
    {
        private uint8 m_serializerVersion = 1;
        private bool m_allowUpgrade = true;
        private MemoryBuffer m_buffer;
        private Meta::Plugin@ m_plugin;

        SettingsSerializer()
        {
        }

        void SetPlugin(Meta::Plugin@ plugin)
        {
            @m_plugin = plugin;
        }

        string WriteBase64String()
        {
            SerializeToBuffer();
            return "";
            // Sort Settings by VarName ?
        }

        bool ValidateBase64String(const string&in input)
        {
            return false;
            // Read Header
            // Read each Setting
            // CRC?
        }

        private void SerializeToBuffer()
        {
            m_buffer.Resize(0);
            auto settings = m_plugin.GetSettings();
            for (uint settingsIndex = 0; settingsIndex < settings.Length; settingsIndex++)
            {
                auto pluginSetting = settings[settingsIndex];
            }
        }

        // Overall Header
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    0 |    3 | Serializer Version | Integer version for the serializer
        //    0 |    1 | Allow Upgrade Flag | Flag indicating settings can be upgraded
        //    0 |    4 | Settings Count     | Integer number of settings in file
        //    1 |    8 | Plugin Name Hash   | One byte hash of plugin name
        private void WriteOverallHeader(const uint8&in settingsCount, const uint8&in pluginNameHash)
        {
            uint8 byte0 = ((m_serializerVersion & 0x07) << 5) | ((m_allowUpgrade ? 0x01 : 0x00) << 4) | (settingsCount & 0x0f);
            m_buffer.Write(byte0);
            m_buffer.Write(pluginNameHash);
        }
        private void ReadOverallHeader()
        {
            uint8 byte0 = m_buffer.ReadUInt8();
            uint8 serializerVersion = (byte0 >> 5) & 0x07;
            bool allowUpgrade = ((byte0 >> 4) & 0x01) != 0x00;
            uint8 settingsCount = byte0 & 0x0f;
            uint8 pluginNameHash = m_buffer.ReadUInt8();
            warn("TODO: ReadOverallHeader");
        }

        // Setting Header
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    0 |    8 | VarName Hash       | Hash of setting's variable name
        //    1 |    4 | Setting Type       | Type enumeration
        //  1-n |    n | Data               | (See definition of each type)
        void ReadSetting()
        {
            uint8 hashId = m_buffer.ReadUInt8();
            uint8 byte1 = m_buffer.ReadUInt8();
            auto settingType = Meta::PluginSettingType((byte1 >> 4) & 0x0f);
            uint8 byte1_Data = byte1 & 0x0f;

            if (settingType == Meta::PluginSettingType::Bool)
            {
                ReadBool(byte1_Data);
            }
            else if (settingType == Meta::PluginSettingType::Enum
                || settingType == Meta::PluginSettingType::Int8
                || settingType == Meta::PluginSettingType::Int16
                || settingType == Meta::PluginSettingType::Int32)
            {
                ReadInteger(byte1_Data);
            }
        }

        // Bool
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    3 | Spare              | Spare
        //    1 |    1 | Boolean value      | Boolean data
        void WriteBool(Meta::PluginSetting@ setting)
        {
            uint8 byte0 = Hash8(setting.VarName);
            m_buffer.Write(byte0);
            uint8 byte1 = ((uint8(setting.Type) & 0x0f) << 4);

            byte1 |= (setting.ReadBool() ? 0x01 : 0x00);
            m_buffer.Write(byte1);
        }
        void ReadBool(uint8 byte1_Data)
        {
            bool value = (byte1_Data & 0x01) != 0x00;
            warn("TODO: ReadBool");
            error("ReadBool: Do something with the value doofus");
        }

        // Integer/Enum
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Data Bytes Count   | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    1 | Signed/Unsigned    | 1=Signed Data; 0=Unsigned Data
        //    1 |    1 | Spare              | Spare
        //    n |  n*8 | Data               | Integer data
        void WriteInteger(Meta::PluginSetting@ setting)
        {
            uint8 byte0 = Hash8(setting.VarName);
            m_buffer.Write(byte0);
            uint8 byte1 = ((uint8(setting.Type) & 0x0f) << 4);

            int64 value = 0;
            if (setting.Type == Meta::PluginSettingType::Enum)
            {
                value = setting.ReadEnum();
            }
            else if (setting.Type == Meta::PluginSettingType::Int8)
            {
                value = setting.ReadInt8();
            }
            else if (setting.Type == Meta::PluginSettingType::Int16)
            {
                value = setting.ReadInt16();
            }
            else if (setting.Type == Meta::PluginSettingType::Int32)
            {
                value = setting.ReadInt32();
            }
            else
            {
                warn("TODO: handle this");
                error("Unexpected Type in WriteInteger: " + tostring(setting.Type));
            }

            if (value < 0)
            {
                if (value >= INT8_MIN)
                {
                    byte1 |= (0x00 << 2);   // 1 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int8(value));
                }
                else if (value >= INT16_MIN)
                {
                    byte1 |= (0x01 << 2);   // 2 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int16(value));
                }
                else if (value >= INT32_MIN)
                {
                    byte1 |= (0x02 << 2);   // 4 byte
                    byte1 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte1);
                    m_buffer.Write(int(value));
                }
                else
                {
                    warn("TODO: handle this");
                    error("Unexpected value occured in WriteInteger: " + tostring(value));
                }
            }
            else
            {
                if (uint64(value) <= UINT8_MAX)
                {
                    byte1 |= (0x00 << 2);   // 1 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint8(value));
                }
                else if (uint64(value) <= UINT16_MAX)
                {
                    byte1 |= (0x01 << 2);   // 2 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint16(value));
                }
                else if (uint64(value) <= UINT32_MAX)
                {
                    byte1 |= (0x02 << 2);   // 4 byte
                    byte1 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte1);
                    m_buffer.Write(uint(value));
                }
                else
                {
                    warn("TODO: handle this");
                    error("Unexpected value occured in WriteInteger: " + tostring(value));
                }
            }
        }

        void ReadInteger(uint8 byte1_Data)
        {
            uint8 dataByteEnum = (byte1_Data >> 2) & 0x03;
            bool isSigned = ((byte1_Data >> 1) & 0x01) != 0x00;
            int64 value = 0;
            if (isSigned)
            {
                if (dataByteEnum == 0)
                {
                    value = int8(m_buffer.ReadInt8());
                }
                else if (dataByteEnum == 1)
                {
                    value = int16(m_buffer.ReadInt16());
                }
                else if (dataByteEnum == 2)
                {
                    value = int(m_buffer.ReadInt32());
                }
                else /*if (dataByteEnum == 3)*/
                {
                    value = int64(m_buffer.ReadInt64());
                }
            }
            else
            {
                if (dataByteEnum == 0)
                {
                    value = int8(m_buffer.ReadUInt8());
                }
                else if (dataByteEnum == 1)
                {
                    value = int16(m_buffer.ReadUInt16());
                }
                else if (dataByteEnum == 2)
                {
                    value = int(m_buffer.ReadUInt32());
                }
                else /*if (dataByteEnum == 3)*/
                {
                    value = int64(m_buffer.ReadUInt64());
                }
            }
        }

        // Float
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum   | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum    | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    n |  8*n | Data               | Scaled float data

        // String
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    4 | Data Byte Count 1  | Number of bytes of data. If set to 15, then another byte of count data will follow
        //    2 |    8 | Data Byte Count 2  | [OPTIONAL] If previous field was 15 this is included and data count is sum of both
        // 2/3+ |  n*8 | String Data        | String data of count described

        // Vec2
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    4 | Spare              | Spare
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y

        // Vec3
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Z | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y
        //    n |  n*8 | Data Z             | Scaled float data Z

        // Vec4
        // ====================================================================
        // Byte | Bits | Data               | Description
        // -----|------|--------------------|----------------------------------
        //    1 |    2 | Byte Number Enum X | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    1 |    2 | Resolution Enum X  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Y | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Y  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    2 |    2 | Byte Number Enum Z | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    2 |    2 | Resolution Enum Z  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    3 |    2 | Byte Number Enum W | 0=1byte; 1=2bytes; 2=4bytes; 3=8bytes
        //    3 |    2 | Resolution Enum W  | 0=0.001; 1=0.01; 2=0.1; 3=1.0
        //    3 |    4 | Spare              | Spare
        //    n |  n*8 | Data X             | Scaled float data X
        //    n |  n*8 | Data Y             | Scaled float data Y
        //    n |  n*8 | Data Z             | Scaled float data Z
        //    n |  n*8 | Data W             | Scaled float data W
    }
}

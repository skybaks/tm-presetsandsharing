
namespace Serialization
{
    class SettingsSerializer
    {
        private MemoryBuffer m_buffer;

        SettingsSerializer()
        {
        }

        // Dictionary Format: string, Serialization::SettingsDataItem@
        bool ReadFromBinary(const string&in inputBase64String, dictionary@ settingsResult)
        {
            m_buffer.Resize(0);
            m_buffer.WriteFromBase64(inputBase64String);
            return false;
        }

        // Dictionary Format: string, Meta::PluginSetting@
        bool WriteToBinary(dictionary@ inputSettings, const string&in pluginId, string&out resultBase64String)
        {
            bool success = false;
            m_buffer.Resize(0);

            const uint8 SERIALIZER_VERSION = 0;

            // Header
            m_buffer.Write(uint8(((SERIALIZER_VERSION & 0x0F) << 4) | (0 & 0x0F)));
            m_buffer.Write(uint8(inputSettings.GetSize()));
            m_buffer.Write(uint8(Hash8(pluginId)));

            auto keys = inputSettings.GetKeys();
            for (uint i = 0; i < keys.Length; i++)
            {
                m_buffer.Write(uint16(Text::ParseUInt(keys[i])));
                Meta::PluginSetting@ pluginSetting = cast<Meta::PluginSetting>(inputSettings[keys[i]]);
                uint8 settingType = 0x0F & uint8(pluginSetting.Type);

                if (pluginSetting.Type == Meta::PluginSettingType::Bool)
                {
                    m_buffer.Write(uint8((settingType << 4) | (pluginSetting.ReadBool() ? 0x01 : 0x00)));
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Enum
                    || pluginSetting.Type == Meta::PluginSettingType::Int8
                    || pluginSetting.Type == Meta::PluginSettingType::Int16
                    || pluginSetting.Type == Meta::PluginSettingType::Int32)
                {
                    int64 value = 0;
                    switch (pluginSetting.Type)
                    {
                    case Meta::PluginSettingType::Enum:
                        value = int64(pluginSetting.ReadEnum());
                        break;
                    case Meta::PluginSettingType::Int8:
                        value = int64(pluginSetting.ReadInt8());
                        break;
                    case Meta::PluginSettingType::Int16:
                        value = int64(pluginSetting.ReadInt16());
                        break;
                    case Meta::PluginSettingType::Int32:
                    default:
                        value = int64(pluginSetting.ReadInt32());
                        break;
                    }
                    if (value == 0)
                    {
                        m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::Zero) << 2) | (0x00 << 1)));
                    }
                    else if (value < 0)
                    {
                        if (value >= INT8_MIN)
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::One) << 2) | (0x01 << 1)));
                            m_buffer.Write(int8(value));
                        }
                        else if (value >= INT16_MIN)
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::Two) << 2) | (0x01 << 1)));
                            m_buffer.Write(int16(value));
                        }
                        else /* INT32 */
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::Four) << 2) | (0x01 << 1)));
                            m_buffer.Write(int(value));
                        }
                    }
                    else
                    {
                        if (uint64(value) <= UINT8_MAX)
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::One) << 2) | (0x00 << 1)));
                            m_buffer.Write(uint8(value));
                        }
                        else if (uint64(value) <= UINT16_MAX)
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::Two) << 2) | (0x00 << 1)));
                            m_buffer.Write(uint16(value));
                        }
                        else /* UINT32 */
                        {
                            m_buffer.Write(uint8((settingType << 4) | ((0x03 & BinaryFormatV0::IntegerByteCount::Four) << 2) | (0x00 << 1)));
                            m_buffer.Write(uint(value));
                        }
                    }
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Float)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCount;
                    Serialization::BinaryFormatV0::FloatResolution resolution;
                    int64 packedValue;
                    bool determinedFloatPacking = BinaryFormatV0::DetermineFloatPacking(pluginSetting.ReadFloat(), byteCount, resolution, packedValue);
                    if (determinedFloatPacking)
                    {
                        m_buffer.Write(uint8((settingType << 4) | ((0x03 & byteCount) << 2) | (0x03 & resolution)));
                        if (byteCount == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValue));
                        }
                        else if (byteCount == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValue));
                        }
                        else /* Four Bytes */
                        {
                            m_buffer.Write(int(packedValue));
                        }
                    }
                    else
                    {
                        error("ERROR: Unable to serialize float setting \"" + pluginSetting.VarName + "\". Unable to determine packing");
                    }
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::String)
                {
                    uint64 stringLengthTotal = pluginSetting.ReadString().Length;
                    uint stringLengthPart1 = Math::Min(15, stringLengthTotal);
                    uint stringLengthPart2 = Math::Max(0, stringLengthTotal - stringLengthPart1);
                    m_buffer.Write(uint8((settingType << 4) | (0x0F & stringLengthPart1)));
                    if (stringLengthPart2 > 0)
                    {
                        m_buffer.Write(uint8(stringLengthPart2));
                    }
                    m_buffer.Write(pluginSetting.ReadString());
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Vec2)
                {
                    warn("TODO: Meta::PluginSettingType::Vec2");
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Vec3)
                {
                    warn("TODO: Meta::PluginSettingType::Vec3");
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Vec4)
                {
                    warn("TODO: Meta::PluginSettingType::Vec4");
                }
                else
                {
                    error("ERROR: Unexpected Setting Type");
                }
            }

            resultBase64String = "";
            if (m_buffer.GetSize() > 0)
            {
                m_buffer.Seek(0);
                resultBase64String = m_buffer.ReadToBase64(m_buffer.GetSize());
                success = true;
            }
            return success;
        }

        private void WriteOverallHeader(const uint8&in settingsCount, const uint8&in pluginNameHash)
        {
        }
        private void ReadOverallHeader()
        {
        }

        void WriteSetting(Meta::PluginSetting@ setting)
        {
            uint16 hashId = Hash16(setting.VarName);
            uint8 byte2 = (uint8(setting.Type) & 0x0f) << 4;

            if (setting.Type == Meta::PluginSettingType::Bool)
            {
                WriteBool(byte2, setting.ReadBool());
            }
            else if (setting.Type == Meta::PluginSettingType::Enum
                || setting.Type == Meta::PluginSettingType::Int8
                || setting.Type == Meta::PluginSettingType::Int16
                || setting.Type == Meta::PluginSettingType::Int32)
            {
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
                else /*if (setting.Type == Meta::PluginSettingType::Int32)*/
                {
                    value = setting.ReadInt32();
                }
                WriteInteger(byte2, value);
            }
        }
        void ReadSetting()
        {
            uint16 hashId = m_buffer.ReadUInt16();
            uint8 byte2 = m_buffer.ReadUInt8();
            auto settingType = Meta::PluginSettingType((byte2 >> 4) & 0x0f);

            if (settingType == Meta::PluginSettingType::Bool)
            {
                ReadBool(byte2);
            }
            else if (settingType == Meta::PluginSettingType::Enum
                || settingType == Meta::PluginSettingType::Int8
                || settingType == Meta::PluginSettingType::Int16
                || settingType == Meta::PluginSettingType::Int32)
            {
                ReadInteger(byte2);
            }
        }

        void WriteBool(uint8 byte2, bool value)
        {
            byte2 |= (value ? 0x01 : 0x00);
            m_buffer.Write(byte2);
        }
        void ReadBool(uint8 byte2)
        {
            bool value = (byte2 & 0x01) != 0x00;
        }

        void WriteInteger(uint8 byte2, int64 value)
        {
            if (value < 0)
            {
                if (value >= INT8_MIN)
                {
                    byte2 |= (0x00 << 2);   // 1 byte
                    byte2 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte2);
                    m_buffer.Write(int8(value));
                }
                else if (value >= INT16_MIN)
                {
                    byte2 |= (0x01 << 2);   // 2 byte
                    byte2 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte2);
                    m_buffer.Write(int16(value));
                }
                else /*if (value >= INT32_MIN)*/
                {
                    byte2 |= (0x02 << 2);   // 4 byte
                    byte2 |= (0x01 << 1);   // signed
                    m_buffer.Write(byte2);
                    m_buffer.Write(int(value));
                }
            }
            else
            {
                if (uint64(value) <= UINT8_MAX)
                {
                    byte2 |= (0x00 << 2);   // 1 byte
                    byte2 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte2);
                    m_buffer.Write(uint8(value));
                }
                else if (uint64(value) <= UINT16_MAX)
                {
                    byte2 |= (0x01 << 2);   // 2 byte
                    byte2 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte2);
                    m_buffer.Write(uint16(value));
                }
                else /*if (uint64(value) <= UINT32_MAX)*/
                {
                    byte2 |= (0x02 << 2);   // 4 byte
                    byte2 |= (0x00 << 1);   // unsigned
                    m_buffer.Write(byte2);
                    m_buffer.Write(uint(value));
                }
            }
        }

        void ReadInteger(uint8 byte2)
        {
            uint8 dataByteEnum = (byte2 >> 2) & 0x03;
            bool isSigned = ((byte2 >> 1) & 0x01) != 0x00;
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

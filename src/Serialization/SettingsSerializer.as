
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
            m_buffer.Seek(0);

            // Header
            uint8 headerByte0 = m_buffer.ReadUInt8();
            uint serializerVersion = (headerByte0 & 0xF0) >> 4;
            uint8 settingsCount = m_buffer.ReadUInt8();
            uint8 pluginNameHash = m_buffer.ReadUInt8();

            while (!m_buffer.AtEnd())
            {
                uint16 settingId = m_buffer.ReadUInt16();
                uint8 settingByte2 = m_buffer.ReadUInt8();
                Meta::PluginSettingType settingType = Meta::PluginSettingType((settingByte2 & 0xF0) >> 4);
                string stringifiedValue = "";
                if (settingType == Meta::PluginSettingType::Bool)
                {
                    uint boolValue = settingByte2 & 0x01;
                    stringifiedValue = tostring(boolValue);
                }
                else if (settingType == Meta::PluginSettingType::Enum
                    || settingType == Meta::PluginSettingType::Int8
                    || settingType == Meta::PluginSettingType::Int16
                    || settingType == Meta::PluginSettingType::Int32)
                {
                    Serialization::BinaryFormatV0::IntegerByteCount byteCount = Serialization::BinaryFormatV0::IntegerByteCount((settingByte2 >> 2) & 0x03);
                    bool isSigned = (settingByte2 & 0x02) != 0;

                    if (byteCount == BinaryFormatV0::IntegerByteCount::Zero)
                    {
                        stringifiedValue = tostring(0);
                    }
                    else if (byteCount == BinaryFormatV0::IntegerByteCount::One)
                    {
                        if (isSigned)
                        {
                            stringifiedValue = tostring(m_buffer.ReadInt8());
                        }
                        else
                        {
                            stringifiedValue = tostring(m_buffer.ReadUInt8());
                        }
                    }
                    else if (byteCount == BinaryFormatV0::IntegerByteCount::Two)
                    {
                        if (isSigned)
                        {
                            stringifiedValue = tostring(m_buffer.ReadInt16());
                        }
                        else
                        {
                            stringifiedValue = tostring(m_buffer.ReadUInt16());
                        }
                    }
                    else /* Four Bytes */
                    {
                        if (isSigned)
                        {
                            stringifiedValue = tostring(m_buffer.ReadInt32());
                        }
                        else
                        {
                            stringifiedValue = tostring(m_buffer.ReadUInt32());
                        }
                    }
                }
                else if (settingType == Meta::PluginSettingType::Float)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCount = Serialization::BinaryFormatV0::FloatByteCount((settingByte2 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolution = Serialization::BinaryFormatV0::FloatResolution((settingByte2 >> 0) & 0x03);
                    int64 packedValue = 0;
                    if (byteCount == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValue = 0;
                    }
                    else if (byteCount == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValue = m_buffer.ReadInt8();
                    }
                    else if (byteCount == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValue = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValue = m_buffer.ReadInt32();
                    }

                    if (resolution == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue = tostring(float(packedValue * 0.001));
                    }
                    else if (resolution == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue = tostring(float(packedValue * 0.01));
                    }
                    else if (resolution == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue = tostring(float(packedValue * 0.1));
                    }
                    else /* Ones */
                    {
                        stringifiedValue = tostring(float(packedValue * 1.0));
                    }
                }
                else if (settingType == Meta::PluginSettingType::String)
                {
                    uint64 stringLen = settingByte2 & 0x0F;
                    if (stringLen == 15)
                    {
                        uint additionalStringLen = m_buffer.ReadUInt8();
                        stringLen += additionalStringLen;
                    }
                    stringifiedValue = m_buffer.ReadString(stringLen);
                }
                else if (settingType == Meta::PluginSettingType::Vec2)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX = Serialization::BinaryFormatV0::FloatByteCount((settingByte2 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionX = Serialization::BinaryFormatV0::FloatResolution((settingByte2 >> 0) & 0x03);
                    uint8 settingByte3 = m_buffer.ReadUInt8();
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY = Serialization::BinaryFormatV0::FloatByteCount((settingByte3 >> 6) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionY = Serialization::BinaryFormatV0::FloatResolution((settingByte3 >> 4) & 0x03);
                    int64 packedValueX = 0;
                    int64 packedValueY = 0;
                    if (byteCountX == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueX = 0;
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueX = m_buffer.ReadInt8();
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueX = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueX = m_buffer.ReadInt32();
                    }

                    if (byteCountY == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueY = 0;
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueY = m_buffer.ReadInt8();
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueY = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueY = m_buffer.ReadInt32();
                    }

                    if (resolutionX == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.001)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.01)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueX * 1.0)) + ";";
                    }

                    if (resolutionY == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.001));
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.01));
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.1));
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueY * 1.0));
                    }
                }
                else if (settingType == Meta::PluginSettingType::Vec3)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX = Serialization::BinaryFormatV0::FloatByteCount((settingByte2 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionX = Serialization::BinaryFormatV0::FloatResolution((settingByte2 >> 0) & 0x03);
                    uint8 settingByte3 = m_buffer.ReadUInt8();
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY = Serialization::BinaryFormatV0::FloatByteCount((settingByte3 >> 6) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionY = Serialization::BinaryFormatV0::FloatResolution((settingByte3 >> 4) & 0x03);
                    Serialization::BinaryFormatV0::FloatByteCount byteCountZ = Serialization::BinaryFormatV0::FloatByteCount((settingByte3 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionZ = Serialization::BinaryFormatV0::FloatResolution((settingByte3 >> 0) & 0x03);
                    int64 packedValueX = 0;
                    int64 packedValueY = 0;
                    int64 packedValueZ = 0;
                    if (byteCountX == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueX = 0;
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueX = m_buffer.ReadInt8();
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueX = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueX = m_buffer.ReadInt32();
                    }

                    if (byteCountY == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueY = 0;
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueY = m_buffer.ReadInt8();
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueY = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueY = m_buffer.ReadInt32();
                    }

                    if (byteCountZ == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueZ = 0;
                    }
                    else if (byteCountZ == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueZ = m_buffer.ReadInt8();
                    }
                    else if (byteCountZ == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueZ = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueZ = m_buffer.ReadInt32();
                    }

                    if (resolutionX == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.001)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.01)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueX * 1.0)) + ";";
                    }

                    if (resolutionY == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.001)) + ";";
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.01)) + ";";
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueY * 1.0)) + ";";
                    }

                    if (resolutionZ == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.001));
                    }
                    else if (resolutionZ == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.01));
                    }
                    else if (resolutionZ == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.1));
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueZ * 1.0));
                    }
                }
                else if (settingType == Meta::PluginSettingType::Vec4)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX = Serialization::BinaryFormatV0::FloatByteCount((settingByte2 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionX = Serialization::BinaryFormatV0::FloatResolution((settingByte2 >> 0) & 0x03);
                    uint8 settingByte3 = m_buffer.ReadUInt8();
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY = Serialization::BinaryFormatV0::FloatByteCount((settingByte3 >> 6) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionY = Serialization::BinaryFormatV0::FloatResolution((settingByte3 >> 4) & 0x03);
                    Serialization::BinaryFormatV0::FloatByteCount byteCountZ = Serialization::BinaryFormatV0::FloatByteCount((settingByte3 >> 2) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionZ = Serialization::BinaryFormatV0::FloatResolution((settingByte3 >> 0) & 0x03);
                    uint8 settingByte4 = m_buffer.ReadUInt8();
                    Serialization::BinaryFormatV0::FloatByteCount byteCountW = Serialization::BinaryFormatV0::FloatByteCount((settingByte4 >> 6) & 0x03);
                    Serialization::BinaryFormatV0::FloatResolution resolutionW = Serialization::BinaryFormatV0::FloatResolution((settingByte4 >> 4) & 0x03);
                    int64 packedValueX = 0;
                    int64 packedValueY = 0;
                    int64 packedValueZ = 0;
                    int64 packedValueW = 0;
                    if (byteCountX == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueX = 0;
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueX = m_buffer.ReadInt8();
                    }
                    else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueX = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueX = m_buffer.ReadInt32();
                    }

                    if (byteCountY == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueY = 0;
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueY = m_buffer.ReadInt8();
                    }
                    else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueY = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueY = m_buffer.ReadInt32();
                    }

                    if (byteCountZ == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueZ = 0;
                    }
                    else if (byteCountZ == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueZ = m_buffer.ReadInt8();
                    }
                    else if (byteCountZ == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueZ = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueZ = m_buffer.ReadInt32();
                    }

                    if (byteCountW == BinaryFormatV0::FloatByteCount::Zero)
                    {
                        packedValueW = 0;
                    }
                    else if (byteCountW == BinaryFormatV0::FloatByteCount::One)
                    {
                        packedValueW = m_buffer.ReadInt8();
                    }
                    else if (byteCountW == BinaryFormatV0::FloatByteCount::Two)
                    {
                        packedValueW = m_buffer.ReadInt16();
                    }
                    else /* Four Bytes */
                    {
                        packedValueW = m_buffer.ReadInt32();
                    }

                    if (resolutionX == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.001)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.01)) + ";";
                    }
                    else if (resolutionX == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueX * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueX * 1.0)) + ";";
                    }

                    if (resolutionY == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.001)) + ";";
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.01)) + ";";
                    }
                    else if (resolutionY == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueY * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueY * 1.0)) + ";";
                    }

                    if (resolutionZ == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.001)) + ";";
                    }
                    else if (resolutionZ == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.01)) + ";";
                    }
                    else if (resolutionZ == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueZ * 0.1)) + ";";
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueZ * 1.0)) + ";";
                    }

                    if (resolutionW == BinaryFormatV0::FloatResolution::Thousanths)
                    {
                        stringifiedValue += tostring(float(packedValueW * 0.001));
                    }
                    else if (resolutionW == BinaryFormatV0::FloatResolution::Hundredths)
                    {
                        stringifiedValue += tostring(float(packedValueW * 0.01));
                    }
                    else if (resolutionW == BinaryFormatV0::FloatResolution::Tenths)
                    {
                        stringifiedValue += tostring(float(packedValueW * 0.1));
                    }
                    else /* Ones */
                    {
                        stringifiedValue += tostring(float(packedValueW * 1.0));
                    }
                }
                else
                {
                    error("ERROR: Unknown or unexpected plugin setting type encountered while reading binary.");
                }
                auto newSetting = Serialization::SettingsDataItem();
                newSetting.m_SettingType = settingType;
                newSetting.m_ValueStringified = stringifiedValue;
                settingsResult[tostring(settingId)] = newSetting;
            }

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
                        else if (byteCount == BinaryFormatV0::FloatByteCount::Four)
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
                    // TODO: Need to handle situation where string is longer than this?
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
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY;
                    Serialization::BinaryFormatV0::FloatResolution resolutionX;
                    Serialization::BinaryFormatV0::FloatResolution resolutionY;
                    int64 packedValueX;
                    int64 packedValueY;

                    vec2 value = pluginSetting.ReadVec2();
                    bool determinedFloatPackinX = BinaryFormatV0::DetermineFloatPacking(value.x, byteCountX, resolutionX, packedValueX);
                    bool determinedFloatPackinY = BinaryFormatV0::DetermineFloatPacking(value.y, byteCountY, resolutionY, packedValueY);
                    if (determinedFloatPackinX && determinedFloatPackinY)
                    {
                        m_buffer.Write(uint8((settingType << 4) | ((0x03 & byteCountX) << 2) | (0x03 & resolutionX)));
                        m_buffer.Write(uint8(((0x03 & byteCountY) << 6) | ((0x03 & resolutionY) << 4) | (0x0F & 0x00)));

                        if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueX));
                        }

                        if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueY));
                        }
                    }
                    else
                    {
                        error("ERROR: Unable to serialize vec2 setting \"" + pluginSetting.VarName + "\". Unable to determine packing");
                    }
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Vec3)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountZ;
                    Serialization::BinaryFormatV0::FloatResolution resolutionX;
                    Serialization::BinaryFormatV0::FloatResolution resolutionY;
                    Serialization::BinaryFormatV0::FloatResolution resolutionZ;
                    int64 packedValueX;
                    int64 packedValueY;
                    int64 packedValueZ;

                    vec3 value = pluginSetting.ReadVec3();
                    bool determinedFloatPackinX = BinaryFormatV0::DetermineFloatPacking(value.x, byteCountX, resolutionX, packedValueX);
                    bool determinedFloatPackinY = BinaryFormatV0::DetermineFloatPacking(value.y, byteCountY, resolutionY, packedValueY);
                    bool determinedFloatPackinZ = BinaryFormatV0::DetermineFloatPacking(value.z, byteCountZ, resolutionZ, packedValueZ);
                    if (determinedFloatPackinX && determinedFloatPackinY && determinedFloatPackinZ)
                    {
                        m_buffer.Write(uint8((settingType << 4) | ((0x03 & byteCountX) << 2) | (0x03 & resolutionX)));
                        m_buffer.Write(uint8(((0x03 & byteCountY) << 6) | ((0x03 & resolutionY) << 4) | ((0x03 & byteCountZ) << 2) | (0x03 & resolutionZ)));

                        if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueX));
                        }

                        if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueY));
                        }

                        if (byteCountZ == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueZ));
                        }
                        else if (byteCountZ == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueZ));
                        }
                        else if (byteCountZ == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueZ));
                        }
                    }
                    else
                    {
                        error("ERROR: Unable to serialize vec3 setting \"" + pluginSetting.VarName + "\". Unable to determine packing");
                    }
                }
                else if (pluginSetting.Type == Meta::PluginSettingType::Vec4)
                {
                    Serialization::BinaryFormatV0::FloatByteCount byteCountX;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountY;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountZ;
                    Serialization::BinaryFormatV0::FloatByteCount byteCountW;
                    Serialization::BinaryFormatV0::FloatResolution resolutionX;
                    Serialization::BinaryFormatV0::FloatResolution resolutionY;
                    Serialization::BinaryFormatV0::FloatResolution resolutionZ;
                    Serialization::BinaryFormatV0::FloatResolution resolutionW;
                    int64 packedValueX;
                    int64 packedValueY;
                    int64 packedValueZ;
                    int64 packedValueW;

                    vec4 value = pluginSetting.ReadVec4();
                    bool determinedFloatPackinX = BinaryFormatV0::DetermineFloatPacking(value.x, byteCountX, resolutionX, packedValueX);
                    bool determinedFloatPackinY = BinaryFormatV0::DetermineFloatPacking(value.y, byteCountY, resolutionY, packedValueY);
                    bool determinedFloatPackinZ = BinaryFormatV0::DetermineFloatPacking(value.z, byteCountZ, resolutionZ, packedValueZ);
                    bool determinedFloatPackinW = BinaryFormatV0::DetermineFloatPacking(value.w, byteCountW, resolutionW, packedValueW);
                    if (determinedFloatPackinX && determinedFloatPackinY && determinedFloatPackinZ && determinedFloatPackinW)
                    {
                        m_buffer.Write(uint8((settingType << 4) | ((0x03 & byteCountX) << 2) | (0x03 & resolutionX)));
                        m_buffer.Write(uint8(((0x03 & byteCountY) << 6) | ((0x03 & resolutionY) << 4) | ((0x03 & byteCountZ) << 2) | (0x03 & resolutionZ)));
                        m_buffer.Write(uint8(((0x03 & byteCountW) << 6) | ((0x03 & resolutionW) << 4) | (0x0F & 0x00)));

                        if (byteCountX == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueX));
                        }
                        else if (byteCountX == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueX));
                        }

                        if (byteCountY == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueY));
                        }
                        else if (byteCountY == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueY));
                        }

                        if (byteCountZ == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueZ));
                        }
                        else if (byteCountZ == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueZ));
                        }
                        else if (byteCountZ == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueZ));
                        }

                        if (byteCountW == BinaryFormatV0::FloatByteCount::One)
                        {
                            m_buffer.Write(int8(packedValueW));
                        }
                        else if (byteCountW == BinaryFormatV0::FloatByteCount::Two)
                        {
                            m_buffer.Write(int16(packedValueW));
                        }
                        else if (byteCountW == BinaryFormatV0::FloatByteCount::Four)
                        {
                            m_buffer.Write(int(packedValueW));
                        }
                    }
                    else
                    {
                        error("ERROR: Unable to serialize vec4 setting \"" + pluginSetting.VarName + "\". Unable to determine packing");
                    }
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
    }
}

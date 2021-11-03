
namespace Serialization
{
    namespace BinaryFormatV0
    {
        enum IntegerByteCount
        {
            Zero = 0x00,
            One = 0x01,
            Two = 0x02,
            Four = 0x03
        }

        enum FloatByteCount
        {
            Zero = 0x00,
            Packed_One = 0x01,
            Packed_Two = 0x02,
            Unpacked_Four = 0x03
        }

        enum FloatResolution
        {
            Thousanths = 0x00,
            Hundredths = 0x01,
            Tenths = 0x02,
            Ones = 0x03
        }

        bool DetermineFloatPacking(const float&in inputValue, FloatByteCount&out resultByteCount, FloatResolution&out resultResolution, int64&out resultPackedValue)
        {
            bool success = false;

            resultResolution = FloatResolution::Ones;
            float resolutionValue = 1.0f;
            // TODO: Need to worry about scientific notation? Test for it.
            string[]@ matchResult = Regex::Match(tostring(inputValue - Math::Floor(inputValue)), "-?\\d+\\.(\\d+)");
            if (matchResult.Length > 1)
            {
                if (matchResult[1].Length == 1)
                {
                    resultResolution = FloatResolution::Tenths;
                    resolutionValue = 0.1f;
                }
                else if (matchResult[1].Length == 2)
                {
                    resultResolution = FloatResolution::Hundredths;
                    resolutionValue = 0.01f;
                }
                else
                {
                    // TODO: What if we need more precision? Ignored for now.
                    resultResolution = FloatResolution::Thousanths;
                    resolutionValue = 0.001f;
                }
            }

            if (inputValue == 0.0f)
            {
                resultByteCount = FloatByteCount::Zero;
                success = true;
            }
            else if (Math::Abs(inputValue) < CalculateMsbValue(resolutionValue, FloatByteCount::Packed_One))
            {
                resultByteCount = FloatByteCount::Packed_One;
                success = true;
            }
            else if (Math::Abs(inputValue) < CalculateMsbValue(resolutionValue, FloatByteCount::Packed_Two))
            {
                resultByteCount = FloatByteCount::Packed_Two;
                success = true;
            }
            else
            {
                resultByteCount = FloatByteCount::Unpacked_Four;
                success = true;
            }

            if (success)
            {
                resultPackedValue = int64(inputValue / resolutionValue);
            }
            else
            {
                resultPackedValue = 0;
            }

            return success;
        }

        float CalculateMsbValue(const float&in resoValue, const FloatByteCount&in numBytes)
        {
            int numberOfBits = 1;
            switch (numBytes)
            {
            case FloatByteCount::Packed_One:
                numberOfBits = 8;
                break;
            case FloatByteCount::Packed_Two:
                numberOfBits = 16;
                break;
            default:
                break;
            }
            float msbValue = resoValue * Math::Pow(2, numberOfBits - 1);
            return msbValue;
        }
    }
}

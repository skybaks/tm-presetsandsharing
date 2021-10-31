
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
            One = 0x01,
            Two = 0x02,
            Four = 0x03
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
            string[]@ matchResult = Regex::Match(tostring(inputValue), "\\d+\\.(\\d+)");
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
            else if (Math::Abs(inputValue) < CalculateMsbValue(resultResolution, FloatByteCount::One))
            {
                resultByteCount = FloatByteCount::One;
                success = true;
            }
            else if (Math::Abs(inputValue) < CalculateMsbValue(resultResolution, FloatByteCount::Two))
            {
                resultByteCount = FloatByteCount::Two;
                success = true;
            }
            else if (Math::Abs(inputValue) < CalculateMsbValue(resultResolution, FloatByteCount::Four))
            {
                resultByteCount = FloatByteCount::Four;
                success = true;
            }
            else
            {
                // TODO: Handle this error by expanding to more bytes?
                error("ERROR: Unable to fit float setting value \"" + tostring(inputValue) + "\" within existing binary format.");
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

        float CalculateMsbValue(const FloatResolution&in resolution, const FloatByteCount&in numBytes)
        {
            float resoValue = 0.0f;
            switch (resolution)
            {
            case FloatResolution::Thousanths:
                resoValue = 0.001f;
                break;
            case FloatResolution::Hundredths:
                resoValue = 0.01f;
                break;
            case FloatResolution::Tenths:
                resoValue = 0.1f;
                break;
            case FloatResolution::Ones:
            default:
                resoValue = 1.0f;
                break;
            }
            int numberOfBits = 0;
            switch (numBytes)
            {
            case FloatByteCount::One:
                numberOfBits = 8;
                break;
            case FloatByteCount::Two:
                numberOfBits = 16;
                break;
            case FloatByteCount::Four:
                numberOfBits = 32;
                break;
            default:
                numberOfBits = 1;
                break;
            }
            return resoValue * float(2 ** (numberOfBits - 1));
        }
    }
}

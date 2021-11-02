#if UNIT_TEST

[Setting category="INT8"]
int8 Setting_INT8_Test01 = 0;
[Setting category="INT8"]
int8 Setting_INT8_Test02 = 0;
[Setting category="INT8"]
int8 Setting_INT8_Test03 = 0;
[Setting category="INT8"]
int8 Setting_INT8_Test04 = 0;

namespace Test
{
    void Test_Int8Settings()
    {
        Verification::TestBegin("Test_Int8Settings");

        Setting_INT8_Test01 = Serialization::INT8_MAX;
        Setting_INT8_Test02 = Serialization::INT8_MIN;
        Setting_INT8_Test03 = 0;
        Setting_INT8_Test04 = -12;

        auto serial1 = Serialization::SettingsInterface();
        serial1.Initialize(Meta::ExecutingPlugin(), {"INT8"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary), "Error writing settings to binary");

        Setting_INT8_Test01 = 0;
        Setting_INT8_Test02 = 0;
        Setting_INT8_Test03 = 0;
        Setting_INT8_Test04 = 0;

        auto serial2 = Serialization::SettingsInterface();
        serial2.Initialize(Meta::ExecutingPlugin());
        Verification::Condition(serial2.ReadAndValidateBinary(binary), "Error reading binary settings");

        Verification::Condition(serial2.ApplyBinaryToSettings(), "Error applying settings from binary");

        Verification::AreEqual(Serialization::INT8_MAX, Setting_INT8_Test01, "Unexpected value in Setting_INT8_Test01");
        Verification::AreEqual(Serialization::INT8_MIN, Setting_INT8_Test02, "Unexpected value in Setting_INT8_Test02");
        Verification::AreEqual(0, Setting_INT8_Test03, "Unexpected value in Setting_INT8_Test03");
        Verification::AreEqual(-12, Setting_INT8_Test04, "Unexpected value in Setting_INT8_Test04");

        Verification::TestEnd();
    }
}
#endif
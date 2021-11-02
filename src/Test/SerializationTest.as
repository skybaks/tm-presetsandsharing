#if UNIT_TEST

[Setting Category="INT8"]
int8 Setting_INT8_Test01 = 15;
[Setting Category="INT8"]
int8 Setting_INT8_Test02 = -120;
[Setting Category="INT8"]
int8 Setting_INT8_Test03 = Serialization::INT8_MAX;
[Setting Category="INT8"]
int8 Setting_INT8_Test04 = Serialization::INT8_MIN;

namespace Test
{
    void Test_PackAllSettings()
    {
        Verification::TestBegin("Test_PackAllSettings");

        auto serial1 = Serialization::SettingsInterface();
        serial1.SetPlugin(Meta::ExecutingPlugin());
        string binary;
        Verification::AreEqual(true, serial1.WriteCurrentToBinary(binary));

        auto serial2 = Serialization::SettingsInterface();
        serial2.SetPlugin(Meta::ExecutingPlugin());
        Verification::AreEqual(true, serial2.ReadAndValidateBinary(binary));

        Verification::TestEnd();
    }
}
#endif
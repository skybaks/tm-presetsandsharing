#if UNIT_TEST

[Setting category="BOOL"]
bool Setting_BOOL_Test01 = false;
[Setting category="BOOL"]
bool Setting_BOOL_Test02 = false;
[Setting category="BOOL"]
bool Setting_BOOL_Test03 = false;
[Setting category="BOOL"]
bool Setting_BOOL_Test04 = false;

enum TestEnum01 { VALUE_01, VALUE_02, VALUE_03 }
[Setting category="ENUM"]
TestEnum01 Setting_ENUM_Test01 = TestEnum01::VALUE_01;
enum TestEnum02 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05, VALUE_06, VALUE_07, VALUE_08, VALUE_09, VALUE_10 }
[Setting category="ENUM"]
TestEnum02 Setting_ENUM_Test02 = TestEnum02::VALUE_01;
enum TestEnum03 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05, VALUE_06, VALUE_07 }
[Setting category="ENUM"]
TestEnum03 Setting_ENUM_Test03 = TestEnum03::VALUE_01;
enum TestEnum04 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05 }
[Setting category="ENUM"]
TestEnum04 Setting_ENUM_Test04 = TestEnum04::VALUE_01;

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
    void Test_BoolSettings()
    {
        Verification::TestBegin("Test_BoolSettings");

        Setting_BOOL_Test01 = true;
        Setting_BOOL_Test02 = true;
        Setting_BOOL_Test03 = false;
        Setting_BOOL_Test04 = true;

        auto serial1 = Serialization::SettingsInterface();
        serial1.Initialize(Meta::ExecutingPlugin(), {"BOOL"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary), "Error writing settings to binary");

        Setting_BOOL_Test01 = false;
        Setting_BOOL_Test02 = false;
        Setting_BOOL_Test03 = false;
        Setting_BOOL_Test04 = false;

        serial1.Initialize(Meta::ExecutingPlugin());
        Verification::Condition(serial1.ReadAndValidateBinary(binary), "Error reading binary settings");
        Verification::Condition(serial1.ApplyBinaryToSettings(), "Error applying settings from binary");

        Verification::AreEqual(true, Setting_BOOL_Test01, "Unexpected value in Setting_BOOL_Test01");
        Verification::AreEqual(true, Setting_BOOL_Test02, "Unexpected value in Setting_BOOL_Test02");
        Verification::AreEqual(false, Setting_BOOL_Test03, "Unexpected value in Setting_BOOL_Test03");
        Verification::AreEqual(true, Setting_BOOL_Test04, "Unexpected value in Setting_BOOL_Test04");

        Verification::TestEnd();
    }

    void Test_EnumSettings()
    {
        Verification::TestBegin("Test_EnumSettings");

        Setting_ENUM_Test01 = TestEnum01::VALUE_03;
        Setting_ENUM_Test02 = TestEnum02::VALUE_09;
        Setting_ENUM_Test03 = TestEnum03::VALUE_07;
        Setting_ENUM_Test04 = TestEnum04::VALUE_04;

        auto serial1 = Serialization::SettingsInterface();
        serial1.Initialize(Meta::ExecutingPlugin(), {"ENUM"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary), "Error writing settings to binary");

        Setting_ENUM_Test01 = TestEnum01::VALUE_01;
        Setting_ENUM_Test02 = TestEnum02::VALUE_01;
        Setting_ENUM_Test03 = TestEnum03::VALUE_01;
        Setting_ENUM_Test04 = TestEnum04::VALUE_01;

        serial1.Initialize(Meta::ExecutingPlugin());
        Verification::Condition(serial1.ReadAndValidateBinary(binary), "Error reading binary settings");
        Verification::Condition(serial1.ApplyBinaryToSettings(), "Error applying settings from binary");

        Verification::AreEqual(TestEnum01::VALUE_03, Setting_ENUM_Test01, "Unexpected value in Setting_ENUM_Test01");
        Verification::AreEqual(TestEnum02::VALUE_09, Setting_ENUM_Test02, "Unexpected value in Setting_ENUM_Test02");
        Verification::AreEqual(TestEnum03::VALUE_07, Setting_ENUM_Test03, "Unexpected value in Setting_ENUM_Test03");
        Verification::AreEqual(TestEnum04::VALUE_04, Setting_ENUM_Test04, "Unexpected value in Setting_ENUM_Test04");

        Verification::TestEnd();
    }

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
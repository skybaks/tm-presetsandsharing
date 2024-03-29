
[Setting category="BOOL" hidden]
bool Setting_BOOL_Test01 = false;
[Setting category="BOOL" hidden]
bool Setting_BOOL_Test02 = false;
[Setting category="BOOL" hidden]
bool Setting_BOOL_Test03 = false;
[Setting category="BOOL" hidden]
bool Setting_BOOL_Test04 = false;

enum TestEnum01 { VALUE_01, VALUE_02, VALUE_03 }
[Setting category="ENUM" hidden]
TestEnum01 Setting_ENUM_Test01 = TestEnum01::VALUE_01;
enum TestEnum02 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05, VALUE_06, VALUE_07, VALUE_08, VALUE_09, VALUE_10 }
[Setting category="ENUM" hidden]
TestEnum02 Setting_ENUM_Test02 = TestEnum02::VALUE_01;
enum TestEnum03 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05, VALUE_06, VALUE_07 }
[Setting category="ENUM" hidden]
TestEnum03 Setting_ENUM_Test03 = TestEnum03::VALUE_01;
enum TestEnum04 { VALUE_01, VALUE_02, VALUE_03, VALUE_04, VALUE_05 }
[Setting category="ENUM" hidden]
TestEnum04 Setting_ENUM_Test04 = TestEnum04::VALUE_01;

[Setting category="FLOAT" hidden]
float Setting_FLOAT_Test01 = 0.0;
[Setting category="FLOAT" hidden]
float Setting_FLOAT_Test02 = 0.0;
[Setting category="FLOAT" hidden]
float Setting_FLOAT_Test03 = 0.0;
[Setting category="FLOAT" hidden]
float Setting_FLOAT_Test04 = 0.0;

[Setting category="INT8" hidden]
int8 Setting_INT8_Test01 = 0;
[Setting category="INT8" hidden]
int8 Setting_INT8_Test02 = 0;
[Setting category="INT8" hidden]
int8 Setting_INT8_Test03 = 0;
[Setting category="INT8" hidden]
int8 Setting_INT8_Test04 = 0;

[Setting category="INT16" hidden]
int16 Setting_INT16_Test01 = 0;
[Setting category="INT16" hidden]
int16 Setting_INT16_Test02 = 0;
[Setting category="INT16" hidden]
int16 Setting_INT16_Test03 = 0;
[Setting category="INT16" hidden]
int16 Setting_INT16_Test04 = 0;

[Setting category="INT32" hidden]
int Setting_INT32_Test01 = 0;
[Setting category="INT32" hidden]
int Setting_INT32_Test02 = 0;
[Setting category="INT32" hidden]
int Setting_INT32_Test03 = 0;
[Setting category="INT32" hidden]
int Setting_INT32_Test04 = 0;

[Setting category="STRING" hidden]
string Setting_STRING_Test01 = "";
[Setting category="STRING" hidden]
string Setting_STRING_Test02 = "";
[Setting category="STRING" hidden]
string Setting_STRING_Test03 = "";
[Setting category="STRING" hidden]
string Setting_STRING_Test04 = "";

[Setting category="VEC2" hidden]
vec2 Setting_VEC2_Test01 = vec2(0, 0);
[Setting category="VEC2" hidden]
vec2 Setting_VEC2_Test02 = vec2(0, 0);
[Setting category="VEC2" hidden]
vec2 Setting_VEC2_Test03 = vec2(0, 0);
[Setting category="VEC2" hidden]
vec2 Setting_VEC2_Test04 = vec2(0, 0);

[Setting category="VEC3" hidden]
vec3 Setting_VEC3_Test01 = vec3(0, 0, 0);
[Setting category="VEC3" hidden]
vec3 Setting_VEC3_Test02 = vec3(0, 0, 0);
[Setting category="VEC3" hidden]
vec3 Setting_VEC3_Test03 = vec3(0, 0, 0);
[Setting category="VEC3" hidden]
vec3 Setting_VEC3_Test04 = vec3(0, 0, 0);

[Setting category="VEC4" hidden]
vec4 Setting_VEC4_Test01 = vec4(0, 0, 0, 0);
[Setting category="VEC4" hidden]
vec4 Setting_VEC4_Test02 = vec4(0, 0, 0, 0);
[Setting category="VEC4" hidden]
vec4 Setting_VEC4_Test03 = vec4(0, 0, 0, 0);
[Setting category="VEC4" hidden]
vec4 Setting_VEC4_Test04 = vec4(0, 0, 0, 0);

[Setting category="UINT8" hidden]
uint8 Setting_UINT8_Test01 = 0;
[Setting category="UINT8" hidden]
uint8 Setting_UINT8_Test02 = 0;
[Setting category="UINT8" hidden]
uint8 Setting_UINT8_Test03 = 0;
[Setting category="UINT8" hidden]
uint8 Setting_UINT8_Test04 = 0;

[Setting category="UINT16" hidden]
uint16 Setting_UINT16_Test01 = 0;
[Setting category="UINT16" hidden]
uint16 Setting_UINT16_Test02 = 0;
[Setting category="UINT16" hidden]
uint16 Setting_UINT16_Test03 = 0;
[Setting category="UINT16" hidden]
uint16 Setting_UINT16_Test04 = 0;

[Setting category="UINT32" hidden]
uint32 Setting_UINT32_Test01 = 0;
[Setting category="UINT32" hidden]
uint32 Setting_UINT32_Test02 = 0;
[Setting category="UINT32" hidden]
uint32 Setting_UINT32_Test03 = 0;
[Setting category="UINT32" hidden]
uint32 Setting_UINT32_Test04 = 0;

namespace Test
{
    Serialization::SettingsSerializationValidation g_testValidation;

    void Test_BoolSettings()
    {
        Verification::TestBegin("Test_BoolSettings");

        Setting_BOOL_Test01 = true;
        Setting_BOOL_Test02 = true;
        Setting_BOOL_Test03 = false;
        Setting_BOOL_Test04 = true;

        auto serial1 = Serialization::SettingsInterface();
        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"BOOL"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_BOOL_Test01 = false;
        Setting_BOOL_Test02 = false;
        Setting_BOOL_Test03 = false;
        Setting_BOOL_Test04 = false;

        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial1.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial1.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(true, Setting_BOOL_Test01, "Unexpected value in Setting_BOOL_Test01");
        Verification::AreEqual(true, Setting_BOOL_Test02, "Unexpected value in Setting_BOOL_Test02");
        Verification::AreEqual(false, Setting_BOOL_Test03, "Unexpected value in Setting_BOOL_Test03");
        Verification::AreEqual(true, Setting_BOOL_Test04, "Unexpected value in Setting_BOOL_Test04");

        Setting_BOOL_Test01 = false;
        Setting_BOOL_Test02 = false;
        Setting_BOOL_Test03 = false;
        Setting_BOOL_Test04 = false;

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
        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"ENUM"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_ENUM_Test01 = TestEnum01::VALUE_01;
        Setting_ENUM_Test02 = TestEnum02::VALUE_01;
        Setting_ENUM_Test03 = TestEnum03::VALUE_01;
        Setting_ENUM_Test04 = TestEnum04::VALUE_01;

        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial1.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial1.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(TestEnum01::VALUE_03, Setting_ENUM_Test01, "Unexpected value in Setting_ENUM_Test01");
        Verification::AreEqual(TestEnum02::VALUE_09, Setting_ENUM_Test02, "Unexpected value in Setting_ENUM_Test02");
        Verification::AreEqual(TestEnum03::VALUE_07, Setting_ENUM_Test03, "Unexpected value in Setting_ENUM_Test03");
        Verification::AreEqual(TestEnum04::VALUE_04, Setting_ENUM_Test04, "Unexpected value in Setting_ENUM_Test04");

        Setting_ENUM_Test01 = TestEnum01::VALUE_01;
        Setting_ENUM_Test02 = TestEnum02::VALUE_01;
        Setting_ENUM_Test03 = TestEnum03::VALUE_01;
        Setting_ENUM_Test04 = TestEnum04::VALUE_01;

        Verification::TestEnd();
    }

    void Test_FloatSettings()
    {
        Verification::TestBegin("Test_FloatSettings");

        Setting_FLOAT_Test01 = 5564.2;
        Setting_FLOAT_Test02 = -0.659;
        Setting_FLOAT_Test03 = 0.0;
        Setting_FLOAT_Test04 = 9147480000.0;

        auto serial1 = Serialization::SettingsInterface();
        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"FLOAT"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_FLOAT_Test01 = 0.0;
        Setting_FLOAT_Test02 = 0.0;
        Setting_FLOAT_Test03 = 0.0;
        Setting_FLOAT_Test04 = 0.0;

        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial1.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial1.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(0.0, 5564.2 - Setting_FLOAT_Test01, 0.001, "Unexpected value in Setting_FLOAT_Test01");
        Verification::AreEqual(0.0, -0.659 - Setting_FLOAT_Test02, 0.001, "Unexpected value in Setting_FLOAT_Test02");
        Verification::AreEqual(0.0, 0.0 - Setting_FLOAT_Test03, 0.001, "Unexpected value in Setting_FLOAT_Test03");
        Verification::AreEqual(9147480000.0, Setting_FLOAT_Test04, 0.001, "Unexpected value in Setting_FLOAT_Test04");

        Setting_FLOAT_Test01 = 0.0;
        Setting_FLOAT_Test02 = 0.0;
        Setting_FLOAT_Test03 = 0.0;
        Setting_FLOAT_Test04 = 0.0;

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
        serial1.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"INT8"});
        string binary;
        Verification::Condition(serial1.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_INT8_Test01 = 0;
        Setting_INT8_Test02 = 0;
        Setting_INT8_Test03 = 0;
        Setting_INT8_Test04 = 0;

        auto serial2 = Serialization::SettingsInterface();
        serial2.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial2.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial2.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(Serialization::INT8_MAX, Setting_INT8_Test01, "Unexpected value in Setting_INT8_Test01");
        Verification::AreEqual(Serialization::INT8_MIN, Setting_INT8_Test02, "Unexpected value in Setting_INT8_Test02");
        Verification::AreEqual(0, Setting_INT8_Test03, "Unexpected value in Setting_INT8_Test03");
        Verification::AreEqual(-12, Setting_INT8_Test04, "Unexpected value in Setting_INT8_Test04");

        Setting_INT8_Test01 = 0;
        Setting_INT8_Test02 = 0;
        Setting_INT8_Test03 = 0;
        Setting_INT8_Test04 = 0;

        Verification::TestEnd();
    }

    void Test_Int16Settings()
    {
        Verification::TestBegin("Test_Int16Settings");

        Setting_INT16_Test01 = Serialization::INT8_MAX;
        Setting_INT16_Test02 = Serialization::INT16_MIN;
        Setting_INT16_Test03 = 0;
        Setting_INT16_Test04 = -136;

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"INT16"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_INT16_Test01 = -1;
        Setting_INT16_Test02 = -1;
        Setting_INT16_Test03 = -1;
        Setting_INT16_Test04 = -1;

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(Serialization::INT8_MAX, Setting_INT16_Test01, "Unexpected value in Setting_INT16_Test01");
        Verification::AreEqual(Serialization::INT16_MIN, Setting_INT16_Test02, "Unexpected value in Setting_INT16_Test02");
        Verification::AreEqual(0, Setting_INT16_Test03, "Unexpected value in Setting_INT16_Test03");
        Verification::AreEqual(-136, Setting_INT16_Test04, "Unexpected value in Setting_INT16_Test04");

        Setting_INT16_Test01 = 0;
        Setting_INT16_Test02 = 0;
        Setting_INT16_Test03 = 0;
        Setting_INT16_Test04 = 0;

        Verification::TestEnd();
    }

    void Test_Int32Settings()
    {
        Verification::TestBegin("Test_Int32Settings");

        Setting_INT32_Test01 = Serialization::INT16_MAX;
        Setting_INT32_Test02 = Serialization::INT32_MIN;
        Setting_INT32_Test03 = 0;
        Setting_INT32_Test04 = -26978;

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"INT32"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_INT32_Test01 = -1;
        Setting_INT32_Test02 = -1;
        Setting_INT32_Test03 = -1;
        Setting_INT32_Test04 = -1;

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(Serialization::INT16_MAX, Setting_INT32_Test01, "Unexpected value in Setting_INT32_Test01");
        Verification::AreEqual(Serialization::INT32_MIN, Setting_INT32_Test02, "Unexpected value in Setting_INT32_Test02");
        Verification::AreEqual(0, Setting_INT32_Test03, "Unexpected value in Setting_INT32_Test03");
        Verification::AreEqual(-26978, Setting_INT32_Test04, "Unexpected value in Setting_INT32_Test04");

        Setting_INT32_Test01 = 0;
        Setting_INT32_Test02 = 0;
        Setting_INT32_Test03 = 0;
        Setting_INT32_Test04 = 0;

        Verification::TestEnd();
    }

    void Test_StringSettings()
    {
        Verification::TestBegin("Test_StringSettings");

        Setting_STRING_Test01 = "Shor\t\nString";
        Setting_STRING_Test02 = "LongerStringTha";
        Setting_STRING_Test03 = "ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.";
        Setting_STRING_Test04 = "";

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"STRING"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_STRING_Test01 = "";
        Setting_STRING_Test02 = "";
        Setting_STRING_Test03 = "";
        Setting_STRING_Test04 = "";

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual("Shor\t\nString", Setting_STRING_Test01, "Unexpected value in Setting_STRING_Test01");
        Verification::AreEqual("LongerStringTha", Setting_STRING_Test02, "Unexpected value in Setting_STRING_Test02");
        Verification::AreEqual("ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.ThisSentenceIsThirtyNineCharactersLong.", Setting_STRING_Test03, "Unexpected value in Setting_STRING_Test03");
        Verification::AreEqual("", Setting_STRING_Test04, "Unexpected value in Setting_STRING_Test04");

        Setting_STRING_Test01 = "";
        Setting_STRING_Test02 = "";
        Setting_STRING_Test03 = "";
        Setting_STRING_Test04 = "";

        Verification::TestEnd();
    }

    void Test_Vec2Settings()
    {
        Verification::TestBegin("Test_Vec2Settings");

        Setting_VEC2_Test01 = vec2(23.0, 65.12);
        Setting_VEC2_Test02 = vec2(0.123, 0.566);
        Setting_VEC2_Test03 = vec2(5000000.0, 0.2);
        Setting_VEC2_Test04 = vec2(0, 0);

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"VEC2"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_VEC2_Test01 = vec2(-1, -1);
        Setting_VEC2_Test02 = vec2(-1, -1);
        Setting_VEC2_Test03 = vec2(-1, -1);
        Setting_VEC2_Test04 = vec2(-1, -1);

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(vec2(23.0, 65.12), Setting_VEC2_Test01, 0.001, "Unexpected value in Setting_VEC2_Test01");
        Verification::AreEqual(vec2(0.123, 0.566), Setting_VEC2_Test02, 0.001, "Unexpected value in Setting_VEC2_Test02");
        Verification::AreEqual(vec2(5000000.0, 0.2), Setting_VEC2_Test03, 0.001, "Unexpected value in Setting_VEC2_Test03");
        Verification::AreEqual(vec2(0, 0), Setting_VEC2_Test04, 0.001, "Unexpected value in Setting_VEC2_Test04");

        Setting_VEC2_Test01 = vec2(0, 0);
        Setting_VEC2_Test02 = vec2(0, 0);
        Setting_VEC2_Test03 = vec2(0, 0);
        Setting_VEC2_Test04 = vec2(0, 0);

        Verification::TestEnd();
    }

    void Test_Vec3Settings()
    {
        Verification::TestBegin("Test_Vec3Settings");

        Setting_VEC3_Test01 = vec3(23.0, 65.12, 156.9);
        Setting_VEC3_Test02 = vec3(0.123, -0.566, 0.326);
        Setting_VEC3_Test03 = vec3(5000000.0, 0.2, -659.2);
        Setting_VEC3_Test04 = vec3(0, 0, 0);

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"VEC3"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_VEC3_Test01 = vec3(-1, -1, -1);
        Setting_VEC3_Test02 = vec3(-1, -1, -1);
        Setting_VEC3_Test03 = vec3(-1, -1, -1);
        Setting_VEC3_Test04 = vec3(-1, -1, -1);

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(vec3(23.0, 65.12, 156.9), Setting_VEC3_Test01, 0.001, "Unexpected value in Setting_VEC3_Test01");
        Verification::AreEqual(vec3(0.123, -0.566, 0.326), Setting_VEC3_Test02, 0.001, "Unexpected value in Setting_VEC3_Test02");
        Verification::AreEqual(vec3(5000000.0, 0.2, -659.2), Setting_VEC3_Test03, 0.001, "Unexpected value in Setting_VEC3_Test03");
        Verification::AreEqual(vec3(0, 0, 0), Setting_VEC3_Test04, 0.001, "Unexpected value in Setting_VEC3_Test04");

        Setting_VEC3_Test01 = vec3(0, 0, 0);
        Setting_VEC3_Test02 = vec3(0, 0, 0);
        Setting_VEC3_Test03 = vec3(0, 0, 0);
        Setting_VEC3_Test04 = vec3(0, 0, 0);

        Verification::TestEnd();
    }

    void Test_Vec4Settings()
    {
        Verification::TestBegin("Test_Vec4Settings");

        Setting_VEC4_Test01 = vec4(23.0, 65.12, 156.9, 8363.91);
        Setting_VEC4_Test02 = vec4(0.123, -0.566, 0.326, -0.399);
        Setting_VEC4_Test03 = vec4(5000000.0, 0.2, -659.2, 94722.5);
        Setting_VEC4_Test04 = vec4(0, 0, 0, 0);

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"VEC4"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_VEC4_Test01 = vec4(-1, -1, -1, -1);
        Setting_VEC4_Test02 = vec4(-1, -1, -1, -1);
        Setting_VEC4_Test03 = vec4(-1, -1, -1, -1);
        Setting_VEC4_Test04 = vec4(-1, -1, -1, -1);

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(vec4(23.0, 65.12, 156.9, 8363.91), Setting_VEC4_Test01, 0.001, "Unexpected value in Setting_VEC4_Test01");
        Verification::AreEqual(vec4(0.123, -0.566, 0.326, -0.399), Setting_VEC4_Test02, 0.001, "Unexpected value in Setting_VEC4_Test02");
        Verification::AreEqual(vec4(5000000.0, 0.2, -659.2, 94722.5), Setting_VEC4_Test03, 0.001, "Unexpected value in Setting_VEC4_Test03");
        Verification::AreEqual(vec4(0, 0, 0, 0), Setting_VEC4_Test04, 0.001, "Unexpected value in Setting_VEC4_Test04");

        Setting_VEC4_Test01 = vec4(0, 0, 0, 0);
        Setting_VEC4_Test02 = vec4(0, 0, 0, 0);
        Setting_VEC4_Test03 = vec4(0, 0, 0, 0);
        Setting_VEC4_Test04 = vec4(0, 0, 0, 0);

        Verification::TestEnd();
    }

    void Test_Uint8Settings()
    {
        Verification::TestBegin("Test_Uint8Settings");

        Setting_UINT8_Test01 = 17;
        Setting_UINT8_Test02 = 4;
        Setting_UINT8_Test03 = 127;
        Setting_UINT8_Test04 = 7;

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"UINT8"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_UINT8_Test01 = 0;
        Setting_UINT8_Test02 = 0;
        Setting_UINT8_Test03 = 0;
        Setting_UINT8_Test04 = 0;

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(17, Setting_UINT8_Test01, "Unexpected value in Setting_UINT8_Test01");
        Verification::AreEqual(4, Setting_UINT8_Test02, "Unexpected value in Setting_UINT8_Test02");
        Verification::AreEqual(127, Setting_UINT8_Test03, "Unexpected value in Setting_UINT8_Test03");
        Verification::AreEqual(7, Setting_UINT8_Test04, "Unexpected value in Setting_UINT8_Test04");

        Setting_UINT8_Test01 = 0;
        Setting_UINT8_Test02 = 0;
        Setting_UINT8_Test03 = 0;
        Setting_UINT8_Test04 = 0;

        Verification::TestEnd();
    }

    void Test_Uint16Settings()
    {
        Verification::TestBegin("Test_Uint16Settings");

        Setting_UINT16_Test01 = 4861;
        Setting_UINT16_Test02 = 0;
        Setting_UINT16_Test03 = 65535;
        Setting_UINT16_Test04 = 15;

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"UINT16"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_UINT16_Test01 = 0;
        Setting_UINT16_Test02 = 0;
        Setting_UINT16_Test03 = 0;
        Setting_UINT16_Test04 = 0;

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(4861, Setting_UINT16_Test01, "Unexpected value in Setting_UINT16_Test01");
        Verification::AreEqual(0, Setting_UINT16_Test02, "Unexpected value in Setting_UINT16_Test02");
        Verification::AreEqual(65535, Setting_UINT16_Test03, "Unexpected value in Setting_UINT16_Test03");
        Verification::AreEqual(15, Setting_UINT16_Test04, "Unexpected value in Setting_UINT16_Test04");

        Setting_UINT16_Test01 = 0;
        Setting_UINT16_Test02 = 0;
        Setting_UINT16_Test03 = 0;
        Setting_UINT16_Test04 = 0;

        Verification::TestEnd();
    }

    void Test_Uint32Settings()
    {
        Verification::TestBegin("Test_Uint32Settings");

        Setting_UINT32_Test01 = 4861;
        Setting_UINT32_Test02 = 0;
        Setting_UINT32_Test03 = 65536;
        Setting_UINT32_Test04 = 15;

        auto serial = Serialization::SettingsInterface();
        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation, {"UINT32"});
        string binary;
        Verification::Condition(serial.WriteCurrentToBinary(binary, g_testValidation), "Error writing settings to binary");

        Setting_UINT32_Test01 = 0;
        Setting_UINT32_Test02 = 0;
        Setting_UINT32_Test03 = 0;
        Setting_UINT32_Test04 = 0;

        serial.Initialize(Meta::ExecutingPlugin().ID, g_testValidation);
        Verification::Condition(serial.ReadAndValidateBinary(binary, g_testValidation), "Error reading binary settings");
        Verification::Condition(serial.ApplyBinaryToSettings(g_testValidation), "Error applying settings from binary");

        Verification::AreEqual(4861, Setting_UINT32_Test01, "Unexpected value in Setting_UINT32_Test01");
        Verification::AreEqual(0, Setting_UINT32_Test02, "Unexpected value in Setting_UINT32_Test02");
        Verification::AreEqual(65536, Setting_UINT32_Test03, "Unexpected value in Setting_UINT32_Test03");
        Verification::AreEqual(15, Setting_UINT32_Test04, "Unexpected value in Setting_UINT32_Test04");

        Setting_UINT32_Test01 = 0;
        Setting_UINT32_Test02 = 0;
        Setting_UINT32_Test03 = 0;
        Setting_UINT32_Test04 = 0;

        Verification::TestEnd();
    }
}

#if UNIT_TEST

void Main()
{
    try { Test::Test_GenericTestbed(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_BoolSettings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_EnumSettings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_FloatSettings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Int8Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Int16Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Int32Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_StringSettings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Vec2Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Vec3Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
    try { Test::Test_Vec4Settings(); } catch { error("Test Failed: " + Test::Verification::g_CurrTestName); }
}

#endif
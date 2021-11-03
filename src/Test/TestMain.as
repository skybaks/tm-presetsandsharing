#if UNIT_TEST
namespace Test
{
    void TestMain()
    {
        try { Test_GenericTestbed(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
        try { Test_BoolSettings(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
        try { Test_EnumSettings(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
        try { Test_FloatSettings(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
        try { Test_Int8Settings(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
    }
}
#endif
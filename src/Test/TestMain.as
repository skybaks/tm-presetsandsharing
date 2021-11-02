#if UNIT_TEST
namespace Test
{
    void TestMain()
    {
        try { Test_Int8Settings(); } catch { error("Test Failed: " + Verification::g_CurrTestName); }
    }
}
#endif
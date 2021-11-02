
#if UNIT_TEST
namespace Test
{
    namespace Verification
    {
        uint g_AssertsFailed = 0;
        string g_CurrTestName = "";

        void TestBegin(const string&in testName)
        {
            g_AssertsFailed = 0;
            g_CurrTestName = testName;
        }

        void TestEnd()
        {
            if (g_AssertsFailed > 0)
            {
                error("Test Failed: " + g_CurrTestName);
            }
            else
            {
                print("\\$0f0Test Passed: " + g_CurrTestName);
            }
            g_AssertsFailed = 0;
            g_CurrTestName = "";
        }

        bool AreEqual(bool expected, bool actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(uint expected, uint actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(int expected, int actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(float expected, float actual)
        {
            // TODO: Allow a precision tolerance?
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(string expected, string actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(vec2 expected, vec2 actual)
        {
            bool test = expected.x == actual.x
                && expected.y == actual.y;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(vec3 expected, vec3 actual)
        {
            bool test = expected.x == actual.x
                && expected.y == actual.y
                && expected.z == actual.z;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(vec4 expected, vec4 actual)
        {
            bool test = expected.x == actual.x
                && expected.y == actual.y
                && expected.z == actual.z
                && expected.w == actual.w;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }
    }
}
#endif


namespace Test
{
    namespace Verification
    {
        int g_AssertsFailed = 0;
        string g_CurrTestName = "";
        int g_TestsFailed = 0;

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
            g_AssertsFailed = 0;
            g_CurrTestName = "";
        }

        void ResetTestStatus()
        {
            g_TestsFailed = 0;
        }

        bool GetTestStatus()
        {
            return g_TestsFailed == 0;
        }

        bool Condition(bool actual, const string&in errorMsg = "")
        {
            if (!actual)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": Condition Failed! " + errorMsg);
                throw("");
            }
            return actual;
        }

        bool AreEqual(bool expected, bool actual, const string&in errorMsg = "")
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(uint expected, uint actual, const string&in errorMsg = "")
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(int expected, int actual, const string&in errorMsg = "")
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(float expected, float actual, float tolerance, const string&in errorMsg = "")
        {
            bool test = Math::Abs(expected - actual) <= tolerance;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(const string&in expected, const string&in actual, const string&in errorMsg = "")
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(vec2 expected, vec2 actual, float tolerance, const string&in errorMsg = "")
        {
            bool test = Math::Abs(expected.x - actual.x) <= tolerance
                && Math::Abs(expected.y - actual.y) <= tolerance;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(vec3 expected, vec3 actual, float tolerance, const string&in errorMsg = "")
        {
            bool test = Math::Abs(expected.x - actual.x) <= tolerance
                && Math::Abs(expected.y - actual.y) <= tolerance
                && Math::Abs(expected.z - actual.z) <= tolerance;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }

        bool AreEqual(vec4 expected, vec4 actual, float tolerance, const string&in errorMsg = "")
        {
            bool test = Math::Abs(expected.x - actual.x) <= tolerance
                && Math::Abs(expected.y - actual.y) <= tolerance
                && Math::Abs(expected.z - actual.z) <= tolerance
                && Math::Abs(expected.w - actual.w) <= tolerance;
            if (!test)
            {
                g_AssertsFailed += 1;
                error(g_CurrTestName + ": AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual) + ". " + errorMsg);
                throw("");
            }
            return test;
        }
    }
}

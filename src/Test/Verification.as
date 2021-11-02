
#if UNIT_TEST
namespace Test
{
    namespace Verification
    {
        uint g_AssertsFailed = 0;

        bool AreEqual(bool expected, bool actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(uint expected, uint actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(int expected, int actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
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
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }

        bool AreEqual(string expected, string actual)
        {
            bool test = expected == actual;
            if (!test)
            {
                g_AssertsFailed += 1;
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
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
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
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
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
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
                error("AreEqual Failed! Expected: " + tostring(expected) + " Actual: " + tostring(actual));
            }
            return test;
        }
    }
}
#endif

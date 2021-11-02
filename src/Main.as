#define UNIT_TEST

void Main()
{
#if UNIT_TEST
    Test::TestMain();
#else
    // TODO: todo
    print("TODO: todo");
#endif
}

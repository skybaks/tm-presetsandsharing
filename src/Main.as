
void RenderMenu()
{
    View::RenderPresetsMenu();
}

void Main()
{
//#define UNIT_TEST
#if !UNIT_TEST
    // TODO: todo
#else
    Test::TestMain();
#endif
}

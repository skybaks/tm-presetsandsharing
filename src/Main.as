
Manage::MainData g_data;

void RenderMenu()
{
    View::RenderPresetsMenu();
}

void RenderInterface()
{
    View::RenderInterfaceMainWindow();
}

//#define UNIT_TEST
void Main()
{
#if !UNIT_TEST
    // TODO: todo
#else
    Test::TestMain();
#endif
}


Interface::ManagePresets m_interface;

void RenderMenu()
{
    m_interface.RenderMenu();
}

void RenderInterface()
{
    m_interface.RenderWindow();
}

//#define UNIT_TEST
void Main()
{
#if !UNIT_TEST
    m_interface.Load();
#else
    Test::TestMain();
#endif
}

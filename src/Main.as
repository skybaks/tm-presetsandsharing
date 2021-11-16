
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
    // TODO: todo
#else
    Test::TestMain();
#endif
}

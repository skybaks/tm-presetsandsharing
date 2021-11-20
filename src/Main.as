//#define UNIT_TEST

#if !UNIT_TEST
Interface::ManagePresets m_interface;
#endif

void RenderMenu()
{
#if !UNIT_TEST
    m_interface.RenderMenu();
#endif
}

void RenderInterface()
{
#if !UNIT_TEST
    m_interface.RenderWindow();
#endif
}

void Main()
{
#if !UNIT_TEST
    m_interface.Load();
    int dt = 0;
    int prevFrameTime = Time::Now;
    while (true)
    {
        sleep(50);
        dt = Time::Now - prevFrameTime;
        Interface::Tooltip::Update(dt);
        prevFrameTime = Time::Now;
    }
#else
    Test::TestMain();
#endif
}

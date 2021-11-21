#if !UNIT_TEST

Interface::ManagePresets m_interface;

void RenderMenu()
{
    m_interface.RenderMenu();
}

void RenderInterface()
{
    m_interface.RenderWindow();
}

void Main()
{
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
}

#endif
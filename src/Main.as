#if !UNIT_TEST

Interface::ManagePresets m_interface;

void RenderMenu()
{
    if (m_interface !is null)
    {
        m_interface.RenderMenu();
    }
}

void RenderInterface()
{
    if (m_interface !is null)
    {
        m_interface.RenderWindow();
    }
}

void Main()
{
    if (m_interface !is null)
    {
        m_interface.Load();
    }

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

namespace Manage
{
    class PluginPreset
    {
        private string m_binary;
        private string[] m_categories;

        string[] Categories { get const { return m_categories; } }
        string Binary { get const { return m_binary; } set { m_binary = value; } }

        PluginPreset(string[] categories)
        {
            m_categories = categories;
        }
    }
}

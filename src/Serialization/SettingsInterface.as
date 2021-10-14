
namespace Serialization
{
    class SerializedSettingInfo
    {
        Meta::PluginSetting@ m_setting;
        uint16 m_hash;
    }

    class SettingsInterface
    {
        private Meta::Plugin@ m_plugin;

        SettingsInterface()
        {
        }

        void SetPlugin(Meta::Plugin@ plugin)
        {
            @m_plugin = plugin;
        }

    }
}

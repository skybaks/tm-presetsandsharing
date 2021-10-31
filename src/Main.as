

void Main()
{

    //auto dashSettings = Meta::GetPluginFromID('Dashboard-Dev').GetSettings();
    auto plugin = Meta::GetPluginFromID('Dashboard-Dev');

    auto serial = Serialization::SettingsInterface();
    serial.SetPlugin(plugin);
    serial.WriteCurrentToBinary();

    serial.ReadAndValidateBinary("AHBvg62jM2AH3m4RzUggIaWjM2AHPsA3IPqxEDkUp2ZwAQYCARllEa0FO2QZtPI1D6LnEPh+hmAJAd1ufURyb2lkU2Fucy50dGYstouwXgHIADZ6ozNgB9MDEIsPEZxDEGgYNwogXzcKCqqGUAkg6LGnZnABAgYBjCGLcF4BMmA7EXIrEBTsiGCMAwnEU4uw5gByAbXLEDdCp3dwAQEBASYoNwO6wTYEQQCFUEgMSpARYZuHsDJeAYoEEKdYEUUuEKwHNSEc0ohgjAMEBa+LcOYAMsu5IB42p3dwAQEBAe+5ozNgB2rNNwPsQBFF2DYCloOnZnABAgYB8DSjY3AJAcXapnZwAgEGAfJ5IHhYl3MBAZUgIKU8o2NwCQGMIqMzYAdSCCQBqVwRS4mnd3ABAQEBMvI3AxX3NwXukDsQJ6x0Nwog1aYzcAgBEvUQVUckAn7dNwVt1ad3cAEBAQFdfqdjcAEHAfKgpjNwCAEqUDcFp1Knd3ABAQEBis43A8rINwX3LDcPQNs3NjkgEWE9NxTd6jZLpqmnd3ABAQEBpCg3D46uEUGmfURyb2lkU2Fucy50dGYAFSD7vKMzYAd/oqd3cAEBAQHSO6d3cAEBAQHFKzcDKEI3BdcVNxSfTX1Ecm9pZFNhbnMudHRm+503GHn/IPdaETAeNwXszhHLr6d3cAEBAQHuAzcDwh+TM24Gp3dwAQEBATwSNwPm1jcFA/CWdQYBX1fnlmMIBYYElzMB1WGXcwEBl6iTZwUBD942B3ffNxT5zzYFy2A3GdI3NwqmoX1Ecm9pZFNhbnMudHRmKKk3EA==");

}

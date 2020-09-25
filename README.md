# ESX MOBILE METH
Author: https://forum.cfx.re/u/dividerz/summary

Support: https://discord.gg/WxZ83u3 - New Discord Server for support

# REQUIREMENTS / DEPENDENCIES
- es_extended (legacy) -> https://github.com/esx-framework/es_extended/tree/v1-final
- LegacyFuel (you can edit this yourself) -> https://github.com/InZidiuZ/LegacyFuel

If you're not using LegacyFuel and want to configure your own fuel script, change line 140 in ```client/main.lua```

# USAGE AND INSTALLATION
Insert the .sql file in your database and move the images in 'INVENTORYHUD IMAGE' to your image directory of your inventory script.
Drag and drop this resource in your ESX folder and start it using ```ensure esx_mobilemeth``` in your server.cfg.

# CONFIGURATION OPTIONS
```Config.usingWeight``` set to true when using ESX weight system, false when using ESX limit system
```Config.requiredCops``` defines how many cops need to be connected to be able to use this method

```Config.producingTimeout``` defines the timeout between giving bags

```Config.getVehicle``` defines the vector3 coord where you knock on the door

```Config.spawnVehicle``` defines the vector3 coord where the vehicle should spawn

```Config.spawnHeading``` defines where the vehicle should look towards when spawned


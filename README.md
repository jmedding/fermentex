# Fermentex

This application is intended to control the fermentation portion of the beer brewing process - in other words - it's a temperature controller. I run it on a Rasperberry Pi that uses a DHT11 sensor to measure the current temperature and a pair of 5V relays to turn on and off a cooling system (old refrigerator) and an optional heating element (light bulb inside of the refigerator).

## Setup
TODO: Add info on how to configure the hardware and corresponding config settings.

## Main components
1. Temperature Sensor
2. Fermentation Rate Sensor (aka the Burp sensor) - Coming soon
3. Temperature Controller
4. Temperature Profile
5. Fermentation Runner - Fmeister!


### 1) Temperature Sensor
The temperature sensing is handled by the [Sensor](https://hex.pm/packages/sensor).  This application can be extended to use different types of sensors, which implement a common behaviour. This means, in theory, you can use different temperature sensors without having to adjust this application's code.

### 2) Fermentation Rate Sensor - TODO
The fermenation process generates CO2, which exits the fermentation vesel via a simple bell type air lock.  The bell sits in water and CO2 from the fermentation process is fed into the dome of the bell.  CO2 pressure will push the bell higher and higher until the CO2 can escape from under the endge of the bell, which makes a bubbling sound and results in the bell dropping quickly back into the water.  A simply way to check the fermentation process's vigor is to check the frequency of these burps. Lots of burps per minute (bpms) means lots of CO2 is being generated, which means there are lots of little yeasties hard at work turning sugar into alcohol.  

At the very least, I would like to be able to check this activity on my phone, without having to go down into my basement.  Beyong that, there are some frementing processes that call for different temperatures depending on the stage of the process. The stages of the process are defined by changes in fermentation activtiy. You see where this is going.

### 3) Temperature Controller
This is its own application in the umbrella app.  It's only job is to make things colder and optionally hotter depinding on the messages it receives. In my intitial application, I have a pair of 5V relays that will switch the 220V (Europe...) power to the refrigerator on and off.  The second relay could be used to turn  on a heating element, but normally ambient room temperature is sufficitent for the heating process so I haven't actually implemented it.  I'm not going to give any info on how to wire this up beyond the switching the relay via th RPi.  Working with 220V is super dangerous and will most likely burn your house down, killing you and your family.

### 4) Temperature Profile
This tells the application what the desired temperature is at any given time. At the moment, the application can only hold a steady temperature, which will be sufficient for many different types of beer. Eventually, I will extend this to be able to handle multi-segment profiles and even dynamic profiles (ie changing temerpature based on bpms)

### 5) Fmeister (Fermenetation runner)
Pronounced "Eff M-eye-ster". This will make sense if you understand German. Fmeister controls the hole process. It gets temperature measurements, compares them to the nominal value from the profile and tells the temperature controller to either make it hotter, colder or to stop.....

## Motivation
I wanted to make a real OTP app to learn Elixir design patterns and best practices before heading off into the world of Phoenix.  With that in mind, please let me know if anything could be improved or done in a more ideomatic way.  I'm really open to inputs.

## Next steps
1. Implement a proper profile handler.
2. Implement the bûrp sensor
3. Add a simple phoenix app to first display progress and eventually remote control the process
4. Add more temperature sensors
5. Make this a Nerves project.

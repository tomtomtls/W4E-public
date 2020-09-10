# Watch4Everybody

This is my first attempt to build a watch face, since I could not find the perfect one (<i>i.e</i> integrating all my requirements!).
I was originally looking for HUGE hours, minutes and date display. And if possible steps + stairs daily achievements, and "of course" battery information, all included in a nice layout. That's where things became tricky, since huge means "<i>as big as possible</i>" for me, and there are few watchfaces available with this base. After few searchs on Garmin market, I concluded  I add to build it on my own, and started learning Monkey C + Garmin SDK.
When I first started to design the watchface on a blank page, I discovered I should be able to build something very cute, with colored arcs, icons, etc. And this is what it now looks like:

![Watch4Everybody Cover Image](/screenshots/W4Ecover.png) 

## How to use

1. Install the watchface through Garmin's store (pay attention it is only compatible with 240 pixels rounded screen for now)
2. Go to Garmin Express app on your phone and set your options
3. Enjoy!

## Description

Even if my first idea was quite basic, all along the development process I had many ideas to improve. And as a poor lonesome developer, I decided to enhance the watchface with tones of options!
It now offers:
	* huge time font and date on simple view
	* move alert + battery + stairs + steps arc
	* alarm + bluetooth + notifications icons
	* (optionnal) weekly active minutes arc, bar or icon
	* (optionnal) moon phase arc, bar or icon

## Configuration

### Background color
People (including me!) usually use a lack background. By the way, this option allows people to change the background to others colors so that everyone is happy.

### Hours and minutes color
This one should be quite easy: if you want to change hours and/or minutes font color, just choose the one you like

### Show weekly active minutes
Allows you to display (or not!) weekly active minutes based 

### Show moon phases
As for active minutes, you can choose between no display, vertical bar display (see below), icon display and arc display (see below as well)

__*** Note__ : vertical bar and arc display are defined this way:
1. new moon is displayed as a (full) dark gray moon, therefore as a full bar or full arc
2. evening crescent is displayed as very small (25%) light gray pieces of bar or arc at the bottom of the screen
3. first quarter is displayed as half (50%) light gray pieces of bar or arc at the bottom of the screen
4. waxing gibous is displayed as 3/4 (75%) light gray pieces of bar or arc at the bottom of the screen
5. full moon is displayed as a (full) white moon, therefore as a full bar or full arc
6. waning gibous is displayed as 3/4 (75%) light gray pieces of bar or arc at the top of the screen
7. last quarter is displayed as half (50%) light gray pieces of bar or arc at the top of the screen
8. morning quarter is displayed as very small (25%) light gray pieces of bar or arc at the top of the screen

## Release notes

### latest version (v1.0.1):
- Weekly Active Minutes icon offset corrected

### v1.0.0:
- First public version
- Reduced Weekly Active Minutes and Moon Phases icons by 20%

### v0.9.3.3:
- Moon phase "Arc" option corrected
- Weekly Active Minutes "Arc" option enhanced, now displaying 4 colors:
	* red from 10 to 29%
	* orange until 49%
    * yellow until 79%
    * green from 80 to 100% (or more) 

### v0.9.2.3.2:
- Worked on "Arc" option to display moon phases and weekly active minutes more rapidly and easily

### older versions:
- From alpha to beta: too long to be shared!

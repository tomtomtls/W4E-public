using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian;
using Toybox.Application;

const INTEGER_FORMAT = "%d";
var gIconsFont;
var gIconsFont_Moon;
var gIconsFont_Active;
var notifFont;
var showActiveMinute = 0;
var showMoonBar = 0;
var Dodo = 0;
var gHoursColor = "OxOOOOOO";
var gMinutesColor = "0xFFFFFF";
var gBackgroundColor;
//var gForegroundColor;

class Watch4TOmView extends WatchUi.WatchFace {

	var watchHeight;			
	var watchWidth;

    function initialize() {
        WatchFace.initialize();
        Application.getApp().onSettingsChanged();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));

        watchHeight = dc.getHeight();
		watchWidth = dc.getWidth();

		gIconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
		notifFont = WatchUi.loadResource(Rez.Fonts.NormalFont);
		gIconsFont_Moon = WatchUi.loadResource(Rez.Fonts.MoonFont);
		gIconsFont_Active = WatchUi.loadResource(Rez.Fonts.ActiveFont);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }


    // Update the view
    function onUpdate(dc) {

        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        // Manage BT icon when phone NOT connected even in sleep mode screen
        if (System.getDeviceSettings().phoneConnected == 0) {
        	drawBluetooth(dc, System.getDeviceSettings().phoneConnected);
        }
        
        //! Only draw arcs and icons if gesture or button push detected
        if (Dodo==0) {
	        // Manage BT icon when not sleeping AND phone connected
	      	if (System.getDeviceSettings().phoneConnected == 1) {
        		drawBluetooth(dc, System.getDeviceSettings().phoneConnected);
			} 	
	        
	        // Manage Alarm icon
	        if (System.getDeviceSettings().alarmCount > 0) {
	        	drawAlarm(dc);
	        }
	        
	        // Manage DND icon
//	        if (System.getDeviceSettings().doNotDisturb == 1)  {
//	        	drawDND(dc);
//	        } 	
	        
	        // Manage Arcs
	        drawMyArcs(dc); 
	        
	        // Manage Notifications       
	        if (System.getDeviceSettings().notificationCount > 0)  {
	        	drawMyNotif(dc, System.getDeviceSettings().notificationCount);
	        }
	        
	        // Manage Active Minutes
	        if (showActiveMinute > 0) { // 0 do NOT calculate nor show ; 1 bar ; 2 icon ; 3 arc
	        	drawActiveMinutes(dc);
	        }
	        
	        // Manage Moon Phase
	        if (showMoonBar > 0) { // 0 do NOT calculate nor show ; 1 bar ; 2 icon ; 3 arc
	        	moonPhaseDisplay(dc);
	        }
	        
    	} // End of NOT Dodo
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	//System.println("Réveillé !");
    	Dodo = 0;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	//System.println("Dodo !");
    	Dodo = 1;
    }
    
    function drawMyArcs(dc) {
    // Use drawArc() to draw an arc.
	// 0 degree: 3 o'clock position.
	// 90 degrees: 12 o'clock position.
	// 180 degrees: 9 o'clock position.
	// 270 degrees: 6 o'clock position.
	// @param [Number] x X location of arc center
	// @param [Number] y Y location of arc center
	// @param [Number] r radius of arc.
	// @param [Number] attr Arc drawing attributes. (ARC_COUNTER_CLOCKWISE or ARC_CLOCKWISE)
	// @param [Number] degreeStart The start angle of the arc by degrees.
	// @param [Number] degreeEnd The end angle of the arc by degrees.
	
	dc.setPenWidth(10); // width of all arcs to be drawn
	var rLocal=dc.getWidth()/2-1; // radius of arcs to be drawn
	
//	//! external Battery Arc 360°   
//	var topBattery=90; // 100% => full (360°) arc
//	var myBattery=System.getSystemStats().battery;
//	//System.println("myFloors: "+myFloors);
//	//System.println("myFloorsGoal: "+myFloorsGoal);
//	if (myBattery!=null) {
//		var myBatteryAngle=myBattery*360/100;
//		//System.println("myFloorsAngle: "+myFloorsAngle);
//		var myAngularBattery=90-myBatteryAngle;
//		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
//		//dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 270, 230);
//		dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 90, myAngularBattery);
//	}
//	//! End of Battery Arc
//	

	
	//! Steps Arc from 12h to 03h00 = 0 steps to 10000+ steps
	var topArc = 90; // 0 step = 12 o'clock = 90°
	var mySteps = ActivityMonitor.getInfo().steps;
	var myStepsGoal = ActivityMonitor.getInfo().stepGoal;

	if ((mySteps != null) && (myStepsGoal != null) && (myStepsGoal != 0)) { // Ateps Arc only calculated if necessary (and possible !)

		var myAngle = mySteps * 90 / myStepsGoal;
		//System.println("myAngle: "+myAngle);
		var myAngularSteps = topArc - myAngle; // 90° = 0 step until 0° = 10000+ steps

		if (myAngularSteps < 0) { // if more Steps than Steps Goal (to be implemented : a way to display more than 100%)
			//System.println("On force 0°");
			myAngularSteps = 0;
		}

		if (myAngularSteps < 90) { // Steps Arc only drawn if actual steps > 0
			//System.println("myAngularSteps: "+myAngularSteps);
			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
			dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, topArc, myAngularSteps);
		}
	}
	//! End of Steps Arc

	
	//! Move Arc from 03h to 06h00 => move level 0 to move level 5 
	var topMoves = 360; // level 0 => 03 o'clock => 360°
	var myMoves = ActivityMonitor.getInfo().moveBarLevel;
	//System.println("myMoves: "+myMoves);
	if (myMoves > 0)  { // movebar arc only drawn if necessary
		
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		
		switch (myMoves) {
			
			case 1:	 // First level of movebar detected: draw points
					for (var i=360 ; i>=343 ; i-=2) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-1);
					}
					break;
		
			case 2:	// Draw level 1 + small bars 
					// First level of movebar detected: 
					for (var i=360 ; i>=343 ; i-=2) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-1);
					}
					// Second part of the Arc in pair with second level of movebar detected
					for (var i=342 ; i>=325 ; i-=3) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-2);
					}
					break; 
			
			case 3: // Draw level 1 + level 2 + bars
					// First level of movebar detected
					for (var i=360 ; i>=343 ; i-=2) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-1);
					}
					// Second part of the Arc in pair with second level of movebar detected
					for (var i=342 ; i>=325 ; i-=3) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-2);
					}
					// Third part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 324, 319);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 318, 313);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 312, 307);
					break;
		
			case 4:// Draw level 1 + level 2 + level 3 + huge bars
					// First level of movebar detected
					for (var i=360 ; i>=343 ; i-=2) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-1);
					}
					// Second part of the Arc in pair with second level of movebar detected
					for (var i=342 ; i>=325 ; i-=3) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-2);
					}
					// Third part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 324, 319);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 318, 313);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 312, 307);
					// Fourth part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 306, 298);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 297, 289);
					break;
		
			case 5: // Draw level 1 + level 2 + level 3 + level 4 + arc
					// First level of movebar detected
					for (var i=360 ; i>=343 ; i-=2) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-1);
					}
					// Second part of the Arc in pair with second level of movebar detected
					for (var i=342 ; i>=325 ; i-=3) {
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, i, i-2);
					}
					// Third part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 324, 319);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 318, 313);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 312, 307);
					// Fourth part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 306, 298);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 297, 289);
					// Fifth part of the Arc in pair with second level of movebar detected
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 297, 270);
					break;
		}
		//dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, topMoves, myMovesAngle);
	}	
	//! End of Move Arc

	
//	//! Active Arc from 06h to 09h00 => 0 to 100% per day 
//	var topActive=270; // 0% => 06 o'clock
//	var myMinutesActive=ActivityMonitor.getInfo().activeMinutesWeek.total;
//	var myMinutesActiveGoal=ActivityMonitor.getInfo().activeMinutesWeekGoal;
//	//System.println("myMinutesActive: "+myMinutesActive);
//	//System.println("myMinutesActiveGoal: "+myMinutesActiveGoal);
//	if ((myMinutesActive!=null) && (myMinutesActiveGoal!=null)) {
//		var myActiveAngle=myMinutesActive*90/myMinutesActiveGoal;
//		//System.println("myActiveAngle: "+myActiveAngle);
//		if (myActiveAngle>0) { // Active arc only drawn if necessary
//			var myAngularActive=topActive-myActiveAngle;
//			if (myAngularActive <180) { //in case Active Minutes are more than 100%
//				myAngularActive = 180;
//			}  
//			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
//			//dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 270, 230);
//			dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, topActive, myAngularActive);
//		}
//	}
//	//! End of Active Arc


	//! Battery Arc from 06h to 09h00 => 0 to 100% per day 
	var topBattery = 270; // 0% => 06 o'clock
	var myBattery = System.getSystemStats().battery;
	
	if (myBattery != null) {
		var myBatteryAngle = myBattery * 90 / 100;
		var myAngularBattery = topBattery - myBatteryAngle;
		if (myBattery >= 30) { // battery between 100 and 30% : white color arc
			dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		}
		else {
			if (myBattery >= 15) { // battery between 29 and 15% : yellow color arc 
				dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
			}
			else { // battery less than 15% : red color arc
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			}
		}
		dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, topBattery, myAngularBattery);
	}
	//! End of Active Arc

	
	//! Floors Arc from 09h to 12h00 => 0 to 100% per day 
	var topFloors = 180; // 0% => 09 o'clock
	var myFloors = ActivityMonitor.getInfo().floorsClimbed;
	var myFloorsGoal = ActivityMonitor.getInfo().floorsClimbedGoal;
	
	if ((myFloors != null) && (myFloorsGoal != null)) {
		var myFloorsAngle = myFloors * 90 / myFloorsGoal;
		
		if (myFloorsAngle > 0) { // Floors arc only drawn if necessary
			var myAngularFloors = topFloors - myFloorsAngle;
			if (myAngularFloors < 90) { //in case Fllors climbed are more than 100%
				myAngularFloors = 90;
			}  
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
			//dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 270, 230);
			dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, topFloors, myAngularFloors);
		}
	}
	//! End of Floors Arc
	
	
    }// end of drawArcs()
    
	function drawBluetooth(dc, phoneConnected)  {

		var x = 120;
		var y = 205;
		
		if (phoneConnected == 1) {
			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
		}
		else {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		}

		dc.drawText(
			x,
			y,
			gIconsFont,
			"8", // BT characters
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}// end of drawBluetooth()

	
	function drawAlarm(dc)  {

		var x = 80;
		var y = 205;
		
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		
		dc.drawText(
			x,
			y,
			gIconsFont,
			":", // Alarm characters
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}// end of drawAlarm()

	
	function drawMyNotif(dc, nb)  {

		var x = 160;
		var y = 205;
		
		dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		
		dc.drawText(
			x,
			y,
			gIconsFont,
			"5", // Notification characters
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
		
		x+=18; // shift x to display notif number 
		
		dc.drawText(
			x,
			y,
			notifFont,
			nb, // Notification characters
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);
	}// end of drawMyNotif()

	
//	function drawDND(dc)  {
//
//		var x = 180;
//		var y = 205;
//		
//		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
//		
//		dc.drawText(
//			x,
//			y,
//			gIconsFont_DND,
//			"f", // DND characters
//			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
//		);
//	}// end of drawDND()


	function drawActiveMinutes(dc) {
	
		//System.println("Goal: "+ActivityMonitor.getInfo().activeMinutesWeekGoal);
		var myMinutesActive = ActivityMonitor.getInfo().activeMinutesWeek.total * 100 / ActivityMonitor.getInfo().activeMinutesWeekGoal;
		
		if (myMinutesActive == null) {
			myMinutesActive = 0;
		}

		if (showActiveMinute == 1) { // draw bar option
			var x = 30;
			var y = 170;		
		
			if (myMinutesActive >= 100) { // arc starts at 230° (0% WAM) and grows until 130° (100% WAM)		
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
				dc.drawRoundedRectangle(x, y, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
				dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
				dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
				dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
				dc.drawRoundedRectangle(x, y-60, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-72, 5, 3, 2);
				dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
				dc.drawRoundedRectangle(x, y-84, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-96, 5, 3, 2);
				dc.drawRoundedRectangle(x, y-108, 5, 3, 2);
				
			}
			
			else {
				if (myMinutesActive >= 90) {
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
					dc.drawRoundedRectangle(x, y, 5, 3, 2);
					dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
					dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
					dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
					dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
					dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
					dc.drawRoundedRectangle(x, y-60, 5, 3, 2);
					dc.drawRoundedRectangle(x, y-72, 5, 3, 2);
					dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
					dc.drawRoundedRectangle(x, y-84, 5, 3, 2);
					dc.drawRoundedRectangle(x, y-96, 5, 3, 2);		
				}
				
				else {
					if (myMinutesActive >= 80) {
						dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
						dc.drawRoundedRectangle(x, y, 5, 3, 2);
						dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
						dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
						dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
						dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
						dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
						dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
						dc.drawRoundedRectangle(x, y-60, 5, 3, 2);
						dc.drawRoundedRectangle(x, y-72, 5, 3, 2);
						dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
						dc.drawRoundedRectangle(x, y-84, 5, 3, 2);
					}
			
					else {
						if (myMinutesActive >= 70) {
							dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
							dc.drawRoundedRectangle(x, y, 5, 3, 2);
							dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
							dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
							dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
							dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
							dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
							dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
							dc.drawRoundedRectangle(x, y-60, 5, 3, 2);
							dc.drawRoundedRectangle(x, y-72, 5, 3, 2);			
						}
			
						else {
							if (myMinutesActive >= 60) {
								dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
								dc.drawRoundedRectangle(x, y, 5, 3, 2);
								dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
								dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
								dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
								dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
								dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
								dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
								dc.drawRoundedRectangle(x, y-60, 5, 3, 2);
							}
							
							else {
								if (myMinutesActive >= 50) {
									dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
									dc.drawRoundedRectangle(x, y, 5, 3, 2);
									dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
									dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
									dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
									dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
									dc.drawRoundedRectangle(x, y-48, 5, 3, 2);
								}
				
								else {
									if (myMinutesActive >= 40) {
										dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
										dc.drawRoundedRectangle(x, y, 5, 3, 2);
										dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
										dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
										dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
										dc.drawRoundedRectangle(x, y-36, 5, 3, 2);
									}
				
									else {
										if (myMinutesActive >= 30) {
											dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
											dc.drawRoundedRectangle(x, y, 5, 3, 2);
											dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
											dc.drawRoundedRectangle(x, y-24, 5, 3, 2);
										}
				
										else {
											if (myMinutesActive >= 20) {
												dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
												dc.drawRoundedRectangle(x, y, 5, 3, 2);
												dc.drawRoundedRectangle(x, y-12, 5, 3, 2);
											}
											
											else {
												if (myMinutesActive >= 10) {
													dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
													dc.drawRoundedRectangle(x, y, 5, 3, 2);
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		} // end if (showActiveMinute == 1)
		
		else { 
			if (showActiveMinute == 2) { // draw icon option
			
				var x = 30 ;
				var y = 120;			
				
				//color depends on the level of Weekly Active Minutes Active
				if (myMinutesActive >= 90) { 			
					dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
				}
				else {
					if (myMinutesActive >= 60) {
						dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
					}
					
					else {
						if (myMinutesActive >= 30) {
							dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
						}
						
						else {
							dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
						}
					}
				}
				
				dc.drawText(
					x,
					y,
					gIconsFont_Active,
					"A",
					Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
				);
			} // end if (showActiveMinute == 2)
			
			else { // showActiveMinute should be equal to 3 so draw arc option
			
				dc.setPenWidth(10); // width of all arcs to be drawn
				var rLocal = dc.getWidth() / 2 - 16; // radius of arcs to be drawn
				//System.println("myMinutesActive: "+myMinutesActive);
				
				//dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 230, 130);
				
				if (myMinutesActive >= 10) { 			
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 230, 220);
				}
				
				if (myMinutesActive >= 20) {
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 220, 210);
				}
					
				if (myMinutesActive >= 30) {
					dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 210, 200);
				}
						
				if (myMinutesActive >= 40) {
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 200, 190);
				}
							
				if (myMinutesActive >= 50) {
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 190, 180);
				}
						
				if (myMinutesActive >= 60) {
					dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 180, 170);
				}
									
				if (myMinutesActive >= 70) {
					dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 170, 160);
				}
									
				if (myMinutesActive >= 80) {
					dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 160, 150);
				}
										
				if (myMinutesActive >= 90) {
					dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 150, 140);
				}
										
				if (myMinutesActive >= 100) {
					dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 140, 130);
				}
			}
		}
	} // end of drawActiveMinutes	


    static function normalize(value)
    {
    	var nValue = value - Math.floor(value);
    	if (nValue < 0)
    	{
    		nValue = nValue + 1;
    	}
    	return nValue;
    } // End of normalize


	static function getMoonPhase(timeNow) // from Watch4Me
    {   	
    	var JD = timeNow.value().toDouble() / Gregorian.SECONDS_PER_DAY.toDouble() + 2440587.500d;
    	var IP = normalize((JD.toDouble() - 2451550.1d) / 29.530588853d);
    	var Age = IP * 29.53d;
    	
    	var phase = 0;
    	if(      Age <  1.84566 ) {phase = 0;} // new moon
        else if( Age <  5.53699 ) {phase = 1;} // evening crescent aka small first quarter
        else if( Age <  9.22831 ) {phase = 2;} // first quarter
        else if( Age < 12.91963 ) {phase = 3;} // waxing gibbous
        else if( Age < 16.61096 ) {phase = 4;} // full moon
        else if( Age < 20.30228 ) {phase = 5;} // waning gibbous
        else if( Age < 23.99361 ) {phase = 6;} // last quarter
        else if( Age < 27.68493 ) {phase = 7;} // morning crescent aka small last quarter
        else                      {phase = 0;} // new moon

    	return [phase];
    } // End of getMoonPhase


	function moonPhaseDisplay(dc) {
		
		var moonData = getMoonPhase(Time.now());
		
		if (showMoonBar == 1) {
			
			var x = 205; // set x moon phase diagram depending on ActiveMinutes bar so that it seems centered 
			var y = 173;
			
			//System.println("moonData[0]: "+moonData[0]);
			
			if (moonData[0] == 4) { // Full moon: all rectangles displayed in white
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
				dc.drawRoundedRectangle(x, y, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-16, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-32, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-48, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-64, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-80, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-96, 5, 8, 2);
				dc.drawRoundedRectangle(x, y-112, 5, 8, 2);
			}
			
			else {
				if (moonData[0] == 0) { // New moon: all rectangles displayed in dark grey
					dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
					dc.drawRoundedRectangle(x, y, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-16, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-32, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-48, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-64, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-80, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-96, 5, 8, 2);
					dc.drawRoundedRectangle(x, y-112, 5, 8, 2);
				}
				
				else {
					if (moonData[0] == 1) { // Evening crescent aka small first quarter: two rectangles starting at the bottom of the screen
						dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
						dc.drawRoundedRectangle(x, y, 5, 8, 2);
						dc.drawRoundedRectangle(x, y-16, 5, 8, 2);
					}
					
					else {
						if (moonData[0] == 2) { // First quarter: 4 rectangles starting at the bottom of the screen
							dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
							dc.drawRoundedRectangle(x, y, 5, 8, 2);
							dc.drawRoundedRectangle(x, y-16, 5, 8, 2);
							dc.drawRoundedRectangle(x, y-32, 5, 8, 2);
							dc.drawRoundedRectangle(x, y-48, 5, 8, 2);
						}
						
						else {
							if (moonData[0] == 3) { // Waxing gibbous: 6 rectangles starting at the bottom of the screen
								dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
								dc.drawRoundedRectangle(x, y, 5, 8, 2);
								dc.drawRoundedRectangle(x, y-16, 5, 8, 2);
								dc.drawRoundedRectangle(x, y-32, 5, 8, 2);
								dc.drawRoundedRectangle(x, y-48, 5, 8, 2);
								dc.drawRoundedRectangle(x, y-64, 5, 8, 2);
								dc.drawRoundedRectangle(x, y-80, 5, 8, 2);
							}
							
							else {
								if (moonData[0] == 5) { // Waning gibbous: 6 rectangles starting at the top of the screen
									dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
									dc.drawRoundedRectangle(x, y-32, 5, 8, 2);
									dc.drawRoundedRectangle(x, y-48, 5, 8, 2);
									dc.drawRoundedRectangle(x, y-64, 5, 8, 2);
									dc.drawRoundedRectangle(x, y-80, 5, 8, 2);
									dc.drawRoundedRectangle(x, y-96, 5, 8, 2);
									dc.drawRoundedRectangle(x, y-112, 5, 8, 2);
								}
								
								else {
									if (moonData[0] == 6) { // Last quarter: 4 rectangles starting at the top of the screen
										dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
										dc.drawRoundedRectangle(x, y-64, 5, 8, 2);
										dc.drawRoundedRectangle(x, y-80, 5, 8, 2);
										dc.drawRoundedRectangle(x, y-96, 5, 8, 2);
										dc.drawRoundedRectangle(x, y-112, 5, 8, 2);
									}
									
									else {
										if (moonData[0] == 7) { // Morning crescent aka last small quarter: 2 rectangles starting at the top of the screen
											dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
											dc.drawRoundedRectangle(x, y-96, 5, 8, 2);
											dc.drawRoundedRectangle(x, y-112, 5, 8, 2);
										}
									}
								}
							}
						}
					}
				}
			}
		} // showMoonBar == 1
		
		else { 
		
			if (showMoonBar == 2) { // draw icons
		
				var x = 215 ;
				var y = 120 ;
				
				//System.println("showMoonBar: "+showMoonBar);
				dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
				
				if (moonData[0] == 4) { // Full moon: all rectangles displayed in white
					dc.drawText(
						x,
						y,
						gIconsFont_Moon,
						"0", // full moon char
						Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
					);
				}
				
				else {
					if (moonData[0] == 0) { // New moon
						dc.drawText(
							x,
							y,
							gIconsFont_Moon,
							"@", // new moon char
							Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
						);
					}
					
					else {
						if (moonData[0] == 1) { // Evening crescent aka small first quarter
							dc.drawText(
								x,
								y,
								gIconsFont_Moon,
								"C",
								Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
							);
						}
						
						else {
							if (moonData[0] == 2) { // First quarter
								dc.drawText(
									x,
									y,
									gIconsFont_Moon,
									"E",
									Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
								);
							}
							
							else {
								if ((moonData[0] == 3) || (moonData[0] == 5)) { // Waxing gibbous or Waning gibbous
									dc.drawText(
										x,
										y,
										gIconsFont_Moon,
										"G",
										Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
									);
								}
								
								else {
									if (moonData[0] == 6) { // Last quarter
										dc.drawText(
											x,
											y,
											gIconsFont_Moon,
											"I",
											Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
										);
									}
									
									else {
										if (moonData[0] == 7) { // Morning crescent aka last small quarter
											dc.drawText(
												x,
												y,
												gIconsFont_Moon,
												"K",
												Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
											);
										}
									}	
								}
							}
						}
					}
				}
			} // end of icon mode	
			
			else { // showMoonBar should be equal to 3: arc mode
			
				dc.setPenWidth(10); // width of all arcs to be drawn
				var rLocal = dc.getWidth() / 2 - 16; // radius of arcs to be drawn
				
				if (moonData[0] == 4) { // Full moon: all rectangles displayed in white
					dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
					dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 50, 310);	
				}
				
				else {
					if (moonData[0] == 0) { // New moon
						dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
						dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 50, 310);
					}
					
					else {
						if (moonData[0] == 1) { // Evening crescent aka small first quarter
							//System.println("moonData[0]: "+moonData[0]);
							dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
							dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 335, 310);
						}
						
						else {
							if (moonData[0] == 2) { // First quarter
								//System.println("moonData[0]: "+moonData[0]);
								dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
								dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 0, 310);
							}
							
							else {
								if (moonData[0] == 3) { // Waxing gibbous
									//System.println("moonData[0]: "+moonData[0]);
									dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
									dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 25, 310);						
								}
								
								else {
									if (moonData[0] == 5) {// Waning gibbous
										//System.println("moonData[0]: "+moonData[0]);
										dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
										dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 50, 335);
									}
								
									else {
										if (moonData[0] == 6) { // Last quarter
											//System.println("moonData[0]: "+moonData[0]);
											dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
											dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 50, 0);
										}
										
										else {
											if (moonData[0] == 7) { // Morning crescent aka last small quarter
												//System.println("moonData[0]: "+moonData[0]);
												dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
												dc.drawArc(120, 120, rLocal, Graphics.ARC_CLOCKWISE, 50, 25);
											}
										}	
									}	
								}
							}
						}
					}
				}
			}	
		}
	} // end of moonPhaseDisplay
}

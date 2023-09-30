// W Prime Bal on Connect IQ / 2015 - 2022 Gregory Chanez
// Find details about this software on <www.nakan.ch> (french) or
// <www.trinakan.com> (english)
// Enjoy your ride !
// *
// * This program is free software: you can redistribute it and/or modify
// * it under the terms of the GNU General Public License as published by
// * the Free Software Foundation, either version 3 of the License, or
// * (at your option) any later version.
// *
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program.  If not, see <http://www.gnu.org/licenses/>.
// *
// - Most of the source here is adapted from GoldenCheetah wprime.cpp
// - <http://www.goldencheetah.org> software, also available under GPL.
// - Thanks to their authors, and specially to Mark Liversedge for his
// - blog post about W Prime implementation <http://markliversedge.blogspot.ch/>

using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application as App;
// using Toybox.FitContributor as Fit;
using Toybox.AntPlus;
using Toybox.UserProfile;

class WPRIMEBALViewPct extends Ui.SimpleDataField {

	// Constants
	const WPRIME_BAL_FIELD_ID = 0;
	var CP;
	var WPRIME;
	var FORMULA;
	var VALUE;
	var TTE;
	var SPORT;

	// Variables
	var rollingpwr = new [10];
	var avgpwr = 0;
	var remainsec;
	var remainmin;
	// var wprimebalField = null;
	var elapsedSec = 0;
	var pwr = 0;
	var powerValue;
	var I = 0;
	var output;
	var wprimebal = 0;
	var wprimebalpc = 100;
	var totalBelowCP = 0;
	var countBelowCP = 0;
	var TAUlive = 0;
	var W = 0;

	var listener;
	var bikePower;

    //! Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        // Get current sport profile
        var SportProfile = UserProfile.getCurrentSport();
		// IF SPORT IS RUNNING
		if (SportProfile == 1) {
			CP = App.getApp().getProperty("RFTPW").toNumber();
			WPRIME = App.getApp().getProperty("RWPRIME").toNumber();
			SPORT = "R";
		}

        // IF SPORT IS CYCLING
		else {
			CP = 280; // App.getApp().getProperty("CP").toNumber();
			WPRIME = 20000; //App.getApp().getProperty("WPRIME").toNumber();
			SPORT="C";
		}

		// GLOBAL SETTINGS
    	// FORMULA = App.getApp().getProperty("FORMULA").toNumber();
    	// VALUE = App.getApp().getProperty("VALUE").toNumber();
    	// TTE = App.getApp().getProperty("TTE").toNumber();
    	FORMULA = 0;
    	VALUE = 0;
    	TTE = 0;

    	// Initialize the array of the last 10 seconds of power
    	for(var i = 0; i < rollingpwr.size(); i++) {
			rollingpwr[i] = 0;
		}

		// If the formula is differential, initial value of w'bal is WPRIME.
		if (FORMULA == 1) {
			wprimebal = WPRIME;
		}

		// Change the field title with the compute method choosen
		if (FORMULA == 0) {
			if (VALUE == 0) {
				// label = "% W' Bal (int)";
				label = "W'bal %";
			}
			else {
				// label = "kJ W' Bal (int)";
				label = "W'bal";
			}
		}
		else {
			if (VALUE == 0) {
				label = "% W' Bal (diff)";
			}
			else {
				label = "kJ W' Bal (diff)";
			}
    	}
    	// Create the custom FIT data field we want to record.
        // wprimebalField = createField(
        //     "wprime_bal",
        //     WPRIME_BAL_FIELD_ID,
        //     Fit.DATA_TYPE_FLOAT,
        //     {:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"kJ"}
        // );
        // wprimebalField.setData(wprimebal/1000);

		// Initialize the AntPlus.BikePowerListener object
		listener = new MyBikePower();

		// Initialize the AntPlus.BikePower object with a listener
		bikePower = new AntPlus.BikePower(listener);
    }


    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.

        // Check if the activity is started or not
		if (info.elapsedTime > 0) {

			// Check if power is negative or null, and normalize it to 0.
			var calculatedPower = bikePower.getCalculatedPower();
			if (calculatedPower == null || calculatedPower.power == null || calculatedPower.power < 0) {
				pwr = 0;
			} else {
				pwr = calculatedPower.power;
			}

			// Method by differential equation Froncioni / Clarke
			if (FORMULA == 1) {
				if (pwr < CP) {
				  	wprimebal = wprimebal + (CP-pwr)*(WPRIME-wprimebal)/WPRIME.toFloat();
				}
				else {
					wprimebal = wprimebal + (CP-pwr);
				}
			}

			// Method by integral formula Skiba et al
			else {
				// powerValue
				if (pwr > CP) {
					powerValue = (pwr - CP);
				}
				else {
					powerValue = 0;
				}
				// Compute TAU
				if (pwr < CP) {
					totalBelowCP += pwr;
					countBelowCP++;
				}
				if (countBelowCP > 0) {
					TAUlive = 546.00 * Math.pow(Math.E, -0.01*(CP - (totalBelowCP/countBelowCP))) + 316;
	  			}
				else {
					TAUlive = 546 * Math.pow(Math.E, -0.01*(CP)) + 316;
				}

				// Start compute W'Bal
				I += Math.pow(Math.E, (elapsedSec.toFloat()/TAUlive.toFloat())) * powerValue;
				output = Math.pow(Math.E, (-elapsedSec.toFloat()/TAUlive.toFloat())) * I;
				wprimebal = WPRIME - output;
			}

			// TTE: Add current value to 10 sec history
			rollingpwr = rollingpwr.slice(1, 10);
			rollingpwr.add(pwr);

			// TTE: Compute TTE
    		for(var i = 0; i < rollingpwr.size(); i++) { avgpwr += rollingpwr[i]; }
    		avgpwr = avgpwr/10;
    		if (avgpwr - CP != 0) {
				remainsec = wprimebal/(avgpwr - CP);
			}
			remainmin = Math.floor(remainsec/60);
			remainsec = remainsec - (remainmin*60);

			if (VALUE == 0) {
				// Compute a percentage from raw values
				wprimebalpc = wprimebal * (100/WPRIME.toFloat());
			}
			else {
				wprimebalpc = wprimebal/1000;
			}

			// One more second in life...
			elapsedSec++;
		}
		else {
			// Initial display, before the the session is started
			return SPORT + "|" + CP + "|" + WPRIME + "| TTE:" + TTE;
			//Sys.println("Elapsed time: " + info.elapsedTime);
		}

		// For debug purposes on the simulator only
		//Sys.println("REMAIN: " + remainmin.format("%02d") + ":" + remainsec.format("%02d") + " - FORMULA: " + FORMULA + " - ELAPSED SEC: " + elapsedSec + " - POWER: " + pwr + " - WPRIMEBAL: " + wprimebal + " - TAULIVE: " + TAUlive);


		// If TTE is enabled AND the power is higher than CP, then display TTE:
		if ((TTE == 1) && (avgpwr > CP) && (wprimebal > 0)) {
			return remainmin.format("%02d") + ":" + remainsec.format("%02d");
		}
		// Return the value to the watch
		// wprimebalField.setData(wprimebal/1000);
		return wprimebalpc.format("%.1f");
    }
}

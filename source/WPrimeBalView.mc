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
using Toybox.FitContributor as Fit;
using Toybox.AntPlus;
using Toybox.UserProfile;

class WPrimeBalView extends Ui.SimpleDataField {
	// Constants
	const WPRIME_BAL_FIELD_ID = 0;
	var CP;
	var WPRIME;
	var FORMULA;
	var DISPLAY_UNIT;
	var DISPLAY_TTE;
	var DISPLAY_FIT;

	// Variables
	var rollingpwr = new [10];
	var avgpwr = 0;
	var remainsec;
	var remainmin;
	var wprimebalField = null;
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
			CP = Defaults.getRunningCP(App.getApp().getProperty("RunningCP"));
			WPRIME = Defaults.getRunningWPrime(App.getApp().getProperty("RWPrime")) * 1000;
        // IF SPORT IS CYCLING
		} else {
			CP = Defaults.getCriticalPower(App.getApp().getProperty("CriticalPower"));
			WPRIME = Defaults.getWPrime(App.getApp().getProperty("WPrime")) * 1000;
		}

		// GLOBAL SETTINGS
		var formula = App.getApp().getProperty("Formula");
    	FORMULA = formula == null ? 0 : formula.toNumber();
		var displayUnit = App.getApp().getProperty("DisplayUnit");
    	DISPLAY_UNIT = displayUnit == null ? 0 : displayUnit.toNumber();
    	var displayTTE = App.getApp().getProperty("DisplayTTE");
    	DISPLAY_TTE = displayTTE != null && displayTTE.toNumber() == 1;
    	var displayFIT = App.getApp().getProperty("DisplayFIT");
    	DISPLAY_FIT = displayFIT != null && displayFIT.toNumber() == 1;

    	// Initialize the array of the last 10 seconds of power
    	for (var i = 0; i < rollingpwr.size(); i++) {
			rollingpwr[i] = 0;
		}

		// If the formula is differential, initial value of w'bal is WPRIME.
		if (FORMULA == 1) {
			wprimebal = WPRIME;
		}

		// Change the field title with the unit choosen
		label = DISPLAY_UNIT == 0 ? "W'bal %" : "W'bal  kJ";

    	// Create the custom FIT data field we want to record.
		if (DISPLAY_FIT) {
			wprimebalField = createField(
				"wprime_bal",
				WPRIME_BAL_FIELD_ID,
				Fit.DATA_TYPE_FLOAT,
				{:mesgType=>Fit.MESG_TYPE_RECORD, :units=>"kJ"}
			);
			wprimebalField.setData(wprimebal/1000);
		}

		// Initialize the AntPlus.BikePowerListener object
		listener = new AntPlus.BikePowerListener();
		bikePower = new AntPlus.BikePower(listener);
    }


    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.

        // Check if the activity is started or not
		if (info.elapsedTime > 0) {
			if (info has :currentPower) {
				if (info.currentPower == null || info.currentPower < 0) {
					pwr = 0;
				} else {
					pwr = info.currentPower;
				}
			} else {
				var calculatedPower = bikePower.getCalculatedPower();
				if (calculatedPower == null || calculatedPower.power == null || calculatedPower.power < 0) {
					pwr = 0;
				} else {
					pwr = calculatedPower.power;
				}
			}

			// Method by differential equation Froncioni / Clarke
			if (FORMULA == 1) {
				if (pwr < CP) {
				  	wprimebal = wprimebal + (CP-pwr)*(WPRIME-wprimebal)/WPRIME.toFloat();
				} else {
					wprimebal = wprimebal + (CP-pwr);
				}
			// Method by integral formula Skiba et al
			} else {
				powerValue = (pwr > CP) ? (pwr - CP) : 0;

				// Compute TAU
				if (pwr < CP) {
					totalBelowCP += pwr;
					countBelowCP++;
				}
				if (countBelowCP > 0) {
					TAUlive = 546.00 * Math.pow(Math.E, -0.01*(CP - (totalBelowCP/countBelowCP))) + 316;
	  			} else {
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
    		for (var i = 0; i < rollingpwr.size(); i++) { avgpwr += rollingpwr[i]; }
    		avgpwr = avgpwr/10;
    		if (avgpwr - CP != 0) {
				remainsec = wprimebal/(avgpwr - CP);
			}
			remainmin = Math.floor(remainsec/60);
			remainsec = remainsec - (remainmin*60);

			if (DISPLAY_UNIT == 0) {
				// Compute a percentage from raw values
				wprimebalpc = wprimebal * (100/WPRIME.toFloat());
			} else {
				wprimebalpc = wprimebal/1000;
			}

			elapsedSec++;
		} else {
			// Initial display, before the the session is started
			return (DISPLAY_UNIT == 0 ? wprimebalpc : WPRIME/1000).format("%.1f");
		}

		// For debug purposes on the simulator only
		//Sys.println("REMAIN: " + remainmin.format("%02d") + ":" + remainsec.format("%02d") + " - FORMULA: " + FORMULA + " - ELAPSED SEC: " + elapsedSec + " - POWER: " + pwr + " - WPRIMEBAL: " + wprimebal + " - TAULIVE: " + TAUlive);

		// If TTE is enabled AND the power is higher than CP, then display TTE:
		if (DISPLAY_TTE && (avgpwr > CP) && (wprimebal > 0)) {
			return remainmin.format("%02d") + ":" + remainsec.format("%02d");
		}

		if (DISPLAY_FIT) {
			wprimebalField.setData(wprimebal/1000);
		}

		// Return the value to the watch
		return wprimebalpc.format("%.1f");
    }
}

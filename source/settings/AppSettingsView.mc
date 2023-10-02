using Toybox.WatchUi;
import Toybox.Lang;

class AppSettingsDelegate extends WatchUi.Menu2InputDelegate {
	function initialize() {
		Menu2InputDelegate.initialize();
    }

	function onSelect(item) {
		if (item.getId().equals("CriticalPower")) {
			var cpPicker = new NumberPicker(Rez.Strings.CriticalPower, "CriticalPower", Defaults.CriticalPower, 0, 500, 1);
			WatchUi.pushView(cpPicker, new NumberPickerDelegate(cpPicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("WPrime")) {
			var wprimePicker = new NumberPicker(Rez.Strings.WPrime, "WPrime", Defaults.WPrime, 0, 100, 1);
			WatchUi.pushView(wprimePicker, new NumberPickerDelegate(wprimePicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("RunningCP")) {
			var rcpPicker = new NumberPicker(Rez.Strings.RunningCP, "RunningCP", Defaults.RunningCP, 0, 800, 1);
			WatchUi.pushView(rcpPicker, new NumberPickerDelegate(rcpPicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("RWPrime")) {
			var rwprimePicker = new NumberPicker(Rez.Strings.RunningWPrime, "RWPrime", Defaults.RunningWPrime, 0, 100, 1);
			WatchUi.pushView(rwprimePicker, new NumberPickerDelegate(rwprimePicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("Formula")) {
			var formulaPicker = new WordPicker(Rez.Strings.Formula, "Formula", [Rez.Strings.Integral, Rez.Strings.Differential] as Array<Symbol>);
			WatchUi.pushView(formulaPicker, new WordPickerDelegate(formulaPicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("DisplayUnit")) {
			var displayUnitPicker = new WordPicker(Rez.Strings.DisplayUnit, "DisplayUnit", [Rez.Strings.UnitPercent, Rez.Strings.UnitKJ] as Array<Symbol>);
			WatchUi.pushView(displayUnitPicker, new WordPickerDelegate(displayUnitPicker), WatchUi.SLIDE_IMMEDIATE);
		} else if (item.getId().equals("DisplayTTE")) {
			if (item instanceof WatchUi.ToggleMenuItem) {
				var displayTTE = Application.getApp().getProperty("DisplayTTE");
				var currentValue = !(displayTTE == null || displayTTE == 0);
				var toggleValue = item.isEnabled();
				if (currentValue != toggleValue) {
					Application.getApp().setProperty("DisplayTTE", toggleValue ? 1 : 0);
				}
			}
		} else if (item.getId().equals("WriteFIT")) {
			if (item instanceof WatchUi.ToggleMenuItem) {
				var writeFIT = Application.getApp().getProperty("WriteFIT");
				var currentValue = !(writeFIT == null || writeFIT == 0);
				var toggleValue = item.isEnabled();
				if (currentValue != toggleValue) {
					Application.getApp().setProperty("WriteFIT", toggleValue ? 1 : 0);
				}
			}
		}
	}

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class AppSettingsView extends WatchUi.Menu2 {
	hidden var mCP;
	hidden var mWPrime;
	hidden var mRunCP;
	hidden var mRunWPrime;
	hidden var mFormula;
	hidden var formulaList;
	hidden var mDisplayUnit;
	hidden var unitList;

	function initialize() {
		Menu2.initialize({:title => "W'bal Settings"});

		mCP = Application.getApp().getProperty("CriticalPower");
		var currentCP = Defaults.getCriticalPower(mCP).toString();
		addItem(new WatchUi.MenuItem(Rez.Strings.CriticalPower, currentCP, "CriticalPower", {}));

		mWPrime = Application.getApp().getProperty("WPrime");
		var currentWPrime = Defaults.getWPrime(mWPrime).toString();
		addItem(new WatchUi.MenuItem(Rez.Strings.WPrime, currentWPrime, "WPrime", {}));

		mRunCP = Application.getApp().getProperty("RunningCP");
		var currentRunCP = Defaults.getRunningCP(mRunCP).toString();
		addItem(new WatchUi.MenuItem(Rez.Strings.RunningCP, currentRunCP, "RunningCP", {}));

		mRunWPrime = Application.getApp().getProperty("RWPrime");
		var currentRunWPrime = Defaults.getRunningWPrime(mRunWPrime).toString();
		addItem(new WatchUi.MenuItem(Rez.Strings.RunningWPrime, currentRunWPrime, "RWPrime", {}));

		mFormula = Application.getApp().getProperty("Formula");
		formulaList = [Rez.Strings.Integral, Rez.Strings.Differential];
		var currentFormula = formulaList[mFormula == null ? 0 : mFormula];
		addItem(new WatchUi.MenuItem(Rez.Strings.Formula, currentFormula, "Formula", {}));

		mDisplayUnit = Application.getApp().getProperty("DisplayUnit");
		unitList = [Rez.Strings.UnitPercent, Rez.Strings.UnitKJ];
		var currentDisplayUnit = unitList[mDisplayUnit == null ? 0 : mDisplayUnit];
		addItem(new WatchUi.MenuItem(Rez.Strings.DisplayUnit, currentDisplayUnit, "DisplayUnit", {}));

		var displayTTE = Application.getApp().getProperty("DisplayTTE");
		var currentDisplayTTE = !(displayTTE == null || displayTTE == 0);
		addItem(new WatchUi.ToggleMenuItem(Rez.Strings.DisplayTTE, null, "DisplayTTE", currentDisplayTTE, {}));

		var writeFIT = Application.getApp().getProperty("WriteFIT");
		var currentWriteFIT = !(writeFIT == null || writeFIT == 0);
		addItem(new WatchUi.ToggleMenuItem(Rez.Strings.WriteFIT, null, "WriteFIT", currentWriteFIT, {}));
	}

	function onShow() {
		var cp = Application.getApp().getProperty("CriticalPower");
		if (cp != mCP) {
			mCP = cp;

			var item = self.getItem(0);
			if (item != null) {
				item.setSubLabel(mCP.toString());
				self.updateItem(item, 0);
			}
		}

		var wPrime = Application.getApp().getProperty("WPrime");
		if (wPrime != mWPrime) {
			mWPrime = wPrime;

			var item = self.getItem(1);
			if (item != null) {
				item.setSubLabel(mWPrime.toString());
				self.updateItem(item, 1);
			}
		}

		var runCP = Application.getApp().getProperty("RunningCP");
		if (runCP != mRunCP) {
			mRunCP = runCP;

			var item = self.getItem(2);
			if (item != null) {
				item.setSubLabel(mRunCP.toString());
				self.updateItem(item, 2);
			}
		}

		var rwPrime = Application.getApp().getProperty("RWPrime");
		if (rwPrime != mRunWPrime) {
			mRunWPrime = rwPrime;

			var item = self.getItem(3);
			if (item != null) {
				item.setSubLabel(mRunWPrime.toString());
				self.updateItem(item, 3);
			}
		}

		var formula = Application.getApp().getProperty("Formula");
		if (formula != mFormula) {
			mFormula = formula;

			var item = self.getItem(4);
			if (item != null) {
				var currentFormula = formulaList[mFormula == null ? 0 : mFormula];
				item.setSubLabel(currentFormula);
				self.updateItem(item, 4);
			}
		}

		var displayUnit = Application.getApp().getProperty("DisplayUnit");
		if (displayUnit != mDisplayUnit) {
			mDisplayUnit = displayUnit;

			var item = self.getItem(5);
			if (item != null) {
				var currentDisplayUnit = unitList[mDisplayUnit == null ? 0 : mDisplayUnit];
				item.setSubLabel(currentDisplayUnit);
				self.updateItem(item, 5);
			}
		}
	}
}

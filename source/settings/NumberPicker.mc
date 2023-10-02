using Toybox.WatchUi;

class NumberPicker extends WatchUi.Picker {
	var prop;

	function initialize(label, p, def, min, max, step) {
		prop = p;

		var val = Application.getApp().getProperty(prop);
		var defaultCP = val == null ? def : val.toNumber();
		if (defaultCP > max) {
			defaultCP = max;
		}

		Picker.initialize({
			:title => new WatchUi.Text({:text => label}),
			:pattern => [new NumberFactory(min, max, step, {})],
			:defaults => [defaultCP]
		});
	}
}

class NumberPickerDelegate extends WatchUi.PickerDelegate {
	var prop;

	function initialize(view as NumberPicker) {
		prop = view.prop;
	}

	function onAccept(values) {
		Application.getApp().setProperty(prop, values[0]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}

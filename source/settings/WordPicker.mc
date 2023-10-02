using Toybox.WatchUi;

class WordPicker extends WatchUi.Picker {
	var prop;
	var words;
	var factory;

	function initialize(label, p, values) {
		prop = p;
		words = values;

		factory = new WordFactory(words, {});
		var val = Application.getApp().getProperty(prop);
		var defaultWord = val == null ? 0 : val.toNumber();
		// var defaultWord = 0;

		Picker.initialize({
			:title => new WatchUi.Text({:text => label}),
			:pattern => [factory],
			:defaults => [defaultWord],
			:confirm => null
		});
	}
}

class WordPickerDelegate extends WatchUi.PickerDelegate {
	var prop;
	var factory;

	function initialize(view as WordPicker) {
		prop = view.prop;
		factory = view.factory;
	}

	function onAccept(values) {
		Application.getApp().setProperty(prop, factory.getIndex(values[0]));
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}

// TODO rewrite using default properties
class Defaults {
	static var CriticalPower = 250;
	static var WPrime = 20;
	static var RunningCP = 340;
	static var RunningWPrime = 10;

	static function getCriticalPower(val) {
		if (val == null) {
			return CriticalPower;
		} else {
			return val.toNumber();
		}
	}

	static function getWPrime(val) {
		if (val == null) {
			return WPrime;
		} else {
			return val.toNumber();
		}
	}

	static function getRunningCP(val) {
		if (val == null) {
			return RunningCP;
		} else {
			return val.toNumber();
		}
	}

	static function getRunningWPrime(val) {
		if (val == null) {
			return RunningWPrime;
		} else {
			return val.toNumber();
		}
	}
}

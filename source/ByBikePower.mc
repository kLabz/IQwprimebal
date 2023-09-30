using Toybox.AntPlus;
class MyBikePower extends AntPlus.BikePowerListener {
    var pwr = 0;

    //! Initializes class variables
    function initialize() {
        BikePowerListener.initialize();
        pwr = 0;
    }

    //! Sets the isPowerUpdated boolean to true
    //! Allows view to know an update has been received
    //! Takes a data parameter which is the CalculatedPower object that has been
    //! modified
    function onCalculatedPowerUpdate(data) {
		if (data.power == null) {
			pwr = 0;
		} else {
        	pwr = data.power;
		}
    }

    //! Sets the isDistanceUpdated boolean to true
    //! Allows view to know an update has been received
    //! Takes a data parameter which is the CalculatedWheelDistance object that
    //! has been modified
    function onCalculatedWheelDistanceUpdate(data) {
        // data.distance
    }

    //! Sets the isSpeedUpdated boolean to true
    //! Allows view to know an update has been received
    //! Takes a data parameter which is the CalculatedWheelSpeed object that has
    //! been modified
    function onCalculatedSpeedUpdate(data) {
        // data.wheelSpeed
    }
}

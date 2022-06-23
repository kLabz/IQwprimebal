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

using Toybox.Application as App;

class WPRIMEBALApp extends App.AppBase {
	
    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new WPRIMEBALView() ];
    }

}

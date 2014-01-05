package ;

import flash.Vector;
import haxe.Timer;

using haxe.macro.MacroUtils;
/**
 * ...
 * @author qw01_01
 */
	
class Main {
		
	static function main() 
	{
		var max = 3000000;
		
		var time = Timer.stamp();
		var i = max;
		while (i-->0) {
			var t = Vector.ofArray([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
		}
		trace(Timer.stamp() - time);
		//----------------------------------------
		time = Timer.stamp();
		i = max;
		while (i-->0) {
			var t = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5].toVector();
		}
		trace(Timer.stamp() - time);
		//----------------------------------------
		time = Timer.stamp();
		i = max;
		while (i-->0) {
			var t = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
		}
		trace(Timer.stamp() - time);
	}
}	
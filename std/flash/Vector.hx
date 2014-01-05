/*
 * Copyright (C)2005-2012 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package flash;

/**
	The Vector class is very similar to Array but is only supported by the Flash Player 10+
**/
@:require(flash10) extern class Vector<T> implements ArrayAccess<T> {

	var length : Int;
	var fixed : Bool;

	function new( ?length : UInt, ?fixed : Bool ) : Void;
	function concat( ?a : Vector<T> ) : Vector<T>;
	function join( sep : String ) : String;
	function pop() : Null<T>;
	function push(x : T, ?x1:T, ?x2:T, ?x3:T, ?x4:T, ?x5:T, ?x6:T, ?x7:T, ?x8:T, ?x9:T, ?x10:T, 
					?x11:T, ?x12:T, ?x13:T, ?x14:T, ?x15:T, ?x16:T, ?x17:T, ?x18:T, ?x19:T, ?x20:T,
					?x21:T, ?x22:T, ?x23:T, ?x24:T, ?x25:T, ?x26:T, ?x27:T, ?x28:T, ?x29:T, ?x30:T,
					?x31:T, ?x32:T, ?x33:T, ?x34:T, ?x35:T, ?x36:T, ?x37:T, ?x38:T, ?x39:T, ?x40:T,
					?x41:T, ?x42:T, ?x43:T, ?x44:T, ?x45:T, ?x46:T, ?x47:T, ?x48:T, ?x49:T, ?x50:T
				) : Int;
	function reverse() : Void;
	function shift() : Null<T>;
	function unshift( x : T ) : Void;
	function slice( ?pos : Int, ?end : Int ) : Vector<T>;
	function sort( f : T -> T -> Int ) : Void;
	function splice( pos : Int, len : Int ) : Vector<T>;
	function toString() : String;
	function indexOf( x : T, ?from : Int ) : Int;
	function lastIndexOf( x : T, ?from : Int ) : Int;

	public inline static function ofArray<T>( v : Array<T> ) : Vector<T> {
		return untyped __vector__(v);
	}

	public inline static function convert<T,U>( v : Vector<T> ) : Vector<U> {
		return untyped __vector__(v);
	}
}

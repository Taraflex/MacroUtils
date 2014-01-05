package haxe.macro;
/**
 * ...
 * @author qw01_01
 */
 
class MacroUtils
{	
	macro public static function toVector(array):haxe.macro.Expr {
		
		var s:String = (haxe.macro.Context.typeof(array).getParameters()[1][0]) + "";

		s = s.split('(')[1];

		s = s.split(',')[0];

		var p = haxe.macro.Context.currentPos();
			
		return { expr : EBlock([ { expr : EVars([ { expr : { expr : ENew( { name : 'Vector', pack : [], params : [TPType(TPath( 
		{ name : s, pack : [], params : [] }
		))] }, []), pos : p }, name : 't', type : null } ]), pos : p }, { expr : ECall( { expr : EField( { expr : EConst(CIdent('t')), pos : p }, 'push'), pos : p },
			
		array.expr.getParameters()[0]
			
		), pos : p },{ expr : EConst(CIdent('t')), pos : p }]), pos : p }
	}
}
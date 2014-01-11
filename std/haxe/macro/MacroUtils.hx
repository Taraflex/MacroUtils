package haxe.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
/**
 * ...
 * @author qw01_01
 */
 
class MacroUtils
{	
	macro public static function toVector(array,?type):haxe.macro.Expr {
		var s:String = (type.expr.getParameters()[0] + '').split('CIdent(')[1].split(')')[0];
		if (s == 'null') { 
			s = (haxe.macro.Context.typeof(array).getParameters()[1][0]) + "";
			s = s.split('(')[1];
			s = s.split(',')[0];
		}
		var p = haxe.macro.Context.currentPos();
			
		return { expr : EBlock([ { expr : EVars([ { expr : { expr : ENew( { name : 'Vector', pack : [], params : [TPType(TPath( 
		{ name : s, pack : [], params : [] }
		))] }, []), pos : p }, name : 't', type : null } ]), pos : p }, { expr : ECall( { expr : EField( { expr : EConst(CIdent('t')), pos : p }, 'push'), pos : p },
			
		array.expr.getParameters()[0]
			
		), pos : p },{ expr : EConst(CIdent('t')), pos : p }]), pos : p }
	}
	
	macro public static function autoConstructor():Array<Field>{
		var res = Context.getBuildFields();
		var p = Context.currentPos();
		
		var args:Array<FunctionArg> = [];
		var funblock:Array<Expr> = [];
		for (e in res) {
			if (e.name == 'new')
				e.name = '__new__';
			else	
				switch(e.kind) {
					case FVar(t, v):
						if (e.access.length == 0) {
							e.access.push(APublic);
						}
						if (Lambda.indexOf(e.access, AStatic) < 0) { 
							args.push( { name:e.name, type:t, opt:false, value:v } );
							funblock.push( { expr : EBinop(OpAssign, { expr : EField( { expr : EConst(CIdent('this')), pos :p }, e.name), pos :p }, { expr : EConst(CIdent(e.name)), pos :p } ), pos :p } );
							if (t != null) { 
								e.kind = FVar(t, null);
								var i = Lambda.indexOf(res, e);
								res[i] = e;
							}
						}
					default: 
						continue;
				}
		}
		res.push({ 
			kind : FFun( { args : args, expr : { expr : EBlock(funblock), pos : p }, params : [], ret : null } ), 
			meta : [],
			name : 'new',
			doc : null,
			pos : p ,
			access : [APublic]
		});
		return res;
	}
}
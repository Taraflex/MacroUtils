package haxe.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
/**
 * ...
 * @author qw01_01
 */
 
class MacroUtils
{	
	macro public static function csLambda():Array<Field> {
		var fields = Context.getBuildFields ();
		for (field in fields) {
			switch (field.kind) {
				case FVar (t,e): d (e);
				case FFun (f): d (f.expr);
				case FProp (get, set, t, e): d (e);
			}
		}
		return fields;
	}

	#if macro
	static function d (E:Expr,isPrevArray:Bool = false):Int {
		if (E == null) return null;
		
		var hasReturn = 0;
		
		switch (E.expr) {
			case EArray (e1,e2): hasReturn += d (e1) + d (e2);
			case EBinop (op, e1, e2): 
				if (op == OpArrow && !isPrevArray) {
					checkLambda(e1, e2, E);
				}else {
					hasReturn += d(e1) + d(e2);
				}
			case EField (e,field): hasReturn += d (e);
			case EParenthesis (e): hasReturn += d (e);
			case EObjectDecl (fields): for (f in fields) hasReturn += d (f.expr);
			case EArrayDecl (values): for (v in values) hasReturn += d (v,true);
			case ECall (e, params): hasReturn += d (e); for (p in params) hasReturn += d (p);
			case ENew (t, params): for (p in params) hasReturn += d (p);
			case EUnop (op, postFix, e): hasReturn += d (e);
			case EVars (vars): for (v in vars) hasReturn += d (v.expr);
			case EFunction (name, f): hasReturn += d (f.expr);
			case EBlock (exprs): for (e in exprs) hasReturn += d (e);
			case EFor (it, expr): hasReturn += d (it) + d (expr);
			case EIn (e1, e2): hasReturn += d (e1) + d (e2);
			case EIf (econd, eif, eelse): hasReturn += d (econd) + d (eif) + d (eelse);
			case EWhile (econd, e, normalWhile): hasReturn += d (econd) + d (e);
			case ESwitch (e, cases, edef): 
				hasReturn += d (e);
				for (c in cases) {
					for (v in c.values) hasReturn += d (v);
					hasReturn += d (c.expr);
				}
				hasReturn += d (edef);
			case ETry (e, catches): hasReturn += d (e); for (c in catches) hasReturn += d (c.expr);
			case EReturn (e): d (e); hasReturn = 1;
			case EUntyped (e), EThrow (e): hasReturn += d (e);
			case ECast (e, t): hasReturn += d (e);
			case EDisplay (e, isCall): hasReturn += d (e);
			case EDisplayNew (t):
			case ETernary (econd, eif, eelse): hasReturn += d (econd) + d (eif) + d (eelse);
			case ECheckType (e, t): hasReturn += d (e);
			default:
		}
		
		return hasReturn;
	}

	static function checkLambda(left:Expr, right:Expr,target:Expr){
		var args = new Array<FunctionArg>();
		switch(left.expr) {
			case EArrayDecl(values): 
				for (v in values) {
					switch(v.expr) {
						case EConst(c):
							args.push( { name : getConstName(c), opt : false, type : null } );
						case EBinop (op, e1, e2): 
							var name = getExprName(e1.expr);
							switch(op) {
								case OpArrow:
									var typename = getExprName(e2.expr);
									args.push( { name : name, opt : false, type : TPath( { name : typename, pack : [], params : [] } ) } );
								case OpAssign:
									args.push( { name : name, opt : false, type : null, value:e2 } );
								default:
									Context.error('Invalid argument $v.expr', Context.currentPos());
							}
						default: Context.error('Invalid argument $v.expr', Context.currentPos());
					}
				}
			case EConst(c):
				args.push( { name : getConstName(c), opt : false, type : null } );
			default:return;
		}
		
		var hasReturn = d(right) > 0;
		var isBlock = false;
		var retExpr:ExprDef;
		
		switch(right.expr) {
			case EBlock(vls): retExpr = right.expr; isBlock = true;
			default:retExpr = EReturn (right);
		}
	
		target.expr = EFunction (null, {
			args:args,
			ret: (!isBlock || hasReturn) ? null : TPath( { name : 'Void', pack : [], params : [] } ),
			expr:{expr:retExpr, pos:Context.currentPos ()},
			params:[]
		});
	}
	
	static function getConstName(e:Constant):String {
		switch(e) {
			case CIdent(name): return name;
			default: Context.error('Invalid argument $e', Context.currentPos());
		}
		return '';
	}
	
	static function getExprName(e:ExprDef):String {
		switch(e) {
			case EConst(c):return getConstName(c);
			default: Context.error('Invalid argument $e', Context.currentPos());
		}	
		return '';
	}
	
	#end
	//-------------------------------------------------------
	
	macro public static function createSignals():Array<Field>{
		var res = Context.getBuildFields();
		var p = Context.currentPos();
	
		for (e in res) {
			switch(e.kind) {
				case FVar(t, v):
					for (o in e.meta)
						if (o.name == 'change') {
							e.kind = FProp('default', 'set', t, v);
							e.access = [APublic];
							e.meta = [];
							
							var fun =  { 
								kind : FFun( { 
									args : [ { name : 'v', type : null, opt : false, value : null } ], 
									expr : { expr : EBlock([ { expr : EBinop(OpAssign, { expr : EConst(CIdent(e.name)), pos : p }, { expr : EConst(CIdent('v')), pos : p } ), pos : p }, { expr : EBinop(OpAssign, { expr : o.params[0].expr, pos : p }, { expr : EConst(CIdent('true')), pos : p } ), pos : p }, { expr : EReturn( { expr : EConst(CIdent('v')), pos : p } ), pos : p } ]), pos : p }, params : [], ret : null } ),
								meta : [],
								name : 'set_'+e.name,
								doc : null, 
								pos : p, 
								access : [AInline] 
							}
							res.push(fun);
							break;
						}
				default: 
					continue;
			}
		}
		return res;
	}
	
	macro public static function toVector(array, ?type):Expr {
		var s:String = getConstName(type.expr.getParameters()[0]);
		if (s == 'null') { 
			s = (Context.typeof(array).getParameters()[1][0]) + "";
			s = s.split('(')[1];
			s = s.split(',')[0];
		}
		var p = Context.currentPos();
			
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
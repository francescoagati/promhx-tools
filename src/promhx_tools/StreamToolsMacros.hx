package promhx_tools;
import haxe.macro.Expr;

using haxe.macro.ComplexTypeTools;
using haxe.macro.MacroStringTools;
using haxe.macro.ExprTools;

class StreamToolsMacro {

  inline static function set_type(complex:haxe.macro.Expr.ComplexType,tp:String) {
    switch(complex) {
    case TPath(data): data.params = [TPType(TPath({ name : tp, pack : [], params : [] }))];
    case _:null;
    }
  }

  static function get_path(complex:haxe.macro.Expr.ComplexType) {
    return switch(complex) {
      case TPath(data): return data;
      case _:null;
    };
  }



  public macro static function getADeferredStream<T>(cls:ExprOf<Class<promhx_tools.StreamTools>>,tp:ExprOf<Class<T>>) {

    var abstract_deferred = 'promhx_tools.ADeferredStream'.toComplex();
    var deferred_stream = 'promhx.deferred.DeferredStream'.toComplex();


    set_type(abstract_deferred,tp.toString());
    set_type(deferred_stream,tp.toString());

    var s = 'var x = new promhx.deferred.DeferredStream<String>()';
    var x = haxe.macro.Context.parseInlineString(s,haxe.macro.Context.currentPos());

    var path = get_path(deferred_stream);


    var expr = macro ((new $path()) : $abstract_deferred);

    //trace(complex);
    //var c= macro var x:$complex;
    //trace(complex);

    return macro  $expr;

  }

}

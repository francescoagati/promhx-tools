package promhx_tools.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.ExprTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.Tools;
using haxe.macro.MacroStringTools;
using tink.macro.Metadatas;
using tink.MacroApi;


class JQueryBinder {

  static var bind_events:Array<Field> = [];

  static inline function set_meta(field:Field,name:String,list:Array<Field>) {
    var meta = field.meta.toMap();
    if (meta.exists(name)) {
      list.push(field);
    }
  }

  inline static function process_sub_metas(field:Field) {
    var meta = field.meta.toMap();
    var name_temp = '${field.name}_temp';
    return if (meta.exists(':chain')) {
      var expr = meta.get(':chain')[0][0];
      expr.substitute({"_stream":macro $i{name_temp}});
    } else {
      macro null;
    }
  }

  inline static function process_event_stream(fields:Array<Field>) {
      return [
        for (field in fields) {
            var meta =  field.meta.toMap();
            var name = field.name;
            var params = meta.get(':event_stream')[0];
            var root = params[0];
            var selector = params[1];
            var events = params[2];
            //trace(params[0].toString());
            if (meta.exists(':chain')) {
              var chain = process_sub_metas(field);
              var name_temp = '${name}_temp';
              macro {
                var node =  untyped __js__("jQuery({0})",$root);
                var $name_temp =  promhx_tools.StreamTools.jQasEventStreamDelegate(node,$events,$selector);
                $i{name} = $chain;
              };
            } else {
              macro {
                var node =  untyped __js__("jQuery({0})",$root);
                $i{name} =  promhx_tools.StreamTools.jQasEventStreamDelegate(node,$events,$selector);
              };

            }


            //macro new js.JQuery($i{root}).delegate($i{selector},$i{events});
        }
      ];
  }

  public static macro function build():Array<Field> {
    var fields = Context.getBuildFields();

    for (field in fields) {
      set_meta(field,':event_stream',bind_events);
    }

    var exprs = process_event_stream(bind_events);

    var meta_class = macro class {
      inline function init_streams() {
        $b{exprs};
      }
    };

    fields = fields.concat(meta_class.fields);

    return fields;

  }


}

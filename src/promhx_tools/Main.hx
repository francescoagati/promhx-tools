package promhx_tools;
import promhx_tools.StreamTools;
import promhx_tools.ADeferredStream;
using promhx_tools.StreamTools;
using promhx_tools.StreamToolsMacros;
using thx.Functions;

@:build(promhx_tools.macro.JQueryBinder.build())
class View {

   var root:js.JQuery;

   @:event_stream(root,'div','click')
   @:chain(_stream.delay(2000).delay(4000).map(function(e) { return "Test"; }))
   var click:promhx.Stream<String>;

   @:event_stream(root,'div','click')
   var click_raw:promhx.Stream<Dynamic>;



   public function new() {
     root = new js.JQuery('.container');
     init_streams();
     click.delay(100);
   }

}

class Main {
  static function main() {
    var stream =new promhx.deferred.DeferredStream<String>();
    stream.boundStream.bufferWithCount(5).log('log');

    var def = StreamTools.getADeferredStream(String);
    var def2 = StreamTools.getADeferredStream(String);

    def << '1' << '2' << '3' << def2.boundStream <<  def2-- << '4' << '5';
    new View();

  }
}

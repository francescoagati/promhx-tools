package promhx_tools;
import promhx_tools.StreamTools;
import promhx_tools.ADeferredStream;
using promhx_tools.StreamTools;
using promhx_tools.StreamToolsMacros;
class Main {
  static function main() {
    var stream =new promhx.deferred.DeferredStream<String>();
    stream.boundStream.bufferWithCount(5).log('log');

    var def = StreamTools.getADeferredStream(String);
    var def2 = StreamTools.getADeferredStream(String);



    def << '1' << '2' << '3' << def2.boundStream << '4' << '5';

  }
}

package promhx_tools;
import promhx_tools.StreamTools;
using promhx_tools.StreamTools;

class Main {
  static function main() {
    var stream =new promhx.deferred.DeferredStream<String>();

    stream.boundStream.bufferWithCount(5).log('log');

  }
}

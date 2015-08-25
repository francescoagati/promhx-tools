package promhx_tools;
import tink.core.Future;

class FutureTools {

  public inline static function toFuture<T>(promise:promhx.Promise<T>):Future<T> {
    var f:FutureTrigger<T> = Future.trigger();
    promise.then(function(value:T) {
      f.trigger(value);
    });

    return f.asFuture();
  }

}

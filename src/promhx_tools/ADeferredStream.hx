package promhx_tools;
import promhx.Stream;
import promhx.deferred.DeferredStream;
using promhx_tools.StreamTools;

@:forward abstract ADeferredStream<T>(DeferredStream<T>) from DeferredStream<T> to DeferredStream<T> {
  public inline function new(df:DeferredStream<T>) this = df;

  @:op(A << B) public inline function plugStream<T>(stream:Stream<T>) {
    this.plug(stream);
    return new ADeferredStream<T>(this);
  }

  @:op(A << B) public inline function pushData<T>(data:T) {
    this.resolve(data);
    return new ADeferredStream<T>(this);
  }

}

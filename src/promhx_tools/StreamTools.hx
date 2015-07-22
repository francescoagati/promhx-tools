package promhx_tools;

#if js
	import js.JQuery;
#end
import haxe.Timer;
import promhx.deferred.DeferredStream;
import promhx.Stream;
import promhx.Thenable;
import promhx.base.AsyncBase;
using promhx_tools.StreamTools;
import thx.Dynamics;


class StreamTools {


  public inline  static  function map<A,B>(stream:Stream<A>,fn:A->B):Stream<B> {
    return stream.then(function(value) {
      return fn(value);
    });
  }

  public inline static  function doAction<T>(stream:Stream<T>,fn:T->Void):Stream<T> {
    var new_stream:DeferredStream<T> = new DeferredStream();
    stream.then(function(value) {
      fn(value);
      new_stream.resolve(value);
      return value;
    });
    return new_stream.boundStream;
  }

  public inline  static  function initValue<T>(stream:DeferredStream<T>, initValue:T) {
		stream.resolve(initValue);
		return stream;
	}

  public inline  static  function log<T>(stream:Stream<T>,?msg = ""):Stream<T>  {
    return stream.doAction(function(value) {
      trace(msg,value);
    });
  }

  public inline static   function bufferWithCount<T>(stream:Stream<T>,n:Int) {
    var acc:Array<T> = [];
    var new_stream:DeferredStream<Array<T>> = new DeferredStream();
    stream.then(function(value) {
      acc.push(value);
      if (acc.length >= n) {
        new_stream.resolve(acc);
        acc = [];
      }
    });

    return new_stream.boundStream;
  }

	#if !php
  public inline static  function bufferWithTime<T>(stream:Stream<T>,ms:Int) {
    var acc:Array<T> = [];
    var new_stream:DeferredStream<Array<T>> = new DeferredStream();

		stream.then(function(value) {
			acc.push(value);
		} );

		var timer = new haxe.Timer(ms);
		timer.run = function() {
			if (acc.length > 0) {
				new_stream.resolve(acc);
				acc = [];
			}
		}

		stream.endThen(function(value) {
			timer.stop();
		} );

    return new_stream.boundStream;
  }
  #end

  public inline static function filter<T>(stream:Stream<T>,fn:T->Bool) {

    var new_stream:DeferredStream<T> = new DeferredStream();

		stream.then(function(value) {
			if (fn(value) == true) {
				new_stream.resolve(value);
			}
		} );
    return new_stream.boundStream;
  }


  public inline static  function take<T>(stream:Stream<T>,n:Int) {
		var cnt = 0;
    var new_stream:DeferredStream<T> = new DeferredStream();

		stream.then(function(value) {
			if (cnt<=n) {
				new_stream.resolve(value);
				cnt++;
			} else {
				cnt = 0;
				stream.end();
			}
		} );
    return new_stream.boundStream;
  }

  public inline static function flatMapFunction<A, B>(x : Stream<A>, f : A -> Stream<B>):Stream<B> {
  	var new_stream:DeferredStream<B> = new DeferredStream();
    //return x.pipe(f);
    x.then(function(value) {
      f(value).then(function(v) {
        new_stream.resolve(v);
      });
    });
    return new_stream.boundStream;
  }

	public inline static function flatMapWithStream<A, B>(x : Stream<A>, f : A -> DeferredStream<B> -> Void) {
  	var new_stream:DeferredStream<B> = new DeferredStream();

    x.then(function(value:A) {
			f(value,new_stream);
    });
    return new_stream.boundStream;
  }


#if js
  @:extern
  public inline static function asEventStream<T,A>(element:js.html.Element,event:String) {
    var new_stream:DeferredStream<A> = new DeferredStream();
    element.addEventListener(event,function(e:A) {
      new_stream.resolve(e);
    });
    return new_stream.boundStream;
  }


  //public inline static function asEventStreamDelegate<T,A>(element:lib.HtmlTools.AElement,event:String,selector:String) {
  //  var new_stream:DeferredStream<A> = new DeferredStream();
  //	lib.EventDelegation.on(element,event,selector,function(e) {
  //		new_stream.resolve(e);
  //	});
  //  return new_stream.boundStream;
  //}

  public inline static function jQasEventStream(element:JQuery,event:String) {
    var new_stream:DeferredStream<Dynamic> = new DeferredStream();
    element.on(event,function(e) {
      	new_stream.resolve(e);
    });
    return new_stream.boundStream;
  }

  public inline static function jQasEventStreamDelegate(element:JQuery,event:String,selector:String) {
    var new_stream:DeferredStream<Dynamic> = new DeferredStream();
    (element:Dynamic).on(event,selector,function(e) {
      new_stream.resolve({target:untyped __js__('this'),event:e});
    });
    return new_stream.boundStream;
  }

  //static public inline function printTo(promise:promhx.Stream<String>,element:lib.HtmlTools.AElement) {
  //  return promise.then(function(html) {
  //    element ^ html;
  //    return html;
  //	});
  //}

#end


  public inline static function throttleWithCount<T>(stream:Stream<T>,count:Int) {
    var index = 0;
    return stream.filter(function(value) {
      index++;
      return index % count == 0;
    });
  }

 #if !php


 public inline static function throttle<T>(stream:Stream<T>,ms:Int)
		return stream
			.bufferWithTime(ms)
			.map(function(buffer) {
				return buffer[buffer.length - 1];
			});






 #end

 public inline static function skipDuplicates<T>(stream:Stream<T>) {
   var old_value:T = null;
	 return stream.filter(function(new_value) {
	 	 var check = Dynamics.equals(old_value, new_value);
		 old_value = new_value;
		 return check;
	 } );
 }

 #if !php
 public inline static function delay<T>(stream:Stream<T>,ms:Int) {
		var locked = false;
    var new_stream:DeferredStream<T> = new DeferredStream();

		stream.then(function(value) {
        Timer.delay(function() {
          new_stream.resolve(value);
        },ms);
		} );
    return new_stream.boundStream;
 }
 #end

	public inline static function plug<T>(dfStream:promhx.deferred.DeferredStream<T>,stream:Stream<T>) {
		stream.doAction(dfStream.resolve);
		return dfStream;
	}



}

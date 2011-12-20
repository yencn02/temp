/*
Copyright (c) 2007 Alexander MacCaw

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
  Compile using MTACS (http://www.mtasc.org/)
  mtasc -version 8 -header 1:1:1 -main -swf juggernaut.swf juggernaut.as
*/

import flash.external.ExternalInterface;
import flash.events.IOErrorEvent;

class SocketServer {
  
  static var socket : XMLSocket;
  
  static function connect(host:String, port:Number) {
	try{
		// The following line was causing crashes on Leopard
		// System.security.loadPolicyFile('xmlsocket://' + host + ':' + port);

		socket = new XMLSocket();
		socket.onData = onData;
		socket.onConnect = onConnect;
		socket.onClose = onDisconnect;
		socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
		ExternalInterface.call("juggernaut.connecting");
		socket.connect(host, port);
	} catch(e:Error) {
		ExternalInterface.call("juggernaut.exception", e.toString());
	}
  }
  
  static function disconnect(){
    socket.close();
  }
  
  static function onConnect(success:Boolean) {
    if(success){
      ExternalInterface.call("juggernaut.connected");
    } else {
      ExternalInterface.call("juggernaut.errorConnecting");
    }
  }
  
  static function sendData(data:String){
    socket.send(unescape(data));
  }
  
  static function onError(event:Object) {
	ExternalInterface.call("juggernaut.error", event.toString());
  }
  
  static function onDisconnect() {
    ExternalInterface.call("juggernaut.disconnected");
  }
  
  static function onData(data:String) {    
    ExternalInterface.call("juggernaut.receiveData", escape(data));
  }
  
  static function main() {
    ExternalInterface.addCallback("connect", null, connect);
    ExternalInterface.addCallback("sendData", null, sendData);
    ExternalInterface.addCallback("disconnect", null, disconnect);
    
    ExternalInterface.call("juggernaut.initialized");
  }
  
}


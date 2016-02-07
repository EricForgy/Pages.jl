"use strict";

var Pages = (function () {

    var sock = new WebSocket('ws://'+window.location.host);
    sock.onmessage = function( message ){
        var msg = JSON.parse(message.data);
        var type = msg.type,
            data = msg.data;
        switch(type) {
            case "script":
                eval(data);
                break
            case "say":
                console.log(data);
                break
        }
    }

    function notify(name) {
        sock.send(JSON.stringify({"name":"notify","args":name}))
    }

    // Message a specified connected browser. Note: id = 0 corresponding to the server.
    function message(id,name,args) {
        sock.send(JSON.stringify({"name":"message","args":[id,name,args]}))
    }

    function broadcast(name,args) {
        sock.send(JSON.stringify({"name":"broadcast","args":[name,args]}))
    }

    var addget = function (c, name) {
		Object.defineProperty(c, name, {
			get: function () { return eval(name); },
			enumerable: true,
			configurable: true
		});
		return c;
	};

    var c = {};
    c = addget(c, "sock");
    c = addget(c, "notify");
    c = addget(c, "message");
    c = addget(c, "broadcast");
	return c;
})();

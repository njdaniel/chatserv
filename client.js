
var socket = new WebSocket("ws://localhost:8000/");

var chatbox = document.getElementById("chatbox");
function send() {
  var text = document.getElementById("text");
  var user = document.getElementById("user");
  socket.send(JSON.stringify({user_name:user.value, user_text:text.value}));
  text.value = "";
}

socket.onmessage = function(event) {
  var msg = JSON.parse(event.data);
  chatbox.innerHTML += msg.user_name + ":" + msg.user_text + "<br/>";
}

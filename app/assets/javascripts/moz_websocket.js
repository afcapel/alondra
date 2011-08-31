/* In Firefox 6 WebSocket has been renamed to MozWebSocket */

if( window.WebSocket == null && window.MozWebSocket ){
  window.WebSocket = window.MozWebSocket;
}
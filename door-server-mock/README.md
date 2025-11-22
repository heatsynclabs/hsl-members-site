# Mock door server

Implements the HTTP server interface from `Open_Access_Control_Ethernet`

```
$ npm run typecheck
$ npm run serve
Server running at http://localhost:4444/
```

```
$ curl 'http://localhost:4444/?e=wink&l=2'
<pre>Request: {
  "params": {
    "e": "wink",
    "l": "2"
  },
  "request": {
    "type": "lockDoor",
    "door": "back"
  },
  "privateMode": {
     "enabled": true
  }
}</pre>
```

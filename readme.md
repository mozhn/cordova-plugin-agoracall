# cordova-plugin-agoracall
Cordova Plugin for Agora voice call. Video call will be added soon.

## Installation

- Add this to the 'package.json'
  - In the dependencies section:
  ```
  "me.mazlum.agoracall": "https://github.com/mozhn/cordova-plugin-agora"
  ```

  - In the cordova plugins section:
  ```
    "me.mazlum.agoracall": {}
  ```

## Usage

### Init Engine
```
cordova.plugins.AgoraCall.init(appId, eventCallback);
```

### Join Channel
```
cordova.plugins.AgoraCall.join(accessToken, channelName, uid);
```

### Leave Channel
```
cordova.plugins.AgoraCall.leave();
```

### Switch Speaker
```
cordova.plugins.AgoraCall.switchSpeaker(status);
```

### Switch Audio
```
cordova.plugins.AgoraCall.switchAudio(status);
```

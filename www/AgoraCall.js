var exec = require('cordova/exec');

exports.init = function (appId, callback) {
    exec(callback, null, 'AgoraCall', 'init', [appId]);
};

exports.join = function (accessToken, channelName, uid, success, error) {
    exec(success, error, 'AgoraCall', 'join', [
        accessToken, channelName, uid
    ]);
};

exports.leave = function (success, error) {
    exec(success, error, 'AgoraCall', 'leave');
}

exports.switchSpeaker = function (status, success, error) {
    exec(success, error, 'AgoraCall', 'switchSpeaker', [status]);
}

exports.switchAudio = function (status, success, error) {
    exec(success, error, 'AgoraCall', 'switchAudio', [status]);
}

package me.mazlum.agoracall;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.models.ChannelMediaOptions;

public class AgoraCall extends CordovaPlugin {
    private static final String LOG_TAG = "AgoraCall";
    private RtcEngine rtcEngine;
    private CallbackContext callbackContext;

    private final IRtcEngineEventHandler rtcEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onLocalUserRegistered(int uid, String userAccount) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "USER_REGISTERED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "CONNECTED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onLeaveChannel(IRtcEngineEventHandler.RtcStats stats) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "DISCONNECTED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "PARTICIPANT_CONNECTED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onUserOffline(int uid, int elapsed) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "PARTICIPANT_DISCONNECTED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onConnectionLost() {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "CONNECTION_LOST");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onWarning(int warn) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "WARNING_CODE_" + warn);
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onError(int err) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "ERROR_CODE_" + err);
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        @Override
        public void onRequestToken() {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "TOKEN_EXPIRED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }
    };

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
            this.callbackContext = callbackContext;
            this.initEngine(args.getString(0), callbackContext);
            return true;
        } else if (action.equals("join")) {
            String accessToken = args.getString(0);
            String channelName = args.getString(1);
            String uid = args.getString(2);

            this.joinChannel(accessToken, channelName, uid, callbackContext);
            return true;
        } else if (action.equals("leave")) {
            this.leaveChannel(callbackContext);
            return true;
        } else if (action.equals("switchSpeaker")) {
            Boolean value = Boolean.parseBoolean(args.getString(0));
            this.switchSpeaker(value, callbackContext);
            return true;
        } else if (action.equals("switchAudio")) {
            Boolean value = Boolean.parseBoolean(args.getString(0));
            this.switchAudio(value, callbackContext);
            return true;
        }
        return false;
    }

    private void initEngine(String appId, CallbackContext callbackContext) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    rtcEngine = RtcEngine.create(
                        cordova.getActivity().getBaseContext(), appId, rtcEventHandler
                    );

                    PluginResult result = new PluginResult(PluginResult.Status.OK, "ENGINE_CREATED");
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                } catch (Exception error) {
                    Log.e(LOG_TAG, Log.getStackTraceString(error));
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, "ENGINE_FAILED");
                    result.setKeepCallback(true);
                    callbackContext.sendPluginResult(result);
                }
            }
        });
    }

    private void joinChannel(String accessToken, String channelName, String uid, CallbackContext callbackContext) {
        if (rtcEngine == null) {
            callbackContext.error("You must first call the init method.");
            return;
        }

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                ChannelMediaOptions mediaOptions = new ChannelMediaOptions();

                mediaOptions.autoSubscribeAudio = true;
                mediaOptions.autoSubscribeVideo = false;

                try {
                    rtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_COMMUNICATION);
                    rtcEngine.joinChannelWithUserAccount(
                        accessToken, channelName, uid, mediaOptions
                    );

                    callbackContext.success("success");
                } catch (Exception error) {
                    Log.e(LOG_TAG, Log.getStackTraceString(error));
                    callbackContext.error("failure");
                }
            }
        });
    }

    private void leaveChannel(CallbackContext callbackContext) {
        if (rtcEngine == null) {
            callbackContext.error("You must first call the init method.");
            return;
        }

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    rtcEngine.leaveChannel();
                    RtcEngine.destroy();
                    rtcEngine = null;
                    callbackContext.success("success");
                } catch (Exception error) {
                    Log.e(LOG_TAG, Log.getStackTraceString(error));
                    callbackContext.error("failure");
                }
            }
        });
    }

    private void switchSpeaker(boolean status, CallbackContext callbackContext) {
        if (rtcEngine == null) {
            callbackContext.error("You must first call the init method.");
            return;
        }

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                rtcEngine.setEnableSpeakerphone(status);
                callbackContext.success("success");
            }
        });
    }

    private void switchAudio(boolean status, CallbackContext callbackContext) {
        if (rtcEngine == null) {
            callbackContext.error("You must first call the init method.");
            return;
        }

        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                rtcEngine.muteLocalAudioStream(status);
                callbackContext.success("success");
            }
        });
    }
}

package me.mazlum.agoracall;

import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import io.agora.rtc2.Constants;
import io.agora.rtc2.IRtcEngineEventHandler;
import io.agora.rtc2.RtcEngine;
import io.agora.rtc2.ChannelMediaOptions;

import io.agora.rtc2.video.VideoCanvas;
import io.agora.rtc2.video.VideoEncoderConfiguration;

public class AgoraCall extends CordovaPlugin {
    private static final String LOG_TAG = "AgoraCall";
    private RtcEngine rtcEngine;
    private CallbackContext callbackContext;

    private FrameLayout mLocalContainer;
    private RelativeLayout mRemoteContainer;
    private VideoCanvas mLocalVideo;
    private VideoCanvas mRemoteVideo;

    private ImageView mCallBtn;
    private ImageView mMuteBtn;
    private ImageView mSwitchCameraBtn;

    private boolean mMuted;
    private String channelType;
    private FakeR fakeR;

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

            if (channelType.contains("video")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        setupRemoteVideo(uid);
                    }
                });
            }
        }

        @Override
        public void onUserOffline(int uid, int elapsed) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "PARTICIPANT_DISCONNECTED");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);

            if (channelType.contains("video")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        setupRemoteVideo(uid);
                    }
                });
            }
        }

        @Override
        public void onConnectionLost() {
            PluginResult result = new PluginResult(PluginResult.Status.OK, "CONNECTION_LOST");
            result.setKeepCallback(true);
            callbackContext.sendPluginResult(result);
        }

        //@Override
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

            this.mMuted = false;

            return true;
        } else if (action.equals("join")) {
            String accessToken = args.getString(0);
            String channelName = args.getString(1);
            String uid = args.getString(2);
            this.channelType = args.getString(3);

            Log.e(LOG_TAG, "Channel Type: " + this.channelType);

            if (this.channelType.contains("video")) {
                this.initUI();
            }

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
                fakeR = new FakeR(
                    cordova.getActivity().getApplicationContext()
                );

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

    private void initUI() {
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    cordova.getActivity().setContentView(
                        fakeR.getLayout("activity_video_chat_view")
                    );

                    mLocalContainer = cordova.getActivity().findViewById(
                        fakeR.getId("local_video_view_container")
                    );
                    mRemoteContainer = cordova.getActivity().findViewById(
                        fakeR.getId("remote_video_view_container")
                    );

                    mCallBtn = cordova.getActivity().findViewById(fakeR.getId("btn_call"));
                    mMuteBtn = cordova.getActivity().findViewById(fakeR.getId("btn_mute"));
                    mSwitchCameraBtn = cordova.getActivity().findViewById(
                        fakeR.getId("btn_switch_camera")
                    );

                    mCallBtn.setOnClickListener(callClickListener());
                    mMuteBtn.setOnClickListener(muteClickListener());
                    mSwitchCameraBtn.setOnClickListener(switchVideoClickListener());
                    mLocalContainer.setOnClickListener(switchViewClickListener());
                } catch (Exception error) {
                    Log.e(LOG_TAG, Log.getStackTraceString(error));
                }
            }
        });
    }

    private View getView() {
        try {
            return (View)webView.getClass().getMethod("getView").invoke(webView);
        } catch (Exception e) {
            return (View)webView;
        }
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
                mediaOptions.autoSubscribeVideo = channelType.contains("video");

                if (channelType.contains("video")) {
                    setupVideoConfig();
                    setupLocalVideo();
                }

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
                    removeChannel();
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
                mMuted = status;
                rtcEngine.muteLocalAudioStream(status);
                callbackContext.success("success");
            }
        });
    }

    private View.OnClickListener callClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (rtcEngine != null) {
                    removeChannel();
                }
            }
        };
    }

    private View.OnClickListener muteClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMuted = !mMuted;

                rtcEngine.muteLocalAudioStream(mMuted);
                int res = mMuted ? fakeR.getDrawable("btn_mute") : fakeR.getDrawable("btn_unmute");
                mMuteBtn.setImageResource(res);
            }
        };
    }

    private View.OnClickListener switchViewClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchView(mLocalVideo);
                switchView(mRemoteVideo);
            }
        };
    }

    private View.OnClickListener switchVideoClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                rtcEngine.switchCamera();
            }
        };
    }

    private ViewGroup removeFromParent(VideoCanvas canvas) {
        if (canvas != null) {
            ViewParent parent = canvas.view.getParent();
            if (parent != null) {
                ViewGroup group = (ViewGroup) parent;
                group.removeView(canvas.view);
                return group;
            }
        }
        return null;
    }

    private void setupVideoConfig() {
        rtcEngine.enableVideo();

        rtcEngine.setVideoEncoderConfiguration(
            new VideoEncoderConfiguration(
                VideoEncoderConfiguration.VD_640x360,
                VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_30,
                VideoEncoderConfiguration.STANDARD_BITRATE,
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT
            )
        );
    }

    private void setupLocalVideo() {
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    SurfaceView view = RtcEngine.CreateRendererView(
                        cordova.getActivity().getBaseContext()
                    );
                    view.setZOrderMediaOverlay(true);
                    view.setBackgroundResource(fakeR.getDrawable("round_local_frame"));
                    mLocalContainer.addView(view);

                    mLocalVideo = new VideoCanvas(view, VideoCanvas.RENDER_MODE_HIDDEN, 0);
                    rtcEngine.setupLocalVideo(mLocalVideo);
                } catch (Exception error) {
                    Log.e(LOG_TAG, Log.getStackTraceString(error));
                }
            }
        });
    }

    private void setupRemoteVideo(int uid) {
        ViewGroup parent = mRemoteContainer;
        if (parent.indexOfChild(mLocalVideo.view) > -1) {
            parent = mLocalContainer;
        }

        if (mRemoteVideo != null) {
            return;
        }

        SurfaceView view = RtcEngine.CreateRendererView(
            cordova.getActivity().getBaseContext()
        );
        view.setZOrderMediaOverlay(parent == mLocalContainer);
        parent.addView(view);
        mRemoteVideo = new VideoCanvas(view, VideoCanvas.RENDER_MODE_HIDDEN, uid);

        rtcEngine.setupRemoteVideo(mRemoteVideo);
    }

    private void onRemoteUserLeft(int uid) {
        if (mRemoteVideo != null && mRemoteVideo.uid == uid) {
            removeFromParent(mRemoteVideo);
            mRemoteVideo = null;
        }
    }

    private void removeChannel() {
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (rtcEngine != null) {
                    if (channelType.contains("video")) {
                        removeFromParent(mLocalVideo);
                        mLocalVideo = null;
                        removeFromParent(mRemoteVideo);
                        mRemoteVideo = null;

                        cordova.getActivity().setContentView(getView());
                    }

                    rtcEngine.leaveChannel();
                    RtcEngine.destroy();
                    rtcEngine = null;
                }
            }
        });
    }

    private void switchView(VideoCanvas canvas) {
        ViewGroup parent = removeFromParent(canvas);
        if (parent == mLocalContainer) {
            if (canvas.view instanceof SurfaceView) {
                ((SurfaceView) canvas.view).setZOrderMediaOverlay(false);
            }
            mRemoteContainer.addView(canvas.view);
        } else if (parent == mRemoteContainer) {
            if (canvas.view instanceof SurfaceView) {
                ((SurfaceView) canvas.view).setZOrderMediaOverlay(true);
            }
            mLocalContainer.addView(canvas.view);
        }
    }
}

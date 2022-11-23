package com.mux.realtimevideoexample;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.mux.sdk.webrtc.spaces.LocalParticipant;
import com.mux.sdk.webrtc.spaces.MuxError;
import com.mux.sdk.webrtc.spaces.Participant;
import com.mux.sdk.webrtc.spaces.Space;
import com.mux.sdk.webrtc.spaces.SpaceConfiguration;
import com.mux.sdk.webrtc.spaces.Spaces;
import com.mux.sdk.webrtc.spaces.Track;
import com.mux.sdk.webrtc.spaces.views.TrackRendererSurfaceView;

import java.util.HashMap;

public class MainActivity extends AppCompatActivity {
    private static final String[] PERMISSIONS = new String[] {
        Manifest.permission.CAMERA,
        Manifest.permission.RECORD_AUDIO
    };

    private final Space.Listener spaceListener = new Space.Listener() {
        @Override
        public void onJoined(Space space, LocalParticipant localParticipant) {
            Toast.makeText(MainActivity.this, "Joined space "+space.getId()+" as "+localParticipant.getId(), Toast.LENGTH_SHORT).show();

            localParticipant.publish(localParticipant.getCameraTrack());
            localParticipant.publish(localParticipant.getMicrophoneTrack());
        }

        @Override
        public void onParticipantTrackSubscribed(Space space, Participant participant, Track track) {
            // We can only add video type tracks to views or we'll get an IllegalArgumentException
            if(track.trackType == Track.TrackType.Video) {
                TrackRendererSurfaceView trackRendererSurfaceView = new TrackRendererSurfaceView(MainActivity.this);
                // Evil sizing hard coding to keep things on point
                // TrackRendererSurfaceView has other layout capabilities
                trackRendererSurfaceView.setLayoutParams(new LinearLayout.LayoutParams(320, 240));

                trackRendererSurfaceView.setTrack(track);
                remoteViews.put(track, trackRendererSurfaceView);
                ((ViewGroup) findViewById(R.id.activity_main_remote_renderers)).addView(trackRendererSurfaceView);
            }
        }

        @Override
        public void onParticipantTrackUnsubscribed(Space space, Participant participant, Track track) {
            TrackRendererSurfaceView view = remoteViews.get(track);
            if(view != null) {
                ((ViewGroup) findViewById(R.id.activity_main_remote_renderers)).removeView(view);
                remoteViews.remove(view);
            }
        }

        @Override
        public void onError(Space space, MuxError muxError) {
            Toast.makeText(MainActivity.this, "Error! "+muxError.toString(), Toast.LENGTH_SHORT).show();
        }
    };

    private TrackRendererSurfaceView localRenderView;
    private Space space;
    private HashMap<Track, TrackRendererSurfaceView> remoteViews;

    private ActivityResultLauncher<String []> requestPermissionLauncher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        remoteViews = new HashMap<>();

        requestPermissionLauncher = registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), grants -> {
            if(grants.containsValue(false)) {
                askForPermissions();
            } else {
                joinSpace();
            }
        });

        askForPermissions();
    }

    private void askForPermissions() {
        if(!hasPermissions(PERMISSIONS)) {
            requestPermissionLauncher.launch(PERMISSIONS);
        } else {
            joinSpace();
        }
    }

    private boolean hasPermissions(String[] permissions) {
        for(String s: permissions) {
            if(checkSelfPermission(s) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }

        return true;
    }

    private void joinSpace() {
        if(space != null) {
            return;
        }

        final String jwt = "YOUR JWT";

        SpaceConfiguration spaceConfiguration = null;

        try {
            spaceConfiguration = SpaceConfiguration.newBuilder()
                    .setJWT(jwt)
                    .build();
        } catch (Exception e) {
            e.printStackTrace();

            Toast.makeText(MainActivity.this, "Your JWT is not valid", Toast.LENGTH_SHORT).show();

            return;
        }

        Spaces spaces = Spaces.getInstance(this);

        localRenderView = (TrackRendererSurfaceView) findViewById(R.id.activity_main_local_renderer);

        space = spaces.getSpace(spaceConfiguration);

        localRenderView.setTrack(space.getLocalParticipant().getCameraTrack());

        space.join(spaceListener);
    }

    @Override
    protected void onDestroy() {
        if (space != null) {
            space.leave(spaceListener, isChangingConfigurations());
            space = null;
        }

        super.onDestroy();
    }
}
package com.mux.screenshareexample;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.mux.sdk.webrtc.spaces.LocalParticipant;
import com.mux.sdk.webrtc.spaces.MuxError;
import com.mux.sdk.webrtc.spaces.Participant;
import com.mux.sdk.webrtc.spaces.Space;
import com.mux.sdk.webrtc.spaces.SpaceConfiguration;
import com.mux.sdk.webrtc.spaces.Spaces;
import com.mux.sdk.webrtc.spaces.Track;
import com.mux.sdk.webrtc.spaces.views.TrackRendererSurfaceView;

import java.util.HashMap;

public class MainActivity extends Activity {
    private TrackRendererSurfaceView localRenderView;
    private Spaces spaces;
    private Space space;
    private HashMap<Track, TrackRendererSurfaceView> remoteViews;

    private TextView status;
    private Button startScreenshare;
    private Button stopScreenshare;

    private final Space.Listener spaceListener = new Space.Listener() {
        @Override
        public void onJoined(Space space, LocalParticipant localParticipant) {
            Toast.makeText(MainActivity.this, "Joined space "+space.getId()+" as "+localParticipant.getId(), Toast.LENGTH_SHORT).show();
            status.setText("Joined");
            updateUI();
        }

        @Override
        public void onParticipantTrackSubscribed(Space space, Participant participant, Track track) {
            // We can only add video type tracks to views or we'll get an IllegalArgumentException
            if(track.trackType == Track.TrackType.Video) {
                TrackRendererSurfaceView trackRendererSurfaceView = new TrackRendererSurfaceView(MainActivity.this);
                // Evil sizing hard coding to keep things on point
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
        public void onParticipantTrackPublished(Space space, Participant participant, Track track) {
            updateUI();
        }

        @Override
        public void onParticipantTrackUnpublished(Space space, Participant participant, Track track) {
            updateUI();
        }

        @Override
        public void onError(Space space, MuxError muxError) {
            Toast.makeText(MainActivity.this, "Error! "+muxError.toString(), Toast.LENGTH_SHORT).show();
            updateUI();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        localRenderView = findViewById(R.id.activity_main_local_renderer);
        remoteViews = new HashMap<>();

        status = findViewById(R.id.activity_main_status);
        startScreenshare = findViewById(R.id.activity_main_start_screensharing);
        stopScreenshare = findViewById(R.id.activity_main_stop_screensharing);

        status.setText("onCreate called");
        startScreenshare.setVisibility(View.GONE);
        stopScreenshare.setVisibility(View.GONE);

        startScreenshare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(space != null) {
                    space.getLocalParticipant().publish(space.getLocalParticipant().getScreenCaptureTrack());
                    updateUI();
                }
            }
        });

        stopScreenshare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(space != null) {
                    space.getLocalParticipant().unpublish(space.getLocalParticipant().getScreenCaptureTrack());
                    updateUI();
                }
            }
        });

        // We can customize the notification the SDK displays while screen sharing
        // This serves two important purposes:
        // 1. It refers to this specific application as doing the screen sharing
        // 2. We create a PendingIntent which returns to this Activity instance when selecting the notification so the user can get
        // back to a screen where they can stop the screensharing
        NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        Notification.Builder builder = null;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    "screen_capture_channel_id",
                    "Screen Capture",
                    NotificationManager.IMPORTANCE_LOW
            );

            nm.createNotificationChannel(channel);
            builder = new Notification.Builder(this, channel.getId());
        } else {
            builder = new Notification.Builder(this);
            builder.setPriority(Notification.PRIORITY_DEFAULT);
        }

        // For this to work the launchMode of MainActivity must be set to "singleTop" in AndroidManifest.xml
        // This ensures Activity instances are unique and so the notification won't do things like launch a new activity
        // If you have more complex use cases which require things like preserving a large back stack you will need to use one of the
        // normal approaches for doing that, but it will be highly specific to your application.
        Intent intent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 1, intent, PendingIntent.FLAG_MUTABLE);

        // The setSmallIcon is necessary or the operating system will silently disregard the notification, and so the whole screen sharing request
        // setOngoing ensures the user can't remove the notification while screensharing
        builder.setContentIntent(pendingIntent)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setOngoing(true)
                .setContentTitle("Mux Spaces SDK Screen sharing example")
                .setContentText("Your screen is being shared");

        Notification notification = builder.build();

        updateUI();

        spaces = Spaces.getInstance(this);
        spaces.setScreenShareNotification(notification);
        spaces.setActivity(this);
        
        joinSpace();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        spaces.onActivityResult(requestCode, resultCode, data);
    }

    private void updateUI() {
        if(space == null) {
            status.setText("Not connected");
            startScreenshare.setVisibility(View.GONE);
            stopScreenshare.setVisibility(View.GONE);
            localRenderView.setTrack(null);
            return;
        }

        if(space.getLocalParticipant().getScreenCaptureTrack().isPublished()) {
            startScreenshare.setVisibility(View.GONE);
            stopScreenshare.setVisibility(View.VISIBLE);
            localRenderView.setTrack(space.getLocalParticipant().getScreenCaptureTrack());
        } else {
            startScreenshare.setVisibility(View.VISIBLE);
            stopScreenshare.setVisibility(View.GONE);
            localRenderView.setTrack(null);
        }
    }

    @Override
    protected void onStop() {
        if(space != null && space.getLocalParticipant().getScreenCaptureTrack().isPublished()) {
            // Don't do anything!
            // We want to keep the app running when in the background
        } else {
            if (space != null) {
                // This is so that when the screen rotates we don't disconnect and reconnect to the server
                // When the device is being rotated isChangingConfigurations will return true, and this flag
                // will ensure that the space stays connected for a short grace period (about half a second)
                // so that when the Activity requests the space with spaces.getSpace(spaceConfiguration); it
                // actually gets exactly the same instance, in the same connected state.
                space.leave(spaceListener, isChangingConfigurations());
                space = null;
            }

            if (!isChangingConfigurations()) {
                finish();
            }
        }

        super.onStop();
    }

    protected void onResume() {
        super.onResume();
        joinSpace();
        updateUI();
    }

    private void joinSpace() {
        if(space != null) {
            return;
        }

        status.setText("Joining space");

        final String jwt = "YOUR JWT";

        SpaceConfiguration spaceConfiguration = null;

        try {
            spaceConfiguration = SpaceConfiguration.newBuilder()
                    .setJWT(jwt)
                    .build();
        } catch (Exception e) {
            status.setText("Error with configuration: "+e.getMessage());
            e.printStackTrace();
            return;
        }

        space = spaces.getSpace(spaceConfiguration);

        space.join(spaceListener);
    }
}
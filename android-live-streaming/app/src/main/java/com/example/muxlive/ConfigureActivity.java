package com.example.muxlive;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

public class ConfigureActivity extends AppCompatActivity {

    private static final String TAG = "MuxLive";
    private BroadcastActivity.Preset preset = BroadcastActivity.Preset.hd_720p_30fps_3mbps;

    // UI Element references
    private EditText streamKeyField;

    // If you're testing in a tight loop, you won't want to paste a stream key each time.
    // Instead, set a static stream key below.
    private static final String defaultStreamKey = "";

    // Permissions required to access the camera, microphone, and storage
    private final String[] PERMISSIONS = {
            Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_configure);
        getSupportActionBar().setTitle("Configure RTMP Stream Key");
        streamKeyField = (EditText) findViewById(R.id.streamKeyField);

        if (!hasPermissions(this, PERMISSIONS)) {
            Log.i(TAG, "Requesting Permissions");
            ActivityCompat.requestPermissions(this, PERMISSIONS, 1);
        }
    }

    public void changeProfile(View view) {
        Log.i(TAG, "Changing Profile");
        switch (view.getId()) {
            case R.id.p360p:
                preset = BroadcastActivity.Preset.sd_360p_30fps_1mbps;
                break;
            case  R.id.p540p:
                preset = BroadcastActivity.Preset.sd_540p_30fps_2mbps;
                break;
            case  R.id.p720p:
                preset = BroadcastActivity.Preset.hd_720p_30fps_3mbps;
                break;
            case  R.id.p1080p:
                preset = BroadcastActivity.Preset.hd_1080p_30fps_5mbps;
                break;
        }
    }

    public void startCamera(View view) {
        Log.i(TAG, "Button tapped");

        if (hasPermissions(this, PERMISSIONS)){

            String streamKey = streamKeyField.getText().toString();

            // Use the hardwired default stream key if it exists, and there's nothing in the text box
            if (streamKey.isEmpty() && !defaultStreamKey.isEmpty()) {
                streamKey = defaultStreamKey;
            }

            if (streamKey.isEmpty()) {
                Toast.makeText(ConfigureActivity.this, "Enter a Stream key, or set a default in code.", Toast.LENGTH_SHORT).show();
            }
            else {
                Intent intent = new Intent(ConfigureActivity.this, BroadcastActivity.class);
                intent.putExtra(BroadcastActivity.intentExtraStreamKey, streamKey);
                intent.putExtra(BroadcastActivity.intentExtraPreset, preset);
                startActivity(intent);
            }

        } else {
            Log.i(TAG, "Requesting Permissions");
            ActivityCompat.requestPermissions(this, PERMISSIONS, 1);
            // It would be nice if we could immediately move to the configure activity when the
            // permissions changed, but this seems to be hard. This'll do for now.
        }
    }

    private boolean hasPermissions(Context context, String... permissions) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission)
                        != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }
}

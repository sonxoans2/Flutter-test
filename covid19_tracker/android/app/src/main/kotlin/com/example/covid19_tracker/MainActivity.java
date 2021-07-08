package com.example.covid19_tracker;

import android.os.Bundle;
import android.view.WindowManager;

import io.flutter.app.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
        super.onCreate(savedInstanceState);
    }
}

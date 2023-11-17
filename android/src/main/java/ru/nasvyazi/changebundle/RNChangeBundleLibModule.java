package ru.nasvyazi.changebundle;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.facebook.react.bridge.WritableNativeArray;
import com.jakewharton.processphoenix.ProcessPhoenix;
import com.facebook.react.module.annotations.ReactModule;

import org.json.JSONException;
import org.json.JSONObject;

@ReactModule(name = "RNChangeBundleLib")
public class RNChangeBundleLibModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;

    @SuppressLint("RestrictedApi")
    public RNChangeBundleLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNChangeBundleLib";
    }

    @ReactMethod
    public void addBundle(String bundleId, String bundlePath, String assetsPath, Promise promise) {
        try {
            RNChangeBundleLib.addBundle(this.reactContext, bundleId, bundlePath, assetsPath);
            promise.resolve("Added");
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void deleteBundle(String bundleId, Promise promise) {
        try {
            RNChangeBundleLib.deleteBundle(this.reactContext, bundleId);
            promise.resolve("Deleted");
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void getBundles(Promise promise) {
        try {
            Set<String> versions = RNChangeBundleLib.getBundles(this.reactContext);

            List<String> list =  new ArrayList<>();

            list.addAll(versions);

            WritableNativeArray array = Arguments.makeNativeArray((List)list);
            promise.resolve(array);


        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void getActiveBundle(Promise promise) {
        try {
            String activeBundle = RNChangeBundleLib.getActiveBundle(this.reactContext);
            promise.resolve(activeBundle);
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void activateBundle(String bundleId, Promise promise) {
        try {
            RNChangeBundleLib.activateBundle(this.reactContext, bundleId);
            promise.resolve("Activated");
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void notifyIfUpdateApplies(Promise promise) {
        try {
            RNChangeBundleLib.notifyIfUpdateApplies(this.reactContext);
            promise.resolve("Notified");
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void reload(Promise promise) {
        try {
            RNChangeBundleLib.reload(this.reactContext);
            promise.resolve("Reloaded");
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }

    @ReactMethod
    public void getBuildId(Promise promise) {
        try {
            String buildId = RNChangeBundleLib.getBuildId(this.reactContext);
            promise.resolve(buildId);
        }catch(Exception err){
            promise.reject("RNChangeBundleModule", err.getLocalizedMessage());
        }
    }
}























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
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import com.jakewharton.processphoenix.ProcessPhoenix;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = "RNChangeBundleLib")
public class RNChangeBundleLibModule extends ReactContextBaseJavaModule {

    private static final String REACT_APPLICATION_CLASS_NAME = "com.facebook.react.ReactApplication";
    private static final String REACT_NATIVE_HOST_CLASS_NAME = "com.facebook.react.ReactNativeHost";

    private LifecycleEventListener mLifecycleEventListener = null;

    private final ReactApplicationContext reactContext;
    private final SharedPreferences bundlePrefs;
    private final SharedPreferences extraPrefs;

    public static String launchResolveBundlePath(Context ctx) {
        SharedPreferences bundlePrefs = ctx.getSharedPreferences("_bundles", Context.MODE_PRIVATE);
        SharedPreferences extraPrefs = ctx.getSharedPreferences("_extra", Context.MODE_PRIVATE);

        String activeBundle = extraPrefs.getString("activeBundle", null);
        if (activeBundle == null) {
            return null;
        }
        return bundlePrefs.getString(activeBundle, null);
    }

    @SuppressLint("RestrictedApi")
    public RNChangeBundleLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.bundlePrefs = reactContext.getSharedPreferences("_bundles", Context.MODE_PRIVATE);
        this.extraPrefs = reactContext.getSharedPreferences("_extra", Context.MODE_PRIVATE);
    }



    @Override
    public String getName() {
        return "RNChangeBundleLib";
    }

    @ReactMethod
    public void setActiveBundle(String bundleId) {
        SharedPreferences.Editor editor = this.extraPrefs.edit();
        editor.putString("activeBundle", bundleId);
        editor.commit();
    }

    @ReactMethod
    public void registerBundle(String bundleId, String relativePath) {
        File absolutePath = new File(reactContext.getFilesDir(), relativePath);
        Log.i("RNChangeBundleLib", absolutePath.getAbsolutePath());

        SharedPreferences.Editor editor = this.bundlePrefs.edit();
        editor.putString(bundleId, absolutePath.getAbsolutePath());
        editor.commit();
    }

    @ReactMethod
    public void unregisterBundle(String bundleId) {
        SharedPreferences.Editor editor = this.bundlePrefs.edit();
        editor.remove(bundleId);
        editor.commit();
    }

    @ReactMethod
    public void reloadBundle() {
        ProcessPhoenix.triggerRebirth(getReactApplicationContext());
    }

    private void loadBundleLegacy() {
        final Activity currentActivity = getCurrentActivity();
        if (currentActivity == null) {
            return;
        }

        currentActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                currentActivity.recreate();
            }
        });
    }

    private void loadBundle() {
        clearLifecycleEventListener();
        try {
            final ReactInstanceManager instanceManager = resolveInstanceManager();
            if (instanceManager == null) {
                return;
            }

            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    try {
                        instanceManager.recreateReactContextInBackground();
                    } catch (Throwable t) {
                        loadBundleLegacy();
                    }
                }
            });

        } catch (Throwable t) {
            loadBundleLegacy();
        }
    }

    private static ReactInstanceHolder mReactInstanceHolder;

    static ReactInstanceManager getReactInstanceManager() {
        if (mReactInstanceHolder == null) {
            return null;
        }
        return mReactInstanceHolder.getReactInstanceManager();
    }

    private ReactInstanceManager resolveInstanceManager() throws NoSuchFieldException, IllegalAccessException {
        ReactInstanceManager instanceManager = getReactInstanceManager();
        if (instanceManager != null) {
            return instanceManager;
        }

        final Activity currentActivity = getCurrentActivity();
        if (currentActivity == null) {
            return null;
        }

        ReactApplication reactApplication = (ReactApplication) currentActivity.getApplication();
        instanceManager = reactApplication.getReactNativeHost().getReactInstanceManager();

        return instanceManager;
    }

    private void clearLifecycleEventListener() {
        if (mLifecycleEventListener != null) {
            getReactApplicationContext().removeLifecycleEventListener(mLifecycleEventListener);
            mLifecycleEventListener = null;
        }
    }

    @ReactMethod
    public void getBundles(Promise promise) {
        WritableMap bundles = Arguments.createMap();
        for (String bundleId: bundlePrefs.getAll().keySet()) {
            String path = bundlePrefs.getString(bundleId, null);
            Uri url = Uri.fromFile(new File(path));

            bundles.putString(bundleId, url.toString());
        }

        promise.resolve(bundles);
    }

    @ReactMethod
    public void getActiveBundle(Promise promise) {
        promise.resolve(extraPrefs.getString("activeBundle", null));
    }


    public String resolveBundlePath() {
        String activeBundle = extraPrefs.getString("activeBundle", null);
        if (activeBundle == null) {
            return null;
        }
        return bundlePrefs.getString(activeBundle, null);
    }


}























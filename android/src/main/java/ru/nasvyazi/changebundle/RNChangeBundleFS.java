package ru.nasvyazi.changebundle;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashSet;

public class RNChangeBundleFS {
    static String bundlesFolderName = "bundles";
    static String assetsFolderName = "assets";
    static String bundleFileName = "index.android.bundle";
    static String storeFileName = "_RNChangeBundle";
    static String nameExistsChecker = "existsChecker";
    static String nameBundleList = "bundleList";
    static String activeBundleName = "activeBundle";
    static String nameWaitingReactStart = "waitReactStart";
    static String nameNativeBuildVersion = "nativeBuildVersion";
    static String nameShouldDropActiveVersion = "shouldDropActiveVersion";
    static String nameFileSize = "fileSize";
    static String nameModificationDate = "modificationDate";

    public static String getDocumentDir(Context context){
        return context.getFilesDir().getAbsolutePath();
    }


    public static String getFolderForBundleId(Context context, String bundleId){
        File bundlesFolder = new File(context.getFilesDir(), bundlesFolderName);
        File absolutePath = new File(bundlesFolder, bundleId);
        return absolutePath.getAbsolutePath();
    }

    public static String getBundleFileNameForBundleId(Context context, String bundleId){
        File bundlesFolder = new File(context.getFilesDir(), bundlesFolderName);
        File bundleFolder = new File(bundlesFolder, bundleId);
        File absolutePath = new File(bundleFolder, bundleFileName);
        return absolutePath.getAbsolutePath();
    }

    public static String getAssetsFolderNameForBundleId(Context context, String bundleId){
        File bundlesFolder = new File(context.getFilesDir(), bundlesFolderName);
        File bundleFolder = new File(bundlesFolder, bundleId);
        File absolutePath = new File(bundleFolder, assetsFolderName);
        return absolutePath.getAbsolutePath();
    }

    public static void commitOnPreferences(Context context, IRNChangeBundleRunOnPref actions) {
        SharedPreferences prefs = context.getSharedPreferences(storeFileName, Context.MODE_PRIVATE);

        SharedPreferences.Editor editor = prefs.edit();
        actions.runOnPref(editor);
        editor.commit();
    }

    public static SharedPreferences getPreferences(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(storeFileName, Context.MODE_PRIVATE);

        if (prefs.contains(nameExistsChecker)) {
            return prefs;
        } else {
            return RNChangeBundleFS.createEmptyStore(context);
        }
    }

    public static SharedPreferences createEmptyStore(Context context) {
        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            editor.putBoolean(nameExistsChecker, true);
            editor.putStringSet(nameBundleList, new HashSet<String>());
            editor.putString(activeBundleName, "");
            editor.putString(nameNativeBuildVersion, "");
            editor.putBoolean(nameWaitingReactStart, false);
            editor.putBoolean(nameShouldDropActiveVersion, false);
        });

        SharedPreferences prefs = context.getSharedPreferences(storeFileName, Context.MODE_PRIVATE);

        return prefs;
    }

    public static boolean exists(String path) {
        return (new File(path)).exists();
    }

    public static boolean createFolder(String path) {
        return (new File(path)).mkdirs();
    }

    public static boolean deleteDirectory(File path) {
        if(path.exists()) {
            File[] files = path.listFiles();
            for(int i=0; i<files.length; i++) {
                if(files[i].isDirectory()) {
                    deleteDirectory(files[i]);
                }
                else {
                    files[i].delete();
                }
            }
        }
        return(path.delete());
    }

    public static boolean remove(String path) {
        File file = new File(path);
        if (file.isDirectory()){
            return RNChangeBundleFS.deleteDirectory(file);
        } else {
            return file.delete();
        }
    }

    public static void moveWithOverride(String from, String to) {
        File fromFile = new File(from);
        File toFile = new File(to);

        if (toFile.exists()){
            toFile.delete();
        }

        fromFile.renameTo(toFile);
    }

    public static void extractAssets(Context context, String path, String bundleId) {
        File assetsFolder = new File(path);
        File[] files = assetsFolder.listFiles();
        for(int i=0; i<files.length; i++) {
            if(files[i].isDirectory()) {
                File dest = new File(RNChangeBundleFS.getFolderForBundleId(context, bundleId), files[i].getName());
                files[i].renameTo(dest);
            }
        }
    }

    public static void saveFileInfo(Context context, String path) {
        File file = new File(path);
        String fileSize = String.valueOf(file.length()/1024);
        String lastModified = String.valueOf(file.lastModified());

        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            editor.putString(nameFileSize, fileSize);
            editor.putString(nameModificationDate, lastModified);
        });
    }

    public static boolean verifyFileInfo(Context context, String path) {
        File file = new File(path);
        String fileSize = String.valueOf(file.length()/1024);
        String lastModified = String.valueOf(file.lastModified());

        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);

        String storedFileSize = prefs.getString(nameFileSize, null);
        String storedLastModified = prefs.getString(nameModificationDate, null);

        boolean isFileSizeEquals = storedFileSize.equals(fileSize);
        boolean isModifiedDateEquals = storedLastModified.equals(lastModified);

        return isFileSizeEquals && isModifiedDateEquals;
    }
}

package ru.nasvyazi.changebundle;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.jakewharton.processphoenix.ProcessPhoenix;

import java.util.HashSet;
import java.util.Set;

public class RNChangeBundleLib {
    static String nameBundleList = "bundleList";
    static String activeBundleName = "activeBundle";
    static String nameWaitingReactStart = "waitReactStart";
    static String nameNativeBuildVersion = "nativeBuildVersion";
    static String nameShouldDropActiveVersion = "shouldDropActiveVersion";

    public static String getBundleURL(Context context) {
        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        String activeBundle = prefs.getString(activeBundleName, "");
        String nativeBuildVersion = prefs.getString(nameNativeBuildVersion, "");
        boolean waitReactStart = prefs.getBoolean(nameWaitingReactStart, false);

        // Если стоит дефолтный запуск
        if (activeBundle.equals("")){

            return null;
        } else {

            //Если прошло нативное обновление или не указано
            if (nativeBuildVersion.equals("") || nativeBuildVersion.equals(RNChangeBundleLib.getBuildId(context))){
                // Если нативного обновления не было
                // Если стоит запуск кастомного бандла

                String path = RNChangeBundleFS.getBundleFileNameForBundleId(context, activeBundle);

                // Проверка на прошлый запуск реакта
                // if (waitReactStart){
                // Временное решение
                if (false){
                    // Если прошлый раз реакт не стартанул
                    RNChangeBundleFS.commitOnPreferences(context, editor -> {
                        editor.putBoolean(nameWaitingReactStart, false);
                        editor.putBoolean(nameShouldDropActiveVersion, true);
                    });

                    return null;
                } else {

                    // Если прошлый раз реакт стартанул
                    boolean isFileExists = RNChangeBundleFS.exists(path);
                    // Проверка на наличие этого кастомного файла
                    if (isFileExists){

                        boolean isFileNotChanged = RNChangeBundleFS.verifyFileInfo(context, path);

                        if (isFileNotChanged){

                            // Если файл существует и не менялся, то запускаем проверку на успешный старт реакта
                            RNChangeBundleFS.commitOnPreferences(context, editor -> {
                                editor.putBoolean(nameWaitingReactStart, true);
                            });

                            return path;
                        } else {
                            // Если файл менялся, то включим ка мы дефолт
                            RNChangeBundleFS.commitOnPreferences(context, editor -> {
                                editor.putBoolean(nameShouldDropActiveVersion, true);
                            });
                            return null;
                        }
                    } else {
                        // Если файла нет, то и кастомного реакта нет
                        RNChangeBundleFS.commitOnPreferences(context, editor -> {
                            editor.putBoolean(nameShouldDropActiveVersion, true);
                        });
                        return null;
                    }
                }
            } else {

                // Если было нативное обновление
                RNChangeBundleFS.commitOnPreferences(context, editor -> {
                    editor.putBoolean(nameShouldDropActiveVersion, true);
                });
                return null;
            }
        }
    }

    public static void addBundle(Context context, String bundleId, String bundlePath, String assetsPath) {
        String folderPath = RNChangeBundleFS.getFolderForBundleId(context, bundleId);
        boolean isFolderExists = RNChangeBundleFS.exists(folderPath);
        if (!isFolderExists){
            RNChangeBundleFS.createFolder(folderPath);
        }

        RNChangeBundleFS.moveWithOverride(bundlePath, RNChangeBundleFS.getBundleFileNameForBundleId(context, bundleId));
        RNChangeBundleFS.moveWithOverride(assetsPath, RNChangeBundleFS.getAssetsFolderNameForBundleId(context, bundleId));
        RNChangeBundleFS.extractAssets(context, RNChangeBundleFS.getAssetsFolderNameForBundleId(context, bundleId), bundleId);

        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        Set<String> versions = prefs.getStringSet(nameBundleList, new HashSet<String>());
        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            versions.add(bundleId);
            editor.putStringSet(nameBundleList, versions);
        });
    }

    public static void deleteBundle(Context context, String bundleId) {
        String folderPath = RNChangeBundleFS.getFolderForBundleId(context, bundleId);
        boolean isFolderExists = RNChangeBundleFS.exists(folderPath);

        if (isFolderExists){
            RNChangeBundleFS.remove(folderPath);
        }

        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        Set<String> versions = prefs.getStringSet(nameBundleList, new HashSet<String>());
        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            versions.remove(bundleId);
            editor.putStringSet(nameBundleList, versions);
        });
    }

    public static Set<String> getBundles(Context context) {
        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        Set<String> versions = prefs.getStringSet(nameBundleList, new HashSet<String>());
        return versions;
    }

    public static String getActiveBundle(Context context) {
        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        String activeBundle = prefs.getString(activeBundleName, "");
        return activeBundle;
    }

    public static void activateBundle(Context context, String bundleId) {
        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            editor.putString(activeBundleName, bundleId);
            editor.putString(nameNativeBuildVersion, RNChangeBundleLib.getBuildId(context));
        });
        RNChangeBundleFS.saveFileInfo(context, RNChangeBundleFS.getBundleFileNameForBundleId(context, bundleId));
    }

    public static void notifyIfUpdateApplies(Context context){
        SharedPreferences prefs = RNChangeBundleFS.getPreferences(context);
        RNChangeBundleFS.commitOnPreferences(context, editor -> {
            editor.putBoolean(nameWaitingReactStart, false);
        });
        if (prefs.getBoolean(nameShouldDropActiveVersion, false)){
            RNChangeBundleLib.deleteBundle(context, prefs.getString(activeBundleName, ""));
            RNChangeBundleLib.activateBundle(context, "");

            RNChangeBundleFS.commitOnPreferences(context, editor -> {
                editor.putBoolean(nameShouldDropActiveVersion, false);
                editor.putString(nameNativeBuildVersion, "");
            });

        }
    }

    public static void reload(Context context){
        ProcessPhoenix.triggerRebirth(context);
    }

    public static String getBuildId(Context context)  {
        try {
            PackageInfo pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            return pInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            return "";
        }
    }
}

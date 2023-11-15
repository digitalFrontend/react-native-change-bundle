import { NativeModules } from 'react-native';

const { RNChangeBundleLib } = NativeModules;



let ChangeBundle = {
    // setActiveBundle: (bundleId) => {
    //     RNChangeBundleLib.setActiveBundle(bundleId)
    // },
    // registerBundle: (bundleId, relativePath) => {
    //     console.log(321)
    //     RNChangeBundleLib.registerBundle(bundleId, relativePath)
    // },
    // unregisterBundle: (bundleId) => {
    //     RNChangeBundleLib.unregisterBundle(bundleId)
    // },
    // reloadBundle: () => {
    //     RNChangeBundleLib.reloadBundle()
    // },
    // getBundles: () => {
    //     return RNChangeBundleLib.getBundles()
    // },
    // getActiveBundle: () => {
    //     return RNChangeBundleLib.getActiveBundle()
    // },

    addBundle: (bundleId, bundlePath, assetsPath) => {
        return RNChangeBundleLib.addBundle(bundleId, bundlePath, assetsPath)
    },
    deleteBundle: bundleId => {
        return RNChangeBundleLib.deleteBundle(bundleId)
    },
    getBundles: () => {
        return RNChangeBundleLib.getBundles()
    },
    getActiveBundle: () => {
        return RNChangeBundleLib.getActiveBundle()
    },
    activateBundle: (bundleId) => {
        return RNChangeBundleLib.activateBundle(bundleId)
    },
    notifyIfUpdateApplies: () => {
        return RNChangeBundleLib.notifyIfUpdateApplies()
    },
    reload: () => {
        return RNChangeBundleLib.reload()
    },
    getBuildId: () => {
        return RNChangeBundleLib.getBuildId()
    }
}


export default ChangeBundle;

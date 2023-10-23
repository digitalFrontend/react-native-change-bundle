import { NativeModules } from 'react-native';

const { RNChangeBundleLib } = NativeModules;



let ChangeBundle = {
    setActiveBundle: (bundleId) => {
        RNChangeBundleLib.setActiveBundle(bundleId)
    },
    registerBundle: (bundleId, relativePath) => {
        console.log(321)
        RNChangeBundleLib.registerBundle(bundleId, relativePath)
    },
    unregisterBundle: (bundleId) => {
        RNChangeBundleLib.unregisterBundle(bundleId)
    },
    reloadBundle: () => {
        RNChangeBundleLib.reloadBundle()
    },
    getBundles: () => {
        return RNChangeBundleLib.getBundles()
    },
    getActiveBundle: () => {
        return RNChangeBundleLib.getActiveBundle()
    }
}


export default ChangeBundle;

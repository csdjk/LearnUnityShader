#if (!UNITY_EDITOR && UNITY_ANDROID)
#define IMPORT_STATIC
#elif (!UNITY_EDITOR && UNITY_IOS)
#define IMPORT_STATIC
#else
#define IMPORT_DYNAMIC // Make this an "#else" so that, by default, the corresponding script code (below) is enabled!
#endif

using System;
using UnityEngine;
using System.Runtime.InteropServices;

using System.IO;
using System.Reflection;
using System.Collections.Generic;

namespace Substance.Platform
{
    public class NativeFunctions
    {
        // ToDo: move "build target" function out of here, they have nothing to do with "native functions".
        public enum BuildTarget
        {
            Default = 0, // or: Editor
            StandAlone,
            IOS,
            Android
        }


        public static BuildTarget GetBuildTarget()
        {
            // Use Unity's environment variables:
            BuildTarget buildTarget = BuildTarget.Default;

#if (UNITY_STANDALONE)
            buildTarget = BuildTarget.StandAlone;
#elif (UNITY_IOS)
            buildTarget = BuildTarget.IOS;
#elif (UNITY_ANDROID)
            buildTarget = BuildTarget.Android;
#endif

            return buildTarget;
        }

        public static string GetBuildTargetString()
        {
            // Use Unity's environment variables:
            string buildTarget = "UNKNOWN";

#if (UNITY_STANDALONE)
                buildTarget = "StandAlone";
#elif (UNITY_IOS)
                buildTarget = "IOS";
#elif (UNITY_ANDROID)
                buildTarget = "Android";
#endif

            return buildTarget;
        }

        public static bool IsMobile()
        {
            bool bMobile = false;

#if (UNITY_IOS || UNITY_ANDROID)
            bMobile = true;
#endif

            return bMobile;
        }

        public static TextureFormat GetMobileTextureFormat()
        {
            TextureFormat format = TextureFormat.RGBA32;

#if (UNITY_IOS)
            format = TextureFormat.PVRTC_RGBA4;
#elif (UNITY_ANDROID)
            format = TextureFormat.ETC2_RGBA8;
#else
            Debug.LogError("The current build target is NOT for a modbile platform!");
#endif
            return format;
        }

        public static void ShowBuildTargetEnvironment()
        {
#if (UNITY_EDITOR)
            Debug.Log("UNITY_EDITOR");
#endif
#if (UNITY_EDITOR_WIN)
            Debug.Log("UNITY_EDITOR_WIN");
#endif
#if (UNITY_EDITOR_OSX)
            Debug.Log("UNITY_EDITOR_OSX");
#endif
#if (UNITY_STANDALONE_OSX)
            Debug.Log("UNITY_STANDALONE_OSX");
#endif
#if (UNITY_STANDALONE_WIN)
            Debug.Log("UNITY_STANDALONE_WIN");
#endif
#if (UNITY_STANDALONE_LINUX)
            Debug.Log("UNITY_STANDALONE_LINUX");
#endif
#if (UNITY_STANDALONE)
            Debug.Log("UNITY_STANDALONE");
#endif
#if (UNITY_IOS)
            Debug.Log("UNITY_IOS");
#endif
#if (UNITY_IPHONE)
            Debug.Log("UNITY_IPHONE");
#endif
#if (ENABLE_MONO)
            Debug.Log("ENABLE_MONO");
#endif
#if (UNITY_ANDROID)
            Debug.Log("UNITY_ANDROID");
#endif
#if (ENABLE_IL2CPP)
            Debug.Log("ENABLE_IL2CPP");
#endif
        }


        // ========================================================================================

        // STATIC IMPORT UTILITIES:
        // Define DllImport's attribute value here:
#if (UNITY_IOS)
        public const string attributeValue = "__Internal";
#elif (UNITY_ANDROID)
        public const string attributeValue = "Substance.Engine.Mobile";
#else
        public const string attributeValue = "UnknownAttributeValue";
#endif

        // ======================================================================
        // DYNAMIC IMPORT UTILITIES:
#if IMPORT_DYNAMIC
        internal class DLLHelpers
        {
            [DllImport("kernel32.dll", EntryPoint = "LoadLibrary", SetLastError = true, CharSet = CharSet.Unicode)]
            protected static extern IntPtr LoadLibrary(string filename);

            [DllImport("kernel32.dll", EntryPoint = "GetProcAddress", SetLastError = true)]
            protected static extern IntPtr GetProcAddress(IntPtr hModule, string procname);

            [DllImport("kernel32.dll", SetLastError = true)]
            static extern bool FreeLibrary(IntPtr hModule);

            [DllImport("libdl.dylib")]
            protected static extern IntPtr dlopen(string filename, int flags);

            [DllImport("libdl.dylib")]
            protected static extern IntPtr dlsym(IntPtr handle, string symbol);

            [DllImport("libdl.dylib")]
            protected static extern IntPtr dlerror();

            [DllImport("libdl.dylib")]
            protected static extern int dlclose(IntPtr handle);

            internal static IntPtr DllHandle = IntPtr.Zero;
            private static object[] mParams = new object[0];

            internal static object[] GetParams(int size)
            {
                Array.Resize<object>(ref mParams, size);
                return mParams;
            }

            internal static void LoadDLL(string dataPath)
            {
                //load external library
                if (DllHandle == IntPtr.Zero)
                {
                    string LibDestination = "";

                    if (IsWindows())
                    {
                        LibDestination = Path.Combine(dataPath, "Plugins/Substance.Engine.dll");

                        DllHandle = LoadLibrary(LibDestination);
                    }
                    else if (IsMac())
                    {
                        LibDestination = Path.Combine(dataPath, "Plugins/Substance.Engine.bundle/Contents/MacOS/Substance.Engine");

                        DllHandle = dlopen(LibDestination, 3);
                    }

                    if (DllHandle == IntPtr.Zero)
                    {
                        Debug.LogError("Substance engine failed to load.");
                    }
                }
            }

            internal static void UnloadDLL()
            {
                if (DllHandle != IntPtr.Zero)
                {
                    if (IsWindows())
                    {
                        FreeLibrary(DllHandle);
                    }
                    else if (IsMac())
                    {
                        dlclose(DllHandle);
                    }

                    DllHandle = IntPtr.Zero;
                }
            }

            internal static Delegate GetFunction(string funcname, Type t)
            {
                IntPtr ptr = IntPtr.Zero;
                if (DllHandle == IntPtr.Zero)
                    return null;

                if (IsWindows())
                {
                    ptr = GetProcAddress(DllHandle, funcname);
                }
                else if (IsMac())
                {
                    ptr = dlsym(DllHandle, funcname);
                }

                if (ptr == IntPtr.Zero)
                {
                    return null;
                }

                return Marshal.GetDelegateForFunctionPointer(ptr, t);
            }

            private static bool IsWindows()
            {
                return (Application.platform == RuntimePlatform.WindowsEditor
                        || Application.platform == RuntimePlatform.WindowsPlayer);
            }

            private static bool IsMac()
            {
                return (Application.platform == RuntimePlatform.OSXEditor
                        || Application.platform == RuntimePlatform.OSXPlayer);
            }

            private static bool IsLinux()
            {
                return (Application.platform == RuntimePlatform.LinuxEditor
                        || Application.platform == RuntimePlatform.LinuxPlayer);
            }
        }
#endif // IMPORT_DYNAMIC

        // ======================================================================
#if IMPORT_DYNAMIC
        public delegate IntPtr cppHelloDelegate();
        public static IntPtr cppHello()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppHelloDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppHelloDelegate)) as cppHelloDelegate;
            return (IntPtr)function.Invoke();
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppHello();
#endif

#if IMPORT_DYNAMIC
        public delegate void cppInitSubstanceDelegate(string applicationDataPath);
        public static void cppInitSubstance(string applicationDataPath)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            DLLHelpers.LoadDLL(applicationDataPath);
            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppInitSubstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppInitSubstanceDelegate)) as cppInitSubstanceDelegate;
            function.Invoke(applicationDataPath);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppInitSubstance(string applicationDataPath);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppSetCallbacksDelegate(IntPtr log, IntPtr texture, IntPtr numerical, IntPtr graphInitialized);
        public static void cppSetCallbacks(IntPtr log, IntPtr texture, IntPtr numerical, IntPtr graphInitialized)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppSetCallbacksDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetCallbacksDelegate)) as cppSetCallbacksDelegate;
            function.Invoke(log, texture, numerical, graphInitialized);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppSetCallbacks(IntPtr log, IntPtr texture, IntPtr numerical, IntPtr graphInitialized);
#endif

#if IMPORT_DYNAMIC // not used!
        public delegate bool cppIsValidGraphHandleDelegate(IntPtr pGraphHandle);
        public static bool cppIsValidGraphHandle(IntPtr pGraphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return false;

            cppIsValidGraphHandleDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppIsValidGraphHandleDelegate)) as cppIsValidGraphHandleDelegate;
            return function.Invoke(pGraphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern bool cppIsValidGraphHandle(IntPtr pGraphHandle);
#endif

#if IMPORT_DYNAMIC // not used!
        public delegate bool cppCheckDimensionsDelegate(IntPtr pGraphHandle);
        public static bool cppCheckDimensions(IntPtr pGraphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return false;

            cppCheckDimensionsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppCheckDimensionsDelegate)) as cppCheckDimensionsDelegate;
            return function.Invoke(pGraphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern bool cppCheckDimensions(IntPtr pGraphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppApplyPresetDelegate(IntPtr graphHandle, string presetStr);
        public static void cppApplyPreset(IntPtr graphHandle, string presetStr)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppApplyPresetDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppApplyPresetDelegate)) as cppApplyPresetDelegate;
            function.Invoke(graphHandle, presetStr);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppApplyPreset(IntPtr graphHandle, string presetStr);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetPresetDelegate(IntPtr graphHandle);
        public static IntPtr cppGetPreset(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetPresetDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetPresetDelegate)) as cppGetPresetDelegate;
            return (IntPtr)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetPreset(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppListAssetsDelegate();
        public static IntPtr cppListAssets()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppListAssetsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppListAssetsDelegate)) as cppListAssetsDelegate;
            return (IntPtr)function.Invoke();
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppListAssets();
#endif

#if IMPORT_DYNAMIC
        public delegate int cppGetNumOutputsDelegate(IntPtr graphHandle);
        public static int cppGetNumOutputs(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetNumOutputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetNumOutputsDelegate)) as cppGetNumOutputsDelegate;
            return (int)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppGetNumOutputs(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppGetNumMainTexturesDelegate(IntPtr graphHandle);
        public static int cppGetNumMainTextures(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetNumMainTexturesDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetNumMainTexturesDelegate)) as cppGetNumMainTexturesDelegate;
            return (int)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppGetNumMainTextures(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetColorSpaceListDelegate(IntPtr graphHandle, int numOutputs);
        public static IntPtr cppGetColorSpaceList(IntPtr graphHandle, int numOutputs)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetColorSpaceListDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetColorSpaceListDelegate)) as cppGetColorSpaceListDelegate;
            return (IntPtr)function.Invoke(graphHandle, numOutputs);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetColorSpaceList(IntPtr graphHandle, int numOutputs);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppFreeMemoryDelegate(IntPtr pointer);
        public static void cppFreeMemory(IntPtr pointer)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppFreeMemoryDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppFreeMemoryDelegate)) as cppFreeMemoryDelegate;
            function.Invoke(pointer);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppFreeMemory(IntPtr pointer);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppSetCreateSubstanceGraphCallbackEditorPtrDelegate(IntPtr fp);
        public static void cppSetCreateSubstanceGraphCallbackEditorPtr(IntPtr fp)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppSetCreateSubstanceGraphCallbackEditorPtrDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetCreateSubstanceGraphCallbackEditorPtrDelegate)) as cppSetCreateSubstanceGraphCallbackEditorPtrDelegate;
            function.Invoke(fp);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppSetCreateSubstanceGraphCallbackEditorPtr(IntPtr fp);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetMInputsDelegate(IntPtr graphHandle, int pNumInputs);
        public static IntPtr cppGetMInputs(IntPtr graphHandle, int pNumInputs)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetMInputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetMInputsDelegate)) as cppGetMInputsDelegate;
            return (IntPtr)function.Invoke(graphHandle, pNumInputs);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetMInputs(IntPtr graphHandle, int pNumInputs);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetOutputsDescDelegate(IntPtr graphHandle, ref int pNumOutputs);
        public static IntPtr cppGetOutputsDesc(IntPtr graphHandle, ref int pNumOutputs)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetOutputsDescDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOutputsDescDelegate)) as cppGetOutputsDescDelegate;
            return (IntPtr)function.Invoke(graphHandle, ref pNumOutputs);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetOutputsDesc(IntPtr graphHandle, ref int pNumOutputs);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppShutdownSubstanceDelegate();
        public static int cppShutdownSubstance()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppShutdownSubstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppShutdownSubstanceDelegate)) as cppShutdownSubstanceDelegate;
            int result = (int)function.Invoke();

            DLLHelpers.UnloadDLL();

            return result;
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppShutdownSubstance();
#endif

#if IMPORT_DYNAMIC
        public delegate int cppRemoveAssetDelegate(string pAssetPath);
        public static int cppRemoveAsset(string pAssetPath)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppRemoveAssetDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppRemoveAssetDelegate)) as cppRemoveAssetDelegate;
            return (int)function.Invoke(pAssetPath);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppRemoveAsset(string pAssetPath);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppMoveAssetDelegate(string pFromAssetPath, string pToAssetPath);
        public static int cppMoveAsset(string pFromAssetPath, string pToAssetPath)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppMoveAssetDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppMoveAssetDelegate)) as cppMoveAssetDelegate;
            return (int)function.Invoke(pFromAssetPath, pToAssetPath);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppMoveAsset(string pFromAssetPath, string pToAssetPath);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppLoadSubstanceDelegate(string pAssetPath, IntPtr array, Int32 size,
            IntPtr assetCtx, IntPtr substanceObject,
            UInt32[] graphIndices, string[] graphPrototypeNames, string[] graphLabels,
            int[] graphFormats, int[] normalFormats, UInt32 numGraphIndices,
            int rawOverride, int projectContext);
        public static int cppLoadSubstance(string pAssetPath, IntPtr array, Int32 size, IntPtr assetCtx, IntPtr substanceObject,
                                           UInt32[] graphIndices, string[] graphPrototypeNames, string[] graphLabels,
                                           int[] graphFormats, int[] normalFormats, UInt32 numGraphIndices,
                                           int rawOverride, int projectContext)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppLoadSubstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppLoadSubstanceDelegate)) as cppLoadSubstanceDelegate;
            return (int)function.Invoke(pAssetPath, array, size, assetCtx, substanceObject,
                                        graphIndices, graphPrototypeNames, graphLabels,
                                        graphFormats, normalFormats, numGraphIndices,
                                        rawOverride, projectContext);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppLoadSubstance(string pAssetPath, IntPtr array, Int32 size, IntPtr assetCtx,
            IntPtr substanceObject, UInt32[] graphIndices, string[] graphPrototypeNames, string[] graphLabels,
            int[] graphFormats, int[] normalFormats, UInt32 numGraphIndices, int rawOverride, int projectContext);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppQueueSubstanceDelegate(IntPtr graphHandle);
        public static void cppQueueSubstance(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppQueueSubstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppQueueSubstanceDelegate)) as cppQueueSubstanceDelegate;
            function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppQueueSubstance(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate uint cppRenderSubstancesDelegate(bool bAsync, IntPtr preComputeCallback);
        public static uint cppRenderSubstances(bool bAsync, IntPtr preComputeCallback)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppRenderSubstancesDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppRenderSubstancesDelegate)) as cppRenderSubstancesDelegate;
            return (uint)function.Invoke(bAsync, preComputeCallback);
        }
#else
        [DllImport(attributeValue)]
        public static extern uint cppRenderSubstances(bool bAsync, IntPtr preComputeCallback);
#endif

#if IMPORT_DYNAMIC
        public delegate bool cppIsRendererBusyDelegate(uint runid);
        public static bool cppIsRendererBusy(uint runid)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return false;

            cppIsRendererBusyDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppIsRendererBusyDelegate)) as cppIsRendererBusyDelegate;
            return (bool)function.Invoke(runid);
        }
#else
        [DllImport(attributeValue)]
        public static extern bool cppIsRendererBusy(uint runid);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppSetDirtyOutputsDelegate(IntPtr graphHandle);
        public static void cppSetDirtyOutputs(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppSetDirtyOutputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetDirtyOutputsDelegate)) as cppSetDirtyOutputsDelegate;
            function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppSetDirtyOutputs(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppGetNumInputsDelegate(IntPtr graphHandle);
        public static int cppGetNumInputs(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetNumInputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetNumInputsDelegate)) as cppGetNumInputsDelegate;
            return (int)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppGetNumInputs(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetInput_IntsDelegate(IntPtr graphHandle, string pFieldName, int pNumInputs);
        public static IntPtr cppGetInput_Ints(IntPtr graphHandle, string pFieldName, int pNumInputs)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetInput_IntsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetInput_IntsDelegate)) as cppGetInput_IntsDelegate;
            return (IntPtr)function.Invoke(graphHandle, pFieldName, pNumInputs);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetInput_Ints(IntPtr graphHandle, string pFieldName, int pNumInputs);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetMComboBoxItemsDelegate(IntPtr graphHandle, string pIdentifier, out int pNumValues);
        public static IntPtr cppGetMComboBoxItems(IntPtr graphHandle, string pIdentifier, out int pNumValues)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
            {
                pNumValues = 0;
                return IntPtr.Zero;
            }

            cppGetMComboBoxItemsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetMComboBoxItemsDelegate)) as cppGetMComboBoxItemsDelegate;
            return (IntPtr)function.Invoke(graphHandle, pIdentifier, out pNumValues);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetMComboBoxItems(IntPtr graphHandle, string pIdentifier, out int pNumValues);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppGetInput_FloatDelegate(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues);
        public static void cppGetInput_Float(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppGetInput_FloatDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetInput_FloatDelegate)) as cppGetInput_FloatDelegate;
            function.Invoke(graphHandle, pInputName, values, numValues);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppGetInput_Float(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppSetInput_FloatDelegate(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues);
        public static int cppSetInput_Float(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return -2;

            cppSetInput_FloatDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetInput_FloatDelegate)) as cppSetInput_FloatDelegate;
            return (int)function.Invoke(graphHandle, pInputName, values, numValues);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppSetInput_Float(IntPtr graphHandle, string pInputName, float[] values, UInt32 numValues);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppGetInput_IntDelegate(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues);
        public static void cppGetInput_Int(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppGetInput_IntDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetInput_IntDelegate)) as cppGetInput_IntDelegate;
            function.Invoke(graphHandle, pInputName, values, numValues);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppGetInput_Int(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppSetInput_IntDelegate(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues);
        public static void cppSetInput_Int(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppSetInput_IntDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetInput_IntDelegate)) as cppSetInput_IntDelegate;
            function.Invoke(graphHandle, pInputName, values, numValues);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppSetInput_Int(IntPtr graphHandle, string pInputName, int[] values, UInt32 numValues);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppSetInput_StringDelegate(IntPtr graphHandle, string pInputName, string value);
        public static int cppSetInput_String(IntPtr graphHandle, string pInputName, string value)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return -2;

            cppSetInput_StringDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetInput_StringDelegate)) as cppSetInput_StringDelegate;
            return (int)function.Invoke(graphHandle, pInputName, value);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppSetInput_String(IntPtr graphHandle, string pInputName, string value);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetInput_StringDelegate(IntPtr graphHandle, string pInputName);
        public static IntPtr cppGetInput_String(IntPtr graphHandle, string pInputName)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetInput_StringDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetInput_StringDelegate)) as cppGetInput_StringDelegate;
            return (IntPtr)function.Invoke(graphHandle, pInputName);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetInput_String(IntPtr graphHandle, string pInputName);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppSetInput_TextureDelegate(IntPtr graphHandle, string pInputName, int format, int mipCount, int width, int height, IntPtr pixels);
        public static int cppSetInput_Texture(IntPtr graphHandle, string pInputName, int format, int mipCount, int width, int height, IntPtr pixels)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return -2;

            cppSetInput_TextureDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppSetInput_TextureDelegate)) as cppSetInput_TextureDelegate;
            return (int)function.Invoke(graphHandle, pInputName, format, mipCount, width, height, pixels);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppSetInput_Texture(IntPtr graphHandle, string pInputName, int format, int mipCount, int width, int height, IntPtr pixels);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppProcessQueuedOutputsDelegate();
        public static int cppProcessQueuedOutputs()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppProcessQueuedOutputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppProcessQueuedOutputsDelegate)) as cppProcessQueuedOutputsDelegate;
            return (int)function.Invoke();
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppProcessQueuedOutputs();
#endif

#if IMPORT_DYNAMIC // not used anymore
        public delegate IntPtr cppGetOutputLabelFromHashDelegate(string pAssetPath, UInt32 outputHash);
        public static IntPtr cppGetOutputLabelFromHash(string pAssetPath, UInt32 outputHash)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetOutputLabelFromHashDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOutputLabelFromHashDelegate)) as cppGetOutputLabelFromHashDelegate;
            return (IntPtr)function.Invoke(pAssetPath, outputHash);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetOutputLabelFromHash(string pAssetPath, UInt32 outputHash);
#endif

#if IMPORT_DYNAMIC // not used anymore
        public delegate IntPtr cppGetOutputIdentifierFromHashDelegate(string pAssetPath, UInt32 outputHash);
        public static IntPtr cppGetOutputIdentifierFromHash(string pAssetPath, UInt32 outputHash)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetOutputIdentifierFromHashDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOutputIdentifierFromHashDelegate)) as cppGetOutputIdentifierFromHashDelegate;
            return (IntPtr)function.Invoke(pAssetPath, outputHash);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetOutputIdentifierFromHash(string pAssetPath, UInt32 outputHash);
#endif

#if IMPORT_DYNAMIC // not used anymore
        public delegate bool cppIsImageOutputFromHashDelegate(string pAssetPath, UInt32 outputHash);
        public static bool cppIsImageOutputFromHash(string pAssetPath, UInt32 outputHash)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return false;

            cppIsImageOutputFromHashDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppIsImageOutputFromHashDelegate)) as cppIsImageOutputFromHashDelegate;
            return (bool)function.Invoke(pAssetPath, outputHash);
        }
#else
        [DllImport(attributeValue)]
        public static extern bool cppIsImageOutputFromHash(string pAssetPath, UInt32 outputHash);
#endif

#if IMPORT_DYNAMIC // not used anymore
        public delegate IntPtr cppGetOutputChannelStrFromHashDelegate(string pAssetPath, UInt32 outputHash);
        public static IntPtr cppGetOutputChannelStrFromHash(string pAssetPath, UInt32 outputHash)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetOutputChannelStrFromHashDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOutputChannelStrFromHashDelegate)) as cppGetOutputChannelStrFromHashDelegate;
            return (IntPtr)function.Invoke(pAssetPath, outputHash);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetOutputChannelStrFromHash(string pAssetPath, UInt32 outputHash);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppOnGenerateMipMapsChangedDelegate(IntPtr graphHandle, bool bGenerateMipMaps);
        public static void cppOnGenerateMipMapsChanged(IntPtr graphHandle, bool bGenerateMipMaps)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppOnGenerateMipMapsChangedDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppOnGenerateMipMapsChangedDelegate)) as cppOnGenerateMipMapsChangedDelegate;
            function.Invoke(graphHandle, bGenerateMipMaps);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppOnGenerateMipMapsChanged(IntPtr graphHandle, bool bGenerateMipMaps);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppModifyTexturePackingDelegate(IntPtr graphHandle,
                                                   string pSourceNames, int[] pSourceComponents,
                                                   string pTargetName, int[] pTargetComponents,
                                                    int pNumComponents);
        public static void cppModifyTexturePacking(IntPtr graphHandle,
                                                   string pSourceNames, int[] pSourceComponents,
                                                   string pTargetName, int[] pTargetComponents,
                                                   int pNumComponents)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppModifyTexturePackingDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppModifyTexturePackingDelegate)) as cppModifyTexturePackingDelegate;
            function.Invoke(graphHandle,
                            pSourceNames, pSourceComponents,
                            pTargetName, pTargetComponents,
                            pNumComponents);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppModifyTexturePacking(IntPtr graphHandle,
                                                   string pSourceNames, int[] pSourceComponents,
                                                   string pTargetName, int[] pTargetComponents,
                                                   int pNumComponents);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppGetTextureDimensionsDelegate(IntPtr graphHandle, out int pWidth, out int pHeight);
        public static void cppGetTextureDimensions(IntPtr graphHandle, out int pWidth, out int pHeight)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
            {
                pWidth = 256;
                pHeight = 256;
                return;
            }

            cppGetTextureDimensionsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetTextureDimensionsDelegate)) as cppGetTextureDimensionsDelegate;
            function.Invoke(graphHandle, out pWidth, out pHeight);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppGetTextureDimensions(IntPtr graphHandle, out int pWidth, out int pHeight);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppDuplicateGraphInstanceDelegate(IntPtr graphHandle);
        public static IntPtr cppDuplicateGraphInstance(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppDuplicateGraphInstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppDuplicateGraphInstanceDelegate)) as cppDuplicateGraphInstanceDelegate;
            return (IntPtr)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppDuplicateGraphInstance(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate void cppRemoveGraphInstanceDelegate(IntPtr graphHandle);
        public static void cppRemoveGraphInstance(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return;

            cppRemoveGraphInstanceDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppRemoveGraphInstanceDelegate)) as cppRemoveGraphInstanceDelegate;
            function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern void cppRemoveGraphInstance(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppListInputsDelegate(IntPtr graphHandle);
        public static int cppListInputs(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return -2;

            cppListInputsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppListInputsDelegate)) as cppListInputsDelegate;
            return (int)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppListInputs(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetChannelNamesDelegate();
        public static IntPtr cppGetChannelNames()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetChannelNamesDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetChannelNamesDelegate)) as cppGetChannelNamesDelegate;
            return (IntPtr)function.Invoke();
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetChannelNames();
#endif

#if IMPORT_DYNAMIC
        public delegate uint cppGetOutputHashDelegate(IntPtr graphHandle, int pOutputIndex);
        public static uint cppGetOutputHash(IntPtr graphHandle, int pOutputIndex)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetOutputHashDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOutputHashDelegate)) as cppGetOutputHashDelegate;
            return (uint)function.Invoke(graphHandle, pOutputIndex);
        }
#else
        [DllImport(attributeValue)]
        public static extern uint cppGetOutputHash(IntPtr graphHandle, int outputIndex);
#endif

#if IMPORT_DYNAMIC
        public delegate IntPtr cppGetEngineVersionDelegate();
        public static IntPtr cppGetEngineVersion()
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return IntPtr.Zero;

            cppGetEngineVersionDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetEngineVersionDelegate)) as cppGetEngineVersionDelegate;
            return (IntPtr)function.Invoke();
        }
#else
        [DllImport(attributeValue)]
        public static extern IntPtr cppGetEngineVersion();
#endif

#if IMPORT_DYNAMIC
        public delegate int cppGetNumberOfDuplicatedGraphsDelegate(IntPtr graphHandle);
        public static int cppGetNumberOfDuplicatedGraphs(IntPtr graphHandle)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetNumberOfDuplicatedGraphsDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetNumberOfDuplicatedGraphsDelegate)) as cppGetNumberOfDuplicatedGraphsDelegate;
            return (int)function.Invoke(graphHandle);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppGetNumberOfDuplicatedGraphs(IntPtr graphHandle);
#endif

#if IMPORT_DYNAMIC
        public delegate int cppGetOldFileIdDelegate(string pCharArray, int pTypeConstant);

        public static int cppComputeOldFileID(string pCharArray, int pTypeConstant)
        {
            string myName = System.Reflection.MethodBase.GetCurrentMethod().Name;

            if (DLLHelpers.DllHandle == IntPtr.Zero)
                return 0;

            cppGetOldFileIdDelegate function = DLLHelpers.GetFunction(
                myName, typeof(cppGetOldFileIdDelegate)) as cppGetOldFileIdDelegate;
            return (int)function.Invoke(pCharArray, pTypeConstant);
        }
#else
        [DllImport(attributeValue)]
        public static extern int cppComputeOldFileID(string pCharArray, int pTypeConstant);
#endif

    }
}
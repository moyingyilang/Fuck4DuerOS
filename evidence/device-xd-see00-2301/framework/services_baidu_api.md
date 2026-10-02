# DuerOS services.jar 非标准 API 面（Lcom/baidu/*）

共 **45** 个非标准类。数据由 `dexdump` 提取，解析脚本见 `scripts/parse_dexdump.py`。

- 类：45
- 方法：386

## `Lcom/android/server/baidu`

### `AppOpsUtils`

- 完整类名：`Lcom/android/server/baidu/AppOpsUtils`
- 方法（4）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `isAppInAppOpsWhiteList` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `isAppInCheckPackageWhiteList` | `(Landroid/content/Context;ILjava/lang/String;)Z` | PUBLIC STATIC |

### `DuerLocalServiceIntf`

- 完整类名：`Lcom/android/server/baidu/DuerLocalServiceIntf`
- 方法（4）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `openSocket` | `()Z` | PRIVATE STATIC |
  | `writeLocalCommand` | `(Ljava/nio/ByteBuffer;)Z` | PUBLIC STATIC |

### `DuerService`

- 完整类名：`Lcom/android/server/baidu/DuerService`
- 父类：`Landroid/os/baidu/IDuerService$Stub;`
- 方法（85）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Landroid/content/Context;)V` | PUBLIC CONSTRUCTOR |
  | `compressImage` | `(Landroid/graphics/Bitmap;)[B` | PRIVATE |
  | `compressScale` | `(Landroid/graphics/Bitmap;II)[B` | PRIVATE |
  | `getAppProcessControllerStatus` | `(Ljava/lang/String;)Z` | PRIVATE |
  | `getUid` | `(Ljava/lang/String;)I` | PRIVATE |
  | `initLogcatStatus` | `()V` | PRIVATE |
  | `onCameraClosed` | `(Ljava/lang/String;I)V` | PRIVATE |
  | `onCameraOpened` | `(Ljava/lang/String;I)V` | PRIVATE |
  | `onMicrophoneOff` | `(Ljava/lang/String;)V` | PRIVATE |
  | `onMicrophoneOn` | `(Ljava/lang/String;)V` | PRIVATE |
  | `setAppProcessControllerStatus` | `(Ljava/lang/String;Z)Z` | PRIVATE |
  | `signatureToHexString` | `(Landroid/content/pm/Signature;)Ljava/lang/String;` | PUBLIC STATIC |
  | `takeScreenshotInternal` | `(II)Landroid/graphics/Bitmap;` | PRIVATE |
  | `verifyCallingSignature` | `()Z` | PRIVATE |
  | `verifyMideaSignature` | `()Z` | PRIVATE |
  | `verifyRTCSignature` | `()Z` | PRIVATE |
  | `verifySignature` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PRIVATE |
  | `closeSocketToSupplicant` | `()V` | PUBLIC |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC |
  | `createSocketToSupplicant` | `()I` | PUBLIC |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableNetwork` | `(I)V` | PUBLIC |
  | `dump` | `(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;[Ljava/lang/String;)V` | PROTECTED |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC |
  | `enableSink` | `(Z)V` | PUBLIC |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC |
  | `forgetWifi` | `(I)V` | PUBLIC |
  | `freeStorage` | `(J)V` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
  | `getAppletControllerStatus` | `()Z` | PUBLIC |
  | `getBluetoothOnMesh` | `()Z` | PUBLIC |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `getDataBytes` | `(Ljava/lang/String;)J` | PUBLIC |
  | `getMicUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `getMinimumScreenBrightnessSetting` | `()I` | PUBLIC |
  | `getOemUnlockEnabled` | `()Z` | PUBLIC |
  | `getPermissionFlag` | `(Ljava/lang/String;Ljava/lang/String;)I` | PUBLIC |
  | `getScreenState` | `()I` | PUBLIC |
  | `getSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC |
  | `getTransportTypes` | `(Landroid/net/Network;)[I` | PUBLIC |
  | `getWifiVerboseLoggingLevel` | `()I` | PUBLIC |
  | `goToSleep` | `(J)V` | PUBLIC |
  | `isMinimumBrightnessMode` | `()Z` | PUBLIC |
  | `isNotificationEnabled` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isRuntimePermissionsGranted` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC |
  | `isSafeMediaVolumeEnabled` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isSinkEnabled` | `()Z` | PUBLIC |
  | `onTransact` | `(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z` | PUBLIC |
  | `readWifiPassWd` | `()Ljava/lang/String;` | PUBLIC |
  | `recvMgmtEnable` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `screenshot` | `(II)[B` | PUBLIC |
  | `sendMgmt` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `sendUibcInputEvent` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setActiveDream` | `(Landroid/content/ComponentName;)V` | PUBLIC |
  | `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | PUBLIC |
  | `setActivityStackListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC |
  | `setAppProcessControllerSwitch` | `(Z)V` | PUBLIC |
  | `setAppletControllerStatus` | `(Z)Z` | PUBLIC |
  | `setBlockingActivities` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBlockingPackages` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBluetoothOnMesh` | `(Z)V` | PUBLIC |
  | `setDebugLogStatus` | `(Z)Z` | PUBLIC |
  | `setIgnoreBatteryOptimizationStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setMinimumBrightnessValue` | `(I)V` | PUBLIC |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC |
  | `setNotificationEnableStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC |
  | `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `setRuntimePermissionsByGroup` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setSafeMediaVolumeEnabled` | `(ZLjava/lang/String;)V` | PUBLIC |
  | `setSafeMediaVolumeIndex` | `(I)V` | PUBLIC |
  | `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setZenMode` | `(Z)V` | PUBLIC |
  | `startDreaming` | `()V` | PUBLIC |
  | `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | PUBLIC |
  | `unRegisterCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `updateSystemConfig` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `waitForMgmtEvent` | `()Ljava/lang/String;` | PUBLIC |
  | `waitWifiDisplayConnection` | `(Landroid/view/Surface;)V` | PUBLIC |
  | `wipe` | `()V` | PUBLIC |

### `DuerSystemConfigManager`

- 完整类名：`Lcom/android/server/baidu/DuerSystemConfigManager`
- 方法（9）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getAppControlListFromFile` | `(Ljava/util/List;Ljava/io/File;)V` | PRIVATE |
  | `getInstance` | `()Lcom/android/server/baidu/DuerSystemConfigManager;` | PUBLIC STATIC |
  | `getSystemDir` | `()Ljava/io/File;` | PRIVATE |
  | `configInit` | `(Ljava/util/List;Ljava/util/List;)V` | PUBLIC |
  | `dump` | `(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;)V` | PUBLIC |
  | `getStructType` | `()I` | PUBLIC |
  | `getVersion` | `()I` | PUBLIC |
  | `updateDuerSystemConfigInfo` | `(IILjava/util/List;Ljava/util/List;)Z` | PUBLIC |

## `Lcom/baidu/am`

### `ActivityRedirection`

- 完整类名：`Lcom/baidu/am/ActivityRedirection`
- 方法（14）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `<init>` | `(Lcom/baidu/am/ActivityRedirection$1;)V` | SYNTHETIC CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/ActivityRedirection;` | PUBLIC STATIC |
  | `isSettingsAction` | `(Landroid/content/Intent;)Z` | PRIVATE |
  | `redirectToDefaultSettingAction` | `(Landroid/content/Intent;Lcom/baidu/am/ActivityRedirection$ActivityRedirectionResult;Landroid/content/pm/ResolveInfo;Lcom/android/server/wm/ActivityTaskSupervisor;Ljava/lang/String;ILandroid/content/Context;II)Lcom/baidu/am/ActivityRedirection$ActivityRedirectionResult;` | PRIVATE |
  | `reportStatisticEvent` | `(Landroid/content/Context;ZLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PRIVATE |
  | `getLaunchIntent` | `(Landroid/content/Context;Ljava/lang/String;)Landroid/content/Intent;` | PUBLIC |
  | `isForegroundServiceNotificationAllowed` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isSystemApp` | `(Lcom/android/server/am/ProcessRecord;)Z` | PUBLIC |
  | `performRedirect` | `(Landroid/content/Intent;Landroid/content/pm/ResolveInfo;Lcom/android/server/wm/ActivityTaskSupervisor;Ljava/lang/String;ILandroid/content/Context;II)Lcom/baidu/am/ActivityRedirection$ActivityRedirectionResult;` | PUBLIC |
  | `replacePendingIntent` | `(Landroid/content/Context;Landroid/app/Notification;Ljava/lang/String;)Z` | PUBLIC |
  | `replaceTaskAffinityIfNeeded` | `(Landroid/content/pm/ActivityInfo;Landroid/content/Intent;Landroid/content/pm/ResolveInfo;)V` | PUBLIC |
  | `shouldRedirect` | `(Landroid/content/pm/ResolveInfo;Lcom/android/server/wm/WindowProcessController;Landroid/content/Intent;)Z` | PUBLIC |

### `ActivityRedirection$1`

- 完整类名：`Lcom/baidu/am/ActivityRedirection$1`

### `ActivityRedirection$ActivityRedirectHolder`

- 完整类名：`Lcom/baidu/am/ActivityRedirection$ActivityRedirectHolder`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |

### `ActivityRedirection$ActivityRedirectionResult`

- 完整类名：`Lcom/baidu/am/ActivityRedirection$ActivityRedirectionResult`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Intent;Landroid/content/pm/ResolveInfo;)V` | CONSTRUCTOR |

### `ActivityStackMonitor`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor`
- 方法（43）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/ActivityStackMonitor;` | PUBLIC STATIC |
  | `notifyAllClients` | `(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PRIVATE |
  | `schedulePostToast` | `(Ljava/lang/String;)V` | PRIVATE |
  | `checkStartActivity` | `(Landroid/content/pm/ActivityInfo;Landroid/content/Intent;Landroid/app/IApplicationThread;)Z` | PUBLIC |
  | `checkStartActivity` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/content/Intent;Z)Z` | PUBLIC |
  | `dump` | `(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;)V` | PUBLIC |
  | `filterBlockedResolveInfo` | `(Landroid/content/Intent;ILjava/util/List;)V` | PUBLIC |
  | `filterBlockedServiceResolveInfo` | `(Landroid/content/Intent;Ljava/util/List;)V` | PUBLIC |
  | `forceStopPackage` | `(Ljava/lang/String;)V` | PUBLIC |
  | `genCrash` | `(Ljava/lang/String;)V` | PUBLIC |
  | `getAdj` | `(ILjava/lang/String;)I` | PUBLIC |
  | `getAppletControllerStatus` | `()Z` | PUBLIC |
  | `isBlockedActivity` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isBlockedPackage` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isNonBlockedApplet` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `onActivityManagerTransactExceptionLocked` | `(IIILjava/lang/RuntimeException;)V` | PUBLIC |
  | `onAddStartingWindow` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `onAddToDropBox` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onAmsWatchDogMonitor` | `()V` | PUBLIC |
  | `onAppProcessBound` | `(Lcom/android/server/am/ProcessRecord;)V` | PUBLIC |
  | `onAppProcessDied` | `(Lcom/android/server/am/ProcessRecord;)V` | PUBLIC |
  | `onDestroyActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onLaunchActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onNewIntent` | `(Landroid/content/Intent;)V` | PUBLIC |
  | `onNewIntent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onPauseActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onResumeActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onSetTaskDescription` | `(Lcom/android/server/wm/ActivityRecord;Landroid/app/ActivityManager$TaskDescription;Ljava/lang/Runnable;)V` | PUBLIC |
  | `onStopActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onSystemReady` | `()V` | PUBLIC |
  | `sendLaunchTimeoutEventLocked` | `(Lcom/android/server/wm/ActivityRecord;)V` | PUBLIC |
  | `setAppletControllerStatus` | `(Z)Z` | PUBLIC |
  | `setBlockingActivityList` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBlockingPackageList` | `(Ljava/util/List;)V` | PUBLIC |
  | `setContext` | `(Landroid/content/Context;)Lcom/baidu/am/ActivityStackMonitor;` | PUBLIC |
  | `setHandler` | `(Landroid/os/Handler;)Lcom/baidu/am/ActivityStackMonitor;` | PUBLIC |
  | `setListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC |
  | `setService` | `(Lcom/android/server/am/ActivityManagerService;)Lcom/baidu/am/ActivityStackMonitor;` | PUBLIC |
  | `setWatchDogLock` | `(Z)V` | PUBLIC |

### `ActivityStackMonitor$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/ActivityStackMonitor;Lcom/android/server/wm/ActivityRecord;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `ActivityStackMonitor$$ExternalSyntheticLambda1`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor$$ExternalSyntheticLambda1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/ActivityStackMonitor;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `ActivityStackMonitor$$ExternalSyntheticLambda2`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor$$ExternalSyntheticLambda2`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/ActivityStackMonitor;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `ActivityStackMonitor$$ExternalSyntheticLambda3`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor$$ExternalSyntheticLambda3`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `ActivityStackMonitor$$ExternalSyntheticLambda4`

- 完整类名：`Lcom/baidu/am/ActivityStackMonitor$$ExternalSyntheticLambda4`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/ActivityStackMonitor;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `accept` | `(Ljava/lang/Object;)V` | PUBLIC FINAL |

### `AppProcessController`

- 完整类名：`Lcom/baidu/am/AppProcessController`
- 方法（19）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/AppProcessController;` | PUBLIC STATIC |
  | `initBlockedHostTypes` | `()V` | PRIVATE |
  | `isActivityHostingType` | `(Ljava/lang/String;)Z` | PRIVATE |
  | `isBlockedHostTypeOfPackage` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PRIVATE |
  | `isSystemApp` | `(Landroid/content/pm/ApplicationInfo;)Z` | PRIVATE |
  | `loadProcessWhiteListPackageFromFile` | `()Ljava/util/List;` | PRIVATE |
  | `saveProcessWhiteListPackageToFile` | `()V` | PRIVATE |
  | `addAppProcessControllerWhiteList` | `(Ljava/util/List;)Z` | PUBLIC |
  | `addProcessWhitelistPackage` | `(Ljava/lang/String;)V` | PUBLIC |
  | `dump` | `(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;)V` | PUBLIC |
  | `getAppProcessControllerStatus` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
  | `init` | `(Landroid/content/Context;)V` | PUBLIC |
  | `onStartProcessLocked` | `(Ljava/lang/String;Landroid/content/pm/ApplicationInfo;Lcom/android/server/am/HostingRecord;Ljava/util/ArrayList;)Z` | PUBLIC |
  | `removeProcessWhitelistPackage` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setAppProcessControllerStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setBackgroundControllerSwitch` | `(Z)V` | PUBLIC |

### `AppProcessController$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/am/AppProcessController$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/AppProcessController;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `AppProcessController$$ExternalSyntheticLambda1`

- 完整类名：`Lcom/baidu/am/AppProcessController$$ExternalSyntheticLambda1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/am/AppProcessController;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `BroadcastBlocker`

- 完整类名：`Lcom/baidu/am/BroadcastBlocker`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `isAllowedProtectedBroadcast` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `isValidBugreportReceiver` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `shouldBlock` | `(Lcom/android/server/am/ProcessRecord;Ljava/lang/String;Landroid/content/pm/ActivityInfo;Ljava/lang/String;)Z` | PUBLIC STATIC |

### `ClearTaskController`

- 完整类名：`Lcom/baidu/am/ClearTaskController`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/ClearTaskController;` | PUBLIC STATIC |
  | `isDoNotKillPackage` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isForceStopPackage` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `removePackage` | `(Ljava/lang/String;)V` | PUBLIC |
  | `updateForceStopPackages` | `(Ljava/util/HashSet;)V` | PUBLIC |

### `CrashController`

- 完整类名：`Lcom/baidu/am/CrashController`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/CrashController;` | PUBLIC STATIC |
  | `putInProcessMap` | `(Lcom/android/server/am/ProcessRecord;J)V` | PRIVATE |
  | `onAppCrashLocked` | `(Landroid/content/Context;Lcom/android/server/am/ProcessRecord;Lcom/android/server/am/ActivityManagerService;)V` | PUBLIC |

### `CrashController$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/am/CrashController$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/android/server/am/ProcessRecord;Lcom/android/server/am/ActivityManagerService;Landroid/content/Context;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `ProcessStartStatistics`

- 完整类名：`Lcom/baidu/am/ProcessStartStatistics`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/am/ProcessStartStatistics;` | PUBLIC STATIC |
  | `onBroadcastStartProcess` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onChangeProcessWhitelistPackage` | `(Ljava/lang/String;Z)V` | PUBLIC |
  | `onClearDataAfterCrash` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onProcessStartedLocked` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |

### `SyncManagerBlocker`

- 完整类名：`Lcom/baidu/am/SyncManagerBlocker`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `shouldBlock` | `(Landroid/content/ComponentName;I)Z` | PUBLIC STATIC |

## `Lcom/baidu/input`

### `InputMethodMonitor`

- 完整类名：`Lcom/baidu/input/InputMethodMonitor`
- 方法（10）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getDefaultInputMethodId` | `(Landroid/content/ContentResolver;)Ljava/lang/String;` | PRIVATE |
  | `getEnabledInputMethodsConcatenatedIds` | `(Landroid/content/ContentResolver;)Ljava/lang/String;` | PRIVATE |
  | `getInputComponents` | `(Ljava/lang/String;)Ljava/util/List;` | PRIVATE |
  | `getInstance` | `()Lcom/baidu/input/InputMethodMonitor;` | PUBLIC STATIC |
  | `parseInputMethod` | `(Landroid/content/Context;)V` | PRIVATE |
  | `getCurrentInputMethod` | `()Ljava/lang/String;` | PUBLIC |
  | `getEnabledInputMethods` | `()Ljava/util/List;` | PUBLIC |
  | `init` | `(Landroid/content/Context;)V` | PUBLIC |
  | `onInputSettingsChanged` | `(Landroid/content/Context;Ljava/lang/String;)V` | PUBLIC |

### `InputMethodMonitor$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/input/InputMethodMonitor$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/input/InputMethodMonitor;Landroid/content/Context;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

## `Lcom/baidu/log`

### `AmsShellCommand`

- 完整类名：`Lcom/baidu/log/AmsShellCommand`
- 父类：`Lcom/baidu/log/base/BaseLogShellCommand;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Lcom/android/server/am/ActivityManagerService;)V` | PUBLIC CONSTRUCTOR |
  | `getModuleName` | `()Ljava/lang/String;` | PROTECTED |
  | `getPropertyPrefix` | `()Ljava/lang/String;` | PROTECTED |
  | `getTargetClass` | `()Ljava/lang/Class;` | PROTECTED |
  | `runGenCrashCommand` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `runWatchdogCommand` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `setLogTagValue` | `(Ljava/lang/String;Z)V` | PROTECTED |

### `DuerOsDebugConfig`

- 完整类名：`Lcom/baidu/log/DuerOsDebugConfig`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |

### `PmsShellCommand`

- 完整类名：`Lcom/baidu/log/PmsShellCommand`
- 父类：`Lcom/baidu/log/base/BaseLogShellCommand;`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Lcom/android/server/pm/PackageManagerService;)V` | PUBLIC CONSTRUCTOR |
  | `getModuleName` | `()Ljava/lang/String;` | PROTECTED |
  | `getPropertyPrefix` | `()Ljava/lang/String;` | PROTECTED |
  | `getTargetClass` | `()Ljava/lang/Class;` | PROTECTED |

### `WmsShellCommand`

- 完整类名：`Lcom/baidu/log/WmsShellCommand`
- 父类：`Lcom/baidu/log/base/BaseLogShellCommand;`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Lcom/android/server/wm/WindowManagerService;)V` | PUBLIC CONSTRUCTOR |
  | `getAllDebugSwitchField` | `()Ljava/util/List;` | PROTECTED |
  | `getModuleName` | `()Ljava/lang/String;` | PROTECTED |
  | `getPropertyPrefix` | `()Ljava/lang/String;` | PROTECTED |
  | `getTargetClass` | `()Ljava/lang/Class;` | PROTECTED |

## `Lcom/baidu/log/base`

### `BaseLogShellCommand`

- 完整类名：`Lcom/baidu/log/base/BaseLogShellCommand`
- 父类：`Landroid/os/ShellCommand;`
- 方法（24）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `isDuerCommand` | `([Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `disableLogSwitch` | `(Ljava/io/PrintWriter;Landroid/os/ShellCommand;)I` | PROTECTED |
  | `dumpHelp` | `(Ljava/io/PrintWriter;)V` | PROTECTED |
  | `enableLogSwitch` | `(Ljava/io/PrintWriter;Landroid/os/ShellCommand;)I` | PROTECTED |
  | `getAllDebugSwitchField` | `()Ljava/util/List;` | PROTECTED |
  | `getLogTagValue` | `(Ljava/lang/String;)Ljava/lang/Object;` | PROTECTED |
  | `getModuleName` | `()Ljava/lang/String;` | PROTECTED ABSTRACT |
  | `getPropertyPrefix` | `()Ljava/lang/String;` | PROTECTED ABSTRACT |
  | `getTargetClass` | `()Ljava/lang/Class;` | PROTECTED ABSTRACT |
  | `initTags` | `()V` | PUBLIC |
  | `onCommand` | `(Ljava/lang/String;)I` | PUBLIC |
  | `onCommand` | `(Ljava/lang/String;Landroid/os/ShellCommand;)I` | PUBLIC |
  | `onHelp` | `()V` | PUBLIC |
  | `refreshAllTagStatus` | `()V` | PROTECTED |
  | `runGenCrashCommand` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `runGetLogSwitch` | `(Ljava/io/PrintWriter;Landroid/os/ShellCommand;)I` | PROTECTED |
  | `runHelp` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `runListTags` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `runSetLogSwitch` | `(Ljava/io/PrintWriter;Landroid/os/ShellCommand;)I` | PROTECTED |
  | `runWatchdogCommand` | `(Ljava/io/PrintWriter;)I` | PROTECTED |
  | `setAllLogTagField` | `(Z)V` | PROTECTED |
  | `setLogTagField` | `(Ljava/lang/String;Z)V` | PROTECTED |
  | `setLogTagValue` | `(Ljava/lang/String;Z)V` | PROTECTED |

## `Lcom/baidu/monitors`

### `CameraUseStatusMonitor`

- 完整类名：`Lcom/baidu/monitors/CameraUseStatusMonitor`
- 父类：`Lcom/baidu/monitors/CommonSensorUseStatusMonitor;`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/android/server/baidu/DuerService;)V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `(Lcom/android/server/baidu/DuerService;)Lcom/baidu/monitors/CameraUseStatusMonitor;` | PUBLIC STATIC |
  | `connectService` | `()V` | PUBLIC |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `onCameraClosed` | `(Ljava/lang/String;I)V` | PUBLIC |
  | `onCameraOpened` | `(Ljava/lang/String;I)V` | PUBLIC |

### `CameraUseStatusMonitor$1`

- 完整类名：`Lcom/baidu/monitors/CameraUseStatusMonitor$1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/monitors/CameraUseStatusMonitor;)V` | CONSTRUCTOR |
  | `binderDied` | `()V` | PUBLIC |

### `CameraUseStatusMonitor$1$1`

- 完整类名：`Lcom/baidu/monitors/CameraUseStatusMonitor$1$1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/monitors/CameraUseStatusMonitor$1;)V` | CONSTRUCTOR |
  | `run` | `()V` | PUBLIC |

### `CommonSensorUseStatusMonitor`

- 完整类名：`Lcom/baidu/monitors/CommonSensorUseStatusMonitor`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `registerCallbackListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC STATIC |
  | `unRegisterCallbackListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC STATIC |
  | `mapToString` | `(Landroid/util/ArrayMap;)Ljava/lang/String;` | PUBLIC |

### `MicUseStatusMonitor`

- 完整类名：`Lcom/baidu/monitors/MicUseStatusMonitor`
- 父类：`Lcom/baidu/monitors/CommonSensorUseStatusMonitor;`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/android/server/baidu/DuerService;)V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `(Lcom/android/server/baidu/DuerService;)Lcom/baidu/monitors/MicUseStatusMonitor;` | PUBLIC STATIC |
  | `connectService` | `()V` | PUBLIC |
  | `getMicUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `onMicrophoneOff` | `(Ljava/lang/String;)V` | PUBLIC |
  | `onMicrophoneOn` | `(Ljava/lang/String;)V` | PUBLIC |

### `MicUseStatusMonitor$1`

- 完整类名：`Lcom/baidu/monitors/MicUseStatusMonitor$1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/monitors/MicUseStatusMonitor;)V` | CONSTRUCTOR |
  | `binderDied` | `()V` | PUBLIC |

### `MicUseStatusMonitor$1$1`

- 完整类名：`Lcom/baidu/monitors/MicUseStatusMonitor$1$1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/monitors/MicUseStatusMonitor$1;)V` | CONSTRUCTOR |
  | `run` | `()V` | PUBLIC |

## `Lcom/baidu/notification`

### `NotificationController`

- 完整类名：`Lcom/baidu/notification/NotificationController`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/notification/NotificationController;` | PUBLIC STATIC |
  | `isAllowedToPostNotification` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isAllowedToPostNotification` | `(Ljava/lang/String;Landroid/app/Notification;)Z` | PUBLIC |

## `Lcom/baidu/pm`

### `Permission`

- 完整类名：`Lcom/baidu/pm/Permission`
- 方法（21）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Ljava/lang/String;ZLjava/lang/String;ZI)V` | PUBLIC CONSTRUCTOR |
  | `getAppOp` | `()Ljava/lang/String;` | PUBLIC |
  | `getFlags` | `()I` | PUBLIC |
  | `getName` | `()Ljava/lang/String;` | PUBLIC |
  | `hasAppOp` | `()Z` | PUBLIC |
  | `isAppOpAllowed` | `()Z` | PUBLIC |
  | `isGranted` | `()Z` | PUBLIC |
  | `isNetworkSet` | `()Z` | PUBLIC |
  | `isPolicyFixed` | `()Z` | PUBLIC |
  | `isReviewRequired` | `()Z` | PUBLIC |
  | `isSystemFixed` | `()Z` | PUBLIC |
  | `isUserFixed` | `()Z` | PUBLIC |
  | `isUserSet` | `()Z` | PUBLIC |
  | `resetReviewRequired` | `()V` | PUBLIC |
  | `setAppOpAllowed` | `(Z)V` | PUBLIC |
  | `setGranted` | `(Z)V` | PUBLIC |
  | `setNetworkSet` | `(Z)V` | PUBLIC |
  | `setRevokeOnUpgrade` | `(Z)V` | PUBLIC |
  | `setUserFixed` | `(Z)V` | PUBLIC |
  | `setUserSet` | `(Z)V` | PUBLIC |
  | `shouldRevokeOnUpgrade` | `()Z` | PUBLIC |

### `PermissionController`

- 完整类名：`Lcom/baidu/pm/PermissionController`
- 方法（13）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `isAppInPermissionWhiteList` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `isAppInPermissionWhiteList` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC STATIC |
  | `isDuerOsAppStorePackageName` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `isDuerOsDangerousPermission` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `isWritableRuntimePermission` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `removeLauncherIfNeeded` | `(Ljava/util/List;)V` | PUBLIC STATIC |
  | `revokePkgFlagsIfNeeded` | `(Lcom/android/server/pm/parsing/pkg/ParsedPackage;)V` | PUBLIC STATIC |
  | `shouldGrantApplicationOverlayPermission` | `(ILandroid/content/pm/ApplicationInfo;)Z` | PUBLIC STATIC |
  | `shouldGrantSignaturePermission` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC STATIC |
  | `shouldNotShowConfirmationDialog` | `(Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `shouldRevokeSignaturePermission` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC STATIC |

### `PermissionUtils`

- 完整类名：`Lcom/baidu/pm/PermissionUtils`
- 方法（13）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `checkNotNullAppOpList` | `(Ljava/util/List;)Z` | PRIVATE STATIC |
  | `getSpecialPermissionStatus` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `grantRuntimePermission` | `(Landroid/content/Context;Landroid/content/pm/PackageInfo;Lcom/baidu/pm/Permission;)V` | PRIVATE STATIC |
  | `isLocationEnabled` | `(Landroid/content/Context;)Z` | PRIVATE STATIC |
  | `isLocationGroupAndProvider` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PRIVATE STATIC |
  | `isNetworkLocationProvider` | `(Ljava/lang/String;)Z` | PRIVATE STATIC |
  | `isRuntimePermissionsGranted` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `revokeRuntimePermission` | `(Landroid/content/Context;Landroid/content/pm/PackageInfo;Lcom/baidu/pm/Permission;)V` | PRIVATE STATIC |
  | `setRuntimePermission` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Z)V` | PUBLIC STATIC |
  | `setRuntimePermission` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;ZZ)V` | PUBLIC STATIC |
  | `setRuntimePermissionByGroup` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC STATIC |
  | `setSpecialPermissionStatus` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC STATIC |

### `PermissionUtils$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/pm/PermissionUtils$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/pm/PackageInfo;[Z[ZLjava/lang/String;Landroid/app/AppOpsManager;ZLjava/lang/String;Ljava/util/concurrent/CountDownLatch;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `accept` | `(Ljava/lang/Object;)V` | PUBLIC FINAL |

### `PermissionUtils$$ExternalSyntheticLambda1`

- 完整类名：`Lcom/baidu/pm/PermissionUtils$$ExternalSyntheticLambda1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Ljava/lang/String;Landroid/content/Context;Ljava/lang/String;Z)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `accept` | `(Ljava/lang/Object;)V` | PUBLIC FINAL |

### `PreloadAppController`

- 完整类名：`Lcom/baidu/pm/PreloadAppController`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/pm/PreloadAppController;` | PUBLIC STATIC |
  | `loadPreloadFileList` | `(Ljava/io/File;)Ljava/util/Set;` | PRIVATE STATIC |
  | `dump` | `(Ljava/io/FileDescriptor;Ljava/io/PrintWriter;)V` | PUBLIC |
  | `isGelingApps` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isPreloadThirdPartyApps` | `(Ljava/lang/String;)Z` | PUBLIC |

## `Lcom/baidu/power`

### `DuerPowerManager`

- 完整类名：`Lcom/baidu/power/DuerPowerManager`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/power/DuerPowerManager;` | PUBLIC STATIC |
  | `updateMinimumBrightnessMode` | `(Landroid/content/Context;)V` | PRIVATE |
  | `getMinimumScreenBrightnessSetting` | `(Landroid/content/Context;)I` | PUBLIC |
  | `isMinimumBrightnessMode` | `(Landroid/content/Context;)Z` | PUBLIC |
  | `setMinimumBrightnessValue` | `(Landroid/content/Context;I)V` | PUBLIC |


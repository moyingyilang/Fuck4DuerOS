# DuerOS framework.jar 非标准 API 面（Landroid/*/baidu、Lcom/baidu/*）

共 **62** 个非标准类。数据由 `dexdump` 提取，解析脚本见 `scripts/parse_dexdump.py`。

- 类：62
- 方法：722

## `Landroid/app/baidu`

### `DuerServiceManager`

- 完整类名：`Landroid/app/baidu/DuerServiceManager`
- 方法（71）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;Landroid/os/baidu/IDuerService;)V` | PUBLIC CONSTRUCTOR |
  | `nativeSetRlimit` | `(IJJ)V` | PRIVATE STATIC NATIVE |
  | `closeSocketToSupplicant` | `()V` | PUBLIC |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC |
  | `createSocketToSupplicant` | `()I` | PUBLIC |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableNetwork` | `(I)V` | PUBLIC |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC |
  | `enableSink` | `(Z)V` | PUBLIC |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC |
  | `forgetWifi` | `(I)V` | PUBLIC |
  | `freeStorage` | `(J)V` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
  | `getBluetoothOnMesh` | `()Z` | PUBLIC |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `getDataBytes` | `(Ljava/lang/String;)J` | PUBLIC |
  | `getMicUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `getMinimumScreenBrightnessSetting` | `()I` | PUBLIC |
  | `getOemUnlockEnabled` | `()Z` | PUBLIC |
  | `getPermissionFlag` | `(Ljava/lang/String;Ljava/lang/String;)I` | PUBLIC |
  | `getScreenState` | `()I` | PUBLIC |
  | `getServiceVersion` | `()I` | PUBLIC |
  | `getSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC |
  | `getTransportTypes` | `(Landroid/net/Network;)[I` | PUBLIC |
  | `getWifiVerboseLoggingLevel` | `()I` | PUBLIC |
  | `gotoSleep` | `(J)V` | PUBLIC |
  | `isMinimumBrightnessMode` | `()Z` | PUBLIC |
  | `isNotificationEnabled` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isRuntimePermissionsGranted` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC |
  | `isSafeMediaVolumeEnabled` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `isSinkEnabled` | `()Z` | PUBLIC |
  | `notifyVolumeControllerVisible` | `(Z)V` | PUBLIC |
  | `readWifiPassWd` | `()Ljava/lang/String;` | PUBLIC |
  | `recvMgmtEnable` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `resetPackage` | `(Ljava/lang/String;Landroid/app/baidu/IPackageDataListener;)V` | PUBLIC |
  | `screenshot` | `(II)[B` | PUBLIC |
  | `sendMgmt` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `sendUibcInputEvent` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setActiveDream` | `(Landroid/content/ComponentName;)V` | PUBLIC |
  | `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | PUBLIC |
  | `setActivityStackListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC |
  | `setAppProcessControllerSwitch` | `(Z)V` | PUBLIC |
  | `setAutoPowerOnTime` | `(JLandroid/app/PendingIntent;)V` | PUBLIC |
  | `setBlockingActivities` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBlockingPackages` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBluetoothOnMesh` | `(Z)V` | PUBLIC |
  | `setDebugLogStatus` | `(Z)Z` | PUBLIC |
  | `setIgnoreBatteryOptimizationStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setMinimumBrightnessValue` | `(I)V` | PUBLIC |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC |
  | `setNotificationEnableStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC |
  | `setRlimit` | `(IJJ)V` | PUBLIC |
  | `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `setRuntimePermissionsByGroup` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setSafeMediaVolumeEnabled` | `(ZLjava/lang/String;)V` | PUBLIC |
  | `setSafeMediaVolumeIndex` | `(I)V` | PUBLIC |
  | `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setVolumeController` | `(Landroid/app/baidu/IVolumeControllerListener;)V` | PUBLIC |
  | `setZenMode` | `(Z)V` | PUBLIC |
  | `startDreaming` | `()V` | PUBLIC |
  | `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | PUBLIC |
  | `unRegisterCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `updateSystemConfig` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `waitForMgmtEvent` | `()Ljava/lang/String;` | PUBLIC |
  | `waitWifiDisplayConnection` | `(Landroid/view/Surface;)V` | PUBLIC |
  | `wipe` | `()V` | PUBLIC |

### `DuerServiceManager$1`

- 完整类名：`Landroid/app/baidu/DuerServiceManager$1`
- 父类：`Landroid/content/pm/IPackageDataObserver$Stub;`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/app/baidu/DuerServiceManager;Landroid/app/baidu/IPackageDataListener;)V` | CONSTRUCTOR |
  | `onRemoveCompleted` | `(Ljava/lang/String;Z)V` | PUBLIC |

### `DuerShowInputEventReceiver`

- 完整类名：`Landroid/app/baidu/DuerShowInputEventReceiver`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Ljava/lang/String;Landroid/app/baidu/ITouchEventMonitor;Landroid/os/Looper;)V` | PUBLIC CONSTRUCTOR |
  | `monitorGestureInput` | `(Ljava/lang/String;)Landroid/view/InputChannel;` | PRIVATE |
  | `pilferPointers` | `()V` | PUBLIC |

### `DuerShowInputEventReceiver$1`

- 完整类名：`Landroid/app/baidu/DuerShowInputEventReceiver$1`
- 父类：`Landroid/view/BatchedInputEventReceiver;`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/app/baidu/DuerShowInputEventReceiver;Landroid/view/InputChannel;Landroid/os/Looper;Landroid/view/Choreographer;)V` | CONSTRUCTOR |
  | `onInputEvent` | `(Landroid/view/InputEvent;)V` | PUBLIC |

### `DuerVolumeController`

- 完整类名：`Landroid/app/baidu/DuerVolumeController`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;Landroid/app/baidu/IVolumeControllerListener;)V` | PUBLIC CONSTRUCTOR |
  | `notifyVolumeControllerVisible` | `(Z)V` | PUBLIC |
  | `setVolumeController` | `()V` | PUBLIC |

### `DuerVolumeController$1`

- 完整类名：`Landroid/app/baidu/DuerVolumeController$1`

### `DuerVolumeController$VC`

- 完整类名：`Landroid/app/baidu/DuerVolumeController$VC`
- 父类：`Landroid/media/IVolumeController$Stub;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/app/baidu/DuerVolumeController;)V` | PRIVATE CONSTRUCTOR |
  | `<init>` | `(Landroid/app/baidu/DuerVolumeController;Landroid/app/baidu/DuerVolumeController$1;)V` | SYNTHETIC CONSTRUCTOR |
  | `dismiss` | `()V` | PUBLIC |
  | `displaySafeVolumeWarning` | `(I)V` | PUBLIC |
  | `masterMuteChanged` | `(I)V` | PUBLIC |
  | `setA11yMode` | `(I)V` | PUBLIC |
  | `setLayoutDirection` | `(I)V` | PUBLIC |
  | `volumeChanged` | `(II)V` | PUBLIC |

### `DuerVolumeController$W`

- 完整类名：`Landroid/app/baidu/DuerVolumeController$W`
- 父类：`Landroid/os/Handler;`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/app/baidu/DuerVolumeController;Landroid/os/Looper;)V` | CONSTRUCTOR |
  | `handleMessage` | `(Landroid/os/Message;)V` | PUBLIC |

### `IPackageDataListener`

- 完整类名：`Landroid/app/baidu/IPackageDataListener`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `onRemoveCompleted` | `(Ljava/lang/String;Z)V` | PUBLIC ABSTRACT |

### `ITouchEventMonitor`

- 完整类名：`Landroid/app/baidu/ITouchEventMonitor`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `onTouchEvent` | `(Landroid/view/MotionEvent;)V` | PUBLIC ABSTRACT |

### `IVolumeControllerListener`

- 完整类名：`Landroid/app/baidu/IVolumeControllerListener`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `dismiss` | `()V` | PUBLIC ABSTRACT |
  | `displaySafeVolumeWarning` | `(I)V` | PUBLIC ABSTRACT |
  | `masterMuteChanged` | `(IZ)V` | PUBLIC ABSTRACT |
  | `setLayoutDirection` | `(I)V` | PUBLIC ABSTRACT |
  | `volumeChanged` | `(II)V` | PUBLIC ABSTRACT |

### `SharedPreferenceHack`

- 完整类名：`Landroid/app/baidu/SharedPreferenceHack`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getInstance` | `()Landroid/app/baidu/SharedPreferenceHack;` | PUBLIC STATIC |
  | `onGetBoolean` | `(Ljava/lang/String;ZLjava/lang/Boolean;)Ljava/lang/Boolean;` | PUBLIC |
  | `onPutString` | `(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;` | PUBLIC |

## `Landroid/os/baidu`

### `IActivityStackListener`

- 完整类名：`Landroid/os/baidu/IActivityStackListener`
- 方法（9）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `onAppProcessBound` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onAppProcessDied` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onBlockedActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onDestroyActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onLaunchActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onNewIntent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onPauseActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onResumeActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onStopActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |

### `IActivityStackListener$Default`

- 完整类名：`Landroid/os/baidu/IActivityStackListener$Default`
- 方法（11）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `onAppProcessBound` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onAppProcessDied` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onBlockedActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onDestroyActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onLaunchActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onNewIntent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onPauseActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onResumeActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onStopActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |

### `IActivityStackListener$Stub`

- 完整类名：`Landroid/os/baidu/IActivityStackListener$Stub`
- 父类：`Landroid/os/Binder;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asInterface` | `(Landroid/os/IBinder;)Landroid/os/baidu/IActivityStackListener;` | PUBLIC STATIC |
  | `getDefaultImpl` | `()Landroid/os/baidu/IActivityStackListener;` | PUBLIC STATIC |
  | `getDefaultTransactionName` | `(I)Ljava/lang/String;` | PUBLIC STATIC |
  | `setDefaultImpl` | `(Landroid/os/baidu/IActivityStackListener;)Z` | PUBLIC STATIC |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getTransactionName` | `(I)Ljava/lang/String;` | PUBLIC |
  | `onTransact` | `(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z` | PUBLIC |

### `IActivityStackListener$Stub$Proxy`

- 完整类名：`Landroid/os/baidu/IActivityStackListener$Stub$Proxy`
- 方法（12）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/os/IBinder;)V` | CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getInterfaceDescriptor` | `()Ljava/lang/String;` | PUBLIC |
  | `onAppProcessBound` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onAppProcessDied` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onBlockedActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onDestroyActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onLaunchActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onNewIntent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onPauseActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onResumeActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onStopActivity` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |

### `ICameraAndMicActionListener`

- 完整类名：`Landroid/os/baidu/ICameraAndMicActionListener`
- 方法（4）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `onCameraClosed` | `(Ljava/lang/String;I)V` | PUBLIC ABSTRACT |
  | `onCameraOpened` | `(Ljava/lang/String;I)V` | PUBLIC ABSTRACT |
  | `onMicrophoneOff` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onMicrophoneOn` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |

### `ICameraAndMicActionListener$Default`

- 完整类名：`Landroid/os/baidu/ICameraAndMicActionListener$Default`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `onCameraClosed` | `(Ljava/lang/String;I)V` | PUBLIC |
  | `onCameraOpened` | `(Ljava/lang/String;I)V` | PUBLIC |
  | `onMicrophoneOff` | `(Ljava/lang/String;)V` | PUBLIC |
  | `onMicrophoneOn` | `(Ljava/lang/String;)V` | PUBLIC |

### `ICameraAndMicActionListener$Stub`

- 完整类名：`Landroid/os/baidu/ICameraAndMicActionListener$Stub`
- 父类：`Landroid/os/Binder;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asInterface` | `(Landroid/os/IBinder;)Landroid/os/baidu/ICameraAndMicActionListener;` | PUBLIC STATIC |
  | `getDefaultImpl` | `()Landroid/os/baidu/ICameraAndMicActionListener;` | PUBLIC STATIC |
  | `getDefaultTransactionName` | `(I)Ljava/lang/String;` | PUBLIC STATIC |
  | `setDefaultImpl` | `(Landroid/os/baidu/ICameraAndMicActionListener;)Z` | PUBLIC STATIC |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getTransactionName` | `(I)Ljava/lang/String;` | PUBLIC |
  | `onTransact` | `(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z` | PUBLIC |

### `ICameraAndMicActionListener$Stub$Proxy`

- 完整类名：`Landroid/os/baidu/ICameraAndMicActionListener$Stub$Proxy`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/os/IBinder;)V` | CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getInterfaceDescriptor` | `()Ljava/lang/String;` | PUBLIC |
  | `onCameraClosed` | `(Ljava/lang/String;I)V` | PUBLIC |
  | `onCameraOpened` | `(Ljava/lang/String;I)V` | PUBLIC |
  | `onMicrophoneOff` | `(Ljava/lang/String;)V` | PUBLIC |
  | `onMicrophoneOn` | `(Ljava/lang/String;)V` | PUBLIC |

### `IDuerService`

- 完整类名：`Landroid/os/baidu/IDuerService`
- 方法（63）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `closeSocketToSupplicant` | `()V` | PUBLIC ABSTRACT |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC ABSTRACT |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `createSocketToSupplicant` | `()I` | PUBLIC ABSTRACT |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC ABSTRACT |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `disableNetwork` | `(I)V` | PUBLIC ABSTRACT |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC ABSTRACT |
  | `enableSink` | `(Z)V` | PUBLIC ABSTRACT |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC ABSTRACT |
  | `forgetWifi` | `(I)V` | PUBLIC ABSTRACT |
  | `freeStorage` | `(J)V` | PUBLIC ABSTRACT |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC ABSTRACT |
  | `getBluetoothOnMesh` | `()Z` | PUBLIC ABSTRACT |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `getDataBytes` | `(Ljava/lang/String;)J` | PUBLIC ABSTRACT |
  | `getMicUseApps` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `getMinimumScreenBrightnessSetting` | `()I` | PUBLIC ABSTRACT |
  | `getOemUnlockEnabled` | `()Z` | PUBLIC ABSTRACT |
  | `getPermissionFlag` | `(Ljava/lang/String;Ljava/lang/String;)I` | PUBLIC ABSTRACT |
  | `getScreenState` | `()I` | PUBLIC ABSTRACT |
  | `getSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `getTransportTypes` | `(Landroid/net/Network;)[I` | PUBLIC ABSTRACT |
  | `getWifiVerboseLoggingLevel` | `()I` | PUBLIC ABSTRACT |
  | `goToSleep` | `(J)V` | PUBLIC ABSTRACT |
  | `isMinimumBrightnessMode` | `()Z` | PUBLIC ABSTRACT |
  | `isNotificationEnabled` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isRuntimePermissionsGranted` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isSafeMediaVolumeEnabled` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isSinkEnabled` | `()Z` | PUBLIC ABSTRACT |
  | `readWifiPassWd` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `recvMgmtEnable` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC ABSTRACT |
  | `screenshot` | `(II)[B` | PUBLIC ABSTRACT |
  | `sendMgmt` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `sendUibcInputEvent` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setActiveDream` | `(Landroid/content/ComponentName;)V` | PUBLIC ABSTRACT |
  | `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `setActivityStackListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC ABSTRACT |
  | `setAppProcessControllerSwitch` | `(Z)V` | PUBLIC ABSTRACT |
  | `setBlockingActivities` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setBlockingPackages` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setBluetoothOnMesh` | `(Z)V` | PUBLIC ABSTRACT |
  | `setDebugLogStatus` | `(Z)Z` | PUBLIC ABSTRACT |
  | `setIgnoreBatteryOptimizationStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setMinimumBrightnessValue` | `(I)V` | PUBLIC ABSTRACT |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setNotificationEnableStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC ABSTRACT |
  | `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setRuntimePermissionsByGroup` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setSafeMediaVolumeEnabled` | `(ZLjava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setSafeMediaVolumeIndex` | `(I)V` | PUBLIC ABSTRACT |
  | `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setZenMode` | `(Z)V` | PUBLIC ABSTRACT |
  | `startDreaming` | `()V` | PUBLIC ABSTRACT |
  | `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | PUBLIC ABSTRACT |
  | `unRegisterCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC ABSTRACT |
  | `updateSystemConfig` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `waitForMgmtEvent` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `waitWifiDisplayConnection` | `(Landroid/view/Surface;)V` | PUBLIC ABSTRACT |
  | `wipe` | `()V` | PUBLIC ABSTRACT |

### `IDuerService$Default`

- 完整类名：`Landroid/os/baidu/IDuerService$Default`
- 方法（65）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `closeSocketToSupplicant` | `()V` | PUBLIC |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC |
  | `createSocketToSupplicant` | `()I` | PUBLIC |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableNetwork` | `(I)V` | PUBLIC |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC |
  | `enableSink` | `(Z)V` | PUBLIC |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC |
  | `forgetWifi` | `(I)V` | PUBLIC |
  | `freeStorage` | `(J)V` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
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

### `IDuerService$Stub`

- 完整类名：`Landroid/os/baidu/IDuerService$Stub`
- 父类：`Landroid/os/Binder;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asInterface` | `(Landroid/os/IBinder;)Landroid/os/baidu/IDuerService;` | PUBLIC STATIC |
  | `getDefaultImpl` | `()Landroid/os/baidu/IDuerService;` | PUBLIC STATIC |
  | `getDefaultTransactionName` | `(I)Ljava/lang/String;` | PUBLIC STATIC |
  | `setDefaultImpl` | `(Landroid/os/baidu/IDuerService;)Z` | PUBLIC STATIC |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getTransactionName` | `(I)Ljava/lang/String;` | PUBLIC |
  | `onTransact` | `(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z` | PUBLIC |

### `IDuerService$Stub$Proxy`

- 完整类名：`Landroid/os/baidu/IDuerService$Stub$Proxy`
- 方法（66）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/os/IBinder;)V` | CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `closeSocketToSupplicant` | `()V` | PUBLIC |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC |
  | `createSocketToSupplicant` | `()I` | PUBLIC |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableNetwork` | `(I)V` | PUBLIC |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC |
  | `enableSink` | `(Z)V` | PUBLIC |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC |
  | `forgetWifi` | `(I)V` | PUBLIC |
  | `freeStorage` | `(J)V` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
  | `getBluetoothOnMesh` | `()Z` | PUBLIC |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC |
  | `getDataBytes` | `(Ljava/lang/String;)J` | PUBLIC |
  | `getInterfaceDescriptor` | `()Ljava/lang/String;` | PUBLIC |
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

### `IOnAppletBlockedListener`

- 完整类名：`Landroid/os/baidu/IOnAppletBlockedListener`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `onAppletBlocked` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |

### `IOnAppletBlockedListener$Default`

- 完整类名：`Landroid/os/baidu/IOnAppletBlockedListener$Default`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `onAppletBlocked` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |

### `IOnAppletBlockedListener$Stub`

- 完整类名：`Landroid/os/baidu/IOnAppletBlockedListener$Stub`
- 父类：`Landroid/os/Binder;`
- 方法（8）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `asInterface` | `(Landroid/os/IBinder;)Landroid/os/baidu/IOnAppletBlockedListener;` | PUBLIC STATIC |
  | `getDefaultImpl` | `()Landroid/os/baidu/IOnAppletBlockedListener;` | PUBLIC STATIC |
  | `getDefaultTransactionName` | `(I)Ljava/lang/String;` | PUBLIC STATIC |
  | `setDefaultImpl` | `(Landroid/os/baidu/IOnAppletBlockedListener;)Z` | PUBLIC STATIC |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getTransactionName` | `(I)Ljava/lang/String;` | PUBLIC |
  | `onTransact` | `(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z` | PUBLIC |

### `IOnAppletBlockedListener$Stub$Proxy`

- 完整类名：`Landroid/os/baidu/IOnAppletBlockedListener$Stub$Proxy`
- 方法（4）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/os/IBinder;)V` | CONSTRUCTOR |
  | `asBinder` | `()Landroid/os/IBinder;` | PUBLIC |
  | `getInterfaceDescriptor` | `()Ljava/lang/String;` | PUBLIC |
  | `onAppletBlocked` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |

## `Landroid/widget/baidu`

### `ToastUtils`

- 完整类名：`Landroid/widget/baidu/ToastUtils`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getConfigurationContext` | `(Landroid/content/Context;)Landroid/content/Context;` | PUBLIC STATIC |
  | `setMediumStyle` | `(Landroid/widget/TextView;)V` | PUBLIC STATIC |

## `Lcom/baidu/android/duershow`

### `DuerShowManagerEx`

- 完整类名：`Lcom/baidu/android/duershow/DuerShowManagerEx`
- 方法（72）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;)V` | PRIVATE CONSTRUCTOR |
  | `getService` | `(Landroid/content/Context;)Lcom/baidu/android/duershow/IDuerShowManagerEx;` | PUBLIC STATIC |
  | `closeSocketToSupplicant` | `()V` | PUBLIC |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC |
  | `createSocketToSupplicant` | `()I` | PUBLIC |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC |
  | `disableNetwork` | `(I)V` | PUBLIC |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC |
  | `enableSink` | `(Z)V` | PUBLIC |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC |
  | `forgetWifi` | `(I)V` | PUBLIC |
  | `freeStorage` | `(J)V` | PUBLIC |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC |
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
  | `notifyVolumeControllerVisible` | `(Z)V` | PUBLIC |
  | `pilferPointers` | `(I)V` | PUBLIC |
  | `readWifiPassWd` | `()Ljava/lang/String;` | PUBLIC |
  | `recvMgmtEnable` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `registerInputEventMonitor` | `(Ljava/lang/String;Landroid/app/baidu/ITouchEventMonitor;Landroid/os/Looper;)V` | PUBLIC |
  | `resetPackage` | `(Ljava/lang/String;Landroid/app/baidu/IPackageDataListener;)V` | PUBLIC |
  | `screenshot` | `(II)[B` | PUBLIC |
  | `sendMgmt` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `sendUibcInputEvent` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setActiveDream` | `(Landroid/content/ComponentName;)V` | PUBLIC |
  | `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | PUBLIC |
  | `setActivityStackListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC |
  | `setAppProcessControllerSwitch` | `(Z)V` | PUBLIC |
  | `setAutoPowerOnTime` | `(JLandroid/app/PendingIntent;)V` | PUBLIC |
  | `setBlockingActivities` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBlockingPackages` | `(Ljava/util/List;)V` | PUBLIC |
  | `setBluetoothOnMesh` | `(Z)V` | PUBLIC |
  | `setDebugLogStatus` | `(Z)Z` | PUBLIC |
  | `setIgnoreBatteryOptimizationStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setMinimumBrightnessValue` | `(I)V` | PUBLIC |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC |
  | `setNotificationEnableStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC |
  | `setRlimit` | `(IJJ)V` | PUBLIC |
  | `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `setRuntimePermissionsByGroup` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setSafeMediaVolumeEnabled` | `(ZLjava/lang/String;)V` | PUBLIC |
  | `setSafeMediaVolumeIndex` | `(I)V` | PUBLIC |
  | `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC |
  | `setVolumeController` | `(Landroid/app/baidu/IVolumeControllerListener;)V` | PUBLIC |
  | `setZenMode` | `(Z)V` | PUBLIC |
  | `startDreaming` | `()V` | PUBLIC |
  | `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | PUBLIC |
  | `unRegisterCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC |
  | `updateSystemConfig` | `(Ljava/lang/String;)Z` | PUBLIC |
  | `waitForMgmtEvent` | `()Ljava/lang/String;` | PUBLIC |
  | `waitWifiDisplayConnection` | `(Landroid/view/Surface;)V` | PUBLIC |
  | `wipe` | `()V` | PUBLIC |

### `IDuerShowManagerEx`

- 完整类名：`Lcom/baidu/android/duershow/IDuerShowManagerEx`
- 方法（70）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `closeSocketToSupplicant` | `()V` | PUBLIC ABSTRACT |
  | `computeBatteryTimeRemaining` | `()J` | PUBLIC ABSTRACT |
  | `copyProcessProcFiles` | `(ILjava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `createSocketToSupplicant` | `()I` | PUBLIC ABSTRACT |
  | `disableAutoPowerOn` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `disableBluetoothMeshOn` | `()V` | PUBLIC ABSTRACT |
  | `disableEphemeralNetwork` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `disableNetwork` | `(I)V` | PUBLIC ABSTRACT |
  | `enableBluetoothMeshOn` | `()V` | PUBLIC ABSTRACT |
  | `enableSink` | `(Z)V` | PUBLIC ABSTRACT |
  | `enableWifiVerboseLogging` | `(I)V` | PUBLIC ABSTRACT |
  | `forgetWifi` | `(I)V` | PUBLIC ABSTRACT |
  | `freeStorage` | `(J)V` | PUBLIC ABSTRACT |
  | `getAppProcessControllerWhiteList` | `()Ljava/util/List;` | PUBLIC ABSTRACT |
  | `getBluetoothOnMesh` | `()Z` | PUBLIC ABSTRACT |
  | `getCameraUseApps` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `getDataBytes` | `(Ljava/lang/String;)J` | PUBLIC ABSTRACT |
  | `getMicUseApps` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `getMinimumScreenBrightnessSetting` | `()I` | PUBLIC ABSTRACT |
  | `getOemUnlockEnabled` | `()Z` | PUBLIC ABSTRACT |
  | `getPermissionFlag` | `(Ljava/lang/String;Ljava/lang/String;)I` | PUBLIC ABSTRACT |
  | `getScreenState` | `()I` | PUBLIC ABSTRACT |
  | `getSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `getTransportTypes` | `(Landroid/net/Network;)[I` | PUBLIC ABSTRACT |
  | `getWifiVerboseLoggingLevel` | `()I` | PUBLIC ABSTRACT |
  | `goToSleep` | `(J)V` | PUBLIC ABSTRACT |
  | `isMinimumBrightnessMode` | `()Z` | PUBLIC ABSTRACT |
  | `isNotificationEnabled` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isRuntimePermissionsGranted` | `(Ljava/lang/String;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isSafeMediaVolumeEnabled` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `isSinkEnabled` | `()Z` | PUBLIC ABSTRACT |
  | `notifyVolumeControllerVisible` | `(Z)V` | PUBLIC ABSTRACT |
  | `pilferPointers` | `(I)V` | PUBLIC ABSTRACT |
  | `readWifiPassWd` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `recvMgmtEnable` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `registerCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC ABSTRACT |
  | `registerInputEventMonitor` | `(Ljava/lang/String;Landroid/app/baidu/ITouchEventMonitor;Landroid/os/Looper;)V` | PUBLIC ABSTRACT |
  | `resetPackage` | `(Ljava/lang/String;Landroid/app/baidu/IPackageDataListener;)V` | PUBLIC ABSTRACT |
  | `screenshot` | `(II)[B` | PUBLIC ABSTRACT |
  | `sendMgmt` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `sendUibcInputEvent` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setActiveDream` | `(Landroid/content/ComponentName;)V` | PUBLIC ABSTRACT |
  | `setActiveProfileOwner` | `(Landroid/content/ComponentName;Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `setActivityStackListener` | `(Landroid/os/baidu/IActivityStackListener;)V` | PUBLIC ABSTRACT |
  | `setAppProcessControllerSwitch` | `(Z)V` | PUBLIC ABSTRACT |
  | `setAutoPowerOnTime` | `(JLandroid/app/PendingIntent;)V` | PUBLIC ABSTRACT |
  | `setBlockingActivities` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setBlockingPackages` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setBluetoothOnMesh` | `(Z)V` | PUBLIC ABSTRACT |
  | `setDebugLogStatus` | `(Z)Z` | PUBLIC ABSTRACT |
  | `setIgnoreBatteryOptimizationStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setMinimumBrightnessValue` | `(I)V` | PUBLIC ABSTRACT |
  | `setNonBlockingApplets` | `(Ljava/util/List;)V` | PUBLIC ABSTRACT |
  | `setNotificationEnableStatus` | `(Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setOnAppletBlockedListener` | `(Landroid/os/baidu/IOnAppletBlockedListener;)V` | PUBLIC ABSTRACT |
  | `setRlimit` | `(IJJ)V` | PUBLIC ABSTRACT |
  | `setRuntimePermissions` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setRuntimePermissionsByGroup` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setSafeMediaVolumeEnabled` | `(ZLjava/lang/String;)V` | PUBLIC ABSTRACT |
  | `setSafeMediaVolumeIndex` | `(I)V` | PUBLIC ABSTRACT |
  | `setSpecialPermissionStatus` | `(Ljava/lang/String;Ljava/lang/String;Z)Z` | PUBLIC ABSTRACT |
  | `setVolumeController` | `(Landroid/app/baidu/IVolumeControllerListener;)V` | PUBLIC ABSTRACT |
  | `setZenMode` | `(Z)V` | PUBLIC ABSTRACT |
  | `startDreaming` | `()V` | PUBLIC ABSTRACT |
  | `takeScreenshot` | `(II)Landroid/graphics/Bitmap;` | PUBLIC ABSTRACT |
  | `unRegisterCameraAndMicActionListener` | `(Landroid/os/baidu/ICameraAndMicActionListener;)V` | PUBLIC ABSTRACT |
  | `updateSystemConfig` | `(Ljava/lang/String;)Z` | PUBLIC ABSTRACT |
  | `waitForMgmtEvent` | `()Ljava/lang/String;` | PUBLIC ABSTRACT |
  | `waitWifiDisplayConnection` | `(Landroid/view/Surface;)V` | PUBLIC ABSTRACT |
  | `wipe` | `()V` | PUBLIC ABSTRACT |

## `Lcom/baidu/framework`

### `ContextUtil`

- 完整类名：`Lcom/baidu/framework/ContextUtil`
- 方法（4）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/framework/ContextUtil;` | PUBLIC STATIC |
  | `getContext` | `()Landroid/content/Context;` | PUBLIC |
  | `setContext` | `(Landroid/content/Context;)V` | PUBLIC |

### `DuerOsFeatures`

- 完整类名：`Lcom/baidu/framework/DuerOsFeatures`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/framework/features/DefaultFeatures;` | PUBLIC STATIC |

## `Lcom/baidu/framework/features`

### `DefaultFeatures`

- 完整类名：`Lcom/baidu/framework/features/DefaultFeatures`
- 方法（22）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getBaiduBatteryMaxVolume` | `()I` | PUBLIC |
  | `getBaiduDefaultVolume` | `()I` | PUBLIC |
  | `getDefaultLeboDeviceName` | `()Ljava/lang/String;` | PUBLIC |
  | `getInstallPolicy` | `()I` | PUBLIC |
  | `isAlertDialogSmallUI` | `()Z` | PUBLIC |
  | `isBlockWeChatRegBroadcast` | `()Z` | PUBLIC |
  | `isCheckBajinUseDevice` | `()Z` | PUBLIC |
  | `isDefaultRotation` | `()Z` | PUBLIC |
  | `isDisableUninstallUselessApps` | `()Z` | PUBLIC |
  | `isDuerShowDream` | `()Z` | PUBLIC |
  | `isDuerShowPowerkeyToLauncher` | `()Z` | PUBLIC |
  | `isDuerShowWebViewLimit` | `()Z` | PUBLIC |
  | `isExternalAppInstallUI` | `()Z` | PUBLIC |
  | `isFilterBootAnimationStopped` | `()Z` | PUBLIC |
  | `isReplacePendingIntentEnabled` | `()Z` | PUBLIC |
  | `isSupportThreeRotation` | `()Z` | PUBLIC |
  | `isToastCustom` | `()Z` | PUBLIC |
  | `isVirtualBackCamera` | `()Z` | PUBLIC |
  | `isVirtualBackCameraRotation180` | `()Z` | PUBLIC |
  | `isWakeUpWhenWeChatCall` | `()Z` | PUBLIC |
  | `printToggleStatus` | `()V` | PUBLIC |

### `FeaturesCX15`

- 完整类名：`Lcom/baidu/framework/features/FeaturesCX15`
- 父类：`Lcom/baidu/framework/features/DefaultFeatures;`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |

## `Lcom/baidu/framework/statistics`

### `AnalyticsReporter`

- 完整类名：`Lcom/baidu/framework/statistics/AnalyticsReporter`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;)V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `(Landroid/content/Context;)Lcom/baidu/framework/statistics/AnalyticsReporter;` | PUBLIC STATIC |
  | `getReporter` | `()Lcom/baidu/framework/statistics/IReporter;` | PUBLIC |

### `DuerCpuTracker`

- 完整类名：`Lcom/baidu/framework/statistics/DuerCpuTracker`
- 方法（10）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Landroid/content/Context;IJ)V` | PUBLIC CONSTRUCTOR |
  | `compute` | `(Z)V` | PRIVATE |
  | `getProcessCpuInfo` | `()[J` | PRIVATE |
  | `getProcessMemoryInfo` | `()J` | PRIVATE |
  | `getSysCPUInfo` | `()[J` | PRIVATE |
  | `getSysMemRate` | `()F` | PRIVATE |
  | `init` | `(Landroid/content/Context;IJ)V` | PRIVATE DECLARED_SYNCHRONIZED |
  | `resetStatInfo` | `()V` | PRIVATE |
  | `report` | `(ZLjava/lang/String;)V` | PUBLIC DECLARED_SYNCHRONIZED |

### `DuerLaunchTimeReporter`

- 完整类名：`Lcom/baidu/framework/statistics/DuerLaunchTimeReporter`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/framework/statistics/DuerLaunchTimeReporter;` | PUBLIC STATIC |
  | `onTrack` | `(Landroid/content/Context;Lorg/json/JSONObject;)V` | PUBLIC DECLARED_SYNCHRONIZED |

### `EventType`

- 完整类名：`Lcom/baidu/framework/statistics/EventType`

### `IReporter`

- 完整类名：`Lcom/baidu/framework/statistics/IReporter`
- 方法（16）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `init` | `()V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Map;)V` | PUBLIC ABSTRACT |
  | `onEvent` | `(Ljava/lang/String;Ljava/util/Map;)V` | PUBLIC ABSTRACT |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;J)V` | PUBLIC ABSTRACT |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;JLjava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;J)V` | PUBLIC ABSTRACT |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;JLjava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `onEventJson` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `sendClickEvent` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |
  | `sendSlideEvent` | `(Ljava/lang/String;)V` | PUBLIC ABSTRACT |

### `PmsEventQueue`

- 完整类名：`Lcom/baidu/framework/statistics/PmsEventQueue`
- 方法（6）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/framework/statistics/PmsEventQueue;` | PUBLIC STATIC |
  | `clear` | `()V` | PUBLIC DECLARED_SYNCHRONIZED |
  | `getPmsEvents` | `()Ljava/util/ArrayList;` | PUBLIC DECLARED_SYNCHRONIZED |
  | `put` | `(Lcom/baidu/framework/statistics/model/PmsEvent;)V` | PUBLIC DECLARED_SYNCHRONIZED |

### `StatisticConstants`

- 完整类名：`Lcom/baidu/framework/statistics/StatisticConstants`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |

### `StatisticConstants$PermissionControl`

- 完整类名：`Lcom/baidu/framework/statistics/StatisticConstants$PermissionControl`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |

### `StatisticController`

- 完整类名：`Lcom/baidu/framework/statistics/StatisticController`
- 方法（12）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/framework/statistics/StatisticController;` | PUBLIC STATIC |
  | `sendClickEvent` | `(Landroid/content/Context;Lcom/baidu/framework/statistics/model/CesEvent;)V` | PRIVATE |
  | `sendSlideEvent` | `(Landroid/content/Context;Lcom/baidu/framework/statistics/model/CesEvent;)V` | PRIVATE |
  | `onChooserActivityClicked` | `(Landroid/content/Context;Ljava/lang/String;Landroid/content/Intent;Ljava/lang/String;)V` | PUBLIC |
  | `onThirdAppDownloadEvent` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;)V` | PUBLIC |
  | `onThirdAppDownloadEvent` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;ZJZLjava/lang/String;)V` | PUBLIC |
  | `sendPmsEvent` | `(Landroid/content/Context;Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;)V` | PUBLIC |
  | `sendPmsEvent` | `(Landroid/content/Context;Lcom/baidu/framework/statistics/model/PmsEvent;)V` | PUBLIC |
  | `sendProcDex2oatEvent` | `(Landroid/content/Context;Ljava/lang/String;)V` | PUBLIC |
  | `sendProcHealthyDataEvent` | `(Landroid/content/Context;Ljava/lang/String;)V` | PUBLIC |
  | `sendZcombieProcEvent` | `(Landroid/content/Context;Ljava/lang/String;JJJJ)V` | PUBLIC |

## `Lcom/baidu/framework/statistics/model`

### `CesEvent`

- 完整类名：`Lcom/baidu/framework/statistics/model/CesEvent`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `getActivityName` | `(Landroid/content/Context;)Ljava/lang/String;` | PRIVATE STATIC |
  | `getPackageName` | `(Landroid/content/Context;)Ljava/lang/String;` | PRIVATE STATIC |
  | `toJsonString` | `()Ljava/lang/String;` | PUBLIC |
  | `toString` | `()Ljava/lang/String;` | PUBLIC |

### `PmsEvent`

- 完整类名：`Lcom/baidu/framework/statistics/model/PmsEvent`
- 方法（17）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `toJsonString` | `()Ljava/lang/String;` | PRIVATE |
  | `getCertIndex` | `()Ljava/lang/String;` | PUBLIC |
  | `getCertReadSignaturesSize` | `()I` | PUBLIC |
  | `getErrorType` | `()Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;` | PUBLIC |
  | `getEventPageType` | `()Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;` | PUBLIC |
  | `getExtendItem` | `()Ljava/lang/String;` | PUBLIC |
  | `getPackageName` | `()Ljava/lang/String;` | PUBLIC |
  | `getUserId` | `()I` | PUBLIC |
  | `setCertIndex` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setCertReadSignaturesSize` | `(I)V` | PUBLIC |
  | `setErrorType` | `(Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;)V` | PUBLIC |
  | `setEventPageType` | `(Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;)V` | PUBLIC |
  | `setExtendItem` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setPackageName` | `(Ljava/lang/String;)V` | PUBLIC |
  | `setUserId` | `(I)V` | PUBLIC |
  | `toString` | `()Ljava/lang/String;` | PUBLIC |

### `PmsEvent$ErrorType`

- 完整类名：`Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType`
- 父类：`Ljava/lang/Enum;`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;ILjava/lang/String;)V` | PRIVATE CONSTRUCTOR |
  | `valueOf` | `(Ljava/lang/String;)Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;` | PUBLIC STATIC |
  | `values` | `()[Lcom/baidu/framework/statistics/model/PmsEvent$ErrorType;` | PUBLIC STATIC |
  | `getValue` | `()Ljava/lang/String;` | PUBLIC |

### `PmsEvent$EventPageType`

- 完整类名：`Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType`
- 父类：`Ljava/lang/Enum;`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;ILjava/lang/String;)V` | PRIVATE CONSTRUCTOR |
  | `valueOf` | `(Ljava/lang/String;)Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;` | PUBLIC STATIC |
  | `values` | `()[Lcom/baidu/framework/statistics/model/PmsEvent$EventPageType;` | PUBLIC STATIC |
  | `getValue` | `()Ljava/lang/String;` | PUBLIC |

### `ThirdAppDownloadEvent`

- 完整类名：`Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;Ljava/lang/String;Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;Ljava/lang/String;Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;ZJZLjava/lang/String;)V` | PUBLIC CONSTRUCTOR |
  | `toJsonString` | `()Ljava/lang/String;` | PRIVATE |
  | `toString` | `()Ljava/lang/String;` | PUBLIC |

### `ThirdAppDownloadEvent$InstallResult`

- 完整类名：`Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult`
- 父类：`Ljava/lang/Enum;`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `(Ljava/lang/String;ILjava/lang/String;)V` | PRIVATE CONSTRUCTOR |
  | `valueOf` | `(Ljava/lang/String;)Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;` | PUBLIC STATIC |
  | `values` | `()[Lcom/baidu/framework/statistics/model/ThirdAppDownloadEvent$InstallResult;` | PUBLIC STATIC |
  | `getValue` | `()Ljava/lang/String;` | PUBLIC |

### `ZcombieProcEvent`

- 完整类名：`Lcom/baidu/framework/statistics/model/ZcombieProcEvent`
- 方法（3）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(JJJ)V` | PUBLIC CONSTRUCTOR |
  | `toJsonString` | `()Ljava/lang/String;` | PUBLIC |
  | `toString` | `()Ljava/lang/String;` | PUBLIC |

## `Lcom/baidu/framework/statistics/reporter`

### `BroadcastReporter`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter`
- 方法（17）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;)V` | PUBLIC CONSTRUCTOR |
  | `init` | `()V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Map;)V` | PUBLIC |
  | `onEvent` | `(Ljava/lang/String;Ljava/util/Map;)V` | PUBLIC |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;J)V` | PUBLIC |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;JLjava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;J)V` | PUBLIC |
  | `onEventDuration` | `(Ljava/lang/String;Ljava/util/Date;Ljava/util/Date;JLjava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `onEventJson` | `(Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC |
  | `sendClickEvent` | `(Ljava/lang/String;)V` | PUBLIC |
  | `sendSlideEvent` | `(Ljava/lang/String;)V` | PUBLIC |

### `BroadcastReporter$$ExternalSyntheticLambda0`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter$$ExternalSyntheticLambda0`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/reporter/BroadcastReporter;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `BroadcastReporter$$ExternalSyntheticLambda1`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter$$ExternalSyntheticLambda1`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/reporter/BroadcastReporter;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `BroadcastReporter$$ExternalSyntheticLambda2`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter$$ExternalSyntheticLambda2`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/reporter/BroadcastReporter;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `BroadcastReporter$$ExternalSyntheticLambda3`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter$$ExternalSyntheticLambda3`
- 方法（2）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/reporter/BroadcastReporter;Ljava/util/Map;Ljava/lang/String;Ljava/lang/String;)V` | PUBLIC SYNTHETIC CONSTRUCTOR |
  | `run` | `()V` | PUBLIC FINAL |

### `BroadcastReporter$1`

- 完整类名：`Lcom/baidu/framework/statistics/reporter/BroadcastReporter$1`
- 父类：`Ljava/util/HashMap;`
- 方法（1）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Lcom/baidu/framework/statistics/reporter/BroadcastReporter;Ljava/util/Date;Ljava/util/Date;JLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V` | CONSTRUCTOR |

## `Lcom/baidu/framework/view`

### `WindowFlagsCleaner`

- 完整类名：`Lcom/baidu/framework/view/WindowFlagsCleaner`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `cleanFlags` | `(IILjava/lang/String;)I` | PUBLIC STATIC |
  | `isFlagSet` | `(II)Z` | PRIVATE STATIC |
  | `unsetMask` | `(II)I` | PRIVATE STATIC |

## `Lcom/baidu/utils`

### `PackageUtils`

- 完整类名：`Lcom/baidu/utils/PackageUtils`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `()V` | PUBLIC CONSTRUCTOR |
  | `getApplicationInfo` | `(Landroid/content/Context;Ljava/lang/String;)Landroid/content/pm/ApplicationInfo;` | PRIVATE STATIC |
  | `isSystemApp` | `(I)Z` | PUBLIC STATIC |
  | `isSystemApp` | `(Landroid/content/Context;Ljava/lang/String;)Z` | PUBLIC STATIC |
  | `shouldAllowGrantUriPermission` | `(Landroid/content/Context;Ljava/lang/String;)Z` | PUBLIC STATIC |

## `Lcom/baidu/view`

### `AppDensityController`

- 完整类名：`Lcom/baidu/view/AppDensityController`
- 方法（5）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/view/AppDensityController;` | PUBLIC STATIC |
  | `getOverrideAppDensity` | `()I` | PUBLIC |
  | `shouldOverrideDensity` | `()Z` | PUBLIC |

### `ResourceDebugUtil`

- 完整类名：`Lcom/baidu/view/ResourceDebugUtil`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<clinit>` | `()V` | STATIC CONSTRUCTOR |
  | `<init>` | `()V` | PRIVATE CONSTRUCTOR |
  | `getInstance` | `()Lcom/baidu/view/ResourceDebugUtil;` | PUBLIC STATIC |
  | `getNameById` | `(Landroid/content/res/Resources;Ljava/lang/String;)Ljava/lang/String;` | PRIVATE |
  | `getPrefix` | `(I)Ljava/lang/String;` | PRIVATE |
  | `printLayoutXmlInner` | `(Landroid/content/res/XmlResourceParser;Landroid/content/res/Resources;)V` | PRIVATE |
  | `printLayoutXml` | `(ILandroid/content/res/Resources;)V` | PUBLIC |

### `RoundRectImageView`

- 完整类名：`Lcom/baidu/view/RoundRectImageView`
- 父类：`Landroid/widget/ImageView;`
- 方法（7）：

  | 方法 | 签名 | 可见性 |
  | --- | --- | --- |
  | `<init>` | `(Landroid/content/Context;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Landroid/content/Context;Landroid/util/AttributeSet;)V` | PUBLIC CONSTRUCTOR |
  | `<init>` | `(Landroid/content/Context;Landroid/util/AttributeSet;I)V` | PUBLIC CONSTRUCTOR |
  | `initView` | `()V` | PRIVATE |
  | `drawableToBitmap` | `(Landroid/graphics/drawable/Drawable;)Landroid/graphics/Bitmap;` | PUBLIC |
  | `getRoundBitmapByShader` | `(Landroid/graphics/Bitmap;III)Landroid/graphics/Bitmap;` | PUBLIC |
  | `onDraw` | `(Landroid/graphics/Canvas;)V` | PROTECTED |


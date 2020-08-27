with Ada.Containers.Ordered_Maps;
with Ada.Exceptions;

package CUDA is
   pragma Elaborate_Body;

   package Temp_registry_map_1 is new Ada.Containers.Ordered_Maps
     (Integer, Ada.Exceptions.Exception_Id, "<", Ada.Exceptions."=");
   Exception_Registry : Temp_registry_map_1.Map;
   ErrorInvalidValue                : exception;
   ErrorMemoryAllocation            : exception;
   ErrorInitializationError         : exception;
   ErrorCudartUnloading             : exception;
   ErrorProfilerDisabled            : exception;
   ErrorProfilerNotInitialized      : exception;
   ErrorProfilerAlreadyStarted      : exception;
   ErrorProfilerAlreadyStopped      : exception;
   ErrorInvalidConfiguration        : exception;
   ErrorInvalidPitchValue           : exception;
   ErrorInvalidSymbol               : exception;
   ErrorInvalidHostPointer          : exception;
   ErrorInvalidDevicePointer        : exception;
   ErrorInvalidTexture              : exception;
   ErrorInvalidTextureBinding       : exception;
   ErrorInvalidChannelDescriptor    : exception;
   ErrorInvalidMemcpyDirection      : exception;
   ErrorAddressOfConstant           : exception;
   ErrorTextureFetchFailed          : exception;
   ErrorTextureNotBound             : exception;
   ErrorSynchronizationError        : exception;
   ErrorInvalidFilterSetting        : exception;
   ErrorInvalidNormSetting          : exception;
   ErrorMixedDeviceExecution        : exception;
   ErrorNotYetImplemented           : exception;
   ErrorMemoryValueTooLarge         : exception;
   ErrorInsufficientDriver          : exception;
   ErrorInvalidSurface              : exception;
   ErrorDuplicateVariableName       : exception;
   ErrorDuplicateTextureName        : exception;
   ErrorDuplicateSurfaceName        : exception;
   ErrorDevicesUnavailable          : exception;
   ErrorIncompatibleDriverContext   : exception;
   ErrorMissingConfiguration        : exception;
   ErrorPriorLaunchFailure          : exception;
   ErrorLaunchMaxDepthExceeded      : exception;
   ErrorLaunchFileScopedTex         : exception;
   ErrorLaunchFileScopedSurf        : exception;
   ErrorSyncDepthExceeded           : exception;
   ErrorLaunchPendingCountExceeded  : exception;
   ErrorInvalidDeviceFunction       : exception;
   ErrorNoDevice                    : exception;
   ErrorInvalidDevice               : exception;
   ErrorStartupFailure              : exception;
   ErrorInvalidKernelImage          : exception;
   ErrorDeviceUninitialized         : exception;
   ErrorMapBufferObjectFailed       : exception;
   ErrorUnmapBufferObjectFailed     : exception;
   ErrorArrayIsMapped               : exception;
   ErrorAlreadyMapped               : exception;
   ErrorNoKernelImageForDevice      : exception;
   ErrorAlreadyAcquired             : exception;
   ErrorNotMapped                   : exception;
   ErrorNotMappedAsArray            : exception;
   ErrorNotMappedAsPointer          : exception;
   ErrorECCUncorrectable            : exception;
   ErrorUnsupportedLimit            : exception;
   ErrorDeviceAlreadyInUse          : exception;
   ErrorPeerAccessUnsupported       : exception;
   ErrorInvalidPtx                  : exception;
   ErrorInvalidGraphicsContext      : exception;
   ErrorNvlinkUncorrectable         : exception;
   ErrorJitCompilerNotFound         : exception;
   ErrorInvalidSource               : exception;
   ErrorFileNotFound                : exception;
   ErrorSharedObjectSymbolNotFound  : exception;
   ErrorSharedObjectInitFailed      : exception;
   ErrorOperatingSystem             : exception;
   ErrorInvalidResourceHandle       : exception;
   ErrorIllegalState                : exception;
   ErrorSymbolNotFound              : exception;
   ErrorNotReady                    : exception;
   ErrorIllegalAddress              : exception;
   ErrorLaunchOutOfResources        : exception;
   ErrorLaunchTimeout               : exception;
   ErrorLaunchIncompatibleTexturing : exception;
   ErrorPeerAccessAlreadyEnabled    : exception;
   ErrorPeerAccessNotEnabled        : exception;
   ErrorSetOnActiveProcess          : exception;
   ErrorContextIsDestroyed          : exception;
   ErrorAssert                      : exception;
   ErrorTooManyPeers                : exception;
   ErrorHostMemoryAlreadyRegistered : exception;
   ErrorHostMemoryNotRegistered     : exception;
   ErrorHardwareStackError          : exception;
   ErrorIllegalInstruction          : exception;
   ErrorMisalignedAddress           : exception;
   ErrorInvalidAddressSpace         : exception;
   ErrorInvalidPc                   : exception;
   ErrorLaunchFailure               : exception;
   ErrorCooperativeLaunchTooLarge   : exception;
   ErrorNotPermitted                : exception;
   ErrorNotSupported                : exception;
   ErrorSystemNotReady              : exception;
   ErrorSystemDriverMismatch        : exception;
   ErrorCompatNotSupportedOnDevice  : exception;
   ErrorStreamCaptureUnsupported    : exception;
   ErrorStreamCaptureInvalidated    : exception;
   ErrorStreamCaptureMerge          : exception;
   ErrorStreamCaptureUnmatched      : exception;
   ErrorStreamCaptureUnjoined       : exception;
   ErrorStreamCaptureIsolation      : exception;
   ErrorStreamCaptureImplicit       : exception;
   ErrorCapturedEvent               : exception;
   ErrorStreamCaptureWrongThread    : exception;
   ErrorTimeout                     : exception;
   ErrorGraphExecUpdateFailure      : exception;
   ErrorUnknown                     : exception;
   ErrorApiFailureBase              : exception;

end CUDA;

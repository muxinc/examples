/**
 * DEBUGGING
 */
// https://developers.google.com/cast/docs/debugging/cast_debug_logger
const castDebugLogger = cast.debug.CastDebugLogger.getInstance();
const LOG_TAG = 'MUX';
castDebugLogger.setEnabled(true);

// Debug overlay on tv screen. You don't need this if you're debugging using the cast tool (https://casttool.appspot.com/cactool) as it will show the logs in your browser.
castDebugLogger.showDebugLogs(true);

castDebugLogger.loggerLevelByTags = {
    [LOG_TAG]: cast.framework.LoggerLevel.DEBUG,
};

/**
 * DRM SUPPORT
 */
context.getPlayerManager().setMediaPlaybackInfoHandler((loadRequest, playbackConfig) => {
    const customData = loadRequest.media.customData || {};

    if (customData.mux && customData.mux.tokens.drm) {
        castDebugLogger.debug(LOG_TAG, 'Setting license URL.');
        playbackConfig.licenseUrl = `https://license.mux.com/license/widevine/${customData.mux.playbackId}?token=${customData.mux.tokens.drm}`;
    }

    playbackConfig.protectionSystem = cast.framework.ContentProtection.WIDEVINE;

    castDebugLogger.debug(LOG_TAG, 'license url', playbackConfig.licenseUrl);

    return playbackConfig;
});

/**
 * START LISTENING FOR CASTS
 */
context.start();
function playVideo(context) {
    const playbackId = '...';
    const playbackToken = '...';
    const drmToken = '...';
    const mediaUrl = `https://stream.mux.com/${playbackId}.m3u8?token=${playbackToken}`;
    let mediaInfo = new chrome.cast.media.MediaInfo(mediaUrl, 'application/x-mpegurl');

    // Mux HLS URLs with DRM will always use `fmp4` segments.
    mediaInfo.hlsSegmentFormat = chrome.cast.media.HlsSegmentFormat.FMP4;
    mediaInfo.hlsVideoSegmentFormat = chrome.cast.media.HlsVideoSegmentFormat.FMP4;

    // Send the information needed to create a new license url.
    mediaInfo.customData = {
        mux: {
            playbackId,
            tokens: {
                drm: drmToken
            }
        }
    }

    const request = new chrome.cast.media.LoadRequest(mediaInfo);

    // Cast the video.
    context.getCurrentSession().loadMedia(request).then(() => {
        console.log('Load Succeeded');
    }).catch((err) => {
        console.log(`Error code: ${errorCode}`);
    });
}
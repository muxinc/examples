type VideoViewEvent = {
  "serverTime": {
    "seconds": number;
    "nanos": number;
  }
  "viewerTime": {
    "seconds": number;
    "nanos": number;
  }
  "playheadTime": {
    "seconds"?: number;
    "nanos"?: number;
  }
  "type": string;
  "sequenceNumber": number;
  "renditionInfo"?: {
    "width": number;
    "height": number;
    "bitrate": number;
  }
};

type VideoView = {
  "viewId": string;
  "propertyId": string;
  "viewStart": {
    "seconds": number;
    "nanos": number;
  },
  "viewEnd": {
    "seconds": number;
    "nanos": number;
  },
  "events": VideoViewEvent[];
  "asn": number;
  "browser": string;
  "browserVersion": string;
  "cdn": string;
  "continentCode": string;
  "country": string;
  "countryName": string;
  "exitBeforeVideoStart": boolean;
  "latitude": number;
  "longitude": number;
  "maxDownscalePercentage": number;
  "maxUpscalePercentage": number;
  "muxApiVersion": string;
  "muxEmbedVersion": string;
  "muxViewerId": string;
  "operatingSystem": string;
  "operatingSystemVersion": string;
  "pageLoadTime": number;
  "pageUrl": string;
  "playbackSuccessScore": number;
  "playerAutoplay": boolean;
  "playerHeight": number;
  "playerInstanceId": string;
  "playerMuxPluginName": string;
  "playerMuxPluginVersion": string;
  "playerPoster": string;
  "playerPreload": true,
  "playerSoftware": string;
  "playerSoftwareVersion": string;
  "playerSourceDomain": string;
  "playerSourceDuration": number;
  "playerSourceHeight": number;
  "playerSourceUrl": string;
  "playerSourceWidth": number;
  "playerStartupTime": number;
  "playerViewCount": number;
  "playerWidth": number;
  "region": string;
  "sessionId": string;
  "smoothnessScore": number;
  "sourceHostname": string;
  "sourceType": string;
  "startupTimeScore": number;
  "videoEncodingVariant": string;
  "videoId": string;
  "videoQualityScore": number;
  "videoStartupTime": number;
  "videoTitle": string;
  "viewMaxPlayheadPosition": number;
  "viewPlayingTime": number;
  "viewSeekCount": number;
  "viewSeekDuration": number;
  "viewTotalContentPlaybackTime": number;
  "viewTotalDownscaling": number;
  "viewTotalUpscaling": number;
  "viewerDeviceCategory": string;
  "viewerDeviceManufacturer": string;
  "viewerExperienceScore": number;
  "viewerUserAgent": string;
  "viewerUserId": string;
  "watchTime": number;
  "watched": true,
  "weightedAverageBitrate": number;
  "streamType": string;
  "assetId": string;
  "playbackId": string;
  "environmentId": string;
}

export default VideoView;
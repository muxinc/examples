let mediaRecorder;
let mediaStream;
let nextByteStart = 0;
const CHUNK_SIZE = 8 * 1024 * 1024; // 8MB chunks, must be multiple of 256KB
const maxRetries = 3;
const lockName = 'uploadLock';
let activeUploads = 0;
let isFinalizing = false;

// DOM Elements
const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const logArea = document.getElementById('log');
const videoPreview = document.getElementById('preview');
const uploadUrlInput = document.getElementById('uploadUrl');

/**
 * Logs messages to the log area with a timestamp and color coding.
 * @param {string} message - The message to log.
 * @param {string} type - The type of log ('chunk', 'buffer', 'upload', 'error', 'info').
 */
function log(message, type = 'info') {
  const timestamp = new Date().toLocaleTimeString();
  const logEntry = document.createElement('div');
  logEntry.className = `log-${type}`;
  
  const timestampSpan = document.createElement('span');
  timestampSpan.className = 'timestamp';
  timestampSpan.textContent = `[${timestamp}] `;
  
  logEntry.appendChild(timestampSpan);
  logEntry.appendChild(document.createTextNode(message));
  
  logArea.appendChild(logEntry);
  logArea.scrollTop = logArea.scrollHeight;
}

/**
 * Gets the current upload URL from the input field
 * @returns {string} The upload URL
 * @throws {Error} If no URL is provided
 */
function getUploadUrl() {
  const url = uploadUrlInput.value.trim();
  if (!url) {
    throw new Error('Please enter an upload URL before starting the recording');
  }
  return url;
}

/**
 * Adds detailed browser console logging.
 * @param {string} message - The message to log.
 * @param {any} data - Optional data to log.
 */
function debugLog(message, data = null) {
  const timestamp = new Date().toLocaleTimeString();
  console.log(`[${timestamp}] ${message}`, data || '');
  log(message);
}

/**
 * Starts media recording.
 */
async function startRecording() {
  try {
    // Validate upload URL first
    try {
      getUploadUrl();
    } catch (error) {
      debugLog(`URL Error: ${error.message}`);
      return;
    }

    // Define video constraints
    const constraints = {
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        sampleRate: 44100,
        channelCount: 2
      },
      video: {
        width: { ideal: 1280 },
        height: { ideal: 720 },
        frameRate: { ideal: 30 },
        facingMode: 'user'
      }
    };

    debugLog('Requesting media stream with constraints:', constraints);
    
    // Get the user's media stream with constraints
    mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
    debugLog('Media stream obtained:', mediaStream.getTracks().map(track => ({
      kind: track.kind,
      label: track.label,
      settings: track.getSettings()
    })));

    // Show the preview
    videoPreview.srcObject = mediaStream;

    // Detect if mobile device
    const isMobileDevice = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    
    // Set video bitrate based on device type
    const videoBitrate = isMobileDevice ? 1000000 : 5000000; // 1Mbps for mobile, 5Mbps for desktop
    debugLog(`Using video bitrate: ${videoBitrate}bps for ${isMobileDevice ? 'mobile' : 'desktop'} device`);

    // Modify MIME type stack
    const MIME_TYPE_STACK = [
      'video/webm;codecs=vp8,opus',  // Try WebM first
      'video/webm',
      'video/mp4;codecs=avc1,mp4a.40.2',
      'video/mp4'
    ];

    // Determine supported MIME type with more detailed testing
    debugLog('Testing MIME types:', MIME_TYPE_STACK);
    
    let supportedMimeType = null;
    for (const mimeType of MIME_TYPE_STACK) {
      const isSupported = MediaRecorder.isTypeSupported(mimeType);
      debugLog(`Testing ${mimeType}:`, {
        isSupported,
        mediaRecorder: typeof MediaRecorder !== 'undefined',
        platform: navigator.platform,
        userAgent: navigator.userAgent
      });
      
      if (isSupported) {
        supportedMimeType = mimeType;
        break;
      }
    }

    if (!supportedMimeType) {
      throw new Error('No supported MIME type found for MediaRecorder.');
    }
    debugLog(`Selected MIME type: ${supportedMimeType}`);

    // Create MediaRecorder
    mediaRecorder = new MediaRecorder(mediaStream, {
      mimeType: supportedMimeType,
      videoBitsPerSecond: videoBitrate,
      audioBitsPerSecond: 128000
    });
    debugLog('MediaRecorder initial state:', mediaRecorder.state);

    // Initialize buffer variables
    let buffer = new Blob([], { type: supportedMimeType });
    let bufferSize = 0;
    let totalBytesReceived = 0;

    mediaRecorder.ondataavailable = async (event) => {
      if (event.data.size > 0 && !isFinalizing) {
        // Log chunk collection
        const chunkSizeMB = (event.data.size / (1024 * 1024)).toFixed(2);
        log(`Received chunk: ${chunkSizeMB}MB`, 'chunk');
        
        // Immediately process the chunk
        buffer = new Blob([buffer, event.data], { type: supportedMimeType });
        bufferSize += event.data.size;
        totalBytesReceived += event.data.size;

        // Log buffer progress
        const bufferPercent = ((bufferSize / CHUNK_SIZE) * 100).toFixed(1);
        const bufferMB = (bufferSize / (1024 * 1024)).toFixed(2);
        const chunkSizeMBFormatted = (CHUNK_SIZE / (1024 * 1024)).toFixed(2);
        
        log(`Buffer: ${bufferMB}MB / ${chunkSizeMBFormatted}MB (${bufferPercent}% full)`, 'buffer');
        log(`Total received: ${(totalBytesReceived / (1024 * 1024)).toFixed(2)}MB`, 'buffer');

        // Process buffer if it's large enough
        while (bufferSize >= CHUNK_SIZE) {
          const chunk = buffer.slice(0, CHUNK_SIZE);
          const chunkSize = chunk.size;

          log(`Buffer full! Uploading ${(chunkSize / (1024 * 1024)).toFixed(2)}MB chunk...`, 'upload');

          // Update buffer
          buffer = buffer.slice(CHUNK_SIZE);
          bufferSize -= CHUNK_SIZE;

          // Upload chunk
          await uploadChunk(chunk, nextByteStart, false);
          nextByteStart += chunkSize;

          // Log remaining buffer after upload
          if (bufferSize > 0) {
            const remainingMB = (bufferSize / (1024 * 1024)).toFixed(2);
            const remainingPercent = ((bufferSize / CHUNK_SIZE) * 100).toFixed(1);
            log(`Remaining buffer: ${remainingMB}MB (${remainingPercent}% of next chunk)`, 'buffer');
          } else {
            log('Buffer empty - waiting for more data...', 'buffer');
          }
        }
      }
    };

    // Add error handler
    mediaRecorder.onerror = (event) => {
      log(`MediaRecorder error: ${event.error}`, 'error');
    };

    // Handle recording stop
    mediaRecorder.onstop = async () => {
      try {
        log('Recording stopped. Waiting for pending uploads...', 'info');
        isFinalizing = true;

        // Wait for any in-progress uploads to complete
        while (activeUploads > 0) {
          await new Promise(resolve => setTimeout(resolve, 100));
        }

        if (buffer.size > 0) {
          log('Uploading final chunk...', 'info');
          const success = await uploadChunk(buffer, nextByteStart, true);
          if (success) {
            nextByteStart += buffer.size;
            buffer = new Blob([], { type: supportedMimeType });
            bufferSize = 0;
            log('All chunks uploaded successfully.', 'info');
          } else {
            log('Failed to upload final chunk.', 'error');
          }
        } else {
          log('No final chunk needed. All chunks uploaded.', 'info');
        }
      } catch (error) {
        log(`Error during final upload: ${error.message}`, 'error');
      } finally {
        isFinalizing = false;
        // Clean up media stream
        if (mediaStream) {
          mediaStream.getTracks().forEach((track) => track.stop());
          videoPreview.srcObject = null;
        }
      }
    };

    // Start recording
    debugLog('Starting MediaRecorder with 1000ms timeslice');
    mediaRecorder.start(500); // Get data every 500ms
    debugLog('MediaRecorder state after start:', mediaRecorder.state);

    log('Recording started - collecting chunks every 500ms', 'info');
    startBtn.disabled = true;
    stopBtn.disabled = false;
  } catch (error) {
    debugLog('Recording error:', error);
    log(`Error starting recording: ${error.message}`, 'error');
  }
}

/**
 * Stops media recording.
 */
function stopRecording() {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop();
    log('Stopping recording...', 'info');
    startBtn.disabled = false;
    stopBtn.disabled = true;
  }
}

/**
 * Uploads a chunk to the server with retry logic.
 * @param {Blob} chunk - The media chunk to upload.
 * @param {number} byteStart - The starting byte position of the chunk.
 * @param {boolean} isFinalChunk - Whether this is the final chunk.
 */
async function uploadChunk(chunk, byteStart, isFinalChunk) {
  // If this is the final chunk, wait for other uploads to complete
  if (isFinalChunk) {
    while (activeUploads > 0) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
  }

  const byteEnd = byteStart + chunk.size - 1;
  const totalSize = isFinalChunk ? byteEnd + 1 : '*';

  const headers = {
    'Content-Length': chunk.size.toString(),
    'Content-Range': `bytes ${byteStart}-${byteEnd}/${totalSize}`,
  };

  let attempt = 0;
  let success = false;

  try {
    // Increment active uploads counter
    activeUploads++;

    // Use Web Locks API to ensure sequential uploads
    await navigator.locks.request(lockName, async (lock) => {
      while (attempt < maxRetries && !success) {
        try {
          const response = await fetch(getUploadUrl(), {
            method: 'PUT',
            headers,
            body: chunk,
          });

          if (response.status === 308 || response.ok) {
            success = true;
            log(`Chunk ${byteStart}-${byteEnd} uploaded successfully. Status: ${response.status}`, 'info');
            if (isFinalChunk && response.ok) {
              log('Final chunk uploaded. Upload complete.', 'info');
            }
          } else {
            throw new Error(`Upload failed with status: ${response.status}`);
          }
        } catch (error) {
          attempt++;
          log(`Chunk upload failed (attempt ${attempt}): ${error.message}`, 'error');
          if (attempt < maxRetries) {
            const delay = attempt * 1000;
            log(`Retrying in ${delay / 1000} seconds...`, 'info');
            await new Promise(resolve => setTimeout(resolve, delay));
          } else {
            throw error;
          }
        }
      }
    });
  } catch (error) {
    log('Max retries reached. Upload failed.', 'error');
    if (!isFinalChunk) {
      stopRecording();
    }
  } finally {
    // Decrement active uploads counter
    activeUploads--;
  }

  return success;
}

// Event Listeners
startBtn.addEventListener('click', startRecording);
stopBtn.addEventListener('click', stopRecording);

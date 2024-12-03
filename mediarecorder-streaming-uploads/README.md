# Mux MediaRecorder Streaming Uploads Example

This project demonstrates how to record video using the MediaRecorder API, process the data into chunks, and upload the chunks to a specified server in real-time as they are recorded.

## Features

- Real-time Video Recording: Records video directly from the user's webcam or mobile device.
- Chunked Uploads: Processes recorded data into 8MB chunks (configurable) for efficient uploads.
- Retry Logic: Retries failed uploads with exponential backoff for resilience.
- Web Locks API Integration: Ensures chunks are uploaded sequentially without overlap.
- Visual Feedback: Logs upload progress, buffer sizes, and errors in a scrolling log area.

## Setup

### Prerequisites

- A Mux [Direct Upload URL](https://docs.mux.com/guides/upload-files-directly)
- A modern browser that supports the MediaRecorder API and `navigator.mediaDevices`.

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/muxinc/examples.git
   cd examples/media-recorder-streaming-uploads
   ```

2. Run a basic server to host the example:
   ```bash
   npx serve
   ```

3. Provide a valid direct upload URL in the input field.

4. Start recording by clicking the Start Recording button.

5. Stop recording by clicking the Stop Recording button.

## How it works

### 1. Start Recording
- The app requests access to the user's webcam and microphone.
- Initializes the MediaRecorder with the appropriate MIME type and bitrate.
- Begins recording data in chunks every 500ms.

```javascript
mediaRecorder.start(500); // Collect chunks every 500ms
```

### 2. Chunk Processing

- Each chunk is buffered until the size exceeds CHUNK_SIZE (8MB by default).
- When the buffer is full, the chunk is uploaded to the server.
- If there is remaining data after a chunk upload, it stays in the buffer for the next chunk.

### 3. Uploading with Retry Logic
- Chunks are uploaded using PUT requests with Content-Range headers to indicate byte ranges.
- Failed uploads are retried up to 3 times with exponential backoff.
- The Web Locks API is used to ensure that chunks are uploaded sequentially without overlap.

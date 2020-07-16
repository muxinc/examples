import { useEffect, useRef, useState, useCallback } from 'react'
import Router from 'next/router'
import * as UpChunk from '@mux/upchunk'
import useSwr from 'swr'
import {useDropzone} from 'react-dropzone'
import Button from './button'
import Spinner from './spinner'
import ErrorMessage from './error-message'

const fetcher = (url) => {
  return fetch(url).then((res) => res.json())
}

const UploadForm = () => {
  const [isUploading, setIsUploading] = useState(false)
  const [isPreparing, setIsPreparing] = useState(false)
  const [uploadId, setUploadId] = useState(null)
  const [progress, setProgress] = useState(null)
  const [errorMessage, setErrorMessage] = useState('')
  const inputRef = useRef(null)

  const { data, error } = useSwr(
    () => (isPreparing ? `/api/upload/${uploadId}` : null),
    fetcher,
    { refreshInterval: 5000 }
  )

  const upload = data && data.upload

  const startUpload = (file) => {
    if (isUploading) {
      console.warn('already uploading');
      return
    }

    setIsUploading(true)
    const upload = UpChunk.createUpload({
      endpoint: createUpload,
      file,
    })

    upload.on('error', (err) => {
      setErrorMessage(err.detail)
    })

    upload.on('progress', (progress) => {
      setProgress(Math.floor(progress.detail))
    })

    upload.on('success', () => {
      setIsPreparing(true)
    })
  }

  const onDrop = useCallback(acceptedFiles => {
    if (acceptedFiles && acceptedFiles[0]) {
      startUpload(acceptedFiles[0]);
    } else {
      console.warn('got a drop event but no file');
    }
  }, [])

  const {getRootProps, getInputProps, isDragActive} = useDropzone({onDrop})

  useEffect(() => {
    if (upload && upload.asset_id) {
      Router.push({
        pathname: `/asset/${upload.asset_id}`,
        scroll: false,
      })
    }
  }, [upload])

  if (error) return <ErrorMessage message="Error fetching api" />
  if (data && data.error) return <ErrorMessage message={data.error} />

  const createUpload = async () => {
    try {
      return fetch('/api/upload', {
        method: 'POST',
      })
        .then((res) => res.json())
        .then(({ id, url }) => {
          setUploadId(id)
          return url
        })
    } catch (e) {
      console.error('Error in createUpload', e)
      setErrorMessage('Error creating upload')
    }
  }

  const onInputChange = (evt) => {
    startUpload(inputRef.current.files[0])
  }

  if (errorMessage) return <ErrorMessage message={errorMessage} />

  return (
    <>
      <div className="container">
        {isUploading ? (
          <>
            {isPreparing ? (
              <div>Preparing..</div>
            ) : (
              <div>Uploading...{progress ? `${progress}%` : ''}</div>
            )}
            <Spinner />
          </>
        ) : (
          <div {...getRootProps()} className={`drop-area ${isDragActive ? 'active' : '' }`}>
            <label>
              <Button type="button" onClick={() => inputRef.current.click()}>
                Select a video file
              </Button>
              <input type="file" {...getInputProps()} onChange={onInputChange} ref={inputRef} />
            </label>
            <p>(or drag a video file)</p>
          </div>
        )}
      </div>
      <style jsx>{`
        input {
          display: none;
        }
        .drop-area {
          padding: 30px 80px;
          display: inline-block;
          transition: background-color 0.1s linear;
        }
        .drop-area.active {
          background: #ffe5e5
        }
        p {
          margin-bottom: 0;
        }
      `}</style>
    </>
  )
}

export default UploadForm

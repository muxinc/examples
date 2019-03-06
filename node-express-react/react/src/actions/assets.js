import { API_URL, get, put, post } from '../utils/base_api';

export const getAssets = () => get(`${API_URL}/mux-assets`);

export const getPreSignedUrl = filename => get(`${API_URL}/pre-signed-url?filename=${filename}`);

export const uploadVideo = (signedUrl, fileData) => put(signedUrl, fileData, { headers: { 'Content-Type': 'file' } });

export const ingestVideo = fileName => post(`${API_URL}/video`, JSON.stringify({fileName}));

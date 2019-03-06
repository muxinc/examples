import fetch from 'isomorphic-fetch';
import { clearPersistedSession } from './auth';

const API_URL = process.env.API_URL || 'http://localhost:3000';

const getRequestDefaultOptions = () => ({
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
  mode: 'cors',
  credentials: 'include',
});

const makeRequest = (url, options) => {
  return fetch(url, options)
    .then(response => parseResponse(response));
};

const get = (url, options) => {
  const requestOptions = {...getRequestDefaultOptions(), ...{ method: 'GET', ...options }};
  return makeRequest(url, requestOptions);
};

const post = (url, body, options) => {
  const requestOptions = {...getRequestDefaultOptions(), ...{ method: 'POST', body, ...options }};
  return makeRequest(url, requestOptions);
};

const del = (url, options) => {
  const requestOptions = {...getRequestDefaultOptions(), ...{ method: 'DELETE', ...options }};
  return makeRequest(url, requestOptions);
};

const put = (url, body, options) => {
  const requestOptions = {...getRequestDefaultOptions(), ...{ method: 'PUT', body, ...options }};
  return makeRequest(url, requestOptions);
};

const parseResponse = (response) => {
  if (response.status === 401) {
    clearPersistedSession();
    window.location = '/login';
  }
  if (response.status >= 400) {
    throw new Error("Bad response from server");
  }

  return response.text()
    .then((text) => text ? JSON.parse(text) : {});
};

export {
  get,
  post,
  put,
  del,
  API_URL,
}

import { API_URL, get } from '../utils/base_api';
import { clearPersistedSession, persistSession } from '../utils/auth';
import * as io from "socket.io-client";

export const joinRoom = (userId) => {
  const socket = io(API_URL);
  socket.on('connect', () => {
    socket.emit('user_join', userId);
  });

  return socket;
};

export const loginUser = () => (
  getSession()
    .then(res => {
      const user = res.session.user;
      persistSession(user);
    })
);

export const logoutUser = () => (
  get(`${API_URL}/logout`, { mode: 'no-cors' })
    .then(() => clearPersistedSession())
);

export const getSession = () =>  get(`${API_URL}/session`);

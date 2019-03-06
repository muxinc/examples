
const SESSION_STORAGE_KEY = 'sessionData';

const persistSession = session => localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));

const getPersistedSession = () => JSON.parse(localStorage.getItem(SESSION_STORAGE_KEY));

const hasPersistedSession = () => !!localStorage.getItem(SESSION_STORAGE_KEY);

const clearPersistedSession = () => localStorage.removeItem(SESSION_STORAGE_KEY);


export {
  persistSession,
  getPersistedSession,
  hasPersistedSession,
  clearPersistedSession,
}

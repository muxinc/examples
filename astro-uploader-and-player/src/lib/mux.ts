import Mux from '@mux/mux-node';

const mux = new Mux({
  tokenId: import.meta.env.MUX_TOKEN_ID,
  tokenSecret: import.meta.env.MUX_TOKEN_SECRET,
});

export default mux;

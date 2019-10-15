const keySecret = process.env.MUX_PRIVATE_KEY
import { signPlaybackId } from '../src/mux_signatures';

exports.handler = async (event, context) => {
  try {
    const { queryStringParameters } = event;
    const { playbackId } = queryStringParameters;
    if (!playbackId) {
      return { statusCode: 400, body: JSON.stringify({errors: [{message: 'Missing playbackId in query string'}]}) };
    }
    const token = await signPlaybackId(playbackId);
    return  {
      statusCode: 302,
      headers: {
        'Access-Control-Allow-Origin': '*',
        location: `https://stream.mux.com/${playbackId}.m3u8?token=${token}`
      },
      body: '',
    }
  } catch (e) {
    console.error(e);
    return { statusCode: 500, body: JSON.stringify({ errors: [{message: 'Server Error'}] }) };
  }
}

const Mux = require('@mux/mux-node');
const { Video } = new Mux(process.env.MUX_ACCESS_TOKEN, process.env.MUX_SECRET);
const { JWT } = Mux;

exports.handler = async (event) => {

    // only allow POST requests
    if (event.httpMethod !== 'POST') {
        return { statusCode: 405 };
    }

    const playbackId = event.body.playbackId;
    const playbackType = event.body.type || 'video';
    // query params to be used for playback
    const params = event.body.params || {};

    // A playback ID is required to generate a signed url
    if (!playbackId) {
        return {
            statusCode: 400,
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ message: '`playbackId` is required to generate signed url' }),
        };
    }

    const data = await Video.SigningKeys.create();

    const token = JWT.sign(playbackId, {
        keyId: data.id,
        keySecret: data.private_key,
        type: playbackType,
        // expiration expressed in seconds or a string describing a time span [zeit/ms](https://github.com/zeit/ms).
        expiration: '7d',
        params,
    });

    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            playbackId,
            token,
            signedUrl: `https://stream.mux.com/${playbackId}.m3u8?token=${token}`,
        }),
    };
};

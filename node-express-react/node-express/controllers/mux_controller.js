const Mux = require('@mux/mux-node');
const muxClient = new Mux(process.env.MUX_ACCESS_TOKEN, process.env.MUX_SECRET);
const { Video } = muxClient;

const db = require('../db/api');
const { s3_bucket_name, s3_url } = require('../config/config');

const postVideo = (req, res, next) => {
  const { fileName } = req.body;
  const { id } = req.user;
  ingestAsset(fileName, id, (err, muxResponse) => {
    if (err) {
      return next(err);
    }
    return res.status(200).send({ message: muxResponse });
  });
};

const getUserAssets = (req, res, next) => {
  const { id } = req.user;
  getAssetsForUser(id, (err, assetResponse) => {
    if (err) {
      return next(err);
    }
    return res.status(200).send({ data: assetResponse });
  });
};

const processMuxAsset = (req, res, next, io) => {
  const { data } = req.body;
  updateAsset(data, (error, response) => {
    let socketMessage = JSON.stringify(response);
    if (error) {
      socketMessage = JSON.stringify({ error });
    }
    return getAsset(data.id, (err, res) => {
      io.to(res.google_id).emit('asset-updated', socketMessage);
    });
  });
  return res.status(200).send({ status: 200 });
};

// Private controller functions
const ingestAsset = (fileName, googleId, cb) => {
  const ingestUrl = `${s3_url}/${s3_bucket_name}/${fileName}`;
  Video.assets.create({ input: ingestUrl })
    .then((muxResponse) => {
      const { data } = muxResponse;
      createAssetEntry(data, googleId, (err, res) => cb(err, res));
    })
    .catch((err, muxResponse) => {
      return cb(err, muxResponse);
    });
};

// Database interactors
const createAssetEntry = (assetData, googleId, cb) => (
  db.createAsset(assetData, googleId)
    .then(res => cb(null, res))
    .catch((err, res) =>  cb(err, res))
);

const getAssetsForUser = (googleId, cb) => (
  db.findAssetsByUserId(googleId)
    .then(assets => cb(null, assets))
    .catch(err => cb(err, null))
);

const updateAsset = (assetData, cb) => (
  db.updateAsset(assetData)
    .then(res => cb(null, res))
    .catch(err => cb(err, assetData))
);

const getAsset = (assetId, cb) => (
  db.getAsset(assetId)
    .then(res => cb(null, res))
    .catch(err => cb(err, assetId))
);

module.exports = {
  postVideo,
  getUserAssets,
  processMuxAsset,
};

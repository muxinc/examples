const AWS = require('aws-sdk');

const {
  aws_region,
  s3_url, s3_bucket_name } = require('../config/config');

AWS.config.update({
  region: aws_region,
  endpoint: s3_url,
  accessKeyId: process.env.AWS_ACCESS_KEY,
  secretAccessKey: process.env.AWS_SECRET_KEY,
});

const s3 = new AWS.S3({ signatureVersion: 'v4' });
const signedUrlExpireSeconds = 60 * 10;

const getPreSignedUrlForVideo = (req, res, next) => {
  getPreSignedUrl(req.query.filename, (err, url) => {
    if (err) {
      return next(err);
    }
    return res.status(200).send({ url });
  });
};

const getPreSignedUrl = (filename, cb) => {
  return s3.getSignedUrl('putObject', {
    Bucket: s3_bucket_name,
    Key: filename,
    Expires: signedUrlExpireSeconds,
    ACL: 'public-read',
  },(err, url) => cb(err, url));
};

module.exports = {
  getPreSignedUrlForVideo,
};

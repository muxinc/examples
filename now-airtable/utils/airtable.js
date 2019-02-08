const Airtable = require('airtable');
const { invert } = require('lodash');

Airtable.configure({
  endpointUrl: 'https://api.airtable.com',
  apiKey: process.env.AIRTABLE_TOKEN,
});

const base = Airtable.base(process.env.AIRTABLE_BASE);

const TABLE_NAME = 'Videos';

const schemaMap = {
  title: 'Title',
  description: 'Description',
  uploadId: 'Upload ID',
  assetId: 'Asset ID',
  playbackId: 'Playback ID',
  status: 'Status',
  uploadUrl: 'Upload URL',
};

const view = item => ({
  id: item.getId(),
  ...translateSchemaFromAirtable(item.fields),
});

const translateSchemaToAirtable = obj =>
  Object.keys(obj).reduce((result, key) => {
    result[schemaMap[key]] = obj[key];

    return result;
  }, {});

const translateSchemaFromAirtable = obj => {
  const invertedSchemaMap = invert(schemaMap);

  return Object.keys(obj).reduce((result, key) => {
    result[invertedSchemaMap[key]] = obj[key];

    return result;
  }, {});
};

const getVideo = async id => {
  const video = await base(TABLE_NAME).find(id);

  return view(video);
};

const createVideo = async params => {
  const translatedObj = translateSchemaToAirtable(params);
  const createdVideo = await base(TABLE_NAME).create(translatedObj);

  return view(createdVideo);
};

const updateVideo = async (id, update) => {
  const translatedObj = translateSchemaToAirtable(update);
  const updatedVideo = await base(TABLE_NAME).update(id, translatedObj);

  return view(updatedVideo);
};

const listVideos = async page => {
  let videos = [];

  await base(TABLE_NAME)
    .select({ sort: [{ field: 'ID', direction: 'desc' }] })
    .eachPage((records, fetchNextPage) => {
      console.log(records);
      videos = [...videos, ...records.map(view)];

      fetchNextPage();
    });

  return videos;
};

module.exports = { createVideo, getVideo, updateVideo, listVideos };

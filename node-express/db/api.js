const knex = require('./knex');

module.exports = {
  findUserById: googleId => (
    knex('users')
      .select()
      .where({ google_id: googleId })
      .first()
  ),

  createUser: googleId => (
    knex('users')
      .insert({ google_id: googleId })
  ),

  findAssetsByUserId: googleId => (
    knex('assets')
      .select()
      .where({ google_id: googleId })
      .orderBy('id', 'asc')
  ),

  getAsset: assetId => (
    knex('assets')
      .select()
      .where({ asset_id: assetId })
      .first()
  ),

  createAsset: (assetData, googleId) => {
    const {
      duration,
      playback_ids,
      created_at,
      aspect_ratio,
      status,
    } = assetData;

    return knex('assets')
      .insert({
        google_id: googleId,
        asset_id: assetData.id,
        duration,
        playback_ids,
        aspect_ratio,
        created_at,
        status,
      });
  },

  updateAsset: (assetData) => {
    const {
      duration,
      playback_ids,
      aspect_ratio,
      status,
    } = assetData;

    return knex('assets')
      .where({ asset_id: assetData.id })
      .update({
        duration,
        playback_ids,
        aspect_ratio,
        status,
      });
  },
};

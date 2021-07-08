
exports.up = (knex) => {
  return knex.schema.createTable('assets', (table) => {
    table.increments('id').unsigned().primary();
    table.string('asset_id');
    table.string('google_id');
    table.integer('created_at');
    table.string('status');
    table.double('duration');
    table.string('aspect_ratio');
    table.specificType('playback_ids', 'jsonb[]');
  });
};

exports.down = (knex) => knex.schema.dropTable('assets');

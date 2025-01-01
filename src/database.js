// database.js
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost', // O 127.0.0.1 si prefieres
  database: 'anc',
  password: 'kiritokun',
  port: 5432, // Puerto predeterminado para PostgreSQL
});

module.exports = pool;

const lowdb = require('lowdb');
const fs = require('lowdb/adapters/FileSync');

const adapter = new fs('db.json')

const db = lowdb(adapter);

module.exports = db;

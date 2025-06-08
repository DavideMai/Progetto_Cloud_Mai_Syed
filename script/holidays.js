const mongoose = require('mongoose');

const holidays_schema = new mongoose.Schema({
    Date: String,
    Name: String,
    Type: String,
    CountryCode: String,
    CountryName: String,
    comprehend_analysis: mongoose.Schema.Types.Mixed
  }, { collection: 'holidays' });

  module.exports = mongoose.model('holidays', holidays_schema);
const mongoose = require('mongoose');

const related_schema = new mongoose.Schema({
    _id: String,
    title: String,
    url: String,
    description: String,
    speakers: String,
    watch_next_id: Array,
    watch_next_title: Array,
    comprehend_analysis: mongoose.Schema.Types.Mixed
}, { collection: 'tedx_data' });

module.exports = mongoose.model('related', related_schema);
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const yourSchema = new Schema({
    applianceName: { type: String, required: true },
    wattage: { type: Number, required: true },
    usagePattern: { type: Number, required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true }
});

module.exports = mongoose.model('Collection Schema', yourAppliance);

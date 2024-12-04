const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const compareApplianceSchema = new Schema({
    compareApplianceName: {
        type: String,
        required: true,
        unique: true
    },
    applianceCategory: {
            type: String,
            enum: [
                'Personal Devices',
                'Kitchen Appliances',
                'Cleaning & Laundry Appliances',
                'Personal Care Appliances',
                'Home Media and Office Appliances',
                'Climate and Lighting Control Appliances'
            ],
            default: 'Personal Devices',
        },
    costPerHour: {
        type: Number,
        required: true,
        min: 0
    },
    monthlyCost: {
        type: Number,
        required: true,
        min: 0
    },
    carbonEmission: {
        type: Number,
        required: true,
        min: 0
    }
});

module.exports = mongoose.model('Compare', compareApplianceSchema);
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const applianceSchema = new Schema({
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    applianceName: { type: String, required: true, trim: true },
    wattage: { type: Number, required: true },
    usagePatternPerDay: { type: Number, required: true },
    usagePatternPerWeek: { type: Number, required: false },
    selectedDays: { type: [Number], required: true },
    monthlyCost: { type: Number, default: 0 },
//    applianceCategory: {
//        type: String,
//        enum: [
//            'Personal Devices',
//            'Kitchen Appliances',
//            'Cleaning & Laundry Appliances',
//            'Personal Care Appliances',
//            'Home Media and Office Appliances',
//            'Climate and Lighting Control Appliances'
//        ],
//        default: 'Personal Devices',
//    },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: null },
    deletedAt: { type: Date, default: null },
});

applianceSchema.index({ userId: 1 });

module.exports = mongoose.model('Appliance', applianceSchema);


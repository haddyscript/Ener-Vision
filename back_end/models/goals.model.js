const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
    userId: { type: String, required: true, ref: 'User' },
    description: {
        type: String,
        required: true,
    },
    startDate: {
        type: Date,
        required: true,
    },
    endDate: {
        type: Date,
        required: true,
    },
    startTime: {
        type: String,
        required: true,
    },
    endTime: {
        type: String,
        required: true,
    },
    category: {
        type: String,
        required: true,
    },
    status: {
        type: String,
        enum: ['Accomplished', 'Pending', 'Started', 'Missed', 'Ended'],
        default: 'Pending',
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model('Goal', goalSchema);
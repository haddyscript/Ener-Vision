const express = require('express');
const router = express.Router();
const Device = require('../models/devices.model');

router.get('/category/:category', async (req, res) => {
    const category = req.params.category;
    const validCategories = ['Cooking', 'Lighting', 'Cooling', 'Entertainment', 'Laundry'];
    if (!validCategories.includes(category)) {
        return res.status(400).json({ error: 'Invalid appliance category' });
    }
    try {
        const devices = await Device.find({ applianceCategory: category });
        res.status(200).json({
            success: true,
            category: category,
            deviceCount: devices.length,
            devices: devices,
        });
    } catch (error) {
        console.error('Error fetching devices:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch devices' });
    }
});
module.exports = router;
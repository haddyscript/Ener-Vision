// energyProviders.route.js

const express = require('express');
const router = express.Router();
const EnergyProvider = require('../models/energy_provider.model');

router.get('/api/providers', async (req, res) => {
    try {
        const providers = await EnergyProvider.find({}, { providerName: 1, ratePerKwh: 1 });

        console.log('Energy providers fetched from MongoDB:', providers);

        res.status(200).json(providers);
    } catch (error) {
        console.error('Error fetching providers:', error);
        res.status(500).json({ message: 'Failed to fetch providers', error });
    }
});

module.exports = router;

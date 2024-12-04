const express = require('express');
const asyncHandler = require('../centralized_codes/authMiddleware'); // Ensure this middleware is correctly defined
const Appliance = require('../models/compared_appliance.model'); // Adjust path as necessary
const Compare = require('../models/compared_appliance.model'); // Correctly import Compare model
const router = express.Router();

router.post('/addAppliance', asyncHandler(async (req, res) => {
    try {
        const { compareApplianceName, applianceCategory, costPerHour, monthlyCost, carbonEmission } = req.body;

        // Create a new appliance instance with the provided data
        const newAppliance = new Appliance({
            compareApplianceName,
            applianceCategory,
            costPerHour,
            monthlyCost,
            carbonEmission
        });

        // Save the new appliance to the database
        await newAppliance.save();

        // Send a success response
        res.status(201).json({
            message: 'Appliance added successfully',
            appliance: newAppliance
        });
    } catch (error) {
        // Handle any errors that occur
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}));

// Route to get a compared appliance by ID
router.get('/getComparedAppliance/:compareId', asyncHandler(async (req, res) => {
    try {
        const { compareId } = req.params;
        const appliance = await Compare.findById(compareId); // Use Compare model

        if (!appliance) {
            return res.status(404).json({ message: 'Appliance not found' });
        }

        res.status(200).json(appliance);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}));

// Route to get all appliances
router.get('/getAllAppliances', asyncHandler(async (req, res) => {
    try {
        const appliances = await Appliance.find(); // Find all appliances

        if (appliances.length === 0) {
            return res.status(404).json({ message: 'No appliances found' });
        }

        res.status(200).json(appliances);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}));

module.exports = router;

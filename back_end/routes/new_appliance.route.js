const express = require('express');
const User = require('../models/user.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
const Appliance = require('../models/appliances.model');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model');
const protectedRouter = require('../routes/privateRouter');
const authenticateToken = require('../middleware'); // Import your token middleware


router.patch('/updateKwh/:userId', authenticateToken,asyncHandler(async (req, res) => {
    const userId = req.params.userId;
    const updates = req.body;
    const updateKWHRate = await User.findByIdAndUpdate(userId, updates, { new: true });
    if (!updateKWHRate) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ message: 'Users KWH  updated successfully', user: updateKWHRate });
    res.status(500).json({ message: 'Internal server error', error: err.message });
}));
router.get('/getUserKwhRate/:userId', authenticateToken , asyncHandler(async (req, res) => {
    const userId = req.params.userId;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' }); // Handle no user found
    }

    if (user.kwhRate != null && user.kwhRate !== '') {
      return res.status(200).json({ kwhRate: user.kwhRate }); // Send kwhRate if found
    } else {
      return res.status(404).json({ message: 'kwhRate not found for the user' }); // No kwhRate set
    }
    return res.status(500).json({ message: 'Failed to fetch user kwhRate', error: error.message });
}));

const saveMonthlyConsumption = async (userId, month, year) => {
    const user = await User.findById(userId);
    if (!user) {
        throw new Error('User not found');
    }

    const emissionFactor = 0.7;

    // Calculate totalMonthlyCost and gather appliance details
    const appliances = await Appliance.find({ userId });
    let totalMonthlyCost = 0;
    const applianceDetails = appliances.map(appliance => {
        totalMonthlyCost += appliance.monthlyCost || 0;
        return {
            applianceId: appliance._id,
            applianceName: appliance.applianceName,
            monthlyCost: appliance.monthlyCost || 0.0,
            wattage: appliance.wattage || 0.0,
            createdAt: appliance.createdAt
        };
    });

    // Calculate totalMonthlyKwhConsumption
    const totalMonthlyKwhConsumption = user.kwhRate > 0 ? totalMonthlyCost / user.kwhRate : 0;

    // Calculate totalMonthlyCO2Emissions
    const totalMonthlyCO2Emissions = totalMonthlyKwhConsumption * emissionFactor;

    // Check if a record for the given month and year already exists
    const existingRecord = await MonthlyConsumption.findOne({ userId, month, year });

    if (existingRecord) {
        // Update the existing record
        existingRecord.totalMonthlyConsumption = totalMonthlyCost;
        existingRecord.totalMonthlyKwhConsumption = totalMonthlyKwhConsumption;
        existingRecord.totalMonthlyCO2Emissions = totalMonthlyCO2Emissions;
        existingRecord.appliances = applianceDetails;

        await existingRecord.save();
    } else {
        // Create a new record if none exists
        const monthlyConsumption = new MonthlyConsumption({
            userId: user._id,
            month: parseInt(month, 10),
            year: parseInt(year, 10),
            totalMonthlyConsumption: totalMonthlyCost,
            totalMonthlyKwhConsumption,
            totalMonthlyCO2Emissions,
            appliances: applianceDetails
        });

        await monthlyConsumption.save();
    }
};

router.post('/addApplianceNewLogic', authenticateToken,asyncHandler(async (req, res) => {
    const { userId, applianceData } = req.body;
    const { applianceName, wattage, usagePatternPerDay, createdAt, selectedDays } = applianceData;

    if (!userId || !applianceData || !applianceName || !wattage || !usagePatternPerDay || !selectedDays) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const existingAppliance = await Appliance.findOne({ applianceName: applianceName.trim(), userId });
    if (existingAppliance) {
        return res.status(400).json({ message: 'Appliance already exists for this user.' });
    }

    if (typeof wattage !== 'number' || typeof usagePatternPerDay !== 'number') {
        return res.status(400).json({ error: 'Wattage and usage pattern must be numbers' });
    }

    if (!Array.isArray(selectedDays) || !selectedDays.every(Number.isInteger)) {
        return res.status(400).json({ error: 'Selected days must be an array of integers' });
    }

    const user = await User.findById(userId);
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const kwhRate = user.kwhRate || 0;
    const createdDate = createdAt ? new Date(createdAt) : new Date();

    const startDay = createdDate.getDate();
    const startMonth = createdDate.getMonth() + 1;
    const startYear = createdDate.getFullYear();

    const daysUsed = getRemainingOccurrences(startYear, startMonth, startDay, selectedDays);
    const totalDaysUsed = Object.values(daysUsed).reduce((sum, count) => sum + count, 0);

    const totalHoursUsed = totalDaysUsed * usagePatternPerDay;
    const energyKwh = (wattage / 1000) * totalHoursUsed;

    const monthlyCost = kwhRate * energyKwh;

    const newAppliance = new Appliance({
        applianceName: applianceName.trim(),
        wattage,
        usagePatternPerDay,
        createdAt: createdDate,
        monthlyCost,
        userId,
        selectedDays
    });

    await newAppliance.save();
    user.appliances.push(newAppliance._id);
    await user.save({ validateBeforeSave: false });

    // Call saveMonthlyConsumption here
    const currentMonth = createdDate.getMonth() + 1;
    const currentYear = createdDate.getFullYear();

    try {
        await saveMonthlyConsumption(userId, currentMonth, currentYear);
    } catch (error) {
        return res.status(500).json({ message: 'Error updating monthly consumption', error: error.message });
    }

    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
}));
router.patch('/updateApplianceOccurrences/:applianceId',authenticateToken ,asyncHandler(async (req, res) => {
    const applianceId = req.params.applianceId;
    const { updatedAt, updatedData } = req.body; // Extract updatedAt and updatedData from request body
    const { applianceName, wattage, usagePatternPerDay, selectedDays } = updatedData;

    // Validate input
    if (!applianceName || typeof applianceName !== 'string') {
        return res.status(400).json({ error: 'Appliance name is required and must be a string' });
    }

    if (!applianceId || !updatedData || !wattage || !usagePatternPerDay || !selectedDays) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    // Ensure wattage and usage pattern are numbers
    if (typeof wattage !== 'number' || typeof usagePatternPerDay !== 'number') {
        return res.status(400).json({ error: 'Wattage and usage pattern must be numbers' });
    }

    // Ensure selectedDays is an array of numbers
    if (!Array.isArray(selectedDays) || !selectedDays.every(Number.isInteger)) {
        return res.status(400).json({ error: 'Selected days must be an array of integers' });
    }

    // Find the appliance by its ID
    const appliance = await Appliance.findById(applianceId);
    if (!appliance) {
        return res.status(404).json({ error: 'Appliance not found' });
    }

    // Check the last updated date to enforce once-per-month restriction
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();
    const applianceLastUpdatedMonth = new Date(appliance.updatedAt).getMonth();
    const applianceLastUpdatedYear = new Date(appliance.updatedAt).getFullYear();

    if (applianceLastUpdatedMonth === currentMonth && applianceLastUpdatedYear === currentYear) {
        return res.status(400).json({ error: 'Appliance can only be updated once per month' });
    }

    // Find the user associated with the appliance (by appliance.userId)
    const user = await User.findById(appliance.userId);
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const kwhRate = user.kwhRate || 0;

    const createdDate = appliance.createdAt;
    const updatedDate = updatedAt ? new Date(updatedAt) : new Date();

    // Ensure the updatedAt date is not before the createdAt date
    if (updatedDate < createdDate) {
        return res.status(400).json({ error: 'Updated date cannot be before the created date' });
    }

    // --- First Calculation: From createdAt to day before updatedAt using old data ---
    const oldEndDate = new Date(updatedDate);
    oldEndDate.setDate(updatedDate.getDate() - 1);  // Exclude the updatedAt day

    const oldDaysUsed = getOccurrencesBetweenDates(createdDate, oldEndDate, appliance.selectedDays);
    const oldTotalDaysUsed = Object.values(oldDaysUsed).reduce((sum, count) => sum + count, 0);
    const oldTotalHoursUsed = oldTotalDaysUsed * appliance.usagePatternPerDay;
    const oldEnergyKwh = (appliance.wattage / 1000) * oldTotalHoursUsed;

    // --- Second Calculation: From updatedAt to end of the month using new data ---
    const updatedEndOfMonth = new Date(updatedDate.getFullYear(), updatedDate.getMonth() + 1, 0);
    const newDaysUsed = getOccurrencesBetweenDates(updatedDate, updatedEndOfMonth, selectedDays);
    const newTotalDaysUsed = Object.values(newDaysUsed).reduce((sum, count) => sum + count, 0);
    const newTotalHoursUsed = newTotalDaysUsed * usagePatternPerDay;
    const newEnergyKwh = (wattage / 1000) * newTotalHoursUsed;

    // Sum both energy consumptions
    const totalEnergyKwh = oldEnergyKwh + newEnergyKwh;

    // Calculate the final monthly cost
    const updatedMonthlyCost = kwhRate * totalEnergyKwh;

    // Update the appliance data with the new information
    appliance.applianceName = applianceName;
    appliance.wattage = wattage;
    appliance.usagePatternPerDay = usagePatternPerDay;
    appliance.selectedDays = selectedDays;
    appliance.updatedAt = updatedDate;
    appliance.monthlyCost = updatedMonthlyCost;

    await appliance.save();

    res.status(200).json({ message: 'Appliance updated successfully', newEnergyKwh, oldEnergyKwh, newTotalDaysUsed, appliance });
}));
router.delete('/deleteAppliance/:applianceId', authenticateToken,asyncHandler(async (req, res) =>{
    const applianceId = req.params.applianceId;

    // Find the appliance to delete
    const appliance = await Appliance.findByIdAndDelete(applianceId);
    if (!appliance) {
      return res.status(404).json({ message: 'Appliance not found' });
    }

    // Remove the appliance from the user's list
    await User.updateMany(
      { appliances: applianceId },
      { $pull: { appliances: applianceId } }
    );
    res.json({ message: 'Appliance deleted successfully' });
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
}));

// Function to calculate remaining occurrences of selected days in a month
function getRemainingOccurrences(year, month, startDay, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    let currentDate = new Date(year, month - 1, startDay);
    const lastDay = new Date(year, month, 0);

    for (let day = currentDate; day <= lastDay; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }
    return dayOccurrences;
}
function getOccurrencesBetweenDates(startDate, endDate, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    for (let day = new Date(startDate); day <= endDate; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }

    return dayOccurrences;
}

router.post('/testSaveMonthlyConsumption', asyncHandler(async (req, res) => {
    const { userId, month, year, totalMonthlyConsumption } = req.body;

    if (!month || !year) {
        return res.status(400).json({ message: 'Month and year are required.' });
    }

    const user = await User.findById(userId);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Define emission factor
    const emissionFactor = 0.7;

    // Calculate totalMonthlyCost
    let totalMonthlyCost = 0;
    if (totalMonthlyConsumption) {
        totalMonthlyCost = totalMonthlyConsumption;
    } else {
        const appliances = await Appliance.find({ userId });
        totalMonthlyCost = appliances.reduce((total, appliance) => {
            return total + (appliance.monthlyCost || 0);
        }, 0);
    }

    // Calculate totalMonthlyKwhConsumption
    const totalMonthlyKwhConsumption = user.kwhRate > 0 ? totalMonthlyCost / user.kwhRate : 0;

    // Calculate totalMonthlyCO2Emissions
    const totalMonthlyCO2Emissions = totalMonthlyKwhConsumption * emissionFactor;

    // Save monthly consumption data
    const monthlyConsumption = new MonthlyConsumption({
        userId: user._id,
        month: parseInt(month, 10),
        year: parseInt(year, 10),
        totalMonthlyConsumption: totalMonthlyCost,
        totalMonthlyKwhConsumption,
        totalMonthlyCO2Emissions
    });

    await monthlyConsumption.save();

    res.status(200).json({
        message: 'Monthly consumption saved successfully.',
        totalMonthlyConsumption: totalMonthlyCost,
        totalMonthlyKwhConsumption,
        totalMonthlyCO2Emissions
    });
}));

module.exports = router;

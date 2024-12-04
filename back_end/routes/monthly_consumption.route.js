const express = require('express');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model'); // Import model
const Appliance = require('../models/appliances.model'); // Import appliance model
const User = require('../models/user.model'); // Import user model
const mongoose = require('mongoose');
const asyncHandler = require('../centralized_codes/authMiddleware');



router.post('/saveMonthlyData', asyncHandler(async (req, res) => {
    const { userId, year, month, monthlyConsumption, monthlyKwhConsumption } = req.body;

    if (!userId || !year || month === undefined || !monthlyConsumption) { // Check for month being undefined
        return res.status(400).json({ error: 'All fields are required: userId, year, month, and monthlyConsumption' });
    }

    try {
        const existingData = await MonthlyConsumption.findOne({ userId, year, month });

        if (existingData) {
            existingData.totalMonthlyConsumption = monthlyConsumption;
            existingData.totalMonthlyKwhConsumption = monthlyKwhConsumption;
            await existingData.save();
            return res.status(200).json({ message: 'Monthly consumption data updated successfully' });
        } else {
            const newMonthlyData = new MonthlyConsumption({
                userId,
                year,
                month,  // Ensure this is a number
                totalMonthlyConsumption: monthlyConsumption,
                totalMonthlyKwhConsumption: monthlyKwhConsumption
            });
            await newMonthlyData.save();
            return res.status(201).json({ message: 'Monthly consumption data saved successfully' });
        }
    } catch (error) {
        console.error('Error saving or updating monthly data:', error);
        return res.status(500).json({ error: 'Server error while saving or updating monthly data' });
    }
}));


router.post('/save-consumption', async (req, res) => {
    const { userId } = req.body;

    const currentDate = new Date();
    const day = currentDate.getDate();
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();

    try {
        const appliances = await Appliance.find({ userId });

        if (!appliances || appliances.length === 0) {
            return res.status(404).json({ message: 'No appliances found for this user' });
        }

        const user = await User.findById(userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;

        // Initialize totals
        let totalMonthlyWattage = 0;
        let totalMonthlyCost = 0;

        // Save consumption data
        const consumptionPromises = appliances.map(async (appliance) => {
            const dailyWattage = (appliance.wattage / 1000) * appliance.usagePattern;
            const dailyCost = dailyWattage * kwhRate;
            const monthlyWattage = appliance.monthlyUsagePattern;
            const monthlyCost = monthlyWattage * kwhRate;

            totalMonthlyWattage += monthlyWattage;
            totalMonthlyCost += monthlyCost;

            return calculateAndSaveConsumption(
                userId,
                appliance._id,
                day,
                month,
                year,
                dailyWattage,
                dailyCost,
                monthlyWattage,
                monthlyCost
            );
        });

        await Promise.all(consumptionPromises);

        res.status(201).json({
            message: 'Daily and monthly consumption saved',
            totalMonthlyWattage,
            totalMonthlyCost
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

const calculateAndSaveConsumption = async (userId, applianceId, day, month, year, dailyWattage, dailyCost, monthlyWattage, monthlyCost) => {
    const newConsumption = new MonthlyConsumption({
        userId,
        applianceId,
        day,
        month,
        year,
        dailyWattage,
        dailyCost,
        monthlyWattage,
        monthlyCost
    });
    await newConsumption.save();
};


router.get('/get-daily-consumption/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    // Fetch consumption data for the user
    const consumption = await MonthlyConsumption.findOne({ userId });

    // Check if consumption records exist
    if (!consumption) {
      return res.status(404).json({ message: 'No consumption records found for this user' });
    }

    // Assuming dailyCost is an array of daily consumption data
    res.status(200).json({
      message: 'Daily consumption records found',
      dailyCost: consumption.dailyCost, // Daily consumption data for each day
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});

// In your routes file (e.g., monthly_consumption.route.js)

router.get('/monthlyConsumption', asyncHandler(async (req, res) => {
    const { userId, month, year } = req.query;

    // Validate required parameters
    if (!userId || !month || !year) {
        return res.status(400).json({ message: 'userId, month, and year are required.' });
    }

    // Fetch the monthly consumption for the given user, month, and year
    const monthlyConsumption = await MonthlyConsumption.findOne({
        userId,
        month: parseInt(month, 10),  // Convert to integer
        year: parseInt(year, 10)      // Convert to integer
    });

    // If not found, return a 404 error
    if (!monthlyConsumption) {
        return res.status(404).json({ message: 'Monthly consumption not found.' });
    }

    // Send the found monthly consumption data
    res.status(200).json(consumption);
}));

router.get('/monthly-consumption/:userId', async (req, res) => {
    const { userId } = req.params;
    const { month, year } = req.query;

    try {
        const monthlyConsumptions = await MonthlyConsumption.find({
            userId,
            month,
            year
        });

        if (!monthlyConsumptions || monthlyConsumptions.length === 0) {
            return res.status(404).json({ message: 'No consumption records found for this user' });
        }

        let totalWattage = 0;
        let totalCost = 0;
        monthlyConsumptions.forEach(consumption => {
            totalWattage += consumption.monthlyWattage;
            totalCost += consumption.monthlyCost;
        });

        res.status(200).json({
            message: 'Monthly consumption retrieved successfully',
            totalWattage,
            totalCost,
            monthlyConsumptions
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});



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


router.post('/calculate-occurrences', (req, res) => {
    const { year, month, startDay, selectedDays } = req.body;
    // Check if any required parameter is missing
    if (!year || !month || !startDay || !selectedDays) {
        return res.status(400).send({ error: 'Missing required parameters' });
    }

    // Calculate the occurrences of the selected days
//    const occurrences = getRemainingDates(year, month, startDay, selectedDays);

    // Calculate the total number of occurrences (sum of all values in the occurrences object)
   const occurrences = getRemainingOccurrences(year, month, startDay, selectedDays);
   const totalOccurrences = Object.values(occurrences).reduce((sum, count) => sum + count, 0);

   // Multiply totalOccurrences by something (e.g., a rate or value)
   const result = totalOccurrences * 18;

   res.send({ occurrences, totalOccurrences, result });

});

function getOccurrencesBetweenDates(year, month, startDate, endDate, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    let currentDate = new Date(year, month - 1, startDate);
    let lastDate = new Date(year, month - 1, endDate);

    // Loop from startDate to endDate
    for (let day = currentDate; day <= lastDate; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }

    return dayOccurrences;
}

// API endpoint to handle original and new selected days after the update
router.post('/calculate-occurrences-update', (req, res) => {
    const { year, month, originalStartDay, updateDay, originalSelectedDays, newSelectedDays } = req.body;

    if (!year || !month || !originalStartDay || !updateDay || !originalSelectedDays || !newSelectedDays) {
        return res.status(400).send({ error: 'Missing required parameters' });
    }

    // 1. Calculate occurrences from original start date to the day before the update using original selected days
    const occurrencesBeforeUpdate = getOccurrencesBetweenDates(year, month, originalStartDay, updateDay - 1, originalSelectedDays);

    // 2. Calculate occurrences from update day to the end of the month using new selected days
    const lastDayOfMonth = new Date(year, month, 0).getDate();  // Get the last day of the month
    const occurrencesAfterUpdate = getOccurrencesBetweenDates(year, month, updateDay, lastDayOfMonth, newSelectedDays);

    // 3. Sum the occurrences from both periods
    const totalOccurrencesBeforeUpdate = Object.values(occurrencesBeforeUpdate).reduce((sum, count) => sum + count, 0);
    const totalOccurrencesAfterUpdate = Object.values(occurrencesAfterUpdate).reduce((sum, count) => sum + count, 0);

    const totalOccurrences = totalOccurrencesBeforeUpdate + totalOccurrencesAfterUpdate;

    // Respond with detailed occurrences and total count
    res.send({
        occurrencesBeforeUpdate,
        occurrencesAfterUpdate,
        totalOccurrencesBeforeUpdate,
        totalOccurrencesAfterUpdate,
        totalOccurrences
    });
});


module.exports = router;

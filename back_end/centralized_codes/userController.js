const express = require('express');
const User = require('../models/user.model');
const router = express.Router();

// Find user and kWh rate utility function
const findUserWithKwhRate = async (userId) => {
  const user = await User.findById(userId);
  if (!user || !user.kwhRate) throw new Error('User or kWh rate not found');
  return user;
};

// Function to calculate consumption
const calculateConsumption = (appliance, kwhRate) => {
  const kwh = appliance.wattage / 1000;
  const dailyKwh = kwh * appliance.usagePatternPerDay;
  const dailyConsumption = dailyKwh * kwhRate;

  const hoursUsedPerWeek = appliance.usagePatternPerDay * appliance.usagePatternPerWeek;
  const kwhUsedPerWeek = hoursUsedPerWeek * kwh;
  const costPerWeek = kwhUsedPerWeek * kwhRate;

  const monthlyConsumption = costPerWeek * 4.345;

  return { dailyConsumption, monthlyConsumption };
};


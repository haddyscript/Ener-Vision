const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();
const Goal = require('../models/goals.model');
const User = require('../models/user.model');


router.post('/goals', async (req, res) => {
  const { description, startTime, endTime, startDate, endDate, category, userId } = req.body;

  console.log('Received data:', req.body);

  if (!description || !startTime || !endTime || !startDate || !endDate || !category || !userId) {
    console.log('Missing required fields');
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const newGoal = new Goal({
      description,
      startTime,
      endTime,
      startDate,
      endDate,
      category,
      userId,
    });

    console.log('Attempting to save new goal:', newGoal);
    await newGoal.save();
    console.log('Goal saved:', newGoal);  
    res.status(201).json(newGoal);  
  } catch (error) {
    console.error('Error occurred while saving goal:', {
      message: error.message,
      stack: error.stack,
      requestBody: req.body,
    });
    res.status(500).json({ error: 'Failed to add goal', details: error.message });
  }
});


router.get('/goals', async (req, res) => {
  const { userId, month, year } = req.query;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    let query = { userId };

    if (month && year) {
      const startOfMonth = new Date(year, month - 1, 1);
      const endOfMonth = new Date(year, month, 0);

      startOfMonth.setHours(0, 0, 0, 0);
      endOfMonth.setHours(23, 59, 59, 999);

      query = {
        userId,
        $or: [
          {
            startDate: { $gte: startOfMonth, $lte: endOfMonth },
            endDate: { $gte: startOfMonth, $lte: endOfMonth }
          },
          {
            endDate: { $gte: startOfMonth, $lte: endOfMonth },
            startDate: { $lte: endOfMonth }
          },
        ]
      };
    }

    const goals = await Goal.find(query).select(
      'description startTime endTime startDate endDate category status userId createdAt'
    );

    if (goals.length === 0) {
      return res.status(404).json({ message: 'No goals found for this user' });
    }

    console.log('Fetched goals:', goals);

    res.status(200).json(goals);
  } catch (error) {
    console.error('Error fetching goals:', error.message);
    res.status(500).json({ error: 'Failed to fetch goals', details: error.message });
  }
});

  
  router.patch('/goals/:goalId', async (req, res) => {
    console.log('Request body:', req.body); 
  
    const { status } = req.body;
  
    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }
  
    try {
      const goal = await Goal.findById(req.params.goalId);
      if (!goal) {
        return res.status(404).json({ error: 'Goal not found' });
      }
  
      goal.status = status;
      await goal.save();
  
      res.status(200).json({ message: 'Goal status updated successfully' });
    } catch (error) {
      console.error('Error updating goal:', error);
      res.status(500).json({ error: 'Server error' });
    }
  });
  
  router.delete('/goals/:goalId', async (req, res) => {
    try {
      const { goalId } = req.params;
  
      // Validate if goalId is a valid ObjectId
      if (!mongoose.Types.ObjectId.isValid(goalId)) {
        return res.status(400).json({ error: 'Invalid goal ID format' });
      }
  
      const goal = await Goal.findByIdAndDelete(goalId);
      if (!goal) {
        return res.status(404).json({ error: 'Goal not found' });
      }
  
      res.json({ message: 'Goal deleted successfully' });
    } catch (error) {
      console.error('Error deleting goal:', error);
      res.status(500).json({ error: 'Failed to delete goal', details: error.message });
    }
  });
    
module.exports = router;

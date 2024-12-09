const express = require('express');
const router = express.Router();
const User = require('../models/user.model');
const UserProfile = require('../models/profile.model');

router.get('/userProfileLatest/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    console.log('Received User ID:', userId);

    // Fetch user profile
    const userProfile = await UserProfile.findOne({ userId }).select('name mobileNumber birthDate address avatar');
    if (!userProfile) {
      console.log(`User profile not found for userId: ${userId}`);
      return res.status(404).json({ message: `User profile not found for userId: ${userId}` });
    }

    // Fetch user email
    const user = await User.findById(userId).select('email');
    if (!user) {
      console.log(`User not found for userId: ${userId}`);
      return res.status(404).json({ message: `User not found for userId: ${userId}` });
    }

    // Combine all user data
    const userDetails = {
      name: userProfile.name,
      email: user.email,
      mobileNumber: userProfile.mobileNumber,
      birthDate: userProfile.birthDate,
      address: userProfile.address,
      avatar: `${req.protocol}://${req.get('host')}/uploads/${userProfile.avatar}`, // Construct full URL
    };


    console.log('Fetched user details:', userDetails);
    res.status(200).json(userDetails);
  } catch (error) {
    console.error('Error fetching user data:', error);
    res.status(500).json({ message: 'An error occurred while fetching user data' });
  }
});

router.post('/delete-account/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findByIdAndUpdate(userId, { status: 'deleted' }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'Account has been marked as deleted.' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to delete account', error: err.message });
  }
});

module.exports = router;
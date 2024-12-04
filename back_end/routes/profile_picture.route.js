const express = require("express");
const UserProfile = require("../models/profile.model"); // Adjust the path as necessary
const asyncHandler = require('../centralized_codes/authMiddleware'); // Your async middleware
const multer = require("multer");
const router = express.Router();
const path = require("path");
router.post('/uploadProfilePicture', upload.single('profilePicture'), async (req, res) => {
  try {
    const { userId } = req.body;

    // Save profile picture URL in the ProfilePicture collection
    const profilePicture = new ProfilePicture({
      userId: userId,
      url: req.file.path,  // The path where the image is stored
    });
    await profilePicture.save();

    // Update the UserProfile with the new profile picture ID
    await UserProfile.findOneAndUpdate(
      { userId },
      { profilePictureId: profilePicture._id },
      { new: true }
    );

    return res.status(200).json({ message: 'Profile picture uploaded successfully!' });
  } catch (error) {
    return res.status(500).json({ message: 'Error uploading profile picture', error: error.message });
  }
});
router.get('/getUserProfile', async (req, res) => {
  try {
    const userProfile = await UserProfile.findOne({ userId: req.query.userId })
      .populate('profilePictureId'); // Fetches the profile picture from the ProfilePicture collection

    if (!userProfile) {
      return res.status(404).json({ message: 'User profile not found' });
    }

    return res.status(200).json(userProfile);
  } catch (error) {
    return res.status(500).json({ message: 'Error fetching user profile', error: error.message });
  }
});

module.exports = router;
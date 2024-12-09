const express = require("express");
const UserProfile = require("../models/profile.model"); // Adjust the path as necessary
const multer = require("multer");
const path = require("path"); // Import path module for file extension handling
const fs = require("fs");
const router = express.Router();
const asyncHandler = require('../centralized_codes/authMiddleware');

// Ensure the uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const username = req.decoded?.username || 'user';
    cb(null, `${username}-${Date.now()}${path.extname(file.originalname)}`);
  },
});

// Configure multer without file type restriction
const upload = multer({
  storage,
  limits: { fileSize: 1024 * 1024 * 6 }, // 6MB limit
  fileFilter: (req, file, cb) => {
    const fileTypes = /jpeg|jpg|png|gif/;
    const extName = fileTypes.test(path.extname(file.originalname).toLowerCase());
    const mimeType = fileTypes.test(file.mimetype);
    if (extName && mimeType) {
      return cb(null, true);
    } else {
      cb(new Error('Only images are allowed!'));
    }
  },
});


// Route to create or update user profile
router.post('/updateUserProfile', upload.single('avatar'), asyncHandler(async (req, res) => {
  const { userId, name, gender, occupation, birthDate, energyInterest, mobileNumber, address } = req.body;

  try {
    let userProfile = await UserProfile.findOne({ userId });

    const avatar = req.file ? req.file.path : null;

    if (userProfile) {
      userProfile.name = name;
      userProfile.gender = gender;
      userProfile.occupation = occupation;
      userProfile.birthDate = birthDate;
      userProfile.energyInterest = energyInterest;
      userProfile.mobileNumber = mobileNumber;
      userProfile.avatar = avatar || userProfile.avatar;
      userProfile.address = address;

      await userProfile.save();
      return res.status(200).json({ message: 'User profile updated successfully!', userProfile });
    } else {
      // Create new profile
      userProfile = new UserProfile({
        userId,
        name,
        gender,
        occupation,
        birthDate,
        energyInterest,
        mobileNumber,
        avatar,
        address
      });

      await userProfile.save(); // Save new profile
      return res.status(201).json({ message: 'User profile created successfully!', userProfile });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to update or create user profile', error: error.message });
  }
}));


// Route to get user profile
router.post('/updateUserProfile', upload.single('avatar'), asyncHandler(async (req, res) => {
  const { userId, name, birthDate, energyInterest, mobileNumber, address } = req.body;

  try {
    // Validate required fields
    if (!userId || !name || !birthDate || !address) {
      return res.status(400).json({ message: 'Missing required fields!' });
    }

    const addressObj = typeof address === 'string' ? JSON.parse(address) : address;
    if (!addressObj.countryLine || !addressObj.cityLine || !addressObj.streetLine) {
      return res.status(400).json({ message: 'Incomplete address information!' });
    }

    let userProfile = await UserProfile.findOne({ userId });

    const avatar = req.file ? path.relative(uploadDir, req.file.path) : null;

    if (userProfile) {
      // Update existing profile
      userProfile.name = name;
      userProfile.birthDate = birthDate;
      userProfile.energyInterest = energyInterest;
      userProfile.mobileNumber = mobileNumber;
      userProfile.avatar = avatar || userProfile.avatar;
      userProfile.address = addressObj;

      await userProfile.save();
      return res.status(200).json({ message: 'User profile updated successfully!', userProfile });
    } else {
      // Create new profile
      userProfile = new UserProfile({
        userId,
        name,
        birthDate,
        energyInterest,
        mobileNumber,
        avatar,
        address: addressObj,
      });

      await userProfile.save();
      return res.status(201).json({ message: 'User profile created successfully!', userProfile });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to update or create user profile', error: error.message });
  }
}));

// Route to get user avatar
router.get('/getUserAvatarLatest', async (req, res) => {
  const { username } = req.query; // Get username from query parameters

  if (!username) {
    return res.status(400).json({ message: 'Username is required' });
  }

  try {
    // Find the user profile by username
    const userProfile = await UserProfile.findOne({ username });

    if (userProfile && userProfile.img) {
      return res.status(200).json({ avatar: userProfile.img });
    } else {
      return res.status(404).json({ message: 'User profile or avatar not found' });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch user avatar', error: error.message });
  }
});

module.exports = router;

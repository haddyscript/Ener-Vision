const express = require("express");
const UserProfile = require("../models/profile.model");
const asyncHandler = require('../centralized_codes/authMiddleware');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const fs = require('fs');
const authenticateToken = require('../middleware'); // Import your token middleware


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // folder to save images
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname); // unique file name
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 1024 * 1024 * 5 }, // Limit file size to 5MB
});
// Update user profile route
router.post('/updateUserProfile', upload.single('avatar'),authenticateToken, asyncHandler(async (req, res) => {
  const { userId, name, birthDate, energyInterest, mobileNumber, address } = req.body;

  try {
    let userProfile = await UserProfile.findOne({ userId });

    // Check if a file was uploaded
    const avatar = req.file ? req.file.path : null;

    if (userProfile) {
      // Update existing profile
      userProfile.name = name;
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
        birthDate,
        energyInterest,
        mobileNumber,
        avatar,
        address,
      });

      await userProfile.save();
      return res.status(201).json({ message: 'User profile created successfully!', userProfile });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to update or create user profile', error: error.message });
  }
}));
router.get('/getAvatarNew', asyncHandler(async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ message: 'User ID is required' });
  }

  try {
    const trimmedUserId = userId.trim(); // Trim any extra spaces or newlines
    const userProfile = await UserProfile.findOne({userId: trimmedUserId});

    if (!userProfile || !userProfile.avatar) {
      return res.status(404).json({ message: 'User or avatar not found' });
    }

    res.json({
      message: 'Avatar found',
      avatar: userProfile.avatar,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching avatar', error: error.message });
  }
}));

router.get('/getUserProfile', asyncHandler(async (req, res) => {
  const { userId } = req.query; // Get userId from query parameters

  try {
    const userProfile = await UserProfile.findOne({ userId });

    if (userProfile) {
      return res.status(200).json(userProfile);
    } else {
      return res.status(404).json({ message: 'User profile not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch user profile', error: error.message });
  }
}));

router.get('/getUserAvatar', asyncHandler(async (req, res) => {
  const { userId } = req.query; // Get userId from query parameters

  if (userId) {
    return res.status(400).json({ message: 'User ID is required' });
  }

  try {
    const userProfile = await User.findOne({ userId });

    if (userProfile && userProfile.profilePicture) {
      return res.status(200).json({ avatar: User.profilePicture });
    } else {
      return res.status(404).json({ message: 'User profile or avatar not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch user avatar', error: error.message });
  }
}));


module.exports = router;
/*
require('dotenv').config(); // Ensure you have the dotenv package installed to load environment variables

const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const path = require('path');

// Configure AWS SDK with your credentials
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
});

// Create an S3 instance
const s3 = new AWS.S3();

// Configure multer to use S3 for file storage
const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: process.env.S3_BUCKET_NAME, // Your S3 bucket name from the environment variable
    acl: 'public-read', // Make the file publicly readable (optional)
    key: (req, file, cb) => {
      const username = req.decoded?.username || 'user'; // Generate a unique file name
      cb(null, `${username}-${Date.now()}${path.extname(file.originalname)}`);
    },
  }),
  limits: {
    fileSize: 1024 * 1024 * 6, // Set a file size limit (6MB)
  },
  fileFilter: (req, file, cb) => {
    const allowedMimeTypes = ['image/jpeg', 'image/png'];
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG and PNG are allowed.'), false);
    }
  },
});

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ error: err.message });
  } else if (err) {
    return res.status(400).json({ error: err.message });
  }
  next();
};

module.exports = { upload, errorHandler };

*/
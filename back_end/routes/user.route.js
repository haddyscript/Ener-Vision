const express = require("express");
const multer = require("multer");
const User = require("../models/user.model");
const UserProfile = require("../models/profile.model");
const Appliance = require("../models/appliances.model");
const MonthlyConsumption = require("../models/monthly_consumption.model");
const router = express.Router();
const path = require("path");
const fs = require('fs');
const jwt = require("jsonwebtoken");
const cron = require('node-cron');
const authenticateToken = require('../middleware');

const dotenv = require('dotenv');

dotenv.config();


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

const runMonthlyCronJob = async () => {
    try {
        const users = await User.find(); // Get all users
        const currentMonth = new Date().getMonth() + 1; // Get current month (1-12)
        const currentYear = new Date().getFullYear(); // Get current year

        for (const user of users) {
            await saveMonthlyConsumption(user._id, currentMonth, currentYear);
        }

        console.log('Monthly consumption saved/updated for all users.');
    } catch (error) {
        console.error('Error during cron job execution:', error);
    }
};

cron.schedule('59 20 19 11 *', async () => {
    const now = new Date();
    const lastDayOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();

    // Ensure the cron job only runs on the last day of the month
    if (now.getDate() === lastDayOfMonth) {
        console.log('Running scheduled cron job...');
        await runMonthlyCronJob();
    }
});



router.get('/run-cron', async (req, res) => {
    try {
        await runMonthlyCronJob(); // Call the cron job function
        res.status(200).send('Cron job executed successfully');
    } catch (err) {
        console.error('Error running cron job:', err);
        res.status(500).send('Cron job failed');
    }
});


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

// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 6, // 6MB limit
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
    return res.status(400).send({ error: err.message });
  } else if (err) {
    return res.status(400).send({ error: err.message });
  }
  next();
};

router.get('/getCommunityGuidelines/:userId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId);
        if (!user) {
            return res.status(404).json({
                message: 'User not found',
                error: 'Invalid userId or user does not exist'
            });
        }
        res.status(200).json({ accepted: user.communityGuidelinesAccepted });
    } catch (error) {
        res.status(500).json({
            message: 'Server error',
            error: error.message
        });
    }
});

router.post('/acceptCommunityGuideLines/:userId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        user.communityGuidelinesAccepted = true;
        await user.save();
        res.status(200).json({ message: 'Community guidelines accepted' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

router.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if email or password is missing
    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Compare the entered password with the stored hashed password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Ensure JWT_SECRET is loaded properly
    console.log(process.env.JWT_SECRET); // Log it to verify
console.log("JWT_SECRET:", process.env.JWT_SECRET); // This will help you verify the loaded secret

    // Generate a JWT token
    const token = jwt.sign(
      { id: user._id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    // Check if the user has a profile
    const profile = await UserProfile.findOne({ userId: user._id });
      console.log('User token', token);

    // Successful login response
    return res.status(200).json({
      token,

      user: {
        _id: user._id,
        username: user.username,
        hasProfile: profile ? true : false,
      },

    });



  } catch (err) {
    console.error("Error during signin: ", err.message);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});

function capitalizeWords(str) {
  return str.replace(/\b\w/g, char => char.toUpperCase());
}

router.post("/signup", async (req, res) => {
  try {
    const existingUser = await User.findOne({ email: req.body.email });
    const formattedUsername = capitalizeWords(req.body.username);

    if (!existingUser) {
      const newUser = new User({
        email: req.body.email,
        password: req.body.password,
        username: formattedUsername,
      });

      await newUser.save();

      // Generate a JWT token
      const token = jwt.sign(
        { id: newUser._id, username: newUser.username },
        process.env.JWT_SECRET,  // Make sure your secret is in the environment variables
          { expiresIn: '1d' } // Set the token expiration (1 hour in this example)
      );
        console.log('User token', token);

      // Send the response with the user info and token
      res.status(201).json({
        message: "User created successfully",
        user: {
          _id: newUser._id,
          username: newUser.username,
          email: newUser.email,
        },
        token: token
      });
        console.log('User token', token);

    } else {
      res.status(400).json({ message: "Email is already in use" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});


router.put("/update-kwh-rate",  async (req, res) => {
  try {
    const userId = req.user.id;
    const { kwhRate } = req.body;

    // Validate kwhRate
    if (typeof kwhRate !== 'number' || kwhRate <= 0) {
      return res.status(400).json({ message: "Invalid kwhRate" });
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { kwhRate },
      { new: true } // Return the updated document
    );

    res.status(200).json({ message: "kWh rate updated successfully", user: updatedUser });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});

// Older versions of my sign-up and sign-in
/*
router.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Compare the entered password with the stored hashed password
    const isMatch = await user.comparePassword(password);  // Assuming comparePassword is implemented
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Check if the user has a profile
    const profile = await UserProfile.findOne({ userId: user._id });

    // Successful login response
    return res.status(200).json({
      user: {
        _id: user._id,
        profiles: profile ? true : false,  // Send true if profile exists, false otherwise
      },
    });
  } catch (err) {
    console.error("Error during signin: ", err.message);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});
*/

router.post(
  "/updateProfile",
  upload.single("profilePicture"),
  async (req, res) => {
    console.log("Update profile endpoint hit");
    console.log("Received userId:", req.body.userId);

    try {
      const userId = req.body.userId;
      const { countryLine, cityLine, streetLine, mobileNumber, appliances } = req.body;
      let profilePicturePath;
      if (req.file) {
        profilePicturePath = path.relative(__dirname, req.file.path);
      }

      const updateUser = await User.findByIdAndUpdate(
        userId,
        {
          countryLine,
          cityLine,
          streetLine,
          mobileNumber,
          profilePicture: profilePicturePath,
        },
        { new: true }
      );

      if (updateUser) {
        console.log("User Profile Updated", updateUser);
        res.json(updateUser);
      } else {
        console.log("User not found");
        res.status(404).json({ message: "User not found" });
      }
    } catch (error) {
      console.log("Error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

router.get('/getUsername/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.username != null && user.username !== '') {
      return res.status(200).json({ username: user.username });
    } else {
      return res.status(404).json({ message: 'username not found for the user' });
    }

  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch Username', error: error.message });
  }
});

router.get("/user/:userId/kwhRate", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ kwhRate: user.kwhRate });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


router.get("/user/:userId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
  res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

router.get('/users/:userId', async (req, res) => {
  try {
    const { fields } = req.query;

    let user;
    if (fields === 'username') {
      user = await User.findById(req.params.userId).select('username');
    } else {
      user = await User.findById(req.params.userId);
    }

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

router.delete('/users/:userId',async (req, res) => {
try {
const user = await User.findByIdAndDelete(req.params.userId);
if (!user) {
return res.status(404).json({message: "User not found"});
}
res.json({message : 'User deleted successfully'});
}catch(err) {
    console.error(err);
    res.status(500).json({message: 'Internal server error'})
        }
});

module.exports = router;
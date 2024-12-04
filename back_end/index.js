const express = require('express');
const app = express();
const profileRoutes = require('./routes/profile');
const port = process.env.PORT || 8080;
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const MonthlyConsumption = require('./models/monthly_consumption.model'); // Import model
const cron = require('node-cron');
const winston = require('winston');
const User = require('./models/user.model'); // Adjust the path as needed
const Appliance = require('./models/appliances.model');
const router = express.Router();
require('dotenv').config();
const publicRouter = require('./routes/publicRouter'); // Assume this exports public routes
const protectedRouter = require('./routes/privateRouter'); // Assume this exports protected routes


app.use(express.json()); // Middleware to parse JSON



mongoose.connect(
process.env.MONGO_URI
// "mongodb://localhost:27017/enervision"
).then(() => {
  console.log('Connected to MongoDB');
  console.log("MONGO_URI:", process.env.MONGO_URI); // Should show the Mongo URI
  console.log("JWT_SECRET:", process.env.JWT_SECRET); // Should show the JWT

}).catch((error) => {
  console.error('MongoDB connection error:', error);

});

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.json());

const path = require('path');
app.use('/images', express.static(path.join(__dirname, 'images')));
app.use('/uploads', express.static('uploads'));
// Route definitions
app.use('/', require('./routes/user.route'));
app.use('/', require('./routes/appliances.route'));
app.use('/', require('./routes/new_appliance.route'));
app.use('/', require('./routes/post.route'));
app.use('/', require('./routes/suggestions.route'));
app.use('/', require('./routes/profile.route'));
app.use('/', require('./routes/profiles.route'));
app.use('/', require('./routes/account.route'));
app.use('/', require('./routes/chats.route'));
app.use('/', require('./routes/faqs.route'));
app.use('/', require('./routes/energy_providers.route'));
app.use('/', require('./routes/compared_appliance.route'));
app.use('/', require('./routes/monthly_consumption.route'));
app.use('/', require('./routes/device_info.route'));


// Cron job to save monthly consumption on the last day of each month
cron.schedule('0 0 1 * *', async () => {
    const users = await User.find(); // Get all users
    for (const user of users) {
        const appliances = await Appliance.find({ userId: user._id });

        // Debugging: Log the appliances and their monthly costs
        console.log('Appliances for user:', user._id, appliances);

        const totalMonthlyCost = appliances.reduce((total, appliance) => {
            return total + (appliance.monthlyCost || 0);
        }, 0);

        // Debugging: Log the total monthly cost
        console.log('Total Monthly Cost for user:', user._id, totalMonthlyCost);

        const month = new Date().getMonth() + 1; // Get the current month (1-12)
        const year = new Date().getFullYear(); // Get the current year

        const monthlyConsumption = new MonthlyConsumption({
            userId: user._id,
            month,
            year,
            totalMonthlyConsumption: totalMonthlyCost
        });

        // Debugging: Log before saving to the database
        console.log('Saving Monthly Consumption:', monthlyConsumption);

        await monthlyConsumption.save(); // Save to database
    }
});
app.get('/run-cron', async (req, res) => {
  try {
    await runCronJob(); // Extract cron logic into a separate function
    res.status(200).send('Cron job executed successfully');
  } catch (err) {
    res.status(500).send('Cron job failed');
  }
});


const logger = winston.createLogger({
  level: 'error',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log' }),
    new winston.transports.Console(),
  ],
});

app.use((err, req, res, next) => {
  logger.error(err.message, { stack: err.stack });
  res.status(500).send('Something failed');
});

// Start server
// app.listen(port, () => {
//   console.log('Server running on port ' + port);
// });


module.exports = app; 
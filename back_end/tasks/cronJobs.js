const cron = require('node-cron');
const MonthlyConsumption = require('./models/monthlyConsumption'); // Import the MonthlyConsumption model
const User = require('./models/User'); // Import your User model if you have one to get user data

// Cron job to run at 11:59 PM on the last day of every month
cron.schedule('59 23 28-31 * *', async () => {
  const today = new Date();
  const month = today.getMonth() + 1; // Months are zero-based
  const year = today.getFullYear();

  try {
    // Assuming you have a function that calculates the total monthly consumption
    const users = await User.find(); // Fetch all users or filter as necessary

    for (const user of users) {
      // Assuming you have a method to get user's total consumption for the month
      const totalConsumption = await getTotalConsumption(user._id, month, year);

      // Save or update the monthly consumption
      await MonthlyConsumption.findOneAndUpdate(
        { userId: user._id, month: month, year: year },
        { consumption: totalConsumption },
        { upsert: true } // Create a new entry if none exists
      );
    }
    console.log(`Monthly consumption data saved for ${month}/${year}`);
  } catch (error) {
    console.error('Error saving monthly consumption:', error);
  }
});

// Function to calculate total monthly consumption
async function getTotalConsumption(userId, month, year) {
  // Implement your logic to calculate the user's total consumption
  // This could involve querying another collection where daily consumption is stored
  return 0; // Replace this with actual calculation logic
}

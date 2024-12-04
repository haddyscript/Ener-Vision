const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const Schema = mongoose.Schema;

const MonthlyConsumption = require('./monthly_consumption.model'); // Adjust path as necessary

const userSchema = new Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    match: [/.+@.+\..+/, 'Please enter a valid email address'],
  },
  password: { type: String, required: true },
  username: { type: String, required: true, unique: true },
  kwhRate: { type: Number },
  status: {
    type: String,
    enum: ['active', 'banned', 'deleted'],
    default: 'active',
  },
  banReason: { type: String },
  banDate: { type: Date },
  role: {
    type: String,
    enum: ['user', 'admin', 'reporter'],
    default: 'user',
  },
  appliances: [{ type: Schema.Types.ObjectId, ref: 'Appliance' }],
  posts: [{ type: Schema.Types.ObjectId, ref: 'Post' }],
  energyDiary: [{ type: Schema.Types.ObjectId, ref: 'EnergyDiary' }],
  deletedAt: { type: Date, default: null },
}, { timestamps: true });

// Define indexes correctly
userSchema.index({ username: 1 });
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ appliances: 1 });
userSchema.index({ posts: 1 });

// Password hashing middleware
userSchema.pre('save', async function (next) {
  const user = this;

  if (!user.isModified('password')) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(user.password, salt);
    user.password = hashedPassword;
    next();
  } catch (err) {
    next(err);
  }
});

// Method to compare password during login
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to get total monthly consumption
userSchema.methods.getTotalMonthlyConsumption = async function(month, year) {
  try {
    const consumptionData = await MonthlyConsumption.aggregate([
      {
        $match: {
          userId: this._id,
          month: month,
          year: year
        }
      },
      {
        $group: {
          _id: null,
          totalMonthlyWattage: { $sum: "$monthlyWattage" },  // Adjust field names if necessary
          totalMonthlyCost: { $sum: "$monthlyCost" }        // Adjust field names if necessary
        }
      }
    ]);

    return consumptionData[0] || { totalMonthlyWattage: 0, totalMonthlyCost: 0 };
  } catch (error) {
    throw new Error('Error calculating total monthly consumption: ' + error.message);
  }
};

module.exports = mongoose.model('User', userSchema);

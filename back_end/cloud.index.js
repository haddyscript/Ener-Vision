const express = require('express');
const app = express();
const profileRoutes = require('./routes/profile');
const port = process.env.PORT || 8080;
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const winston = require('winston');
require('dotenv').config(); // Load environment variables

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB Atlas');
}).catch((error) => {
  console.error('Connection error', error);
});

const corsOptions = {
  origin: 'http://your-frontend-url.com', // Replace with your frontend URL
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use('/', require('./routes/user.route'));
app.use('/', require('./routes/appliances.route'));
app.use('/', require('./routes/post.route'));
app.use('/', require('./routes/suggestions.route'));
app.use('/', require('./routes/monthly_consumption.route'));
app.use('/uploads', express.static('uploads'));
app.use('/api/profile', profileRoutes); // Profile route under /api/profile

app.use((err, req, res, next) => {
  winston.error(err.message, err);
  res.status(500).send('Something failed');
});

app.listen(port, () => {
  console.log('Port running on ' + port);
});

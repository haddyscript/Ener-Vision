// faqs.js (for your MongoDB FAQ model)
const mongoose = require('mongoose');

const faqSchema = new mongoose.Schema({
  question: {
    type: String,
    required: true,
  },
  answer: {
    type: String,
    required: true,
  },
});

const FAQ = mongoose.model('FAQ', faqSchema);
module.exports = FAQ;

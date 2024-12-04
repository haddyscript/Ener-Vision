const express = require('express');
const router = express.Router();
const FAQ = require('../models/faq.model');

// Fetch all FAQs
router.get('/faqs', async (req, res) => {
  try {
    const faqs = await FAQ.find();
    res.json(faqs);
  } catch (err) {
    res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;


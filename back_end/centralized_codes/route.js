const express = require('express');
const modelDirectory = require('../models/posts.model');
const router = express.Router();

// Create Post of the current user
router.post('/methodName', async (req, res) => {
  try {
  } catch (err) {
  }
});

// Get all posts of a user
router.get('/methodName/:userId', async (req, res) => {
  try {
  } catch (err) {
  }
})

// Get a specific posts of a user
router.get('/methodName/:userId/:postId', async (req, res) => {
  try {
  } catch (err) {
  }
})


// Delete a specific posts of a user
router.delete('/methodName/:userId/:postId', async (req, res) => {
  try {
  } catch (err) {
  }
})
// Update a specific posts of a user
router.put('/methodName/:userId/:postId', async (req, res) => {
})

// Update a specific posts of a user (with partial update)
router.patch('/methodName/:userId/:postId', async (req, res) => {
  try {
  } catch (err) {
  }
})

// Delete all posts of a user
router.delete('/posts/:userId', async (req, res) => {
  try {
  } catch (err) {
  }
})
module.exports = router;
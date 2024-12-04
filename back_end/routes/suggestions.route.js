const express = require('express');
const router = express.Router();
const Suggestion = require('../models/suggestions.model');
const Posts = require('../models/posts.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
const authenticate = require('../middleware');
//const Posts = require('../routes/post.route');
const authenticateToken = require('../middleware');


// Add a new suggestion to a post
router.post('/addSuggestions/:postId', async (req, res) => {
  try {
    const { postId } = req.params; // Get postId from URL parameters
    const { suggestionText, userId } = req.body; // Extract suggestionText and userId from request body

    // Validate required fields
    if (!userId || !suggestionText) {
      return res.status(400).json({ message: 'User ID and suggestion text are required' });
    }

    // Check if the post exists
    const post = await Posts.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Create a new suggestion
    const newSuggestion = new Suggestion({
      suggestionText,
      postId,
      userId,
    });

    // Save the new suggestion
    await newSuggestion.save();

    // Add the suggestion to the post's suggestions array
    post.suggestions.push(newSuggestion._id);
    await post.save();

    // Respond with success
    res.status(201).json({ message: 'Suggestion added to Post', suggestion: newSuggestion });
  } catch (err) {
    console.error('Error adding suggestion:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
router.post('/addSuggestionToPost/:postId/suggestions', asyncHandler(async (req, res) => {
    const { postId } = req.params;
    const { userId, suggestionText } = req.body;

    // Validate input
    if (!userId || !suggestionText) {
        return res.status(400).json({ message: 'User ID and suggestion text are required' });
    }

    // Check if the post exists
    const post = await Posts.findById(postId);
    if (!post) {
        return res.status(404).json({ message: 'Post not found' });
    }

    // Create the suggestion
    const newSuggestion = new Suggestion({
        postId,
        userId,
        suggestionText,
    });

    // Save the suggestion
    const savedSuggestion = await newSuggestion.save();

    // Update the post with the new suggestion ID
    post.suggestions.push(savedSuggestion._id);
    await post.save();

    res.status(201).json({
        message: 'Suggestion added successfully',
        suggestion: savedSuggestion,
    });
}));

// Retrieve all suggestions for a specific post
router.get('/getAllPostsSuggestions/:postId', async (req, res) => {
  try {
  const post = await Posts.findById(req.params.postId)
      .populate({
          path: 'suggestions',
          options: { sort: { createdAt: -1 } }, // Sort by createdAt, latest first
          populate: { path: 'userId', select: 'username' }
      });

//    const post = await Post.findById(req.params.postId)
//      .populate({
//        path: 'suggestions',
//        populate: { path: 'userId', select: 'username' }
//      });

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const suggestionsWithUsernames = post.suggestions.map(({ _id, suggestionText,createdAt,userId }) => ({
      _id,
      suggestionText,
      createdAt,
      username: userId?.username || 'Unknown',
    }));

    res.status(200).json(suggestionsWithUsernames);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


router.put('/editSuggestion/:suggestionId',
// authenticate,
 async (req, res) => {
    const { suggestionId } = req.params;
    const { suggestionText } = req.body;

    try {
        const suggestion = await Suggestion.findById(suggestionId);
        if (!suggestion) {
            return res.status(404).json({ message: 'Suggestion not found' });
        }

        suggestion.suggestionText = suggestionText;
        await suggestion.save();

        res.status(200).json({ message: 'Suggestion updated successfully', suggestion });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.delete('/deleteSuggestion/:suggestionId', authenticateToken, async (req, res) => {
    const { suggestionId } = req.params;
    const userId = req.user.id; // Extracted from the token by the authentication middleware

    try {
        // Find the suggestion by ID
        const suggestion = await Suggestion.findById(suggestionId);

        // Check if suggestion exists
        if (!suggestion) {
            return res.status(404).json({ message: 'Suggestion not found' });
        }

        // Check if the suggestion belongs to the authenticated user
        if (suggestion.userId.toString() !== userId) {
            return res.status(403).json({ message: 'You are not authorized to delete this suggestion' });
        }

        // Remove the suggestion from the post's suggestions array
        await Posts.updateOne(
            { suggestions: suggestionId },
            { $pull: { suggestions: suggestionId } }
        );

        // Delete the suggestion
        await suggestion.deleteOne();

        res.status(200).json({ message: 'Suggestion deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error' });
    }
});



router.put('/editUserSuggestion/:suggestionId', authenticateToken, async (req, res) => {
    const { suggestionId } = req.params;
    const { suggestionText } = req.body;
    const userId = req.user.id; // Extracted from the token by the authentication middleware

    try {
        const suggestion = await Suggestion.findById(suggestionId);
        if (!suggestion) {
            return res.status(404).json({ message: 'Suggestion not found' });
        }

        // Check if the suggestion belongs to the logged-in user
        if (suggestion.userId.toString() !== userId) {
            return res.status(403).json({ message: 'You are not authorized to edit this suggestion' });
        }

        suggestion.suggestionText = suggestionText;
        await suggestion.save();

        res.status(200).json({ message: 'Suggestion updated successfully', suggestion });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.delete('/deleteUserSuggestion/:suggestionId', authenticateToken, async (req, res) => {
    const { suggestionId } = req.params;
    const userId = req.user.id; // Extracted from the token by the authentication middleware

    try {
        // Find the suggestion by ID
        const suggestion = await Suggestion.findById(suggestionId);

        // Check if suggestion exists
        if (!suggestion) {
            return res.status(404).json({ message: 'Suggestion not found' });
        }

        // Check if the suggestion belongs to the authenticated user
        if (suggestion.userId.toString() !== userId) {
            return res.status(403).json({ message: 'You are not authorized to delete this suggestion' });
        }

        // Remove the suggestion from the post's suggestions array
        await Posts.updateOne(
            { suggestions: suggestionId },
            { $pull: { suggestions: suggestionId } }
        );

        // Delete the suggestion
        await suggestion.deleteOne();

        res.status(200).json({ message: 'Suggestion deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error' });
    }
});
/*
// Update a specific suggestion of a user
router.put('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
    const { userId, suggestionId } = req.params;
    const updatedData = req.body;

    const suggestion = await Suggestion.findOneAndUpdate(
      { _id: suggestionId, userId: userId },
      updatedData,
      { new: true }
    );

    if (!suggestion) {
      return res.status(404).json({ message: 'Suggestion not found' });
    }

    res.status(200).json({ message: 'Suggestion updated successfully',suggestion });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Delete a specific suggestion of a user
router.delete('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
    const { userId, suggestionId } = req.params;

    const suggestion = await Suggestion.findOneAndDelete({ _id: suggestionId, userId: userId });

    if (!suggestion) {
      return res.status(404).json({ message: 'Suggestion not found' });
    }

    res.status(200).json({ message: 'Suggestion deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
router.get('/suggestionsPost/:postId/suggestions', asyncHandler(async (req, res) => {
    const { postId } = req.params;

    // Fetch all suggestions for the post
    const suggestions = await Suggestion.find({ postId })
        .populate('userId', 'username') // Populate user details
        .sort({ suggestionDate: -1 }); // Sort by the most recent suggestions

    if (!suggestions.length) {
        return res.status(404).json({ message: 'No suggestions found for this post' });
    }

    res.status(200).json({
        message: 'Suggestions retrieved successfully',
        suggestions,
    });
}));
*/
module.exports = router;

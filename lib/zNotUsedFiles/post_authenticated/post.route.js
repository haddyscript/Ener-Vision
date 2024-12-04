const express = require('express');
const multer = require('multer');
const path = require('path');
const User = require('../models/user.model');
const Posts = require('../models/posts.model');
const router = express.Router();
const asyncHandler = require('../centralized_codes/authMiddleware');
const authenticateToken = require('../middleware');

// Configure multer for file upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

router.post('/addPost', upload.single('uploadPhoto'),authenticateToken, asyncHandler(async (req, res) => {
    const { userId, title, description, tags } = req.body;

    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Create the new post object
    const newPost = new Posts({
      title,
      description,
      tags,
      userId,
      uploadPhoto: req.file ? req.file.filename : null
    });

    await newPost.save();
    user.posts.push(newPost._id);
    await user.save();

    res.status(201).json({ message: 'Post added successfully', post: newPost });
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
}));



router.get('/getAllPosts',authenticateToken ,asyncHandler(async (req, res) => {
    const posts = await Posts.find()
        .populate('userId', 'username') // Populate post author username
        .populate({
            path: 'suggestions',
            select: 'content suggestionText userId', // Select suggestion data
            populate: { path: 'userId', select: 'username' } // Populate nested suggestion author username
        })
        .exec();

    if (!posts || posts.length === 0) {
        return res.status(404).json({ message: 'No posts found' });
    }

    res.status(200).json({
        message: 'All posts retrieved successfully',
        posts: posts.map(post => ({
            id: post._id,
            title: post.title, // Post title
            tags: post.tags, // Post tags
            description: post.description, // Post description
            createdAt: post.createdAt, // Post creation timestamp
            username: post.userId?.username || 'Unknown', // Post author's username
            suggestions: post.suggestions.map(suggestion => ({
                id: suggestion._id,
                content: suggestion.content, // Suggestion content
                suggestionText: suggestion.suggestionText || '', // Suggestion text
                suggestedBy: suggestion.userId?.username || 'Unknown', // Suggestion author's username
            })),
        })),
    });
}));


router.get('/getAllPosts/:userId/posts', asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.userId)
        .select('username posts') // Select only the username and posts fields
        .populate('posts'); // Populate the posts field

    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Respond with the user's posts
    res.status(200).json({
        message: 'Posts retrieved successfully',
        username: user.username,
        posts: user.posts,
    });
}));



// Get a specific post of a user
router.get('/posts/:userId/:postId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId).populate('posts');

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const post = user.posts.find(post => post._id.toString() === req.params.postId);

        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        res.status(200).json({ message: 'Post retrieved successfully', post });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});


// Delete a specific posts of a user
router.delete('/posts/:userId/:postId', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.userId);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  const postIndex = user.posts.findIndex(post => post._id.toString() === req.params.postId);
  if (postIndex === -1) {
    return res.status(404).json({ message: 'Post not found' });
  }

  // Remove the post from the user's posts array
  user.posts.splice(postIndex, 1);
  await user.save();

  return res.status(200).json({ message: 'Post deleted successfully' });
}));

router.delete('/deletePost/:postId', async (req, res) => {
  try {
    const postId = req.params.postId;

    // Delete the post from the Post collection
    const post = await Posts.findByIdAndDelete(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Remove the post reference from the user's posts array
    await User.updateOne(
      { posts: postId },  // Finds the user with this post in their array
      { $pull: { posts: postId } }  // Removes the post from the 'posts' array
    );

    res.json({ message: 'Post deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});
// Get all posts of all users
router.get('/displayPosts', asyncHandler(async (req, res) => {
    const posts = await Posts.find().populate('userId', 'username');
    res.status(200).json({ message: 'Posts are retrieved', posts });
}));

module.exports = router;

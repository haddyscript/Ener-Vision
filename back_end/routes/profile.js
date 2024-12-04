const express = require('express');
const router = express.Router();

router.get('/profile/:userId', async (req, res) =>  {
    res.send('User profile information');
     try {
     const {userId} = req.params.userId;
     const user = await User.findById(userId);
     if (!user) {
     return res.status(404).json({message: 'User not found'}),
     res.status(200).json({ message: 'User profile retrieved', user });
     }

      } catch (err) {

       res.status(500).json({ message: 'Error fetching profile', error: error.message });
      }
});

module.exports = router;

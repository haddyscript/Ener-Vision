const express = require('express');
const authenticate = require('../middleware');

const protectedRouter = express.Router();
protectedRouter.use(authenticate);



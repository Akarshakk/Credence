const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Protect routes - require authentication
exports.protect = async (req, res, next) => {
  let token;

  // Check for token in header
  console.log('[AuthMiddleware] Headers:', JSON.stringify(req.headers));
  
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  } else if (req.headers['x-auth-token']) {
    // Alternative header
    token = req.headers['x-auth-token'];
  }

  console.log('[AuthMiddleware] Token:', token ? 'Found' : 'Missing');

  // Check if token exists
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized - No token provided',
      hint: 'Please include Authorization header with Bearer token'
    });
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('[AuthMiddleware] Token decoded for user:', decoded.id);

    // Get user from token
    req.user = await User.findById(decoded.id);

    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'User not found - Token may be invalid'
      });
    }

    console.log('[AuthMiddleware] User authenticated:', req.user.email);
    next();
  } catch (error) {
    console.error('[AuthMiddleware] Token verification failed:', error.message);
    return res.status(401).json({
      success: false,
      message: 'Not authorized - Invalid token',
      error: error.message
    });
  }
};

const express = require('express');
const router = express.Router();
const {
    createGroup,
    getGroups,
    getGroupById,
    joinGroup,
    addMember,
    deleteGroup,
    addExpense
} = require('../controllers/groupController');
const { protect } = require('../middleware/auth');

// All routes require authentication
router.use(protect);

// Group routes
router.post('/', createGroup);
router.get('/', getGroups);
router.post('/join', joinGroup);
router.get('/:id', getGroupById);
router.post('/:id/members', addMember);
router.delete('/:id', deleteGroup);

// Expense routes
router.post('/:id/expenses', addExpense);

module.exports = router;

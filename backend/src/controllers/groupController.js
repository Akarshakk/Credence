const Group = require('../models/Group');

// Generate unique 6-character invite code
const generateInviteCode = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
};

// @desc    Create a new group
// @route   POST /api/groups
// @access  Private
exports.createGroup = async (req, res) => {
    try {
        const { name, description, memberEmails } = req.body;
        const userId = req.user.id;

        // Generate unique invite code
        let inviteCode;
        let codeExists = true;
        while (codeExists) {
            inviteCode = generateInviteCode();
            const existing = await Group.findOne({ inviteCode });
            if (!existing) codeExists = false;
        }

        // Create group with creator as first member
        const group = await Group.create({
            name,
            description: description || '',
            members: [{
                userId,
                name: req.user.name,
                email: req.user.email,
                amountOwed: 0,
                amountLent: 0
            }],
            expenses: [],
            createdBy: userId,
            inviteCode,
            imageUrl: ''
        });

        res.status(201).json({
            success: true,
            data: { group }
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Get all groups for logged-in user
// @route   GET /api/groups
// @access  Private
exports.getGroups = async (req, res) => {
    try {
        const userId = req.user.id;

        // Find all groups where user is a member
        const groups = await Group.find({
            'members.userId': userId
        }).sort({ createdAt: -1 });

        res.json({
            success: true,
            data: { groups },
            total: groups.length
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Get group by ID
// @route   GET /api/groups/:id
// @access  Private
exports.getGroupById = async (req, res) => {
    try {
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Check if user is a member
        const isMember = group.members.some(m => m.userId === req.user.id);
        if (!isMember) {
            return res.status(403).json({
                success: false,
                message: 'You are not a member of this group'
            });
        }

        res.json({
            success: true,
            data: { group }
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Join group by invite code
// @route   POST /api/groups/join
// @access  Private
exports.joinGroup = async (req, res) => {
    try {
        const { inviteCode } = req.body;
        const userId = req.user.id;

        const group = await Group.findOne({ inviteCode: inviteCode.toUpperCase() });

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Invalid invite code'
            });
        }

        // Check if user is already a member
        const isMember = group.members.some(m => m.userId === userId);
        if (isMember) {
            return res.status(400).json({
                success: false,
                message: 'You are already a member of this group'
            });
        }

        // Add user to group
        group.members.push({
            userId,
            name: req.user.name,
            email: req.user.email,
            amountOwed: 0,
            amountLent: 0
        });

        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Joined group successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Add member to group
// @route   POST /api/groups/:id/members
// @access  Private
exports.addMember = async (req, res) => {
    try {
        const { userId, name, email } = req.body;
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Check if requester is a member
        const isMember = group.members.some(m => m.userId === req.user.id);
        if (!isMember) {
            return res.status(403).json({
                success: false,
                message: 'You are not a member of this group'
            });
        }

        // Check if user is already a member
        const alreadyMember = group.members.some(m => m.userId === userId);
        if (alreadyMember) {
            return res.status(400).json({
                success: false,
                message: 'User is already a member'
            });
        }

        // Add member
        group.members.push({
            userId,
            name,
            email,
            amountOwed: 0,
            amountLent: 0
        });

        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Member added successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Delete group
// @route   DELETE /api/groups/:id
// @access  Private
exports.deleteGroup = async (req, res) => {
    try {
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Only creator can delete
        if (group.createdBy !== req.user.id) {
            return res.status(403).json({
                success: false,
                message: 'Only the group creator can delete this group'
            });
        }

        await group.deleteOne();

        res.json({
            success: true,
            message: 'Group deleted successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Add expense to group
// @route   POST /api/groups/:id/expenses
// @access  Private
exports.addExpense = async (req, res) => {
    try {
        const { paidBy, paidByName, amount, description, splits, category } = req.body;
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Check if user is a member
        const isMember = group.members.some(m => m.userId === req.user.id);
        if (!isMember) {
            return res.status(403).json({
                success: false,
                message: 'You are not a member of this group'
            });
        }

        // Add expense
        group.expenses.push({
            paidBy,
            paidByName,
            amount,
            description: description || 'Group Expense',
            splits,
            category: category || 'other',
            date: new Date()
        });

        // Update member balances
        for (const split of splits) {
            const memberIndex = group.members.findIndex(m => m.userId === split.memberId);
            if (memberIndex !== -1) {
                group.members[memberIndex].amountOwed += split.amount;
            }
        }

        // Update payer's balance
        const payerIndex = group.members.findIndex(m => m.userId === paidBy);
        if (payerIndex !== -1) {
            group.members[payerIndex].amountLent += amount;
        }

        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Expense added successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

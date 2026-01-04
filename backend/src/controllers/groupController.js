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

        console.log('=== GET GROUPS DEBUG ===');
        console.log('Looking for userId:', userId);
        console.log('userId type:', typeof userId);

        // Find all groups where user is a member
        const groups = await Group.find({
            'members.userId': userId
        }).sort({ createdAt: -1 });

        console.log('Found groups:', groups.length);
        if (groups.length > 0) {
            console.log('First group members:', groups[0].members.map(m => ({
                userId: m.userId,
                email: m.email
            })));
        }

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
        const { memberEmail } = req.body;
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

        // Find user by email
        const User = require('../models/User');
        const user = await User.findOne({ email: memberEmail });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found with this email'
            });
        }

        console.log('=== ADD MEMBER DEBUG ===');
        console.log('Found user._id:', user._id);
        console.log('Found user._id type:', typeof user._id);
        console.log('Current user (req.user.id):', req.user.id);
        console.log('Current user type:', typeof req.user.id);

        // Check if user is already a member (by userId or email)
        const alreadyMember = group.members.some(m =>
            m.userId === user._id.toString() || m.email === memberEmail
        );
        if (alreadyMember) {
            return res.status(400).json({
                success: false,
                message: 'User is already a member'
            });
        }

        // Add member - use same format as req.user.id
        const userIdToStore = user._id.toString();
        console.log('Storing userId:', userIdToStore);

        group.members.push({
            userId: userIdToStore,
            name: user.name,
            email: user.email,
            amountOwed: 0,
            amountLent: 0
        });

        await group.save();

        console.log('Member added. Group members:', group.members.map(m => ({
            userId: m.userId,
            email: m.email
        })));

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

// @desc    Leave group
// @route   POST /api/groups/:id/leave
// @access  Private
exports.leaveGroup = async (req, res) => {
    try {
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Check if user is a member
        const memberIndex = group.members.findIndex(m => m.userId === req.user.id);
        if (memberIndex === -1) {
            return res.status(400).json({
                success: false,
                message: 'You are not a member of this group'
            });
        }

        // Don't allow creator to leave if there are other members
        if (group.createdBy === req.user.id && group.members.length > 1) {
            return res.status(400).json({
                success: false,
                message: 'Group creator cannot leave. Delete the group or transfer ownership first.'
            });
        }

        // Remove member
        group.members.splice(memberIndex, 1);

        // If last member leaving, delete the group
        if (group.members.length === 0) {
            await group.deleteOne();
            return res.json({
                success: true,
                message: 'You left the group. Group has been deleted as you were the last member.'
            });
        }

        await group.save();

        res.json({
            success: true,
            message: 'You have left the group'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Transfer group ownership
// @route   POST /api/groups/:id/transfer
// @access  Private
exports.transferOwnership = async (req, res) => {
    try {
        const { newOwnerId } = req.body;
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Only current creator can transfer ownership
        if (group.createdBy !== req.user.id) {
            return res.status(403).json({
                success: false,
                message: 'Only the group creator can transfer ownership'
            });
        }

        // Check if new owner is a member
        const newOwner = group.members.find(m => m.userId === newOwnerId);
        if (!newOwner) {
            return res.status(400).json({
                success: false,
                message: 'New owner must be a member of the group'
            });
        }

        // Transfer ownership
        group.createdBy = newOwnerId;
        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Ownership transferred successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

// @desc    Settle up payment between members
// @route   POST /api/groups/:id/settle
// @access  Private
exports.settleUp = async (req, res) => {
    try {
        const { fromUserId, toUserId, amount } = req.body;
        const group = await Group.findById(req.params.id);

        if (!group) {
            return res.status(404).json({
                success: false,
                message: 'Group not found'
            });
        }

        // Verify requester is a member
        const isMember = group.members.some(m => m.userId === req.user.id);
        if (!isMember) {
            return res.status(403).json({
                success: false,
                message: 'You are not a member of this group'
            });
        }

        // Find the members involved
        const fromMember = group.members.find(m => m.userId === fromUserId);
        const toMember = group.members.find(m => m.userId === toUserId);

        if (!fromMember || !toMember) {
            return res.status(400).json({
                success: false,
                message: 'Both members must be in the group'
            });
        }

        // Update balances - person paying reduces their debt (owed), person receiving reduces what they're owed (lent)
        const fromIndex = group.members.findIndex(m => m.userId === fromUserId);
        const toIndex = group.members.findIndex(m => m.userId === toUserId);

        group.members[fromIndex].amountOwed = Math.max(0, group.members[fromIndex].amountOwed - amount);
        group.members[toIndex].amountLent = Math.max(0, group.members[toIndex].amountLent - amount);

        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Payment settled successfully'
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

// @desc    Delete expense from group
// @route   DELETE /api/groups/:id/expenses/:expenseId
// @access  Private
exports.deleteGroupExpense = async (req, res) => {
    try {
        const { expenseId } = req.params;
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

        // Find the expense
        const expenseIndex = group.expenses.findIndex(e => e._id.toString() === expenseId);
        if (expenseIndex === -1) {
            return res.status(404).json({
                success: false,
                message: 'Expense not found'
            });
        }

        const expense = group.expenses[expenseIndex];

        // Reverse the balance changes
        for (const split of expense.splits) {
            const memberIndex = group.members.findIndex(m => m.userId === split.memberId);
            if (memberIndex !== -1) {
                group.members[memberIndex].amountOwed = Math.max(0, group.members[memberIndex].amountOwed - split.amount);
            }
        }

        // Reverse payer's balance
        const payerIndex = group.members.findIndex(m => m.userId === expense.paidBy);
        if (payerIndex !== -1) {
            group.members[payerIndex].amountLent = Math.max(0, group.members[payerIndex].amountLent - expense.amount);
        }

        // Remove expense
        group.expenses.splice(expenseIndex, 1);

        await group.save();

        res.json({
            success: true,
            data: { group },
            message: 'Expense deleted successfully'
        });
    } catch (error) {
        res.status(400).json({
            success: false,
            message: error.message
        });
    }
};

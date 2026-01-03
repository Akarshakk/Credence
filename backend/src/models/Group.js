const mongoose = require('mongoose');

const groupMemberSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },
    amountOwed: {
        type: Number,
        default: 0
    },
    amountLent: {
        type: Number,
        default: 0
    }
}, { _id: false });

const expenseSplitSchema = new mongoose.Schema({
    memberId: {
        type: String,
        required: true
    },
    memberName: {
        type: String,
        required: true
    },
    amount: {
        type: Number,
        required: true
    }
}, { _id: false });

const groupExpenseSchema = new mongoose.Schema({
    paidBy: {
        type: String,
        required: true
    },
    paidByName: {
        type: String,
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    description: {
        type: String,
        default: 'Group Expense'
    },
    splits: [expenseSplitSchema],
    category: {
        type: String,
        default: 'other'
    },
    date: {
        type: Date,
        default: Date.now
    }
}, { timestamps: true });

const groupSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Group name is required'],
        trim: true
    },
    description: {
        type: String,
        default: ''
    },
    members: [groupMemberSchema],
    expenses: [groupExpenseSchema],
    createdBy: {
        type: String,
        required: true
    },
    inviteCode: {
        type: String,
        required: true,
        unique: true,
        uppercase: true,
        length: 6
    },
    imageUrl: {
        type: String,
        default: ''
    }
}, {
    timestamps: true
});

// Calculate total expenses for a group
groupSchema.methods.getTotalExpenses = function () {
    return this.expenses.reduce((sum, expense) => sum + expense.amount, 0);
};

// Get member balance (positive means they are owed, negative means they owe)
groupSchema.methods.getMemberBalance = function (userId) {
    const member = this.members.find(m => m.userId === userId);
    if (!member) return 0;
    return member.amountLent - member.amountOwed;
};

module.exports = mongoose.model('Group', groupSchema);

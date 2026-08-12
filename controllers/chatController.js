// controllers/chatController.js
const aiChatService = require('../services/aiChatService');
const { asyncHandler } = require('../middleware/errorHandler');

const chat = asyncHandler(async (req, res) => {
  try {
    const result = await aiChatService.chatWithAI(req.body.messages);
    res.json(result);
  } catch (err) {
    // Pertahankan bentuk respons error lama: { error: { message, status } }
    if (err.payload) {
      return res.status(err.statusCode || 500).json(err.payload);
    }
    throw err;
  }
});

module.exports = { chat };

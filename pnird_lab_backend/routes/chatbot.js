const router = require("express").Router();
const OpenAI = require("openai");
const vectorStore = require("../services/vectorStore");
const Conversation = require("../models/conversation");

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Initialize vector store on startup
vectorStore.initialize().catch(err => {
  console.error("Failed to initialize vector store:", err);
});

// Chat endpoint with RAG
router.post("/chat", async (req, res) => {
  try {
    const { message, conversationHistory = [], userId, conversationId } = req.body;

    if (!message || message.trim() === '') {
      return res.status(400).json({ 
        error: "Message is required" 
      });
    }

    // Search for relevant context from PDF
    let context = "";
    let hasContext = false;
    
    try {
      const relevantChunks = await vectorStore.search(message, 3);
      if (relevantChunks.length > 0) {
        context = relevantChunks
          .map(chunk => chunk.text)
          .join('\n\n---\n\n');
        hasContext = true;
      }
    } catch (error) {
      console.error("Error searching vector store:", error);
      // Continue without context if search fails
    }

    // Build system prompt with context
    let systemPrompt = `You are a helpful assistant for the PNIRD Lab at Virginia State University's Psychology Department.

Lab Information:
- Lab Director: Dr. Larry Keen
- Focus Areas: Neuropsychology, Addiction, Psychophysiology
- Research includes: Cannabis use disorder, autonomic nervous system, heart rate variability, neuroimaging
- Recent publications include work on parasympathetic responses and cannabis use

Answer questions about the lab, research, team members, and neuroscience topics. Be friendly and informative.`;

    if (context) {
      systemPrompt += `\n\nRelevant information from lab documents:\n${context}\n\nUse this information to provide accurate and specific answers when relevant.`;
    }

    // Build conversation messages
    const messages = [
      {
        role: "system",
        content: systemPrompt
      },
      ...conversationHistory.map(msg => ({
        role: msg.isUser ? "user" : "assistant",
        content: msg.text
      })),
      {
        role: "user",
        content: message
      }
    ];

    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo", // Cost-effective model
      messages: messages,
      temperature: 0.7,
      max_tokens: 500,
    });

    const response = completion.choices[0].message.content;

    // Save conversation if userId is provided
    let savedConversation = null;
    if (userId) {
      try {
        console.log(`💾 Saving conversation for userId: ${userId}, conversationId: ${conversationId || 'new'}`);
        
        // Build all messages including the new ones
        const allMessages = [
          ...conversationHistory.map(msg => ({
            text: msg.text || '',
            isUser: msg.isUser === true,
            timestamp: msg.timestamp ? new Date(msg.timestamp) : new Date(),
          })),
          {
            text: message,
            isUser: true,
            timestamp: new Date(),
          },
          {
            text: response,
            isUser: false,
            timestamp: new Date(),
          },
        ];
        
        console.log(`💬 Saving ${allMessages.length} messages (${conversationHistory.length} existing + 2 new)`);

        if (conversationId) {
          // Update existing conversation
          savedConversation = await Conversation.findByIdAndUpdate(
            conversationId,
            {
              $set: {
                messages: allMessages,
                title: allMessages[0]?.text?.substring(0, 50) || "New Conversation",
              },
            },
            { new: true }
          );
          console.log(`✅ Updated conversation: ${savedConversation?._id}`);
        } else {
          // Create new conversation
          savedConversation = await Conversation.create({
            userId: userId,
            title: message.substring(0, 50) || "New Conversation",
            messages: allMessages,
          });
          console.log(`✅ Created new conversation: ${savedConversation._id}`);
        }
      } catch (saveError) {
        console.error("❌ Error saving conversation:", saveError);
        console.error("Error details:", saveError.message);
        console.error("Stack:", saveError.stack);
        // Continue even if save fails
      }
    } else {
      console.log("⚠️  No userId provided, skipping conversation save");
    }

    res.json({ 
      answer: response,
      hasContext: hasContext,
      conversationId: savedConversation?._id?.toString(),
    });
  } catch (error) {
    console.error("Chatbot error:", error);
    
    // Handle specific OpenAI errors
    if (error.status === 401) {
      return res.status(401).json({ 
        error: "Invalid API key. Please check your OpenAI API key configuration."
      });
    }
    
    if (error.status === 429) {
      return res.status(429).json({ 
        error: "Rate limit exceeded. Please try again later."
      });
    }
    
    res.status(500).json({ 
      error: "Failed to get response from chatbot",
      message: error.message 
    });
  }
});

// Get all conversations for a user
router.get("/conversations/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    const conversations = await Conversation.find({ userId })
      .sort({ updatedAt: -1 })
      .select('title messages createdAt updatedAt')
      .lean();

    const formattedConversations = conversations.map(conv => ({
      _id: conv._id.toString(),
      title: conv.title,
      messageCount: conv.messages.length,
      createdAt: conv.createdAt ? new Date(conv.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: conv.updatedAt ? new Date(conv.updatedAt).toISOString() : new Date().toISOString(),
    }));

    res.json({ conversations: formattedConversations });
  } catch (error) {
    console.error("Error fetching conversations:", error);
    res.status(500).json({ error: "Failed to fetch conversations" });
  }
});

// Get a specific conversation
router.get("/conversations/:userId/:conversationId", async (req, res) => {
  try {
    const { userId, conversationId } = req.params;
    
    const conversation = await Conversation.findOne({
      _id: conversationId,
      userId: userId,
    }).lean();

    if (!conversation) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    const formattedMessages = conversation.messages.map(msg => ({
      text: msg.text,
      isUser: msg.isUser,
      timestamp: msg.timestamp ? new Date(msg.timestamp).toISOString() : new Date().toISOString(),
    }));

    res.json({
      _id: conversation._id.toString(),
      title: conversation.title,
      messages: formattedMessages,
      createdAt: conversation.createdAt ? new Date(conversation.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: conversation.updatedAt ? new Date(conversation.updatedAt).toISOString() : new Date().toISOString(),
    });
  } catch (error) {
    console.error("Error fetching conversation:", error);
    res.status(500).json({ error: "Failed to fetch conversation" });
  }
});

// Delete a conversation
router.delete("/conversations/:userId/:conversationId", async (req, res) => {
  try {
    const { userId, conversationId } = req.params;
    
    const result = await Conversation.deleteOne({
      _id: conversationId,
      userId: userId,
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    res.json({ success: true, message: "Conversation deleted" });
  } catch (error) {
    console.error("Error deleting conversation:", error);
    res.status(500).json({ error: "Failed to delete conversation" });
  }
});

// Update conversation title
router.patch("/conversations/:userId/:conversationId/title", async (req, res) => {
  try {
    const { userId, conversationId } = req.params;
    const { title } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: "Title is required" });
    }

    const conversation = await Conversation.findOneAndUpdate(
      { _id: conversationId, userId: userId },
      { title: title.trim() },
      { new: true }
    );

    if (!conversation) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    res.json({ success: true, title: conversation.title });
  } catch (error) {
    console.error("Error updating conversation title:", error);
    res.status(500).json({ error: "Failed to update conversation title" });
  }
});

// Health check endpoint
router.get("/health", (req, res) => {
  res.json({ 
    status: "ok",
    vectorStoreInitialized: vectorStore.initialized,
    embeddingsCount: vectorStore.embeddings.length
  });
});

module.exports = router;


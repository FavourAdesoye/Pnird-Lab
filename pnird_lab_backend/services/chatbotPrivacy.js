const Conversation = require("../models/conversation");

function envBool(name, defaultValue = false) {
  const raw = process.env[name];
  if (raw === undefined || raw === "") {
    return defaultValue;
  }
  return ["1", "true", "yes", "on"].includes(String(raw).toLowerCase());
}

function envInt(name, defaultValue) {
  const parsed = Number.parseInt(process.env[name] || "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : defaultValue;
}

const chatbotPrivacy = {
  /** When false, chat replies still work but nothing is stored in Mongo */
  saveConversations: () => envBool("CHATBOT_SAVE_CONVERSATIONS", true),
  /** Delete conversations older than this many days */
  retentionDays: () => envInt("CHATBOT_RETENTION_DAYS", 30),
  /** Cap messages kept per conversation (and sent to OpenAI as history) */
  maxMessages: () => envInt("CHATBOT_MAX_MESSAGES", 40),
};

/**
 * Keep only the most recent N messages (pairs preserved as best-effort).
 */
function truncateMessages(messages, maxMessages = chatbotPrivacy.maxMessages()) {
  if (!Array.isArray(messages) || messages.length <= maxMessages) {
    return messages || [];
  }
  return messages.slice(-maxMessages);
}

/**
 * Delete expired chatbot conversations. Safe to call on a timer.
 */
async function purgeExpiredConversations() {
  const days = chatbotPrivacy.retentionDays();
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
  const result = await Conversation.deleteMany({ updatedAt: { $lt: cutoff } });
  if (result.deletedCount > 0) {
    console.log(
      `Chatbot retention: deleted ${result.deletedCount} conversation(s) older than ${days} day(s)`
    );
  }
  return result.deletedCount || 0;
}

let retentionTimer = null;

function startConversationRetentionJob() {
  // Run once shortly after boot, then daily
  const run = () => {
    purgeExpiredConversations().catch((err) => {
      console.error("Chatbot retention cleanup failed:", err.message);
    });
  };

  setTimeout(run, 15_000);
  if (retentionTimer) {
    clearInterval(retentionTimer);
  }
  retentionTimer = setInterval(run, 24 * 60 * 60 * 1000);
  if (typeof retentionTimer.unref === "function") {
    retentionTimer.unref();
  }
}

module.exports = {
  chatbotPrivacy,
  truncateMessages,
  purgeExpiredConversations,
  startConversationRetentionJob,
};

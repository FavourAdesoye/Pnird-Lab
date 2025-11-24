const express = require("express");
const router = express.Router();
const Notification = require("../models/notifications");
const BroadcastNotification = require("../models/broadcast_notifications");
const User = require("../models/User");

// Create a new notification
router.post("/", async (req, res) => {
  try {
    const notification = new Notification(req.body);
    const saved = await notification.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mark broadcast as seen (MUST be before /:userId route)
router.patch("/:userId/broadcast/:broadcastId/seen", async (req, res) => {
  try {
    const { userId, broadcastId } = req.params;
    
    // Add broadcast ID to user's seenBroadcasts array
    await User.findByIdAndUpdate(userId, {
      $addToSet: { seenBroadcasts: broadcastId }
    });
    
    res.json({ message: "Broadcast marked as seen" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get unread notification count (MUST be before /:userId route)
router.get("/:userId/unread/count", async (req, res) => {
  try {
    const userId = req.params.userId;
    
    // Count personal unread notifications (likes, comments, messages)
    const personalUnread = await Notification.countDocuments({ 
      userId: userId, 
      isRead: false,
      type: { $in: ["like", "comment", "message"] }
    });
    
    // Count unseen broadcasts
    const user = await User.findById(userId);
    const seenBroadcastIds = user?.seenBroadcasts || [];
    
    const unseenBroadcasts = await BroadcastNotification.countDocuments({
      _id: { $nin: seenBroadcastIds },
      type: { $in: ["study", "event"] }
    });
    
    const totalUnread = personalUnread + unseenBroadcasts;
    res.json({ count: totalUnread });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mark all notifications as read (MUST be before /:userId route)
router.patch("/:userId/read-all", async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.params.userId, isRead: false },
      { isRead: true }
    );
    res.json({ message: "All notifications marked as read" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mark notification as read (MUST be before /:userId route)
router.patch("/:id/read", async (req, res) => {
  try {
    const updated = await Notification.findByIdAndUpdate(req.params.id, { isRead: true }, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a notification (MUST be before /:userId route)
router.delete("/:id", async (req, res) => {
  try {
    await Notification.findByIdAndDelete(req.params.id);
    res.json({ message: "Notification deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all notifications for a user (MUST be last - generic route)
router.get("/:userId", async (req, res) => {
  try {
    const userId = req.params.userId;
    
    // 1. Get personal notifications (likes, comments, messages)
    const personalNotifications = await Notification.find({ 
      userId: userId,
      type: { $in: ["like", "comment", "message"] }
    })
      .sort({ createdAt: -1 })
      .populate('senderId', 'username profilePicture')
      .lean();
    
    // 2. Get all broadcasts (studies, events)
    const allBroadcasts = await BroadcastNotification.find({
      type: { $in: ["study", "event"] }
    })
      .sort({ createdAt: -1 })
      .populate('senderId', 'username profilePicture')
      .lean();
    
    // 3. Get user's seen broadcasts
    const user = await User.findById(userId);
    const seenBroadcastIds = user?.seenBroadcasts || [];
    const seenBroadcastIdStrings = seenBroadcastIds.map(id => id.toString());
    
    // 4. Filter unseen broadcasts
    const unseenBroadcasts = allBroadcasts.filter(
      broadcast => !seenBroadcastIdStrings.includes(broadcast._id.toString())
    );
    
    // 5. Format personal notifications
    const formattedPersonal = personalNotifications.map(notif => ({
      ...notif,
      _id: notif._id.toString(),
      userId: notif.userId.toString(),
      isBroadcast: false,
      senderId: notif.senderId ? {
        _id: notif.senderId._id.toString(),
        username: notif.senderId.username,
        profilePicture: notif.senderId.profilePicture
      } : null,
      referenceId: notif.referenceId ? notif.referenceId.toString() : null,
      createdAt: notif.createdAt ? new Date(notif.createdAt).toISOString() : null,
      updatedAt: notif.updatedAt ? new Date(notif.updatedAt).toISOString() : null,
    }));
    
    // 6. Format broadcasts (add userId for display purposes)
    const formattedBroadcasts = unseenBroadcasts.map(broadcast => ({
      ...broadcast,
      _id: broadcast._id.toString(),
      userId: userId, // For display purposes
      isBroadcast: true,
      isRead: false, // Broadcasts are considered "unread" if unseen
      senderId: broadcast.senderId ? {
        _id: broadcast.senderId._id.toString(),
        username: broadcast.senderId.username,
        profilePicture: broadcast.senderId.profilePicture
      } : null,
      referenceId: broadcast.referenceId ? broadcast.referenceId.toString() : null,
      createdAt: broadcast.createdAt ? new Date(broadcast.createdAt).toISOString() : null,
      updatedAt: broadcast.updatedAt ? new Date(broadcast.updatedAt).toISOString() : null,
    }));
    
    // 7. Combine and sort by createdAt (newest first)
    const combined = [...formattedPersonal, ...formattedBroadcasts].sort((a, b) => {
      const dateA = new Date(a.createdAt);
      const dateB = new Date(b.createdAt);
      return dateB - dateA; // Newest first
    });
    
    res.json(combined);
  } catch (err) {
    console.error("Error fetching notifications:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

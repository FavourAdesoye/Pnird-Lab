const express = require("express");
const router = express.Router();
const Notification = require("../models/notifications");
const BroadcastNotification = require("../models/broadcast_notifications");
const User = require("../models/User");
const firebaseAuthMiddleware = require("../middleware/firebaseAuthMiddleware");
const { requireSelf } = firebaseAuthMiddleware;

router.use(firebaseAuthMiddleware);

// Mark broadcast as seen
router.patch(
  "/:userId/broadcast/:broadcastId/seen",
  requireSelf("params", "userId"),
  async (req, res) => {
    try {
      const { userId, broadcastId } = req.params;

      await User.findByIdAndUpdate(userId, {
        $addToSet: { seenBroadcasts: broadcastId },
      });

      res.json({ message: "Broadcast marked as seen" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Get unread notification count
router.get(
  "/:userId/unread/count",
  requireSelf("params", "userId"),
  async (req, res) => {
    try {
      const userId = req.params.userId;

      const personalUnread = await Notification.countDocuments({
        userId: userId,
        isRead: false,
        type: { $in: ["like", "comment", "message"] },
      });

      const user = req.mongoUser;
      const seenBroadcastIds = user?.seenBroadcasts || [];

      const unseenBroadcasts = await BroadcastNotification.countDocuments({
        _id: { $nin: seenBroadcastIds },
        type: { $in: ["study", "event"] },
      });

      const totalUnread = personalUnread + unseenBroadcasts;
      res.json({ count: totalUnread });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Mark all notifications as read
router.patch(
  "/:userId/read-all",
  requireSelf("params", "userId"),
  async (req, res) => {
    try {
      await Notification.updateMany(
        { userId: req.params.userId, isRead: false },
        { isRead: true }
      );
      res.json({ message: "All notifications marked as read" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Mark notification as read (must own the notification)
router.patch("/:id/read", async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }
    if (String(notification.userId) !== String(req.mongoUser._id)) {
      return res.status(403).json({ message: "You can only update your own notifications." });
    }
    notification.isRead = true;
    await notification.save();
    res.json(notification);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a notification (must own it)
router.delete("/:id", async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }
    if (String(notification.userId) !== String(req.mongoUser._id)) {
      return res.status(403).json({ message: "You can only delete your own notifications." });
    }
    await Notification.findByIdAndDelete(req.params.id);
    res.json({ message: "Notification deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all notifications for the authenticated user
router.get("/:userId", requireSelf("params", "userId"), async (req, res) => {
  try {
    const userId = req.params.userId;

    const personalNotifications = await Notification.find({
      userId: userId,
      type: { $in: ["like", "comment", "message"] },
    })
      .sort({ createdAt: -1 })
      .populate("senderId", "username profilePicture")
      .lean();

    const allBroadcasts = await BroadcastNotification.find({
      type: { $in: ["study", "event"] },
    })
      .sort({ createdAt: -1 })
      .populate("senderId", "username profilePicture")
      .lean();

    const user = req.mongoUser;
    const seenBroadcastIds = user?.seenBroadcasts || [];
    const seenBroadcastIdStrings = seenBroadcastIds.map((id) => id.toString());

    const unseenBroadcasts = allBroadcasts.filter(
      (broadcast) => !seenBroadcastIdStrings.includes(broadcast._id.toString())
    );

    const formattedPersonal = personalNotifications.map((notif) => ({
      ...notif,
      _id: notif._id.toString(),
      userId: notif.userId.toString(),
      isBroadcast: false,
      senderId: notif.senderId
        ? {
            _id: notif.senderId._id.toString(),
            username: notif.senderId.username,
            profilePicture: notif.senderId.profilePicture,
          }
        : null,
      referenceId: notif.referenceId ? notif.referenceId.toString() : null,
      createdAt: notif.createdAt ? new Date(notif.createdAt).toISOString() : null,
      updatedAt: notif.updatedAt ? new Date(notif.updatedAt).toISOString() : null,
    }));

    const formattedBroadcasts = unseenBroadcasts.map((broadcast) => ({
      ...broadcast,
      _id: broadcast._id.toString(),
      userId: userId,
      isBroadcast: true,
      isRead: false,
      senderId: broadcast.senderId
        ? {
            _id: broadcast.senderId._id.toString(),
            username: broadcast.senderId.username,
            profilePicture: broadcast.senderId.profilePicture,
          }
        : null,
      referenceId: broadcast.referenceId ? broadcast.referenceId.toString() : null,
      createdAt: broadcast.createdAt
        ? new Date(broadcast.createdAt).toISOString()
        : null,
      updatedAt: broadcast.updatedAt
        ? new Date(broadcast.updatedAt).toISOString()
        : null,
    }));

    const combined = [...formattedPersonal, ...formattedBroadcasts].sort((a, b) => {
      const dateA = new Date(a.createdAt);
      const dateB = new Date(b.createdAt);
      return dateB - dateA;
    });

    res.json(combined);
  } catch (err) {
    console.error("Error fetching notifications:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

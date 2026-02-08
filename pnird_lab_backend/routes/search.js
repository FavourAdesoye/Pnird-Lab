const router = require("express").Router();
const Post = require("../models/Post");
const StudiesModel = require("../models/studies");
const EventsModel = require("../models/events");
const User = require("../models/User");

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// Unified search endpoint
router.get("/", async (req, res) => {
  try {
    const { q, type } = req.query; // q = query string, type = filter (posts, studies, events, users, or 'all')
    
    if (!q || q.trim() === '') {
      return res.status(400).json({ message: "Search query is required" });
    }

    const searchQuery = q.trim();
    if (searchQuery.length > 100) {
      return res.status(400).json({ message: "Search query is too long" });
    }
    const safeRegex = new RegExp(escapeRegex(searchQuery), "i");
    const searchType = type || 'all';

    const results = {
      posts: [],
      studies: [],
      events: [],
      users: []
    };

    // Search posts
    if (searchType === 'all' || searchType === 'posts') {
      results.posts = await Post.find({
        $or: [
          { description: safeRegex }
        ]
      })
      .populate('userId', 'username profilePicture')
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();
    }

    // Search studies
    if (searchType === 'all' || searchType === 'studies') {
      results.studies = await StudiesModel.find({
        $or: [
          { titlePost: safeRegex },
          { description: safeRegex }
        ]
      })
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();
    }

    // Search events
    if (searchType === 'all' || searchType === 'events') {
      results.events = await EventsModel.find({
        $or: [
          { titlepost: safeRegex },
          { description: safeRegex },
          { location: safeRegex }
        ]
      })
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();
    }

    // Search users
    if (searchType === 'all' || searchType === 'users') {
      results.users = await User.find({
        $or: [
          { username: safeRegex },
          { email: safeRegex }
        ]
      })
      .select('username email profilePicture role')
      .limit(20)
      .lean();
    }

    // Convert dates to ISO strings for consistency
    results.posts = results.posts.map(post => ({
      ...post,
      _id: post._id.toString(),
      userId: post.userId ? {
        ...post.userId,
        _id: post.userId._id.toString()
      } : null,
      createdAt: post.createdAt ? new Date(post.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: post.updatedAt ? new Date(post.updatedAt).toISOString() : new Date().toISOString()
    }));

    results.studies = results.studies.map(study => ({
      ...study,
      _id: study._id.toString(),
      createdAt: study.createdAt ? new Date(study.createdAt).toISOString() : new Date().toISOString(),
      updatedAt: study.updatedAt ? new Date(study.updatedAt).toISOString() : new Date().toISOString()
    }));

    results.events = results.events.map(event => ({
      ...event,
      _id: event._id.toString(),
      createdAt: event.createdAt ? new Date(event.createdAt).toISOString() : new Date().toISOString(),
      dateofevent: event.dateofevent ? new Date(event.dateofevent).toISOString() : null
    }));

    results.users = results.users.map(user => ({
      ...user,
      _id: user._id.toString()
    }));

    res.status(200).json(results);
  } catch (error) {
    console.error("Search error:", error);
    res.status(500).json({ message: "Error performing search" });
  }
});

// Autocomplete/suggestions endpoint - returns lightweight suggestions
router.get("/suggestions", async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.trim() === '' || q.length < 2) {
      return res.status(200).json({ suggestions: [] });
    }

    const searchQuery = q.trim();
    if (searchQuery.length > 100) {
      return res.status(200).json({ suggestions: [] });
    }
    const safeRegex = new RegExp(escapeRegex(searchQuery), "i");
    const suggestions = [];

    // Get quick suggestions from each category (limited to 3-5 each for performance)
    try {
      // Post suggestions (just titles/descriptions)
      const postSuggestions = await Post.find({
        description: safeRegex
      })
      .select('description _id')
      .limit(3)
      .lean();
      
      postSuggestions.forEach(post => {
        suggestions.push({
          type: 'post',
          text: post.description?.substring(0, 50) || 'Post',
          id: post._id.toString()
        });
      });

      // Study suggestions
      const studySuggestions = await StudiesModel.find({
        $or: [
          { titlePost: safeRegex },
          { description: safeRegex }
        ]
      })
      .select('titlePost description _id')
      .limit(3)
      .lean();
      
      studySuggestions.forEach(study => {
        suggestions.push({
          type: 'study',
          text: study.titlePost || study.description?.substring(0, 50) || 'Study',
          id: study._id.toString()
        });
      });

      // Event suggestions
      const eventSuggestions = await EventsModel.find({
        $or: [
          { titlepost: safeRegex },
          { location: safeRegex }
        ]
      })
      .select('titlepost location _id')
      .limit(3)
      .lean();
      
      eventSuggestions.forEach(event => {
        suggestions.push({
          type: 'event',
          text: event.titlepost || event.location || 'Event',
          id: event._id.toString()
        });
      });

      // User suggestions
      const userSuggestions = await User.find({
        $or: [
          { username: safeRegex },
          { email: safeRegex }
        ]
      })
      .select('username email _id')
      .limit(3)
      .lean();
      
      userSuggestions.forEach(user => {
        suggestions.push({
          type: 'user',
          text: user.username || user.email || 'User',
          id: user._id.toString()
        });
      });

      res.status(200).json({ suggestions: suggestions.slice(0, 10) }); // Limit to 10 total suggestions
    } catch (error) {
      console.error("Suggestions error:", error);
      res.status(200).json({ suggestions: [] }); // Return empty on error
    }
  } catch (error) {
    console.error("Suggestions error:", error);
    res.status(200).json({ suggestions: [] });
  }
});

module.exports = router;

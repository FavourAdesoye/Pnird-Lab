import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/pages/chats_page.dart';
import 'package:pnirdlab/pages/studies.dart';
import 'package:pnirdlab/pages/events_page.dart';
import 'package:pnirdlab/pages/message_page.dart';
import 'package:pnirdlab/pages/post_detail_page.dart';
import 'package:pnirdlab/pages/studies_details.dart';
import 'package:pnirdlab/pages/events_detail_page.dart';
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/model/study_model.dart';

String formattedDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
}

String getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    return 'Just now';
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  String? userId;
  bool isLoading = true;
  int unreadCount = 0;
  SocketService? _socketService;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    
    if (userId != null) {
      await loadUserAndNotifications();
      _setupSocketListener();
      _loadUnreadCount();
    }
  }

  Future<void> loadUserAndNotifications() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      if (userId != null) {
        final fetchedNotifications = await NotificationService.fetchNotifications(userId!);
        setState(() {
          notifications = fetchedNotifications;
          isLoading = false;
        });
        _loadUnreadCount();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    if (userId != null) {
      final count = await NotificationService.getUnreadCount(userId!);
      setState(() {
        unreadCount = count;
      });
    }
  }

  void _setupSocketListener() {
    if (userId == null) return;
    
    _socketService = SocketService();
    _socketService!.connect(userId!);
    
    // Listen for personal notifications (likes, comments, messages)
    _socketService!.socket.on("new_notification", (data) {
      // Add new notification to the top of the list
      setState(() {
        notifications.insert(0, data);
        if (!data['isRead']) {
          unreadCount++;
        }
      });
    });
    
    // Listen for broadcast notifications (studies, events)
    _socketService!.socket.on("new_broadcast", (data) {
      // Add broadcast to the top of the list
      setState(() {
        final broadcastData = {
          ...data,
          'isBroadcast': true,
          'isRead': false,
          'userId': userId,
        };
        notifications.insert(0, broadcastData);
        unreadCount++;
      });
    });
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    if (notifications[index]['isRead'] == true) return;
    
    // Handle broadcasts differently
    if (notifications[index]['isBroadcast'] == true) {
      if (userId != null) {
        await NotificationService.markBroadcastAsSeen(userId!, notificationId);
      }
    } else {
      await NotificationService.markAsRead(notificationId);
    }
    
    setState(() {
      notifications[index]['isRead'] = true;
      if (unreadCount > 0) {
        unreadCount--;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    if (userId == null || unreadCount == 0) return;
    
    // Mark personal notifications as read
    await NotificationService.markAllAsRead(userId!);
    
    // Mark all unseen broadcasts as seen
    final unseenBroadcasts = notifications.where((notif) => 
      notif['isBroadcast'] == true && notif['isRead'] != true
    ).toList();
    
    for (var broadcast in unseenBroadcasts) {
      await NotificationService.markBroadcastAsSeen(userId!, broadcast['_id']);
    }
    
    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = true;
      }
      unreadCount = 0;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    // Don't allow deleting broadcasts - they're shared by all users
    if (notifications[index]['isBroadcast'] == true) {
      // Instead, mark as seen
      if (userId != null) {
        await NotificationService.markBroadcastAsSeen(userId!, notificationId);
        setState(() {
          notifications[index]['isRead'] = true;
          if (unreadCount > 0) unreadCount--;
        });
      }
      return;
    }
    
    await NotificationService.deleteNotification(notificationId);
    setState(() {
      if (!notifications[index]['isRead']) {
        if (unreadCount > 0) unreadCount--;
      }
      notifications.removeAt(index);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _navigateToNotification(dynamic notif) async {
    final type = notif['type'];
    final isBroadcast = notif['isBroadcast'] == true;
    final referenceId = notif['referenceId'];
    final senderId = notif['senderId'];
    
    // Mark broadcast as seen when user clicks on it
    if (isBroadcast && userId != null && !notif['isRead']) {
      NotificationService.markBroadcastAsSeen(userId!, notif['_id']);
      setState(() {
        notif['isRead'] = true;
        if (unreadCount > 0) {
          unreadCount--;
        }
      });
    }
    
    try {
      switch (type) {
        case 'message':
          // Navigate to specific conversation with sender
          // senderId can be an object (populated) or a string (ID)
          String? senderIdStr;
          String senderName = 'Unknown User';
          
          if (senderId != null) {
            if (senderId is Map) {
              senderIdStr = senderId['_id']?.toString();
              senderName = senderId['username'] ?? 'Unknown User';
            } else {
              senderIdStr = senderId.toString();
            }
          }
          
          if (senderIdStr != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagePage(
                  recipientId: senderIdStr!,
                  recipientName: senderName,
                  isAdmin: false,
                ),
              ),
            );
          } else {
            // Fallback to chats page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatsPage()),
            );
          }
          break;
          
        case 'comment':
        case 'like':
        case 'new_post':
          // Navigate to specific post
          if (referenceId != null) {
            await _navigateToPost(referenceId);
          } else {
            // Fallback to home feed
            Navigator.pushNamed(context, '/home');
          }
          break;
          
        case 'study':
          // Navigate to specific study
          if (referenceId != null) {
            await _navigateToStudy(referenceId);
          } else {
            // Fallback to studies page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudiesPage()),
            );
          }
          break;
          
        case 'event':
          // Navigate to specific event
          if (referenceId != null) {
            await _navigateToEvent(referenceId);
          } else {
            // Fallback to events page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventsPage()),
            );
          }
          break;
          
        default:
          // Default to home
          Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      // Show error and fallback to general page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Fallback navigation based on type
      switch (type) {
        case 'message':
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatsPage()));
          break;
        case 'study':
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StudiesPage()));
          break;
        case 'event':
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage()));
          break;
        default:
          Navigator.pushNamed(context, '/home');
      }
    }
  }

  Future<void> _navigateToPost(String postId) async {
    try {
      // Fetch the specific post
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/posts/$postId"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        final postData = jsonDecode(response.body);
        final post = Post.fromJson(postData);
        
        // Navigate to post detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              posts: [post],
              initialIndex: 0,
            ),
          ),
        );
      } else {
        // Fallback to home if post not found
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      print('Error fetching post: $e');
      Navigator.pushNamed(context, '/home');
    }
  }

  Future<void> _navigateToStudy(String studyId) async {
    try {
      // Fetch the specific study
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/studies/$studyId"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        final studyData = jsonDecode(response.body);
        final study = Study.fromJson(studyData);
        
        // Navigate to study detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyDetailsPage(study: study),
          ),
        );
      } else {
        // Fallback to studies page if study not found
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudiesPage()),
        );
      }
    } catch (e) {
      print('Error fetching study: $e');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudiesPage()),
      );
    }
  }

  Future<void> _navigateToEvent(String eventId) async {
    try {
      // Fetch all events and find the one we need
      // (Since there's no single event endpoint, we fetch all and filter)
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/events/events"),
        headers: ApiService.headers,
      );
      
      if (response.statusCode == 200) {
        final List events = jsonDecode(response.body);
        dynamic eventData;
        try {
          eventData = events.firstWhere(
            (event) => event['_id'] == eventId,
          );
        } catch (e) {
          eventData = null;
        }
        
        if (eventData != null) {
          // Navigate to event detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: eventData),
            ),
          );
        } else {
          // Event not found, fallback to events page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventsPage()),
          );
        }
      } else {
        // Fallback to events page if fetch fails
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsPage()),
        );
      }
    } catch (e) {
      print('Error fetching event: $e');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EventsPage()),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'new_post':
        return Icons.post_add;
      case 'study':
        return Icons.science;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'message':
        return Colors.blue;
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.green;
      case 'new_post':
        return Colors.purple;
      case 'study':
        return Colors.orange;
      case 'event':
        return Colors.teal;
      default:
        return Colors.yellow;
    }
  }

  @override
  void dispose() {
    _socketService?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadUserAndNotifications,
      color: Colors.yellow,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            )
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications yet",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pull down to refresh",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header with mark all as read button
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]
                          : Colors.yellow.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _markAllAsRead,
                              child: const Text(
                                'Mark all as read',
                                style: TextStyle(color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Notifications list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                          final isRead = notif['isRead'] == true;
                          final type = notif['type'] ?? 'notification';
                          final timestamp = notif['createdAt'] ?? notif['timestamp'];
                          final dateTime = timestamp != null 
                              ? DateTime.parse(timestamp).toLocal()
                              : DateTime.now();
                          
                          return Dismissible(
                            key: Key(notif['_id'] ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _deleteNotification(notif['_id'], index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? (isRead ? Colors.grey[900] : Colors.grey[800])
                                  : (isRead ? Colors.white : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRead 
                                      ? Colors.yellow.withValues(alpha: 0.2)
                                      : Colors.yellow.withValues(alpha: 0.5),
                                  width: isRead ? 1 : 2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _getNotificationColor(type).withValues(alpha: 0.3),
                                      child: Icon(
                                        _getNotificationIcon(type),
                                        color: _getNotificationColor(type),
                                      ),
                                    ),
                                    if (!isRead)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.yellow,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  notif['message'] ?? 'Notification',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    getRelativeTime(dateTime),
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                trailing: PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey
                                      : Colors.grey[600],
                                  ),
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                                  onSelected: (value) {
                                    if (value == 'read') {
                                      _markAsRead(notif['_id'], index);
                                    } else if (value == 'delete') {
                                      _deleteNotification(notif['_id'], index);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    final isBroadcast = notif['isBroadcast'] == true;
                                    final isDark = Theme.of(context).brightness == Brightness.dark;
                                    return [
                                      PopupMenuItem(
                                        value: 'read',
                                        child: Text(
                                          isRead ? 'Mark as unread' : 'Mark as read',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      // Don't show delete option for broadcasts
                                      if (!isBroadcast)
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                    ];
                                  },
),
                  onTap: () {
                                  _markAsRead(notif['_id'], index);
                                  _navigateToNotification(notif);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
            ),
    );
  }
}

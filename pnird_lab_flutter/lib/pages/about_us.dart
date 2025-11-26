import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pnirdlab/model/team_member.dart';
import 'package:pnirdlab/services/team_service.dart';
import 'package:pnirdlab/pages/cv_viewer_page.dart';
import 'package:pnirdlab/pages/chatbot/main_chatbot.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  // Get team members from service
  late final List<TeamMember> teamMembers;

  @override
  void initState() {
    super.initState();
    teamMembers = TeamService.getTeamMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: const Text('About Us'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Chathome()),
          );
        },
        backgroundColor: Colors.yellow,
        child: const Icon(
          Icons.chat_bubble,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Image Section with overlay
            _buildHeroSection(),
            
            const SizedBox(height: 30),
            
            // About Section with lab information
            _buildAboutSection(),
            
            const SizedBox(height: 40),
            
            // Team Section with member tiles
            _buildTeamSection(),
            
            const SizedBox(height: 40),
            
            // Contact Section
            _buildContactSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Builds the hero section with lab group photo and overlay
  Widget _buildHeroSection() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/pnird_group_photo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      
      ),
    );
  }

  /// Builds the about section with vision, mission, and capabilities
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Our Lab',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Our Vision',
            'To be a leading research laboratory in neuroscience, advancing our understanding of the brain and developing innovative solutions for neurological challenges through cutting-edge research and collaboration.',
            Icons.visibility,
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Our Mission',
            'We conduct cutting-edge research in neuroscience, collaborate with global partners, and train the next generation of researchers to make meaningful contributions to brain science and improve human health.',
            Icons.flag,
          ),
          
          const SizedBox(height: 20),
          
          _buildInfoCard(
            'Our Capabilities',
            'Advanced brain imaging, machine learning applications, behavioral studies, data analysis, computational modeling, and collaborative research across multiple disciplines including neuroscience, psychology, and technology.',
            Icons.science,
          ),
        ],
      ),
    );
  }

  /// Builds the team section with member tiles in a grid layout
  Widget _buildTeamSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meet Our Team',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Team Members Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              return _buildTeamMemberCard(teamMembers[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Builds the contact section with interactive contact cards
  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildContactCard(
            'Email Us',
            'info@pnirdlab.com',
            Icons.email,
            () => _launchEmail('info@pnirdlab.com'),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactCard(
            'Visit Our Lab',
            '123 Research Avenue, Science District',
            Icons.location_on,
            () => _launchMaps('123 Research Avenue, Science District'),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactCard(
            'Call Us',
            '+1 (555) 123-4567',
            Icons.phone,
            () => _launchPhone('+15551234567'),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds an information card with icon, title, and content
  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.yellow, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a team member card for the grid layout
  Widget _buildTeamMemberCard(TeamMember member) {
    return GestureDetector(
      onTap: () => _showMemberDetails(member),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile picture
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(member.profileImage),
            ),
            const SizedBox(height: 6),
            
            // Member name
            Text(
              member.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            
            // Member role
            Text(
              member.role,
              style: TextStyle(
                fontSize: 11,
                color: Colors.yellow[300],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            
            // Department
            Text(
              member.department,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a contact card with interactive functionality
  Widget _buildContactCard(String title, String content, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.yellow.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.yellow, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  /// Shows detailed member information in a modal bottom sheet
  void _showMemberDetails(TeamMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(member.profileImage),
                    ),
                    const SizedBox(height: 16),
                    
                    // Member name
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Member role
                    Text(
                      member.role,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.yellow[300],
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Department
                    Text(
                      member.department,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bio
                    Text(
                      member.bio,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Specializations as tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: member.specializations.map((spec) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 12,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Contact action buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        if (member.email.isNotEmpty)
                          _buildActionButton(
                            Icons.email,
                            'Email',
                            () => _launchEmail(member.email),
                          ),
                        if (member.linkedin != null)
                          _buildActionButton(
                            Icons.link,
                            'LinkedIn',
                            () => _launchUrl(member.linkedin!),
                          ),
                        if (member.github != null)
                          _buildActionButton(
                            Icons.code,
                            'GitHub',
                            () => _launchUrl(member.github!),
                          ),
                        if (member.cvUrl != null)
                          _buildActionButton(
                            Icons.description,
                            'CV',
                            () => _viewCv(member.cvUrl!, member.name),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                     // Publications section
                    if (member.publications.isNotEmpty) ...[
                      const Text(
                        'Publications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...member.publications.map((publication) => GestureDetector(
                        onTap: () => _viewPublication(publication.pdfPath, publication.title),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      publication.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (publication.journal != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${publication.journal}${publication.year != null ? ' (${publication.year})' : ''}',
                                        style: TextStyle(
                                          color: Colors.yellow[300],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                    if (publication.authors != null && publication.authors!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        publication.authors!.join(', '),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new,
                                color: Colors.yellow,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                      const SizedBox(height: 20),
                    ],
                    
                    // Bottom padding for safe area
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an action button for member details
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.withOpacity(0.5)),
            ),
            child: Icon(icon, color: Colors.yellow, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  /// Launches email application with the specified email address
  Future<void> _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Show error message if email app is not available
        _showEmailError(email);
      }
    } catch (e) {
      // Show error message if email launch fails
      _showEmailError(email);
    }
  }

  /// Shows error message when email cannot be launched
  void _showEmailError(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Email Not Available',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to open email app. You can copy the email address:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Copy email to clipboard
                      Clipboard.setData(ClipboardData(text: email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, color: Colors.yellow),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  /// Launches phone application with the specified phone number
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// Launches maps application with the specified address
  Future<void> _launchMaps(String address) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      path: 'maps.google.com/maps',
      query: 'q=$address',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    }
  }

  /// Launches URL in the default browser
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens CV viewer page
  void _viewCv(String cvPath, String memberName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CvViewerPage(
          cvPath: cvPath,
          memberName: memberName,
        ),
      ),
    );
  }

  /// Opens publication PDF viewer page
  void _viewPublication(String pdfPath, String publicationTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CvViewerPage(
          cvPath: pdfPath,
          memberName: publicationTitle,
        ),
      ),
    );
  }
}

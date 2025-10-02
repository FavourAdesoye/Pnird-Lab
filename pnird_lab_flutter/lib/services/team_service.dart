import 'package:pnirdlab/model/team_member.dart';

/// Service for managing team member data
class TeamService {
  /// Sample team members data - replace with real lab member information
  static List<TeamMember> getTeamMembers() {
    return [
      TeamMember(
        id: '1',
        name: 'Dr. Larry Keen',
        role: 'Lab Director',
        bio: 'Leading researcher in neuroscience with 15+ years of experience in brain imaging and cognitive studies. Published over 50 research papers and led multiple international collaborations.',
        profileImage: 'assets/images/defaultprofilepic.png',
        email: 'lkeen@vsu.edu',
        linkedin: 'https://linkedin.com/in/sarahjohnson',
        twitter: 'https://twitter.com/sarahjohnson',
        website: 'https://sarahjohnson.com',
        cvUrl: 'https://sarahjohnson.com/cv.pdf',
        specializations: ['Neuroscience', 'Brain Imaging', 'Cognitive Studies', 'Research Leadership'],
        department: 'Research',
      ),
      TeamMember(
        id: '2',
        name: 'Alexis Morris',
        role: 'Clinical Research Assistant & Program Coordinator',
        bio: 'Alexis Morris is a second-year Health Psychology PhD student at Virginia State University whose research interests include exploring the associations among reproductive health throughout the perinatal period, cardiovascular activity, and substance use among African American women. Her ultimate goal is to become a reproductive health researcher specializing in cardiovascular health and substance use. Alexis also desires to become a doula.',
        profileImage: 'assets/images/Headshot-image_6483441.JPG',
        email: 'amorris@vsu.edu',
        linkedin: 'https://www.linkedin.com/in/alexismorris29',
        cvUrl: 'assets/cv/Morris_CV.pdf',
        specializations: ['Substance Use', 'Cannabis Use', 'Cardiovascular Activity', 'Somatic Symptoms', 'Maternal Health', 'Reproductive Health'],
        department: 'Psychology',
      ),
      TeamMember(
        id: '3',
        name: 'Brittany S. Powell, MPH',
        role: 'Program Manager',
        bio: 'Experienced Public Health professional with a demonstrated history of working in emergency preparedness, population health, & community outreach. Skilled in project management, public speaking, program development, and community coalition building. I have a passion for servant leadership & creating health equity initiatives.',
        profileImage: 'assets/images/grad photo.jpg',
        email: 'bspowell@vsu.edu',
        linkedin: 'https://www.linkedin.com/in/brittany-powell-mph-75b19089',
        cvUrl: 'assets/cv/B. Powell Resume_Updated (1).pdf',
        specializations: ['Public Health', 'Emergency Preparedness', 'Community Health & Outreach'],
        department: 'Honors College, Ce. Otter, & Wright Center for Clinical & Translational Sciences - VSU Site Team',
      ),
      TeamMember(
        id: '4',
        name: 'Davian Clifton',
        role: 'Ce Otter Scholar/Research Assistant',
        bio: 'Senior Psychology Major at Virginia State University',
        profileImage: 'assets/images/Clifton Profile Image.jpg',
        email: 'dcli9928@students.vsu.edu',
        linkedin: 'https://www.linkedin.com/in/davian-clifton-34a9a5266/',
        cvUrl: 'assets/cv/2025 Davian CV.docx',
        specializations: ['Sexual Minority Mental Health Disparities'],
        department: 'Psychology Research',
      ),
    ];
  }

  /// Get team members by department
  static List<TeamMember> getTeamMembersByDepartment(String department) {
    return getTeamMembers().where((member) => member.department == department).toList();
  }

  /// Get team member by ID
  static TeamMember? getTeamMemberById(String id) {
    try {
      return getTeamMembers().firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }
}

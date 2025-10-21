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
        bio: 'Neuropsychology and addiction researcher with 12+ years of experience. Published over 50 publications papers and led multiple national and community-oriented collaborations',
        profileImage: 'assets/images/drKeen.jpg',
        email: 'lkeen@vsu.edu',
        linkedin: ' www.linkedin.com/in/larry-keen-ii-ph-d-10b75735',
        website: 'http://www.pnird.com/',
        cvUrl: 'https://sarahjohnson.com/cv.pdf',
        specializations: ['Neuropsychology', 'Addiction', 'Psychophysiology'],
        department: 'Psychology, Center for Outreach and Treatment Through Education and Research (Ce. OTTER)',
        publications: [
          Publication(
            title: 'Neural correlates of addiction recovery: A longitudinal study',
            pdfPath: 'assets/publications/keen_neural_correlates_2023.pdf',
            journal: 'Journal of Neuropsychology',
            year: 2023,
            authors: ['L. Keen'],
          ),
          Publication(
            title: 'Psychophysiological markers of substance dependence',
            pdfPath: 'assets/publications/keen_psychophysiological_2022.pdf',
            journal: 'Addiction Research',
            year: 2022,
            authors: ['L. Keen', 'J. Smith'],
          ),
          Publication(
            title: 'Cognitive rehabilitation in addiction treatment: A meta-analysis',
            pdfPath: 'assets/publications/keen_cognitive_rehab_2021.pdf',
            journal: 'Clinical Psychology Review',
            year: 2021,
            authors: ['L. Keen', 'M. Johnson', 'K. Brown'],
          ),
        ],
      ),
      TeamMember(
        id: '2',
        name: 'Alexis Morris',
        role: 'Clinical Research Assistant & Program Coordinator',
        bio: 'Alexis Morris is a second-year Health Psychology PhD student at Virginia State University whose research interests include exploring the associations among reproductive health throughout the perinatal period, cardiovascular activity, and substance use among African American women. Her ultimate goal is to become a reproductive health researcher specializing in cardiovascular health and substance use. Alexis also desires to become a doula.',
        profileImage: 'assets/images/grad photo.jpg',
        email: 'amorris@vsu.edu',
        linkedin: 'https://www.linkedin.com/in/alexismorris29',
        cvUrl: 'assets/cv/Morris_CV.pdf',
        specializations: ['Substance Use', 'Cannabis Use', 'Cardiovascular Activity', 'Somatic Symptoms', 'Maternal Health', 'Reproductive Health'],
        department: 'Psychology',
        publications: [
          Publication(
            title: 'Cardiovascular responses to cannabis use during pregnancy: A pilot study',
            pdfPath: 'assets/publications/morris_cardiovascular_2024.pdf',
            journal: 'Maternal and Child Health Journal',
            year: 2024,
            authors: ['A. Morris'],
          ),
          Publication(
            title: 'Substance use patterns among African American women in perinatal period',
            pdfPath: 'assets/publications/morris_substance_use_2023.pdf',
            journal: 'Journal of Women\'s Health',
            year: 2023,
            authors: ['A. Morris', 'R. Williams'],
          ),
        ],
      ),
      TeamMember(
        id: '3',
        name: 'Brittany S. Powell, MPH',
        role: 'Program Manager',
        bio: 'Experienced Public Health professional with a demonstrated history of working in emergency preparedness, population health, & community outreach. Skilled in project management, public speaking, program development, and community coalition building. I have a passion for servant leadership & creating health equity initiatives.',
        profileImage: 'assets/images/Headshot-image_6483441.JPG',
        email: 'bspowell@vsu.edu',
        linkedin: 'https://www.linkedin.com/in/brittany-powell-mph-75b19089',
        cvUrl: 'assets/cv/B. Powell Resume_Updated (1).pdf',
        specializations: ['Public Health', 'Emergency Preparedness', 'Community Health & Outreach'],
        department: 'Honors College, Ce. Otter, & Wright Center for Clinical & Translational Sciences - VSU Site Team',
        publications: [
          Publication(
            title: 'Community health interventions during public health emergencies',
            pdfPath: 'assets/publications/powell_community_health_2023.pdf',
            journal: 'American Journal of Public Health',
            year: 2023,
            authors: ['B.S. Powell'],
          ),
          Publication(
            title: 'Building resilient communities: A framework for emergency preparedness',
            pdfPath: 'assets/publications/powell_resilient_communities_2022.pdf',
            journal: 'Health Promotion Practice',
            year: 2022,
            authors: ['B.S. Powell', 'L. Davis', 'M. Thompson'],
          ),
        ],
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
        publications: [
          Publication(
            title: 'Mental health disparities in sexual minority populations: A systematic review',
            pdfPath: 'assets/publications/clifton_mental_health_2024.pdf',
            journal: 'Psychology of Sexual Orientation and Gender Diversity',
            year: 2024,
            authors: ['D. Clifton'],
          ),
          Publication(
            title: 'Intersectionality and mental health outcomes in LGBTQ+ communities',
            pdfPath: 'assets/publications/clifton_intersectionality_2023.pdf',
            journal: 'Journal of Counseling Psychology',
            year: 2023,
            authors: ['D. Clifton', 'S. Martinez'],
          ),
        ],
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
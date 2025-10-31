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
        linkedin: 'https://www.linkedin.com/in/larry-keen-ii-ph-d-10b75735',
        website: 'http://www.pnird.com/',
        cvUrl: '',
        specializations: ['Neuropsychology', 'Addiction', 'Psychophysiology'],
        department: 'Psychology, Center for Outreach and Treatment Through Education and Research (Ce. OTTER)',
        publications: [
          Publication(
            title: 'Parasympathetic decreases immediately following self-reported cannabis smoking among adults living with cannabis use disorder',
            pdfPath: 'assets/publications/Parasympathetic decreases.pdf',
            journal: 'International Journal of Psychophysiology',
            year: 2025,
            authors: ['Larry Keen', 'Caroline Bena Kuno' 'Alexis Morris' ],
          ),
          Publication(
            title: 'Relationship between central autonomic effective connectivity and heart rate variability: A Resting-state fMRI dynamic causal modeling study',
            pdfPath: 'assets/publications/Relationship between central autonomic.pdf',
            journal: 'NeuroImage',
            year: 2024,
            authors: ['Liangsuo Ma', 'Larry D. Keen II', 'Joel L. Steinberg', 'David Eddie', 'Alex Tan', 'Lori Keyser-Marcus', 'Antonio Abbate', 'F. Gerard Moeller'],
          ),
         
          Publication(
            title: 'Differences in internalizing symptoms between those with and without Cannabis Use Disorder among HBCU undergraduate students',
            pdfPath: 'assets/publications/Differences in internalizing symptoms between those with and without Cannabis Use Disorder among HBCU undergraduate students.pdf',
            journal: 'Journal of american college HealtH',
            year: 2021,
            authors: ['Larry Keen II, PhD',  'Arlener D. Turner, PhD', 'Toni Harris, PhD', 'Lauren George, PhD', 'Jonae Crump, BS'],
          ),
           Publication(
            title: 'The Psychoneuroimmunological Influences 1 of Recreational Marijuana',
            pdfPath: 'assets/publications/The Psychoneuroimmunological Influences of Recreational Marijuana Chapter.pdf',
            journal: 'Springer International Publishing AG',
            year: 2017,
            authors: ['Larry Keen II', 'Arlener D. Turner', 'Deidre Pereira', 'Clive Callender', ' Alfonso Campbell'],
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
        publications: [],
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
        publications: [],
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
        publications: [],
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

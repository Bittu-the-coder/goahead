// Badge definitions for FocusFlow gamification
export const BADGES = [
  // Streak badges
  { id: 'streak_3', name: 'Getting Started', icon: '🔥', description: '3 day study streak', type: 'streak', requirement: 3 },
  { id: 'streak_7', name: 'Weekly Warrior', icon: '⚔️', description: '7 day study streak', type: 'streak', requirement: 7 },
  { id: 'streak_14', name: 'Consistent', icon: '💪', description: '14 day study streak', type: 'streak', requirement: 14 },
  { id: 'streak_30', name: 'Monthly Master', icon: '👑', description: '30 day study streak', type: 'streak', requirement: 30 },
  { id: 'streak_100', name: 'Legendary', icon: '🏆', description: '100 day study streak', type: 'streak', requirement: 100 },

  // Study hours badges
  { id: 'hours_1', name: 'First Hour', icon: '⏰', description: 'Study for 1 hour total', type: 'hours', requirement: 60 },
  { id: 'hours_10', name: 'Dedicated', icon: '📚', description: '10 hours studied', type: 'hours', requirement: 600 },
  { id: 'hours_50', name: 'Scholar', icon: '🎓', description: '50 hours studied', type: 'hours', requirement: 3000 },
  { id: 'hours_100', name: 'Expert', icon: '🌟', description: '100 hours studied', type: 'hours', requirement: 6000 },
  { id: 'hours_500', name: 'Master', icon: '💎', description: '500 hours studied', type: 'hours', requirement: 30000 },

  // Session badges
  { id: 'first_session', name: 'First Steps', icon: '🎯', description: 'Complete first study session', type: 'sessions', requirement: 1 },
  { id: 'sessions_10', name: 'Regular', icon: '📖', description: 'Complete 10 study sessions', type: 'sessions', requirement: 10 },
  { id: 'sessions_50', name: 'Committed', icon: '🔰', description: 'Complete 50 study sessions', type: 'sessions', requirement: 50 },
  { id: 'sessions_100', name: 'Centurion', icon: '🛡️', description: 'Complete 100 study sessions', type: 'sessions', requirement: 100 },

  // Special badges
  { id: 'early_bird', name: 'Early Bird', icon: '🌅', description: 'Study before 6 AM', type: 'special', requirement: 1 },
  { id: 'night_owl', name: 'Night Owl', icon: '🦉', description: 'Study after 11 PM', type: 'special', requirement: 1 },
  { id: 'weekend_warrior', name: 'Weekend Warrior', icon: '🗓️', description: 'Study on both Saturday and Sunday', type: 'special', requirement: 1 },
  { id: 'perfect_week', name: 'Perfect Week', icon: '💯', description: 'Study every day for a week', type: 'special', requirement: 7 }
];

// Get badge by ID
export const getBadgeById = (id) => BADGES.find(b => b.id === id);

// Get badges by type
export const getBadgesByType = (type) => BADGES.filter(b => b.type === type);

// Check if user qualifies for a badge
export const checkBadgeEligibility = (user, badge) => {
  switch (badge.type) {
    case 'streak':
      return user.studyStats?.currentStreak >= badge.requirement ||
             user.studyStats?.longestStreak >= badge.requirement;
    case 'hours':
      return user.studyStats?.totalMinutes >= badge.requirement;
    case 'sessions':
      return user.studyStats?.totalSessions >= badge.requirement;
    default:
      return false;
  }
};

export default BADGES;

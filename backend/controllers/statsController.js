import { BADGES, checkBadgeEligibility } from '../config/badges.js';
import StudySession from '../models/StudySession.js';
import User from '../models/User.js';

// @desc    Get user stats summary
// @route   GET /api/stats/summary
// @access  Private
export const getStatsSummary = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() - today.getDay());

    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);

    // Get sessions for different time periods
    const [dailySessions, weeklySessions, monthlySessions] = await Promise.all([
      StudySession.find({ user: req.user.id, startTime: { $gte: today }, completed: true }),
      StudySession.find({ user: req.user.id, startTime: { $gte: weekStart }, completed: true }),
      StudySession.find({ user: req.user.id, startTime: { $gte: monthStart }, completed: true })
    ]);

    const dailyMinutes = dailySessions.reduce((sum, s) => sum + (s.duration || 0), 0);
    const weeklyMinutes = weeklySessions.reduce((sum, s) => sum + (s.duration || 0), 0);
    const monthlyMinutes = monthlySessions.reduce((sum, s) => sum + (s.duration || 0), 0);

    res.json({
      success: true,
      stats: {
        daily: {
          minutes: dailyMinutes,
          sessions: dailySessions.length,
          goal: user.preferences?.dailyGoal || 240
        },
        weekly: {
          minutes: weeklyMinutes,
          sessions: weeklySessions.length,
          goal: user.studyStats?.weeklyGoal || 600
        },
        monthly: {
          minutes: monthlyMinutes,
          sessions: monthlySessions.length
        },
        lifetime: {
          minutes: user.studyStats?.totalMinutes || 0,
          sessions: user.studyStats?.totalSessions || 0
        },
        streak: {
          current: user.studyStats?.currentStreak || 0,
          longest: user.studyStats?.longestStreak || 0,
          lastStudyDate: user.studyStats?.lastStudyDate
        }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all badges with earned status
// @route   GET /api/stats/badges
// @access  Private
export const getBadges = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const earnedBadgeIds = user.badges?.map(b => b.badgeId) || [];

    const badgesWithStatus = BADGES.map(badge => ({
      ...badge,
      earned: earnedBadgeIds.includes(badge.id),
      earnedAt: user.badges?.find(b => b.badgeId === badge.id)?.earnedAt
    }));

    res.json({
      success: true,
      badges: badgesWithStatus,
      earnedCount: earnedBadgeIds.length,
      totalCount: BADGES.length
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update stats after study session
// @route   POST /api/stats/update
// @access  Private
export const updateStats = async (req, res) => {
  try {
    const { minutes, sessionCompleted = true } = req.body;
    const user = await User.findById(req.user.id);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Update total stats
    user.studyStats = user.studyStats || {};
    user.studyStats.totalMinutes = (user.studyStats.totalMinutes || 0) + minutes;
    if (sessionCompleted) {
      user.studyStats.totalSessions = (user.studyStats.totalSessions || 0) + 1;
    }

    // Update daily log
    const todayLog = user.dailyStudyLog?.find(log => {
      const logDate = new Date(log.date);
      logDate.setHours(0, 0, 0, 0);
      return logDate.getTime() === today.getTime();
    });

    if (todayLog) {
      todayLog.minutes += minutes;
    } else {
      user.dailyStudyLog = user.dailyStudyLog || [];
      user.dailyStudyLog.push({ date: today, minutes });
    }

    // Update streak
    const lastStudyDate = user.studyStats.lastStudyDate ? new Date(user.studyStats.lastStudyDate) : null;
    if (lastStudyDate) {
      lastStudyDate.setHours(0, 0, 0, 0);
    }

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (!lastStudyDate || lastStudyDate.getTime() < yesterday.getTime()) {
      // Streak broken or first study
      user.studyStats.currentStreak = 1;
    } else if (lastStudyDate.getTime() === yesterday.getTime()) {
      // Continuing streak
      user.studyStats.currentStreak = (user.studyStats.currentStreak || 0) + 1;
    }
    // If studied today already, streak stays same

    user.studyStats.lastStudyDate = today;

    // Update longest streak
    if (user.studyStats.currentStreak > (user.studyStats.longestStreak || 0)) {
      user.studyStats.longestStreak = user.studyStats.currentStreak;
    }

    // Check for new badges
    const newBadges = [];
    const earnedBadgeIds = user.badges?.map(b => b.badgeId) || [];

    for (const badge of BADGES) {
      if (!earnedBadgeIds.includes(badge.id) && checkBadgeEligibility(user, badge)) {
        const newBadge = {
          badgeId: badge.id,
          name: badge.name,
          icon: badge.icon,
          description: badge.description,
          earnedAt: new Date()
        };
        user.badges = user.badges || [];
        user.badges.push(newBadge);
        newBadges.push(newBadge);
      }
    }

    await user.save();

    res.json({
      success: true,
      stats: user.studyStats,
      newBadges,
      message: newBadges.length > 0 ? `You earned ${newBadges.length} new badge(s)!` : 'Stats updated'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get streak calendar (last 30 days)
// @route   GET /api/stats/calendar
// @access  Private
export const getStreakCalendar = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    thirtyDaysAgo.setHours(0, 0, 0, 0);

    const recentLogs = user.dailyStudyLog?.filter(log => {
      return new Date(log.date) >= thirtyDaysAgo;
    }) || [];

    // Create calendar data
    const calendar = [];
    for (let i = 0; i < 30; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);

      const log = recentLogs.find(l => {
        const logDate = new Date(l.date);
        logDate.setHours(0, 0, 0, 0);
        return logDate.getTime() === date.getTime();
      });

      calendar.unshift({
        date: date.toISOString(),
        minutes: log?.minutes || 0,
        studied: (log?.minutes || 0) > 0
      });
    }

    res.json({
      success: true,
      calendar,
      currentStreak: user.studyStats?.currentStreak || 0,
      longestStreak: user.studyStats?.longestStreak || 0
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

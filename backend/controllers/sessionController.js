import StudySession from '../models/StudySession.js';

// @desc    Get all study sessions for user
// @route   GET /api/sessions
// @access  Private
export const getSessions = async (req, res, next) => {
  try {
    const { subject, startDate, endDate } = req.query;

    let query = { user: req.user.id };

    if (subject) query.subject = subject;
    if (startDate || endDate) {
      query.startTime = {};
      if (startDate) query.startTime.$gte = new Date(startDate);
      if (endDate) query.startTime.$lte = new Date(endDate);
    }

    const sessions = await StudySession.find(query).sort({ startTime: -1 });

    res.status(200).json({
      success: true,
      count: sessions.length,
      sessions
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single session
// @route   GET /api/sessions/:id
// @access  Private
export const getSession = async (req, res, next) => {
  try {
    const session = await StudySession.findById(req.params.id);

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }

    // Make sure user owns session
    if (session.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    res.status(200).json({
      success: true,
      session
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create new study session
// @route   POST /api/sessions
// @access  Private
export const createSession = async (req, res, next) => {
  try {
    req.body.user = req.user.id;
    const session = await StudySession.create(req.body);

    res.status(201).json({
      success: true,
      session
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update study session
// @route   PUT /api/sessions/:id
// @access  Private
export const updateSession = async (req, res, next) => {
  try {
    let session = await StudySession.findById(req.params.id);

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }

    // Make sure user owns session
    if (session.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    session = await StudySession.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      session
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete study session
// @route   DELETE /api/sessions/:id
// @access  Private
export const deleteSession = async (req, res, next) => {
  try {
    const session = await StudySession.findById(req.params.id);

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }

    // Make sure user owns session
    if (session.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    await session.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Session deleted'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get study statistics
// @route   GET /api/sessions/stats
// @access  Private
export const getStats = async (req, res, next) => {
  try {
    const { period = 'week' } = req.query;

    let startDate = new Date();
    if (period === 'day') {
      startDate.setHours(0, 0, 0, 0);
    } else if (period === 'week') {
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === 'month') {
      startDate.setMonth(startDate.getMonth() - 1);
    }

    const sessions = await StudySession.find({
      user: req.user.id,
      startTime: { $gte: startDate }
    });

    const totalMinutes = sessions.reduce((sum, session) => sum + session.duration, 0);
    const totalSessions = sessions.length;
    const avgFocusScore = sessions.length > 0
      ? sessions.reduce((sum, s) => sum + s.focusScore, 0) / sessions.length
      : 0;

    // Group by subject
    const bySubject = sessions.reduce((acc, session) => {
      if (!acc[session.subject]) {
        acc[session.subject] = { minutes: 0, sessions: 0 };
      }
      acc[session.subject].minutes += session.duration;
      acc[session.subject].sessions += 1;
      return acc;
    }, {});

    res.status(200).json({
      success: true,
      stats: {
        totalMinutes,
        totalHours: Math.round(totalMinutes / 60 * 10) / 10,
        totalSessions,
        avgFocusScore: Math.round(avgFocusScore),
        bySubject
      }
    });
  } catch (error) {
    next(error);
  }
};

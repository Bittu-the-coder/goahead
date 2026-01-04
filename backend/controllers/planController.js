import PlanTemplate from '../models/PlanTemplate.js';
import StudyPlan from '../models/StudyPlan.js';

// @desc    Get all plan templates
// @route   GET /api/plans/templates
// @access  Public
export const getTemplates = async (req, res) => {
  try {
    const templates = await PlanTemplate.find({ isActive: true });
    res.json({
      success: true,
      count: templates.length,
      templates
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get single template
// @route   GET /api/plans/templates/:id
// @access  Public
export const getTemplate = async (req, res) => {
  try {
    const template = await PlanTemplate.findById(req.params.id);

    if (!template) {
      return res.status(404).json({
        success: false,
        message: 'Template not found'
      });
    }

    res.json({
      success: true,
      template
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get user's study plans
// @route   GET /api/plans
// @access  Private
export const getPlans = async (req, res) => {
  try {
    const plans = await StudyPlan.find({ user: req.user.id }).sort('-createdAt');

    res.json({
      success: true,
      count: plans.length,
      plans
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get single plan
// @route   GET /api/plans/:id
// @access  Private
export const getPlan = async (req, res) => {
  try {
    const plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    res.json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Create plan from template
// @route   POST /api/plans
// @access  Private
export const createPlan = async (req, res) => {
  try {
    const { templateId, name, startDate, customizations } = req.body;

    let planData = {
      user: req.user.id,
      name,
      startDate: new Date(startDate)
    };

    if (templateId) {
      const template = await PlanTemplate.findById(templateId);

      if (!template) {
        return res.status(404).json({
          success: false,
          message: 'Template not found'
        });
      }

      // Calculate end date based on template duration
      const endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + (template.duration.weeks * 7));

      planData = {
        ...planData,
        templateType: template.type,
        description: template.description,
        endDate,
        weeklySchedule: template.weeklySchedule,
        totalWeeks: template.duration.weeks,
        customizations: customizations || {}
      };
    } else {
      // Custom plan
      planData = {
        ...planData,
        ...req.body,
        templateType: 'Custom'
      };
    }

    const plan = await StudyPlan.create(planData);

    res.status(201).json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update plan
// @route   PUT /api/plans/:id
// @access  Private
export const updatePlan = async (req, res) => {
  try {
    let plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    plan = await StudyPlan.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete plan
// @route   DELETE /api/plans/:id
// @access  Private
export const deletePlan = async (req, res) => {
  try {
    const plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    await plan.deleteOne();

    res.json({
      success: true,
      message: 'Plan deleted'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update plan progress
// @route   PATCH /api/plans/:id/progress
// @access  Private
export const updateProgress = async (req, res) => {
  try {
    const { progress } = req.body;

    const plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    plan.progress = progress;
    await plan.save();

    res.json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Toggle subject completion
// @route   PATCH /api/plans/:id/subject/complete
// @access  Private
export const toggleSubjectCompletion = async (req, res) => {
  try {
    const { day, subjectIndex, completed } = req.body;

    const plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // Find the day schedule
    const daySchedule = plan.weeklySchedule.find(d => d.day === day);

    if (!daySchedule) {
      return res.status(404).json({
        success: false,
        message: 'Day not found in schedule'
      });
    }

    // Update subject completion
    if (daySchedule.subjects[subjectIndex]) {
      daySchedule.subjects[subjectIndex].completed = completed;
      daySchedule.subjects[subjectIndex].completedDate = completed ? new Date() : null;
    }

    // Save will trigger auto-progress calculation
    await plan.save();

    res.json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update day schedule
// @route   PATCH /api/plans/:id/schedule/:day
// @access  Private
export const updateDaySchedule = async (req, res) => {
  try {
    const { day } = req.params;
    const { subjects } = req.body;

    const plan = await StudyPlan.findById(req.params.id);

    if (!plan) {
      return res.status(404).json({
        success: false,
        message: 'Plan not found'
      });
    }

    // Make sure user owns the plan
    if (plan.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized'
      });
    }

    // Find and update the day schedule
    const daySchedule = plan.weeklySchedule.find(d => d.day === day);

    if (!daySchedule) {
      return res.status(404).json({
        success: false,
        message: 'Day not found in schedule'
      });
    }

    daySchedule.subjects = subjects;

    await plan.save();

    res.json({
      success: true,
      plan
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

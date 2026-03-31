import { Request, Response } from 'express';
import TimeSlot, { ProductivityType } from '../models/TimeSlot';
import { generateDailyInsights } from '../services/groqService';

// Helper to get start and end dates based on query (day, week, month)
const getDateRange = (dateStr: string, period: string) => {
  const queryDate = new Date(dateStr);
  const start = new Date(queryDate);
  const end = new Date(queryDate);
  
  if (period === 'day') {
    start.setHours(0,0,0,0);
    end.setHours(23,59,59,999);
  } // Extend for week, month, etc if needed.
  return { start, end };
};

// @desc    Get analytics for a given period
// @route   GET /api/analytics/:period
export const getAnalytics = async (req: Request, res: Response) => {
  const { period } = req.params;
  const { date } = req.query;
  const user = (req as any).user;

  try {
    const { start, end } = getDateRange((date as string) || new Date().toISOString(), period);

    const slots = await TimeSlot.find({
      userId: user._id,
      date: { $gte: start, $lte: end }
    });

    const totalTrackedSlots = slots.length;
    if (totalTrackedSlots === 0) {
      return res.json({ 
        totalMinutes: 0, productiveMinutes: 0, 
        wastedMinutes: 0, productivityPercentage: 0, 
        insights: "No time tracked for this period." 
      });
    }

    let productiveCount = 0;
    let wastedCount = 0;
    let categoryMap: { [key: string]: number } = {};

    slots.forEach(slot => {
      // Each slot is 20 minutes
      if (slot.productivityType === ProductivityType.PRODUCTIVE) productiveCount++;
      if (slot.productivityType === ProductivityType.WASTED) wastedCount++;
      
      categoryMap[slot.category] = (categoryMap[slot.category] || 0) + 20;
    });

    const productiveMinutes = productiveCount * 20;
    const wastedMinutes = wastedCount * 20;
    const totalMinutes = totalTrackedSlots * 20;
    
    // Formula: (Productive Time / Total Tracked Time) * 100
    const productivityPercentage = (productiveMinutes / totalMinutes) * 100;

    // Get insights via LLM
    const promptPayload = {
      slotsCompleted: totalTrackedSlots,
      productiveMinutes,
      wastedMinutes,
      productivityPercentage,
      categories: categoryMap
    };
    const insights = await generateDailyInsights(promptPayload);

    res.json({
      totalMinutes,
      productiveMinutes,
      wastedMinutes,
      productivityPercentage: productivityPercentage.toFixed(2),
      categoryBreakdown: categoryMap,
      insights
    });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

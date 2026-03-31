import { Request, Response } from 'express';
import TimeSlot from '../models/TimeSlot';

// @desc    Create a new time slot
// @route   POST /api/slots
export const createTimeSlot = async (req: Request, res: Response) => {
  const { date, timeRange, taskSelected, category, productivityType } = req.body;
  const user = (req as any).user;

  try {
    const slot = await TimeSlot.create({
      userId: user._id,
      date: new Date(date),
      timeRange,
      taskSelected,
      category,
      productivityType,
    });
    
    res.status(201).json(slot);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get time slots for a specific date
// @route   GET /api/slots
export const getTimeSlots = async (req: Request, res: Response) => {
  const { date } = req.query;
  const user = (req as any).user;

  try {
    const queryDate = new Date(date as string);
    const startOfDay = new Date(queryDate.setHours(0,0,0,0));
    const endOfDay = new Date(queryDate.setHours(23,59,59,999));

    const slots = await TimeSlot.find({
      userId: user._id,
      date: { $gte: startOfDay, $lte: endOfDay }
    }).sort({ timeRange: 1 });
    
    res.json(slots);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

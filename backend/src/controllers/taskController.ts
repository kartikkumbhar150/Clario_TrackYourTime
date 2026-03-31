import { Request, Response } from 'express';
import Task from '../models/Task';

// @desc    Create a new task (Immutable once created)
// @route   POST /api/tasks
export const createTask = async (req: Request, res: Response) => {
  const { taskName, date } = req.body;
  const user = (req as any).user;

  try {
    const task = await Task.create({
      userId: user._id,
      taskName,
      date: new Date(date),
      isCompleted: false
    });
    res.status(201).json(task);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get tasks for a specific date
// @route   GET /api/tasks
export const getTasks = async (req: Request, res: Response) => {
  const { date } = req.query;
  const user = (req as any).user;

  try {
    const queryDate = new Date(date as string);
    // Simple filter to get tasks created/scheduled for the same day
    const startOfDay = new Date(queryDate.setHours(0,0,0,0));
    const endOfDay = new Date(queryDate.setHours(23,59,59,999));

    const tasks = await Task.find({
      userId: user._id,
      date: { $gte: startOfDay, $lte: endOfDay }
    });
    
    res.json(tasks);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

// Mark completed (Only modification allowed)
export const markTaskCompleted = async (req: Request, res: Response) => {
  const { id } = req.params;
  const user = (req as any).user;

  try {
    const task = await Task.findOne({ _id: id, userId: user._id });
    if (!task) return res.status(404).json({ message: 'Task not found' });

    task.isCompleted = true;
    await task.save();

    res.json(task);
  } catch(error: any) {
    res.status(400).json({ message: error.message });
  }
};

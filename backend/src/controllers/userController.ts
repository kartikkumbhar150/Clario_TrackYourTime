import { Request, Response } from 'express';
import User from '../models/User';

// @desc    Get user categories
// @route   GET /api/users/categories
export const getUserCategories = async (req: Request, res: Response) => {
  const user = (req as any).user;
  
  try {
    const dbUser = await User.findById(user._id);
    if (!dbUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(dbUser.categories);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update user categories
// @route   PUT /api/users/categories
export const updateUserCategories = async (req: Request, res: Response) => {
  const { categories } = req.body;
  const user = (req as any).user;
  
  try {
    if (!Array.isArray(categories)) {
      return res.status(400).json({ message: 'Categories must be an array of strings' });
    }

    const dbUser = await User.findById(user._id);
    if (!dbUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    dbUser.categories = categories;
    await dbUser.save();
    
    res.json(dbUser.categories);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

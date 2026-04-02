import mongoose, { Schema, Document } from 'mongoose';

export enum ProductivityType {
  PRODUCTIVE = 'Productive',
  NEUTRAL = 'Neutral',
  WASTED = 'Wasted'
}

export interface ITimeSlot extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  timeRange: string; // e.g., '09:00-09:20'
  taskSelected?: mongoose.Types.ObjectId | string;
  category: string;
  productivityType: ProductivityType;
}

const TimeSlotSchema: Schema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  timeRange: { type: String, required: true },
  taskSelected: { type: Schema.Types.Mixed }, // Could be reference or string fallback
  category: { type: String, required: true },
  productivityType: { 
    type: String, 
    enum: Object.values(ProductivityType),
    required: true 
  },
}, { timestamps: true });

TimeSlotSchema.index({ userId: 1, date: 1 });

export default mongoose.model<ITimeSlot>('TimeSlot', TimeSlotSchema);

import mongoose, { Schema, Document } from 'mongoose';

export interface ITask extends Document {
  userId: mongoose.Types.ObjectId;
  taskName: string;
  date: Date;
  isCompleted: boolean;
}

const TaskSchema: Schema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  taskName: { type: String, required: true },
  date: { type: Date, required: true },
  isCompleted: { type: Boolean, default: false },
}, { timestamps: true });

TaskSchema.index({ userId: 1, date: 1 });

export default mongoose.model<ITask>('Task', TaskSchema);

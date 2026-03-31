import mongoose, { Schema, Document } from 'mongoose';

export interface IReport extends Document {
  userId: mongoose.Types.ObjectId;
  date: Date;
  summary: string;
  productivityScore: number;
}

const ReportSchema: Schema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  date: { type: Date, required: true },
  summary: { type: String, required: true },
  productivityScore: { type: Number, required: true },
}, { timestamps: true });

export default mongoose.model<IReport>('Report', ReportSchema);

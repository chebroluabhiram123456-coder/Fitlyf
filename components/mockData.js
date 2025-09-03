// components/mockData.js
import { format, subDays, addDays } from 'date-fns';

// Helper to format dates into a 'YYYY-MM-DD' string to use as a key
const getKey = (date) => format(date, 'yyyy-MM-dd');
const today = new Date();

// This is our fake database
export const dailyData = {
  [getKey(subDays(today, 2))]: {
    weight: '75.8 kg',
    workout: { name: 'Rest Day' },
    isCompleted: true,
  },
  [getKey(subDays(today, 1))]: {
    weight: '75.5 kg',
    workout: {
      name: 'Full Body Strength A',
      exercises: ['Squats: 3x5', 'Bench Press: 3x5', 'Barbell Row: 3x5'],
    },
    isCompleted: true,
  },
  [getKey(today)]: {
    weight: '75.2 kg',
    workout: {
      name: 'Cardio & Core',
      exercises: ['Running: 30 min', 'Plank: 3x60s', 'Crunches: 3x15'],
    },
    isCompleted: false, // Today's workout is not yet complete
  },
  [getKey(addDays(today, 1))]: {
    weight: null, // No weight logged for a future date
    workout: {
      name: 'Full Body Strength B',
      exercises: ['Overhead Press: 3x5', 'Deadlift: 1x5', 'Pull-ups: 3x8'],
    },
    isCompleted: false,
  },
};


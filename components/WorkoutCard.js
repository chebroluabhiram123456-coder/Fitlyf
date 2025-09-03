// components/WorkoutCard.js
import React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { format, isSameDay } from 'date-fns';

export default function WorkoutCard({ date, data }) {
  const { workout, isCompleted } = data;
  const isRestDay = workout.name === 'Rest Day';

  return (
    <View style={styles.card}>
      <Text style={styles.title}>
        {isSameDay(date, new Date()) ? "Today's Workout" : `Workout for ${format(date, 'MMM d')}`}
      </Text>
      
      {isCompleted && !isRestDay && <Text style={styles.status}>✅ Completed</Text>}
      {isRestDay && <Text style={styles.status}>😌 Rest Day</Text>}

      {!isRestDay && (
        <View style={styles.exerciseList}>
          <Text style={styles.workoutName}>{workout.name}</Text>
          {workout.exercises?.map((ex, index) => (
            <Text key={index} style={styles.exerciseText}>- {ex}</Text>
          ))}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
    marginBottom: 15,
  },
  title: {
    fontSize: 14,
    color: '#888',
    fontWeight: '600',
    marginBottom: 8,
  },
  workoutName: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  exerciseList: {
    marginTop: 5,
  },
  exerciseText: {
    fontSize: 16,
    lineHeight: 24,
  },
  status: {
    fontSize: 20,
    fontWeight: 'bold',
    marginTop: 10,
  },
});


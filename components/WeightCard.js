// components/WeightCard.js
import React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { format, isSameDay } from 'date-fns';

export default function WeightCard({ date, data }) {
  const { weight } = data;
  
  return (
    <View style={styles.card}>
      <Text style={styles.title}>
        {isSameDay(date, new Date()) ? "Today's Weight" : `Weight for ${format(date, 'MMM d')}`}
      </Text>
      <Text style={styles.weightText}>
        {weight ? weight : '-- kg'}
      </Text>
      {!weight && <Text style={styles.prompt}>Log your weight</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
  },
  title: {
    fontSize: 14,
    color: '#888',
    fontWeight: '600',
    marginBottom: 8,
  },
  weightText: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  prompt: {
    fontSize: 14,
    color: '#007AFF',
    marginTop: 4,
  },
});


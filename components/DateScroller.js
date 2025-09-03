// components/DateScroller.js
import React from 'react';
import { StyleSheet, View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { format, isSameDay, addDays } from 'date-fns';

const getKey = (date) => format(date, 'yyyy-MM-dd');

export default function DateScroller({ selectedDate, onDateSelect, data }) {
  const dates = Array.from({ length: 20 }, (_, i) => addDays(new Date(), i - 10));

  return (
    <View style={styles.container}>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scroller}
      >
        {dates.map((date, index) => {
          const isSelected = isSameDay(date, selectedDate);
          const dayData = data[getKey(date)] || {};
          const isCompleted = dayData.isCompleted || false;

          return (
            <TouchableOpacity key={index} onPress={() => onDateSelect(date)}>
              <View style={[styles.dateItem, isSelected && styles.selectedItem]}>
                <Text style={[styles.dayText, isSelected && styles.selectedText]}>
                  {format(date, 'E')}
                </Text>
                <Text style={[styles.dateText, isSelected && styles.selectedText]}>
                  {format(date, 'd')}
                </Text>
                
                {/* --- The Completion Tick --- */}
                {isCompleted && <View style={styles.tick} />}
              </View>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    height: 90,
    marginBottom: 20,
  },
  scroller: {
    paddingHorizontal: 10,
    alignItems: 'center',
  },
  dateItem: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 60,
    height: 70,
    borderRadius: 12,
    marginHorizontal: 5,
    backgroundColor: '#fff',
  },
  selectedItem: {
    backgroundColor: '#007AFF',
  },
  dayText: {
    fontSize: 12,
    color: '#888',
  },
  dateText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  selectedText: {
    color: '#fff',
  },
  tick: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: '#007AFF',
    position: 'absolute',
    bottom: 8,
  },
});


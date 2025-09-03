// screens/HomeScreen.js
import React, { useState, useMemo } from 'react';
import { StyleSheet, View, Text, SafeAreaView, StatusBar } from 'react-native';
import { format } from 'date-fns';
import { dailyData } from '../components/mockData';
import DateScroller from '../components/DateScroller';
import WorkoutCard from '../components/WorkoutCard';
import WeightCard from '../components/WeightCard';

const getKey = (date) => format(date, 'yyyy-MM-dd');

export default function HomeScreen() {
  const [selectedDate, setSelectedDate] = useState(new Date());

  const currentDayData = useMemo(() => {
    const key = getKey(selectedDate);
    return dailyData[key] || { weight: null, workout: { name: 'No Plan' }, isCompleted: false };
  }, [selectedDate]);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <Text style={styles.header}>Your Activity</Text>
      
      <DateScroller
        selectedDate={selectedDate}
        onDateSelect={setSelectedDate}
        data={dailyData}
      />
      
      <View style={styles.cardContainer}>
        <WorkoutCard date={selectedDate} data={currentDayData} />
        <WeightCard date={selectedDate} data={currentDayData} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f4f4f8',
  },
  header: {
    fontSize: 28,
    fontWeight: 'bold',
    margin: 20,
    marginTop: 10,
  },
  cardContainer: {
    paddingHorizontal: 20,
  },
});


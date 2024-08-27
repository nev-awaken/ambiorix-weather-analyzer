import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import ReactECharts from 'echarts-for-react';
import { Box, Typography, Button, CircularProgress, Alert, Select, MenuItem, FormControl, InputLabel } from '@mui/material';

const API_URL = process.env.REACT_APP_AMBIORIX_BACKEND_URL;

const TrendChart = () => {
  const [chartData, setChartData] = useState({ xAxis: [], series: [] });
  const [forecastData, setForecastData] = useState({ xAxis: [], series: [] });
  const [location, setLocation] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [forecastHours, setForecastHours] = useState(2);

  const fetchTrendData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_URL}/raw-trend`);
      if (response.data.success) {
        const { location, timestamp, temperature } = response.data.data;
        setLocation(location);
        setChartData({
          xAxis: timestamp,
          series: temperature
        });
        console.log('Raw trend data:', response.data.data);
      }
    } catch (error) {
      console.error('Error fetching trend data:', error);
      setError('Failed to fetch trend data. Please try again.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTrendData();
    const interval = setInterval(fetchTrendData, 10 * 60 * 1000); // Refresh every 10 minutes
    return () => clearInterval(interval);
  }, [fetchTrendData]);

  const handleForecastClick = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_URL}/forecast-trend`, {
        params: { hours: forecastHours }
      });
      if (response.data.success) {
        const { timestamp, temperature } = response.data.forecast;
        setForecastData({
          xAxis: timestamp,
          series: temperature
        });
        console.log('Raw forecast data:', response.data.forecast);
      }
    } catch (error) {
      console.error('Error fetching forecast data:', error);
      setError('Failed to fetch forecast data. Please try again.');
    } finally {
      setLoading(false);
    }
  };


  const option = {
    backgroundColor: '#ffffff',
    title: { 
      text: 'Temperature Trend and Forecast',
      textStyle: {
        color: '#333'
      }
    },
    tooltip: {
      trigger: 'axis',
      formatter: function(params) {
        let tooltip = `Date: ${params[0].axisValue}<br/>`;
        params.forEach(param => {
          tooltip += `${param.seriesName}: ${param.value}°C<br/>`;
        });
        tooltip += `Location: ${location}`;
        return tooltip;
      }
    },
    legend: {
      data: ['Temperature', 'Forecast'],
      textStyle: {
        color: '#333'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: [...chartData.xAxis, ...forecastData.xAxis],
      axisLabel: {
        color: '#333'
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        formatter: '{value} °C',
        color: '#333'
      }
    },
    series: [
      {
        name: 'Temperature',
        type: 'line',
        data: chartData.series,
        smooth: true,
        lineStyle: {
          color: '#ff7300'
        },
        itemStyle: {
          color: '#ff7300'
        }
      },
      {
        name: 'Forecast',
        type: 'line',
        data: new Array(chartData.series.length).fill(null).concat(forecastData.series),
        smooth: true,
        lineStyle: {
          type: 'dashed',
          color: '#4caf50'
        },
        itemStyle: {
          color: '#4caf50'
        }
      }
    ]
  };

  return (
    <Box sx={{ p: 2, bgcolor: 'background.paper', borderRadius: 1, boxShadow: 1 }}>
      <Typography variant="h5" gutterBottom>Location: {location}</Typography>
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: 400 }}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <Alert severity="error" sx={{ height: 400, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {error}
        </Alert>
      ) : (
        <ReactECharts option={option} style={{ height: '400px' }} />
      )}
      <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Button 
          onClick={fetchTrendData} 
          disabled={loading}
          variant="contained"
          color="primary"
        >
          Refresh Data
        </Button>
        <FormControl sx={{ minWidth: 120 }}>
          <InputLabel id="forecast-hours-label">Forecast Hours</InputLabel>
          <Select
            labelId="forecast-hours-label"
            value={forecastHours}
            label="Forecast Hours"
            onChange={(e) => setForecastHours(e.target.value)}
          >
            <MenuItem value={1}>1 hour</MenuItem>
            <MenuItem value={2}>2 hours</MenuItem>
            <MenuItem value={4}>4 hours</MenuItem>
            <MenuItem value={8}>8 hours</MenuItem>
            <MenuItem value={24}>24 hours</MenuItem>
          </Select>
        </FormControl>
        <Button 
          onClick={handleForecastClick} 
          disabled={loading}
          variant="contained"
          color="secondary"
        >
          Forecast
        </Button>
      </Box>
    </Box>
  );
};



export default TrendChart;
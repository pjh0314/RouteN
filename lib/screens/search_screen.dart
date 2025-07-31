import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

enum SearchSection { none, city, period, theme }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});
  final String title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// need to fix here later
class _SearchScreenState extends State<SearchScreen> {
  SearchSection _currentSection = SearchSection.none;

  String? _selectedCity;
  PickerDateRange? _selectedPeriod;
  String? _selectedTheme;
  // should replace with Geo API
  final List<String> _cities = [
    'Seoul',
    'New York',
    'Tokyo',
    'Paris',
    'Busan',
    'Osaka',
    'London',
    'Madrid',
    'LA',
    'Austin',
  ];
  final List<String> _themes = [
    'Alone',
    'Couple',
    'Family',
    'Business',
    'Friends',
  ];

  // function for calling section
  void _onSectionPressed(SearchSection section) {
    setState(() {
      if (_currentSection == section) {
        _currentSection =
            SearchSection.none; //close when click the selected section again
      } else {
        _currentSection = section;
      }
    });
  }

  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedPeriod = args.value;
    });
  }

  String _getPeriodText() {
    if (_selectedPeriod == null) {
      return 'Choose Date';
    }
    final startDate = DateFormat('MM/dd').format(_selectedPeriod!.startDate!);
    final endDate = _selectedPeriod!.endDate != null
        ? DateFormat('MM/dd').format(_selectedPeriod!.endDate!)
        : '';

    return startDate.isEmpty ? startDate : '$startDate - $endDate';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSearchWidget(),
          _buildSearchButton(),
          Expanded(child: _buildContentForSection()),
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSearchSection(
            'City',
            _selectedCity ?? 'Choose City',
            SearchSection.city,
            Icons.location_city,
          ),
          _buildSearchSection(
            'Period',
            _getPeriodText(),
            SearchSection.period,
            Icons.calendar_today,
          ),
          _buildSearchSection(
            'Theme',
            _selectedTheme ?? 'Choose Theme',
            SearchSection.theme,
            Icons.interests,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    final isAllSelected =
        _selectedCity != null &&
        _selectedPeriod != null &&
        _selectedTheme != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: isAllSelected
            ? () {
                Navigator.pushNamed(
                  context,
                  '/result',
                  arguments: {
                    'city': _selectedCity!,
                    'period': _selectedPeriod!,
                    'theme': _selectedTheme!,
                  },
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const SizedBox(
          width: double.infinity,
          child: Center(child: Text('Go')),
        ),
      ),
    );
  }

  // main widget for choosing each sections cities/period/themes
  Widget _buildSearchSection(
    String title,
    String subtitle,
    SearchSection section,
    IconData icon,
  ) {
    bool isSelected = _currentSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSectionPressed(section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // return the proper content to currently chosen section
  Widget _buildContentForSection() {
    switch (_currentSection) {
      case SearchSection.city:
        return _buildCityList();
      case SearchSection.period:
        return _buildDatePicker();
      case SearchSection.theme:
        return _buildThemeList();
      case SearchSection.none:
        //default:
        return const Center(
          child: Text(
            'Where do u want to travel?\nChoose the condition above.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
    }
  }

  // show the list of cities
  Widget _buildCityList() {
    return ListView.builder(
      itemCount: _cities.length,
      itemBuilder: (context, index) {
        final city = _cities[index];
        return ListTile(
          title: Text(city),
          onTap: () {
            setState(() {
              _selectedCity = city;
              _currentSection = SearchSection.none; // Close after choosing
            });
          },
        );
      },
    );
  }

  /// show the calander
  Widget _buildDatePicker() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfDateRangePicker(
          onSelectionChanged: _onDateSelectionChanged,
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: _selectedPeriod,
          minDate: DateTime.now(),
          headerStyle: const DateRangePickerHeaderStyle(
            textAlign: TextAlign.center,
          ),
          monthViewSettings: const DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1, // Monday Start
          ),
        ),
      ),
    );
  }

  /// show theme list in theme section
  Widget _buildThemeList() {
    return ListView.builder(
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        return ListTile(
          title: Text(theme),
          onTap: () {
            setState(() {
              _selectedTheme = theme;
              _currentSection = SearchSection.none; // Close after choosing
            });
          },
        );
      },
    );
  }
}

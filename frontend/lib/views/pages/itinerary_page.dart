import 'package:flutter/material.dart';
import 'layover_page.dart';
import 'holiday_planner_page.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1E),
      appBar: AppBar(
        title: const Text(
          'Itinerary Planner',
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF1B1C1E),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Layover Plans'),
            Tab(text: 'Holiday Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LayoverPage(),
          HolidayPlannerPage(),
        ],
      ),
    );
  }
}

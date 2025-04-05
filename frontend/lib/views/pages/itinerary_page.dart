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

  static const Color primaryColor = Color(0xFF1B1C1E); // Black
  static const Color secondaryColor = Colors.amber; // Amber

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
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/tower.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black45, // make it "lite tone"
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Main content with tabs
          DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.transparent, // important!
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
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
            ),
          ),
        ],
      ),
    );
  }
}

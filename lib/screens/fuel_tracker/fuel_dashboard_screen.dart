import 'package:flutter/material.dart';
import '../../placeholder_action_screen.dart';
import 'vehicle_management_screen.dart';
import 'add_fuel_screen.dart';

/// Initial Fuel Tracker dashboard.
class FuelDashboardScreen extends StatelessWidget {
  const FuelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget summaryCard(String label, String value) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget actionTile(
      String title,
      IconData icon,
      Widget destination,
    ) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => destination,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Tracker'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track every refill. Know every kilometre.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  summaryCard('Total fuel expenses', 'â€”'),
                  summaryCard('Total litres purchased', 'â€”'),
                  summaryCard('Total distance', 'â€”'),
                  summaryCard('Since last fuel', 'â€”'),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Quick actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              actionTile(
                'Add Fuel',
                Icons.local_gas_station,
                const AddFuelScreen(),
              ),
              actionTile(
                'Manual Distance',
                Icons.straighten,
                const PlaceholderActionScreen(title: 'Manual Distance'),
              ),
              actionTile(
                'GPS Ride',
                Icons.navigation,
                const PlaceholderActionScreen(title: 'GPS Ride'),
              ),
              actionTile(
                'History',
                Icons.history,
                const PlaceholderActionScreen(title: 'History'),
              ),
              actionTile(
                'Analytics',
                Icons.bar_chart,
                const PlaceholderActionScreen(title: 'Analytics'),
              ),
              actionTile(
                'Manage Vehicles',
                Icons.directions_car,
                const VehicleManagementScreen(),
              ),

              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.directions_car_filled,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No vehicles added yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap "Manage Vehicles" to get started.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


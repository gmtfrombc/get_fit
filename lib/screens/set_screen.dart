import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/workout_group_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/add_workout.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SetScreen extends StatelessWidget {
  final Workout workout;
  final bool isLoading = false;
  const SetScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      authProvider: Provider.of<AuthProviderClass>(context, listen: false),
      customAppBar: CustomAppBar(
        title: Image.asset(
          'lib/assets/images/get_fit_icon.png',
          fit: BoxFit.cover,
          height: 40,
        ),
        backgroundColor: AppTheme.primaryBackgroundColor,
        showEndDrawerIcon: true,
        showLeading: true,
      ),
      showDrawer: true,
      showAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          _showAddWorkoutSheet(context);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      child: Stack(
        children: [
          _buildWorkout(context),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildWorkout(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildBanner(),
        _buildWorkoutList(context),
      ],
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: AppTheme.primaryBackgroundColor,
        child: Text(
          'Today\'s Workout',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    return Consumer<WorkoutGroupProvider>(
      builder: (context, workoutGroupProvider, child) {
        return Expanded(
          // Wrap with Expanded
          child: ListView.builder(
            itemCount: workoutGroupProvider.userWorkoutDetails.length,
            itemBuilder: (context, index) {
              var workoutDetail =
                  workoutGroupProvider.userWorkoutDetails[index];
              return _buildCard(
                context,
                workout,
                workoutDetail,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, workout, workoutDetail) {
    double screenWidth = MediaQuery.of(context).size.width;
    String imageUrl = workout.image;
    return Dismissible(
      key: Key(workoutDetail.name),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<WorkoutGroupProvider>(context, listen: false)
            .deleteWorkout(workoutDetail.name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Workout removed"),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: screenWidth - 20,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12.0),
              gradient: AppTheme.cardGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1, // Spread radius
                  blurRadius: 5, // Blur radius
                  offset: const Offset(0, 2), // Changes position of shadow
                ),
              ],
            ),
            child: Card(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 16, // Adjust the left position to your preference
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        workoutDetail.name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
        child: Center(
          child: CustomProgressIndicator(
            color: AppTheme.primaryColor,
          ), // Loading indicator
        ),
      ),
    );
  }

  void _showAddWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => _addWorkoutBottomSheet(context),
    );
  }

  Widget _addWorkoutBottomSheet(BuildContext context) {
    return Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
      final elements = workoutProvider.workouts;
      if (elements.isEmpty) {
        return const Center(
          child: Text('No workouts available'),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        itemCount: elements.length,
        itemBuilder: (context, index) {
          final workout = elements[index];
          return ListTile(
            title: Text(workout.group),
            onTap: () {
              Navigator.pop(context);
              _handleButtonClick(context, workout);
            },
          );
        },
      );
    });
  }

  void _handleButtonClick(BuildContext context, workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddWorkout(),
      ),
    );
  }
}

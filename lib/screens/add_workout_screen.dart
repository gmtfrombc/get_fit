import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/user_workout_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;

  const AddWorkoutScreen({Key? key, required this.workout}) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final bool isLoading = false;
  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutProvider>(context, listen: false)
        .fetchWorkoutsByGroup(widget.workout.group);
  }

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
      child: Stack(
        children: [
          _buildContent(context),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildBanner(),
        _buildWorkoutElementList(context),
      ],
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

  Widget _buildBanner() {
    return Container(
      color: AppTheme.primaryBackgroundColor,
      child: Text(
        'Choose a workout',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: GoogleFonts.outfit().fontFamily,
        ),
      ),
    );
  }

  Widget _buildWorkoutElementList(BuildContext context) {
    return Expanded(
      child: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          //final elements = workoutProvider.workouts;
          final allExercises = workoutProvider.workouts
              .expand((workout) => workout.exercises)
              .toList();

          if (allExercises.isEmpty) {
            return const Center(
              child: Text('No exercises found'),
            );
          }
          return ListView.builder(
            itemCount: allExercises.length,
            itemBuilder: (context, index) {
              final exercise = allExercises[index];
              return _buildCard(context, exercise);
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, ExerciseSummary exercise) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              _addNewExercise(exercise);
            },
            child: Container(
              width: screenWidth - 20,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Card(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Text(
                        'Default Sets: ${exercise.defaultSets}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewExercise(ExerciseSummary exercise) {
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);
    bool added = userWorkoutProvider.addExerciseToSelectedGroup(exercise);

    if (!added) {
      // Show dialog here because the workout already exists
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Workout Already Exists"),
              content: const Text("This workout is already in your list."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close this dialog
                  },
                ),
              ],
            );
          });
    } else {
      Navigator.of(context).pop(); // Close AddWorkoutScreen if added
    }
  }
}

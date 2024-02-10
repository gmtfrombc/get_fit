import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/user_workout_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/add_workout_screen.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/services/firebase_services.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SetScreen extends StatefulWidget {
  final Workout workout;

  const SetScreen({
    super.key,
    required this.workout,
  });

  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  final bool isLoading = false;
  bool needsUpdate = false;

  @override
  Widget build(BuildContext context) {
    if (needsUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<WorkoutProvider>(context, listen: false).fetchWorkouts();
          setState(
            () {
              needsUpdate = false;
            },
          );
        }
      });
    }
    return BaseScreen(
      authProvider: Provider.of<AuthProviderClass>(context, listen: false),
      customAppBar: CustomAppBar(
        title: const Text('Get Fit'),
        backgroundColor: AppTheme.primaryBackgroundColor,
        showEndDrawerIcon: false,
        showLeading: false,
      ),
      showDrawer: false,
      showAppBar: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.secondaryColor,
        onPressed: () {
          _showAddWorkoutSheet(context);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
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
      children: <Widget>[
        const SizedBox(height: 40), // Add 20px of space (top margin)
        _buildBanner(context),
        _buildWorkoutList(context),
        _buildStartWorkout(context, widget.workout),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor,
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: AppTheme.primaryBackgroundColor,
          child: Text(
            'Today\'s Workout',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            _showSaveConfirmationDialog(context);
          },
          child: Text(
            'Save',
            style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor,
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    return Consumer<UserWorkoutProvider>(
      builder: (context, workoutGroupProvider, child) {
        return Expanded(
          child: ListView.builder(
            itemCount: workoutGroupProvider.userWorkoutDetails.length,
            itemBuilder: (context, index) {
              var workoutDetail =
                  workoutGroupProvider.userWorkoutDetails[index];
              return _buildCard(
                context,
                widget.workout,
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
        Provider.of<UserWorkoutProvider>(context, listen: false)
            .deleteWorkout(workoutDetail.name);
      },
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 5),
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
                      left: 16,
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
            const SizedBox(height: 10),
          ],
        ),
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
              _handleAddNewExerciseClick(context, workout);
            },
          );
        },
      );
    });
  }

  void _handleAddNewExerciseClick(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddWorkoutScreen(workout: workout)),
    ).then((value) {
      if (mounted) {
        setState(
          () {
            needsUpdate = true;
          },
        );
      }
    });
  }

  Widget _buildStartWorkout(BuildContext context, workout) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child:
          ElevatedButton(child: const Text('Start Workout'), onPressed: () {}),
    );
  }

  void _saveWorkout(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(
        context); // Reference to ScaffoldMessenger before async gap

    try {
      final workoutProvider =
          Provider.of<UserWorkoutProvider>(context, listen: false);
      final authProvider =
          Provider.of<AuthProviderClass>(context, listen: false);
      final firebaseServices = FirebaseServices();
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      await firebaseServices.saveUserWorkouts(
          userId, workoutProvider.userWorkoutDetails);
      await workoutProvider.fetchUserWorkouts(userId); // Refresh data

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Workouts saved successfully!")));
    } catch (e) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text("Error saving workouts: $e")));
      debugPrint("Error saving workouts: $e");
    }
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Save Results?',
            style: TextStyle(
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          content: Text(
            'Do you want to save the changes to your workout?',
            style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _saveWorkout(context); // Proceed to save the workout
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

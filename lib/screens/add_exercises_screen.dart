import 'package:flutter/material.dart';
import 'package:get_fit/models/all_exercises.dart';
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

class AddExercisesScreen extends StatefulWidget {
  final WorkoutModel workout;
  final bool isNewWorkout;

  const AddExercisesScreen({
    Key? key,
    required this.workout,
    this.isNewWorkout = false,
  }) : super(key: key);

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  final bool isLoading = false;
  final Set<AllExercises> _selectedExercises = {};

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
        _buildSubmitButton(),
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
        'Choose exercises to add',
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

  Widget _buildCard(BuildContext context, AllExercises exercise) {
    bool isSelected = _selectedExercises.contains(exercise);
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 5),
          CheckboxListTile(
            title: Text(
              exercise.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
            ),
            subtitle: Text(
              'Default Sets: ${exercise.defaultSets}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
            ),
            value: isSelected,
            onChanged: (bool? newValue) {
              setState(() {
                if (newValue == true) {
                  _selectedExercises.add(exercise);
                } else {
                  _selectedExercises.remove(exercise);
                }
              });
            },
            secondary: const Icon(Icons.fitness_center),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed:
          _selectedExercises.isNotEmpty ? () => _addNewExercisesBatch() : null,
      child: const Text('Add Selected Exercises'),
    );
  }

  void _addNewExercisesBatch() {
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);

    // Assuming there's a way to determine if this is for a new workout or not.
    // For example, a boolean flag in your state class: bool _isNewWorkout;
    userWorkoutProvider.addExercisesToWorkout(
        context, _selectedExercises.toList(),
        isNewWorkout: widget.isNewWorkout);
    Provider.of<WorkoutProvider>(context, listen: false).fetchWorkouts();
    // Assuming addExercisesToWorkoutList now directly updates the exercises list
    // and doesn't return duplicates but you handle it internally via state management.
    // So, there's no need to check for duplicates here unless you explicitly want to notify the user.

    // Navigate back or show a confirmation dialog based on your app's flow.
    Navigator.of(context)
        .pop(); // Assuming you want to close the AddExerciseScreen upon successful addition.
  }

  // void _addNewExercisesBatch() {
  //   final userWorkoutProvider =
  //       Provider.of<UserWorkoutProvider>(context, listen: false);
  //   List<AllExercises> duplicates = userWorkoutProvider.addExercisesToWorkout(
  //       context, _selectedExercises.toList());

  //   if (duplicates.isNotEmpty) {
  //     // Show dialog with the names of exercises that were already added
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("Some Workouts Already Exist"),
  //           content: Text(
  //             "Some workouts are already in your list and weren't added: ${duplicates.map((e) => e.name).join(', ')}",
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //                 child: const Text("OK"),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   Navigator.of(context).pop();
  //                 } // Close this dialog
  //                 // Close this dialog
  //                 ),
  //           ],
  //         );
  //       },
  //     );
  //   } else {
  //     Navigator.of(context)
  //         .pop(); // Close AddWorkoutScreen if all selected were added
  //   }
  // }
}

  // Widget _buildCard(BuildContext context, AllExercises exercise) {
  //   bool isSelected = _selectedExercises.contains(exercise);
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   return Center(
  //     child: Column(
  //       children: [
  //         const SizedBox(height: 5),
  //         InkWell(
  //           onTap: () {
  //             _addNewExercise(exercise);
  //           },
  //           child: Container(
  //             width: screenWidth - 20,
  //             height: 100,
  //             decoration: BoxDecoration(
  //               color: AppTheme.primaryBackgroundColor,
  //               borderRadius: BorderRadius.circular(12),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: AppTheme.primaryColor.withOpacity(0.5),
  //                   spreadRadius: 2,
  //                   blurRadius: 7,
  //                   offset: const Offset(0, 3), // changes position of shadow
  //                 ),
  //               ],
  //             ),
  //             child: Card(
  //               color: Colors.transparent,
  //               clipBehavior: Clip.antiAlias,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Stack(
  //                 children: [
  //                   Positioned(
  //                     top: 10,
  //                     left: 10,
  //                     child: Text(
  //                       exercise.name,
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.black,
  //                         fontFamily: GoogleFonts.outfit().fontFamily,
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     bottom: 10,
  //                     left: 10,
  //                     child: Text(
  //                       'Default Sets: ${exercise.defaultSets}',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.black,
  //                         fontFamily: GoogleFonts.outfit().fontFamily,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

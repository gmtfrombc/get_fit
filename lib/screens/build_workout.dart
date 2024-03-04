import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/user_workout_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/add_exercises_screen.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BuildWorkout extends StatefulWidget {
  const BuildWorkout({super.key});

  @override
  State<BuildWorkout> createState() => _BuildWorkoutState();
}

class _BuildWorkoutState extends State<BuildWorkout> {
  String selectedWorkoutGroup = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // Provider.of<WorkoutProvider>(context, listen: false).fetchWorkouts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
          PageView.builder(
            controller: _pageController,
            itemCount: 4,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageContent(index, screenHeight);
            },
          ),
          if (isLoading) _buildLoadingOverlay(),
          if (_currentPage < 3)
            Positioned(
              bottom: 20,
              right: 20,
              child: IconButton(
                color: AppTheme.secondaryColor,
                icon: const Icon(Icons.arrow_forward),
                iconSize: 40,
                onPressed: () {
                  if (_currentPage < 4) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushNamed(context, '/homescreen');
                  }
                },
              ),
            ),
          if (_currentPage == 2)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: _navigateToAddExercisesScreen,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int index, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            _buildBanner(context),
            const SizedBox(
              height: 40.0,
            ),
            if (index == 0) _buildName('Name your workout', _nameController),
            if (index == 1) _buildGroup(selectedWorkoutGroup),
            if (index == 2) _buildExercises(),
            if (index == 3) _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CustomProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryBackgroundColor,
      child: Text(
        'Build New Workout',
        style: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildName(String label, TextEditingController nameController) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter workout name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String selectedWorkoutGroup) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final elements = workoutProvider.workouts;
        if (elements.isEmpty) {
          return const Center(
            child: Text('No workouts found'),
          );
        }
        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: elements.length,
            itemBuilder: (context, index) {
              return _buildWorkoutElementCard(context, elements[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkoutElementCard(BuildContext context, workout) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedWorkoutGroup = workout.group;
        });
      },
      child: Card(
        shadowColor: AppTheme.primaryColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          workout.group,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: GoogleFonts.roboto().fontFamily,
            shadows: const [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercises() {
    return Consumer<UserWorkoutProvider>(
      builder: (context, provider, child) {
        final exercises = provider.newWorkoutExercises;

        return Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              if (exercises.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No exercises added yet.',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ),
                ),
              // Use SliverList to display exercises if the list is not empty
              if (exercises.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = exercises[index];
                      return Dismissible(
                        key: Key(exercise.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            provider.removeExerciseFromNewWorkout(exercise),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(exercise.name),
                          // Optionally, add trailing or leading widgets here
                        ),
                      );
                    },
                    childCount: exercises.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10.0,
      ),
      child: ElevatedButton(
        onPressed: () {
          final userId = Provider.of<AuthProviderClass>(context, listen: false)
              .currentUser!
              .uid;
          final userWorkoutProvider =
              Provider.of<UserWorkoutProvider>(context, listen: false);
          debugPrint('Adding new workout');
          userWorkoutProvider.addNewWorkoutGroup(
            userId,
            _nameController.text,
            userWorkoutProvider.newWorkoutExercises,
          );
          Navigator.pushNamed(context, '/homescreen');
        },
        child: const Text('Submit'),
      ),
    );
  }

  void _navigateToAddExercisesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExercisesScreen(
          workout: WorkoutModel(
            exercises: [],
            group: selectedWorkoutGroup,
          ),
          isNewWorkout: true,
        ),
      ),
    );
  }
}

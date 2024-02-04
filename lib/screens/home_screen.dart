import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/workout_group_provider.dart';
import 'package:get_fit/providers/workout_provider.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/screens/set_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutProvider>(context, listen: false).fetchWorkouts();
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
        showLeading: false,
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

  Widget _buildWorkoutElementGrid(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final elements = workoutProvider.workouts;
        if (elements.isEmpty) {
          return const Center(
            child: Text('No workouts found'),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: elements.length,
          itemBuilder: (context, index) {
            return _buildWorkoutElementCard(context, elements[index]);
          },
        );
      },
    );
  }

  Widget _buildWorkoutElementCard(BuildContext context, workout) {
    String imageUrl = workout.image;
    return InkWell(
      onTap: () {
        _handleButtonClick(workout);
      },
      child: Opacity(
        opacity: 0.5,
        child: Card(
          shadowColor: AppTheme.primaryColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8.0),
          _buildBanner(),
          const SizedBox(height: 10.0),
          _buildWorkoutElementGrid(context),
        ],
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
          fontFamily: GoogleFonts.roboto().fontFamily,
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

  void _handleButtonClick(Workout workout) {
    setState(() => isLoading = true);
    try {
      _handleWorkoutGroupSelection(workout);
    } catch (e) {
      debugPrint('Error handling button click: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleWorkoutGroupSelection(Workout workout) {
    final workoutGroupProvider = Provider.of<WorkoutGroupProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workoutGroupProvider
          .setSelectedGroupAndFetchWorkouts(
              workout.group, FirebaseAuth.instance.currentUser!.uid)
          .then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SetScreen(
              workout: workout,
            ),
          ),
        );
      });
    });
  }
}

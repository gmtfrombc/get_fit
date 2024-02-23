import 'package:flutter/material.dart';
import 'package:get_fit/models/user_exercises.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/providers/set_provider.dart';
import 'package:get_fit/providers/user_workout_provider.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:get_fit/widgets/custom_number_pad.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SetScreen extends StatefulWidget {
  final List<UserExercises> exercises;
  final int groupIndex;
  const SetScreen({
    super.key,
    required this.exercises,
    required this.groupIndex,
  });

  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  final FocusNode weightFocusNode = FocusNode();
  final FocusNode repsFocusNode = FocusNode();

  String currentInputTarget = '';
  int editingIndex = -1;
  String? selectedAssessment;
  String? selectedRep;
  int setNumber = 1;
  int exerciseNumber = 0;

  @override
  void initState() {
    super.initState();
    // String userId =
    //     Provider.of<AuthProviderClass>(context, listen: false).currentUser!.uid;
    // Provider.of<UserWorkoutProvider>(context, listen: false)
    //     .fetchUserWorkoutGroups(userId);
    weightFocusNode.addListener(() {
      if (weightFocusNode.hasFocus) {
        weightController.selection = TextSelection(
            baseOffset: 0, extentOffset: weightController.text.length);
      }
    });
    repsFocusNode.addListener(() {
      if (repsFocusNode.hasFocus) {
        repsController.selection = TextSelection(
            baseOffset: 0, extentOffset: repsController.text.length);
      }
    });
    // Set the selected group
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    weightFocusNode.dispose();
    repsFocusNode.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSetBottomSheet(context); // Open the bottom sheet
        },
        child: const Icon(Icons.add),
      ),
      child: Stack(
        children: [_buildContent(context)],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildBanner(context),
                _buildWorkoutSection(),
                _buildSetList(context),
                _buildPreviousSetGrid(),
              ],
            ),
          ),
        ),
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
          onPressed:
              handleExerciseCompletion(widget.groupIndex, widget.exercises),
          child: Text(
            'Next',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              fontFamily: GoogleFonts.outfit().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    return Consumer<UserWorkoutProvider>(
      builder: (context, userWorkoutProvider, child) {
        final exercises = userWorkoutProvider.userExerciseList[0].exercises;
        if (exercises.isNotEmpty &&
            userWorkoutProvider.currentExerciseIndex < exercises.length) {
          var currentExercise =
              exercises[userWorkoutProvider.currentExerciseIndex];
          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                currentExercise
                    .name, // Update to show the name of the current exercise
                style: const TextStyle(fontSize: 20),
              ),
            ],
          );
        } else {
          return const SizedBox(); // Handle the case where there are no exercises or index is out of range
        }
      },
    );
  }

  Widget _buildSetList(BuildContext context) {
    return Consumer<SetProvider>(
      builder: (context, setProvider, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: setProvider.setList.length,
          itemBuilder: (context, index) {
            final set = setProvider.setList[index];
            return _buildSetCard(context, set, index);
          },
        );
      },
    );
  }

  Widget _buildSetCard(
      BuildContext context, Map<String, dynamic> set, int index) {
    bool isEditing = index == editingIndex;
    isEditing = true;
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (isEditing) {
                editingIndex = -1; // Exit editing mode
              } else {
                editingIndex = index; // Enter editing mode for this card
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: _buildEditableCardContent(context, set, index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableCardContent(
      BuildContext context, Map<String, dynamic> set, int index) {
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setProvider.removeSet(index);
      },
      child: Container(
        padding: const EdgeInsets.all(
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set: ${set['set']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onLongPress: () =>
                  _showAddSetBottomSheet(context, editingIndex: index),
              child: Text(
                'Weight: ${set['weight']}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            InkWell(
              onLongPress: () =>
                  _showAddSetBottomSheet(context, editingIndex: index),
              child: Text(
                'Reps: ${set['reps']}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSetGrid() {
    return const Text('Here is the set grid');
  }

  void _showAddSetBottomSheet(BuildContext context, {int? editingIndex}) {
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    bool isEditing = editingIndex != null &&
        editingIndex >= 0 &&
        editingIndex < setProvider.setList.length;

    if (isEditing) {
      final currentSet = setProvider.setList[editingIndex];
      weightController.text = currentSet['weight'];
      repsController.text = currentSet['reps'];
    } else {
      if (setProvider.setList.isNotEmpty) {
        // Use the last set's values as defaults for the new set
        final lastSet = setProvider.setList.last;
        weightController.text = lastSet['weight'];
        repsController.text = lastSet['reps'];
      } else {
        // Default values for the first set
        weightController.text = '100';
        repsController.text = '10';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(isEditing ? 'Edit Set' : 'Add Set',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    // Displaying and editing weight
                    TextField(
                      controller: weightController,
                      focusNode: weightFocusNode,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      // readOnly: false,
                      onTap: () {
                        setState(() => currentInputTarget = 'weight');
                      },
                    ),
                    TextField(
                      controller: repsController,
                      focusNode: repsFocusNode,
                      decoration: const InputDecoration(labelText: 'Reps'),
                      onTap: () {
                        setState(() => currentInputTarget = 'reps');
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: CustomNumberPad(onValueSelected: (String value) {
                        setState(() {
                          TextEditingController currentController =
                              currentInputTarget == 'weight'
                                  ? weightController
                                  : repsController;
                          bool shouldReplace =
                              currentController.selection.baseOffset == 0 &&
                                  currentController.selection.extentOffset ==
                                      currentController.text.length;

                          if (value == 'backspace') {
                            if (!shouldReplace &&
                                currentController.text.isNotEmpty) {
                              currentController.text = currentController.text
                                  .substring(
                                      0, currentController.text.length - 1);
                            }
                          } else {
                            if (shouldReplace) {
                              currentController.text = value;
                            } else {
                              currentController.text += value;
                            }
                          }
                          currentController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: currentController.text.length));
                        });
                      }),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (isEditing) {
                              setProvider.updateSet(editingIndex,
                                  weightController.text, repsController.text);
                            } else {
                              setProvider.addSet(
                                  weightController.text, repsController.text);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Confirm'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  handleExerciseCompletion(int groupIndex, List<UserExercises> exercises) {
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);
    final setProvider = Provider.of<SetProvider>(context, listen: false);
    // Add current exercise to the session
    userWorkoutProvider.addToWorkoutSession(
      exercises[groupIndex].exercises[0].name,
      setProvider.setList,
    );

    if (userWorkoutProvider.isLastExercise) {
      debugPrint('Last exercise');
      // Last exercise, save session
      userWorkoutProvider.saveWorkoutSession(context);
    } else {
      // Move to next exercise
      userWorkoutProvider.nextExercise();
    }

    // Clear current sets
    setProvider.clearSets();
  }
}

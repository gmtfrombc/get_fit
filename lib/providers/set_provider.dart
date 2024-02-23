import 'package:flutter/material.dart';

class SetProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _setList = [];

  String _currentWeight = '';
  String _currentReps = '';
  String _currentInputTarget = '';

  List<Map<String, dynamic>> get setList => _setList;

  int get setNumber => _setList.length + 1;
  String get currentWeight => _currentWeight;
  String get currentReps => _currentReps;

  void setCurrentInput(String target, String weight, String reps) {
    _currentInputTarget = target;
    _currentWeight = weight;
    _currentReps = reps;
    notifyListeners();
  }

    // Update current input values
  void updateInputValue(String value) {
    if (_currentInputTarget == 'weight') {
      _currentWeight = value;
    } else if (_currentInputTarget == 'reps') {
      _currentReps = value;
    }
    notifyListeners();
  }

  void addSet(String weight, String reps) {
    _setList.add({
      'set': _setList.length + 1,
      'weight': weight,
      'reps': reps,
    });
    notifyListeners();
  }

void updateSet(int index, String weight, String reps) {
    if (index >= 0 && index < _setList.length) {
      _setList[index] = {
        'set': index + 1, 
        'weight': weight,
        'reps': reps,
      };
      notifyListeners();
    }
  }


void removeSet(int index) {
    if (index >= 0 && index < _setList.length) {
      _setList.removeAt(index);
      for (int i = 0; i < _setList.length; i++) {
        _setList[i]['set'] = i + 1; // Recalculate set numbers
      }
      notifyListeners();
    }
  }
  
  void clearSets() {
    _setList.clear();
    notifyListeners();
  }
}

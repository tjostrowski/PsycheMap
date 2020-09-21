import 'package:flutter/material.dart';

class Db {
  static Db of(BuildContext context) {
    return new Db();
  }

  List<DrugPortion> getCurrentDrugs() {
    return [
      DrugPortion('Abilify', '50mg', 2),
      DrugPortion('Zolafren', '20mg', 1),
      DrugPortion('Absenor', '20mg', 1),
      DrugPortion('Acatar', '20mg', 1),
      DrugPortion('Acespargin', '20mg', 1),
      DrugPortion('Acidolac', '20mg', 1),
      DrugPortion('Acidolit', '20mg', 1),
      DrugPortion('Aflavic', '40mg', 1),
      DrugPortion('Aflegan', '40mg', 1),
      DrugPortion('Afugin', '40mg', 1),
    ];
  }
}

class DrugPortion {
  String drugName;
  String drugDose;
  int count;

  // e.g. Abilify 50mg 2
  DrugPortion(this.drugName, this.drugDose, this.count);
}

enum WorkflowType {
  workoutLog("Workout Log"),
  cutLog("Cut Log");

  const WorkflowType(this.displayName);
  final String displayName;
}

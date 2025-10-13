enum WorkoutType {
  upper('Upper'),
  lower('Lower'),
  push('Push'),
  pull('Pull'),
  legs('Legs'),
  active('Active');

  const WorkoutType(this.displayName);
  final String displayName;
}

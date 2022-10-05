class ScreenArguments {
  final String personId;
  final String jobId;
  final String jobName;
  final List apiariesNames;
  final List apiariesId;
  final List apiaryNum;
  final String hiveattended;
  final String? taskId;

  ScreenArguments(this.personId, this.jobId, this.jobName, this.apiariesNames,
      this.apiariesId, this.apiaryNum, this.hiveattended,
      {this.taskId});
}

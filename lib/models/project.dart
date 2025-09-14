class Project {
  final String name;
  final String email;
  final String address;
  final String city;
  final String region;
  final String status;
  final String frequency;
  final String projectDescription;
  final String rooms;
  final String workers;
  final String propertySize;
  final String specialRequest;
  final String additionalServices;
  final String type;
  final String startDate;
  final String finishDate;

  Project({
    required this.name,
    required this.email,
    required this.address,
    required this.city,
    required this.region,
    required this.status,
    required this.frequency,
    required this.projectDescription,
    required this.rooms,
    required this.workers,
    required this.propertySize,
    required this.specialRequest,
    required this.additionalServices,
    required this.type,
    required this.startDate,
    required this.finishDate,
  });

  factory Project.empty() {
    return Project(
      name: '',
      email: '',
      address: '',
      city: '',
      region: '',
      status: 'In Progress',
      frequency: 'Daily',
      projectDescription: '',
      rooms: '',
      workers: '',
      propertySize: '',
      specialRequest: '',
      additionalServices: '',
      type: 'Residential',
      startDate: '',
      finishDate: '',
    );
  }
}

class ContactModel {
  final String id;
  final String fullName;
  final String telephone;
  final String email;

  ContactModel({
    required this.id,
    required this.fullName,
    required this.telephone,
    required this.email,
  });
}

// Users in database but not in user's contacts
final List<ContactModel> databaseUsers = [
  ContactModel(
    id: '321054',
    fullName: 'John Doe',
    telephone: '+251911234567',
    email: 'john.doe@example.com',
  ),
  ContactModel(
    id: '123456',
    fullName: 'Jane Smith',
    telephone: '+251922345678',
    email: 'jane.smith@example.com',
  ),
  ContactModel(
    id: '789012',
    fullName: 'Mike Johnson',
    telephone: '+251933456789',
    email: 'mike.j@example.com',
  ),
  ContactModel(
    id: '345678',
    fullName: 'Sarah Williams',
    telephone: '+251944567890',
    email: 'sarah.w@example.com',
  ),
];

// Users in user's contact list
final List<ContactModel> myContacts = [
  ContactModel(
    id: '234567',
    fullName: 'David Brown',
    telephone: '+251955678901',
    email: 'david.b@example.com',
  ),
  ContactModel(
    id: '890123',
    fullName: 'Emma Davis',
    telephone: '+251966789012',
    email: 'emma.d@example.com',
  ),
  ContactModel(
    id: '456789',
    fullName: 'Alex Wilson',
    telephone: '+251977890123',
    email: 'alex.w@example.com',
  ),
];

class Permissions {

  // Store the permissions
  
  final Map<String, bool>? permissionsDict;

  Permissions({required this.permissionsDict});

  // Useful getters
  bool get all => permissionsDict == null;
  bool get samplePermission => all || (permissionsDict!['samplePermission'] ?? false);

}

class Role {

  // Object to control roles and permissions of users

  final RoleTag role;
  final Map<String, bool>? permissionsDict;
  late Permissions permissions;

  Role({ required this.role, required this.permissionsDict }) {
    permissions = Permissions(permissionsDict: permissionsDict);
  }

  // Useful getters
  bool get isAdmin => role == RoleTag.admin;

  // Conversion methods
  static Role fromDict(Map<String, dynamic> data) {
    return Role(role: RoleTag.values.byName(data['role']), permissionsDict: data['permissions']);
  }

}

// Tagged roles enums
enum RoleTag {
  admin,
  worker
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/code.dart';
import 'package:flameo/models/role.dart';
import 'package:flameo/services/auth_database.dart';
import 'package:flameo/services/config_provider.dart';

class AuthService {
  final ConfigProvider config;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService({required this.config});

  String getErrorCode(Object errorObject) {
    // Extract the error code reference from the error string given
    RegExp errorCodePattern = RegExp(r'\(auth/([^)]+)\)');
    RegExp errorCodePattern2 = RegExp(r'\[firebase_auth/([^)]+)\]');
    RegExpMatch? errorMsgMatch = errorCodePattern.firstMatch(errorObject.toString());
    RegExpMatch? errorMsgMatch2 = errorCodePattern2.firstMatch(errorObject.toString());
    return errorMsgMatch?.group(1) ?? errorMsgMatch2?.group(1) ?? '';
  }

  // User stream for whole app
  Stream<ClientUser?> get user {
    return _auth.authStateChanges().map(ClientUser.fromFirebaseUser);
  }

  // email and password register
  Future registerWithEmailAndPassword(String email, String password, String name, Code? code) async {
    User? user;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
    } catch (e) {
      return {
            'email-already-in-use': 'Este usuario ya existe, inicia sesión',
            'invalid-email': 'Email inválido',
            'operation-not-allowed':
                'No es posible el registro, por favor contacta con flameoapp@gmail.com',
            'weak-password': 'Contraseña débil',
            'network-request-failed':
                'Error de conexión, comprueba la conexión a internet'
          }[getErrorCode(e)] ??
          'Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }

    String companyID = code?.isNewCompany ?? true ? 
      await AuthDatabaseService(config: config).createCompany({
        'companyName': name,
        'code': code?.code,
        'dataCompleted': false,
        'mastersApprove': true,
        'faith_called': false,
        'email': email
      })
      : code!.companyID!;
        
    await AuthDatabaseService(uid: user!.uid, config: config).createUser({
      'email': email,
      'code': code?.code,
      'tutorialCompleted': true,
      'role': code?.companyID == null ? RoleTag.admin.name : RoleTag.worker.name,
      'permissions': code?.permissions,
      'companyID': companyID,
      'name': name
    });
    return ClientUser.fromFirebaseUser(user);
  }

  // Register an anonymous customer
  Future registerAnonymously() async {
    User? user;
    try {
      UserCredential result = await _auth.signInAnonymously();
      user = result.user;
    } catch (e) {
      return {
            'operation-not-allowed':
                'No es posible el registro, por favor contacta con flameoapp@gmail.com',
            'network-request-failed':
                'Error de conexión, comprueba la conexión a internet'
          }[getErrorCode(e)] ??
          'Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }
    return user;
  }

  // email and password login
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return ClientUser.fromFirebaseUser(user);
    } catch (e) {
      return {
            'invalid-email': 'Email incorrecto',
            'user-disabled': 'Tu cuenta ha sido bloqueada',
            'user-not-found': 'Email o contraseña incorrecto',
            'wrong-password': 'Email o contraseña incorrecto',
            'operation-not-allowed':
                'No es posible iniciar sesión, por favor contacta con flameoapp@gmail.com',
            'network-request-failed':
                'Error de conexión, comprueba la conexión a internet'
          }[getErrorCode(e)] ??
          '$e Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }
  }

  bool get isUserLoggedin{
       User? user = FirebaseAuth.instance.currentUser;
       return user != null;
  }

  /// This function returns true if the logged in user is master
  bool get userIsMaster {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null && user.uid == 'sauronID';
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  // Delete account
  void deleteAccount() {
    _auth.currentUser!.delete();
  }

  // Change password
  Future changePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
    } catch (e) {
      return {
            'weak-password': 'La contraseña no es segura',
            'requires-recent-login': 'Inicia sesión de nuevo'
          }[getErrorCode(e)] ??
          'Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }
  }

  // Reauthenticate for email or password update
  Future reAuthenticate(String email, String password) async {
    try {
      await _auth.currentUser!.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password));
    } catch (e) {
      return {
            'wrong-password': 'La contraseña actual es incorrecta'
          }[getErrorCode(e)] ??
          'Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }
  }

  // Recover password
  Future recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Nothing to do, to avoid users spying
    }
  }

  // Reset password
  Future resetPassword(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      return {
        'expired-action-code': 'Enlace caducado, solicita la recuperación de contraseña de nuevo',
        'invalid-action-code': 'Enlace incorrecto, no ha sido posible recuperar la contraseña, contacta con info@flameoapp.com',
        'user-disabled': 'Tu cuenta ha sido bloqueada',
        'user-not-found': 'Email o contraseña incorrecto',
        'weak-password': 'Contraseña débil'
      }[getErrorCode(e)] ??
        'Error desconocido, si el problema persiste contacta con info@flameoapp.com';
    }
  }
}

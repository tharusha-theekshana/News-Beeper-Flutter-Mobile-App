import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsbeeper/core/exceptions/app_exception.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_messages.dart';
import '../models/app_config_model.dart';

class AppConfigService {
  final FirebaseFirestore _firestore;

  AppConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AppConfigModel> fetchAppConfig() async {
    final metaData = _firestore.collection(AppConstants.metaDataCollection);

    final snapshots = await Future.wait([
      metaData.doc(AppConstants.apiDataDoc).get(),
      metaData.doc(AppConstants.appDataDoc).get(),
    ]);

    final apiSnapshot = snapshots[0];
    final appSnapshot = snapshots[1];

    // Check if api data not available
    if (!apiSnapshot.exists || !appSnapshot.exists) {
      throw const AppException(AppMessages.configMissing);
    }

    // Convert to the model datal
    final config = AppConfigModel.fromFirestore(
      apiData: apiSnapshot.data() ?? {},
      appData: appSnapshot.data() ?? {},
      apiKeyField: AppConstants.apiKeyField,
      baseUrlField: AppConstants.baseUrlField,
      appVersionField: AppConstants.appVersionField,
    );

    // The documents exist but a field might be empty.
    if (!config.isValid) {
      throw const AppException(AppMessages.configIncomplete);
    }

    return config;
  }
}
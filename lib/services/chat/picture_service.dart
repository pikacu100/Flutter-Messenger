// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class UploadManager {
  static final UploadManager _instance = UploadManager._internal();
  factory UploadManager() => _instance;
  UploadManager._internal();

  final StreamController<UploadProgress> _progressController =
      StreamController<UploadProgress>.broadcast();
  Stream<UploadProgress> get progressStream => _progressController.stream;

  UploadTask? _currentUploadTask;
  String? _currentFileName;

  String? get currentFileName => _currentFileName;

  Future<String?> uploadFile(File file, String destination) async {
    _currentFileName = destination.split('/').last;

    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(destination);
      _currentUploadTask = storageRef.putFile(file);

      _currentUploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        final totalBytes = snapshot.totalBytes;
        final bytesTransferred = snapshot.bytesTransferred;

        _progressController.add(UploadProgress(
          progress: progress,
          fileName: _currentFileName!,
          totalBytes: totalBytes,
          bytesTransferred: bytesTransferred,
        ));
      });

      final TaskSnapshot taskSnapshot = await _currentUploadTask!;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      _progressController.add(UploadProgress(
        progress: 1.0,
        fileName: _currentFileName!,
        totalBytes: taskSnapshot.totalBytes,
        bytesTransferred: taskSnapshot.totalBytes,
        isCompleted: true,
        downloadUrl: downloadUrl,
      ));

      _currentUploadTask = null;
      return downloadUrl;
    } catch (e) {
      _progressController.add(UploadProgress(
        progress: 0.0,
        fileName: _currentFileName!,
        totalBytes: 0,
        bytesTransferred: 0,
        error: e.toString(),
      ));

      _currentUploadTask = null;
      return null;
    }
  }

  void cancelUpload() {
    if (_currentUploadTask != null) {
      _currentUploadTask!.cancel();
      _currentUploadTask = null;

      _progressController.add(UploadProgress(
        progress: 0.0,
        fileName: _currentFileName ?? 'unknown',
        totalBytes: 0,
        bytesTransferred: 0,
        isCancelled: true,
      ));
    }
  }

  void dispose() {
    if (_currentUploadTask != null) {
      _currentUploadTask!.cancel();
    }
    _progressController.close();
  }
}

class UploadProgress {
  final double progress;
  final String fileName;
  final int totalBytes;
  final int bytesTransferred;
  final bool isCompleted;
  final bool isCancelled;
  final String? error;
  final String? downloadUrl;

  UploadProgress({
    required this.progress,
    required this.fileName,
    required this.totalBytes,
    required this.bytesTransferred,
    this.isCompleted = false,
    this.isCancelled = false,
    this.error,
    this.downloadUrl,
  });
}

Future<XFile?> showImageSourceDialog(BuildContext context, bool isDarkMode) async {
  return await showModalBottomSheet<XFile?>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 80,
              margin: const EdgeInsets.only(bottom: 5.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Image Source',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildImageSourceButton(
                  context: context,
                  isDarkMode: isDarkMode,
                  text: "Gallery",
                  icon: Icons.photo_library,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                    Navigator.of(context).pop(file);
                  },
                ),
                buildImageSourceButton(
                  context: context,
                  isDarkMode: isDarkMode,
                  text: "Camera",
                  icon: Icons.photo_camera,
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.camera);
                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget buildImageSourceButton({
  required BuildContext context,
  required bool isDarkMode,
  required String text,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: isDarkMode ? Colors.grey.shade500 : Colors.black,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade200 : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
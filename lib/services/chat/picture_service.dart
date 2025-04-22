import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/services/chat/chat_service.dart';
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

void showImageSourceDialog(BuildContext context, bool isDarkMode) {
  showModalBottomSheet(
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
                    onPressed: () {
                      ImagePickerService().getImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                buildImageSourceButton(
                    context: context,
                    isDarkMode: isDarkMode,
                    text: "Camera",
                    icon: Icons.photo_camera,
                    onPressed: () {
                      ImagePickerService().getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    }),
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

class ImagePickerService {
  final ChatService chatService = ChatService();

  Future<void> getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String destination = 'images/$fileName';

      final uploadManager = UploadManager();
      String? downloadUrl =
          await uploadManager.uploadFile(imageFile, destination);

      if (downloadUrl != null) {}
    } else {
      BuildContext? context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    }
  }

  Future<void> sendImage(
      String imageUrl, String receiverId, String message) async {
    await chatService.sendImageMessage(
      receiverId: receiverId,
      imageUrl: imageUrl,
      caption: message,
    );
  }
}

class UploadProgressWidget extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onCancel;
  final bool autoDismiss;
  final Duration? autoDismissDuration;

  const UploadProgressWidget({
    super.key,
    this.isDarkMode = false,
    this.onCancel,
    this.autoDismiss = true,
    this.autoDismissDuration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UploadProgress>(
      stream: UploadManager().progressStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final progress = snapshot.data!;

        if (progress.isCompleted) {
          return _buildCompletedWidget(progress);
        }

        if (progress.error != null) {
          return _buildErrorWidget(progress);
        }

        return _buildProgressWidget(progress);
      },
    );
  }

  Widget _buildCompletedWidget(UploadProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Complete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  progress.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(UploadProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  progress.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressWidget(UploadProgress progress) {
    final percentComplete = (progress.progress * 100).toStringAsFixed(1);
    final transferredMB =
        (progress.bytesTransferred / (1024 * 1024)).toStringAsFixed(2);
    final totalMB = (progress.totalBytes / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      progress.fileName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onCancel != null)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.progress,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentComplete%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '$transferredMB MB / $totalMB MB',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

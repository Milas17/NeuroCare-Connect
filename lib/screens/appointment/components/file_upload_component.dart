import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/screens/patient/screens/my_report_screen.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileUploadComponent extends StatefulWidget {
  @override
  State<FileUploadComponent> createState() => _FileUploadComponentState();
}

class _FileUploadComponentState extends State<FileUploadComponent> {
  TextEditingController fileCont = TextEditingController();

  static const int maxFileSize = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xls', 'xlsx'];

  @override
  void initState() {
    super.initState();
    _updateFileCount();
  }

  void _updateFileCount() {
    fileCont.text = appointmentAppStore.reportList.isNotEmpty ? "${appointmentAppStore.reportList.length} ${locale.lblFilesSelected}" : '';
  }

  bool isValidFileSize(int fileSize) => fileSize <= maxFileSize && fileSize > 0;

  bool isValidFileType(String fileName) {
    if (fileName.isEmpty) return false;
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  Future<PlatformFile?> convertReportDataToPlatformFile(ReportData report) async {
    try {
      String displayName = report.name?.validate() ?? '';
      String? pathOrUrl = report.uploadReport;

      if (displayName.isEmpty || pathOrUrl.isEmptyOrNull) return null;

      // Get extension from URL if needed
      String extension = '';
      if (pathOrUrl!.contains('.')) {
        extension = '.' + pathOrUrl.split('.').last;
      }

      // Create file name for saving
      String fileNameForSaving = displayName;
      if (!displayName.toLowerCase().endsWith(extension.toLowerCase())) {
        fileNameForSaving += extension;
      }

      File file;
      if (pathOrUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(pathOrUrl)).timeout(const Duration(seconds: 30));
        if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

        final tempDir = await getTemporaryDirectory();
        file = File('${tempDir.path}/$fileNameForSaving');
        await file.writeAsBytes(response.bodyBytes, flush: true);
      } else {
        file = File(pathOrUrl);
        if (!file.existsSync()) return null;
      }

      //if (!isValidFileSize(file.lengthSync())) return null;

      return PlatformFile(
        name: displayName,
        path: file.path,
        size: file.lengthSync(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> pickSingleFile() async {
    final result = await MyReportsScreen(enableSelection: true).launch(context);

    // ✅ If result is null or empty list, user canceled → stop here
    if (result == null || (result is List && result.isEmpty)) {
      return;
    }

    // ✅ If reports were selected
    if (result is List<ReportData>) {
      List<PlatformFile> platformFiles = [];
      for (var report in result) {
        PlatformFile? platformFile = await convertReportDataToPlatformFile(report);
        if (platformFile != null) {
          platformFiles.add(platformFile);
          // Check invalid files
          final invalidSizeFiles = platformFiles.where((f) => !isValidFileSize(f.size)).toList();
          final invalidTypeFiles = platformFiles.where((f) => !isValidFileType(f.path!)).toList();

          if (invalidSizeFiles.isNotEmpty) {
            toast(locale.lblSomeFilesExceedLimit);
            return;
          }

          if (invalidTypeFiles.isNotEmpty) {
            toast(locale.lblInvalidFileType);
            return;
          }

          // ✅ Only valid files are added
          appointmentAppStore.addReportData(data: platformFiles);
          _updateFileCount();
          setState(() {});
        } else {
          toast(locale.lblNoReportWasSelected);
        }
      }
      if (platformFiles.isNotEmpty) {
        appointmentAppStore.addReportData(data: platformFiles);
        _updateFileCount();
        setState(() {});
      } else {
        toast('No valid reports were selected');
      }
      return;
    }

    // final pickedFiles = await FilePicker.platform.pickFiles(
    //   allowMultiple: isProEnabled(),
    //   type: FileType.custom,
    //   allowedExtensions: allowedExtensions,
    // );
  }

  Future<void> _openFile(String path) async {
    try {
      if (path.startsWith('http')) {
        final response = await http.get(Uri.parse(path)).timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final fileName = path.split('/').last;
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          await OpenFile.open(file.path);
        } else {
          toast('Failed to download file: ${response.statusCode}');
        }
      } else {
        await OpenFile.open(path);
      }
    } catch (e) {
      toast('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: fileCont,
            textFieldType: TextFieldType.OTHER,
            readOnly: true,
            decoration: inputDecoration(
              context: context,
              labelText: locale.lblAddMedicalReport,
              suffixIcon: IconButton(
                icon: const Icon(Icons.upload_file, size: 18),
                onPressed: pickSingleFile,
              ),
            ),
          ),
          if (appointmentAppStore.reportList.isNotEmpty) 16.height,
          if (appointmentAppStore.reportList.isNotEmpty)
            ListView.builder(
              itemCount: appointmentAppStore.reportList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                dynamic report = appointmentAppStore.reportList[index];
                String reportName = report is ReportData ? (report.name?.validate() ?? 'Report ${index + 1}') : (report.name ?? 'Report ${index + 1}');
                String reportPath = report is ReportData ? (report.uploadReport ?? '') : (report.path ?? '');

                return SettingItemWidget(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: reportPath.isNotEmpty ? () => _openFile(reportPath) : () {},
                  leading: Icon(Icons.document_scanner, color: context.primaryColor),
                  title: reportName,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  trailing: TextButton(
                    onPressed: () {
                      appointmentAppStore.removeReportData(index: index);
                      _updateFileCount();
                      setState(() {});
                    },
                    child: Text(
                      locale.lblRemove,
                      style: boldTextStyle(color: Colors.red, size: 12),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

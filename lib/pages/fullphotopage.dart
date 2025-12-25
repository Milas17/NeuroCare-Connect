import 'package:flutter/material.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Stack(
          children: [
            PhotoView(
              backgroundDecoration: Utils.setBackground(white, 0),
              imageProvider: NetworkImage(url),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(12),
                    decoration: Utils.setBackground(
                        colorAccent.withValues(alpha: 0.5), 25),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

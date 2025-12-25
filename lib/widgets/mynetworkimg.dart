import 'package:cached_network_image/cached_network_image.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyNetworkImage extends StatelessWidget {
  String imageUrl;
  double? imgHeight, imgWidth;
  dynamic fit;
  bool? islandscap;

  MyNetworkImage(
      {super.key,
      required this.imageUrl,
      required this.fit,
      this.imgHeight,
      this.islandscap,
      this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imgHeight,
      width: imgWidth,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) {
          return MyImage(
            width: imgWidth ?? 0.0,
            height: imgHeight ?? 0.0,
            imagePath: islandscap == false || islandscap == null
                ? "no_image_port.png"
                : "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
        errorWidget: (context, url, error) {
          return MyImage(
            width: imgWidth ?? 0.0,
            height: imgHeight ?? 0.0,
            imagePath: islandscap == false || islandscap == null
                ? "no_image_port.png"
                : "no_image_land.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}

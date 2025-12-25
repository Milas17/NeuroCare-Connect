import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:yourappname/model/blogmodel.dart';

class BlogDetails extends StatefulWidget {
  final Result? blogList;
  const BlogDetails({super.key, required this.blogList});

  @override
  State<BlogDetails> createState() => _BlogDetailsState();
}

class _BlogDetailsState extends State<BlogDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "Blog", false, true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: MyNetworkImage(
                  imageUrl: widget.blogList?.image.toString() ?? "",
                  fit: BoxFit.cover,
                  imgHeight: 150,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: MyText(
                      type: 2,
                      maxline: 2,
                      text: widget.blogList?.title.toString() ?? "",
                      fontsize: 26,
                      fontweight: FontWeight.w700,
                      color: black,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Iconify(
                    Ph.share_network_duotone,
                    size: 25,
                    color: black,
                  )
                ],
              ),
              const SizedBox(height: 20),
              myHtmlText(
                widget.blogList?.description.toString() ?? "",
                color: black,
                fontsize: Dimens.text14Size,
                fontWeight: FontWeight.w400,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myHtmlText(
    String text, {
    Color color = black,
    double? fontsize,
    double? fontsizeWeb,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Html(
      data: text,
      style: {
        "body": Style(
          textAlign: textAlign,
          fontSize:
              FontSize(kIsWeb ? (fontsizeWeb ?? 12.0) : (fontsize ?? 12.0)),
          maxLines: 10000,
          color: color,
          fontWeight: fontWeight,
        ),
      },
    );
  }

  Widget shimerDetails() {
    return Column(
      children: [
        CustomWidget.roundcorner(
          height: 150,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 20,
        ),
        const Row(
          children: [
            Expanded(
              child: CustomWidget.roundcorner(
                height: 30,
                width: 100,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Iconify(
              Ph.share_network_duotone,
              size: 25,
              color: black,
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const IntrinsicHeight(
          child: Row(
            children: [
              CustomWidget.roundcorner(
                height: 15,
                width: 100,
              ),
              SizedBox(
                width: 10,
              ),
              VerticalDivider(
                color: gray,
                thickness: 1,
              ),
              SizedBox(
                width: 10,
              ),
              CustomWidget.roundcorner(
                height: 15,
                width: 60,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomWidget.roundcorner(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 3,
        )
      ],
    );
  }
}

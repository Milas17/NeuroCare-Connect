// import 'package:yourappname/utils/colors.dart';
// import 'package:yourappname/utils/dimens.dart';
// import 'package:yourappname/widgets/mynetworkimg.dart';
// import 'package:yourappname/widgets/mytext.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../provider/commentprovider.dart';

// class CommentReply extends StatefulWidget {
//   final dynamic commentid;
//   const CommentReply({super.key, required this.commentid});

//   @override
//   State<CommentReply> createState() => _CommentReplyState();
// }

// class _CommentReplyState extends State<CommentReply>
//     with AutomaticKeepAliveClientMixin {
//   List? result;
//   late CommentProvider commentprovider;
//   @override
//   void initState() {
//     super.initState();
//     getApi();
//   }

//   getApi() async {
//     commentprovider = Provider.of<CommentProvider>(context, listen: false);
//     await commentprovider.getReplyComent(widget.commentid.toString());
//     setState(() {
//       result = commentprovider.replyCommentsListModel.result;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Consumer<CommentProvider>(
//       builder: (context, commentprovider, child) {
//         if (commentprovider.replyCmtLoading) {
//           return const SizedBox.shrink();
//         } else {
//           if ((result?.length ?? 0) > 0) {
//             return ListView.builder(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: result?.length ?? 0,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 10.0),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(50),
//                         child: MyNetworkImage(
//                           imageUrl:
//                               result?[index].patientsProfileImg.toString() ??
//                                   "",
//                           fit: BoxFit.cover,
//                           imgHeight: 40,
//                           imgWidth: 40,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                           child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           MyText(
//                             text: result?[index].patientName.toString() ?? "",
//                             fontsize: Dimens.text14Size,
//                             color: white,
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           MyText(
//                             text: result?[index].review.toString() ?? "",
//                             fontsize: Dimens.text13Size,
//                             color: gray,
//                           ),
//                         ],
//                       ))
//                     ],
//                   ),
//                 );
//               },
//             );
//           } else {
//             return const SizedBox.shrink();
//           }
//         }
//       },
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/model/chatusermodel.dart';
import 'package:yourappname/model/conversationalmodel.dart';
import 'package:yourappname/model/lasmessagemodel.dart';
import 'package:yourappname/pages/chatscreen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> with TickerProviderStateMixin {
  List<ChatUserModel>? myChatList = [];
  SharedPre sharedPref = SharedPre();
  String currentUserFId = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
    super.initState();
  }

  Future getUserData() async {
    currentUserFId = await sharedPref.read("firebaseid");
    printLog("firebaseid ==> $currentUserFId");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: MyText(
          multilanguage: true,
          color: colorPrimaryDark,
          text: "inbox",
          fontsize: Dimens.text22Size,
          fontweight: FontWeight.w500,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.start,
          fontstyle: FontStyle.normal,
        ),
      ),
      body: SafeArea(
        child: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return FutureBuilder<List<ConversionModel>>(
      future: _fetch(),
      builder: (BuildContext context,
          AsyncSnapshot<List<ConversionModel>> snapshot) {
        if (snapshot.hasError) {
          printLog("snapshot ERROR ==========> ${snapshot.error.toString()}");
          return const NoData(text: '');
        }
        if (snapshot.hasData) {
          if ((snapshot.data?.length ?? 0) > 0) {
            return SingleChildScrollView(
              child: AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 15,
                itemCount: snapshot.data?.length ?? 0,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int position) {
                  return _buildUserItem(
                      position: position, chatUserList: snapshot.data);
                },
              ),
            );
          } else {
            return const NoData(text: '');
          }
        } else {
          return shimmer();
        }
      },
    );
  }

  Widget _buildUserItem(
      {required int position, required List<ConversionModel>? chatUserList}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (Utils.checkLoginUser(context)) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Chatscreen(
                  number: chatUserList?[position]
                          .chatUserModel
                          ?.mobileNumber
                          .toString() ??
                      "",
                  toUserName:
                      chatUserList?[position].chatUserModel?.name.toString() ??
                          "",
                  toChatId:
                      chatUserList?[position].chatUserModel?.userid.toString(),
                  profileImg: chatUserList?[position]
                          .chatUserModel
                          ?.photoUrl
                          .toString() ??
                      "",
                  bioData: chatUserList?[position]
                          .chatUserModel
                          ?.biodata
                          .toString() ??
                      "",
                );
              },
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: MyNetworkImage(
                imageUrl: chatUserList?[position].chatUserModel?.photoUrl ?? "",
                fit: BoxFit.cover,
                imgHeight: 52,
                imgWidth: 52,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  color: colorPrimaryDark,
                  text: chatUserList?[position].chatUserModel?.name ?? "",
                  fontsize: Dimens.text16Size,
                  fontweight: FontWeight.w600,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 5),
                (chatUserList?[position].lastMessage?.type ?? 0) == 0
                    ? Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: MyText(
                          color: ((chatUserList?[position].lastMessage?.read ??
                                      false) ==
                                  false)
                              ? colorPrimaryDark
                              : otherColor,
                          text:
                              (chatUserList?[position].lastMessage?.content ??
                                          "")
                                      .isNotEmpty
                                  ? (chatUserList?[position]
                                          .lastMessage
                                          ?.content ??
                                      "")
                                  : chatUserList?[position]
                                          .chatUserModel
                                          ?.biodata ??
                                      "",
                          fontsize: Dimens.text14Size,
                          fontweight: FontWeight.w400,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      )
                    : MyImage(
                        width: 15,
                        height: 15,
                        fit: BoxFit.contain,
                        imagePath: "ic_pin.png",
                      ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            alignment: Alignment.center,
            child: MyText(
              color: ((chatUserList?[position].lastMessage?.read ?? false) ==
                      false)
                  ? colorAccent
                  : otherColor,
              text: DateFormat('hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(int.parse(
                      chatUserList?[position].lastMessage?.timestamp ?? ""))),
              fontsize: Dimens.text13Size,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ConversionModel>> _fetch() async {
    var messageIds = <String>[];
    var userIds = <String>[];

    // Fetching All Messages.
    var messageSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .where(FirestoreConstants.users, arrayContains: currentUserFId)
        .get();
    if (messageSnapshot.docs.isNotEmpty) {
      for (int i = 0; i < messageSnapshot.docs.length; i++) {
        messageIds.add(messageSnapshot.docs[i].id.toString());
        printLog("messageIds length ========> ${messageIds.length}");
      }
    }

    List<LastMessage> lastMessageList = [];
    /* Get "lastMessage" Documents */
    for (int i = 0; i < messageIds.length; i++) {
      var messagesDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathMessageCollection)
          .doc(messageIds[i])
          .get();

      if ((messagesDoc.data()?.length ?? 0) > 0) {
        printLog("====================== Users fetched ======================");
        if (messagesDoc[FirestoreConstants.users] != null) {
          printLog(
              "users ==========> ${messagesDoc[FirestoreConstants.users]}");
          if (messagesDoc[FirestoreConstants.users][0].toString() != "" ||
              messagesDoc[FirestoreConstants.users][1].toString() != "") {
            printLog("currentUserFId ==========> $currentUserFId");
            if (messagesDoc[FirestoreConstants.users][0].toString() ==
                    currentUserFId ||
                messagesDoc[FirestoreConstants.users][1].toString() ==
                    currentUserFId) {
              userIds.add(messagesDoc[FirestoreConstants.users][0].toString());
              userIds.add(messagesDoc[FirestoreConstants.users][1].toString());
              printLog("userIds length ========> ${userIds.length}");

              /* LastMessage */
              if (messagesDoc
                      .data()
                      ?.containsKey(FirestoreConstants.lastMessage) ??
                  false) {
                LastMessage lastMessageModel = LastMessage.fromMap(
                    messagesDoc[FirestoreConstants.lastMessage]);
                lastMessageList.add(lastMessageModel);
                printLog(
                    "lastMessageModel content ==========> ${lastMessageModel.content}");
                printLog(
                    "lastMessageList length ==========> ${lastMessageList.length}");
              }
            }
          }
        }
      }
    }

    List<ChatUserModel> userList = [];
    /* Get Users Data */
    for (int i = 0; i < userIds.length; i++) {
      if (userIds[i].toString() != currentUserFId) {
        var usersDetails = await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(userIds[i].toString())
            .get();
        ChatUserModel chatUserModel = ChatUserModel.fromDocument(usersDetails);
        printLog("chatUserModel mUser name ==========> ${chatUserModel.name}");
        userList.add(chatUserModel);
        printLog("userList length ==========> ${userList.length}");
      }
    }
    printLog("userList Size ====> ${userList.length}");
    printLog("lastMessageList Size ====> ${lastMessageList.length}");

    /* Combine Users & LastMessage */
    List<ConversionModel> conversionList = [];
    for (var i = 0; i < userList.length; i++) {
      ConversionModel conversionModel = ConversionModel();
      conversionModel.chatUserModel = userList[i];
      conversionModel.lastMessage = lastMessageList[i];
      conversionList.add(conversionModel);
    }
    printLog("conversionList length ==========> ${conversionList.length}");

    return conversionList;
  }

  Widget shimmer() {
    return SingleChildScrollView(
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 0,
        mainAxisSpacing: 15,
        itemCount: 5,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomWidget.circular(
                width: 60,
                height: 60,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      width: 150,
                      height: 15,
                    ),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(
                      width: 150,
                      height: 12,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              CustomWidget.roundrectborder(
                width: 60,
                height: 12,
              ),
            ],
          );
        },
      ),
    );
  }
}

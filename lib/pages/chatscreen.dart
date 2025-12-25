import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/model/chatmessagemodel.dart';
import 'package:yourappname/model/chatusermodel.dart';
import 'package:yourappname/pages/fullphotopage.dart';
import 'package:yourappname/provider/chatprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Chatscreen extends StatefulWidget {
  final String? toUserName, toChatId, profileImg, bioData, number;

  const Chatscreen(
      {super.key,
      required this.toUserName,
      required this.toChatId,
      required this.profileImg,
      required this.bioData,
      this.number});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  SharedPre sharedPref = SharedPre();
  List<QueryDocumentSnapshot>? listMessage = [];
  int _limit = 20;
  int limitIncrement = 20;
  String groupChatId = "", currentUserId = "";

  File? imageFile;
  bool isLoading = false;
  String imageUrl = "";
  ChatUserModel? toUserData;
  ChatUserModel? currentUserData;

  late ChatProvider chatProvider;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Future getUserData() async {
    chatProvider.setLoading(true);
    currentUserId = await sharedPref.read("firebaseid");
    var userDetails = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(widget.toChatId)
        .get();
    toUserData = ChatUserModel.fromDocument(userDetails);
    printLog("toUserData ====> ${toUserData?.name}");

    /* Current User Data */
    printLog("currentUserId ====> $currentUserId");
    var cUserDetails = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(currentUserId)
        .get();
    currentUserData = ChatUserModel.fromDocument(cUserDetails);
    readLocal();
  }

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
    listScrollController.addListener(_scrollListener);
    super.initState();
  }

  makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(Uri.parse(launchUri.toString()))) {
      await launchUrl(Uri.parse(launchUri.toString()));
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  _scrollListener() async {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= (listMessage?.length ?? 0)) {
      setState(() {
        _limit += limitIncrement;
      });
    }
  }

  Future readLocal() async {
    printLog("currentUserId ===========> $currentUserId");
    printLog("toChatId ================> ${widget.toChatId}");
    if (currentUserId.compareTo(widget.toChatId ?? "") > 0) {
      groupChatId = '$currentUserId-${widget.toChatId}';
    } else {
      groupChatId = '${widget.toChatId}-$currentUserId';
    }
    printLog("groupChatId ==============> $groupChatId");

    chatProvider.addFieldsInFirestore(
      FirestoreConstants.pathMessageCollection,
      groupChatId,
      currentUserId,
      widget.toChatId ?? "",
    );

    await chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: widget.toChatId},
    ).whenComplete(() async {
      await chatProvider.setLoading(false);
    });

    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4,
        backgroundColor: colorPrimaryDark,
        titleSpacing: 0,
        leading: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onBackPress(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 25,
              color: white,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MyNetworkImage(
                  imageUrl: widget.profileImg ?? "",
                  fit: BoxFit.cover,
                  imgHeight: 40,
                  imgWidth: 40,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: MyText(
                color: white,
                text: widget.toUserName ?? "",
                fontsize: Dimens.text16Size,
                fontweight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () async {
              String number = widget.number.toString();
              if (number.isNotEmpty && number.toString() != "null") {
                await makeCall(number);
              } else {
                Utils.showToast("Invalid Number!!!");
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.call,
                  size: 20,
                  color: colorPrimary,
                )),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          onBackPress();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      Utils.showSnackbar(context, e.message ?? e.toString(), false);
    }
  }

  Future onSendMessage(String content, int type) async {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      await chatProvider.sendMessage(
          content,
          type,
          groupChatId,
          currentUserId,
          widget.toChatId ?? "",
          DateTime.now().millisecondsSinceEpoch.toString());
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      /*** Send Notification */
      ApiService().sendFCMPushNoti(
          currentUserData, currentUserId, widget.toChatId, toUserData, content);
      /* ***/
    } else {
      Utils.showSnackbar(context, "nothingtosend", true);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      if (!document[FirestoreConstants.read] &&
          document[FirestoreConstants.idTo] == currentUserId) {
        chatProvider.updateMessageRead(document, groupChatId);
        chatProvider.updateLastMessageStatus(groupChatId);
      }
      ChatMessageModel messageChat = ChatMessageModel.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    constraints: BoxConstraints(
                      minWidth: 0,
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20 : 10,
                      right: 10,
                      top: 3,
                    ),
                    padding: const EdgeInsets.all(7),
                    decoration:
                        Utils.setBGWithBorder(colorPrimary, white, 5, 0),
                    child: MyText(
                      color: white,
                      text: messageChat.content,
                      fontweight: FontWeight.normal,
                      // multilanguage: false,
                      fontsize: Dimens.text14Size,
                      fontstyle: FontStyle.normal,
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    // Image
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => FullPhotoPage(
                            //       url: messageChat.content,
                            //     ),
                            //   ),
                            // );
                          },
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0))),
                          child: Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: black,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    // Sticker
                    : Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: Image.asset(
                          'images/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
          ],
        );
      } else {
        // Left (Others message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            widget.profileImg ?? "",
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: colorPrimary,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35,
                                color: gray,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          constraints: BoxConstraints(
                            minWidth: 0,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          margin: const EdgeInsets.only(left: 10, top: 3),
                          padding: const EdgeInsets.all(7),
                          decoration: Utils.setBGWithBorder(
                              colorPrimary, transparent, 5, 0),
                          child: MyText(
                            color: white,
                            text: messageChat.content,
                            fontweight: FontWeight.normal,
                            // multilanguage: false,
                            fontsize: Dimens.text14Size,
                            fontstyle: FontStyle.normal,
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                          url: messageChat.content),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding:
                                        WidgetStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: black,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: colorPrimary,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: MyImage(
                                        imagePath: "",
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      margin:
                          const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(messageChat.timestamp))),
                        style: const TextStyle(
                            color: gray,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage?[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage?[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() async {
    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: null},
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              color: white.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: colorPrimary,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      height: 53,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 53,
              decoration: Utils.setBGWithBorder(white, colorPrimaryDark, 5, 1),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Row(
                children: <Widget>[
                  // Edit text
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          if (textEditingController.text
                              .toString()
                              .isNotEmpty) {
                            onSendMessage(
                                textEditingController.text, TypeMessage.text);
                          }
                        },
                        style: GoogleFonts.inter(
                          color: colorPrimaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                        ),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: "Type here...",
                          filled: true,
                          fillColor: transparent,
                          hintStyle: GoogleFonts.inter(
                            color: black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        focusNode: focusNode,
                        autofocus: false,
                      ),
                    ),
                  ),
                  // Button send image
                  InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(5),
                      child: MyImage(
                        width: 23,
                        height: 23,
                        imagePath: "ic_pin.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button send message
          InkWell(
            onTap: () {
              onSendMessage(textEditingController.text, TypeMessage.text);
            },
            child: Transform.rotate(
              angle: 5.5,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.send,
                    size: 23,
                    color: colorPrimary,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Expanded(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.loading) {
            return shimmer();
          } else {
            return SizedBox(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(groupChatId, _limit),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: MyText(
                        color: colorAccent,
                        text: "somethingwentwrong",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                        fontsize: Dimens.text15Size,
                        fontweight: FontWeight.normal,
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    listMessage = snapshot.data?.docs;
                    if ((listMessage?.length ?? 0) > 0) {
                      return Container(
                        constraints: const BoxConstraints(minHeight: 0),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: listScrollController,
                          itemCount: snapshot.data?.docs.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Container(
                              constraints: const BoxConstraints(minHeight: 0),
                              child:
                                  buildItem(index, snapshot.data?.docs[index]),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: MyText(
                          text: "nomessage",
                          color: white,
                          multilanguage: true,
                          fontstyle: FontStyle.normal,
                          textalign: TextAlign.center,
                          fontsize: Dimens.text16Size,
                          fontweight: FontWeight.w500,
                        ),
                      );
                    }
                  } else {
                    // Loading
                    return Utils.pageLoader();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget shimmer() {
    return SingleChildScrollView(
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        crossAxisSpacing: 0,
        mainAxisSpacing: 15,
        itemCount: 20,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CustomWidget.roundrectborder(
                  width: 150,
                  height: 20,
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: CustomWidget.roundrectborder(
                  width: 150,
                  height: 20,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

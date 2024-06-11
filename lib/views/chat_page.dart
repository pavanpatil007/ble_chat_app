import 'package:ble_chat_app_bb1/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/ble_controller.dart';

class ChatPage extends StatelessWidget {
  final BLEController bleController = Get.find();

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustColors.secondaryColor,
        title: Text(
          "Chat",style: GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 18),),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth_disabled),
            onPressed: () {
              bleController.disconnectFromDevice();
              Get.back();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: bleController.messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(bleController.messages[index]),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                      border: OutlineInputBorder(borderSide: BorderSide(color: CustColors.primaryColor)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,color: CustColors.primaryColor,),
                  onPressed: () {
                    bleController.sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:ble_chat_app_bb1/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/ble_controller.dart';
import 'chat_page.dart';

class ConnectPage extends StatelessWidget {
  final BLEController bleController = Get.put(BLEController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: CustColors.secondaryColor,
          title: Text("Connect to Device",style: GoogleFonts.poppins(fontWeight: FontWeight.w500,fontSize: 18),)),
      body: Obx(() {
        if (bleController.isScanning.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: bleController.devices.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(bleController.devices[index].platformName),
                    subtitle: Text(bleController.devices[index].id.toString()),
                    onTap: () {
                      bleController.connectToDevice(bleController.devices[index]);
                      Get.to(() => ChatPage());
                    },
                  ),
                );
              },
            ),
          );
        }
      }),
    );
  }
}

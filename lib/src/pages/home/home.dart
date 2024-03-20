import 'package:flutter/cupertino.dart';
import 'package:i_chat/src/pages/home/provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(),
      child: Column(
        children: [
          Selector<HomeProvider, bool>(
            selector: (_, ctrl) => ctrl.isBrowser,
            builder: (_, isBrowser, child) {
              return CupertinoSwitch(
                  value: isBrowser, onChanged: (isActive) {});
            },
          ),
          Expanded(
            child: Consumer<HomeProvider>(builder: (_, ctrl, child) {
              return ListView.builder(
                itemCount: ctrl.devices.length,
                itemBuilder: (_, index) {
                  final device = ctrl.devices[index];
                  return Text(device.info.displayName);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

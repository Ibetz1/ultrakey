import 'package:flutter/material.dart';
import 'package:ultrakey_ui/containers/config_container.dart';
import 'package:ultrakey_ui/tabs/ui_config_control.dart';
import 'package:ultrakey_ui/tabs/ui_script_control.dart';
import 'package:ultrakey_ui/widgets/config_state.dart';
import 'package:ultrakey_ui/widgets/nav_disable.dart';

class UltrakeyMain extends StatelessWidget {
  const UltrakeyMain({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NoNavKeysWrapper(
        child: ConfigStateContainer(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                StateControls(),
                const TabBar(
                  tabs: [
                    Tab(text: 'Bindings'),
                    Tab(text: 'Scripts'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(child: UiConfigControls()),
                      SingleChildScrollView(child: UiScriptControls()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
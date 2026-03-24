import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import '../screen_app_bottom_navigator/my_bottom_navigator_screen.dart';
import '../app_widgets/my_animated_card.dart';
import 'settings_bloc.dart';

class SettingsScreen extends StatelessWidget {


  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(LoadSettingsEvent()),
      child: MyDefBgDecoration(
        child: MyScreenBoxDecorationWidget(
          child: const SettingsScreenWidget(),
        ),
      ),
    );
  }
}

class SettingsScreenWidget extends StatelessWidget {
  const SettingsScreenWidget({super.key});
  // --- ЦВЕТА ФОНА И ГРАДИЕНТОВ ---
  /// Начальный цвет градиента карточки
  static const Color bgGradientStart = Color(0xFF3B4152);
  /// Конечный цвет градиента карточки
  static const Color bgGradientEnd = Color(0xFF1A1D25);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: ToolThemeData.mainGreenColor,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgGradientStart,
              bgGradientEnd
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black12,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 4),
              child: MyAnimatedCard(
                intensity: 0.05,
                child: GestureDetector(
                  onTap: () => ToolNavigator.pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Настройки',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 0.5,
                shadows: ToolThemeData.defTextShadow,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildSectionHeader('ОСНОВНЫЕ'),
                  _buildSettingsCard(children: [
                    _buildSettingsTile(
                      icon: Icons.palette_rounded,
                      title: 'Тема оформления',
                      subtitle: 'Тёмный неон',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Уведомления',
                      subtitle: 'Все включены',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Язык приложения',
                      subtitle: 'Русский',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),
                  const Gap(25),
                  _buildSectionHeader('ДАННЫЕ'),
                  _buildSettingsCard(children: [
                    _buildSettingsTile(
                      icon: Icons.cloud_sync_rounded,
                      title: 'Синхронизация',
                      subtitle: 'Последняя: сегодня 12:40',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.storage_rounded,
                      title: 'Хранилище данных',
                      subtitle: 'Экспорт / Импорт',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),
                  const Gap(25),
                  _buildSectionHeader('ПРИЛОЖЕНИЕ'),
                  _buildSettingsCard(children: [
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'О приложении',
                      subtitle: 'Версия 1.2.4 (Build 42)',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.contact_support_rounded,
                      title: 'Поддержка',
                      subtitle: 'Связаться с разработчиком',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),
                  const Gap(60),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: ToolThemeData.highlightColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: ToolThemeData.highlightColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              shadows: ToolThemeData.defTextShadow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return MyAnimatedCard(
      intensity: 0.015,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: ToolThemeData.highlightColor.withValues(alpha: 0.1),
          splashColor: ToolThemeData.highlightColor.withValues(alpha: 0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ToolThemeData.itemBorderColor.withValues(alpha: 0.3),
                        ToolThemeData.highlightColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ToolThemeData.highlightColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ToolThemeData.highlightColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 14,
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

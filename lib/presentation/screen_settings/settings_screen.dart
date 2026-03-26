
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import '../screen_app_bottom_navigator/my_bottom_navigator_screen.dart';
import '../app_widgets/my_animated_card.dart';
import 'settings_bloc.dart';

class SettingsScreen extends StatelessWidget {


  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider(
      create: (_) => SettingsBloc()..add(LoadSettingsEvent()),
      child: const SettingsScreenWidget(),
    );
    if (GetPlatform.isDesktop) {
      return MyDefBgDecoration(
        child: MyScreenBoxDecorationWidget(child: content),
      );
    }
    return MyDefBgDecoration(child: content);
  }
}

class SettingsScreenWidget extends StatelessWidget {
  const SettingsScreenWidget({super.key});
  // --- ЦВЕТА ФОНА И ГРАДИЕНТОВ ---
  /// Начальный цвет градиента карточки
  static const Color bgGradientStart = Color(0xFF282C3A);
  /// Конечный цвет градиента карточки
  static const Color bgGradientEnd = Color(0xFF16181F);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: ToolThemeData.mainGreenColor,
        useMaterial3: true,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
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
          body: SafeArea(
            child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.black12,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    centerTitle: false,
                    leadingWidth: 64,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                      child: MyAnimatedCard(
                        intensity: 0.05,
                        child: GestureDetector(
                          onTap: () => ToolNavigator.pop(),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: const Text(
                      'Настройки',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader('Основные', Icons.tune_rounded),
                        _buildSettingsCard(children: [
                          _buildSettingsTile(
                            icon: Icons.palette_outlined,
                            title: 'Тема оформления',
                            subtitle: state.themeName,
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Уведомления',
                            subtitle: 'Push-уведомления и напоминания',
                            trailing: Switch(
                              value: state.isNotificationsEnabled,
                              onChanged: (val) {
                                context.read<SettingsBloc>().add(ToggleNotificationsEvent(val));
                              },
                              activeThumbColor: ToolThemeData.highlightColor,
                            ),
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Язык',
                            subtitle: state.language,
                            onTap: () {},
                          ),
                        ]),
                        const Gap(24),
                        _buildSectionHeader('ДАННЫЕ', Icons.data_usage_rounded),
                        _buildSettingsCard(children: [
                          _buildSettingsTile(
                            icon: Icons.cloud_outlined,
                            title: 'Синхронизация',
                            subtitle: state.lastSyncDate,
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.folder_open_rounded,
                            title: 'Резервное копирование',
                            subtitle: 'Экспорт локальных данных',
                            onTap: () {},
                          ),
                        ]),
                        const Gap(24),
                        _buildSectionHeader('О ПРИЛОЖЕНИИ', Icons.info_outline_rounded),
                        _buildSettingsCard(children: [
                          _buildSettingsTile(
                            icon: Icons.code_rounded,
                            title: 'Версия приложения',
                            subtitle: state.appVersion,
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Служба поддержки',
                            subtitle: 'Написать разработчику',
                            onTap: () {},
                          ),
                        ]),
                        const Gap(80),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: ToolThemeData.highlightColor,
          ),
          const Gap(12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: ToolThemeData.highlightColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04), // Surface container in M3
        borderRadius: BorderRadius.circular(24), // Material 3 uses large borders
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: trailing != null && trailing is Switch ? null : onTap,
        highlightColor: ToolThemeData.highlightColor.withValues(alpha: 0.05),
        splashColor: ToolThemeData.highlightColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
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
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum EnumTodoCategory {
  active,
  daily,
  social,
  history_social,
  history,
  complete_daily;

  static EnumTodoCategory getEnumTodoCategory(String name) {
    switch (name) {
      case 'active':
        return EnumTodoCategory.active;
      case 'daily':
        return EnumTodoCategory.daily;
      case 'social':
        return EnumTodoCategory.social;
      case 'history_social':
        return EnumTodoCategory.history_social;
      case 'history':
        return EnumTodoCategory.history;
      case 'complete_daily':
        return EnumTodoCategory.complete_daily;
      default:
        throw ArgumentError('Invalid EnumTodoCategory name: $name');
    }
  }
}

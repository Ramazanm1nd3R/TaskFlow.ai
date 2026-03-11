import 'package:taskflow_ai/domain/entities/ai_insights.dart';
import 'package:taskflow_ai/domain/entities/ai_predictions.dart';
import 'package:taskflow_ai/domain/entities/analytics_data.dart';
import 'package:taskflow_ai/domain/repositories/ai_repository.dart';

class AIRepositoryImpl implements AIRepository {
  const AIRepositoryImpl();

  @override
  Future<AIInsights> generateInsights(AnalyticsData analytics) async {
    final topCategory = analytics.topCategories.isEmpty
        ? 'general'
        : analytics.topCategories.first.name;
    return AIInsights(
      productivity:
          'Пик активности около ${analytics.peakProductivityHour}:00. Ставь важные задачи в этот слот.',
      bestDay:
          'Самый сильный день сейчас ${analytics.peakProductivityDay}. Там видно лучший темп по задачам.',
      completionTime:
          analytics.averageCompletionDays == 0
              ? 'Пока мало завершённых задач для оценки цикла.'
              : 'Средний цикл закрытия ${analytics.averageCompletionDays.toStringAsFixed(1)} дня.',
      topCategory:
          'Категория $topCategory ведёт по объёму. Её стоит держать под отдельным фокусом.',
    );
  }

  @override
  Future<AIPredictions> generatePredictions(AnalyticsData analytics) async {
    final nextWeekTasks = ((analytics.totalTasks / 7) * 1.15).round().clamp(1, 99);
    final risk = analytics.activeTasks > analytics.completedTasks
        ? 'Нагрузка повышена: активных задач больше, чем завершённых.'
        : 'Риск перегруза умеренный: баланс активных и завершённых задач пока нормальный.';
    final dailyTarget = (nextWeekTasks / 7).ceil();
    final speed = analytics.completionRate >= 70
        ? 'Скорость выполнения высокая. Можно безопасно брать чуть более амбициозный спринт.'
        : analytics.completionRate >= 40
            ? 'Темп устойчивый, но рост даст более жёсткая приоритизация.'
            : 'Темп низкий. Лучше уменьшить параллельность и дробить задачи.';

    return AIPredictions(
      nextWeekForecast: 'При текущем ритме ожидается около $nextWeekTasks задач на следующей неделе.',
      burnoutRisk: risk,
      dailyRecommendation: 'Оптимальная нагрузка сейчас около $dailyTarget задач в день.',
      completionSpeed: speed,
    );
  }
}

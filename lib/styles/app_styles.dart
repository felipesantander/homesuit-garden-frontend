// Sistema de Material Design para la aplicación
//
// Este módulo exporta todos los estilos globales que pueden ser
// reutilizados en toda la aplicación y en otros proyectos.
//
// Uso:
// ```dart
// import 'package:garden_homesuit/styles/app_styles.dart';
//
// // Usar estilos de texto
// Text('Hola', style: AppTextStyles.title);
//
// // Usar estilos de card
// Container(decoration: AppCardStyles.glassDecoration());
//
// // Usar spacing
// AppSpacing.verticalLG,
// ```

// Exportar todos los estilos
export 'text_styles.dart';
export 'card_styles.dart';
export 'button_styles.dart';
export 'spacing.dart';
export 'input_styles.dart';

// También exportar los colores para conveniencia
export 'package:garden_homesuit/config/app_colors.dart';

class AppComponents {
  static const List<String> viewComponents = [
    'dashboard',
    'dashboard_filter_by_business',
    'dashboard_filter_by_garden',
    'dashboard_add_machine',
    'dashboard_see_machine',
    'dashboard_config_machine',
    'dashboard_delete_machine',
    'machine_candidates',
    'channels',
    'channels_add',
    'channels_see',
    'channels_config',
    'channels_delete',
    'gardens',
    'gardens_add',
    'gardens_see',
    'gardens_config',
    'gardens_delete',
    'users',
    'users_add',
    'users_see',
    'users_config',
    'users_delete',
    'businesses',
    'businesses_add',
    'businesses_see',
    'businesses_config',
    'businesses_delete',
    'alerts',
    'alerts_add',
    'alerts_see',
    'alerts_config',
    'alerts_delete',
    'roles_permissions',
    'roles_permissions_add',
    'roles_permissions_see',
    'roles_permissions_config',
    'roles_permissions_delete',
  ];

  static String getDisplayName(String component) {
    switch (component) {
      case 'dashboard':
        return 'Dashboard';
      case 'dashboard_filter_by_business':
        return 'Dashboard (Filtrado por Negocio)';
      case 'dashboard_filter_by_garden':
        return 'Dashboard (Filtrado por Jardín)';
      case 'dashboard_add_machine':
        return 'Dashboard (Agregar Sensor)';
      case 'dashboard_see_machine':
        return 'Dashboard (Ver Sensor)';
      case 'dashboard_config_machine':
        return 'Dashboard (Configurar Sensor)';
      case 'dashboard_delete_machine':
        return 'Dashboard (Eliminar Sensor)';
      case 'machine_candidates':
        return 'Nuevos Sensores';
      case 'channels':
        return 'Canales';
      case 'channels_add':
        return 'Canales (Agregar)';
      case 'channels_see':
        return 'Canales (Ver)';
      case 'channels_config':
        return 'Canales (Configurar)';
      case 'channels_delete':
        return 'Canales (Eliminar)';
      case 'gardens':
        return 'Jardines';
      case 'gardens_add':
        return 'Jardines (Agregar)';
      case 'gardens_see':
        return 'Jardines (Ver)';
      case 'gardens_config':
        return 'Jardines (Configurar)';
      case 'gardens_delete':
        return 'Jardines (Eliminar)';
      case 'users':
        return 'Usuarios';
      case 'users_add':
        return 'Usuarios (Agregar)';
      case 'users_see':
        return 'Usuarios (Ver)';
      case 'users_config':
        return 'Usuarios (Configurar)';
      case 'users_delete':
        return 'Usuarios (Eliminar)';
      case 'businesses':
        return 'Negocios';
      case 'businesses_add':
        return 'Negocios (Agregar)';
      case 'businesses_see':
        return 'Negocios (Ver)';
      case 'businesses_config':
        return 'Negocios (Configurar)';
      case 'businesses_delete':
        return 'Negocios (Eliminar)';
      case 'alerts':
        return 'Alertas';
      case 'alerts_add':
        return 'Alertas (Agregar)';
      case 'alerts_see':
        return 'Alertas (Ver)';
      case 'alerts_config':
        return 'Alertas (Configurar)';
      case 'alerts_delete':
        return 'Alertas (Eliminar)';
      case 'roles_permissions':
        return 'Roles y Permisos';
      case 'roles_permissions_add':
        return 'Roles y Permisos (Agregar)';
      case 'roles_permissions_see':
        return 'Roles y Permisos (Ver)';
      case 'roles_permissions_config':
        return 'Roles y Permisos (Configurar)';
      case 'roles_permissions_delete':
        return 'Roles y Permisos (Eliminar)';
      default:
        return component;
    }
  }
}

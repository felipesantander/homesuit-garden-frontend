import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../views/login/login.view.dart' deferred as login show LoginView;
import '../views/web/dashboard/dashboard.view.dart'
    deferred as dashboard
    show DashboardView;
import '../views/mobile/dashboard/dashboard_mobile.view.dart'
    deferred as dashboard_mobile
    show DashboardMobileView;
import '../views/mobile/machine_candidates/machine_candidates_mobile.view.dart'
    deferred as machine_candidates_mobile
    show MachineCandidatesMobileView;
import '../views/mobile/garden/gardens_mobile.view.dart'
    deferred as gardens_mobile
    show GardensMobileView;
import '../views/mobile/channel/channels_mobile.view.dart'
    deferred as channels_mobile
    show ChannelsMobileView;
import '../views/mobile/business/businesses_mobile.view.dart'
    deferred as businesses_mobile
    show BusinessesMobileView;
import '../views/mobile/roles_permissions/roles_permissions_mobile.view.dart'
    deferred as roles_permissions_mobile
    show RolesPermissionsMobileView;
import '../views/web/dashboard/machine_details/machine_details.view.dart'
    deferred as machine_details
    show MachineDetailsView;
import '../views/web/machine_candidates/machine_candidates.view.dart'
    deferred as machine_candidates
    show MachineCandidatesView;
import '../views/web/business/businesses.view.dart'
    deferred as businesses
    show BusinessesView;
import '../views/web/garden/gardens.view.dart'
    deferred as gardens
    show GardensView;
import '../views/web/channel/channels.view.dart'
    deferred as channels
    show ChannelsView;
import '../views/web/machine_candidates/register_machine.view.dart'
    deferred as register_machine
    show RegisterMachineView;
import '../views/web/roles_permissions/roles_permissions.view.dart'
    deferred as roles_permissions
    show RolesPermissionsView;
import '../views/web/roles_permissions/permission_form/permission_form.view.dart'
    deferred as permission_form
    show PermissionFormView;
import '../views/web/dashboard/add_sensor/add_sensor.view.dart'
    deferred as add_sensor
    show AddSensorView;
import '../views/web/alerts/alerts_view.dart'
    deferred as alerts
    show AlertsView;
import '../views/web/alerts/add_alert.view.dart'
    deferred as add_alert
    show AddAlertView;
import '../providers/auth.provider.dart';
import '../utils/deferred_widget.dart';

import '../views/mobile/layouts/mobile_layout.dart';
import '../views/web/layouts/web_layout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => DeferredWidget(
          loader: login.loadLibrary,
          builder: () => login.LoginView(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => ResponsiveMainLayout(child: child),

        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ResponsiveDashboardWrapper(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const ResponsiveDashboardWrapper(),
          ),
          GoRoute(
            path: '/dashboard/machine/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DeferredWidget(
                loader: machine_details.loadLibrary,
                builder: () =>
                    machine_details.MachineDetailsView(machineId: id),
              );
            },
          ),
          GoRoute(
            path: '/machine-candidates',
            builder: (context, state) =>
                const ResponsiveMachineCandidatesWrapper(),
          ),

          GoRoute(
            path: '/businesses',
            builder: (context, state) => const ResponsiveBusinessesWrapper(),
          ),

          GoRoute(
            path: '/gardens',
            builder: (context, state) => const ResponsiveGardensWrapper(),
          ),
          GoRoute(
            path: '/channels',
            builder: (context, state) => const ResponsiveChannelsWrapper(),
          ),

          GoRoute(
            path: '/register-machine/:serial',
            builder: (context, state) {
              final serial = state.pathParameters['serial']!;
              return DeferredWidget(
                loader: register_machine.loadLibrary,
                builder: () =>
                    register_machine.RegisterMachineView(serial: serial),
              );
            },
          ),
          GoRoute(
            path: '/roles-permissions',
            builder: (context, state) =>
                const ResponsiveRolesPermissionsWrapper(),
          ),

          GoRoute(
            path: '/roles-permissions/permission/new',
            builder: (context, state) => DeferredWidget(
              loader: permission_form.loadLibrary,
              builder: () => permission_form.PermissionFormView(),
            ),
          ),
          GoRoute(
            path: '/roles-permissions/permission/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return DeferredWidget(
                loader: permission_form.loadLibrary,
                builder: () =>
                    permission_form.PermissionFormView(permissionId: id),
              );
            },
          ),
          GoRoute(
            path: '/dashboard/add-sensor',
            builder: (context, state) => DeferredWidget(
              loader: add_sensor.loadLibrary,
              builder: () => add_sensor.AddSensorView(),
            ),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => DeferredWidget(
              loader: alerts.loadLibrary,
              builder: () => alerts.AlertsView(),
            ),
          ),
          GoRoute(
            path: '/alerts/new',
            builder: (context, state) => DeferredWidget(
              loader: add_alert.loadLibrary,
              builder: () => add_alert.AddAlertView(),
            ),
          ),
          GoRoute(
            path: '/alerts/edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return DeferredWidget(
                loader: add_alert.loadLibrary,
                builder: () => add_alert.AddAlertView(alertId: id),
              );
            },
          ),
        ],
      ),
    ],
  );
});

class ResponsiveMainLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return MobileLayout(child: child);
    }

    return WebLayout(child: child);
  }
}

class ResponsiveMachineCandidatesWrapper extends ConsumerWidget {
  const ResponsiveMachineCandidatesWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: machine_candidates_mobile.loadLibrary,
        builder: () => machine_candidates_mobile.MachineCandidatesMobileView(),
      );
    }

    return DeferredWidget(
      loader: machine_candidates.loadLibrary,
      builder: () => machine_candidates.MachineCandidatesView(),
    );
  }
}

class ResponsiveBusinessesWrapper extends ConsumerWidget {
  const ResponsiveBusinessesWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: businesses_mobile.loadLibrary,
        builder: () => businesses_mobile.BusinessesMobileView(),
      );
    }

    return DeferredWidget(
      loader: businesses.loadLibrary,
      builder: () => businesses.BusinessesView(),
    );
  }
}

class ResponsiveRolesPermissionsWrapper extends ConsumerWidget {
  const ResponsiveRolesPermissionsWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: roles_permissions_mobile.loadLibrary,
        builder: () => roles_permissions_mobile.RolesPermissionsMobileView(),
      );
    }

    return DeferredWidget(
      loader: roles_permissions.loadLibrary,
      builder: () => roles_permissions.RolesPermissionsView(),
    );
  }
}

class ResponsiveGardensWrapper extends ConsumerWidget {
  const ResponsiveGardensWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: gardens_mobile.loadLibrary,
        builder: () => gardens_mobile.GardensMobileView(),
      );
    }

    return DeferredWidget(
      loader: gardens.loadLibrary,
      builder: () => gardens.GardensView(),
    );
  }
}

class ResponsiveChannelsWrapper extends ConsumerWidget {
  const ResponsiveChannelsWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: channels_mobile.loadLibrary,
        builder: () => channels_mobile.ChannelsMobileView(),
      );
    }

    return DeferredWidget(
      loader: channels.loadLibrary,
      builder: () => channels.ChannelsView(),
    );
  }
}

class ResponsiveDashboardWrapper extends ConsumerWidget {
  const ResponsiveDashboardWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile || isTablet) {
      return DeferredWidget(
        loader: dashboard_mobile.loadLibrary,
        builder: () => dashboard_mobile.DashboardMobileView(),
      );
    }

    return DeferredWidget(
      loader: dashboard.loadLibrary,
      builder: () => dashboard.DashboardView(),
    );
  }
}

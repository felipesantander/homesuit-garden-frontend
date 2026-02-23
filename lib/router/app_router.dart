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
import '../views/dashboard/machine_details/machine_details.view.dart'
    deferred as machine_details
    show MachineDetailsView;
import '../views/machine_candidates/machine_candidates.view.dart'
    deferred as machine_candidates
    show MachineCandidatesView;
import '../views/business/businesses.view.dart'
    deferred as businesses
    show BusinessesView;
import '../views/garden/gardens.view.dart' deferred as gardens show GardensView;
import '../views/channel/channels.view.dart'
    deferred as channels
    show ChannelsView;
import '../views/machine_candidates/register_machine.view.dart'
    deferred as register_machine
    show RegisterMachineView;
import '../views/roles_permissions/roles_permissions.view.dart'
    deferred as roles_permissions
    show RolesPermissionsView;
import '../views/roles_permissions/permission_form/permission_form.view.dart'
    deferred as permission_form
    show PermissionFormView;
import '../providers/auth.provider.dart';
import '../utils/deferred_widget.dart';

import '../views/layouts/main_layout.dart';

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
        builder: (context, state, child) => MainLayout(child: child),
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
            builder: (context, state) => DeferredWidget(
              loader: machine_candidates.loadLibrary,
              builder: () => machine_candidates.MachineCandidatesView(),
            ),
          ),
          GoRoute(
            path: '/businesses',
            builder: (context, state) => DeferredWidget(
              loader: businesses.loadLibrary,
              builder: () => businesses.BusinessesView(),
            ),
          ),
          GoRoute(
            path: '/gardens',
            builder: (context, state) => DeferredWidget(
              loader: gardens.loadLibrary,
              builder: () => gardens.GardensView(),
            ),
          ),
          GoRoute(
            path: '/channels',
            builder: (context, state) => DeferredWidget(
              loader: channels.loadLibrary,
              builder: () => channels.ChannelsView(),
            ),
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
            builder: (context, state) => DeferredWidget(
              loader: roles_permissions.loadLibrary,
              builder: () => roles_permissions.RolesPermissionsView(),
            ),
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
        ],
      ),
    ],
  );
});

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

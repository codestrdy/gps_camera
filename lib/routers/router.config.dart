import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_camera/pages/home_page.dart';
import 'package:gps_camera/pages/preview_page.dart';

part 'router.config.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData with _$HomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<PreviewRoute>(path: '/preview')
@immutable
class PreviewRoute extends GoRouteData with _$PreviewRoute {
  final File $extra;

  const PreviewRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) => PreviewPage(image: $extra);
}

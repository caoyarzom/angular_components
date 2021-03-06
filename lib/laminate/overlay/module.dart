// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/laminate/overlay/constants.dart';
import 'package:angular_components/src/laminate/overlay/overlay_service.dart';
import 'package:angular_components/src/laminate/overlay/render/overlay_dom_render_service.dart';
import 'package:angular_components/src/laminate/overlay/render/overlay_style_config.dart';
import 'package:angular_components/laminate/overlay/zindexer.dart';
import 'package:angular_components/laminate/ruler/dom_ruler.dart';
import 'package:angular_components/utils/angular/imperative_view/imperative_view.dart';
import 'package:angular_components/utils/angular/managed_zone/angular_2.dart';
import 'package:angular_components/utils/browser/dom_service/angular_2.dart';
import 'package:angular_components/utils/browser/window/module.dart';

export 'package:angular_components/src/laminate/overlay/render/overlay_dom_render_service.dart'
    show
        overlayContainerName,
        overlayContainerParent,
        overlayContainerToken,
        overlayRepositionLoop,
        overlaySyncDom;

/// Either finds, or creates an "acx-overlay-container" div at the end of body.
@Injectable()
HtmlElement getDefaultContainer(
    @Inject(overlayContainerName) String name,
    @Inject(overlayContainerParent) HtmlElement parent,
    @Optional() @SkipSelf() @Inject(overlayContainerToken) container) {
  if (container != null) return container;

  var element = parent.querySelector('#$overlayDefaultContainerId');
  if (element == null) {
    // Add a hidden focusable element before overlay container to prevent screen
    // reader from picking up content from a random element when users shift tab
    // out of the first visible overlay.
    parent.append(new DivElement()
      ..tabIndex = 0
      ..classes.add(overlayFocusablePlaceholderClassName));

    element = new DivElement()
      ..id = overlayDefaultContainerId
      ..classes.add(overlayContainerClassName);
    parent.append(element);

    // Add a hidden focusable element after overlay container to ensure there's
    // a focusable element when users tab out of the last visible overlay.
    parent.append(new DivElement()
      ..tabIndex = 0
      ..classes.add(overlayFocusablePlaceholderClassName));
  }
  element.attributes[overlayContainerNameAttribute] = name;
  return element;
}

@Injectable()
String getDefaultContainerName(
    @Optional() @SkipSelf() @Inject(overlayContainerName) containerName) {
  return containerName ?? 'default';
}

/// Returns an overlay container with debugging aid enabled.
@Injectable()
HtmlElement getDebugContainer(@Inject(overlayContainerName) String name,
    @Inject(overlayContainerParent) HtmlElement parent) {
  var element = getDefaultContainer(name, parent, null);
  element.classes.add('debug');
  return element;
}

@Injectable()
HtmlElement getOverlayContainerParent(Document document,
    @Optional() @SkipSelf() @Inject(overlayContainerParent) containerParent) {
  return containerParent ?? document.querySelector('body');
}

/// DI module for Overlay and its dependencies.
const overlayModule = const Module(
  include: const [
    windowModule,
  ],
  provide: _overlayProviders,
);

const _overlayProviders = const <Provider>[
  const ClassProvider(AcxImperativeViewUtils),
  const ClassProvider(DomRuler),
  domServiceBinding,
  const ClassProvider(ManagedZone, useClass: Angular2ManagedZone),
  const FactoryProvider.forToken(overlayContainerName, getDefaultContainerName),
  const FactoryProvider.forToken(overlayContainerToken, getDefaultContainer),
  const FactoryProvider.forToken(
      overlayContainerParent, getOverlayContainerParent),
  // Applications may experimentally make this true to increase performance.
  const ValueProvider.forToken(overlaySyncDom, true),
  const ValueProvider.forToken(overlayRepositionLoop, true),
  const ClassProvider(OverlayDomRenderService),
  const ClassProvider(OverlayStyleConfig),
  const ClassProvider(OverlayService),
  const ClassProvider(ZIndexer),
];

/// DI bindings for Overlay and its dependencies.
const overlayBindings = const [
  windowBindings,
  _overlayProviders,
];

/// Similar to [overlayModule], but enables easy debugging of the overlays.
const overlayDebugModule = const Module(
  include: const [
    overlayModule,
  ],
  provide: _overlayDebugProviders,
);

const _overlayDebugProviders = const <Provider>[
  const FactoryProvider.forToken(overlayContainerToken, getDebugContainer),
];

/// Similar to [overlayBindings], but enables easy debugging of the overlays.
const overlayDebugBindings = const [
  overlayBindings,
  _overlayDebugProviders,
];

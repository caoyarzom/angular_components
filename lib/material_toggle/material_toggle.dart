// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:meta/meta.dart';
import 'package:angular_components/interfaces/has_disabled.dart';
import 'package:angular_components/utils/browser/events/events.dart';

/// `material-toggle` is a button that can be either ON or OFF.
/// User can tap the toggle button to change the state.
/// Usually you use toggle buttons when you have a single ON/OFF option.
/// If you have multiple options from a set to be checked/unchecked, use
/// `material-checkbox` instead.
///
/// __Example usage:__
///
///     <material-toggle [disabled]="false" [(checked)]="true" label="Click me">
///     </material-toggle>
@Component(
  selector: 'material-toggle',
  styleUrls: const ['material_toggle.scss.css'],
  templateUrl: 'material_toggle.html',
  directives: const [NgIf],
  providers: const [
    const Provider(HasDisabled, useExisting: MaterialToggleComponent),
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class MaterialToggleComponent implements AfterViewInit, HasDisabled {
  @HostBinding('class')
  static const hostClass = 'themeable';

  @ViewChild('toggle')
  HtmlElement toggleElement;

  @override
  void ngAfterViewInit() {
    _syncAriaPressed();
  }

  /// Enables/disables the toggle button.
  ///
  /// `true` is disabled and `false` is enabled.
  @Input()
  bool disabled = false;

  /// Current state of the toggle button.
  ///
  /// `true` is ON and `false` is OFF.
  @Input()
  set checked(bool value) {
    _checked = value;
    _syncAriaPressed();
  }

  bool get checked => _checked;
  bool _checked = false;

  final _controller = new StreamController<bool>.broadcast();

  /// Event that is fired when the toggle is checked.
  @Output('checkedChange')
  Stream<bool> get onChecked => _controller.stream;

  /// Label for the toggle button.
  @Input()
  String label;

  /// ARIA label to use for the toggle button.
  @Input()
  set ariaLabel(String value) {
    _ariaLabel = value;
  }

  String get ariaLabel => _ariaLabel ?? label;
  String _ariaLabel;

  /// Sets the depth of the shadow
  int shadow_z = 1;

  bool _hasFocus = false;
  bool get hasFocus => _hasFocus;
  set hasFocus(bool value) {
    _hasFocus = value;
    _updateShadowZ();
  }

  bool _isHovered = false;
  bool get isHovered => _isHovered;
  set isHovered(bool value) {
    _isHovered = value;
    _updateShadowZ();
  }

  bool get hasLabel => label != null && label.isNotEmpty;

  void _updateShadowZ() {
    shadow_z = isHovered ? 3 : hasFocus ? 2 : 1;
  }

  @visibleForTesting
  void toggleChecked() {
    if (!disabled) {
      checked = !checked;
      _controller.add(checked);
    }
  }

  @HostListener('click')
  void handleClick(MouseEvent mouseEvent) {
    toggleChecked();
    mouseEvent.preventDefault();
    mouseEvent.stopPropagation();
  }

  @HostListener('keypress')
  void handleKeyPress(KeyboardEvent keyEvent) {
    int keyCode = keyEvent.keyCode;
    if (keyCode == KeyCode.ENTER || isSpaceKey(keyEvent)) {
      toggleChecked();
      keyEvent.preventDefault();
      keyEvent.stopPropagation();
    }
  }

  void _syncAriaPressed() {
    if (toggleElement == null) return;
    toggleElement.attributes['aria-pressed'] = '$checked';
  }
}

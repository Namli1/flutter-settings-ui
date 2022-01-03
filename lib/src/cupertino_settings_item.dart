import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/settings_tile_theme.dart';

import 'colors.dart';
import 'defines.dart';

enum SettingsItemType {
  toggle,
  modal,
}

typedef PressOperationCallback = void Function();

class CupertinoSettingsItem extends StatefulWidget {
  const CupertinoSettingsItem({
    Key? key,
    required this.type,
    this.label,
    this.labelWidget,
    this.labelMaxLines,
    this.subtitle,
    this.subtitleWidget,
    this.subtitleMaxLines,
    this.leading,
    this.trailing,
    this.iosChevron = defaultCupertinoForwardIcon,
    this.iosChevronPadding = defaultCupertinoForwardPadding,
    this.value,
    this.valueWidget,
    this.hasDetails = false,
    this.enabled = true,
    this.onPress,
    this.switchValue = false,
    this.onToggle,
    this.labelTextStyle,
    this.subtitleTextStyle,
    this.valueTextStyle,
    this.switchActiveColor,
    this.listTileTheme,
    this.borderRadius,
    this.setHeight,
    this.height,
  })  : assert(labelMaxLines == null || labelMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0),
        assert(!(height != null && setHeight != null && setHeight == true),
            "Cannot set both a custom height and use the predefined height (i.e. setHeight = true)"),
        super(key: key);

  final String? label;
  final Widget? labelWidget;
  final int? labelMaxLines;
  final String? subtitle;
  final Widget? subtitleWidget;
  final int? subtitleMaxLines;
  final Widget? leading;
  final Widget? trailing;
  final Icon? iosChevron;
  final EdgeInsetsGeometry? iosChevronPadding;
  final SettingsItemType type;
  final String? value;
  final Widget? valueWidget;
  final bool hasDetails;
  final bool enabled;
  final PressOperationCallback? onPress;
  final bool? switchValue;
  final Function(bool value)? onToggle;
  final TextStyle? labelTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextStyle? valueTextStyle;
  final Color? switchActiveColor;
  final SettingsTileTheme? listTileTheme;
  final BorderRadiusGeometry? borderRadius;

  ///Wether or not to set a height for the tile (so you could use dynamic height based on children),
  ///defaults t0 [true]
  final bool? setHeight;

  ///Height of the tile
  final double? height;

  @override
  State<StatefulWidget> createState() => CupertinoSettingsItemState();
}

class CupertinoSettingsItemState extends State<CupertinoSettingsItem> {
  bool pressed = false;
  bool? _checked;

  @override
  Widget build(BuildContext context) {
    _checked = widget.switchValue;

    /// The width of iPad. This is used to make circular borders on iPad and web
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    final ThemeData theme = Theme.of(context);
    final listTileTheme = ListTileTheme.of(context);

    final tileTheme = ListTileTheme(
      dense: widget.listTileTheme?.dense ?? listTileTheme.dense,
      shape: widget.listTileTheme?.shape ?? listTileTheme.shape,
      style: widget.listTileTheme?.style ?? listTileTheme.style,
      selectedColor:
          widget.listTileTheme?.selectedColor ?? listTileTheme.selectedColor,
      iconColor: widget.listTileTheme?.iconColor ?? listTileTheme.iconColor,
      textColor: widget.listTileTheme?.textColor ?? listTileTheme.textColor,
      contentPadding:
          widget.listTileTheme?.contentPadding ?? listTileTheme.contentPadding,
      tileColor: widget.listTileTheme?.tileColor ?? listTileTheme.tileColor,
      selectedTileColor: widget.listTileTheme?.selectedTileColor ??
          listTileTheme.selectedTileColor,
      enableFeedback:
          widget.listTileTheme?.enableFeedback ?? listTileTheme.enableFeedback,
      horizontalTitleGap: widget.listTileTheme?.horizontalTitleGap ??
          listTileTheme.horizontalTitleGap,
      minVerticalPadding: widget.listTileTheme?.minVerticalPadding ??
          listTileTheme.minVerticalPadding,
      minLeadingWidth: widget.listTileTheme?.minLeadingWidth ??
          listTileTheme.minLeadingWidth,
      child: const SizedBox.shrink(),
    );
    //final ListTileTheme tileTheme = listTileThemes ?? ListTileTheme.of(context);

    final iconThemeData = IconThemeData(
      color: widget.enabled
          ? _iconColor(theme, tileTheme)
          : CupertinoColors.inactiveGray,
    );

    Widget? leadingIcon;
    if (widget.leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: widget.leading!,
      );
    }

    List<Widget> rowChildren = [];
    if (leadingIcon != null) {
      rowChildren.add(
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: tileTheme.minLeadingWidth ?? 15.0,
          ),
          child: leadingIcon,
        ),
      );
    }

    final Widget titleSection;
    if (widget.subtitle == null) {
      titleSection = widget.labelWidget ??
          Text(
            widget.label ?? '',
            overflow: TextOverflow.ellipsis,
            style: widget.labelTextStyle ??
                TextStyle(
                    fontSize: 16,
                    color: !widget.enabled
                        ? CupertinoColors.inactiveGray
                        : widget.listTileTheme?.textColor),
          );
    } else {
      titleSection = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.labelWidget ??
              Text(
                widget.label ?? '',
                overflow: TextOverflow.ellipsis,
                style: widget.labelTextStyle,
              ),
          const SizedBox(height: 2.5),
          widget.subtitleWidget ??
              Text(
                widget.subtitle!,
                maxLines: widget.subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: widget.subtitleTextStyle ??
                    const TextStyle(
                      fontSize: 12.0,
                      letterSpacing: -0.2,
                    ),
              ),
        ],
      );
    }

    rowChildren.add(Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 15.0,
          end: 15.0,
        ),
        child: titleSection,
      ),
    ));

    switch (widget.type) {
      case SettingsItemType.toggle:
        rowChildren.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 11.0),
            child: CupertinoSwitch(
              value: widget.switchValue!,
              activeColor: widget.enabled
                  ? (widget.switchActiveColor ??
                      Theme.of(context).colorScheme.secondary)
                  : CupertinoColors.inactiveGray,
              onChanged: !widget.enabled
                  ? null
                  : (bool value) {
                      widget.onToggle!(value);
                    },
            ),
          ),
        );
        break;

      case SettingsItemType.modal:
        if (widget.value != null) {
          rowChildren.add(
            widget.valueWidget ??
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 1.5,
                      end: 2.25,
                    ),
                    child: Text(
                      widget.value!,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: widget.valueTextStyle ??
                          const TextStyle(
                            color: CupertinoColors.inactiveGray,
                            fontSize: 16,
                          ),
                    ),
                  ),
                ),
          );
        }

        final List<Widget> endRowChildren = [];
        if (widget.trailing != null) {
          endRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 0.5,
                start: 2.25,
              ),
              child: widget.trailing,
            ),
          );
        }

        final iosChevron = widget.iosChevron;
        if (widget.trailing == null && iosChevron != null) {
          endRowChildren.add(
            widget.iosChevronPadding == null
                ? iosChevron
                : Padding(
                    padding: widget.iosChevronPadding!,
                    child: iosChevron,
                  ),
          );
        }

        endRowChildren.add(const SizedBox(width: 8.5));

        rowChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: endRowChildren,
          ),
        );
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if ((widget.onPress != null || widget.onToggle != null) &&
            widget.enabled) {
          if (mounted) {
            setState(() {
              pressed = true;
            });
          }

          if (widget.onPress != null) {
            widget.onPress!();
          }

          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                pressed = false;
              });
            }
          });
        }

        if (widget.type == SettingsItemType.toggle && widget.enabled) {
          if (mounted) {
            setState(() {
              _checked = !_checked!;
              widget.onPress?.call();
            });
          }
        }
      },
      onTapUp: (_) {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = false;
          });
        }
      },
      onTapDown: (_) {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = true;
          });
        }
      },
      onTapCancel: () {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: isLargeScreen
              ? (widget.borderRadius ??
                  const BorderRadius.all(Radius.circular(20)))
              : null,
          color: tileTheme.tileColor ?? calculateBackgroundColor(context),
        ),
        height:
            //Set to given height, if non-null
            widget.height ??
                //If we should set height, we use the predefined height, otherwise return null
                ((widget.setHeight ?? true)
                    ? (widget.subtitle == null && widget.subtitleWidget == null
                        ? 44.0
                        : 57.0)
                    : null),
        child: Row(
          children: rowChildren,
        ),
      ),
    );
  }

  Color calculateBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? pressed
              ? iosPressedTileColorLight
              : Colors.white
          : pressed
              ? iosPressedTileColorDark
              : iosTileDarkColor;

  Color? _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    // if (tileTheme.selectedColor != null) {
    //   return tileTheme.selectedColor;
    // }

    if (tileTheme.iconColor != null) {
      return tileTheme.iconColor;
    }

    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return null; // null - use current icon theme color
    }
  }
}

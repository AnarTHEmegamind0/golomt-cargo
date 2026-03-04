import 'package:flutter/material.dart';

class ThemeModePicker extends StatelessWidget {
  const ThemeModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto_rounded),
          label: Text('Систем'),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_rounded),
          label: Text('Цайвар'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_rounded),
          label: Text('Харанхуй'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selected) {
        onChanged(selected.first);
      },
      showSelectedIcon: false,
    );
  }
}

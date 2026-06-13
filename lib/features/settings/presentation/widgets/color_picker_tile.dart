import 'package:flutter/material.dart';
import 'package:vetro/core/theme/vetro_colors.dart';

class ColorPickerTile extends StatelessWidget {
  const ColorPickerTile({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Accent Color'),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
      ),
      onTap: () => _showColorPicker(context),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ColorPickerDialog(
        currentColor: currentColor,
        onColorChanged: onColorChanged,
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({
    required this.currentColor,
    required this.onColorChanged,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Accent Color'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preset colors grid
            const Text('Preset Colors', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VetroColors.seedColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Custom color row
            const Text('Custom', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (_) => _RawColorPicker(initial: _selectedColor),
                    );
                    if (color != null) setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onColorChanged(_selectedColor);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _RawColorPicker extends StatefulWidget {
  const _RawColorPicker({required this.initial});

  final Color initial;

  @override
  State<_RawColorPicker> createState() => _RawColorPickerState();
}

class _RawColorPickerState extends State<_RawColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initial);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  @override
  Widget build(BuildContext context) {
    final color = HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();

    return AlertDialog(
      title: const Text('Custom Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'H',
            value: _hue,
            max: 360,
            color: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
            onChanged: (v) => setState(() => _hue = v),
          ),
          _SliderRow(
            label: 'S',
            value: _saturation,
            max: 1,
            color: HSVColor.fromAHSV(1, _hue, _saturation, 1).toColor(),
            onChanged: (v) => setState(() => _saturation = v),
          ),
          _SliderRow(
            label: 'V',
            value: _value,
            max: 1,
            color: HSVColor.fromAHSV(1, _hue, 1, _value).toColor(),
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, color),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 24, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(value: value, max: max, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}

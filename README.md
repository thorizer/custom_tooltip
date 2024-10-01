# Custom Tooltip

A highly customizable tooltip widget for Flutter applications, offering rich functionality for both desktop and mobile platforms.

![mpvnet_sW3NuBsQJ2](https://github.com/user-attachments/assets/2b9bce53-1ee6-4c51-afdf-3e312a161a56)

## Features

- **Flexible Content**: Supports any widget as both the child and tooltip content.
- **Customizable Appearance**:
  - Adjustable tooltip width and height
  - Customizable background color
  - Configurable border radius
  - Custom padding
  - Adjustable elevation
  - Option for custom decoration
  - Customizable text style
- **Smart Positioning**: Automatically adjusts position to fit within screen bounds
- **Timing Control**:
  - Configurable hover delay before showing tooltip
  - Adjustable show and hide durations for smooth animations
- **Platform-Specific Behavior**:
  - Hover functionality for desktop and web platforms
  - Touch support for mobile platforms
- **Interactive Features**:
  - Tooltip can be pinned on tap/click
  - Tapping outside the tooltip dismisses it
- **Animated Display**: Smooth fade-in and fade-out animations

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  custom_tooltip: ^1.0.0
```

## Usage

Import the package in your Dart code:

```dart
import 'package:custom_tooltip/custom_tooltip.dart';
```

Basic usage:

```dart
CustomTooltip(
  child: Text('Hover or tap me'),
  tooltip: Text('This is a custom tooltip'),
  tooltipWidth: 200,
  tooltipHeight: 100,
  backgroundColor: Colors.blue,
  borderRadius: 8,
  padding: EdgeInsets.all(8),
  elevation: 6.0,
)
```

Advanced usage with more customization:

```dart
CustomTooltip(
  child: Icon(Icons.info),
  tooltip: Column(
    children: [
      Text('Custom Tooltip'),
      SizedBox(height: 10),
      ElevatedButton(
        child: Text('Action'),
        onPressed: () {
          // Handle button press
        },
      ),
    ],
  ),
  tooltipWidth: 250,
  tooltipHeight: 150,
  backgroundColor: Colors.black87,
  borderRadius: 12,
  padding: EdgeInsets.all(12),
  elevation: 8,
  hoverShowDelay: Duration(milliseconds: 500),
  showDuration: Duration(milliseconds: 300),
  hideDuration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: TextStyle(color: Colors.white, fontSize: 16),
)
```

## Additional Information

- The tooltip can be dismissed by tapping outside of it.
- On desktop/web, the tooltip appears after hovering for a specified duration.
- On mobile, tapping the child widget shows the tooltip.
- Tapping the child while the tooltip is visible will pin it in place.
- The tooltip automatically adjusts its position to stay within screen bounds.

For more detailed examples, please refer to the `example` folder in the package repository.

## Customization Options

| Parameter | Type | Description |
|-----------|------|-------------|
| `child` | `Widget` | The widget that triggers the tooltip |
| `tooltip` | `Widget` | The content of the tooltip |
| `tooltipWidth` | `double?` | Width of the tooltip |
| `tooltipHeight` | `double?` | Height of the tooltip |
| `backgroundColor` | `Color` | Background color of the tooltip |
| `borderRadius` | `double` | Border radius of the tooltip |
| `padding` | `EdgeInsetsGeometry` | Internal padding of the tooltip |
| `elevation` | `double` | Elevation (shadow) of the tooltip |
| `hoverShowDelay` | `Duration` | Delay before showing tooltip on hover |
| `showDuration` | `Duration` | Duration of the show animation |
| `hideDuration` | `Duration` | Duration of the hide animation |
| `decoration` | `BoxDecoration?` | Custom decoration for the tooltip |
| `textStyle` | `TextStyle?` | Text style for the tooltip content |

## Contributions

Contributions to the Custom Tooltip package are welcome! Please feel free to submit issues and pull requests on our GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

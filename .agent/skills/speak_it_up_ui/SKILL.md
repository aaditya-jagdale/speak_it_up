---
description: Frontend designing and developing guidelines for the Speak It Up Flutter app — covers design tokens, typography, component patterns, animation, haptics, and code conventions.
---

# Speak It Up — Frontend Design & Development Skill

Use this skill whenever you are creating or modifying any Flutter screen or widget in the **Speak It Up** app. Every rule below is derived from the approved home screen design and must be applied consistently across the entire app.

---

## 1. Design Tokens

### 1.1 Colors
All colours live in `lib/shared/widgets/colors.dart` under `AppColors`. **Never** hard-code colours that have a named token.

| Token | Hex | Usage |
|---|---|---|
| `AppColors.primary` | `#00997A` | CTAs, highlights, active states |
| `AppColors.primary10` | `#CCE7D8` | Slot machine active card background, subtle tints |
| `AppColors.primary5` | `#E5F1E9` | Hover / pressed tint on primary surfaces |
| `AppColors.secondary` | `#093756` | Secondary accents (rare) |
| `AppColors.black` | `#090909` | Default icon colour (SVG `colorFilter`) |
| `AppColors.black75` | `#404040` | Secondary text |
| `AppColors.black50` | `#808080` | Placeholder / hint text |
| `AppColors.white20` | `#E8E8E8` | Dividers, card borders |
| `AppColors.danger` | `#FF5C5C` | Destructive actions, error states |

**Background** of every `Scaffold`: `const Color(0xFFFAFAFA)` — also set on `AppBar.backgroundColor`.

Ghost / disabled text (e.g. slot machine adjacent rows): `const Color(0xFFBBBBBB)`.

Card border colour: `const Color(0xFFE0E0E0)`.

> When mixing opacity into a colour, always use `.withValues(alpha: x)` — **never** the deprecated `.withOpacity()`.

---

### 1.2 Typography

Two font families are registered in `pubspec.yaml`:

| Family key | Usage |
|---|---|
| `'shrikhand'` | Display / hero text only (e.g. app title "Speak it up") |
| `'geist'` | **Everything else** — body, labels, buttons, captions |

**Never** rely on the system default font.

#### Standard sizes
| Role | Size | Weight |
|---|---|---|
| Hero / display | 62 px | Shrikhand (inherently bold) |
| Button label | 16 px | `w600` (primary), `w500` (outlined) |
| Body / card label | 16 px | `w500` |
| Secondary body | 14 px | `w400` |
| Caption / small | 12 px | `w400` |

Line-height (`height`) for display text: `1.05`. For body text omit `height` (use Flutter default).

---

### 1.3 Spacing & Layout

| Property | Value |
|---|---|
| Horizontal screen padding | `20 px` (applied to `Scaffold` body via `Padding`) |
| Standard border radius | `8 px` (`BorderRadius.circular(8)`) |
| Button height | `52 px` |
| Gap between paired buttons | `12 px` |
| Section vertical gaps | `24 px` (small), `32 px` (medium), `40 px` (large) |
| Card inner padding | `horizontal: 10, vertical: 12` |

---

## 2. AppBar Conventions

```dart
AppBar(
  backgroundColor: const Color(0xFFFAFAFA),
  elevation: 0,
  scrolledUnderElevation: 0,
  // title: only if needed — use Geist, fontSize 16, fontWeight w600
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          // action
        },
        child: SvgPicture.asset(
          'assets/icons/<icon>.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xFF090909), BlendMode.srcIn,
          ),
        ),
      ),
    ),
  ],
)
```

- `elevation: 0` and `scrolledUnderElevation: 0` on every AppBar — no shadow.
- AppBar icon buttons are **always** `GestureDetector` with `HitTestBehavior.opaque`.
- Icon size: `24 × 24`. SVG icons are colourised with `colorFilter`.

---

## 3. Button Patterns

### 3.1 Primary (filled) button
```dart
GestureDetector(
  onTap: () {
    HapticFeedback.mediumImpact(); // or lightImpact for secondary actions
    // action
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        'Label',
        style: TextStyle(
          fontFamily: 'geist',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  ),
)
```

### 3.2 Outlined / void button
```dart
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    // action
  },
  child: Container(
    height: 52,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.primary, width: 1.5),
    ),
    child: Center(
      child: Text(
        'Label',
        style: TextStyle(
          fontFamily: 'geist',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    ),
  ),
)
```

**Key rules:**
- **Never** use `ElevatedButton` or `TextButton` for app buttons — use `GestureDetector` + `Container`/`AnimatedContainer`.
- Buttons are always `void` (no Flutter ink splash) — use `GestureDetector`, not `InkWell`.
- Loading state inside a primary button: `CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))` inside a `SizedBox(width: 20, height: 20)`.
- When a loading state dims the button, use `.withValues(alpha: 0.85)`.

---

## 4. Haptic Feedback Rules

Import: `import 'package:flutter/services.dart';`

| Trigger | Feedback |
|---|---|
| Primary action (Spin, Submit, Confirm) | `HapticFeedback.mediumImpact()` |
| Secondary / navigation action (Timer, Settings, Back) | `HapticFeedback.lightImpact()` |
| Success / completion | `HapticFeedback.lightImpact()` (second pulse after primary) |
| Destructive / error | `HapticFeedback.heavyImpact()` |

Call haptic **before** starting any async work so it fires immediately on tap.

---

## 5. Card / Container Patterns

Standard info card:
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  decoration: BoxDecoration(
    color: const Color(0xFFFAFAFA),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
  ),
  child: /* content */,
)
```

Tinted highlight card (e.g. active slot row):
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.primary10,
    borderRadius: BorderRadius.circular(8),
  ),
  child: /* content */,
)
```

---

## 6. Animation Conventions

- Use `AnimatedSwitcher` for content that swaps (e.g. text changing):
  ```dart
  AnimatedSwitcher(
    duration: const Duration(milliseconds: 80),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    ),
    child: Widget(key: ValueKey(uniqueValue)),
  )
  ```
- Always provide a unique `ValueKey` to `AnimatedSwitcher` children.
- Use `AnimatedContainer` (duration `150 ms`) for property transitions on a single widget (colour, size, etc).
- Prefer `Curves.easeOut` for enter transitions, `Curves.easeIn` for exit.
- Always check `if (!mounted) return;` after every `await` in state-mutating async functions.

---

## 7. Scaffold & Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        // title / actions as needed
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // content
            ],
          ),
        ),
      ),
    );
  }
}
```

- Always wrap `body` with `SafeArea`.
- Top-level horizontal padding is always `20` via a single `Padding` wrapping the body column.
- `crossAxisAlignment: CrossAxisAlignment.stretch` on the root `Column` so buttons fill the width.

---

## 8. SVG Icons

- All icons are in `assets/icons/` and must be referenced with `flutter_svg`.
- Always apply a `colorFilter` to SVGs rather than pre-coloured assets:
  ```dart
  SvgPicture.asset(
    'assets/icons/icon_name.svg',
    width: 24,
    height: 24,
    colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
  )
  ```

---

## 9. Code Style Rules

1. **No `ElevatedButton`, `TextButton`, or `OutlinedButton`** in new screens — always `GestureDetector` + `Container`.
2. **No `withOpacity()`** — use `.withValues(alpha: x)`.
3. **No hard-coded colour hex** for values that exist in `AppColors`.
4. Private sub-widgets of a screen go below the screen class in the same file, named with a leading `_`: `_StepCard`, `_SpinButton`, etc.
5. Build-method helpers are private methods named `_build<Section>()`.
6. Comment section dividers inside `build()` with `// ── Section name ───` style.
7. `StatelessWidget` for sub-widgets that don't manage state.
8. Always annotate `// TODO: navigate to X` for navigation stubs.
9. Run `flutter analyze` before committing. Zero issues is the bar.

---

## 10. Quick Reference Checklist

Before submitting any new screen or widget, verify:

- [ ] `Scaffold.backgroundColor` is `const Color(0xFFFAFAFA)`
- [ ] `AppBar` has `elevation: 0`, `scrolledUnderElevation: 0`
- [ ] All fonts specify `fontFamily: 'geist'` (or `'shrikhand'` for display only)
- [ ] Font sizes are from the standard scale (12 / 14 / 16 / 62)
- [ ] All border radii are `8`
- [ ] Button height is `52`
- [ ] Buttons are `GestureDetector` + plain `Container` (no Material ink)
- [ ] Appropriate haptic feedback is called on every interactive element
- [ ] No `.withOpacity()` calls — using `.withValues(alpha:)`
- [ ] `if (!mounted) return;` after every `await` in `setState`-calling async methods
- [ ] `flutter analyze` returns **No issues found**

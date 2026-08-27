# UI System

Based on the CSS prototype in `styles.css`.

## Colors
- **Primary**: `#FF5A36`
- **Primary Hover**: `#E04825`
- **Primary Light**: `#FFF2EF`
- **Secondary**: `#4A7C59`
- **Secondary Hover**: `#3B6347`
- **Secondary Light**: `#EEF6F1`
- **Background App**: `#FAF8F5`
- **Background Card**: `#FFFFFF`
- **Text Main**: `#2D2A26`
- **Text Muted**: `#7E7873`
- **Border**: `#EBE5DF`
- **Accent**: `#E6A23C`
- **Accent Light**: `#FDF6EC`

## Typography
- **Title Font**: `Outfit`, sans-serif
- **Body Font**: `Plus Jakarta Sans`, sans-serif

*Note: Use `google_fonts` package to implement these.*

## Spacing & Radius
- **Radius Small**: 8px
- **Radius Medium**: 16px
- **Radius Large**: 24px
- **Radius XL**: 32px

## Shadows
- **Shadow Small**: `0 2px 8px rgba(45, 42, 38, 0.04)`
- **Shadow Medium**: `0 8px 24px rgba(45, 42, 38, 0.06)`
- **Shadow Large**: `0 16px 40px rgba(45, 42, 38, 0.1)`

## Components

### Buttons
- Buttons should have height `50px` (or similar padded size) and rounded corners (`Radius Medium`).
- Use `Primary` background for primary actions, transparent with border for secondary.

### Input Fields
- Input fields should have `1.5px` border with `Border` color, and focus to `Primary`.

### Navigation
- Persistent Bottom Navigation bar with simple line-art icons and active labels highlighted in `Primary` color.

## UI Rules
- Do NOT invent arbitrary colors. Use the palette above.
- Ensure the Flutter implementation visually reproduces the design system specified in the prototypes (`index.html` and `styles.css`).
- If an exact value cannot be determined, mark it as requiring confirmation instead of inventing one.

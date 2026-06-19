# Changelog

All notable changes to GiroCall will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-06-19

### Added
- Enhanced frosted glassmorphism across Profile and Digital Card views using improved `GlassSurface` with real `BackdropFilter` blur.
- Subtle entrance animations (fade + slide, elastic scale on avatars) in Profile hub and card using `TweenAnimationBuilder`.
- Refined spacing and padding using `AppSpacing` and `AppTokens` for more breathing room and modern layout on `/profile`.

### Changed
- **Visual refresh** on `/profile`, My Card (`/profile/card`), and Digital Business Card:
  - More premium glass effects (frosted + refined borders/shadows) with excellent dark mode support.
  - Better integration with the new vibrant brand palette (#1EB05B green, #F06A36 orange, etc.).
  - Updated `_ProfileHeader`, `_HeroHeader`, Settings tiles, and interactive elements.
- Dark mode refinements: improved glass alphas, shadows, and text contrast on gradients and surfaces.
- Updated `SettingsSection` and `SettingsTile` with larger touch targets, modern rounding, and tighter typography.
- `GlassSurface` now supports `frosted` and `blurSigma` props for stronger premium effects.

### Fixed / Cleaned
- Lint issues resolved (analyze clean).
- Consistent use of brand colors and tokens in profile flows.
- Minor spacing and padding inconsistencies cleaned up.

### Version
- Bumped to `2.1.0+6`

## [2.0.0] - 2026-06-18
- Ground-up v2 Flutter rebuild with design system, Supabase sync, wheel, status, stats, profile hub and more (see prior notes).

[2.1.0]: https://github.com/CulturePassion/GiroCall/compare/v2.0.0...v2.1.0

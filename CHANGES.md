# Statement of changes

Apache License 2.0 section 4(b) requires that modified files carry prominent
notices stating that we changed them. This file is that notice, kept as one list
so a reader can see the whole divergence without walking the tree.

**Upstream base:** [`block/buzz`](https://github.com/block/buzz) @
`f956e6fe06a76e50cbd8fba1a162482e752e7f1a`, forked 2026-08-17. Everything below
is our change relative to that commit; everything not listed is upstream's work,
unmodified, under its original copyright.

## Rebrand (2026-08-17)

The product ships under the name **5dive** and the 5dive mark. Apache-2.0 s6
grants no trademark rights, so the upstream name and mark are removed from
anything that identifies the product to a user or a store.

**Application identity**

| File | Change |
| --- | --- |
| `mobile/ios/Flutter/Release.xcconfig`, `Debug.xcconfig` | `BUNDLE_IDENTIFIER` → `com.fivedive.chat`; `APP_DISPLAY_NAME` → `5dive` |
| `mobile/ios/Runner/Info.plist` | `CFBundleName` → `5dive`; the four permission-prompt strings now name 5dive |
| `mobile/android/app/build.gradle.kts` | `applicationId` → `com.fivedive.chat`; `app_name` resource → `5dive` (release and worktree variants) |

The Android `namespace` is deliberately left as upstream's — it names the
generated `R` class, is never shown to a user, and changing it would touch every
generated reference for no user-visible gain.

**Artwork** — regenerated from the 5dive mark (a white `5` on `#1A1A1F`):

| File | Change |
| --- | --- |
| `mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` | all 15 sizes regenerated |
| `mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png` | all 3 sizes regenerated |
| `mobile/android/app/src/main/res/mipmap-*/ic_launcher.png` | regenerated (5 densities) |
| `mobile/android/app/src/main/res/mipmap-*/ic_launcher_round.png` | regenerated, circular mask (5 densities) |
| `mobile/android/app/src/main/res/mipmap-*/ic_launcher_foreground.png` | adaptive foreground: the glyph on transparent, scaled to the composed icon's weight (5 densities) |
| `mobile/android/app/src/main/res/mipmap-*/launch_image.png` | regenerated (5 densities) |
| `mobile/android/app/src/main/res/values/ic_launcher_background.xml` | adaptive background `#000` → `#1A1A1F`, matching the mark |

**User-visible copy** — string literals only; internal identifiers
(`BuzzLoadingIndicator`, `buzzThemeName`, `package:buzz/…`) are untouched on
purpose, because renaming them is pure rebase cost against a fast-moving
upstream and no user ever sees them:

`mobile/lib/app.dart` · `features/pairing/pairing_page.dart` ·
`features/pairing/pairing_page/pairing_welcome_view.dart` ·
`features/settings/settings_page/connection_section.dart` ·
`features/channels/photo_library.dart` ·
`features/channels/agent_activity/transcript_builder.dart` ·
`features/channels/compose_bar/camera_preview.dart` ·
`features/invites/invite_join_sheet.dart` ·
`shared/security/sensitive_action_authorizer.dart` ·
`shared/theme/theme_provider.dart` · `shared/widgets/tappable_flapping_bee.dart`

`mobile/lib/shared/theme/theme_pairs.dart` gains a display-name override so the
default theme reads "5dive" in the picker; upstream derives that label by
capitalising the theme id, which would otherwise print the upstream name.

The matching assertions were updated in `mobile/test/widget_test.dart`,
`test/features/pairing/pairing_page_test.dart`,
`test/features/settings/connection_section_test.dart`,
`test/features/channels/deep_link_dispatcher_test.dart`,
`test/features/channels/agent_activity/transcript_builder_test.dart`,
`test/shared/security/sensitive_action_authorizer_test.dart`,
`test/shared/theme/buzz_theme_test.dart`.

Added: `NOTICE`, this file, and the fork header in `README.md`.

## Known remaining upstream-brand surfaces — clear these BEFORE any store build

These are named here rather than left to be discovered in review. None of them
is fixed yet.

1. **The bee mark is still Block's.** `mobile/lib/shared/widgets/flapping_bee.dart`
   paints a bee silhouette, and it is the app's loading indicator in ~25 call
   sites, the pull-to-refresh indicator, and the hero on the pairing welcome
   screen. Replacing it is a design task (draw a 5dive loading mark), not a
   string swap, so it was not attempted here. Its accessibility label no longer
   claims to be either brand.
2. **The `buzz://` deep-link scheme is unchanged** — registered in
   `Info.plist` and `AndroidManifest.xml` and parsed across ~8 Dart files
   including regexes. A user sees it in "Copy link" output. Changing it is a
   compatibility break as well as a wide diff; it needs a decision, not a
   rename.
3. **`README.md` and the `VISION*.md` / `ARCHITECTURE.md` docs are upstream's**,
   and describe the upstream product by name. Only the fork header at the top of
   `README.md` is ours.

# RKeeper

RKeeper is a highly visual, offline-first Flutter app for tracking progress in books, comics, manga, anime, TV shows, light novels, and any other serial media.

## Design language

The UI follows the supplied mobile reference: deep black/brown backgrounds, copper-orange accents, cream typography, large rounded visual cards, soft gradients, pill controls, and glass-like bottom navigation.

## Features

- Custom categories with editable colors and image backgrounds.
- Optional groups/sub-folders inside each category.
- Full CRUD for categories, groups, and media items.
- Progress tracking with direct `+` and `-` card controls.
- Clickable source links opened with `url_launcher`.
- Status tags such as Reading, Watching, On Hold, Dropped, Completed, and Plan to Watch.
- Last updated timestamps and recently updated sorting.
- Global search across all tracked items.
- Clipboard URL detector when creating a new item.
- Firebase-powered cloud persistence.

## Run

```bash
flutter pub get
flutter run
```

If you unzip this source-only package into an empty folder and your Flutter tool needs platform folders, run:

```bash
flutter create .
flutter pub get
flutter run
```

## Main folders

- `lib/core`: constants, errors, and helpers.
- `lib/domain`: app entities and repository contract.
- `lib/data`: Firebase storage service and repository implementation.
- `lib/presentation`: Provider state, screens, widgets, and theme.

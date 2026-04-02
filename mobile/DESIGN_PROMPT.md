# 🏆 Award-Winning Cargo App Design & Code Prompt

## 🎯 Vision Statement

Create a visually stunning, Pinterest-inspired cargo delivery app that transforms logistics into a delightful visual experience. Think **Awwwards-level design** meets **Buunduu cargo efficiency** - where every interaction feels Premium, every animation tells a story, and every screen is Instagram-worthy.

---

## 🎨 Design Philosophy

### Core Principles
1. **Visual Storytelling** - Every package has a journey worth seeing
2. **Effortless Elegance** - Complex logistics made beautifully simple
3. **Motion Magic** - Micro-interactions that spark joy
4. **Spatial Luxury** - Generous whitespace, breathing room
5. **Glass Morphism** - Modern depth with frosted glass effects

### Design DNA
- **Pinterest Masonry Layouts** - Dynamic, visual-first card grids
- **Cinematic Animations** - Smooth 60fps transitions everywhere
- **Premium Minimalism** - Less is exponentially more
- **Playful Professionalism** - Serious service, delightful experience
- **Dark Mode First** - OLED-optimized with vibrant accents

---

## 🌈 Color System

### Primary Palette
```dart
// Deep Ocean Blue - Trust & Reliability
primary: Color(0xFF0A1E3D)
primaryLight: Color(0xFF1A2F4D)
primaryDark: Color(0xFF050F1F)

// Electric Violet - Innovation & Energy
accent: Color(0xFF8B5CF6)
accentLight: Color(0xFFA78BFA)
accentGlow: Color(0xFFC4B5FD)

// Soft Coral - Warmth & Completion
success: Color(0xFFFF6B9D)
warning: Color(0xFFFBBF24)
error: Color(0xFFEF4444)

// Neutral Sophistication
neutral100: Color(0xFFF8FAFC) // Backgrounds light
neutral200: Color(0xFFE2E8F0)
neutral300: Color(0xFFCBD5E1)
neutral700: Color(0xFF334155) // Text secondary
neutral800: Color(0xFF1E293B) // Text primary
neutral900: Color(0xFF0F172A) // Deepest dark
```

### Gradient Magic
```dart
heroGradient: LinearGradient(
  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

glassGradient: LinearGradient(
  colors: [
    Color(0x40FFFFFF),
    Color(0x10FFFFFF),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

statusGradient: LinearGradient(
  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
  stops: [0.0, 1.0],
)
```

---

## 🔤 Typography System

### Font Families
```dart
// Primary - Space Grotesk (Modern, Tech-forward)
displayFont: 'SpaceGrotesk'

// Secondary - Inter (Clean, Readable)
bodyFont: 'Inter'

// Accent - JetBrains Mono (Code, Tracking numbers)
monoFont: 'JetBrainsMono'
```

### Text Styles
```dart
// Display - Hero Headlines
display: TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 56,
  fontWeight: FontWeight.w700,
  letterSpacing: -2.0,
  height: 1.1,
)

// Headline - Page Titles
headline: TextStyle(
  fontFamily: 'SpaceGrotesk',
  fontSize: 32,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.5,
  height: 1.2,
)

// Title - Card Headings
title: TextStyle(
  fontFamily: 'Inter',
  fontSize: 18,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.2,
  height: 1.4,
)

// Body - Primary Content
body: TextStyle(
  fontFamily: 'Inter',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
  height: 1.6,
)

// Caption - Metadata, Labels
caption: TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
  height: 1.4,
)

// Tracking - Package IDs
tracking: TextStyle(
  fontFamily: 'JetBrainsMono',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.0,
)
```

---

## 🏗️ Component Library

### 1. Hero Package Card (Pinterest-style)
```dart
// Visual-first card with image, glassmorphism overlay
// Asymmetric layout with dynamic heights
// Hover effects: subtle lift + glow
// Drag to details with elastic spring animation
// Status badge: floating pill with gradient
// ETA countdown: animated ring progress
```

**Specifications:**
- Border radius: 24px
- Shadow: 0px 20px 60px rgba(0,0,0,0.15)
- Image aspect ratio: Dynamic (maintain original)
- Backdrop blur: 20px on overlay
- Touch feedback: Scale(0.98) + haptic

### 2. Masonry Grid Layout
```dart
// Pinterest-style staggered grid
// 2 columns on mobile, 3+ on tablet
// Lazy loading with shimmer placeholders
// Pull to refresh with custom animation
// Infinite scroll with momentum
// Filter chips: floating at top with blur background
```

### 3. Animated Tracking Timeline
```dart
// Vertical timeline with animated connections
// Each checkpoint: Icon + Label + Timestamp
// Active step pulses with gradient ring
// Completed steps: checkmark + success color
// Future steps: dim + dashed connector
// Auto-scroll to active step on load
// Swipe between packages horizontally
```

### 4. Glass Morphism Action Buttons
```dart
// Frosted glass background
// Subtle border with gradient
// Icon + Label horizontal layout
// Ripple effect on press
// Micro-interaction: icon bounces on tap
// Elevation: lifts on press

PrimaryButton:
  - Height: 56px
  - Padding: 24px horizontal
  - Border radius: 28px (pill shape)
  - Gradient background
  - White text + icon
  - Shadow: colored glow effect

SecondaryButton:
  - Glass background (30% opacity)
  - Border: 1px gradient stroke
  - Colored text + icon
  - Hover: background opacity 50%
```

### 5. Smart Search Bar
```dart
// Centered, expandable search
// Icon morphs from magnifying glass to close X
// Suggestions appear in floating card below
// Recent searches with delete swipe action
// Voice input button (animated waveform)
// Barcode scanner integration
// Auto-complete with debouncing
```

### 6. Status Chips
```dart
// Pill-shaped badges with icons
// Gradient backgrounds per status
// Subtle animation loop (pulse/shimmer)
// Haptic feedback on tap
// Size: Small (24h), Medium (32h), Large (40h)

States:
  - Pending: Yellow gradient, clock icon
  - In Transit: Blue gradient, truck icon, animated
  - Delivered: Green gradient, checkmark, confetti
  - Delayed: Orange gradient, warning icon, pulse
  - Cancelled: Gray, X icon
```

### 7. Bottom Sheet Modal
```dart
// Draggable handle at top
// Rounded corners: 32px top only
// Glass background with heavy blur
// Snap points: 50%, 90%, dismiss
// Over-scroll rubber band effect
// Smooth spring physics
// Backdrop: 40% black overlay with blur
```

### 8. Onboarding Flow
```dart
// Full-screen hero animations
// Lottie illustrations for each step
// Liquid swipe transitions
// Skip button: subtle, top-right
// Progress dots: morphing line
// Final CTA: gradient button with arrow animation
```

---

## 🎬 Animation Specifications

### Timing Functions
```dart
// Ease Out Expo - Default for most UI
Curves.easeOutExpo

// Elastic - For playful interactions
Curves.elasticOut

// Decelerate - Sheet dismissals
Curves.fastOutSlowIn

// Spring - Natural physics
CustomCurve(spring: SpringDescription(
  mass: 1.0,
  stiffness: 100.0,
  damping: 15.0,
))
```

### Duration Standards
```dart
micro: 100ms   // Checkbox, toggle
short: 200ms   // Button press, chip select
medium: 300ms  // Card expand, sheet open
long: 500ms    // Page transitions
cinematic: 800ms // Hero animations
```

### Key Animations

#### 1. Page Transitions
```dart
// Shared element transitions
// Z-axis depth (scale + fade)
// Asymmetric timing (enter faster than exit)
// Route-specific animations

HomeToDetails:
  - Card expands to fill screen
  - Other cards fade + scale down
  - Navigation bar crossfades
  - Duration: 500ms elastic

BottomNavSwitch:
  - Slide + fade current screen
  - Offset: 20px horizontal
  - Overlap: 100ms
  - Duration: 300ms ease-out
```

#### 2. Loading States
```dart
// Shimmer effect on placeholder cards
// Gradient shimmer: 45° angle
// Speed: 1.5s per cycle
// Colors: subtle shine over base

// Skeleton screens match final layout
// Progressive loading: text → images
// Success microanimation on load complete
```

#### 3. Micro-interactions
```dart
LikeButton:
  - Scale burst from 1.0 → 1.3 → 1.0
  - Particle explosion (5-8 hearts)
  - Haptic: impact medium
  - Duration: 400ms

AddToCart:
  - Icon flies to cart badge
  - Cart badge bounces + count increments
  - Success checkmark overlay
  - Duration: 600ms

PullToRefresh:
  - Custom indicator: spinning package box
  - Elastic overscroll
  - Success: brief checkmark
  - Rotation: 360° spring
```

#### 4. List Animations
```dart
// Staggered entry animation
// Each item delays by 50ms
// Slide up + fade in
// Total cascade: 300ms for 6 items

ListView:
  - Enter from bottom: offset 20px
  - Opacity: 0 → 1
  - Curve: easeOutExpo
  - Lazy: only animate visible items

Delete:
  - Swipe to reveal action
  - Red background fades in
  - Item scales down + fades
  - List items animate closed
  - Duration: 300ms
```

---

## 📱 Key Screens & User Flows

### 1. Splash Screen (2s)
```dart
// Centered logo with subtle scale pulse
// Gradient background animation
// App name fade-in below logo
// Smooth crossfade to onboarding/home
// Check auth state in background
```

### 2. Onboarding (3 screens)
```
Screen 1: "Track Anything, Anywhere"
  - Hero illustration: Package with wings
  - Body text: Quick value prop
  - Liquid swipe to next

Screen 2: "Live Updates, Real-Time"
  - Illustration: Animated tracking map
  - Feature highlights (3 bullets)
  - Swipe to continue

Screen 3: "Your Packages, Organized"
  - Illustration: Organized dashboard
  - CTA: "Get Started" gradient button
  - Sign in link below (subtle)
```

### 3. Home Dashboard (Pinterest Feed)
```dart
Structure:
┌─────────────────────────┐
│ 🔍 Search + Filter      │ ← Sticky header, glass blur
├─────────────────────────┤
│ 📊 Stats Cards (H-Scroll│ ← Compact metrics
├─────────────────────────┤
│                         │
│  ┌────┐    ┌────────┐  │
│  │IMG │    │  IMG   │  │ ← Masonry grid
│  │    │    │        │  │   Dynamic heights
│  └────┘    │        │  │   Lazy loading
│            └────────┘  │
│  ┌─────────┐           │
│  │   IMG   │  ┌─────┐ │
│  │         │  │ IMG │ │
│  └─────────┘  └─────┘ │
│                         │
└─────────────────────────┘
│ 📦 🔍 ➕ 👤 ⚙️          │ ← Bottom nav glass bar
└─────────────────────────┘

Features:
- Pull to refresh custom animation
- Filter chips: All, In Transit, Delivered
- Each card shows: Image, Title, Status, ETA
- Tap card: hero animation to details
- Long press: quick actions menu
- Empty state: beautiful illustration + CTA
```

### 4. Package Details Screen
```dart
Structure:
┌─────────────────────────┐
│ ← Back        Share ⋯   │ ← Transparent nav over image
├─────────────────────────┤
│                         │
│    HERO PACKAGE IMAGE   │ ← Full width, parallax scroll
│      (with gradient)    │
│                         │
├─────────────────────────┤
│ Package Name            │
│ Status Chip + ETA       │
├─────────────────────────┤
│ 🎯 Tracking Number      │ ← Copy button
│    PKG-2024-XYZ-789     │
├─────────────────────────┤
│ 📍 Current Location     │
│    Warehouse B, Seoul   │
│    Updated 5 mins ago   │
├─────────────────────────┤
│ ━━━━━━━━━━━━━━━━━━━━━  │ ← Timeline
│ ✓ Order Placed          │
│ ✓ Picked Up             │
│ ◉ In Transit            │ ← Active, pulsing
│ ○ Out for Delivery      │
│ ○ Delivered             │
├─────────────────────────┤
│ [View on Map] Button    │
│ [Contact Support]       │
└─────────────────────────┘

Interactions:
- Parallax scroll on hero image
- Copy tracking number (haptic + toast)
- Share button: native share sheet
- Timeline auto-scrolls to active
- Real-time updates (WebSocket)
- Map view: bottom sheet modal
```

### 5. Add Package Screen
```dart
// Two input methods

Method 1: Scan Barcode
┌─────────────────────────┐
│    CAMERA VIEWFINDER    │
│    [ Barcode Frame ]    │
│                         │
│  "Scan tracking number" │
│                         │
│  [Manual Entry Link]    │
└─────────────────────────┘

Method 2: Manual Entry
┌─────────────────────────┐
│ Tracking Number         │ ← Input with paste button
│ ┌─────────────────────┐ │
│ │ PKG-              │ │
│ └─────────────────────┘ │
│                         │
│ Nickname (optional)     │
│ ┌─────────────────────┐ │
│ │ Birthday Gift      │ │
│ └─────────────────────┘ │
│                         │
│ Add Photo (optional)    │
│ ┌─────┐                │
│ │  +  │ Upload         │
│ └─────┘                │
│                         │
│ [Track Package] Button  │ ← Gradient, full width
└─────────────────────────┘

Features:
- Auto-detect carrier from number
- Suggest nickname from AI
- Photo: camera or gallery
- Validate tracking number real-time
- Success: confetti + navigate to details
```

### 6. Profile Screen
```dart
┌─────────────────────────┐
│      ┌─────────┐        │
│      │ Avatar  │        │ ← Large, circular
│      └─────────┘        │
│     User Name           │
│   user@email.com        │
├─────────────────────────┤
│ 📊 Your Stats           │
│ ┌─────┬─────┬─────┐    │
│ │ 45  │ 12  │ 3   │    │ ← Cards with icons
│ │Deliv│Act  │Late │    │
│ └─────┴─────┴─────┘    │
├─────────────────────────┤
│ ⚙️  Settings            │ ← List of options
│ 🔔  Notifications       │   Glass cards
│ 🌙  Dark Mode  [Toggle] │
│ 🌍  Language            │
│ 💬  Support             │
│ ⭐  Rate Us             │
│ 🚪  Sign Out            │
└─────────────────────────┘

Features:
- Edit profile: bottom sheet
- Stats: animated counters on scroll-in
- Toggle switches: smooth animation
- Sign out: confirmation dialog
```

### 7. Archive/History
```dart
// Same masonry layout as home
// Filter by date range
// Search within archive
// Restore to active (swipe action)
// Bulk delete selection mode
// Export as PDF option
```

---

## 🎯 Feature Specifications

### Core Features

#### 1. Real-Time Tracking
```dart
// WebSocket connection for live updates
// Push notifications on status change
// Location map with animated marker
// ETA calculation with ML prediction
// Delivery route visualization
```

#### 2. Multi-Carrier Support
```dart
// Auto-detect: DHL, FedEx, UPS, USPS, etc.
// Unified tracking API integration
// Carrier-specific icons and colors
// Compare delivery times
```

#### 3. Smart Notifications
```dart
// Delivery imminent (30 mins before)
// Package delayed alert
// Left at location (with photo)
// Signature required reminder
// Weekly digest of deliveries
```

#### 4. Package Organization
```dart
// Custom tags and categories
// Priority flagging
// Archive completed deliveries
// Search and filter
// Sort by: ETA, Status, Date added
```

#### 5. Sharing & Collaboration
```dart
// Share tracking link
// Family package management
// Gift tracking (hide from recipient)
// Proof of delivery sharing
```

---

## 🛠️ Technical Implementation

### Architecture: Feature-First

```
lib/
├── main.dart
├── core/
│   ├── app_theme.dart (implement design system above)
│   ├── animations/
│   │   ├── page_transitions.dart
│   │   ├── micro_interactions.dart
│   │   ├── loading_animations.dart
│   │   └── spring_curves.dart
│   ├── di/
│   │   └── app_providers.dart
│   ├── navigation/
│   │   ├── routes.dart
│   │   └── global_keys.dart
│   └── constants/
│       ├── colors.dart
│       ├── typography.dart
│       └── spacing.dart
├── features/
│   ├── onboarding/
│   │   ├── pages/
│   │   │   └── onboarding_flow_page.dart
│   │   └── widgets/
│   │       ├── onboarding_step.dart
│   │       └── liquid_swipe_indicator.dart
│   ├── tracking/
│   │   ├── models/
│   │   │   ├── package.dart
│   │   │   ├── tracking_event.dart
│   │   │   └── carrier.dart
│   │   ├── repositories/
│   │   │   ├── package_repository.dart
│   │   │   └── tracking_api_repository.dart
│   │   ├── services/
│   │   │   ├── tracking_service.dart
│   │   │   ├── realtime_service.dart (WebSocket)
│   │   │   └── notification_service.dart
│   │   ├── providers/
│   │   │   ├── package_list_provider.dart
│   │   │   └── package_detail_provider.dart
│   │   ├── pages/
│   │   │   ├── home_dashboard_page.dart
│   │   │   ├── package_details_page.dart
│   │   │   └── add_package_page.dart
│   │   └── widgets/
│   │       ├── package_card.dart (Pinterest-style)
│   │       ├── masonry_grid.dart
│   │       ├── tracking_timeline.dart
│   │       ├── status_chip.dart
│   │       ├── glass_button.dart
│   │       └── animated_map.dart
│   ├── scanner/
│   │   ├── services/
│   │   │   └── barcode_scanner_service.dart
│   │   ├── pages/
│   │   │   └── scanner_page.dart
│   │   └── widgets/
│   │       └── scanner_overlay.dart
│   ├── profile/
│   │   ├── models/
│   │   │   └── user_stats.dart
│   │   ├── pages/
│   │   │   └── profile_page.dart
│   │   └── widgets/
│   │       └── stats_card.dart
│   └── shell/
│       ├── pages/
│       │   └── app_shell.dart (Bottom nav)
│       └── widgets/
│           └── glass_bottom_nav.dart
└── shared/
    └── widgets/
        ├── shimmer_loading.dart
        ├── empty_state.dart
        ├── error_state.dart
        └── bottom_sheet_modal.dart
```

### Package Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
    
  # State Management
  provider: ^6.1.1
  
  # UI & Animations
  flutter_animate: ^4.3.0
  lottie: ^2.7.0
  shimmer: ^3.0.0
  flutter_staggered_grid_view: ^0.7.0
  
  # Networking
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  
  # Barcode Scanning
  mobile_scanner: ^3.5.5
  
  # Local Storage
  hive_flutter: ^1.1.0
  
  # Notifications
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.0
  
  # Maps
  google_maps_flutter: ^2.5.3
  
  # Image Handling
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  
  # Utils
  intl: ^0.18.1
  url_launcher: ^6.2.4
  share_plus: ^7.2.1
  haptic_feedback: ^0.5.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
```

---

## 🎨 Design System Implementation Code

### colors.dart
```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette
  static const primary = Color(0xFF0A1E3D);
  static const primaryLight = Color(0xFF1A2F4D);
  static const primaryDark = Color(0xFF050F1F);

  // Accent Palette
  static const accent = Color(0xFF8B5CF6);
  static const accentLight = Color(0xFFA78BFA);
  static const accentGlow = Color(0xFFC4B5FD);

  // Semantic Colors
  static const success = Color(0xFFFF6B9D);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF06B6D4);

  // Neutrals
  static const neutral100 = Color(0xFFF8FAFC);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);

  // Gradients
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassGradient = LinearGradient(
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const statusGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
  );

  // Status Colors
  static const statusPending = warning;
  static const statusInTransit = info;
  static const statusDelivered = success;
  static const statusDelayed = Color(0xFFF97316);
  static const statusCancelled = neutral700;
}
```

### typography.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        height: 1.1,
      );

  static TextStyle get headline => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get title => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get tracking => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      );
}
```

### spacing.dart
```dart
abstract class AppSpacing {
  static const double micro = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

abstract class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
```

---

## 🎬 Sample Widget: Glass Morphism Package Card

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:core/core/constants/colors.dart';
import 'package:core/core/constants/spacing.dart';
import 'package:core/features/tracking/models/package.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    required this.package,
    required this.onTap,
    super.key,
  });

  final Package package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardRadius,
          child: Stack(
            children: [
              // Background Image
              if (package.imageUrl != null)
                Image.network(
                  package.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),

              // Glass Overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.glassGradient,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Chip
                    _StatusChip(status: package.status),
                    const SizedBox(height: AppSpacing.sm),

                    // Package Name
                    Text(
                      package.name,
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Tracking Number
                    Text(
                      package.trackingNumber,
                      style: AppTypography.tracking.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),

                    // ETA
                    if (package.estimatedDelivery != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'ETA: ${_formatDate(package.estimatedDelivery!)}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return '${diff.inDays} days';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PackageStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: config.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.label,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({String label, IconData icon, Color color, LinearGradient gradient})
      _getStatusConfig(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return (
          label: 'Pending',
          icon: Icons.schedule,
          color: AppColors.warning,
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
          ),
        );
      case PackageStatus.inTransit:
        return (
          label: 'In Transit',
          icon: Icons.local_shipping,
          color: AppColors.info,
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
          ),
        );
      case PackageStatus.delivered:
        return (
          label: 'Delivered',
          icon: Icons.check_circle,
          color: AppColors.success,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFEC4899)],
          ),
        );
      case PackageStatus.delayed:
        return (
          label: 'Delayed',
          icon: Icons.warning,
          color: AppColors.statusDelayed,
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
        );
      case PackageStatus.cancelled:
        return (
          label: 'Cancelled',
          icon: Icons.cancel,
          color: AppColors.neutral700,
          gradient: const LinearGradient(
            colors: [Color(0xFF64748B), Color(0xFF475569)],
          ),
        );
    }
  }
}
```

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Setup project structure per AGENTS.md
- [ ] Implement design system (colors, typography, spacing)
- [ ] Create core animations utilities
- [ ] Build component library (buttons, cards, chips)
- [ ] Setup navigation and routing
- [ ] Implement app shell with bottom navigation

### Phase 2: Core Features (Week 3-4)
- [ ] Build masonry grid package list
- [ ] Implement package details screen
- [ ] Create tracking timeline widget
- [ ] Add package creation flow
- [ ] Integrate barcode scanner
- [ ] Setup local storage (Hive)

### Phase 3: Backend Integration (Week 5-6)
- [ ] Setup API repositories
- [ ] Integrate tracking APIs (multi-carrier)
- [ ] Implement WebSocket real-time updates
- [ ] Add push notifications
- [ ] Create background sync service
- [ ] Handle offline mode

### Phase 4: Polish & Delight (Week 7-8)
- [ ] Add all micro-animations
- [ ] Implement hero transitions
- [ ] Create onboarding flow
- [ ] Add empty/error states
- [ ] Haptic feedback throughout
- [ ] Performance optimization
- [ ] Dark mode refinement
- [ ] Accessibility audit

### Phase 5: Testing & Launch (Week 9-10)
- [ ] Widget testing (80%+ coverage)
- [ ] Integration testing
- [ ] Beta testing with users
- [ ] Performance profiling
- [ ] Bug fixes and polish
- [ ] App Store assets
- [ ] Launch! 🚀

---

## 🎯 Success Metrics

### Performance
- [ ] 60 FPS on all animations
- [ ] < 3s cold start time
- [ ] < 50MB APK size
- [ ] < 100MB RAM usage

### Design
- [ ] Awwwards submission ready
- [ ] 5/5 stars on design reviews
- [ ] Featured on design galleries
- [ ] Social media shareable

### User Experience
- [ ] < 5s to add first package
- [ ] 95%+ task completion rate
- [ ] 4.5+ star app rating
- [ ] 60%+ D7 retention

---

## 💡 Inspiration References

### Design Inspiration
- **Pinterest App** - Masonry layouts, visual hierarchy
- **Stripe Dashboard** - Glass morphism, gradients
- **Linear App** - Smooth animations, keyboard shortcuts
- **Airbnb** - Card design, imagery
- **Revolut** - Status indicators, micro-interactions

### Animation Inspiration
- **Stripe Press** - Page transitions
- **Apple Pay** - Payment confirmation
- **Clubhouse** - Bottom sheets
- **Instagram** - Like animation
- **Telegram** - Message sending

### Color Inspiration
- **Vercel** - Dark mode excellence
- **Figma** - Accent colors
- **Notion** - Neutral sophistication
- **Discord** - Status colors

---

## 🎓 Development Guidelines

### Code Quality
```dart
// ✅ DO: Use const constructors
const Text('Hello', style: TextStyle(fontSize: 16))

// ✅ DO: Extract reusable widgets
class _SectionHeader extends StatelessWidget { ... }

// ✅ DO: Use meaningful names
final estimatedDeliveryDate = package.eta;

// ❌ DON'T: Deep nesting
if (x) { if (y) { if (z) { ... } } }

// ✅ DO: Early returns
if (!isValid) return;
doSomething();

// ✅ DO: Use extension methods
extension on DateTime {
  String get relativeTime => ...
}
```

### Performance Best Practices
```dart
// ListView optimization
ListView.builder(
  itemCount: packages.length,
  itemBuilder: (context, index) {
    final package = packages[index];
    return PackageCard(
      key: ValueKey(package.id), // Stable keys
      package: package,
    );
  },
);

// Image caching
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => ShimmerPlaceholder(),
  memCacheHeight: 400, // Limit cache size
);

// Const constructors
const SizedBox(height: 16)
const Padding(padding: EdgeInsets.all(16))
```

### Animation Performance
```dart
// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ExpensiveAnimatedWidget(),
)

// Limit animation area
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(animation.value, 0),
      child: child, // Child doesn't rebuild
    );
  },
  child: const ExpensiveWidget(),
)
```

---

## 🏁 Final Notes

This prompt is designed to create a **world-class cargo tracking app** that:

1. **Looks stunning** - Award-worthy design that users want to screenshot
2. **Feels premium** - Smooth 60fps animations and delightful micro-interactions
3. **Works flawlessly** - Real-time tracking across all major carriers
4. **Scales beautifully** - Architecture supports growth to millions of users
5. **Delights users** - Every interaction is thoughtful and joyful

**Key Philosophy**: 
> "Every frame matters. Every animation tells a story. Every interaction should spark joy."

Build this app as if it's going into your portfolio. Make it so beautiful that designers ask about your process. Make it so smooth that engineers ask about your architecture. Make it so delightful that users can't help but recommend it.

**Now go build something extraordinary! 🚀✨**

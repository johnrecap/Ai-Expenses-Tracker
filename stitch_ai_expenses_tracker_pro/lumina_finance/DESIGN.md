---
name: Lumina Finance
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3b494c'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6b7a7d'
  outline-variant: '#bac9cc'
  surface-tint: '#006875'
  primary: '#006875'
  on-primary: '#ffffff'
  primary-container: '#00e5ff'
  on-primary-container: '#00626e'
  inverse-primary: '#00daf3'
  secondary: '#b70052'
  on-secondary: '#ffffff'
  secondary-container: '#dd2269'
  on-secondary-container: '#fffbff'
  tertiary: '#6833ea'
  on-tertiary: '#ffffff'
  tertiary-container: '#d6c9ff'
  on-tertiary-container: '#622be5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9cf0ff'
  primary-fixed-dim: '#00daf3'
  on-primary-fixed: '#001f24'
  on-primary-fixed-variant: '#004f58'
  secondary-fixed: '#ffd9df'
  secondary-fixed-dim: '#ffb1c1'
  on-secondary-fixed: '#3f0018'
  on-secondary-fixed-variant: '#8f003f'
  tertiary-fixed: '#e8deff'
  tertiary-fixed-dim: '#cdbdff'
  on-tertiary-fixed: '#20005f'
  on-tertiary-fixed-variant: '#4f00d0'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  arabic-body:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 20px
  card-gutter: 12px
---

## Brand & Style

The design system is centered on **Modern Glassmorphism** and **Soft Precision**. It targets a demographic that values technological sophistication and financial clarity. The UI should evoke a sense of "intelligent calm"—it is high-tech yet approachable, utilizing light-refracting surfaces and fluid motion to guide the user through their financial data.

The aesthetic avoids the "flat" corporate look in favor of depth created through background blurs, subtle inner glows, and vibrant gradients that feel alive. Every interaction should feel like light moving through glass—weightless, transparent, and refined.

## Colors

The palette is anchored by a **"Cool Slate" base** (#F8FAFC) infused with a subtle cyan tint to keep the interface feeling fresh and energetic. 

- **Primary Accent:** An "Electric Cyan" to "Teal" gradient is used for high-priority actions and growth-related data.
- **Secondary Accent:** A "Magenta" to "Violet" gradient is reserved for AI-driven insights, special features, and spending categories that require visual distinction.
- **Surface Colors:** Use translucent white (`rgba(255, 255, 255, 0.7)`) with a `backdrop-filter: blur(20px)` to create the glass effect over the tinted background.

## Typography

Typography prioritizes legibility for financial figures. **Inter** provides a neutral, systematic foundation for Latin characters, while **IBM Plex Sans Arabic** ensures the RTL experience feels equally modern and professional.

For financial numbers, use tabular lining (tnum) font features to ensure columns of figures align perfectly. Headlines should utilize tighter letter-spacing for a premium, editorial feel, while labels use slightly expanded spacing for clarity at small sizes.

## Layout & Spacing

This design system uses a **Fluid Layout** based on a 4px soft grid. On mobile, a 20px side margin is standard for the main container.

- **Stacking:** Use generous vertical breathing room (24px - 32px) between major sections (e.g., Total Balance vs. Transaction List).
- **In-card Spacing:** Maintain a 16px internal padding for standard cards, increasing to 24px for large "Hero" cards.
- **RTL Transition:** Layouts must mirror horizontally for Arabic. Ensure that icons with directional meaning (arrows, progress bars) are flipped, while brand logos and universal symbols (like the AI sparkle) remain constant.

## Elevation & Depth

Depth is conveyed through **Glassmorphism** rather than traditional drop shadows.

- **Layer 0 (Background):** Solid #F8FAFC with linear-gradient background blobs in primary/secondary colors at 10% opacity.
- **Layer 1 (Cards/Containers):** Semi-transparent white with a 1px inner border (white, 40% opacity) to simulate a "beveled edge" of glass. 
- **Layer 2 (Modals/Popovers):** High-diffusion shadows (Blur: 40px, Spread: -10px, Color: rgba(0, 0, 0, 0.05)) combined with a more intense backdrop blur (40px).
- **Interactive Depth:** When pressed, elements should visually "sink" by reducing the shadow spread and increasing the opacity of the fill.

## Shapes

The shape language is smooth and organic. 
- **Cards:** Use a radius of `24px` for large dashboard cards and `18px` for secondary list items.
- **Interactive Elements:** Buttons and inputs are pill-shaped (fully rounded corners) to contrast against the softer rectangular shapes of the layout containers.
- **AI Elements:** Utilize "Squircle" shapes (continuous curvature) for AI-generated insights to differentiate them from standard system data.

## Components

### Buttons & Inputs
- **Primary Button:** Pill-shaped with a horizontal gradient (Electric Cyan to Teal). Text is white with a subtle 1px drop shadow for legibility.
- **Secondary Button:** Soft fill (`rgba(0, 229, 255, 0.1)`) with Cyan text.
- **Inputs:** Pill-shaped, filled with a very light neutral gray (#F1F5F9). On focus, the background turns white with a 1px Cyan glow.

### Navigation
- **Floating Nav:** A glass-morphic bar hovering 16px from the bottom. The center "Plus" button features a secondary gradient (Magenta/Violet) and a soft glow effect that pulses slightly.

### Cards
- **Financial Cards:** No borders. Background is a mix of glass blur and a faint top-to-bottom white gradient.
- **AI Sparkle:** AI-driven cards feature a "Sparkle" icon in the top right and a thin, animating gradient border (1px) that cycles through the secondary palette colors.

### Status Indicators
- **Syncing:** A subtle rotating "glass" ring.
- **Empty States:** Use translucent, abstract 3D shapes rather than flat icons.

### Motion & AI
- **Number Count-up:** All currency values must animate from 0 or the previous value using a `quintOut` easing curve over 800ms.
- **AI Expansion:** When the AI assistant is activated, the panel should expand from the sparkle icon with a "spring" physics animation.
- **Card Slides:** Transaction lists should slide in from the bottom with a staggered delay (20ms per item) for a cascaded feel.
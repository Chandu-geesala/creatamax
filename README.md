
# Creatamax – Service Management Module

A Flutter app built as a machine test assignment for **Creatamax Infotech**.  
Implements a complete Service Management module with API integration.

---

## 📱 Download APK

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://drive.google.com/file/d/10w5JuxDROhk4_rh7OLBZi5gBz3bgzXRl/view?usp=sharing)

---

## ✅ Features Implemented

- **Service List Screen** — View all created services with category, duration, edit & delete options
- **Create Service Form** — Full form with image picker, dropdowns, and validation
- **Category Dropdown** — Fetched dynamically from `/api/categories`
- **Sub-Category Dropdown** — Loads dynamically on category selection via `/api/categories/:id`
- **Booking Calendar** — Date picker with past date blocking + time slot selection (Morning / Afternoon / Evening / Custom)
- **Create Service API** — POST to `/api/providers/services` with full payload
- **Shimmer loading**, **animations**, **error handling**, and **pull-to-refresh**

---

## 🔗 APIs Integrated

| API | Method | Description |
|-----|--------|-------------|
| `/api/categories` | GET | Fetch all categories |
| `/api/categories/:id` | GET | Fetch sub-categories by category |
| `/api/providers/services` | POST | Create a new service |
| `/api/providers/services` | GET | Fetch all services |

**Auth:** Token passed via `Authorization: Bearer <token>` header

---

## ⚠️ Image Upload Note

The Create Service API accepts `"image"` as a field per the assignment spec.  
The app sends the image as **multipart/form-data** (with fallback to JSON).  
However, the server does not process the file or generate a Cloudinary URL —  
it stores the filename as-is. No separate image upload endpoint exists on the server.  
This is a backend limitation, not an app issue.

---

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **http** — API calls
- **cached_network_image** — Image loading
- **image_picker** — Gallery image selection
- **flutter_animate** — Animations
- **shimmer** — Loading skeletons
- **intl** — Date formatting

---

## 🚀 Run Locally

```bash
git clone https://github.com/Chandu-geesala/creatamax.git
cd creatamax
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── api_service.dart       # All API calls
│   └── constants.dart         # Base URL, token, colors
├── models/
│   ├── service_model.dart
│   └── category_model.dart
├── screens/
│   ├── manage_services_screen.dart
│   ├── add_service_screen.dart
│   └── booking_calendar_screen.dart
└── widgets/
    └── animated_service_card.dart
```

---

## 👨‍💻 Developer

**Chandu Geesala**  
[LinkedIn](https://www.linkedin.com/in/chandu-geesala-b64b342bb) • [GitHub](https://github.com/Chandu-geesala/) • [Portfolio](https://chandu-geesala.github.io/resume/)

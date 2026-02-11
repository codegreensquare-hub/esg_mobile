# Flow: Home Screen → Mission Photo Preview (사진 확인)

This document describes how to reach the **Mission Photo Preview** screen (“사진 확인”) from the app’s home screen.

---

## 1. Start at the home screen

The app can show either:

- **Code Green** (top header tab) with the **Home** tab, or
- **Green Square** (top header tab), which is the default on load (`MainTab.greenSquare`).

So “home” is either **Code Green Home** or **Green Square** (e.g. 스토리 tab).

---

## 2. Go to Green Square (if you started on Code Green)

- Use the top header to switch to the **Green Square** tab (그린스퀘어).
- Or from Code Green Home, tap the entry that calls `onTapGreenSquare` (e.g. “Visit Green Square” / 그린스퀘어 방문).

You should now be in **Green Square** with the bottom nav (스토리, 쇼핑몰, 미션 참여, 나의 콕).

---

## 3. Open the mission list

You can reach the mission list in either of these ways:

**A. Bottom nav – 미션 참여**

- Tap the **미션 참여** (Mission participation) item in the Green Square bottom nav.
- This shows `MissionParticipationTab`, which lists **현재 미션** (current missions) and **지난 미션** (past missions).

**B. Green “콕” button**

- From any Green Square tab, tap the floating green **콕** button.
- A bottom sheet opens with the list of current missions.
- Tap a mission in that list.

---

## 4. Open a mission and start participation

- In the mission list, tap one mission.
- **Mission Detail** opens as a full-screen dialog (`MissionDetailDialog`): mission title, description, “이렇게 해 주세요” / “이건 안 돼요”, points, etc.
- (You must be **logged in**; otherwise you get “로그인이 필요한 기능입니다.”)
- Tap the main **participation** button (e.g. “Participate in Mission” or the mission’s `participationButtonText`).
- This calls `MissionParticipationService.instance.startParticipationFlow(context, mission, …)`.

---

## 5. Choose photo source

- A **bottom sheet** appears with two options:
  - **카메라로 촬영** (Take with camera) → `ImageSource.camera`
  - **앨범에서 선택** (Choose from album) → `ImageSource.gallery`
- User picks one; the app then runs `ImagePicker.pickImage(source: …)`.

---

## 6. Pick or take a photo

- User either takes a photo with the camera or selects an image from the gallery.
- If they cancel (no file chosen), the flow stops.
- If they pick a file, the service gets an `XFile` with `file.path`.

---

## 7. Mission Photo Preview screen (“사진 확인”)

- The app **pushes** the **Mission Photo Preview** screen:

  `Navigator.push(MaterialPageRoute(builder: (_) => MissionPhotoPreviewScreen(imagePath: file.path)))`

- User sees:

  - **App bar:** “사진 확인” and a close (X) button.
  - **Body:** The chosen/taken image (or empty if the path is invalid).
  - **Actions:**
    - “이 사진으로 인증할게요” → confirm and continue (pops with `true`).
    - “다시 촬영할래요” → retake (pops with `false`).
  - **Close (X)** → cancel (pops with `false`).

- If the user confirms (`true`), the service continues: upload photo, create participation, then navigates to **Mission Participation Success** and closes the mission detail.

---

## Flow summary (short)

```
Home (Code Green Home or Green Square)
  → Switch to Green Square (if needed)
  → Tap "미션 참여" in bottom nav (or tap green 콕 button and pick a mission)
  → Tap a mission
  → Mission Detail Dialog opens
  → Tap participation button (must be logged in)
  → Choose "카메라로 촬영" or "앨범에서 선택"
  → Take or pick a photo
  → Mission Photo Preview screen ("사진 확인") is shown
  → Tap "이 사진으로 인증할게요" or "다시 촬영할래요" / close
```

---

## Code references

| Step                                     | File / symbol                                                                                                                                 |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Main screen, Green Square tabs           | `lib/presentation/screens/main.screen.dart` – `_buildGreenSquareContent`, `_greenIndex`                                                       |
| Mission list (tab)                       | `lib/presentation/screens/green_square/mission_participation.tab.dart` – `MissionParticipationTab`                                            |
| Mission list (콕 bottom sheet)           | `lib/presentation/screens/main.screen.dart` – `_onTapKnock`                                                                                   |
| Mission detail dialog                    | `lib/presentation/widgets/mission/mission_detail.dialog.dart` – `MissionDetailDialog`                                                         |
| Start participation                      | `MissionDetailDialog` → `MissionParticipationService.instance.startParticipationFlow`                                                         |
| Image source + pick image + push preview | `lib/core/services/database/mission_participation.service.dart` – `startParticipationFlow`, `_chooseImageSource`, `MissionPhotoPreviewScreen` |
| Photo preview UI                         | `lib/presentation/screens/green_square/mission_photo_preview.screen.dart` – `MissionPhotoPreviewScreen`                                       |

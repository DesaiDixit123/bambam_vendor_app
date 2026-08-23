# TODO - Generate Android .aab release

- [x] Inspect Android/Flutter project and signing setup.
- [x] Build initial Android release AAB.
- [x] Update package name from `com.bambam.user` to `com.bambam.vendor` in `android/app/build.gradle.kts`.
- [ ] Update `android/app/google-services.json` to include Firebase client for `com.bambam.vendor`.
- [ ] Rebuild release AAB (`flutter build appbundle --release`).
- [ ] Confirm final AAB path under `build/app/outputs/bundle/release/`.



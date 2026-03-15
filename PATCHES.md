# Local patches for ZSWatch

This directory vendors `fllama` into the repository so iOS fixes live in source control instead of the pub cache.

## Why this fork exists

The app uses both `fllama` and `whisper_ggml_plus` on iOS. Both dependencies vendor `ggml`/`llama` headers, which caused CocoaPods/Xcode header resolution conflicts during iOS device builds.

## Local changes

1. `src/llava.h`
   - Use explicit platform-specific relative includes for iOS/macOS `ggml` and `llama` headers.
2. `src/clip.cpp`
   - Use explicit platform-specific relative includes for iOS/macOS `ggml*` and `gguf` headers.
3. `ios/llama.cpp/include/llama.h`
   - Use explicit relative includes for `ggml` headers.
4. `ios/llama.cpp/common/log.h`
   - Use explicit relative include for `ggml.h`.
5. `ios/fllama.podspec`
   - Set iOS minimum deployment target to 14.0.
   - Disable Xcode header maps for the `fllama` pod target to keep `ggml` headers isolated.
6. Force CPU-only inference at runtime.
   - `src/fllama.cpp`: Always set `n_gpu_layers = 0` (removed simulator conditional and `llama_supports_gpu_offload()` checks). Metal is still compiled in but never used.
   - Deleted `ios/default.metallib` (pre-compiled Metal kernels — Metal shaders are now embedded in the library via `GGML_METAL_EMBED_LIBRARY`).

## Maintenance

- Prefer rebasing these changes onto upstream `fllama` updates.
- If these fixes are accepted upstream, switch `zswatch_app/pubspec.yaml` back to the upstream dependency.

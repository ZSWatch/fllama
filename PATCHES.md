# Local patches for ZSWatch

ZSWatch fork of [Telosnex/fllama](https://github.com/Telosnex/fllama), rebased
onto upstream `main` (`8969049d`, Oct 2026). The vendored llama.cpp there has
the `gemma4` architecture.

Upstream now builds the native library with a Dart build hook
(`hook/build.dart`, native assets) instead of CocoaPods/Gradle. Our patches
change the sources, so the hook never matches upstream's prebuilt release and
always builds from source.

## Local changes

1. CPU-only inference on iOS (the app runs inference in the background, where
   Metal work is not allowed).
   - `hook/build.dart`: `GGML_METAL` is off for iOS devices too.
   - `src/fllama.cpp`: `n_gpu_layers = 0` on `TARGET_OS_IPHONE`.
   - `hook/build.dart`: `GGML_CPU_ARM_ARCH=armv8.4-a+fp16` on iOS arm64, so the
     CPU kernels use dotprod/fp16 (A13 and newer).
   - `hook/build.dart`: `DEPLOYMENT_TARGET=13.0`; Flutter 3.38 passes iOS 12,
     which lacks `std::filesystem`.
2. Android: `src/fllama.cpp` raises the inference thread priority and pins it
   to the big cores before the model loads; later threads inherit both.
3. One server slot on iOS and Android (`n_parallel = 1`, `src/fllama.cpp`).
   Upstream uses 4 slots, and slots split `n_ctx`: a 3072 context would give
   each request only 768 tokens.
4. `numThreads` on `OpenAiRequest` (`lib/misc/openai.dart`,
   `lib/fllama_universal.dart`); upstream always used 2 threads for chat.
5. OpenAI sampling penalties (`src/fllama.cpp`): `presence_penalty`,
   `frequency_penalty` and `repeat_penalty` come from the request JSON like in
   llama-server. Upstream used `presence_penalty` as the repeat penalty, so
   the app's presence penalty of 2.0 became repeat penalty 2.0.

## Dropped with the rebase

- Header include fixes, iOS 14 podspec and header maps off: fllama is no longer
  a pod, so its ggml headers cannot clash with `whisper_ggml_plus`.
- `enable_thinking`: upstream has it.
- Android shared CPU backend variants (`GGML_CPU_ALL_VARIANTS`): upstream links
  one static library with a `armv8.2-a+dotprod` baseline.
- Model cache timeout: upstream already keeps an idle model for 120 s.

## Maintenance

- Rebase these changes onto upstream `fllama` updates.

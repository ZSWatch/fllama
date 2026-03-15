#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fllama.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fllama'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.dependency 'FlutterMacOS'
  s.swift_version = '5.0'

  s.source           = { :path => '.' }
  
  # Classes contains only the wrapper fllama.cpp that includes ../src/*.cpp files
  s.source_files = 'Classes/**/*'
  
  # Required frameworks:
  # - Foundation: Core requirement
  # - Metal/MetalKit: Required by ggml-metal (compiled in but n_gpu_layers=0 at runtime)
  # - Accelerate: Required for vDSP functions in ggml-cpu optimizations
  s.frameworks = 'Foundation', 'Metal', 'MetalKit', 'Accelerate'
  s.platform = :osx, '10.15'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Header paths for llama.cpp includes - the source code uses paths like:
    # - "llama.h" (in include/)
    # - "ggml.h" (in ggml/include/)  
    # - <nlohmann/json.hpp> (in vendor/)
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/llama.cpp/include $(PODS_TARGET_SRCROOT)/llama.cpp/ggml/include $(PODS_TARGET_SRCROOT)/llama.cpp/vendor',
    # C++17 required for std::scoped_lock, CTAD, and other modern features in vendor/minja/
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'GGML_USE_METAL=1 GGML_METAL_EMBED_LIBRARY=1',
    # Link the libraries directly using full paths (they'll be built by script phase)
    'OTHER_LDFLAGS' => '-L$(PODS_TARGET_SRCROOT)/libs -lllama -lggml -lggml-base -lggml-cpu -lggml-blas -lggml-metal -lcommon',
  }
  
  # Build llama.cpp during Xcode compilation (not during pod install!)
  # This provides proper progress feedback and caching
  s.script_phases = [
    {
      :name => 'Build llama.cpp',
      :script => 'cd "${PODS_TARGET_SRCROOT}" && bash build-llama-macos.sh',
      :execution_position => :before_compile,
      :show_env_vars_in_log => false
    }
  ]
end
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint agora_rtc_engine.podspec` to validate before publishing.
#
require "yaml"
require "ostruct"
project = OpenStruct.new YAML.load_file("../pubspec.yaml")

Pod::Spec.new do |s|
  s.name             = project.name
  s.version          = project.version
  s.summary          = 'A new flutter plugin project.'
  s.description      = project.description
  s.homepage         = 'https://github.com/AgoraIO/Flutter-SDK'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Agora' => 'developer@agora.io' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{h,mm,m,swift}'
  s.dependency       'Flutter'
  s.dependency       'AgoraRtcEngine_iOS/RtcBasic', '3.7.0.3'
  s.dependency       'AgoraIrisRTC_iOS', '3.7.0.3'
  s.platform         = :ios, '9.0'
  s.swift_version    = '5.0'
  s.libraries        = 'stdc++'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'ENABLE_BITCODE' => 'NO'          # <-- Disable bitcode here
  }

  s.script_phases = [{
    :name => 'AgoraStripBitcode',
    :execution_position => :before_compile,
    :shell_path => '/bin/sh',
    :script => %{
set -euo pipefail
if ! command -v xcrun >/dev/null 2>&1; then
  exit 0
fi
BITCODE_STRIP="$(xcrun --find bitcode_strip || true)"
if [ -z "${BITCODE_STRIP}" ]; then
  exit 0
fi
strip_xc_dir() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    return 0
  fi
  find "$dir" -type d -name "*.xcframework" | while read -r xc; do
    find "$xc" -type d -name "ios-*" | while read -r plat; do
      find "$plat" -type d -name "*.framework" | while read -r fw; do
        name="$(basename "$fw" .framework)"
        bin="$fw/$name"
        if [ -f "$bin" ]; then
          "$BITCODE_STRIP" -r "$bin" -o "$bin" || true
        fi
      done
    done
  done
}
strip_xc_dir "$PODS_ROOT/AgoraRtcEngine_iOS"
strip_xc_dir "$PODS_ROOT/AgoraIrisRTC_iOS"
}
  }]
end
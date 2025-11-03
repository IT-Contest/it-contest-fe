#!/bin/sh

# Xcode Cloud용 Flutter 빌드 스크립트
# Archive 전에 Flutter 프로젝트를 빌드하여 필요한 파일들을 생성합니다.

set -e

echo "=========================================="
echo "Flutter 빌드 시작"
echo "=========================================="

# Flutter가 설치되어 있는지 확인
if ! command -v flutter &> /dev/null
then
    echo "Flutter SDK를 설치합니다..."

    # Flutter SDK 다운로드 및 설치
    cd $HOME
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable
    export PATH="$PATH:$HOME/flutter/bin"

    # Flutter 사전 다운로드
    flutter precache --ios
fi

# 프로젝트 루트로 이동
cd $CI_WORKSPACE

# Flutter 버전 확인
flutter --version

# Flutter 의존성 설치
echo "Flutter 의존성 설치 중..."
flutter pub get

# iOS 빌드 (코드 생성 및 Generated.xcconfig 생성)
echo "Flutter iOS 빌드 실행 중..."
flutter build ios --release --no-codesign

echo "=========================================="
echo "Flutter 빌드 완료"
echo "=========================================="

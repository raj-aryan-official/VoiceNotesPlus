#!/bin/bash
set -e

echo "Installing Flutter dependencies..."
flutter pub get

echo "Building Flutter web app..."
flutter build web --release

echo "Build completed successfully!"



#!/bin/bash

echo "🚀 Building Flutter web app..."
flutter build web --release

echo "📦 Preparing for Vercel deployment..."
cd build/web

echo "✅ Build complete! Ready to deploy."
echo ""
echo "To deploy to Vercel, run:"
echo "  vercel --prod"
echo ""
echo "Or use:"
echo "  vercel deploy --prod"



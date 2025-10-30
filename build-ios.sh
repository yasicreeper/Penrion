#!/bin/bash
# Build script for iOS IPA (for sideloading/jailbroken devices)
# This builds an unsigned IPA that can be signed with your own certificate

set -e

echo "🍎 Building Penrion OSU! Tablet for iOS (IPA)"
echo "============================================="

# Configuration
PROJECT_DIR="ios-app/OsuTablet"
PROJECT_NAME="OsuTablet"
SCHEME_NAME="OsuTablet"
BUILD_DIR="build"
OUTPUT_DIR="release/ios"
IPA_NAME="Penrion-OsuTablet.ipa"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}📋 Prerequisites Check${NC}"
echo "========================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗ Error: This script must be run on macOS${NC}"
    echo "  Building iOS apps requires Xcode on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗ Error: Xcode is not installed${NC}"
    echo "  Install Xcode from the Mac App Store"
    exit 1
fi

echo -e "${GREEN}✓ macOS detected${NC}"
echo -e "${GREEN}✓ Xcode installed${NC}"

# Get Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${GREEN}  $XCODE_VERSION${NC}"

echo ""
echo -e "${CYAN}🧹 Cleaning Previous Builds${NC}"
echo "========================================"

# Clean previous builds
cd "$PROJECT_DIR"
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME_NAME" -configuration Release

# Remove old build artifacts
rm -rf "$BUILD_DIR"
rm -rf "../../$OUTPUT_DIR"

echo -e "${GREEN}✓ Cleaned successfully${NC}"

echo ""
echo -e "${CYAN}🔨 Building iOS App${NC}"
echo "========================================"
echo "This may take 2-5 minutes..."
echo ""

# Build the archive
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$BUILD_DIR/${PROJECT_NAME}.xcarchive" \
    -sdk iphoneos \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    AD_HOC_CODE_SIGNING_ALLOWED=YES

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Archive created successfully${NC}"

echo ""
echo -e "${CYAN}📦 Creating IPA Package${NC}"
echo "========================================"

# Create output directory
mkdir -p "../../$OUTPUT_DIR"

# Create Payload directory
PAYLOAD_DIR="$BUILD_DIR/Payload"
mkdir -p "$PAYLOAD_DIR"

# Copy .app to Payload
cp -r "$BUILD_DIR/${PROJECT_NAME}.xcarchive/Products/Applications/${PROJECT_NAME}.app" "$PAYLOAD_DIR/"

# Create IPA (it's just a zip file)
cd "$BUILD_DIR"
zip -r "../../../$OUTPUT_DIR/$IPA_NAME" Payload

cd ../../../

echo -e "${GREEN}✓ IPA created successfully${NC}"

# Get IPA size
IPA_SIZE=$(du -h "$OUTPUT_DIR/$IPA_NAME" | cut -f1)

echo ""
echo -e "${CYAN}📊 Build Summary${NC}"
echo "========================================"
echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""
echo "📦 IPA Location: $OUTPUT_DIR/$IPA_NAME"
echo "📏 IPA Size: $IPA_SIZE"
echo ""

echo -e "${YELLOW}📱 Installation Options:${NC}"
echo ""
echo "1️⃣  ${CYAN}Sideload with AltStore/SideStore:${NC}"
echo "   • Install AltStore/SideStore on your iPad"
echo "   • Add IPA through the app"
echo "   • No jailbreak required (7-day signing)"
echo ""
echo "2️⃣  ${CYAN}Install with Cydia Impactor:${NC}"
echo "   • Download Cydia Impactor"
echo "   • Drag IPA to Impactor"
echo "   • Enter Apple ID credentials"
echo ""
echo "3️⃣  ${CYAN}Install on Jailbroken Device:${NC}"
echo "   • Use Filza or similar file manager"
echo "   • Copy IPA to device"
echo "   • Install with AppSync Unified"
echo ""
echo "4️⃣  ${CYAN}Sign with your own certificate:${NC}"
echo "   • Use ios-app-signer or similar tool"
echo "   • Sign with your Developer/Enterprise cert"
echo "   • Install via Xcode or iTunes"
echo ""
echo "5️⃣  ${CYAN}Install via Xcode (Requires Mac):${NC}"
echo "   • Connect iPad to Mac"
echo "   • Open Xcode > Window > Devices and Simulators"
echo "   • Drag IPA onto your device"
echo ""

echo -e "${YELLOW}⚠️  Note:${NC}"
echo "   This IPA is unsigned and requires signing before installation"
echo "   on non-jailbroken devices. Jailbroken devices with AppSync"
echo "   can install it directly."
echo ""

echo -e "${GREEN}🎉 Done!${NC}"

# Local Development Testing Checklist

## 1. Google Artifact Registry Setup [ ]
- [x] Configure Docker to use Google Artifact Registry authentication
- [x] Create repository in Google Artifact Registry
- [x] Verify access to repository

## 2. Build and Push Images [ ]
- [x] Build waypoint (frontend) image
- [x] Build dockyard (backend) image
- [x] Build dockmaster (auth) image
- [x] Tag all images appropriately
- [x] Push images to Google Artifact Registry
- [x] Verify images in registry

## 3. Prebuilt Images Test [ ]
- [ ] Configure environment for prebuilt images
- [ ] Pull images from Google Artifact Registry
- [ ] Run composition with prebuilt images
- [ ] Verify all services are working

## 4. Local Image Building Test [ ]
- [ ] Test waypoint local build
- [ ] Test dockyard local build
- [ ] Test dockmaster local build
- [ ] Test all services together with local builds

## 5. Source-Mounted Development Test [ ]
- [ ] Configure environment for source mounting
- [ ] Clone all required repositories
- [ ] Set up development keys
- [ ] Run composition with mounted source code
- [ ] Verify live reload functionality

## Progress Log

### Built separate images to test local deploy

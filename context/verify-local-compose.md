# Local Development Testing Checklist

## 1. Google Artifact Registry Setup [ ]
- [ ] Configure Docker to use Google Artifact Registry authentication
- [ ] Create repository in Google Artifact Registry
- [ ] Verify access to repository

## 2. Build and Push Images [ ]
- [ ] Build waypoint (frontend) image
- [ ] Build dockyard (backend) image
- [ ] Build dockmaster (auth) image
- [ ] Tag all images appropriately
- [ ] Push images to Google Artifact Registry
- [ ] Verify images in registry

## 3. Local Image Building Test [ ]
- [ ] Test waypoint local build
- [ ] Test dockyard local build
- [ ] Test dockmaster local build
- [ ] Test all services together with local builds

## 4. Prebuilt Images Test [ ]
- [ ] Configure environment for prebuilt images
- [ ] Pull images from Google Artifact Registry
- [ ] Run composition with prebuilt images
- [ ] Verify all services are working

## 5. Source-Mounted Development Test [ ]
- [ ] Configure environment for source mounting
- [ ] Clone all required repositories
- [ ] Set up development keys
- [ ] Run composition with mounted source code
- [ ] Verify live reload functionality

## Progress Log

### Current Step: None
Let's begin with Google Artifact Registry setup. Would you like to proceed with the first step?

Required Information:
1. Google Cloud project ID
2. Desired repository region
3. Local development machine operating system
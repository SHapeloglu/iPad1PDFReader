ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1PDFReader

iPad1PDFReader_FILES = \
	main.m \
	AppDelegate.m \
	PDFLibraryViewController.m \
	PDFReaderViewController.m \
	TextReaderViewController.m \
	PDFPageView.m \
	BookmarkStore.m \
	RecentStore.m \
	AppearanceStore.m \
	AnnotationStore.m \
	AnnotationOverlayView.m \
	DocumentNavigatorViewController.m \
	ThumbnailViewController.m \
	OutlineViewController.m \
	PDFOutlineParser.m \
	PDFTextExtractor.m \
	SearchViewController.m \
	ReflowViewController.m \
	URLImportViewController.m \
	NetworkCenterViewController.m \
	WebDAVClient.m \
	PageManager.m \
	PageManagerViewController.m \
	PDFAnnotationExporter.m \
	MemoryBudget.m

iPad1PDFReader_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CFNetwork
iPad1PDFReader_CFLAGS = -fno-objc-arc -Wall
iPad1PDFReader_RESOURCE_DIRS = Resources
iPad1PDFReader_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk

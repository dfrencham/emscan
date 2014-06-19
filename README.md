emscan - EM1000 OCR Meter Reader
================================

Overview
---------

A collection of Perl scripts to OCR a power meter via a webcam, and upload to PVOutput. These scripts are in use with the EM1000 model power meter, but should work with other meters (as long as they have a sensible LCD display).

These scripts currently run on a Raspberry Pi (running Rasbian), but should work on almost any Linux distribution.

Setup Instructions
==================

[Full Setup Instructions Here](blob/master/SETUP.md)


###What it Does

- takes a batch of photos at set intervals (20 photos, 1 second apart for example)
- OCRs each photo until it has aquired your power meter import and export figures. Export is determined by looking for a leading minus sign.
- Uploads to PVOutput

###What it Doesn't Do

- Get data directly from your solar inverter. There are already plenty of apps out there to do this

###Software Dependencies

- Perl
- [SSOCR](http://www.unix-ag.uni-kl.de/~auerswal/ssocr/) used for OCR
- UVCCapture - takes photos with your webcam, install with your favourite package manager

###Hardware Dependencies

- A webcam that works with a Raspberry Pi (I'm using the cheapest Logitech model I could find)
- A power meter

See it in action
----------------

- [OCR Solar Meter Reader - Part 1](http://diydeveloper.io/tech/2014/05/19/ocr-solar-meter-reader-part1/)
- [OCR Solar Meter Reader - Part 2](http://diydeveloper.io/tech/2014/05/19/ocr-solar-meter-reader-part2/)


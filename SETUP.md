Setup
=====

1. Install SSOCR
2. Install UVCCapture
3. Download and unzip the release to a folder
4. Edit the emscan.cfg config file with appropriate values. Refer to the "Finding the X/Y Co-ordinates" section. Ensure all paths are correct.
5. Add the cron entries.
6. Set permissions on the .pl scripts: chmod 755 *.pl

Finding the X/Y Co-ordinates
----------------------------

1. Take a single photo with UVCCapture. Ensure you have a photo with the leading minus.
2. Open in a image editor that can display X/Y coords (such as GIMP, Photoshop, or Paint.Net).
3. Determine the X,Y starting point. You should and exclude the bezel, and start AFTER the minus. Calculate the height and width. You will need 4 figures: x y width height.
4. Update the OCRCmd configuration setting with these figures.
5. Repeat for the minus sign only, and update the OCRMinusCmd setting.

Cron
----

Add the following 2 tasks to your cron tab:

| Time         | Command           | Description    |
| :------------|:------------------| :-----:|
| 45 23 * * *  | /tmp/emscan/emscanReadMeter.pl>> /tmp/emscan_photo.log | Runs the photo script at 11:45pm every day. |
| 59 23 * * *  | /tmp/emscan/emscanPVUpload.pl>> /tmp/emscan_upload.log  | Uploads the result to PVOutput at 11:59 every day |

Update the paths to match your emscan install location.
 

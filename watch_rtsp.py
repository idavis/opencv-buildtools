import cv2

import os
os.environ["OPENCV_FFMPEG_CAPTURE_OPTIONS"] = "rtsp_transport;udp"

cap = cv2.VideoCapture("rtsp://example.com:8554/default", cv2.CAP_FFMPEG)

while(True):
    ret, frame = cap.read()
    if ret == True:
        cv2.imshow('frame', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

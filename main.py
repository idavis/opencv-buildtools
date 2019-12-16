import cv2

def main(camera_id):
    cap = cv2.VideoCapture(0)

    while(True):
        ret, frame = cap.read()
        if ret == True:
            cv2.imshow('frame', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

def mainrtsp(camera_id):
    import os
    os.environ["OPENCV_FFMPEG_CAPTURE_OPTIONS"] = "rtsp_transport;udp"

    cap = cv2.VideoCapture(camera_id, cv2.CAP_FFMPEG)

    while(True):
        ret, frame = cap.read()
        if ret == True:
            cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    mainasync(0)
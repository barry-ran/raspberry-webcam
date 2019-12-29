#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  	appCamPanTilt.py
#  	Streaming video with Flask based on tutorial ==> https://blog.miguelgrinberg.com/post/video-streaming-with-flask
# 	PiCam Local Web Server with PanTilt position Control
#
#   MJRoBot.org 30Jan18

import os
from time import sleep
from flask import Flask, render_template, request, Response
from ../pwmcontrol import pwmcontrol

# Raspberry Pi camera module (requires picamera package from Miguel Grinberg)
from camera_pi import Camera

app = Flask(__name__)

# Global variables definition and initialization
global panServoAngle
global tiltServoAngle
panServoAngle = 90
tiltServoAngle = 90

panPin = 27
tiltPin = 17

@app.route('/')
def index():
    """Video streaming home page."""
 
    templateData = {
      'panServoAngle'	: panServoAngle,
      'tiltServoAngle'	: tiltServoAngle
	}
    return render_template('index.html', **templateData)


def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')


@app.route('/video_feed')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')



@app.route('/', methods=['POST'])
def my_form_post():
	global panServoAngle
	global tiltServoAngle

	panNewAngle = int(request.form['panServoAngle'])
	if (panNewAngle != panServoAngle):
		panServoAngle = panNewAngle
		os.system("python3 angleServoCtrl.py " + str(panPin) + " " + str(panServoAngle))

	tiltNewAngle = int(request.form['tiltServoAngle'])
	if (tiltNewAngle != tiltServoAngle):
		tiltServoAngle = tiltNewAngle
		os.system("python3 angleServoCtrl.py " + str(tiltPin) + " " + str(tiltServoAngle))

	templateData = {
      'panServoAngle'	: panServoAngle,
      'tiltServoAngle'	: tiltServoAngle
	}
	return render_template('index.html', **templateData)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port =80, debug=True, threaded=True)


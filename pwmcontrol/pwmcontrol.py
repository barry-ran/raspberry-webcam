from __future__ import division
import Adafruit_PCA9685

 #输入通道与角度。即可选通并使该通道的舵机转动到相应的角度(0-180)
class PWMControl(object):

	def __init__(self, hChannel, vChannel):
		# Initialise the PCA9685 using the default address (0x40).
        self.pwm = Adafruit_PCA9685.PCA9685()
		# Set frequency to 50hz, good for servos.
		self.pwm.set_pwm_freq(50)
		self.hChannel = hChannel
		self.vChannel = vChannel
		self.reset()

	def up(self, internal = 1):
		self.curVAngle = self.curVAngle + internal
		self.__check_angle_range()
		self.__set_servo_angle(self.vChannel, self.curVAngle)

	def down(self, internal = 1):
		self.curVAngle = self.curVAngle - internal
		self.__check_angle_range()
		self.__set_servo_angle(self.vChannel, self.curVAngle)

	def left(self, internal = 1):
		self.curHAngle = self.curHAngle - internal
		self.__check_angle_range()
		self.__set_servo_angle(self.hChannel, self.curHAngle)

	def right(self, internal = 1):
		self.curHAngle = self.curHAngle + internal
		self.__check_angle_range()
		self.__set_servo_angle(self.hChannel, self.curHAngle)

	def reset(self):
		self.curHAngle = 90
		self.curVAngle = 90
		self.__set_servo_angle(self.hChannel, self.curHAngle)
		self.__set_servo_angle(self.vChannel, self.curVAngle)

	def __check_angle_range():
		self.curVAngle = self.curVAngle > 180 ? 180 : self.curVAngle
		self.curVAngle = self.curVAngle < 0 ? 0 : self.curVAngle
		self.curHAngle = self.curHAngle > 180 ? 180 : self.curHAngle
		self.curHAngle = self.curHAngle < 0 ? 0 : self.curHAngle

	def __set_servo_angle(self, channel, angle):
		#2^12精度  角度转换成数值  
		#angle输入的角度值(0--180)  
		#pulsewidth高电平占空时间(0.5ms--2.5ms)   
		#/1000将us转换为ms  #20ms时基脉冲(50HZ)
		#pulse_width=((angle*11)+500)/1000;  
		#将角度转化为500(0.5)<-->2480(2.5)的脉宽值(高电平时间)   angle=180时  pulse_width=2480us(2.5ms)
		#date/4096=pulse_width/20 ->有上pulse_width的计算结果得date=4096*( ((angle*11)+500)/1000 )/20   -->int date=4096((angle*11)+500)/20000;
    	#输入角度转换成12^精度的数值
    	#进行四舍五入运算 date=int(4096*((angle*11)+500)/(20000)+0.5)
		date=int(4096*((angle*11)+500)/20000)					
		self.pwm.set_pwm(channel, 0, date)

if __name__ == "__main__":
	pwm = PWMControl(0, 15)
	pwm.up(45)
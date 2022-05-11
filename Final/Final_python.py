# -*- coding: utf-8 -*-
"""
Created on Sun May  8 18:53:32 2022

@author: meganpc2
"""

# import various libraries necessery to run your Python code
import sys                      # system related library
import time                     # time related library
ok_loc = 'C:\Program Files\Opal Kelly\FrontPanelUSB\API\Python\3.6\x64'
sys.path.append(ok_loc)         # add the path of the OK library
import ok                       # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt
import cv2

#%% 
# Define FrontPanel device variable, open USB communication and load the bit file in the FPGA
dev = ok.okCFrontPanel();                                                     # define a device for FrontPanel communication
# FrontPanel MUST BE CLOSED FOR THIS STEP TO SUCCEED!!!
SerialStatus=dev.OpenBySerial("");      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\Documents\ECE437\Lab9\TestingTopLevel.bit"); # Configure the FPGA with this bit file
print(ConfigStatus)

# Check if FrontPanel is initialized correctly and if the bit file is loaded. Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")


#%% 
# Need to set SPI settings and start with FSM matching CMV300 data sheet
# SPI SETTINGS:
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board

zeros8 = '00000000'
read_bit = '00000000'
write_bit = '00000001'

registers = {
            'raddr3':'0000011',
            'radar4':'0000100',
            '39':str(format(39,'07b')),
            '42':str(format(42, '07b')),
            '43':str(format(43,'07b')),
            '45':str(format(45,'07b')),
            '55':str(format(55,'07b')),
            '57':str(format(57,'07b')),
            '58':str(format(58,'07b')),
            '59':str(format(59,'07b')),
            '60':str(format(60,'07b')),
            '68':str(format(68,'07b')),
            '69':str(format(69,'07b')),
            '80':str(format(80,'07b')),
            '83':str(format(83,'07b')),
            '97':str(format(97,'07b')),
            '98':str(format(98,'07b')),
            '100':str(format(100,'07b')),
            '101':str(format(101,'07b')),
            '102':str(format(102,'07b')),
            '103':str(format(103,'07b')),
            '106':str(format(106,'07b')),
            '107':str(format(107,'07b')),
            '108':str(format(108,'07b')),
            '109':str(format(109,'07b')),
            '110':str(format(110,'07b')),
            '117':str(format(117,'07b'))	     
	    }
read_write = {
            'raddr3_w':'00000011001010010000000000000001',
            'raddr4_w':'00000100100010010000000000000001',
            'raddr3_r':'00000011001010010000000000000000',
            'raddr4_r':'00000100001010010000000000000000',
            '39_w':"0" + registers['39'] + str(format(1,'08b')) + zeros8 + write_bit,
            '39_r':"0" + registers['39'] + str(format(1,'08b')) + zeros8 + read_bit,
            '42_w':"0" + registers['42'] + str(format(0,'08b')) + zeros8 + write_bit, #originally 232 LSB
            '42_r':"0" + registers['42'] + str(format(0,'08b')) + zeros8 + read_bit, # OG 0
            '43_w':"0" + registers['43'] + str(format(10,'08b')) + zeros8 + write_bit, #originally 1 MSB
            '43_r':"0" + registers['43'] + str(format(10,'08b')) + zeros8 + read_bit, # OG 10
            '45_w':"0" + registers['45'] + str(format(0,'08b')) + zeros8 + write_bit, #originally 232
            '45_r':"0" + registers['45'] + str(format(0,'08b')) + zeros8 + read_bit,
            '46_w':"0" + registers['43'] + str(format(10,'08b')) + zeros8 + write_bit,
            '46_r':"0" + registers['43'] + str(format(10,'08b')) + zeros8 + read_bit,
            '55_w':"0" + registers['55'] + str(format(1,'08b')) + zeros8 + write_bit,
            '55_r':"0" + registers['55'] + str(format(1,'08b')) + zeros8 + read_bit,
            '57_w':"0" + registers['57'] + str(format(3,'08b')) + zeros8 + write_bit,
            '57_r':"0" + registers['57'] + str(format(3,'08b')) + zeros8 + read_bit,
            '58_w':"0" + registers['58'] + str(format(44,'08b')) + zeros8 + write_bit,
            '58_r':"0" + registers['58'] + str(format(44,'08b')) + zeros8 + read_bit,
            '59_w':"0" + registers['59'] + str(format(240,'08b')) + zeros8 + write_bit,
            '59_r':"0" + registers['59'] + str(format(240,'08b')) + zeros8 + read_bit,
            '60_w':"0" + registers['60'] + str(format(10,'08b')) + zeros8 + write_bit,
            '60_r':"0" + registers['60'] + str(format(10,'08b')) + zeros8 + read_bit,
            '68_w':"0" + registers['68'] + str(format(2,'08b')) + zeros8 + write_bit,
            '68_r':"0" + registers['68'] + str(format(2,'08b')) + zeros8 + read_bit,
            '69_w':"0" + registers['69'] + str(format(9,'08b')) + zeros8 + write_bit,
            '69_r':"0" + registers['69'] + str(format(9,'08b')) + zeros8 + read_bit,
            '80_w':"0" + registers['80'] + str(format(2,'08b')) + zeros8 + write_bit,
            '80_r':"0" + registers['80'] + str(format(2,'08b')) + zeros8 + read_bit,
            '83_w':"0" + registers['83'] + str(format(155,'08b')) + zeros8 + write_bit, #155 from 251, clk speed 38MHz
            '83_r':"0" + registers['83'] + str(format(155,'08b')) + zeros8 + read_bit,
            '97_w':"0" + registers['97'] + str(format(240,'08b')) + zeros8 + write_bit,
            '97_r':"0" + registers['97'] + str(format(240,'08b')) + zeros8 + read_bit,
            '98_w':"0" + registers['98'] + str(format(10,'08b')) + zeros8 + write_bit,
            '98_r':"0" + registers['98'] + str(format(10,'08b')) + zeros8 + read_bit,
            '100_w':"0" + registers['100'] + str(format(112,'08b')) + zeros8 + write_bit,
            '100_r':"0" + registers['100'] + str(format(112,'08b')) + zeros8 + read_bit,
            '101_w':"0" + registers['101'] + str(format(98,'08b')) + zeros8 + write_bit,
            '101_r':"0" + registers['101'] + str(format(98,'08b')) + zeros8 + read_bit,
            '102_w':"0" + registers['102'] + str(format(34,'08b')) + zeros8 + write_bit,
            '102_r':"0" + registers['102'] + str(format(34,'08b')) + zeros8 + read_bit,
            '103_w':"0" + registers['103'] + str(format(64,'08b')) + zeros8 + write_bit,
            '103_r':"0" + registers['103'] + str(format(64,'08b')) + zeros8 + read_bit,
            '106_w':"0" + registers['106'] + str(format(94,'08b')) + zeros8 + write_bit,
            '106_r':"0" + registers['106'] + str(format(94,'08b')) + zeros8 + read_bit,
            '107_w':"0" + registers['107'] + str(format(110,'08b')) + zeros8 + write_bit,
            '107_r':"0" + registers['107'] + str(format(110,'08b')) + zeros8 + read_bit,
            '108_w':"0" + registers['108'] + str(format(91,'08b')) + zeros8 + write_bit,
            '108_r':"0" + registers['108'] + str(format(91,'08b')) + zeros8 + read_bit,
            '109_w':"0" + registers['109'] + str(format(82,'08b')) + zeros8 + write_bit,
            '109_r':"0" + registers['109'] + str(format(82,'08b')) + zeros8 + read_bit,
            '110_w':"0" + registers['110'] + str(format(80,'08b')) + zeros8 + write_bit,
            '110_r':"0" + registers['110'] + str(format(80,'08b')) + zeros8 + read_bit,
            '117_w':"0" + registers['117'] + str(format(91,'08b')) + zeros8 + write_bit,
            '117_r':"0" + registers['117'] + str(format(91,'08b')) + zeros8 + read_bit 
}


def Write_Grab_FSM(rw):
    PC_control = 1				
    PC_Data=read_write[rw]																# turn FSM on

    # send read/write to PC and grab data into dev
    dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
    dev.SetWireInValue(0x01, int(PC_Data,2))
    dev. UpdateWireIns()                                # Send wirein value to FSM 
    time.sleep(0.001)	
    PC_control = 0																			# turn FSM off
    dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
    dev. UpdateWireIns()                                # Send wirein value to FSM 
	

#%% Ask for system reset    ##
sys_reset_wire = 0x03
dev.SetWireInValue(sys_reset_wire, 0); # trigger sys to 0 (off for restart)
dev.SetWireInValue(0x04, 0); # make sure not grabbing an image
dev.UpdateWireIns();  

time.sleep(.001)                       # make sure sys is reset by waiting for stable signal
dev.SetWireInValue(sys_reset_wire, 1); # Turn sys back on
dev.UpdateWireIns();  

time.sleep(.001)  

#%%

# Send SPI settings to FSM
try:                                                       
    reg_key = read_write.keys()
    for i, key in enumerate(reg_key):
        Write_Grab_FSM(key) 
        if key[-1] !='w':
            dev.UpdateWireOuts()                                
            output = dev.GetWireOutValue(0x21)                  
            print('regaddr:', key[:-2] +'\t'+str(output))       
except KeyboardInterrupt:
    pass

time.sleep(.001)                       # delay for frame req

# set parameters for generating an image
transfer_length = 1 #16
pix1 = 488
pix2 = 648
Block_size_max = pix1*pix2*transfer_length  # 316224 Bytes
Block_size = int(Block_size_max/1024)*1024   # ask for 315392 pixels
print('Block size:', Block_size)
#ignore 812 pixels of the full 316224 pixels to obtain a full 1024 multiple array

# buf = bytearray(315392)  #Block_size

# ---------------------------------------------------------------------------------------------

def buf_thread():
    buf = bytearray(Block_size)
    dev.SetWireInValue(0x04, 1);    # Ask for frame req
    dev.UpdateWireIns();  
    dev.SetWireInValue(0x04, 0);    # stop asking for frame req
    dev.UpdateWireIns(); 
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
    return buf

     
def get_image(buf):
    preimage = np.zeros(pix1*pix2)
    postimage = np.zeros(pix1*pix2)
    
    preimage[:-832] = np.frombuffer(buf, dtype=np.uint8)
    
    postimage = preimage
    postimage = postimage.reshape(pix1, pix2)
    return postimage

def move_motor(dirinput):  # 0 is backwards ccw, 1 is forwards cw
	Pulses = 100
	dutycyle = 100

	dev.SetWireInValue(0x00, 1) # motor control 1: Input data for Variable 1 using mamoery space 0x00
	dev.SetWireInValue(0x01, Pulses) #Input data for Variable 2 using mamoery space 0x01
	dev.SetWireInValue(0x02, dirinput) # direction of motor (0 ccw, 1 cw) Input data for Variable 2 using mamoery space 0x02
	dev.SetWireInValue(0x03, dutycyle) #Input data for Variable 2 using mamoery space 0x03
	dev.UpdateWireIns()  # Update the WireIns

	dev.SetWireInValue(0x00, 0) # motor control 0: Turn motor off
	dev.UpdateWireIns()




num_frames = 500
#Intensity_5050 = np.zeros((num_frames)) # create a empty array the size of the numer of frames to fill with intensity data from pix 50,50
#Int_time = '1ms' # '10ms'

#num_frames = 0
counter = 0
start = time.time()
image_F1 = np.zeros((pix1,pix2)) # set F1 = 0 so first frame all pix will be new
diff_threshold = .80 # Difference in image threshold is 80% of maximum differnce in value (THIS NEEDS TO BE TUNED)
motor_dict = {0: 'cw', 1: 'ccw'}
#try:
while (counter<num_frames):
    image_F2 = image_F1 # save last frame as F2
    
    counter += 1
#    print(counter)
    # Get current frame and save as image_F1
    image_F1 = np.zeros((pix1,pix2))
    buf = buf_thread()
    postimage = get_image(buf)
	
    image = postimage/np.max(postimage)
    im_array = np.array(image).reshape(pix1, pix2)  # Reshape array into a 2D array like image
    image_F1[:-215] = im_array[215:]
    image_F1[-215:] = im_array[:215]
    
    # Find difference between F1 and F2
    frame_diff = image_F1 - image_F2 						# image_F1 and image_F2 must be same shape
    frame_diff_masked = frame_diff[frame_diff >= diff_threshold*np.max(frame_diff)] 	# mask to find maximum frame differences, NEED TO TUNE
    x_avg = np.average(np.average(np.where(frame_diff >=diff_threshold*np.max(frame_diff)), axis=0)) # find x COM
    y_avg = np.average(np.average(np.where(frame_diff >=diff_threshold*np.max(frame_diff)), axis=1)) # find y COM
    if x_avg < pix1/2:
        # if x COM is on left of image
        motor_dir = 0 #ccw
    else:
        motor_dir = 1 #cw
    # Write on image: # bottomLeftCornerOfText, font, fontScale, fontColor, thickness, lineType
#    cv2.putText(image_F1,'fps:' + counter/(time.time()-start) + '\nmotor: ' + motor_dict[motor_dir],(10, 500),cv2.FONT_HERSHEY_SIMPLEX, 1,(255,255,255),1,2)  				
    cv2.imshow('frame', image_F1) # make a movie window from https://www.educative.io/edpresso/how-to-capture-a-frame-from-real-time-camera-video-using-opencv
#        Intensity_5050[counter] = image_F1[50][50]	# Get intensity of pixel 50, 50 (row 50, column 50) and add to array
    
    move_motor(motor_dir)
	
    if cv2.waitKey(1) & 0xFF == ord('s'):
        break
    print('fps = ', counter/(time.time()-start), '\ntotal time = ', time.time()-start, '\nmotor turning: ', motor_dict[motor_dir])

#except KeyboardInterrupt:
#    pass # press ^C to cancel loop     

dev.Close()

# plot intensity of pix 5050
#frames = np.arange(1, num_frames,1) # create a array of frame numbers
#plt.plot(frames, Intensity_5050)
#plt.title('Intensity of pixel (50, 50) \n Standard Deviation = ' + np.std(Intensity_5050))
#plt.ylabel('Intensity')
#plt.xlabel('Frame #')
#plt.tight_layout()
#plt.savefig("Intensity_pix5050_" + Int_time, dpi=300)





#%%

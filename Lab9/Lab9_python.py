# import various libraries necessery to run your Python code
import sys                      # system related library
import time                     # time related library
ok_loc = 'C:\Program Files\Opal Kelly\FrontPanelUSB\API\Python\3.6\x64'
sys.path.append(ok_loc)         # add the path of the OK library
import ok                       # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt

#%% 
# Define FrontPanel device variable, open USB communication and load the bit file in the FPGA
dev = ok.okCFrontPanel();                                                     # define a device for FrontPanel communication
# FrontPanel MUST BE CLOSED FOR THIS STEP TO SUCCEED!!!
SerialStatus=dev.OpenBySerial("");      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\Documents\ECE437\Lab9\BTPipeExample.bit"); # Configure the FPGA with this bit file
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
            '83_w':"0" + registers['83'] + str(format(251,'08b')) + zeros8 + write_bit,
            '83_r':"0" + registers['83'] + str(format(251,'08b')) + zeros8 + read_bit,
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
dev.SetWireInValue(sys_reset_wire, 0); # Set sys to 0 (off for restart)
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

#%% Reset FIFOs ##
# FIFO_wire = 0x02
# dev.SetWireInValue(FIFO_wire, 1);       #Reset FIFOs and counter
# dev.UpdateWireIns();  
# dev.SetWireInValue(FIFO_wire, 0);       #Release reset signal
# dev.UpdateWireIns();  
# time.sleep(.001)                        # delay for sys reset


#%% Ask for frame requst    ##
Frm_req_wire = 0x04
dev.SetWireInValue(Frm_req_wire, 1);    # Ask for frame req
dev.UpdateWireIns();  
dev.SetWireInValue(Frm_req_wire, 0);    # stop asking for frame req
dev.UpdateWireIns(); 
# set frame req to 0 in FSM to get exact clc cycle (want it to fall at falling clk (negedge))
#%% Grab data ##

# Data transfer length multiple of 16
# length of data transfer = image multiple of block size
# Total num of data points = 648 x 488 x 1Byte/pix = 316224 Bytes

# 8 bit in, 32 out

transfer_length = 1 #16
pix1 = 488
pix2 = 648
Block_size_max = pix1*pix2*transfer_length  # 316224 Bytes
Block_size = int(Block_size_max/1024)*1024  # ask for 315392 pixels
print('Block size:', Block_size)
#ignore 812 pixels of the full 316224 pixels to obtain a full 1024 multiple array

buf = bytearray(Block_size*4)                     # make sure buf is bigger than the amount of data coming in
dev.ReadFromBlockPipeOut(0xa0, Block_size, buf);  # Read data from BT PipeOut
print(buf)

#%% Set array to image array ##
image = np.zeros(pix1*pix2)

# counter = 0
for i in range(0, Block_size, 1):
    # print(( buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) ))
    image[i] = ( buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) ) # transfer length is 16 bits
    # counter = counter + 1
    # print (buf[i])

#%% show image ##
image = np.array(image)                         # convert list to array
print(np.max(image))
image= image/np.max(image)
im_array = np.array(image).reshape(pix1, pix2)  # Reshape array into a 2D array like image
pic = plt.imshow(im_array, cmap='jet',origin='lower')            # plot image with origin in lower left
plt.colorbar()
plt.savefig("pic.png")

dev.Close()
#%%

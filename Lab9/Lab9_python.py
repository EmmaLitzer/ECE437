# import various libraries necessery to run your Python code
import sys    # system related library
import time   # time related library
ok_loc = 'C:\Program Files\Opal Kelly\FrontPanelUSB\API\Python\3.6\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt

#%% 
# Define FrontPanel device variable, open USB communication and load the bit file in the FPGA
dev = ok.okCFrontPanel();  # define a device for FrontPanel communication
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
            'raddr3_w':'00000011001010010000000000000001',#"0" + registers['raddr3'] + '00101001' + zeros8 + write_bit,
            'raddr4_w':'00000100100010010000000000000001', # "0" + registers['raddr4'] + '10001001' + zeross8 +write_bit,
            'raddr3_r':'00000011001010010000000000000000', #"0" + registers['raddr3'] + '00101001' + zeros8 + write_bit,
            'raddr4_r':'00000100001010010000000000000000',# "0" + registers['raddr4'] + '00101001' + zeross8 + write_bit
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
            '69_w':"0" + registers['69'] + str(format(9,'08b')) + zeros8 + write_bit,
            '69_r':"0" + registers['69'] + str(format(9,'08b')) + zeros8 + read_bit,
            '80_w':"0" + registers['80'] + str(format(2,'08b')) + zeros8 + write_bit,
            '80_r':"0" + registers['80'] + str(format(2,'08b')) + zeros8 + read_bit,
            '83_w':"0" + registers['83'] + str(format(187,'08b')) + zeros8 + write_bit,
            '83_r':"0" + registers['83'] + str(format(187,'08b')) + zeros8 + read_bit,
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
	


# MAY NEED TO CHANGE WIRE NUMBERS (0x##)
try:                                                        # run temperature loop until ^C is pressed in terminal
    reg_key = read_write.keys()
    for i, key in enumerate(reg_key):
        Write_Grab_FSM(key) 
        if key[-1] !='w':
            dev.UpdateWireOuts()                                # FSM sends Temp data to PC
            output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
            print('regaddr:', key[:-2] +'\t'+str(output))
                        
                        
    #  write sequence
    #Write_Grab_FSM('raddr3_w')
    #Write_Grab_FSM('raddr4_w')
    #Write_Grab_FSM('raddr3_r')
	#
    #dev.UpdateWireOuts()                                # FSM sends Temp data to PC
    #output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
    #print(output)
	
    #Write_Grab_FSM('raddr4_r')
    #dev.UpdateWireOuts()                                # FSM sends Temp data to PC
    #output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
    #print(output)
	
        
        
except KeyboardInterrupt:
    pass

#%% Reset FIFOs ##

dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns

dev.SetWireInValue(0x00, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns
#%% Grab data ##

# Data transfer length multiple of 16
# length of data transfer = image multiple of block size
# Total num of data points = 648 x 488 x 1Byte/pix = 316224 Bytes

# 8 bit in, 32 out

transfer_length = 4 #16
pix1 = 488
pix2 = 648
Block_size = pix1*pix2*transfer_length  # 316224 Bytes
    # 64 or 1024?

image = []

buf = bytearray(Block_size)
dev.ReadFromBlockPipeOut(0xa0, 256, buf);  # Read data from BT PipeOut

#%% Set array to image array ##
counter = 0
for i in range(0, Block_size, 4):   
    image.append(buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16)) # transfer length is 16 bits
    counter = counter + 1
#    print (buf[i])

#%% show image ##
   
image = np.array(image)                         # convert list to array
im_array = np.array(image).reshape(pix1, pix2)  # Reshape array into a 2D array like image
pic = plt.imshow(im_array, cmap='jet',origin='lower')            # plot image with origin in lower left
plt.savefig("pic.png")

dev.Close()
#%%

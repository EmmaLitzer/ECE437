# import various libraries necessery to run your Python code
import sys    # system related library
ok_loc = 'C:\Program Files\Opal Kelly\FrontPanelUSB\API\Python\3.6\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel();  # define a device for FrontPanel communication
# FrontPanel MUST BE CLOSED FOR THIS STEP TO SUCCEED!!!
SerialStatus=dev.OpenBySerial("");      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\Documents\ECE437\Lab9\BTPipeExample.bit"); # Configure the FPGA with this bit file
print(ConfigStatus)
# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)));
    print("Exiting the program.");
    sys.exit ();

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.");
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
    print ("Exiting the progam.");
    sys.exit ();
print("----------------------------------------------------")
print("----------------------------------------------------")

#%% 
# Need to set SPI settings and start with FSM matching CMV300 data sheet



dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns

dev.SetWireInValue(0x00, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns
 

# Data transfer length multiple of 16
# length of data transfer = image multiple of block size
# Total num of data points = 648 x 488 x 1Byte/pix = 316224 Bytes


transfer_length = 4 #16
pix1 = 488
pix2 = 648
Block_size = pix1*pix2*transfer_length  # 316224 Bytes

image = []

buf = bytearray(Block_size);
dev.ReadFromBlockPipeOut(0xa0, 256, buf);  # Read data from BT PipeOut

#%%
counter = 0
for i in range (0, Block_size, 4):   
    image.append(buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16)) # transfer length is 16 bits
    counter = counter + 1
#    print (buf[i])

#%%
   
image = np.array(image)                         # convert list to array
im_array = np.array(image).reshape(pix1, pix2)  # Reshape array into a 2D array like image
pic = plt.imshow(im_array, cmap='jet',origin='lower')            # plot image with origin in lower left
plt.savefig("pic.png")

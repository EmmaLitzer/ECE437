# import various libraries necessery to run your Python code
import sys    # system related library
ok_loc = 'C:\Program Files\Opal Kelly\FrontPanelUSB\API\Python\3.6\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

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
dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns

dev.SetWireInValue(0x00, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns
 
buf = bytearray(1024*4);
dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut

#%%
for i in range (0, 1024, 1):    
   result = buf[i];
   print (buf[i])

    
#%%

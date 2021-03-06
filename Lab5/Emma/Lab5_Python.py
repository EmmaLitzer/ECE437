# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library


bit_file = '' + '.bit'										# bit file name in same folder as python file

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA(bit_file)
# We will NOT load the bit file because it will be loaded using JTAG interface from Vivado

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()
	
# check if bit file loaded correctly
if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.");
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
    print ("Exiting the progam.");
    sys.exit ();
print("----------------------------------------------------")

PC_Control = 1

# MAY NEED TO CHANGE WIRE NUMBERS (0x##)
# try:                                                        # run temperature loop until ^C is pressed in terminal
#     while(1):
#         dev.SetWireInValue(0x00, PC_Control)                # send in value of 1 to start the FSM
#         dev. UpdateWireIns()                                # Send wirein value to FSM 

#         dev.UpdateWireOuts()                                # FSM sends Temp data to PC
#         T_msb = dev.GetWireOutValue(0x01)<<8                # get msb temp register and shift 8 bits to the left
#         T_lsb = dev.GetWireOutValue(0x02)                   # get lsb temp register
#         T = (1/128) * (T_lsb + T_msb)                       # Convert FSM data to Temperature:: See TEMPERATURE CONVERSION FORMULAS in ADT7420 Data Sheet (pg12)
#         print('The Temperature is {} degrees C'.format(xx)) # Print temperature value
#         time.sleep(0.5)                                     # Wait .5s to read next T measurement
# except KeyboardInterrupt:
#     pass


    
#%%


for i in range(0,9):
	dev.SetWireInValue(0x00, PC_Control)                # send in value of 1 to start the FSM
        dev. UpdateWireIns()                                # Send wirein value to FSM 

        dev.UpdateWireOuts()                                # FSM sends Temp data to PC
        T_msb = dev.GetWireOutValue(0x01)<<8                # get msb temp register and shift 8 bits to the left
        T_lsb = dev.GetWireOutValue(0x02)                   # get lsb temp register
        T = (1/128) * (T_lsb + T_msb)                       # Convert FSM data to Temperature:: See TEMPERATURE CONVERSION FORMULAS in ADT7420 Data Sheet (pg12)
        print('Run #{}: The Temperature is {} degrees C'.format(i, xx)) # Print temperature value
        time.sleep(0.5)                                     # Wait .5s to read next T measurement
	
dev.Close


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

# We will NOT load the bit file because it will be loaded using JTAG interface from Vivado

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program

counter = 0
time.sleep(0.5)

# MAY NEED TO CHANGE WIRE NUMBERS (0x##)
try:                                                        # run temperature loop until ^C is pressed in terminal
    while counter<10 :
        PC_Control = 1
        dev.SetWireInValue(0x00, PC_Control)                # send in value of 1 to start the FSM
        dev. UpdateWireIns()                                # Send wirein value to FSM 

        dev.UpdateWireOuts()                                # FSM sends Temp data to PC
        T_MSB = dev.GetWireOutValue(0x20)<<8                # get msb temp register and shift 8 bits to the left
        T_LSB = dev.GetWireOutValue(0x21)>>3                   # get lsb temp register
        T = (1/128) * (T_LSB + T_MSB)                       # Convert FSM data to Temperature:: See TEMPERATURE CONVERSION FORMULAS in ADT7420 Data Sheet (pg12)
        print('The Temperature is {} degrees C'.format(T)) # Print temperature value
        counter = counter + 1
        
        time.sleep(0.5)                                     # Wait .5s to read next T measurement
        
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()  # Update the WireIns
        #Send STOP signal to the FSM"
        
except KeyboardInterrupt:
    pass


dev.Close
    
#%%

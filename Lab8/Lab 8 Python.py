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

# MAY NEED TO CHANGE WIRE NUMBERS (0x##)
try:                                                        # run temperature loop until ^C is pressed in terminal
        #write sequence
        PC_control = 1
        PC_data = "00000011001010010000000000000001"
        dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
        dev.SetWireInValue(0x01, int(PC_data,2))
        dev. UpdateWireIns()                                # Send wirein value to FSM 
        time.sleep(0.001)
        PC_control = 0
        dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
        dev. UpdateWireIns()                                # Send wirein value to FSM 
        
        #read sequence
        PC_control = 1
        PC_data = "00000011001010010000000000000000"
        dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
        dev.SetWireInValue(0x01, int(PC_data,2))
        dev. UpdateWireIns()                                # Send wirein value to FSM 
        time.sleep(0.001)
        PC_control = 0
        dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
        dev. UpdateWireIns()                                # Send wirein value to FSM 
    
        dev.UpdateWireOuts()                                # FSM sends Temp data to PC
        output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
        print(output)
        
        
except KeyboardInterrupt:
    pass


dev.Close()
    
#%%

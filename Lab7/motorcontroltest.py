# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board


#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
motor_control = 1
Pulses = 100
dirinput = 0 #0 is backwards, 1 is forwards
dutycyle = 100

dev.SetWireInValue(0x00, motor_control) #Input data for Variable 1 using mamoery space 0x00
dev.SetWireInValue(0x01, Pulses) #Input data for Variable 2 using mamoery space 0x01
dev.SetWireInValue(0x02, dirinput) #Input data for Variable 2 using mamoery space 0x02
dev.SetWireInValue(0x03, dutycyle) #Input data for Variable 2 using mamoery space 0x03
dev.UpdateWireIns()  # Update the WireIns
               
motor_control = 0
dev.SetWireInValue(0x00, motor_control)
dev.UpdateWireIns()

dev.Close()
    
#%%

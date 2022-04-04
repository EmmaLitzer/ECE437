#%%
# import various libraries necessery to run your Python code
from ast import Add
import time                         # time related library
import sys                         # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)             # add the path of the OK library
import ok                           # OpalKelly library

import numpy as np
import matplotlib.pyplot as plt

bit_file = '' + '.bit'										# bit file name in same folder as python file

#%% 
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board

counter = 0
#time.sleep(0.5)
def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is




#acceleration data load:
RW = 0
dev.SetWireInValue(0x00,RW)             # Turn Read/Write off
dev.UpdateWireIns()

A_SAD = '0011001'
M_SAD = '0011110'
R = '1'
W = '0'

Addresses = {'XLA':0x28,
            'XHA':0x29,
            'YLA':0x2A,
            'YHA':0x2B,
            'ZLA':0x2C,
            'ZHA':0x2D,
            'XLM':0x04,
            'XHM':0x03,
            'YLM':0x08,
            'YHM':0x07,
            'ZLM':0x06,
            'ZHM':0x05}

def grab_convert(PCDATA):
    RW = 0
    dev.SetWireInValue(0x00,RW)                  # Turn R/W off
    dev.UpdateWireIns()
    RW = 1
    dev.SetWireInValue(0x00,RW)                 # Turn read on
    dev.SetWireInValue(0x03,Addresses[PCDATA])               # Address
    dev.UpdateWireIns()  
    time.sleep(0.01)   
    dev.UpdateWireOuts()
    return dev.GetWireOutValue(0x25)            # Grab data from line 25 (Sens_data)



PC_Control = 1
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()

while(1):
    # Write to acceleration sensor
    RW = 2
    dev.SetWireInValue(0x00,RW)                 # Turn write on
    dev.SetWireInValue(0x01,int(A_SAD + R,2))   # SAD + R: 51
    dev.SetWireInValue(0x02,int(A_SAD + W,2))   # SAD + W: 50
    dev.SetWireInValue(0x03,0x20)               # Write to CTRL REG
    dev.SetWireInValue(0x04,0b10010111)         # Write TURN ON to CTRL
    dev.UpdateWireIns()
    dev.SetWireInValue(0x00,0)                  # Turn R/W off
    dev.UpdateWireIns()
    # --------------------------------------------------------
    # grab acceleration data
    PCDATA = 'XLA'
    XLA = grab_convert(PCDATA)
    PCDATA = 'XHA'
    XHA = grab_convert(PCDATA)
    XA_data = XHA<<8 + XLA

    PCDATA = 'YLA'
    YLA = grab_convert(PCDATA)
    PCDATA = 'YHA'
    YHA = grab_convert(PCDATA)
    YA_data = YHA<<8 + YLA


    PCDATA = 'ZLA'
    ZLA = grab_convert(PCDATA)
    PCDATA = 'ZHA'
    ZHA = grab_convert(PCDATA)
    ZA_data = ZHA<<8 + ZLA
   
        
    print("x:%.2f"%(XA_data)) #/16*0.001))
    print("y:%.2f"%(YA_data)) #/16*0.001))
    print("z:%.2f"%(ZA_data)) #/16*0.001))
    time.sleep(.25)
    print("-----------------")

PC_Control = 0
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()



# Write to magnetic sensor
PC_Control = 1
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()


RW = 2
dev.SetWireInValue(0x00,RW) 
dev.SetWireInValue(0x01,int(M_SAD + W,2))
dev.SetWireInValue(0x02,int(A_SAD + R,2)) 
dev.SetWireInValue(0x03,0x02)             # Write to CRTL REG
dev.SetWireInValue(0x04,0b00000000)       # Write TURN ON to mag CTRL reg
dev.UpdateWireIns()
dev.SetWireInValue(0x00,0)
dev.UpdateWireIns()


while(1):
    dev.SetWireInValue(0x00,0)
    dev.UpdateWireIns()
    dev.SetWireInValue(0x00,1)
    dev.SetWireInValue(0x01,int(M_SAD + W,2)) 
    dev.SetWireInValue(0x02,int(M_SAD + R,2)) 
    dev.SetWireInValue(0x03,0b00000011) #Xhm
    dev.UpdateWireIns()  
    time.sleep(0.01)   
    dev.UpdateWireOuts()


    PCDATA = 'XLM'
    XLM = grab_convert(Addresses[PCDATA])
    PCDATA = 'XHM'
    XHM = grab_convert(Addresses[PCDATA])
    XM_data = XHM<<8 + XLM

    PCDATA = 'YLM'
    YLM = grab_convert(Addresses[PCDATA])
    PCDATA = 'YHM'
    YHM = grab_convert(Addresses[PCDATA])
    YM_data = YHM<<8 + YLM

    PCDATA = 'ZLM'
    ZLM = grab_convert(Addresses[PCDATA])
    PCDATA = 'ZHM'
    ZHM = grab_convert(Addresses[PCDATA])
    ZM_data = ZHM<<8 + ZLM
   
        
    print("x:%.2f"%(XA_data)) #/16*0.001))
    print("y:%.2f"%(YA_data)) #/16*0.001))
    print("z:%.2f"%(ZA_data)) #/16*0.001))
    time.sleep(.25)
    print("-----------------")

    print('\n\nAccelerometer: \n\tX:{0}\tY:{1}\tZ:{2}\n\nMagnometer:  \n\tX:{3}\tY:{4}\tZ:{5}'.format(XA_data, YA_data, ZA_data, XM_data, YM_data, ZM_data)) # Print data

PC_Control = 0
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()
 

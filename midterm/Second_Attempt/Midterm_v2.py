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
'''
def twos_comp(val, bits=8):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is
'''



#acceleration data load:
RW = 0
dev.SetWireInValue(0x00,RW)             # Turn Read/Write off
dev.UpdateWireIns()

A_SAD = '0011001'
M_SAD = '0011110'
R = '1'
W = '0'

big = 32768
inc = 65536


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
    return dev.GetWireOutValue(0x20)            # Grab data from line 25 (Sens_data)

#'''
def twos_comp(data):
    if data > big:
        data = data - inc
    return data

#'''
PC_Control = 1
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()

for i in range(0, 50):
    # Write to acceleration sensor
    RW = 2
    dev.SetWireInValue(0x00,RW)                 # Turn write on
    dev.SetWireInValue(0x01,int(A_SAD + R,2))   # SAD + R: 51
    dev.SetWireInValue(0x02,int(A_SAD + W,2))   # SAD + W: 50
    dev.SetWireInValue(0x03,0x20)               # Write to CTRL REG
    dev.SetWireInValue(0x04,0x27)         # Write TURN ON to CTRL
    dev.UpdateWireIns()
    dev.SetWireInValue(0x00,0)                  # Turn R/W off
    dev.UpdateWireIns()
    
    # Write to 4A ctrl
    RW = 2
    dev.SetWireInValue(0x00,RW) 
    dev.SetWireInValue(0x01,int(A_SAD + W,2))
    dev.SetWireInValue(0x02,int(A_SAD + R,2)) 
    dev.SetWireInValue(0x03,0x23)             # Write to CRTL REG
    dev.SetWireInValue(0x04,0x40)       # Write TURN ON to mag CTRL reg
    dev.UpdateWireIns()
    dev.SetWireInValue(0x00,0)
    dev.UpdateWireIns()

    # --------------------------------------------------------
    # Read acceleration data
    PCDATA = 'XLA'
    XLA = grab_convert(PCDATA)
    PCDATA = 'XHA'
    XHA = grab_convert(PCDATA)
    #XA_data = XHA<<8 + XLA
    XA_data = (XHA<<8) + XLA

    XA_data = twos_comp(XA_data)/16*0.001

    PCDATA = 'YLA'
    YLA = grab_convert(PCDATA)
    PCDATA = 'YHA'
    YHA = grab_convert(PCDATA)
    YA_data = (YHA<<8) + YLA
    YA_data = twos_comp(YA_data)/16*0.001

    PCDATA = 'ZLA'
    ZLA = grab_convert(PCDATA)
    PCDATA = 'ZHA'
    ZHA = grab_convert(PCDATA)
    ZA_data = (ZHA<<8) + ZLA
    ZA_data = twos_comp(ZA_data)/16*0.001

    # -----------------------------------------------------------------------------------------
    dev.SetWireInValue(0x00,0)
    dev.UpdateWireIns()
    
    
    # Write to magnetic sensor
    RW = 2
    dev.SetWireInValue(0x00,RW) 
    dev.SetWireInValue(0x01,int(M_SAD + W,2))
    dev.SetWireInValue(0x02,int(M_SAD + R,2)) 
    dev.SetWireInValue(0x03,0x02)             # Write to CRTL REG
    dev.SetWireInValue(0x04,0x00)       # Write TURN ON to mag CTRL reg
    
    #dev.SetWireInValue(0x03,0b00000011) #Xha
    
    dev.UpdateWireIns()
    time.sleep(0.01)
    
    #dev.UpdateWireOuts()
    #XLM = dev.GetWireOutValue(0x25)
    
    dev.SetWireInValue(0x00,0)
    dev.UpdateWireIns()
    
    
#    RW = 2
#    dev.SetWireInValue(0x00,RW) 
#    dev.SetWireInValue(0x01,int(M_SAD + W,2))
#    dev.SetWireInValue(0x02,int(M_SAD + R,2)) 
#    dev.SetWireInValue(0x03,0x00)             # Write to CRTL REG
#    dev.SetWireInValue(0x04,0x14)       # Write TURN ON to mag CTRL reg
#    dev.UpdateWireIns()
#    dev.SetWireInValue(0x00,0)
#    dev.UpdateWireIns()



    # Read Magnetic data
    PCDATA = 'XLM'
    XLM = grab_convert(PCDATA)
    PCDATA = 'XHM'
    XHM = grab_convert(PCDATA)
    XM_data = (XHM<<8) + XLM
    XM_data = twos_comp(XM_data) /1000 # Does not work without /1000?


    PCDATA = 'YLM'
    YLM = grab_convert(PCDATA)
    PCDATA = 'YHM'
    YHM = grab_convert(PCDATA)
    YM_data = (YHM<<8) + YLM
    YM_data = twos_comp(YM_data) /1000


    PCDATA = 'ZLM'
    ZLM = grab_convert(PCDATA)
    PCDATA = 'ZHM'
    ZHM = grab_convert(PCDATA)
    ZM_data = (ZHM<<8) + ZLM
    ZM_data = twos_comp(ZM_data) /1000


    print('\nAccelerometer:\t\t\tMagnometer: \n\tX:{0:.2f}\tY:{1:.2f}\tZ:{2:.2f}\t\tX:{3:.2f}\tY:{4:.2f}\tZ:{5:.2f}'.format(XA_data, YA_data, ZA_data, XM_data, YM_data, ZM_data)) # Print data
    #print("Compass heading:\t{0:.2f}".format((np.arccos(ZM_data/(np.sqrt(XM_data**2 + YM_data**2 + ZM_data**2)))-2)*360))
    #print("Compass heading:\t{0:.2f}".format((np.arctan(YM_data/XM_data))*360))

PC_Control = 0
dev.SetWireInValue(0x07, PC_Control)
dev.UpdateWireIns()

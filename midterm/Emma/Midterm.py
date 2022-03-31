#%%
# import various libraries necessery to run your Python code
from ast import Add
import time                         # time related library
import sys                          # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)             # add the path of the OK library
import ok                           # OpalKelly library


bit_file = '' + '.bit'										# bit file name in same folder as python file

#%% 
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board

counter = 0
#time.sleep(0.5)
def twos_complement(val, nbits):
    """Compute the 2's complement of int value val"""
    if val < 0:
        val = (1 << nbits) + val
    else:
        if (val & (1 << (nbits - 1))) != 0:
            # If sign bit is set.
            # compute negative value.
            val = val - (1 << nbits)
    return val


# PCDATA components
# Accelerometer:
SADW_A =    '00110010'
SADW_M =    '00111100'

# Magnetometer:
SADR_A =    '00110011'
SADR_M =    '00111100'

# Set to read instead of write
RW =        '00000001'


PCDATA = {
    #Set PCDATA addresses for register 
    "X_A": SADW_A + '00101000' + SADR_A + RW,
    "Y_A": SADW_A + '00101010' + SADR_A + RW,
    "Z_A": SADW_A + '00101100' + SADR_A + RW,
    "X_M": SADW_M + '00000011' + SADR_M + RW,
    "Y_M": SADW_M + '00000111' + SADR_M + RW,
    "Z_M": SADW_M + '00000101' + SADR_M + RW
}

#def Start_RW(R, W):
    #dev.UpdateWireIns(0x01, W) #STARTW
    #dev.UpdateWireIns(0x02, R) #STARTR


def grab_convert(data_bit_name, loc_MSB=0x21, loc_LSB=0x20):
    # Grab FSM data from FPGA, convert and concatanate LSB and MSB into SI data units.

    # Write register you want data from

    #dev.SetWireInValue(0x00, PCDATA[data_bit_name])  # Write address to FPGA
    dev.SetWireInValue(0x00, int(PCDATA[data_bit_name],2))  # Write address to FPGA    
    dev.SetWireInValue(0x01, 1) #STARTW
    #Start_RW(0, 1)                                  # Tell FSM you want to write
    dev.UpdateWireIns()                             # Write PCDATA to FSM write to FPGA

    # Tell FSM you want to read data
    # Start_RW(1, 0)                                  # Tell FSM you want to read
    # dev.UpdateWireIns()                             # Tell FSM you want to read

    dev.UpdateWireOuts()                            # FSM sends data to PC

    # Read data from FSM in dev
    if data_bit_name[-1] == 'A':
        # Grab Accelerator data
        MSB = dev.GetWireOutValue(loc_MSB)<<8       # get msb temp register and shift 8 bits to the left
        LSB = dev.GetWireOutValue(loc_LSB)          # get lsb temp register (may need to shift 3 to the right (>>3))
    
    if data_bit_name[-1] == 'M':
        # Grab Magnometer data
        # Magnometer register LSB and MSB are flipped due to ease of Verilog code
        LSB = dev.GetWireOutValue(loc_MSB)<<8       # get msb temp register and shift 8 bits to the left
        MSB = dev.GetWireOutValue(loc_LSB)          # get lsb temp register (may need to shift 3 to the right (>>3))
    
    Data = MSB + LSB                                # Convert FSM data to SI data values:: See CONVERSION FORMULAS in Data Sheet (pg10)
    
    dev.SetWireInValue(0x01, 0)
    #Start_RW(0, 0)                                  # Turn write and read off
    dev.UpdateWireIns()                             # Tell FSM you don't want to write or read
    time.sleep(0.25)  
    return Data

onacc= "00110010001000001001011100000000"
onmag= "00111100000000100000000000000000"
print(int(onacc,2))
dev.SetWireInValue(0x00, int(onacc,2))
dev.SetWireInValue(0x01, 1)
dev.UpdateWireIns()
dev.SetWireInValue(0x01, 0)
dev.UpdateWireIns()
time.sleep(0.25)
#dev.SetWireInValue(0x01, 1)
#dev.SetWireInValue(0x00, int(onmag,2))
#dev.UpdateWireIns()
#dev.SetWireInValue(0x01, 0)
#dev.UpdateWireIns()
#time.sleep(0.25)

try:                     
    # Grab and convert data from FSM into SI units. Print these values.
    for i in range(0,10):
        X_A_bin = grab_convert("X_A")
        Y_A_bin = grab_convert("Y_A")
        Z_A_bin = grab_convert("Z_A")
    
        X_M_bin = grab_convert("X_M")
        Y_M_bin = grab_convert("Y_M")
        Z_M_bin = grab_convert("Z_M")

        print(X_M_bin, '\n',type(X_M_bin))

        X_A=twos_comp(int(X_A_bin,2), len(X_A_bin))
        Y_A=twos_comp(int(Y_A_bin,2), len(Y_A_bin))
        Z_A=twos_comp(int(Z_A_bin,2), len(Z_A_bin))

        X_M=twos_comp(int(X_M_bin,2), len(X_M_bin))
        Y_M=twos_comp(int(Y_M_bin,2), len(Y_M_bin))
        Z_M=twos_comp(int(Z_M_bin,2), len(Z_M_bin))
    
        print('\n\nAccelerometer: \n\tX:{0}\tY:{1}\tZ:{2}\n\nMagnometer:  \n\tX:{3}\tY:{4}\tZ:{5}'.format(X_A, Y_A, Z_A, X_M, Y_M, Z_M), end='\r') # Print data
            
        time.sleep(0.25)                        # Wait .25s to read next Data measurement
        
        
except KeyboardInterrupt:
    pass


dev.Close
    
#%%

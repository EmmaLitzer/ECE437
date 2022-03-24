#%%
# import various libraries necessery to run your Python code
from ast import Add
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library


bit_file = '' + '.bit'										# bit file name in same folder as python file

#%% 
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board

print("----------------------------------------------------")
# Check if FrontPanel is initialized correctly and if the bit file is loaded. Otherwise terminate the program
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()


counter = 0
time.sleep(0.5)


# PCDATA components
SADW_A = '00110010'
SADW_M = '00111100'

SADR_A = '00110011'
SADR_M = '00111100'

RW = '00000001'


PCDATA = {
    #Set PCDATA addresses for register 
    "X_A": SADW_A + '00101000' + SADR_A + RW,
    "Y_A": SADW_A + '00101010' + SADR_A + RW,
    "Z_A": SADW_A + '00101100' + SADR_A + RW,
    "X_M": SADW_M + '00000011' + SADR_M + RW,
    "Y_M": SADW_M + '00000111' + SADR_M + RW,
    "Z_M": SADW_M + '00000101' + SADR_M + RW
}

def Start_RW(R, W):
    dev.UpdateWireIns(0x01, W) #STARTW
    dev.UpdateWireIns(0x02, R) #STARTR


def grab_convert(data_bit_name, loc_MSB=0x21, loc_LSB=0x20):
    # Grab FSM data from FPGA, convert and concatanate LSB and MSB into SI data units.

    # Write register you want data from
    dev.UpdateWireIns(0x00, PCDATA[data_bit_name])
    Start_RW(0, 1)
    dev.UpdateWireIns()                             # Send PCDATA, start R/W values to FSM

    # Tell FSM you want to read data
    Start_RW(1, 0)
    dev.UpdateWireIns()                             # Send PCDATA, start R/W values to FSM

    dev.UpdateWireOuts()                            # FSM sends data to PC

    # Read data from out dev
    if data_bit_name[-1] == 'A'
        MSB = dev.GetWireOutValue(loc_MSB)<<8       # get msb temp register and shift 8 bits to the left
        LSB = dev.GetWireOutValue(loc_LSB)          # get lsb temp register (may need to shift 3 to the right (>>3))
    
    if data_bit_name[-1] == 'M'
        # Magnometer register LSB and MSB are flipped due to ease of Verilog code
        LSB = dev.GetWireOutValue(loc_MSB)<<8       # get msb temp register and shift 8 bits to the left
        MSB = dev.GetWireOutValue(loc_LSB)          # get lsb temp register (may need to shift 3 to the right (>>3))
    
    Data = int(LSB + MSB)                           # Convert FSM data to SI data values:: See CONVERSION FORMULAS in Data Sheet (pg10)

    Start_RW(0, 0)
    dev.UpdateWireIns()                             # Send Start R/W to FSM

    return Data



try:                                                        # run temperature loop until ^C is pressed in terminal
    while counter<100 : 
        X_A = grab_convert("X_A")               # loc MSB, loc LSB
        Y_A = grab_convert("Y_A")               # loc MSB, loc LSB
        Z_A = grab_convert("Z_A")               # loc MSB, loc LSB

        X_M = grab_convert("X_M")               # loc MSB, loc LSB
        Y_M = grab_convert("Y_M")               # loc MSB, loc LSB
        Z_M = grab_convert("Z_M")               # loc MSB, loc LSB


        print('Accelerometer: \n\tX:{0}\tY:{1}\tZ:{2}\n\n' +
              'Magnometer:  \n\tX:{3}\tY:{4}\tZ:{5}'.format(X_A, Y_A, Z_A, X_M, Y_M, Z_M), end='\r') # Print data

        counter = counter + 1
        
        time.sleep(0.25)                                     # Wait .25s to read next Data measurement
        
        
except KeyboardInterrupt:
    pass


dev.Close
    
#%%

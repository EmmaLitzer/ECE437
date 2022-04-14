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


zeros8 = '00000000'
read_bit = '00000000'
write_bit = '00000001'

registers = {'raddr3':'0000011',
	     'radar4':'0000100',
	     
	    }
read_write = {'raddr3_w':"0" + registers['raddr3'] + '00101001' + zeros8 + write_bit,
	      'raddr3_r':"0" + registers['raddr3'] + '00101001' + zeros8 + write_bit,
	     'raddr4_w': "0" + registers['raddr4'] + '10001001' + zeross8 +write_bit,
	     'raddr4_r': "0" + registers['raddr4'] + '00101001' + zeross8 + write_bit,
	     }




def Write_Grab_FSM(rw):
	PC_control = 1																				# turn FSM on
	if rw in read_write.keys():
		PC_Data=read_write[rw]
	else:
		print("Please put a correct key into Write_Grab_FSM")
		
	# send read/write to PC and grab data into dev
	dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
	dev.SetWireInValue(0x01, int(PC_data,2))
	dev. UpdateWireIns()                                # Send wirein value to FSM 
	time.sleep(0.001)	
	PC_control = 0																			# turn FSM off
	dev.SetWireInValue(0x00, PC_control)                # send in value of 1 to start the FSM
	dev. UpdateWireIns()                                # Send wirein value to FSM 
	



# MAY NEED TO CHANGE WIRE NUMBERS (0x##)
try:                                                        # run temperature loop until ^C is pressed in terminal
        # write sequence
	Write_Grab_FSM('raddr3_w')
	Write_Grab_FSM('raddr4_w')
	Write_Grab_FSM('raddr3_r')
	
	dev.UpdateWireOuts()                                # FSM sends Temp data to PC
        output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
        print(output)
	
	Write_Grab_FSM('raddr4_r')
	dev.UpdateWireOuts()                                # FSM sends Temp data to PC
        output = dev.GetWireOutValue(0x20)                  # get msb temp register and shift 8 bits to the left
        print(output)
	
        
        
except KeyboardInterrupt:
    pass


dev.Close()
    
#%%

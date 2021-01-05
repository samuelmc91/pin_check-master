import sys
import time
import epics
import os

def topViewSnap(filePrefix, data_dict_name, file_num, acquire=1):
    im = epics.PV('XF:17IDB-ES:AMX{Cam:9}cam1:ImageMode')
    trig = epics.PV('XF:17IDB-ES:AMX{Cam:9}cam1:TriggerMode')
    dt = epics.PV('XF:17IDB-ES:AMX{Cam:9}cam1:DataType')
    acq = epics.PV('XF:17IDB-ES:AMX{Cam:9}cam1:Acquire')
    file_path = epics.PV('XF:17IDB-ES:AMX{Cam:9}JPEG1:FilePath')
    file_name = epics.PV('XF:17IDB-ES:AMX{Cam:9}JPEG1:FileName')
    file_number = epics.PV('XF:17IDB-ES:AMX{Cam:9}JPEG1:FileNumber')
    write_file = epics.PV('XF:17IDB-ES:AMX{Cam:9}JPEG1:WriteFile')

    os.system("mkdir -p /GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master/" + data_dict_name)
    os.system("chmod 777 /GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master/" + data_dict_name)
    acq.put(0, wait=False)

    time.sleep(1.0)
    trig.put(5)
    im.put(0)
    dt.put(0)

    file_path.put("/GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master/" + data_dict_name)
    file_name.put(filePrefix)
    file_number.put(file_num)

    if acq:
        acq.put(1)
        write_file.put(1)
        trig.put(0)
        im.put(2)
        dt.put(1)
        acq.put(1, wait=False)
    time.sleep(1.0)
    acq.put(1, wait=False)

def main():
    filePrefix = "test"
    data_directory = "pin_check"
    file_number = 103
    topViewSnap(filePrefix, data_directory, file_number)
    exit("/" + data_directory + "/" + filePrefix + "_" + str(file_number))


main()

#!/opt/conda_envs/collection-2018-1.0/bin/python
import sys
import os

pinCheckRoot = "/GPFS/CENTRAL/XF17ID2/sclark1/pin_check-master"
baseDirectory = os.environ["PWD"]
beamline = os.environ["BEAMLINE_ID"]
#runningDir = baseDirectory + "/pinAlign"

os.chdir(pinCheckRoot)

runPinCheck = pinCheckRoot + "/run_pin_check_" + beamline + ".sh"

lines = os.popen(runPinCheck).readlines()
tilted = False

for output in lines:
    if output.find("MISSING") != 1:
        tilted = True
        print(output)

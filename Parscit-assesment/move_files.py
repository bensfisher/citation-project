import os
import shutil
import pandas as pd

rias = pd.read_csv('Parscit-assesment/RIACitations.csv')
rias = rias['RIN'].tolist()

rootdir = 'Parscit-assesment/'
dest = 'Parscit-assesment/test-RIAs'

for root, dirs, files in os.walk(rootdir):
    for name in files:
        if name.endswith('.pdf') and name[3:12] in rias:
            shutil.copy2(os.path.join(root, name), os.path.join(dest, name))


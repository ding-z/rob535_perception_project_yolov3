from glob import glob
import numpy as np
from collections import defaultdict
import csv

files = glob('../data-2019/test/*/*_image.jpg')
test_data = []
for idx in range(len(files)):
    snapshot = files[idx]
    sample = snapshot[18:-10]
    test_data.append(sample)

labels_dict = defaultdict(int)
confidence = defaultdict(int)

with open('Changed_label_v1.txt','r') as f:
    for i, line in enumerate(f):
        infor = line.split()
        cur_name = infor[0]
        cur_label = int(infor[1])
        conf = float(infor[2])
        if cur_label > 0 and conf > confidence[cur_name]:
            labels_dict[cur_name] = cur_label
            confidence[cur_name] = conf
    length = i + 1
print('Changed_label_v1.txt length is',length)

with open('Submission.csv','w') as output:
    output = csv.writer(output, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    output.writerow(['guid/image','label'])
    for sample in test_data:
        output.writerow([sample,labels_dict[sample]])

print('There are',len(test_data),'test data')

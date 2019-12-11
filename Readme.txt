##########################################################################################################################
Task 1:
First step: Change the provided data into standard input data format.

	Input_format.m Change the training data in to input format. The output includes compressed images and corresponding label information. The output are stored in "images" and "labels" folder. These folders should exist before running this script.
	Test_format.m Change testing data in to input format. The output are stored in "test_large" folder.
	generate_train_validate.m Generate training and validation dataset. After running this script, type in paste <(awk "{print \"$PWD\"}" <train.part) train.part | tr -d '\t' > train.txt and paste <(awk "{print \"$PWD\"}" <valid.part) valid.part | tr -d '\t' > valid.txt to get training and testing files with corresponding file paths.

Second step: Use YOLOv3 to train the network with training data. 
	Source code and instructions: https://pjreddie.com/darknet/yolo/ . Follow the instructions to install it. We modify the configuration, architecture and anchor sizes of the network.
	The modifications and other details are shown in the report. Related files are shown in YOLO_files.

Third step: Detect testing data with trained network.

	detect_custom.py This detection script is built based on the detection script from project: https://github.com/eriklindernoren/PyTorch-YOLOv3#train. Some modifications are added to get desired informations.

	To run this script, I run: python3 detect_custom.py --model_def config/yolov3-custom_large.cfg--weights_path weights/yolov3-custom_large_final.weights --class_path data/custom/classes.names --conf_thres 0.1 --nms_thres 0.00001 --image_folder data/samples

	where yolov3-custom_large_final.weights is the trained weights, data/samples is where we stored the testing images.


Fourth step: Change the output format. The detection step would generate an output file called: Detect_information.txt which contains all the information.


	Task1_Change_labels_.m Change the objects' labels to 0 if their distances are larger than 50m.

	Task1_change_label_csv.py Choose the most confidence object in test images and output the desired information.

#####################################################################################################################
Task2:

	Task_2.m Use Detect_information.txt as input and output the distance and angle information as csv file.
######################################################################################################################

The related configuration files for YOLOv3 are also provided. To use these files, file paths should be changed accordingly.
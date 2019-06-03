1. The model is constructed with the Keras. Install the keras with:   
    pip install keras   
	
	
2. set the path of directory contanining training data.  
    in easyExample/SuperCNN_modified/CNN_train/superCNN.py  
    in the main (line around 357):  
    set the directory path to "train_image","train_mask","test_image","train_mask"  
	  
	  
3. Training the model with:  
   python superCNN.py

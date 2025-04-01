
var ImageUtil = {};

ImageUtil.initCanvas = function()
{
	
	 ImageUtil.myCanvas = document.getElementById('my-canvas');
      ImageUtil.myContext = ImageUtil.myCanvas.getContext('2d');
      ImageUtil.canvas = document.createElement('canvas');
      ImageUtil.context = ImageUtil.canvas.getContext('2d');

	
}
ImageUtil.getImageData = function(url,callback){ 
  
  var canvas = document.createElement('canvas'); 
 var context = canvas.getContext('2d'); 
  /* var showimg = document.getElementById('showimg'); 
  var shadow = showimg.getElementsByTagName('span')[0]; 
  var css_code = document.getElementById('css_code');  */
 
   var picimg = new Image();
	picimg.src = url;
 
    picimg.onload = function(e){ // reader onload start 
 
        var img_width = this.width; 
        var img_height = this.height; 
 
        // 设置画布尺寸 
        canvas.width = img_width; 
        canvas.height = img_height; 
 
         //将图片按像素写入画布 
        context.drawImage(this, 0, 0, img_width, img_height); 
 
        // 读取图片像素信息 
       var imageData = context.getImageData(0, 0, img_width, img_height); 
		//var imageData = {imgwidth:img_width,imgheight:img_height};
		callback(imageData);
 
 
      } // image onload end      
  } 
 ImageUtil.readImage = function(file,callback)
 {
        //判断file的类型是不是图片类型。
		var imageType = /image.*/;
		
        if (!file.type.match(imageType)) {
            alert("文件必须为图片！");
            return {};
        }

        var reader = new FileReader(); //声明一个FileReader实例
        reader.readAsDataURL(file); //调用readAsDataURL方法来读取选中的图像文件
        //最后在onload事件中，获取到成功读取的文件内容，并以插入一个img节点的方式显示选中的图片
        reader.onload = function (e) {
			//console.log("imgdata:" + this.result);
			
			// var img = new Image();
            // img.src = reader.result;
			 callback(reader.result);
			 
			 //img.onload = function(e){
				 
				// callback({imgwidth:img.width,imgheight:img.height});
			 //}
			
            //img.setAttribute('src',  this.result);
        }
	 
 }
 
 ImageUtil.convertImageToPng = function(imgUrl,callback)
 {
		var image1 = new Image();
		image1.src = imgUrl + '?' + new Date().getTime();
		image1.setAttribute('crossOrigin', '');

		//img[0].onload = function() {
		image1.onload = function(){
		var img_width = this.naturalWidth;
		var img_height = this.naturalHeight;
		
		if(img_width > img_height)
		{
			img_width = 800;
			img_height = img_height*img_width/this.naturalWidth;
		}
		else
		{
			img_height = 800;
			img_width = img_width*img_height/this.naturalHeight;

		}
		
		
		
		
		// 设置画布尺寸
		ImageUtil.canvas.width = img_width;
		ImageUtil.canvas.height = img_height;
		ImageUtil.myContext.clearRect(0,0,$('#my-canvas')[0].width,$('#my-canvas')[0].height);
		ImageUtil.context.clearRect(0,0,$('#my-canvas')[0].width,$('#my-canvas')[0].height);

		ImageUtil.context.drawImage(this, 0, 0, img_width, img_height);
		$('#my-canvas').attr('width',img_width);
		$('#my-canvas').attr('height',img_height);

		callback(img_width,img_height);

		// 将图片按像素写入画布

	  }
	  //img.attr('src',imgUrl);
	 
 }
 
  ImageUtil.convertImageColor = function(img,imgdata,callback)
 {
		img[0].onload = function() {
		var img_width = this.naturalWidth;
		var img_height = this.naturalHeight;
		
		
		// 设置画布尺寸
		ImageUtil.canvas.width = img_width;
		ImageUtil.canvas.height = img_height;


		ImageUtil.context.drawImage(this, 0, 0, img_width, img_height);
		$('#my-canvas').attr('width',img_width);
		$('#my-canvas').attr('height',img_height);

		callback(img_width,img_height);

		// 将图片按像素写入画布

	  }
	  img.attr('src',imgdata);
	 
 }
 
 ImageUtil.changeWhiteToTransparent = function(img_width, img_height,ismask,callback)
 {
		const rgb = [0, 0, 0,0]
		let color = []
		const imageData = ImageUtil.context.getImageData(0, 0, img_width, img_height);
		const length = imageData.data.length;
		for (let i = 0; i < length; i += 4) {
		  color.push(imageData.data[i], imageData.data[i + 1], imageData.data[i + 2]);
		  if (color[0] + color[1] + color[2] > 700  ) {
			//for (var j = 0; j < rgb.length; j++) {
			//  imageData.data[i - (rgb.length + 1 - j)] = rgb[j]
			//}
			imageData.data[i] = 0;
			imageData.data[i+1] = 0;
			imageData.data[i+2] = 0;
			imageData.data[i+3] = 0;

		  }
		  else if(ismask)
		  {
			  imageData.data[i] = 255;
			imageData.data[i+1] = 255;
			imageData.data[i+2] = 255;
			imageData.data[i+3] = 255;
		  }
		  //if (i > 0 && i % 4 === 0) { // 每四个元素为一个像素数据 r,g,b,alpha
			color = []
		  //}
		}
		ImageUtil.myContext.putImageData(imageData, 0, 0);
		this.convertImg(img_width,img_height,callback);
	 	 
 }
 
  ImageUtil.changeColor = function(img_width, img_height,yellow,callback)
 {
		const rgb = [0, 0, 0,0]
		let color = []
		const imageData = ImageUtil.context.getImageData(0, 0, img_width, img_height);
		const length = imageData.data.length;
		for (let i = 0; i < length; i += 4) {
		  color.push(imageData.data[i], imageData.data[i + 1], imageData.data[i + 2]);
		  if(imageData.data[i+3] > 200)
		  {
			  imageData.data[i] = yellow?255:0;
			imageData.data[i+1] = yellow?255:0;
			imageData.data[i+2] = 0;
			imageData.data[i+3] = 255;
		  }
		  //if (i > 0 && i % 4 === 0) { // 每四个元素为一个像素数据 r,g,b,alpha
			color = []
		  //}
		}
		ImageUtil.myContext.putImageData(imageData, 0, 0);
		this.convertImg(img_width,img_height,callback);
	 	 
 }
 
 ImageUtil.convertImg = function(picwidth,picheight,callback) {
	html2canvas(document.querySelector('#my-canvas'), {
	  useCORS: true,
	  width: picwidth,
	  scale: 1,
	  height: picheight,
	  backgroundColor: null,
	  dpi: 96
	}).then(function (canvas) {

	  var imgData = canvas.toDataURL("image/png");
	  callback(imgData);

	})
 }
package model.picmanagerModel
{
	import model.Userdata;
	
	import utils.UtilTool;

	public class PicInfoVo
	{
		public var picType:int = 0;// 0 目录 1 图片
		
		public var directName:String = "";//目录名 全目录 类似 1|2|3
		
		//public var parentDirect:String = "";
		
		public var directId:String = "";

		public var fid:String = "";
		
		public var picWidth:int;
		public var picHeight:int;
		
		public var picPhysicWidth:Number = 0;
		public var picPhysicHeight:Number = 0;
		
		public var fsize:Number = 0;
		
		public var colorspace:String = "";
		
		public var picClass:String = "";
		public var dpi:Number;
		public var isProcessing:Boolean = false;
		
		public var isCdr:Boolean = false;
		
		public var roadNum:int = 0;
		public var roadLength:int = 0;
		
		public var yixingFid:String = "";
		public var backFid:String = "";
		public var partWhiteFid:String = "";//局部铺白id
		
		public var yixingPicClass:String = "";
		public var backPicClass:String = "";
		public var partWhitePicClass:String = "";

		
		public var relatedRoadNum:int = 0;
		public var relatedRoadLength:int = 0;
		
		public var relatedPicWidth:int = 0;
		
		public var connectnum:int = 0;//连通域数量
		public var area:Number = 0;//面积
		
		public var leftDeleteDays:int = 0;
		
		public var tiaofuwidth:Number = 100;
		
		public var iswhitebg:Boolean = false;
		
		public var unwhiteratio:Number = 1;
		public var partWhiteUnWhiteRatio:Number = 1;//局部铺白遮罩图的有色面积

		public var aiPicDeadline:String;		
		
		public var hasTifAi:Boolean = false;
		
		public var relatedTimes:int = 0;//被关联次数
		//public var max
		
		public function PicInfoVo(fileinfo:Object,dtype:int)
		{
			picType = dtype;
			if(picType == 0)
			{
				directName = fileinfo.dirName;
				//parentDirect = fileinfo.dpath;
				directId = fileinfo.dirId;
			}
			else if(fileinfo != null)
			{
				fid = fileinfo.fileId;
				try
				{
					var fattr:Object = JSON.parse(fileinfo.properties);
					picWidth = Number(fattr.width);
					picHeight = Number(fattr.height);
					colorspace = fattr.colorspace;
					dpi = UtilTool.oneCutNineAdd(fattr.dpi);
					picPhysicWidth = UtilTool.oneCutNineAdd(picWidth/dpi*2.54);
					picPhysicHeight = UtilTool.oneCutNineAdd(picHeight/dpi*2.54);
					fsize = fileinfo.fsize;
					
					hasTifAi = fileinfo.approach == 2;
					yixingFid = fileinfo.maskId == null ?"0":fileinfo.maskId;
					backFid = fileinfo.backId == null ?"0":fileinfo.backId;
					partWhiteFid = fileinfo.partWhiteId == null ?"0":fileinfo.partWhiteId;

					aiPicDeadline = fileinfo.preTime;
					
					if(fileinfo.usedAt != null)
					{
						var updatetime:Date = new Date(Date.parse(UtilTool.convertDateStr(fileinfo.usedAt)));
						//updatetime.time = Date.parse(UtilTool.convertDateStr(fileinfo.fdate));
						
						var passtime:int = Math.ceil(((new Date()).getTime() - updatetime.getTime() + 8 * 3600 * 1000)/(3600*24*1000));
						
						leftDeleteDays = 30 - passtime;
						if(leftDeleteDays < 0)
							leftDeleteDays = 0;
					}
					
					if(fattr.hasOwnProperty("whitebg") && fattr.hasOwnProperty("vsize") && fattr.hasOwnProperty("hsize"))
					{
						iswhitebg = fattr.whitebg;
						if(iswhitebg)
						{
							var longside:Number = Math.max(picWidth,picHeight);

							if(this.picHeight > this.picWidth)
							{
								tiaofuwidth = (fattr.hsize/this.picWidth)*longside/1000*this.picPhysicWidth;
								
							}
							else
							{
								tiaofuwidth = (fattr.vsize/this.picHeight)*longside/1000*this.picPhysicHeight;
								
							}
						}
						
					}
					if(fattr.hasOwnProperty("roadnum")) 
					{
						roadNum = fattr.roadnum;
						var longside:Number = Math.max(picWidth,picHeight);
						roadLength = Math.floor( fattr.totallen * longside/1000);
						//trace("raodNum:" + roadNum + "," + roadLength);
					}
					if(fattr.hasOwnProperty("whiteratio") && fattr.whiteratio != "")
					{
						this.unwhiteratio = 1 - parseFloat(fattr.whiteratio);
					}
					if(fattr.hasOwnProperty("connectnum"))
					{
						connectnum = fattr.connectnum;
						var longside:Number = Math.max(picWidth,picHeight);

						area = Math.floor(fattr.area *  longside/1000 * longside/1000)/(picWidth*picHeight) * picPhysicWidth * picPhysicHeight/10000;
						//trace("connectnum:" + connectnum + "," + area);
					}
					if(fattr != null && fattr.flag == 1)
					{
						picWidth = Math.round(Number(fattr.width)*dpi/2.54);
						picHeight =  Math.round(Number(fattr.height)*dpi/2.54);
						
						picPhysicWidth = parseFloat(parseFloat(fattr.width).toFixed(2));
						picPhysicHeight = parseFloat(parseFloat(fattr.height).toFixed(2));
						
						roadLength = parseInt(fattr.totallen);
						area = parseFloat(fattr.area)/10000;
						
						tiaofuwidth = Math.min(fattr.vsize,fattr.hsize);
						
						isCdr = true;
						
					}
				}
				catch(err:Error)
				{
					isProcessing = true;
				}

				picClass = fileinfo.fileType;
				//picClass = picClass.toLocaleLowerCase();
				
				
				if(isCdr)
					picClass = "zip";
				
				if(fattr != null && fattr.flag == 1)
				{
					directName = fileinfo.name + ".cdr";
//					var strs:Array = directName.split(".");
//					 strs.splice(strs.length - 1,1);
//					directName = strs.join() + ".cdr";
				}
				else
					directName = fileinfo.name;
				//parentDirect = fileinfo.fpath;
				
			}
		}
		
		public function initYixingData():void
		{
			if(yixingFid != "0")
			{
				var info:Array = DirectoryFileModel.instance.getQiegeData(yixingFid);
				
				this.relatedRoadNum = info[0];
				this.relatedRoadLength = info[1];
				this.relatedPicWidth = info[2];
				this.yixingPicClass = info[3];

			}
			
			if(backFid != "0")
			{
				var info:Array = DirectoryFileModel.instance.getQiegeData(backFid);
								
				this.backPicClass = info[3];
				
			}
			if(partWhiteFid != "0")
			{
				var info:Array = DirectoryFileModel.instance.getQiegeData(partWhiteFid);
				
				this.partWhitePicClass = info[3];
				this.partWhiteUnWhiteRatio= info[4];

			}
			
		}
		public function get dpath():String
		{
			//return parentDirect + directId + "|";
			return  directId;
		}
		
		public function get tailFix():String
		{
			if(picClass.toUpperCase() == "PNG")
				return ".png";
			else if((picClass.toUpperCase() == "TIF" || picClass.toUpperCase() == "TIFF") && hasTifAi)
				return ".png";
			
			else return ".jpg";
		}
	}
}
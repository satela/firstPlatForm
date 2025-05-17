package utils
{
	
	import laya.filters.ColorFilter;
	import laya.maths.Point;
	import laya.net.LocalStorage;
	import laya.utils.Browser;
	
	import model.Userdata;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PicOrderItemVo;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.common.TipPanelUI;

	public class UtilTool
	{
		public static function oneCutNineAdd(fnum:Number):Number
		{
			var numstr:String = fnum.toFixed(1);
			var dotnum:int = parseInt(numstr.split(".")[1]);
			
			if(dotnum == 1)
				return parseInt(numstr.split(".")[0]);
			else if(dotnum == 9)
				return parseInt(numstr.split(".")[0]) + 1;
			else
				return parseFloat(numstr);

		}
		private var tipspanel:TipPanelUI;
		
		private static var grayscaleMat:Array = [
			0.3086, 0.6094, 0.0820, 0, 0, 
			0.3086, 0.6094, 0.0820, 0, 0, 
			0.3086, 0.6094, 0.0820, 0, 0, 
			0, 0, 0, 1, 0];
		
		//创建一个颜色滤镜对象，灰图
		public static var grayscaleFilter:ColorFilter = new ColorFilter(grayscaleMat);
		
		
		private static var blackscaleMat:Array = [
			0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 
			0, 0, 0, 0, 0, 
			0, 0, 0, 1, 0];
		
		//创建一个颜色滤镜对象，灰图
		public static var blackscaleFilter:ColorFilter = new ColorFilter(blackscaleMat);
		
		/**
		 *获取本地记录的内容 
		 * @param key
		 * @param defaultValue 默认值，会根据默认值int,float,string自动格式化返回值
		 * @return 
		 * 
		 */		
		public static function getLocalVar(key:String,defaultValue:*= null):*{
			var v:String=laya.net.LocalStorage.getItem(key);
			if(v===null){
				if(defaultValue==null)return null;
				v=defaultValue;
				laya.net.LocalStorage.setItem(key,v+"");
				return v;
			}
			
			if(defaultValue!=null)if(Math.floor(defaultValue)===defaultValue){
				if(v == "")
					v = "0"
				return parseInt(v); 
			}else if (parseFloat(defaultValue+"")===defaultValue){
				if(v == "")
					v = "0"
				return parseFloat(v);
			}
			return v;
		}
		public static function setLocalVar(key:String,value:*):void{
			//清除
			if(value==null){
				removeLocalVar(key);
				return;
			}
			LocalStorage.setItem(key,value+"");
		}
		public static function removeLocalVar(key:String):void{
			LocalStorage.removeItem(key);
		}
		
		public static function formatFullDateTime(date:Date,isFull:Boolean = true):String  
		{  
			var datestr:String = "";
			datestr += date.getFullYear() + "-" ;
			if((date.getMonth()+1) >= 10)
				datestr += (date.getMonth()+1) + "-";
			else
				datestr += "0" + (date.getMonth()+1) + "-";
			
			if(date.getDate() >= 10)
				datestr += date.getDate();
			else
				datestr += "0" + date.getDate();
			if(isFull == false)
				return datestr;
			
			datestr += " ";
			
			
			if(date.getHours() >= 10)
				datestr += date.getHours() + ":";
			else
				datestr += "0" + date.getHours() + ":";
			
			if(date.getMinutes() >= 10)
				datestr += date.getMinutes() + ":";
			else
				datestr += "0" + date.getMinutes() + ":";
			
			if(date.getSeconds() >= 10)
				datestr += date.getSeconds();
			else
				datestr += "0" + date.getSeconds();
			return datestr;
		}  
		
		public static function checkFileIsImg(picInfo:PicInfoVo):Boolean
		{
			if(picInfo.picType == 0 ||(picInfo.picClass.toLocaleUpperCase() != "JPEG" && picInfo.picClass.toLocaleUpperCase() != "JPG" && picInfo.picClass.toLocaleUpperCase() != "TIF" && picInfo.picClass.toLocaleUpperCase() != "TIFF" && picInfo.picClass.toLocaleUpperCase() != "PNG" && picInfo.isCdr == false))
				return false;
			else return true;

		}
		public function UtilTool()
		{
		}
		
		public static function getYixingImageCount(url:String,caller:*):void
		{
			Browser.window.picProcess = UtilTool;
			Browser.window.getImagePixels(url);
		}
		
		public static function getYixingImageInfo(imgdata:*):void
		{
			var pixelsArr:Array = imgdata.data;
			var imgwidth:int = imgdata.width;
			var imgheight:int = imgdata.height;
			
			var pixelVec:Array = new Array(imgheight);
			var temparr:Array = new Array(imgheight);

			var rowBlot:Array = new Array(imgheight);
			var blotIndex:int = 1;
			var allblotindex:Array = [];
			var equalBlot:Object = {};
			
			var areanum:int = 0;
			
			for(var i:int=0;i < imgheight;i++)
			{
				pixelVec[i] = new Array(imgwidth);
				temparr[i] = new Array(imgwidth);
				
				rowBlot[i] = [];

				for(var j:int=0;j < imgwidth;j++)
				{
					var startindex:int = (i*imgwidth + j)*4;
					pixelVec[i][j] = pixelsArr[startindex] +  pixelsArr[startindex+1] + pixelsArr[startindex+2];
					
					//if(Math.abs((pixelsArr[startindex] - pixelsArr[startindex + 1])) >= 20 || Math.abs((pixelsArr[startindex] - pixelsArr[startindex + 2])) >= 20)
					//	trace("jjjj sec" +  pixelsArr[startindex] + "," +  pixelsArr[startindex+1] + "," +  pixelsArr[startindex+2]);
					if(pixelVec[i][j] > 200)
						pixelVec[i][j] = 1;
					else
					{
						pixelVec[i][j] = 0;
						areanum++;
					}
					temparr[i][j] = pixelVec[i][j];
					if(pixelVec[i][j] == 0 )
					{
						if(rowBlot[i].length == 0)
						{
							rowBlot[i].push({start:j,end:j,blot:blotIndex});
							blotIndex++;
						}
						else
						{
							if(j-1 == rowBlot[i][rowBlot[i].length - 1].end)
							{
								rowBlot[i][rowBlot[i].length - 1].end = j;						
							}
							else
							{
								rowBlot[i].push({start:j,end:j,blot:blotIndex});
								blotIndex++;
							}
						}
					}
										
				}
				
				for(m=0;m < rowBlot[i].length;m++)
					allblotindex.push(rowBlot[i][m].blot);
				
				
				if(i > 0 && rowBlot[i].length > 0 && rowBlot[i - 1].length > 0 )
				{
					for(var m:int=0;m < rowBlot[i].length;m++)
					{
						var start:int = rowBlot[i][m].start;
						var end:int = rowBlot[i][m].end;
						var connectBlot:Array = [];
						
						for(var n:int=0;n < rowBlot[i - 1].length;n++)
						{
							if(start > rowBlot[i - 1][n].end+1 || end < rowBlot[i - 1][n].start-1)
								continue;
							else if(connectBlot.indexOf(rowBlot[i - 1][n].blot) < 0 )
								connectBlot.push(rowBlot[i - 1][n].blot);
						}
						
						if(connectBlot.length > 0)
						{
							if(allblotindex.indexOf(rowBlot[i][m].blot) >= 0)
								allblotindex.splice(allblotindex.indexOf(rowBlot[i][m].blot),1);
							
							connectBlot.sort();
							rowBlot[i][m].blot = connectBlot[0];
							if(connectBlot.length > 1)
							{
								if(!equalBlot.hasOwnProperty(connectBlot[0]))
									equalBlot[connectBlot[0]] = [];
								
								for(n=1;n < connectBlot.length;n++)
								{
									if(equalBlot[connectBlot[0]].indexOf(connectBlot[n]) < 0)
										equalBlot[connectBlot[0]].push(connectBlot[n]);
								}
								
							}
							
						}
						
						
					}
				}
				
			}
			
			
			for(var i:int=1;i < imgheight - 1;i++)
			{
				for(var j:int=1;j < imgwidth - 1;j++)
				{
					if(pixelVec[i][j] == 0)
					{
						var eightnei:int = pixelVec[i-1][j-1] + pixelVec[i-1][j] + pixelVec[i-1][j+1] + pixelVec[i][j+1] + pixelVec[i][j-1] + pixelVec[i+1][j-1] + pixelVec[i+1][j] + pixelVec[i+1][j+1];
						if(eightnei == 0)
						{
							temparr[i][j] = 1;
						}
					}
					
				}
			}
			
			
			var allEqualBlot:Array = [];
			for(var startblotindex in equalBlot)
			{
				var hasfind:Boolean = false;
				var startblot:int = Number(startblotindex);
				var hasFindBlotIndex:int = -1;
				for(var i:int=0;i < allEqualBlot.length;i++)
				{
					var equalline:Array = allEqualBlot[i];
					if(equalline.indexOf(startblot) >= 0)
					{
						hasfind = true;
						break;						
					}
					var sameblot:Array = equalBlot[startblotindex];
					for(var j:int=0;j < sameblot.length;j++)
					{
						if(equalline.indexOf(sameblot[j]) >= 0)
						{
							hasfind = true;
							hasFindBlotIndex = i;
							break;
							//break;
						}
					}
					
				}
				if(hasfind && hasFindBlotIndex == -1)
					continue;
				else
				{
					var templine:Array;
					if(hasFindBlotIndex != -1)
						templine = allEqualBlot[hasFindBlotIndex];
					else
						templine = [];
					if(templine.indexOf(startblot) < 0)
						templine.push(startblot);
					
					var equalarr:Array = getEqualBlot(equalBlot[startblotindex],equalBlot);
					//templine.concat(equalarr);
					if(hasFindBlotIndex == -1)
						allEqualBlot.push(templine.concat(equalarr));
					else
						allEqualBlot[hasFindBlotIndex] = templine.concat(equalarr);
					
				}
			}
			
			var blotnum:int = 0;
			for(var i:int=0; i < allblotindex.length;i++)
			{
				
				var inequal:Boolean = false;
				for(var j:int=0;j < allEqualBlot.length;j++)
				{
					if(allEqualBlot[j].indexOf(allblotindex[i]) >= 0)
					{
						inequal = true;
						break;
					}
				}
				if(inequal == false)
					blotnum++;
			}
			trace("面积：" + areanum);
			trace("连通域数量:" + (blotnum + allEqualBlot.length));
			
		}
		
		public static function getCutCountLength(imgdata:*):void
		{
			var pixelsArr:Array = imgdata.data;
			var imgwidth:int = imgdata.width;
			var imgheight:int = imgdata.height;
			
			var pixelVec:Array = new Array(imgheight);
			var temparr:Array = new Array(imgheight);
			
			
			var str:String = "";
			
			for(var i:int=0;i < 20000;i++)
			{											
				str += pixelsArr[i] + " ";
			}
			
			trace(str);
			
			for(var i:int=0;i < imgheight;i++)
			{
				pixelVec[i] = new Array(imgwidth);
				temparr[i] = new Array(imgwidth);
								
				for(var j:int=0;j < imgwidth;j++)
				{
					var startindex:int = (i*imgwidth + j)*4;
					pixelVec[i][j] = pixelsArr[startindex] +  pixelsArr[startindex+1] + pixelsArr[startindex+2];
									
					if(pixelVec[i][j] > 200)
						pixelVec[i][j] = 1;
					else
						pixelVec[i][j] = 0;
					temparr[i][j] = pixelVec[i][j];					
					
				}				
				
			}
//			var str:String = "";
//			for(var i:int=0;i < imgheight;i++)
//			{
//				
//				for(var j:int=0;j < imgwidth;j++)
//				{
//					str += 	pixelVec[i][j] + " ";			
//					
//				}				
//				str += "\n";
//			}
//			
//			trace(str);
			
			for(var i:int=1;i < imgheight - 1;i++)
			{
				for(var j:int=1;j < imgwidth - 1;j++)
				{
					if(pixelVec[i][j] == 0)
					{
						var eightnei:int = pixelVec[i-1][j-1] + pixelVec[i-1][j] + pixelVec[i-1][j+1] + pixelVec[i][j+1] + pixelVec[i][j-1] + pixelVec[i+1][j-1] + pixelVec[i+1][j] + pixelVec[i+1][j+1];
						if(eightnei == 0)
						{
							temparr[i][j] = 1;
						}
					}
					
				}
			}
			var edgenum:int = 0;
			
			var allcutRoad:Array;
			var roadindex:int = 3;
			var curRouteDic:Object = {};
			var roadNum:int = 0;
			var totalLength:int = 0;
			
			for(var i:int=0;i < imgheight;i++)
			{
				for(var j:int=0;j < imgwidth;j++)
				{
					if(temparr[i][j] == 0)
					{
						
						curRouteDic = {};
						edgenum++;
						var backtimes:int = 0;
						var pathroute:Array = [];
						var nextpoint:Point = getNextCutPoint(i,j,temparr,imgwidth,imgheight,curRouteDic);
						
						while(nextpoint != null && (nextpoint.x != i || nextpoint.y != j))
						{
													
							if(curRouteDic[(nextpoint.x+"_" + nextpoint.y)] == null)
							{
								curRouteDic[(nextpoint.x+"_" + nextpoint.y)] = 1;
								pathroute.push(nextpoint);

							}
							nextpoint = getNextCutPoint(nextpoint.x,nextpoint.y,temparr,imgwidth,imgheight,curRouteDic);
							if(nextpoint == null)
							{
								backtimes++;
								var lastpoint:Point = pathroute[pathroute.length - 1];
								
								temparr[lastpoint.x][lastpoint.y] = 1;
								pathroute.splice(pathroute.length - 1,1);
								if(pathroute.length > 0)
								{
									nextpoint = pathroute[pathroute.length - 1];
								}
							}
							else
							{
								backtimes = 0;
							}
							if(backtimes > 30)
							{
								break;
								trace("back");
							}
							
						}
						
						if(nextpoint != null && nextpoint.x == i && nextpoint.y == j && pathroute.length > 5)
						{
							temparr[i][j] = roadindex;
							for(var m:int=0;m < pathroute.length;m++)
								temparr[pathroute[m].x][pathroute[m].y] = roadindex;
							roadNum++;
							totalLength += pathroute.length;
							
							var endpoint:Point = pathroute[pathroute.length - 1];						
							trace("找到路径：" + roadindex + "，起始点" + "[" + i + "," + j + "]" + "终点:" + "[" + endpoint.x + "," + endpoint.y + "]" );
							trace("路径长度:" + (pathroute.length - 1));
							roadindex++;	
						}
					}
				}
				
			}
			
		
			trace("边缘数量：" + totalLength + ",路径数：" + roadNum);
			
		}
		
		private static function getNextCutPoint(row:int,column:int,imgdata:Array,imgwidth:int,imgheight:int,haspassRoute:Object):Point
		{
			var upcenter:int = -1;
			var upright:int = -1;
			var rightpx:int = -1;
			var rightdown:int = -1;
			var centerdown:int = -1;
			var leftdown:int = -1;
			var leftcenter:int = -1;
			var leftup:int = -1;
			
			if(row > 0)
			{
				upcenter = imgdata[row-1][column];
				if(column < imgwidth - 1)
					upright = imgdata[row-1][column+1];
				if(column > 0 )
					leftup = imgdata[row-1][column - 1];
			}
			if(row < imgheight - 1)
			{
				centerdown = imgdata[row+1][column];
				if(column < imgwidth - 1)
					rightdown =  imgdata[row+1][column+1];
				if(column > 0 )
					leftdown = imgdata[row+1][column - 1];
			}
			
			if(column > 0)
				leftcenter = imgdata[row][column - 1];
			
			if(column < imgwidth - 1)
				rightpx =  imgdata[row][column+1];
			
			var nextpoint:Point;
			if(upright == 0 && haspassRoute.hasOwnProperty((row-1) + "_" +(column+1)) == false)
			{
				//imgdata[row-1][column] = 1;
				nextpoint = new Point(row-1,column+1);
				return nextpoint;
			}
			if(upcenter == 0 && haspassRoute.hasOwnProperty((row-1) + "_" +(column)) == false)
			{
				nextpoint = new Point(row-1,column);
				return nextpoint;
			}
			
			if(rightpx == 0 && haspassRoute.hasOwnProperty((row) + "_" +(column+1)) == false)
			{
				nextpoint = new Point(row,column+1);
				return nextpoint;
			}
			
		
			if(rightdown == 0 && haspassRoute.hasOwnProperty((row+1) + "_" +(column+1)) == false)
			{
				//imgdata[row][column + 1] = 1;
				nextpoint = new Point(row+1,column+1);
				return nextpoint;
			}
			
			
			if(centerdown == 0 && haspassRoute.hasOwnProperty((row+1) + "_" +(column)) == false)
			{
				nextpoint = new Point(row+1,column);
				return nextpoint;
			}
			
			if(leftdown == 0 && haspassRoute.hasOwnProperty((row+1) + "_" +(column-1)) == false)
			{
				//imgdata[row+1][column] = 1;			
				nextpoint = new Point(row+1,column - 1);
				return nextpoint;
			}
			
			
			if(leftcenter == 0 && haspassRoute.hasOwnProperty((row) + "_" +(column - 1)) == false)
			{
				nextpoint = new Point(row,column - 1);
				return nextpoint;
			}
			
			if(leftup == 0 && haspassRoute.hasOwnProperty((row-1) + "_" +(column-1)) == false)
			{
				nextpoint = new Point(row - 1,column - 1);
				return nextpoint;
			}
			
			
			return null;
			
		}
		
		public static function getEightNeighbourSum(row:int,column:int,imgdata:Array,imgwidth:int,imgheight:int):int
		{
			var upcenter:int = -1;
			var upright:int = -1;
			var rightpx:int = -1;
			var rightdown:int = -1;
			var centerdown:int = -1;
			var leftdown:int = -1;
			var leftcenter:int = -1;
			var leftup:int = -1;
			
			if(row > 0)
			{
				upcenter = imgdata[row-1][column];
				if(column < imgwidth - 1)
					upright = imgdata[row-1][column+1];
				if(column > 0 )
					leftup = imgdata[row-1][column - 1];
			}
			if(row < imgheight - 1)
			{
				centerdown = imgdata[row+1][column];
				if(column < imgwidth - 1)
					rightdown =  imgdata[row+1][column+1];
				if(column > 0 )
					leftdown = imgdata[row+1][column - 1];
			}
			
			if(column > 0)
				leftcenter = imgdata[row][column - 1];
			
			if(column < imgwidth - 1)
				rightpx =  imgdata[row][column+1];
			
			return upcenter + rightdown + rightpx + leftcenter + leftdown + leftup + centerdown + upright;
		}
		public static function getEqualBlot(blotindexArr:Array,equalblot:Object):Array
		{
			var temp:Array = [];
			for(var i:int=0;i < blotindexArr.length;i++)
			{
				temp.push(blotindexArr[i]);
				if(equalblot.hasOwnProperty(blotindexArr[i]))
				{
					temp = temp.concat(getEqualBlot(equalblot[blotindexArr[i]],equalblot));
				}
				
			}
			
			return temp;
			
		}
		public static function getPaintingPrice(unitprice:Number,baseprice:Number,ratio:Number,picwidth:Number,picheight:Number):Number
		{
			if(ratio != NaN)
				return baseprice + unitprice * ratio * picwidth * picheight;
			else
				return baseprice + unitprice * 1 * picwidth * picheight;

		}
		public static function getProcessPrice(picwidth:Number,picheight:Number,unit:String,unitprice:Number,baseprice:Number):Number
		{
			if(unitprice < 0)
				return 0;
			
			if(unit == OrderConstant.MEASURE_UNIT_FOUR_SIDE)
			{
				var perimeter:Number = 2 * (picwidth + picheight);
				return baseprice + unitprice*perimeter;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_SIDE)
			{
				var longside:Number = Math.max(picwidth,picheight);
				return baseprice + unitprice*longside;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_TOP_BOTTOM)
			{
				var btsum:Number = picwidth + picwidth;
				return baseprice + unitprice*btsum;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LEFT_RIGHT)
			{
				var lrsum:Number = picheight + picheight;
				return baseprice + unitprice*lrsum;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_TWO_SIDE)
			{
				var longside:Number = Math.max(picwidth,picheight);
				return baseprice + unitprice*longside;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_PERIMETER)
			{
				 perimeter = 2 * (picwidth + picheight);
				return baseprice + unitprice*perimeter;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_AREA)
			{
				var area:Number = picwidth * picheight;
				return baseprice + unitprice*area;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LEFT_HEIGHT || unit == OrderConstant.MEASURE_UNIT_RIGHT_HEIGHT)
			{
				var len:Number = picheight;
				return baseprice + unitprice*len;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_TOP_LEN || unit == OrderConstant.MEASURE_UNIT_BOTTOM_LEN)
			{
				var len:Number = picwidth;
				return baseprice + unitprice*len;
			}
			else if(isMeasureUnitByNum(unit))
			{				
				return  unitprice;
			}
			else return 0;
		}
		
		public static function getMaterialWight(picwidth:Number,picheight:Number,unit:String,unitweight:Number):Number
		{
			if(unitweight <= 0)
				return 0;
			
			if(unit == OrderConstant.MEASURE_UNIT_FOUR_SIDE)
			{
				var perimeter:Number = 2 * (picwidth + picheight);
				return  unitweight*perimeter;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_SIDE)
			{
				var longside:Number = Math.max(picwidth,picheight);
				return unitweight*longside;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_TOP_BOTTOM)
			{
				var btsum:Number = picwidth + picwidth;
				return unitweight*btsum;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LEFT_RIGHT)
			{
				var lrsum:Number = picheight + picheight;
				return unitweight*lrsum;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_TWO_SIDE)
			{
				var longside:Number = Math.max(picwidth,picheight);
				return  unitweight*longside*2;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_PERIMETER)
			{
				perimeter = 2 * (picwidth + picheight);
				return unitweight*perimeter;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_AREA)
			{
				var area:Number = picwidth * picheight;
				return unitweight*area;
			}
			else if(isMeasureUnitByNum(unit))
			{				
				return  unitweight;
			}
			else return 0;
		}
		
		public static function getCarvingPrice(area:Number,unit:String,unitprice:Number,baseprice:Number):Number
		{
			return baseprice + unitprice * area;
			
		}
		
		public static function getYixingPrice(picinfo:PicInfoVo,basePrice:Number,unitPrice:Number,finalwidth:Number,finalheight:Number):Number
		{			
			var linemeter:Number = (picinfo.relatedRoadLength /picinfo.relatedPicWidth)  * finalwidth;
			
			//var linemeter1:Number = (picinfo.relatedRoadLength / picinfo.relatedDpi * 2.54) * (finalwidth/picinfo.picPhysicWidth);
			
			//trace("line1:" + linemeter + "," + linemeter1);

			
			return basePrice * picinfo.relatedRoadNum + linemeter*unitPrice;
		}
		
		public static function getAvgCutPrice(orderitem:PicOrderItemVo,basePrice:Number,unitPrice:Number,finalwidth:Number,finalheight:Number):Number
		{			
			var linemeter:Number = orderitem.horiCutNum * finalwidth + orderitem.verCutNum * finalheight;
			
			return basePrice * orderitem.horiCutNum * orderitem.verCutNum + linemeter*unitPrice;
		}
		
		public static function isMeasureUnitByNum(unit:String):Boolean
		{
			return unit == OrderConstant.MEASURE_UNIT_SINGLE_NUM || unit == OrderConstant.MEASURE_UNIT_SINGLE_SUIT || unit == OrderConstant.MEASURE_UNIT_SINGLE_TAO;
		}
		
		public static function isValidPic(picInfo:PicInfoVo):Boolean
		{
			if(picInfo.colorspace.toUpperCase() != "CMYK" && picInfo.colorspace.toUpperCase() != "GRAY" && picInfo.colorspace.toUpperCase() != "SRGB")
				return false;
			
			var validClass:Array = ["JPG","JPEG","TIF","TIFF","ZIP","PNG"];
			if(validClass.indexOf(picInfo.picClass.toLocaleUpperCase()) < 0)
				return false;
			if(picInfo.picClass.toLocaleUpperCase() == "ZIP" && picInfo.directName.indexOf(".cdr") < 0)
				return false;
			
			return true;
		}
		
		//图片大小异常
		public static function isUnNormalPic(picInfo:PicInfoVo):Boolean
		{
			
			var validClass:Array = ["JPG","TIF","TIFF"];
			if(validClass.indexOf(picInfo.picClass.toLocaleUpperCase()) < 0)
				return false;
			var maxsize:Number = (picInfo.picWidth * picInfo.picHeight * 3 + 1024*1024) * 3;
			
			return picInfo.fsize > maxsize;
		}
		
		public static function isValidPicZipai(picinfo:PicInfoVo):Boolean
		{
			if(picinfo.picClass.toLocaleUpperCase() != "ZIP" || !picinfo.isCdr)
			{
				return false;
			}
			else
				return true;
		}
		public static function isFitYixing(sourcefile:PicInfoVo,selfile:PicInfoVo,yixing:int=1):Boolean
		{
			if(sourcefile != null && selfile != null)
			{
//				if(selfile.roadNum <= 0)
//				{
//					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"该图片不符合异形切割图片要求"});
//					return false;
//
//				}
				var xdif:Number = Math.abs(sourcefile.picPhysicWidth - selfile.picPhysicWidth)/sourcefile.picPhysicWidth;
				var ydif:Number = Math.abs(sourcefile.picPhysicHeight - selfile.picPhysicHeight)/sourcefile.picPhysicHeight;
				if(xdif >0.01 || ydif > 0.01)
				{
					//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图片尺寸不匹配"});
					
					return false;
				}
				if(selfile.colorspace.toLocaleUpperCase() != "GRAY" && !selfile.isCdr)
				{
//					if(yixing == 1)
//						ViewManager.showAlert("异形图片必须是灰度格式或者cdr文件");
//					else
//						ViewManager.showAlert("局部铺白图片必须是灰度格式或者cdr文件");

					return false;
				}
				return true;
				
			}
			return false;
		}
		
		public static function isFitFanmain(sourcefile:PicInfoVo,selfile:PicInfoVo):Boolean
		{
			if(sourcefile != null && selfile != null)
			{
				if(selfile.colorspace != "CMYK")
				{
					//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"反面图片必须是CMYK格式"});

					return false;
				}
				var xdif:Number = Math.abs(sourcefile.picPhysicWidth - selfile.picPhysicWidth)/sourcefile.picPhysicWidth;
				var ydif:Number = Math.abs(sourcefile.picPhysicHeight - selfile.picPhysicHeight)/sourcefile.picPhysicHeight;
				if(xdif >0.01 || ydif > 0.01)
				{
					//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图片尺寸不匹配"});
					
					return false;
				}
				return true;
				
			}
			return false;
		}
		
		public static function getBorderDistance(proclist:Vector.<MaterialItemVo>):int
		{
			for(var i:int=0;i < proclist.length;i++)
			{
				if(proclist[i].attachmentList.indexOf("SPlb-5") >=0)
					return 10;
				if(proclist[i].attachmentList.indexOf("SPlb-10") >=0)
					return 20;
				if(proclist[i].attachmentList.indexOf("SPlb-15") >=0)
					return 30;
			}
			
			return 0;
		}
		
		public static function getAttachDesc(matvp:MaterialItemVo):String
		{
			for(var i:int=0;i < matvp.attachmentList.length;i++)
			{
				if(matvp.attachmentList[i].indexOf("SPlb") >= 0)
				
					return "(" + matvp.attachmentList + ")";
				
			}
			 return "";
			
		}
		
		public static function hasChaofuProcess(proclist:Vector.<MaterialItemVo>):Boolean
		{
			
			for(var i:int=0;i < proclist.length;i++)
			{
				if(proclist[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >= 0)
					return true;
			}
			
			return false;
			
		}
		

		public static function getNextFiveDays(curday:String):Array
		{
			var curdate:Date = new Date(Date.parse(convertDateStr(curday)));
			var arr:Array = [];
			
			for(var i:int=1;i <= 5;i++)
			{
				var date:Date = new Date(curdate.getTime() + 24 * 3600 * i * 1000);
				var curmonth:int =  date.getMonth() + 1;
				var tempstr:String = curmonth > 9?curmonth.toString():("0" + curmonth.toString()) + "";
				
				tempstr += "-";
				
				tempstr += date.getDate() > 9 ?date.getDate():("0" + date.getDate());
				arr.push(tempstr);
			}
			
			return arr;
		}
		
		public static function getNextDayStr(curday:String):String
		{
			var curdate:Date = new Date(Date.parse(convertDateStr(curday)));
					
			var date:Date = new Date(curdate.getTime() + 24 * 3600 * 1000);
			
			var yearmonth:String = formatFullDateTime(date,false);
			
			return yearmonth.substr(5,5);
		}
		
		
		public static function getAmoutByUnit(picwidth:Number,picheight:Number,unit:String):Number
		{
						
			if(unit == OrderConstant.MEASURE_UNIT_FOUR_SIDE)
			{
				return 2 * (picwidth + picheight);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_SIDE)
			{
				return  Math.max(picwidth,picheight);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_TOP_BOTTOM)
			{
				return (picwidth + picwidth);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LEFT_RIGHT)
			{
				return (picheight + picheight);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LONG_TWO_SIDE)
			{
				return Math.max(picwidth,picheight);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_PERIMETER)
			{
				return 2 * (picwidth + picheight);
			}
			else if(unit == OrderConstant.MEASURE_UNIT_AREA)
			{
				return picwidth * picheight;
			}
			else if(unit == OrderConstant.MEASURE_UNIT_LEFT_HEIGHT)
			{
				return picheight;
			}
			else if(isMeasureUnitByNum(unit))
			{				
				return  1;
			}
			else return 0;
		}
		
		public static function needChooseAttachPic(matvo:MaterialItemVo):Boolean
		{
			if(matvo.attachmentList.indexOf(OrderConstant.ATTACH_PJZZ) >=0 || matvo.attachmentList.indexOf(OrderConstant.ATTACH_PJSM) >=0)
				return true;
			else
				return false;
			
		}
		
		public static function convertDateStr(dateStr:String):String{
			var strArr:Array = dateStr.split(" ");
			var fStr:String = "{0} {1} {2}";
			return format(fStr, (strArr[0] as String).split("-").join("/"), strArr[1], "GMT+0800");
		}

		public static function getCountDownString(lefttime:int):String
		{
			var min:int = Math.floor(lefttime/60);
			
			var second:int = lefttime%60;
			
			var timestr:String = "";
			if(min > 9)
				timestr += min;
			else
				timestr += "0" + min;
			
			if(second > 9)
				timestr += ":" + second;
			else
				timestr += ":0" + second;
			
			return timestr;
			
		}
		/**以前的format文章中的方法*/
		public static function format(str:String, ...args):String{
			for(var i:int = 0; i<args.length; i++){
				str = str.replace(new RegExp("\\{" + i + "\\}", "gm"), args[i]);
			}
			return str;
		}
		
		private var _serverTime:Number = 0;//服务器时间
		
		public function get unixSeverTime():Number
		{
			return _serverTime;
		}
		
		public function set unixSeverTime(value:Number):void
		{
			_serverTime = value;
			

		}
		
		private function startTimeTick():void
		{
			
			Laya.timer.loop(1000,this,timeTick);
			
		}
		
		private function stopTimeTick():void
		{
			Laya.timer.clear(this,timeTick);

		}
		private function timeTick():void
		{
			_serverTime += 1;
		}
		//获取服务器时间 星期几
		public function getSerVerDay():int
		{
			var date:Date = new Date(_serverTime * 1000);
			
			return date.getDay();
		}
		
		public static function stringIsEmpty(str:String):Boolean
		{
			return str == null || str == "";
		}

		public static function hasForbidenChars(content:String):Boolean
		{
			return content.indexOf("/") >= 0 || content.indexOf("\\") >= 0 || content.indexOf("*")  >= 0 || content.indexOf("\"") >= 0 || content.indexOf("\t") >= 0;

		}
		
		public static function uuid() {
			var s = [];
			var hexDigits = "0123456789abcdef";
			for (var i = 0; i < 36; i++) {
				s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
			}
			s[14] = "4"; // bits 12-15 of the time_hi_and_version field to 0010
			s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1); // bits 6-7 of the clock_seq_hi_and_reserved to 01
			s[8] = s[13] = s[18] = s[23] = "-";
			
			var uuid = s.join("");
			return uuid;
		}
		
		public static function getVerifyCodes(num:int):Array
		{
			
			var allCodes:Array = ["a","b","c","d","e","f","g","h","j","k","m","n","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","J","K","M","N","P","Q","R","S","T","U","V","W","X","Y","Z"];
			var result:Array = [];
			for(var i:int=0;i < num;i++)
			{
				result.push(allCodes[Math.floor(Math.random() * allCodes.length)]);
			}
			
			return result;
		
		}
		
		public static function isValidString(str):Boolean {
			
			return true;
			
			const pattern = /^[a-zA-Z0-9\u4e00-\u9fa5,.()\[\]{}<>\|+=_-]+$/;
			return pattern.test(str);
		}
	
		public static function isEmojiCharacter(substring:String){
			if(substring){
				var reg = new RegExp("[~#^$@%&!?%*]", 'g');
				if (substring.match(reg)) {
					return true;
				}
				
				 reg = /[\uD83C[\uDF00-\uDFFF]|\uD83D[\uDC00-\uDE4F]/;
				
				if(reg.test(substring)){
					return true;
				}
				
				for ( var i = 0; i < substring.length; i++) {
					var hs = substring.charCodeAt(i);
					if (0xd800 <= hs && hs <= 0xdbff) {
						if (substring.length > 1) {
							var ls = substring.charCodeAt(i + 1);
							var uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
							if (0x1d000 <= uc && uc <= 0x1f77f) {
								return true;
							}
						}
					} else if (substring.length > 1) {
						var ls = substring.charCodeAt(i + 1);
						if (ls == 0x20e3) {
							return true;
						}
					} else {
						if (0x2100 <= hs && hs <= 0x27ff) {
							return true;
						} else if (0x2B05 <= hs && hs <= 0x2b07) {
							return true;
						} else if (0x2934 <= hs && hs <= 0x2935) {
							return true;
						} else if (0x3297 <= hs && hs <= 0x3299) {
							return true;
						} else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030
							|| hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b
							|| hs == 0x2b50) {
							return true;
						}
					}
				}
			}
		};


	}
}
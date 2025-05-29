package script.order
{
	import laya.display.Input;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.TextInput;
	
	import model.HttpRequestUtil;
	import model.orderModel.CutImageData;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	import model.orderModel.ProductVo;
	
	import ui.order.CutImageItemUI;
	
	public class ImageCutItem extends CutImageItemUI
	{
		private var cutdata:CutImageData;
		
		//private var matvo:MaterialItemVo;
		//private var param:Object;
		private var leastCutNum:int;
		
		private var cuttype:int;
		
		private var linelist:Vector.<Sprite>;
		private var linenum:int = 19;
		
		private var color1:String = "#000000";
		
		private var color2:String = "#ffffff";
		
		private var linethick:int = 2;
		
		private var curColorIndex:int = 0;
		
		private var hinputlist:Vector.<TextInput>;
		private var vinputlist:Vector.<TextInput>;

		private var inputCount:int = 7;
		
		private var horiCutNumBtnList:Array;
		
		private var vertCutNumBtnList:Array;

		private var horiCutLen:Number = 120;
		private var vertCutLen:Number = 120;
		
		public function ImageCutItem()
		{
			linelist = new Vector.<Sprite>();

			
			super();
			
			hinputlist = new Vector.<TextInput>();
			vinputlist = new Vector.<TextInput>();
			horiCutNumBtnList = [];
			vertCutNumBtnList = [];
			for(var i:int=0;i < inputCount;i++)
			{
				hinputlist.push(this["hinput" + i]);
				vinputlist.push(this["vinput" + i]);
				
				hinputlist[i].on(Event.INPUT,this,onHoriInput,[i]);
				vinputlist[i].on(Event.INPUT,this,onVertInput,[i]);
				
				hinputlist[i].type = Input.TYPE_NUMBER;
				vinputlist[i].type = Input.TYPE_NUMBER;

			}
			
			for(var i:int=0;i < 5;i++)
			{
				horiCutNumBtnList.push(this["hori" + i]);
				vertCutNumBtnList.push(this["vert" + i]);
				
				horiCutNumBtnList[i].on(Event.CLICK,this,onHoriNumChange,[i]);
				vertCutNumBtnList[i].on(Event.CLICK,this,onVertNumChange,[i]);
				
				
				
			}
			
			cutNumInput.maxChars = 2;
			
			//cuttyperad.on(Event.CHANGE,this,onCutTypeChange);
			//cutnumrad.on(Event.CHANGE,this,onCutNumChange);
			cutNumInput.on(Event.INPUT,this,onNumberChange);
			vertCutNumInput.on(Event.INPUT,this,onVertNumberChange);
			horiCutWidthRdo.on(Event.CHANGE,this,onChangeHoriCutLength);
			vertCutWidthRdo.on(Event.CHANGE,this,onChangeVertCutLength);

		}
		
		public function setData(data:*):void
		{
			cutdata = data;
						
			
			
			//cuttyperad.selectedIndex = cutdata.orderitemvo.cuttype;

			cuttype = cutdata.orderitemvo.cuttype;
			initView();
			
			Laya.timer.clearAll(this);
			
			Laya.timer.loop(500,this,onReDrawLine);
		}
		
		private function onReDrawLine():void
		{
			
			drawLines();
			curColorIndex = (curColorIndex+1)%2;
		}
		
//		private function onCutTypeChange():void
//		{
//			
//			//cuttype = cuttyperad.selectedIndex;
//
//			var finalwidth:Number = cutdata.finalWidth + cutdata.border;
//			var finalheight:Number = cutdata.finalHeight + cutdata.border;;
//			var product:ProductVo = PaintOrderModel.instance.curSelectMat;
//			
//			var maxwidth:Number = cutdata.maxwidth;//product.max_width - 3;
//			if(cuttype == 1)
//			{
//				leastCutNum = Math.ceil(finalheight/maxwidth);
//				
//				if(cutdata.maxwidth < OrderConstant.MAX_CUT_THRESHOLD)		
//				{
//					cutdata.orderitemvo.cutnum = Math.ceil(finalheight/OrderConstant.CUT_PRIOR_WIDTH);
//					if(cutdata.orderitemvo.cutnum < 2)
//						cutdata.orderitemvo.cutnum = 2;
//				}
//				else
//					cutdata.orderitemvo.cutnum = leastCutNum;
//			}
//			else
//			{
//				leastCutNum = Math.ceil(finalwidth/maxwidth);
//				
//				if(cutdata.maxwidth < OrderConstant.MAX_CUT_THRESHOLD)		
//				{
//					cutdata.orderitemvo.cutnum = Math.ceil(finalwidth/OrderConstant.CUT_PRIOR_WIDTH);
//					if(cutdata.orderitemvo.cutnum < 2)
//						cutdata.orderitemvo.cutnum = 2;
//				}
//				else
//					cutdata.orderitemvo.cutnum = leastCutNum;
//				
//			}
//			//cutdata.orderitemvo.cutnum = leastCutNum;
//			
//			
//			
//			cutdata.orderitemvo.cuttype = cuttype;
//			//cutdata.orderitemvo.cutnum = leastCutNum;
//			initCutNum();
//
//			resetCutlen();
//			updateInputText();
//		}
		private function initView():void
		{
			
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			
			var border:Number = cutdata.border;
			
			this.borderimg.visible = border > 0;
				
			this.horiCutWidthRdo.labels = cutdata.cutLength.join(",");
			this.vertCutWidthRdo.labels = cutdata.cutLength.join(",");
			
			this.horiCutWidthRdo.selectedIndex = 0;
			this.horiCutLen = cutdata.cutLength[0];
			
			this.horiRdoBox.visible = (cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE);
			this.vertRdoBox.visible = (cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE);

			if(cutdata.cutLength.length > 1 && cuttype == 2)
				this.vertCutWidthRdo.selectedIndex = 1;
			else
				this.vertCutWidthRdo.selectedIndex = 0;
			this.vertCutLen = cutdata.cutLength[this.vertCutWidthRdo.selectedIndex];


			if(finalwidth > finalheight)
			{
				this.borderimg.width = 375;
				this.borderimg.height = 375*(finalheight+border)/(finalwidth+border);
				
				paintimg.width = 375*finalwidth/(finalwidth + border);
				
				paintimg.height = paintimg.width * finalheight/finalwidth;
			}
			else
			{
				this.borderimg.height = 375;
				this.borderimg.width = 375*(finalwidth+border)/(finalheight+border);
				
				paintimg.height = 375*finalheight/(finalheight + border);;
				paintimg.width = paintimg.height * finalwidth/finalheight;
			}
			
			this.hbox.width = paintimg.width;
			this.vbox.height = paintimg.height;
			
			this.horiOperateBox.visible = (cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE);
			this.vertOperateBox.visible = (cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE);

			this.hbox.x = 48 + (375 - this.hbox.width)/2;
			this.vbox.y = 85 + (375 - this.vbox.height)/2;

			paintimg.skin =  HttpRequestUtil.biggerPicUrl + cutdata.fid + (cutdata.orderitemvo.picinfo.picClass.toUpperCase() == "PNG"?".png":".jpg");//HttpRequestUtil.biggerPicUrl + cutdata.fid + ".jpg";
			
			if(cuttype == 0 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					for(var i:int=0;i < cutdata.orderitemvo.vCutnum;i++)
					{
						if(hinputlist.length > i)
							hinputlist[i].text = cutdata.orderitemvo.vEachCutLength[i] + "";
					}
				}
			}
			if(cuttype == 1 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					
					for(var i:int=0;i < cutdata.orderitemvo.hCutnum;i++)
					{
						if(vinputlist.length > i)
							vinputlist[i].text = cutdata.orderitemvo.hEachCutLength[i] + "";
					}
				}
			}
			updateInputText();
			
			initCutNum();
			//cuttyperad.selectedIndex
			//if(matvo.preProc_Code == OrderConstant.HORIZANTAL_CUT_COMBINE)
			//	cuttype = 0;
			
		}
		
		private function onHoriInput(index:int):void
		{
			
			if(index == this.cutdata.orderitemvo.vCutnum - 1)
			{
				this.hinputlist[index].text = cutdata.orderitemvo.vEachCutLength[index] + "";
				return;
			}
			
			if(this.hinputlist[index].text == "")
				return;
			
			//var product:ProductVo = PaintOrderModel.instance.curSelectMat;
			
			var maxwidth:Number = horiCutLen;//cutdata.maxwidth;//product.max_width - 3;
			
			
			var hascutlen:Number = 0;
			for(var i:int=0;i < index;i++)
			{
				hascutlen += cutdata.orderitemvo.vEachCutLength[i];
			}
			
			var curnum:Number = parseFloat(parseFloat(this.hinputlist[index].text).toFixed(2));
			this.hinputlist[index].text = curnum + "";
			var maxlen:Number = Math.min(maxwidth,cutdata.finalWidth + cutdata.border - hascutlen - this.cutdata.orderitemvo.vCutnum + index + 1);
			
			var minlen:Number = Math.max(1,cutdata.finalWidth + cutdata.border - hascutlen - maxwidth*(cutdata.orderitemvo.vCutnum - index - 1));
			
//			if(curnum <= minlen)
//				this.hinputlist[index].text = minlen.toFixed(2) + "";
//			if(curnum > maxlen )
//				this.hinputlist[index].text = maxlen + "";
			
			hascutlen += parseFloat(this.hinputlist[index].text);
			var leftAvg:Number = (cutdata.finalWidth + cutdata.border - hascutlen)/(this.cutdata.orderitemvo.vCutnum - index - 1);
			
			for(var i=index+1;i < this.cutdata.orderitemvo.vCutnum;i++)
			{
				if(i < this.vinputlist.length)
					this.hinputlist[i].text = leftAvg.toFixed(2);
			}
			var temp:Array = [];
			var isvalid:Boolean = true;
			for(var i:int=0;i < this.cutdata.orderitemvo.vCutnum;i++)
			{
				if(i < this.vinputlist.length)
				{
					//cutdata.orderitemvo.vEachCutLength[i] = parseFloat(this.hinputlist[i].text);
					temp.push(parseFloat(this.hinputlist[i].text));
					if(temp[i] > cutdata.maxlength)
						isvalid = false;
				}
			}
			if(isvalid)
			{
				for(var i:int=0;i < this.cutdata.orderitemvo.vCutnum;i++)
				{
					cutdata.orderitemvo.vEachCutLength[i] = temp[i];
				}
			}
			else
			{
				for(var i:int=0;i < cutdata.orderitemvo.vCutnum;i++)
				{
					if(hinputlist.length > i)
						hinputlist[i].text = cutdata.orderitemvo.vEachCutLength[i] + "";
				}
			}
			drawLines();
		}
		
		private function onVertInput(index:int):void
		{
			if(index == this.cutdata.orderitemvo.hCutnum - 1)
			{
				this.vinputlist[index].text = cutdata.orderitemvo.hEachCutLength[index] + "";
				return;
			}
			
			if(this.vinputlist[index].text == "")
				return;
			
			var maxwidth:Number = vertCutLen; //cutdata.maxwidth;
			
			var hascutlen:Number = 0;
			for(var i:int=0;i < index;i++)
			{
				hascutlen += cutdata.orderitemvo.hEachCutLength[i];
			}
			
			var curnum:Number = parseFloat(parseFloat(this.vinputlist[index].text).toFixed(2));
			this.vinputlist[index].text = curnum + "";

			var maxlen:Number = Math.min(maxwidth,cutdata.finalHeight + cutdata.border - hascutlen - this.cutdata.orderitemvo.hCutnum + index + 1);

			var minlen:Number = Math.max(1,cutdata.finalHeight + cutdata.border - hascutlen - maxwidth*(cutdata.orderitemvo.hCutnum - index - 1));

			
//			if(curnum <= minlen)
//				this.vinputlist[index].text = minlen + "";
//			if(curnum > maxlen)
//				this.vinputlist[index].text = maxlen + "";
			
			hascutlen += parseFloat(this.vinputlist[index].text);
			var leftAvg:Number = (cutdata.finalHeight + cutdata.border - hascutlen)/(this.cutdata.orderitemvo.hCutnum - index - 1);
			
			for(var i=index+1;i < this.cutdata.orderitemvo.hCutnum;i++)
			{
				if(i < this.vinputlist.length)
					this.vinputlist[i].text = leftAvg.toFixed(2);
			}
			
			var temp:Array = [];
			var isvalid:Boolean = true;
			
			for(var i:int=0;i < this.cutdata.orderitemvo.hCutnum;i++)
			{
				if(i < this.vinputlist.length)
				{
					//cutdata.orderitemvo.hEachCutLength[i] = parseFloat(this.vinputlist[i].text);
					temp.push(parseFloat(this.vinputlist[i].text));
					if(temp[i] > cutdata.maxlength)
						isvalid = false;
				}
			}
			
			
			if(isvalid)
			{
				for(var i:int=0;i < this.cutdata.orderitemvo.hCutnum;i++)
				{
					cutdata.orderitemvo.hEachCutLength[i] = temp[i];
				}
			}
			else
			{
				for(var i:int=0;i < cutdata.orderitemvo.hCutnum;i++)
				{
					if(vinputlist.length > i)
						vinputlist[i].text = cutdata.orderitemvo.hEachCutLength[i] + "";
				}
			}
			
			drawLines();
		}
		
		private function resetCutlen(changeDirect:int):void
		{
			var cutlen:Number = 0;
			if((cuttype == 0 || cuttype == 2) && changeDirect == 0)
			{
				var leasCutNum:int = Math.ceil((cutdata.finalWidth + cutdata.border)/horiCutLen);
				if(cutdata.orderitemvo.vCutnum > leasCutNum || cuttype != 2)
				{
				 	cutlen = (cutdata.finalWidth + cutdata.border)/cutdata.orderitemvo.vCutnum;			
					cutlen = parseFloat(cutlen.toFixed(2));
					cutdata.orderitemvo.vEachCutLength = [];
					for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
						cutdata.orderitemvo.vEachCutLength.push(cutlen);
				}
				else
				{
					cutdata.orderitemvo.vEachCutLength = [];
					
					for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
					{
						if(j < cutdata.orderitemvo.vCutnum - 1)
							cutdata.orderitemvo.vEachCutLength.push(horiCutLen);
						else
							cutdata.orderitemvo.vEachCutLength.push(cutdata.finalWidth + cutdata.border - horiCutLen * (cutdata.orderitemvo.vCutnum - 1));
						
						
					}
					
					
				}
			}
			
			if((cuttype == 1 || cuttype == 2) && changeDirect == 1)
			{
				var leasCutNum:int = Math.ceil((cutdata.finalHeight + cutdata.border)/vertCutLen);

				if(cutdata.orderitemvo.hCutnum > leasCutNum  || cuttype != 2)
				{
					cutlen = (cutdata.finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
					
					
					cutlen = parseFloat(cutlen.toFixed(2));
					cutdata.orderitemvo.hEachCutLength = [];
					for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
						cutdata.orderitemvo.hEachCutLength.push(cutlen);
				}
				else
				{
					cutdata.orderitemvo.hEachCutLength = [];
					for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
					{
						if(j < cutdata.orderitemvo.hCutnum - 1)
							cutdata.orderitemvo.hEachCutLength.push(vertCutLen);
						else
							cutdata.orderitemvo.hEachCutLength.push(cutdata.finalHeight + cutdata.border - vertCutLen * (cutdata.orderitemvo.hCutnum - 1));
						
						
					}
				}
			}
			
			if(cuttype == 0 || cuttype == 2)
			{
				for(var i:int=0;i < cutdata.orderitemvo.vCutnum;i++)
				{
					if(hinputlist.length > i)
						hinputlist[i].text = cutdata.orderitemvo.vEachCutLength[i] + "";
				}
			}
			if(cuttype == 1 || cuttype == 2)
			{
				for(var i:int=0;i < cutdata.orderitemvo.hCutnum;i++)
				{
					if(hinputlist.length > i)
						vinputlist[i].text = cutdata.orderitemvo.hEachCutLength[i] + "";
				}
			}
			
		}
		private function updateInputText():void
		{
			this.hbox.visible = (cuttype == 0 || cuttype == 2);
			this.vbox.visible = (cuttype == 1 || cuttype == 2);
			
			for(var i:int=0;i < hinputlist.length;i++)
			{
				hinputlist[i].visible = i < cutdata.orderitemvo.vCutnum && cutdata.orderitemvo.vCutnum <=7;
				vinputlist[i].visible = i < cutdata.orderitemvo.hCutnum && cutdata.orderitemvo.hCutnum <=7;

			}
			
			if(cuttype == 0 || cuttype == 2)
				this.hbox.space = (this.hbox.width - this.hinput0.width*cutdata.orderitemvo.vCutnum)/(cutdata.orderitemvo.vCutnum - 1);
			if(cuttype == 1 || cuttype == 2)
			{
				var space = (this.vbox.height  - this.vinput0.height*cutdata.orderitemvo.hCutnum)/(cutdata.orderitemvo.hCutnum - 1);
				for(var i:int=0;i < vinputlist.length;i++)
				{
					vinputlist[i].y = this.vbox.height - this.vinput0.height*(i+1) - space*i;
				}
			}
			

		}
		
		private function initCutNum():void
		{
			
			var finalwidth:Number = cutdata.finalWidth+ cutdata.border;
			var finalheight:Number = cutdata.finalHeight+ cutdata.border;
			//var product:ProductVo = PaintOrderModel.instance.curSelectMat;

			var maxwidth:Number = horiCutLen;//cutdata.maxwidth;//product.max_width - 3;
			
			
			
				leastCutNum = Math.ceil(finalwidth/maxwidth);
			
			//var labes:String = "";
			for(var i:int=0;i < 5;i++)
			{
				//labes += (leastCutNum + i) + " ,";
				horiCutNumBtnList[i].label = (leastCutNum + i) + "";
			}
			
			if(cuttype == 0 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					horiCutNumBtnList[cutdata.orderitemvo.vCutnum - leastCutNum].selected = true;
					
					cutNumInput.text = cutdata.orderitemvo.vCutnum + "";
				
				}
				
			}
			maxwidth = vertCutLen;
			
			leastCutNum = Math.ceil(finalheight/maxwidth);

			for(var i:int=0;i < 5;i++)
			{
				//labes += (leastCutNum + i) + " ,";
				vertCutNumBtnList[i].label = (leastCutNum + i) + "";
			}
			
			if(cuttype == 1 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					vertCutNumBtnList[cutdata.orderitemvo.hCutnum - leastCutNum].selected = true;
					vertCutNumInput.text = cutdata.orderitemvo.hCutnum + "";
				}
				
			}
			//labes = labes.substr(0,labes.length - 1);
			//this.cutnumrad.labels = labes;
			//this.cutnumrad.selectedIndex = cutdata.orderitemvo.cutnum - leastCutNum;
			//this.uiSkin.inputnum.text = leastCutNum + "";
			//onCutNumChange();
			drawLines();
		}
		
//		private function onCutNumChange():void
//		{
//			
//			
//			updateInputText();
//			resetCutlen();
//			
//			drawLines();
//		}
		
		private function onHoriNumChange(index:int):void
		{
			for(var i:int=0;i < horiCutNumBtnList.length;i++)
			 (horiCutNumBtnList[i] as Button).selected = false;
			if(cuttype != 2)
			{
				for(var i:int=0;i < vertCutNumBtnList.length;i++)
					(vertCutNumBtnList[i] as Button).selected = false;
			}
			
			(horiCutNumBtnList[index] as Button).selected = true;
			
			if(cuttype != 2)
			{
				cuttype = 0;
			
				cutdata.orderitemvo.cuttype = cuttype;
				cutdata.orderitemvo.hCutnum = 0;
				cutdata.orderitemvo.hEachCutLength = [];
			}

			var lineNum:int = parseInt((horiCutNumBtnList[index] as Button).text.text);
			
			cutdata.orderitemvo.vCutnum = lineNum;
			cutNumInput.text = lineNum + "";
			
			updateInputText();
			resetCutlen(0);
			
			drawLines();
			
			
		}
		private function onVertNumChange(index:int):void
		{

			for(var i:int=0;i < vertCutNumBtnList.length;i++)
				(vertCutNumBtnList[i] as Button).selected = false;
			if(cuttype != 2)
			{
				for(var i:int=0;i < horiCutNumBtnList.length;i++)
					(horiCutNumBtnList[i] as Button).selected = false;
			}
			
			(vertCutNumBtnList[index] as Button).selected = true;
			
			if(cuttype != 2)
			{
				cuttype = 1;
				
				cutdata.orderitemvo.cuttype = cuttype;
				cutdata.orderitemvo.vCutnum = 0;
				cutdata.orderitemvo.vEachCutLength = [];
			}

			var lineNum:int = parseInt((vertCutNumBtnList[index] as Button).text.text);
			
			cutdata.orderitemvo.hCutnum = lineNum;
			vertCutNumInput.text = lineNum + "";
			
			updateInputText();
			resetCutlen(1);
			
			drawLines();
			
		}
		
		private function onChangeHoriCutLength():void
		{
			
			horiCutLen = cutdata.cutLength[horiCutWidthRdo.selectedIndex];
			
			//var maxwidth:Number = horiCutLen;//cutdata.maxwidth;//product.max_width - 3;
			
			var finalwidth:Number = cutdata.finalWidth+ cutdata.border;

			
			leastCutNum = Math.ceil(finalwidth/horiCutLen);
			
			cutdata.orderitemvo.vCutnum = leastCutNum;
			if(cutdata.orderitemvo.vCutnum < 2)
				cutdata.orderitemvo.vCutnum = 2;
			
			var cutlen:Number = finalwidth/cutdata.orderitemvo.vCutnum;
			cutlen = parseFloat(cutlen.toFixed(2));
			cutdata.orderitemvo.vEachCutLength = [];
			for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
			{
				if(cuttype == 2)
				{
					if(j < cutdata.orderitemvo.vCutnum - 1)
						cutdata.orderitemvo.vEachCutLength.push(horiCutLen);
					else
						cutdata.orderitemvo.vEachCutLength.push(finalwidth - horiCutLen * (cutdata.orderitemvo.vCutnum - 1));
				}
				else
					cutdata.orderitemvo.vEachCutLength.push(cutlen);

				
				
			}
			
			//var labes:String = "";
			for(var i:int=0;i < 5;i++)
			{
				//labes += (leastCutNum + i) + " ,";
				horiCutNumBtnList[i].label = (leastCutNum + i) + "";
				horiCutNumBtnList[i].selected = false;
			}
			
			if(cuttype == 0 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					horiCutNumBtnList[cutdata.orderitemvo.vCutnum - leastCutNum].selected = true;
					
					cutNumInput.text = cutdata.orderitemvo.vCutnum + "";
					
				}
				
			}
			if(cuttype == 0 || cuttype == 2)
			{
				for(var i:int=0;i < cutdata.orderitemvo.vCutnum;i++)
				{
					if(hinputlist.length > i)
						hinputlist[i].text = cutdata.orderitemvo.vEachCutLength[i] + "";
				}
			}
			updateInputText();
		}
		
		private function onChangeVertCutLength():void
		{
			
			vertCutLen = cutdata.cutLength[vertCutWidthRdo.selectedIndex];
			
			//var maxwidth:Number = horiCutLen;//cutdata.maxwidth;//product.max_width - 3;
			
			var finalheight:Number = cutdata.finalHeight+ cutdata.border;
			
			
			leastCutNum = Math.ceil(finalheight/vertCutLen);
			
			cutdata.orderitemvo.hCutnum = leastCutNum;
			if(cutdata.orderitemvo.hCutnum < 2)
				cutdata.orderitemvo.hCutnum = 2;
			
			var cutlen:Number = finalheight/cutdata.orderitemvo.hCutnum;
			cutlen = parseFloat(cutlen.toFixed(2));
			cutdata.orderitemvo.hEachCutLength = [];
			for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
			{
				if(cuttype == 2)
				{
					if(j < cutdata.orderitemvo.hCutnum - 1)
						cutdata.orderitemvo.hEachCutLength.push(vertCutLen);
					else
						cutdata.orderitemvo.hEachCutLength.push(finalheight - vertCutLen * (cutdata.orderitemvo.hCutnum - 1));
				}
				else
				{
					cutdata.orderitemvo.hEachCutLength.push(cutlen);

				}
				
				
			}
			
			//var labes:String = "";
			for(var i:int=0;i < 5;i++)
			{
				//labes += (leastCutNum + i) + " ,";
				vertCutNumBtnList[i].label = (leastCutNum + i) + "";
				vertCutNumBtnList[i].selected = false;
			}
			
			if(cuttype == 1 || cuttype == 2)
			{
				if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
				{
					vertCutNumBtnList[cutdata.orderitemvo.hCutnum - leastCutNum].selected = true;
					
					vertCutNumInput.text = cutdata.orderitemvo.hCutnum + "";
					
				}
				
			}
			if(cuttype == 1 || cuttype == 2)
			{
				for(var i:int=0;i < cutdata.orderitemvo.hCutnum;i++)
				{
					if(vinputlist.length > i)
						vinputlist[i].text = cutdata.orderitemvo.hEachCutLength[i] + "";
				}
			}
			updateInputText();
		}


		
		private function onNumberChange():void
		{
			if(cuttype == 1)
				return;
			
			if(cutNumInput.text == "")
				return;
			var num:int = parseInt(cutNumInput.text);
			if(num <= 0)
				return;
			
			var finalwidth:Number = cutdata.finalWidth + cutdata.border;
			var product:ProductVo = PaintOrderModel.instance.curSelectMat;
			
			var maxwidth:Number = horiCutLen;//cutdata.maxwidth;//product.max_width - 3;
			
			leastCutNum = Math.ceil(finalwidth/maxwidth);
				
			var index:int = num - leastCutNum;
			for(var i:int=0;i < horiCutNumBtnList.length;i++)
				horiCutNumBtnList[i].selected = false;
			if(index >= 0 && index < 5)
				horiCutNumBtnList[index].selected = true;
			
			
			cutdata.orderitemvo.vCutnum = num;

			updateInputText();
			resetCutlen(0);
			
			drawLines();
		}
		
		private function onVertNumberChange():void
		{
			if(cuttype == 0)
				return;
			
			if(cutNumInput.text == "")
				return;
			var num:int = parseInt(vertCutNumInput.text);
			if(num <= 0)
				return;
			var finalheight:Number = cutdata.finalHeight + cutdata.border;
			var product:ProductVo = PaintOrderModel.instance.curSelectMat;
			
			var maxwidth:Number = vertCutLen;//cutdata.maxwidth;//product.max_width - 3;
			leastCutNum = Math.ceil(finalheight/maxwidth);

			var index:int = num - leastCutNum;
			for(var i:int=0;i < vertCutNumBtnList.length;i++)
				vertCutNumBtnList[i].selected = false;
			if(index >= 0 && index < 5)
				vertCutNumBtnList[index].selected = true;
			
			
			cutdata.orderitemvo.hCutnum = num;
			
			updateInputText();
			resetCutlen(1);
			
			drawLines();
		}
		private function drawLines():void
		{
			for(var i:int=0;i < linelist.length;i++)
			{
				
				linelist[i].graphics.clear(true);
				linelist[i].removeSelf();				
				linelist.splice(i,1);
				i--;
				
			}
			
			
			//trace("colroinde:" + curColorIndex);
			if(cutdata.orderitemvo == null)
			{
				trace("null");
			}
			
			var lineNum:int = cutdata.orderitemvo.vCutnum;//cutnumrad.selectedIndex + leastCutNum;

			var stepdist:Number = 0;
			if(cuttype == 0 || cuttype == 2)
			{
				stepdist = borderimg.width/lineNum;
				
				//this.widthnum.text = (cutdata.finalWidth/lineNum).toFixed(2);
				for(var i:int=0;i < 2;i++)
				{
					var sp:Sprite = new Sprite();
					this.paintimg.addChild(sp);									
					
					sp.x = (this.paintimg.width - this.borderimg.width)/2;
					sp.y = (this.paintimg.height - this.borderimg.height)/2;

					var linelen:Number = this.borderimg.width/linenum;
					for(var j:int=0;j < linenum;j++)
					{
						
						if(j % 2 == 0)
							sp.graphics.drawLine(j  * linelen,i * this.borderimg.height, (j + 1) * linelen,i * this.borderimg.height,curColorIndex == 0? color1:color2, linethick);
						else
							sp.graphics.drawLine(j * linelen,i * this.borderimg.height, (j + 1) * linelen,i * this.borderimg.height,curColorIndex == 1? color1:color2, linethick);
						
					}											
					linelist.push(sp);
				}
			}
			 if(cuttype == 1 || cuttype == 2)
			{
				
				 lineNum = cutdata.orderitemvo.hCutnum;
				
				stepdist = borderimg.height/lineNum;
				//this.widthnum.text = (cutdata.finalHeight/lineNum).toFixed(2);

				for(var i:int=0;i < 2;i++)
				{
					var sp:Sprite = new Sprite();
					this.paintimg.addChild(sp);									
					
					sp.x = (this.paintimg.width - this.borderimg.width)/2;
					sp.y = (this.paintimg.height - this.borderimg.height)/2;

					var linelen:Number = this.borderimg.height/linenum;
					for(var j:int=0;j < linenum;j++)
					{
						if(j % 2 == 0)
							sp.graphics.drawLine(i * this.borderimg.width,j * linelen, i * this.borderimg.width,(j +1)* linelen,curColorIndex == 0? color1:color2, linethick);
						else
							sp.graphics.drawLine(i * this.borderimg.width,j * linelen, i * this.borderimg.width,(j +1)* linelen,curColorIndex == 1? color1:color2, linethick);
						
					}											
					linelist.push(sp);

				}
				
			}
			
				if(cuttype == 0 || cuttype== 2)
				{
					lineNum = cutdata.orderitemvo.vCutnum;
					for(var i:int=0;i < lineNum + 1;i++)
					{
						var sp:Sprite = new Sprite();
						this.paintimg.addChild(sp);
						
						sp.x = (this.paintimg.width - this.borderimg.width)/2;
						sp.y = (this.paintimg.height - this.borderimg.height)/2;
						
					//sp.graphics.drawLine((i+1) * stepdist,0, (i+1) * stepdist,this.paintimg.height,"#ff4400", 1);
					
						var linelen:Number = this.borderimg.height/linenum;
						
						var beforewidth:Number = 0;
						for(var k:int=0;k < i;k++)
							beforewidth += cutdata.orderitemvo.vEachCutLength[k];
						var startpos:Number = (beforewidth/cutdata.finalWidth)*this.paintimg.width;
						
						for(var j:int=0;j < linenum;j++)
						{
							//if(j == linenum - 1)
							//	sp.graphics.drawLine((i+1) * stepdist,j * 2 * linelen, (i+1) * stepdist,this.paintimg.height,color2, 1);
							
							
							if(j % 2 == 0)
								sp.graphics.drawLine(startpos,j * linelen, startpos,(j +1)* linelen,curColorIndex == 0? color1:color2, linethick);
							else
								sp.graphics.drawLine(startpos,j * linelen, startpos,(j +1)* linelen,curColorIndex == 1? color1:color2, linethick);
							
						}
						linelist.push(sp);
				
				
					}
				}
				 if(cuttype == 1 || cuttype == 2)
				{
					lineNum = cutdata.orderitemvo.hCutnum;
					
					for(var i:int=0;i < lineNum + 1;i++)
					{
						var sp:Sprite = new Sprite();
						this.paintimg.addChild(sp);
						
						sp.x = (this.paintimg.width - this.borderimg.width)/2;
						sp.y = (this.paintimg.height - this.borderimg.height)/2;
						var linelen:Number = this.borderimg.width/linenum;
						
						var beforewidth:Number = 0;
						for(var k:int=0;k < i;k++)
							beforewidth += cutdata.orderitemvo.hEachCutLength[k];
						var startpos:Number = this.borderimg.height - (beforewidth/(cutdata.finalHeight+cutdata.border))*this.borderimg.height;
						
						for(var j:int=0;j < linenum;j++)
						{
							//if(j == linenum - 1)
							//	sp.graphics.drawLine(j * 2 * linelen,(i+1) * stepdist, this.paintimg.width,(i+1) * stepdist,color2, 1);
							if(j % 2 == 0)
								sp.graphics.drawLine(j  * linelen,startpos, (j + 1) * linelen,startpos,curColorIndex == 0? color1:color2, linethick);
							else
								sp.graphics.drawLine(j * linelen,startpos, (j + 1) * linelen,startpos,curColorIndex == 1? color1:color2, linethick);
							
						}
						linelist.push(sp);

					}
				
	
				
		}
			
//			for(var i:int=0;i < lineNum + 1;i++)
//			{
//				var sp:Sprite = new Sprite();
//				this.paintimg.addChild(sp);
//				
//				sp.x = (this.paintimg.width - this.borderimg.width)/2;
//				sp.y = (this.paintimg.height - this.borderimg.height)/2;
//
//				if(cuttype == 0)
//				{
//					
//					//sp.graphics.drawLine((i+1) * stepdist,0, (i+1) * stepdist,this.paintimg.height,"#ff4400", 1);
//					
//					var linelen:Number = this.borderimg.height/linenum;
//					
//					var beforewidth:Number = 0;
//					for(var k:int=0;k < i;k++)
//						beforewidth += cutdata.orderitemvo.eachCutLength[k];
//					var startpos:Number = (beforewidth/cutdata.finalWidth)*this.paintimg.width;
//					
//					for(var j:int=0;j < linenum;j++)
//					{
//						//if(j == linenum - 1)
//						//	sp.graphics.drawLine((i+1) * stepdist,j * 2 * linelen, (i+1) * stepdist,this.paintimg.height,color2, 1);
//										
//						
//						if(j % 2 == 0)
//							sp.graphics.drawLine(startpos,j * linelen, startpos,(j +1)* linelen,curColorIndex == 0? color1:color2, linethick);
//						else
//							sp.graphics.drawLine(startpos,j * linelen, startpos,(j +1)* linelen,curColorIndex == 1? color1:color2, linethick);
//						
//					}
//					
//					
//				}
//				else
//				{
//					var linelen:Number = this.borderimg.width/linenum;
//					
//					var beforewidth:Number = 0;
//					for(var k:int=0;k < i;k++)
//						beforewidth += cutdata.orderitemvo.eachCutLength[k];
//					var startpos:Number = (beforewidth/(cutdata.finalHeight+cutdata.border))*this.borderimg.height;
//					
//					for(var j:int=0;j < linenum;j++)
//					{
//						//if(j == linenum - 1)
//						//	sp.graphics.drawLine(j * 2 * linelen,(i+1) * stepdist, this.paintimg.width,(i+1) * stepdist,color2, 1);
//						if(j % 2 == 0)
//							sp.graphics.drawLine(j  * linelen,startpos, (j + 1) * linelen,startpos,curColorIndex == 0? color1:color2, linethick);
//						else
//							sp.graphics.drawLine(j * linelen,startpos, (j + 1) * linelen,startpos,curColorIndex == 1? color1:color2, linethick);
//						
//					}
//				}
//				
//				
//				
//				linelist.push(sp);
//			}
		}
	}
}
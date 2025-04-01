package script.order
{
	
	import laya.display.Sprite;
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProductVo;
	
	import ui.order.AvgCutImageItemUI;
	
	public class AvgCutImage extends AvgCutImageItemUI
	{
		private var cutdata:Object;
		
		
		
		private var horilinelist:Vector.<Sprite>;
		private var verlinelist:Vector.<Sprite>;

		private var linenum:int = 19;
		
		private var color1:String = "#000000";
		
		private var color2:String = "#ffffff";
		private var linethick:int = 2;

		private var curColorIndex:int = 0;
		public function AvgCutImage()
		{
			super();
			horilinelist = new Vector.<Sprite>();
			verlinelist = new Vector.<Sprite>();

			this.horiInput.on(Event.INPUT,this,onHoriInput);
			this.vertInput.on(Event.INPUT,this,onVerInput);
			
			this.horiAdd.on(Event.CLICK,this,onAddHoriNum);
			this.horiSub.on(Event.CLICK,this,onSubHoriNum);
			
			this.verAdd.on(Event.CLICK,this,onAddVertNum);
			this.verSub.on(Event.CLICK,this,onSubVertNum);
			
			
			this.horiInput.on(Event.FOCUS,this,onSelectHori);
			this.vertInput.on(Event.FOCUS,this,onSelectVert);
			
		}
		private function onSelectHori():void
		{
			this.horiInput.select();
		}
		
		private function onSelectVert():void
		{
			this.vertInput.select();
		}
		
		private function onAddHoriNum():void
		{
			var curnum:int = parseInt(this.horiInput.text) + 1;
			
			this.horiInput.text = curnum + "";
			
			cutdata.orderitemvo.horiCutNum = curnum;

			onHoriNumChange();
			
		}
		
		private function onSubHoriNum():void
		{
			var curnum:int = parseInt(this.horiInput.text) - 1;
			
			if(curnum < 1)
				return;
			
			this.horiInput.text = curnum + "";
			
			cutdata.orderitemvo.horiCutNum = curnum;
			
			onHoriNumChange();
			
		}
		
		private function onAddVertNum():void
		{
			var curnum:int = parseInt(this.vertInput.text) + 1;
			
			this.vertInput.text = curnum + "";
			
			cutdata.orderitemvo.verCutNum = curnum;
			
			onVerNumChange();
			
		}
		
		private function onSubVertNum():void
		{
			var curnum:int = parseInt(this.vertInput.text) - 1;
			
			if(curnum < 1)
				return;
			
			this.vertInput.text = curnum + "";
			
			cutdata.orderitemvo.verCutNum = curnum;
			
			onVerNumChange();
			
		}
		
		
		public function setData(data:*):void
		{
			cutdata = data;
			
			this.horiInput.text = cutdata.orderitemvo.horiCutNum;
			this.vertInput.text = cutdata.orderitemvo.verCutNum;
			initView();
			
			Laya.timer.clearAll(this);

			Laya.timer.loop(500,this,onReDrawLine);
		}
		
		private function onReDrawLine():void
		{
			
			onHoriNumChange();
			onVerNumChange();

			curColorIndex = (curColorIndex+1)%2;
		}
		private function onHoriInput():void
		{
			if(this.horiInput.text == "")
				return;
			if(parseInt(this.horiInput.text) < 1)
				this.horiInput.text = "1";
			
			cutdata.orderitemvo.horiCutNum = parseInt(this.horiInput.text);
			onHoriNumChange();
			
		}
		private function onVerInput():void
		{
			if(this.vertInput.text == "")
				return;
			if(parseInt(this.vertInput.text) < 1)
				this.vertInput.text = "1";
			
			cutdata.orderitemvo.verCutNum = parseInt(this.vertInput.text);
			onVerNumChange();
			
		}
		
		private function initView():void
		{
			
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			if(finalwidth > finalheight)
			{
				paintimg.width = 400;
				paintimg.height = 400 * finalheight/finalwidth;
			}
			else
			{
				paintimg.height = 400;
				paintimg.width = 400 * finalwidth/finalheight;
			}
			
			paintimg.skin =  HttpRequestUtil.biggerPicUrl + cutdata.fid + (cutdata.orderitemvo.picinfo.picClass.toUpperCase() == "PNG"?".png":".jpg");//HttpRequestUtil.biggerPicUrl + cutdata.fid + ".jpg";
			
			onHoriNumChange();
			onVerNumChange();
			//cuttyperad.selectedIndex
			//if(matvo.preProc_Code == OrderConstant.HORIZANTAL_CUT_COMBINE)
			//	cuttype = 0;
			
		}
		
		
		private function onVerNumChange():void
		{
			for(var i:int=0;i < verlinelist.length;i++)
			{
				
				verlinelist[i].graphics.clear(true);
				verlinelist[i].removeSelf();				
				verlinelist.splice(i,1);
				i--;
				
			}
			
			
			
			var stepdist:Number = 0;
			
			stepdist = paintimg.width/cutdata.orderitemvo.verCutNum;
			
			this.widthNum.text = (cutdata.finalWidth/cutdata.orderitemvo.verCutNum).toFixed(2);

			for(var i:int=0;i < cutdata.orderitemvo.verCutNum + 1;i++)
			{
				var sp:Sprite = new Sprite();
				this.paintimg.addChild(sp);
				
				
				var linelen:Number = this.paintimg.height/linenum;
				for(var j:int=0;j < linenum;j++)
				{
					
					if(j % 2 == 0)
						sp.graphics.drawLine(i * stepdist,j * linelen, i * stepdist,(j +1)* linelen,curColorIndex==0?color1:color2, linethick);
					else
						sp.graphics.drawLine(i * stepdist,j * linelen, i * stepdist,(j +1)* linelen,curColorIndex==0?color2:color1, linethick);
					
				}
										
				
				verlinelist.push(sp);
			}
		}
		
		private function onHoriNumChange():void
		{
			for(var i:int=0;i < horilinelist.length;i++)
			{
				
				horilinelist[i].graphics.clear(true);
				horilinelist[i].removeSelf();				
				horilinelist.splice(i,1);
				i--;
				
			}
			
						
			var stepdist:Number = 0;
			
			stepdist = paintimg.height/cutdata.orderitemvo.horiCutNum;
			
			this.heightNum.text = (cutdata.finalHeight/cutdata.orderitemvo.horiCutNum).toFixed(2);
			
			for(var i:int=0;i < cutdata.orderitemvo.horiCutNum + 1;i++)
			{
				var sp:Sprite = new Sprite();
				this.paintimg.addChild(sp);
				
				
				var linelen:Number = this.paintimg.width/linenum;
				for(var j:int=0;j < linenum;j++)
				{
					
					 if(j % 2 == 0)
						sp.graphics.drawLine(j  * linelen,i * stepdist, (j + 1) * linelen,i * stepdist,curColorIndex==0?color1:color2, linethick);
					else
						sp.graphics.drawLine(j * linelen,i * stepdist, (j + 1) * linelen,i * stepdist,curColorIndex==0?color2:color1, linethick);
					
				}
								
				
				
				horilinelist.push(sp);
			}
		}
	}
}
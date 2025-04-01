package script.order
{
	
	import eventUtil.EventCenter;
	
	import laya.display.Graphics;
	import laya.display.Input;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Point;
	
	import model.HttpRequestUtil;
	import model.orderModel.DakouVo;
	
	import script.ViewManager;
	
	import ui.order.DakouItemUI;
	import ui.order.HoleSpriteUI;
	
	public class DakouCell extends DakouItemUI
	{
		private var cutdata:DakouVo;
		
		private var upholeList:Vector.<HoleSpriteUI>;
		private var bottomholelist:Vector.<HoleSpriteUI>;
		private var leftholelist:Vector.<HoleSpriteUI>;
		private var rightholelist:Vector.<HoleSpriteUI>;

		private var MIN_MARGIN:Number = 1;
		private var MAX_MARGIN:Number = 10;
		
		private var MIN_DISTANCE:Number = 5;
		private var MAX_DISTANCE:Number = 150;

		private var spRadius:Number = 20;
		
		private var curselectHole:HoleSpriteUI;
		private var curHolePoslist:Array;

		private var curIndex:int = -1;
		public function DakouCell()
		{
			super();
			
			upholeList = new Vector.<HoleSpriteUI>();
			bottomholelist = new Vector.<HoleSpriteUI>();
			leftholelist = new Vector.<HoleSpriteUI>();
			rightholelist = new Vector.<HoleSpriteUI>();

			this.marginInput.on(Event.INPUT,this,onMarginInput);
			
			this.marginadd.on(Event.CLICK,this,onAddmargin);
			this.marginsub.on(Event.CLICK,this,onSubmargin);					
			
			this.marginInput.restrict = "0-9";;
			
			this.upHoleInput.restrict = "0-9";
			this.upHoleInput.on(Event.INPUT,this,onUpHomeNumChange);
			this.upHoleAdd.on(Event.CLICK,this,onAddUpHole);
			this.upHoleSub.on(Event.CLICK,this,onSubUpHole);
			
			this.bottomHoleInput.restrict = "0-9";
			this.bottomHoleInput.on(Event.INPUT,this,onbottomHomeNumChange);
			this.bottomHoleAdd.on(Event.CLICK,this,onAddbottomHole);
			this.bottomHoleSub.on(Event.CLICK,this,onSubbottomHole);
			
			this.leftHoleInput.restrict = "0-9";
			this.leftHoleInput.on(Event.INPUT,this,onleftHomeNumChange);
			this.leftHoleAdd.on(Event.CLICK,this,onAddleftHole);
			this.leftHoleSub.on(Event.CLICK,this,onSubleftHole);
			
			this.rightHoleInput.restrict = "0-9";
			this.rightHoleInput.on(Event.INPUT,this,onrightHomeNumChange);
			this.rightHoleAdd.on(Event.CLICK,this,onAddrightHole);
			this.rightHoleSub.on(Event.CLICK,this,onSubrightHole);
			
			this.xposadd.on(Event.CLICK,this,onAddXpos);
			this.xpossub.on(Event.CLICK,this,onSubXpos);
			this.yposadd.on(Event.CLICK,this,onAddYpos);
			this.ypossub.on(Event.CLICK,this,onSubYpos);

			this.xposinput.on(Event.INPUT,this,onXPosChange);
			this.yposinput.on(Event.INPUT,this,onYPosChange);

		}
		
		private function onMarginInput():void
		{
			if(this.marginInput.text == "" || this.marginInput.text == "0")
			{
				this.marginInput.text = "1";
			}
			updateMargin();
		}
		
		private function onAddmargin():void
		{
			
			var num:int = parseInt(this.marginInput.text);
			num++;
			this.marginInput.text = num.toString();
					
			if(num > 10 || num < 1)
			{
				ViewManager.showAlert("孔边距取值范围为1-10");
				return;
			}
			updateMargin();
		}
		private function onSubmargin():void
		{
			
			var num:int = parseInt(this.marginInput.text);
			if(num <= 1)
				return;
			num--;
			this.marginInput.text = num.toString();
			
			if(num > 10 || num < 1)
			{
				ViewManager.showAlert("孔边距取值范围为1-10");
				return;
			}
			updateMargin();
		}
				
		
		private function updateMargin():void
		{
			var num:int = parseInt(this.marginInput.text);
			if(num > 10 || num < 1)
			{
				ViewManager.showAlert("孔边距取值范围为1-10");
				return;
			}
			
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			cutdata.holeMargin = num;
			
			for(var i:int=0;i < cutdata.upHoles.length;i++)
			{
				cutdata.upHoles[i].y = cutdata.holeMargin;
				this.upholeList[i].y = cutdata.upHoles[i].y/finalheight * fileimg.height;
			}
			
			for(var i:int=0;i < cutdata.bottomHoles.length;i++)
			{
				cutdata.bottomHoles[i].y = finalheight - cutdata.holeMargin;
				this.bottomholelist[i].y = cutdata.bottomHoles[i].y/finalheight * fileimg.height - spRadius;
			}
			
			for(var i:int=0;i < cutdata.leftHoles.length;i++)
			{
				cutdata.leftHoles[i].x = cutdata.holeMargin;
				this.leftholelist[i].x = cutdata.leftHoles[i].x/finalwidth * fileimg.width;
			}
			
			for(var i:int=0;i < cutdata.rightHoles.length;i++)
			{
				cutdata.rightHoles[i].x = finalwidth - cutdata.holeMargin;
				this.rightholelist[i].x = cutdata.rightHoles[i].x/finalwidth * fileimg.width - spRadius;
			}
			EventCenter.instance.event(EventCenter.BATCH_EDIT_DAKOU_CELL);

		}
		public function setData(data:*):void
		{
			cutdata = data;
			
			
			initView();
		}
		
		
		private function onAddUpHole():void
		{
			var num:int = parseInt(this.upHoleInput.text);
			num++;
			this.upHoleInput.text = num + "";
			if(this.upHoleInput.text == "" || this.upHoleInput.text == "0")
			{
				this.upHoleInput.text = "1";
			}
			
			var num:int = parseInt(this.upHoleInput.text);
			
			onVerticalHoleNumChange(num,0);
		}
		
		private function onSubUpHole():void
		{
			var num:int = parseInt(this.upHoleInput.text);
			num--;
			if(num >= 0)
			this.upHoleInput.text = num + "";
			if(this.upHoleInput.text == "")
			{
				this.upHoleInput.text = "1";
			}
			
			var num:int = parseInt(this.upHoleInput.text);
			
			onVerticalHoleNumChange(num,0);

		}
		
		private function onAddbottomHole():void
		{
			var num:int = parseInt(this.bottomHoleInput.text);
			num++;
			this.bottomHoleInput.text = num + "";
			
			if(this.bottomHoleInput.text == "" )
			{
				this.bottomHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.bottomHoleInput.text);
			
			onVerticalHoleNumChange(num,1);

		}
		
		private function onSubbottomHole():void
		{
			var num:int = parseInt(this.bottomHoleInput.text);
			num--;
			if(num >= 0)
				this.bottomHoleInput.text = num + "";
			
			if(this.bottomHoleInput.text == "")
			{
				this.bottomHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.bottomHoleInput.text);
			
			onVerticalHoleNumChange(num,1);
			
		}
		private function onUpHomeNumChange():void
		{
			if(this.upHoleInput.text == "")
			{
				this.upHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.upHoleInput.text);
			
			onVerticalHoleNumChange(num,0);
		}
		
		private function onbottomHomeNumChange():void
		{
			if(this.bottomHoleInput.text == "")
			{
				this.bottomHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.bottomHoleInput.text);
			
			onVerticalHoleNumChange(num,1);
		}
		
		private function onVerticalHoleNumChange(num:int,direct:int):void
		{
			
			
			var dist:Number = cutdata.finalWidth;
			
			var stepDist:Number = dist/(num + 1);
			if(stepDist < MIN_DISTANCE)
			{
				ViewManager.showAlert("孔数过多，请修改");
				this.upHoleInput.text = this.upholeList.length + "";
				this.bottomHoleInput.text = this.bottomholelist.length + "";

				return;
			}
			
			var holelist:Vector.<HoleSpriteUI>;
			var holeposlist:Array = direct == 0?this.cutdata.upHoles:this.cutdata.bottomHoles;
			

			if(direct == 0)
				holelist = this.upholeList;
			else
				holelist = this.bottomholelist;
			var addnum:int = num - holelist.length;

			if(addnum < 0)
			{
				while(holelist.length > num)
				{
					
					this.fileimg.removeChild(holelist[0]);
					holelist.splice(0,1);
				}
			}
			holeposlist.splice(0);
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			var ypos:Number = direct == 0?cutdata.holeMargin:finalheight - cutdata.holeMargin;
			for(var i:int=0;i < num;i++)
			{
				holeposlist.push(new Point(stepDist * (i+1),ypos));
				if(holelist.length <= i)
				{
					holelist.push(createHole());
					this.fileimg.addChild(holelist[i]);
				}
				
				holelist[i].x = holeposlist[i].x /finalwidth * this.fileimg.width - spRadius/2;
				if(direct == 1)
					holelist[i].y = holeposlist[i].y/finalheight * fileimg.height - spRadius;
				else
					holelist[i].y = holeposlist[i].y/finalheight * fileimg.height;

				holelist[i].on(Event.CLICK,this,onSelectHole,[holeposlist,holelist,i]);


			}
			
			this.curselectHole = null;
			EventCenter.instance.event(EventCenter.BATCH_EDIT_DAKOU_CELL);

		}
		
		private function onAddleftHole():void
		{
			var num:int = parseInt(this.leftHoleInput.text);
			num++;
			this.leftHoleInput.text = num + "";
			if(this.leftHoleInput.text == "")
			{
				this.leftHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.leftHoleInput.text);
			
			onHorizantalHoleNumChange(num,0);
		}
		
		private function onSubleftHole():void
		{
			var num:int = parseInt(this.leftHoleInput.text);
			num--;
			if(num >= 0)
				this.leftHoleInput.text = num + "";
			if(this.leftHoleInput.text == "")
			{
				this.leftHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.leftHoleInput.text);
			
			onHorizantalHoleNumChange(num,0);
			
		}
		
		private function onAddrightHole():void
		{
			var num:int = parseInt(this.rightHoleInput.text);
			num++;
			this.rightHoleInput.text = num + "";
			
			if(this.rightHoleInput.text == "")
			{
				this.rightHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.rightHoleInput.text);
			
			onHorizantalHoleNumChange(num,1);
			
		}
		
		private function onSubrightHole():void
		{
			var num:int = parseInt(this.rightHoleInput.text);
			num--;
			if(num >= 0)
				this.rightHoleInput.text = num + "";
			
			if(this.rightHoleInput.text == "" )
			{
				this.rightHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.rightHoleInput.text);
			
			onHorizantalHoleNumChange(num,1);
			
		}
		private function onleftHomeNumChange():void
		{
			if(this.leftHoleInput.text == "")
			{
				this.leftHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.leftHoleInput.text);
			
			onHorizantalHoleNumChange(num,0);
		}
		
		private function onrightHomeNumChange():void
		{
			if(this.rightHoleInput.text == "")
			{
				this.rightHoleInput.text = "0";
			}
			
			var num:int = parseInt(this.rightHoleInput.text);
			
			onHorizantalHoleNumChange(num,1);
		}
		
		private function onHorizantalHoleNumChange(num:int,direct:int):void
		{
			
			
			var dist:Number = cutdata.finalHeight;
			
			var stepDist:Number = dist/(num + 1);
			if(stepDist < MIN_DISTANCE)
			{
				ViewManager.showAlert("孔数过多，请修改");
				
				this.leftHoleInput.text = this.leftholelist.length + "";
				this.rightHoleInput.text = this.rightholelist.length + "";

				return;
			}
			
			var holelist:Vector.<HoleSpriteUI>;
			var holeposlist:Array = direct == 0?this.cutdata.leftHoles:this.cutdata.rightHoles;
			
			if(direct == 0)
				holelist = this.leftholelist;
			else
				holelist = this.rightholelist;
			
			var addnum:int = num - holelist.length;

			if(addnum < 0)
			{
				while(holelist.length > num)
				{
					
					this.fileimg.removeChild(holelist[0]);
					holelist.splice(0,1);
				}
			}
			holeposlist.splice(0);
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			var xpos:Number = direct == 0?cutdata.holeMargin:finalwidth - cutdata.holeMargin;
			for(var i:int=0;i < num;i++)
			{
				holeposlist.push(new Point(xpos,stepDist * (i+1)));
				if(holelist.length <= i)
				{
					holelist.push(createHole());
					this.fileimg.addChild(holelist[i]);
				}
				if(direct == 1)
					holelist[i].x = holeposlist[i].x /finalwidth * this.fileimg.width - spRadius;
				else
					holelist[i].x = holeposlist[i].x /finalwidth * this.fileimg.width;

				holelist[i].y = holeposlist[i].y/finalheight * fileimg.height - spRadius/2;
				holelist[i].on(Event.CLICK,this,onSelectHole,[holeposlist,holelist,i]);
				
				
			}
			
			this.curselectHole = null;
			EventCenter.instance.event(EventCenter.BATCH_EDIT_DAKOU_CELL);

		}
		private function onSelectHole(holeposlist:Array,holespritelist:Vector.<HoleSpriteUI>, index:int):void
		{
			var allholes:Vector.<HoleSpriteUI> = this.upholeList.concat(this.bottomholelist).concat(this.leftholelist).concat(this.rightholelist);
			for(var i:int=0;i < allholes.length;i++)
			{
				 allholes[i].greenhole.visible = false;
			}
			
			holespritelist[index].greenhole.visible = true;
			curHolePoslist = holeposlist;
			curselectHole = holespritelist[index];
			curIndex = index;
			this.xposinput.text = (curHolePoslist[index].x as Number).toFixed(1) + "";
			this.yposinput.text = (curHolePoslist[index].y as Number).toFixed(1) + "";
			
			EventCenter.instance.event(EventCenter.SELECT_DAKOU_CELL,this);

		}
		
		public function moveHole(e:Event):void
		{
			if(this.curselectHole == null)
				return;
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			
			if(e.keyCode == Keyboard.LEFT)
			{
				if((this.curHolePoslist[curIndex].x - 1) < this.MIN_MARGIN)
					return;
				
				this.curHolePoslist[curIndex].x--;				
			}
			else if(e.keyCode == Keyboard.RIGHT)
			{
				if((finalwidth - this.curHolePoslist[curIndex].x - 1) < this.MIN_MARGIN)
					return;
				this.curHolePoslist[curIndex].x++;				
			}
			else if(e.keyCode == Keyboard.UP)
			{
				if(this.curHolePoslist[curIndex].y - 1 < this.MIN_MARGIN)
					return;
				this.curHolePoslist[curIndex].y--;				
			}
			else if(e.keyCode == Keyboard.DOWN)
			{
				if(finalheight - this.curHolePoslist[curIndex].y - 1 < this.MIN_MARGIN)
					return;
				this.curHolePoslist[curIndex].y++;				
			}
			else return;
			
			
			
			if(this.upholeList.indexOf(curselectHole) >= 0 || this.bottomholelist.indexOf(curselectHole) >= 0)
			{
				
				this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width - spRadius/2;
				if(this.upholeList.indexOf(curselectHole) >= 0)
					this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height;
				else
					this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height - spRadius;

			
			}
			
			else
			{
				if(this.leftholelist.indexOf(curselectHole) >= 0)
					this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width;
				else
					this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width - spRadius;

				
				this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height - spRadius/2;
				
				
			}
			
			this.xposinput.text = (this.curHolePoslist[curIndex].x as Number).toFixed(1) + "";
			this.yposinput.text = (curHolePoslist[curIndex].y as Number).toFixed(1) + "";
			EventCenter.instance.event(EventCenter.BATCH_EDIT_DAKOU_CELL);


		}
		
		private function onAddXpos():void
		{
			var num:Number = parseFloat(this.xposinput.text);
			
			num++;
			
			this.xposinput.text = num.toFixed(1) + "";
			
			if(this.xposinput.text == "" || this.xposinput.text == "0")
			{
				this.xposinput.text = "1";
			}
			
			onXPosChange();

		}
		
		private function onSubXpos():void
		{
			var num:Number = parseFloat(this.xposinput.text);
			if(num <=1)
				return;
			num--;
			this.xposinput.text = num.toFixed(1) + "";
			
			if(this.xposinput.text == "" || this.xposinput.text == "0")
			{
				this.xposinput.text = "1";
			}
			
			onXPosChange();
		}
		
		private function onAddYpos():void
		{
			var num:Number = parseFloat(this.yposinput.text);
			
			num++;
			
			this.yposinput.text = num.toFixed(1) + "";
			
			if(this.yposinput.text == "" || this.yposinput.text == "0")
			{
				this.yposinput.text = "1";
			}
			
			 num = parseFloat(this.yposinput.text);
			 onYPosChange();
		}
		
		
		private function onSubYpos():void
		{
			var num:Number = parseFloat(this.yposinput.text);
			
			if(num <=1)
				return;
			num--;
			
			this.yposinput.text = num.toFixed(1) + "";
			
			if(this.yposinput.text == "" || this.yposinput.text == "0")
			{
				this.yposinput.text = "1";
			}
			
			onYPosChange()
		}
		
		private function onXPosChange():void
		{
			if(this.curselectHole == null)
				return;
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			var num:Number = parseFloat(this.xposinput.text);
			
			if( num < this.MIN_MARGIN || finalwidth - num < this.MIN_MARGIN)
			{
				ViewManager.showAlert("孔离图片边距不能小于孔边距");
				this.xposinput.text = (this.curHolePoslist[curIndex].x as Number).toFixed(1) + "";
				return;
			}
			
			this.curHolePoslist[curIndex].x = num;
			updateCurHolePos();

		}
		
		private function onYPosChange():void
		{
			if(this.curselectHole == null)
				return;
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			var num:Number = parseFloat(this.yposinput.text);
			
			if( num < this.MIN_MARGIN || finalheight - num < this.MIN_MARGIN)
			{
				ViewManager.showAlert("孔离图片边距不能小于孔边距");
				this.yposinput.text = (this.curHolePoslist[curIndex].y as Number).toFixed(1) + "";
				return;
			}
			
			this.curHolePoslist[curIndex].y = num;
			updateCurHolePos();
		}
		
		private function updateCurHolePos():void
		{
			if(this.curselectHole == null)
				return;
			
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			
			if(this.upholeList.indexOf(curselectHole) >= 0 || this.bottomholelist.indexOf(curselectHole) >= 0)
			{
				
				this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width - spRadius/2;
				if(this.upholeList.indexOf(curselectHole) >= 0)
					this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height;
				else
					this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height - spRadius;
				
				
			}
				
			else
			{
				if(this.leftholelist.indexOf(curselectHole) >= 0)
					this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width;
				else
					this.curselectHole.x = this.curHolePoslist[curIndex].x/finalwidth * fileimg.width - spRadius;
				
				
				this.curselectHole.y = this.curHolePoslist[curIndex].y/finalheight * fileimg.height - spRadius/2;
				
				
			}
			
			EventCenter.instance.event(EventCenter.BATCH_EDIT_DAKOU_CELL);
			
		}
		private function initView():void
		{
			
			var finalwidth:Number = cutdata.finalWidth;
			var finalheight:Number = cutdata.finalHeight;
			if(finalwidth > finalheight)
			{
				fileimg.width = 375;
				fileimg.height = 375 * finalheight/finalwidth;
			}
			else
			{
				fileimg.height = 375;
				fileimg.width = 375 * finalwidth/finalheight;
			}
			
			fileimg.skin =  HttpRequestUtil.biggerPicUrl + cutdata.fid + ".jpg";
			
			//this.rightposinput.text = cutdata.orderitemvo.dkrightpos;
			
			this.picwidth.text = cutdata.finalWidth + "(cm)";
			
			this.marginInput.text = cutdata.holeMargin + "";
			
			this.xposinput.text = "--";
			this.yposinput.text = "--";
			this.upHoleInput.text = cutdata.upHoles.length + "";
			this.bottomHoleInput.text = cutdata.bottomHoles.length + "";
			this.leftHoleInput.text = cutdata.leftHoles.length + "";
			this.rightHoleInput.text = cutdata.rightHoles.length + "";

			var allholes:Vector.<HoleSpriteUI> = this.upholeList.concat(this.bottomholelist).concat(this.leftholelist).concat(this.rightholelist);
			for(var i:int=0;i < allholes.length;i++)
			{
				allholes[i].removeSelf();
			}
			curselectHole = null;
			this.upholeList = new Vector.<HoleSpriteUI>();
			this.bottomholelist = new Vector.<HoleSpriteUI>();
			this.leftholelist = new Vector.<HoleSpriteUI>();
			this.rightholelist = new Vector.<HoleSpriteUI>();

			
			for(var i:int=0;i<cutdata.upHoles.length;i++)
			{
				var hole:HoleSpriteUI = createHole();
				hole.x = cutdata.upHoles[i].x/finalwidth * this.fileimg.width - spRadius/2;
				hole.y = cutdata.upHoles[i].y/finalheight * this.fileimg.height;
				
				this.fileimg.addChild(hole);
				
				hole.on(Event.CLICK,this,onSelectHole,[this.cutdata.upHoles,this.upholeList,i]);

				upholeList.push(hole);
				

			}
			
			for(var i:int=0;i<cutdata.bottomHoles.length;i++)
			{
				var hole:HoleSpriteUI = createHole();
				hole.x = cutdata.bottomHoles[i].x/finalwidth * this.fileimg.width - spRadius/2;
				hole.y = cutdata.bottomHoles[i].y/finalheight * this.fileimg.height - spRadius;
				
				this.fileimg.addChild(hole);
				
				hole.on(Event.CLICK,this,onSelectHole,[this.cutdata.bottomHoles,this.bottomholelist,i]);
				
				bottomholelist.push(hole);
				
				
			}
			
			for(var i:int=0;i<cutdata.leftHoles.length;i++)
			{
				var hole:HoleSpriteUI = createHole();
				hole.x = cutdata.leftHoles[i].x/finalwidth * this.fileimg.width;
				hole.y = cutdata.leftHoles[i].y/finalheight * this.fileimg.height - spRadius/2;
				
				this.fileimg.addChild(hole);
				
				hole.on(Event.CLICK,this,onSelectHole,[this.cutdata.leftHoles,this.leftholelist,i]);
				
				leftholelist.push(hole);
				
				
			}
			
			for(var i:int=0;i<cutdata.rightHoles.length;i++)
			{
				var hole:HoleSpriteUI = createHole();
				hole.x = cutdata.rightHoles[i].x/finalwidth * this.fileimg.width - spRadius;
				hole.y = cutdata.rightHoles[i].y/finalheight * this.fileimg.height - spRadius/2;
				
				this.fileimg.addChild(hole);
				
				hole.on(Event.CLICK,this,onSelectHole,[this.cutdata.rightHoles,this.rightholelist,i]);
				
				rightholelist.push(hole);
				
				
			}

			
		}
		
		private function createHole():HoleSpriteUI
		{
			return new HoleSpriteUI();
		}
	}
}
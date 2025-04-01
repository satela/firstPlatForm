package script.prodCustomer
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Mouse;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	import model.prodCustomerModel.ProdCutomerItemVo;
	
	import script.ViewManager;
	
	import ui.prodCustom.ProdEditItemUI;
	
	public class ProdEditController extends Script
	{
		public var prodCustomerVo:ProdCutomerItemVo;
		
		private var maxWidth:Number = 500;
		private var downPos:Point;

		private var uiSkin:ProdEditItemUI;
		
		private var customerPicInfo:PicInfoVo;
		
		public function ProdEditController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as 	ProdEditItemUI;
			
			uiSkin.customImg.on(Event.MOUSE_DOWN,this,startDragImg);
			uiSkin.customImg.on(Event.MOUSE_UP,this,stopDragImg);
			
			//uiSkin.customImg.mask = uiSkin.maskimg;
			
			uiSkin.customImg.on(Event.MOUSE_OUT,this,function(){
				//uiSkin.dragBox.visible = false;
				;
			})
			uiSkin.customImg.on(Event.MOUSE_OVER,this,function(){
				uiSkin.dragBox.visible = true;
				uiSkin.rotateBox.visible = true;
				
				
			})
			
			uiSkin.dragBox.on(Event.MOUSE_OVER,this,function(){
				
				Mouse.cursor = "nw-resize";
				
			});
			
			uiSkin.dragBox.on(Event.MOUSE_OUT,this,function(){
				
				Mouse.cursor = "auto";
				
			});
			
			uiSkin.rotateBox.on(Event.MOUSE_OVER,this,function(){
				
				Mouse.cursor = "nw-resize";
				
			});
			
			uiSkin.rotateBox.on(Event.MOUSE_OUT,this,function(){
				
				Mouse.cursor = "auto";
				
			});
			
			downPos = new Point();
			
			uiSkin.dragBox.on(Event.MOUSE_DOWN,this,onStartResize);
			uiSkin.dragBox.on(Event.MOUSE_UP,this,onStopResize);
			
			uiSkin.rotateBox.on(Event.MOUSE_DOWN,this,onStartRotate);
			uiSkin.rotateBox.on(Event.MOUSE_UP,this,onStopRotate);
			uiSkin.on(Event.MOUSE_UP,this,onStopRotate);

			
			followFrame();
			uiSkin.chooseImg.on(Event.CLICK,this,showSelectImg);
			uiSkin.resetBtn.on(Event.CLICK,this,resetCustomerImg);
			
			uiSkin.on(Event.CLICK,this,hideFrame);
			
		}
		public function setData(customerVo:ProdCutomerItemVo):void
		{
			prodCustomerVo = customerVo;
			
			if(prodCustomerVo.prodWidth> prodCustomerVo.prodHeight)
			{
				uiSkin.prodImg.width = maxWidth;					
				uiSkin.prodImg.height = maxWidth/prodCustomerVo.prodWidth * prodCustomerVo.prodHeight;
				
				uiSkin.maskimg.width = maxWidth;					
				uiSkin.maskimg.height = maxWidth/prodCustomerVo.prodWidth * prodCustomerVo.prodHeight;
				
			}
			else
			{
				uiSkin.prodImg.height = maxWidth;
				uiSkin.prodImg.width = maxWidth/prodCustomerVo.prodHeight * prodCustomerVo.prodWidth;	
				
				uiSkin.maskimg.height = maxWidth;					
				uiSkin.maskimg.width = maxWidth/prodCustomerVo.prodHeight * prodCustomerVo.prodWidth;
			
			}
			
			uiSkin.prodImg.skin = prodCustomerVo.prodImg;
			uiSkin.maskimg.skin = prodCustomerVo.maskImg;
			
		}
		
		private function setCustomerImg(picInfoVo:PicInfoVo):void
		{
			
			if(picInfoVo)
			{
				customerPicInfo= picInfoVo;
				uiSkin.customImg.skin =  HttpRequestUtil.biggerPicUrl + picInfoVo.fid + ".jpg";
				
				
				if(picInfoVo.picWidth> picInfoVo.picHeight)
				{
					uiSkin.customImg.width = maxWidth;					
					uiSkin.customImg.height = maxWidth/picInfoVo.picWidth * picInfoVo.picHeight;
					
				}
				else
				{
					uiSkin.customImg.height = maxWidth;					
					uiSkin.customImg.width = maxWidth/picInfoVo.picHeight * picInfoVo.picWidth;
					
				}
				
			}
			
		}
		
		private function showSelectImg():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_PIC_TO_ORDER,false,{caller:this,callback:setCustomerImg,customer:true});
		}
		
		private function resetCustomerImg():void
		{
			if(customerPicInfo)
			{
				if(customerPicInfo.picWidth> customerPicInfo.picHeight)
				{
					uiSkin.customImg.width = maxWidth;					
					uiSkin.customImg.height = maxWidth/customerPicInfo.picWidth * customerPicInfo.picHeight;
					
				}
				else
				{
					uiSkin.customImg.height = maxWidth;					
					uiSkin.customImg.width = maxWidth/customerPicInfo.picHeight * customerPicInfo.picWidth;
					
				}
				
				uiSkin.customImg.x = maxWidth/2;
				uiSkin.customImg.y = maxWidth/2;
				uiSkin.customImg.rotation = 0;
				followFrame();
			}
		}
		private function hideFrame(e:Event):void
		{
			if(e.target == uiSkin.imgframe || e.target == uiSkin.customImg || e.target == uiSkin.dragBox || e.target == uiSkin.rotateBox)
				return;
			
			uiSkin.imgframe.visible = false;
			uiSkin.dragBox.visible = false;
			uiSkin.rotateBox.visible = false;
			
			
		}
		private function startDragImg(e:Event):void
		{
			uiSkin.imgframe.visible = true;
			
			Laya.timer.frameLoop(1,this,followFrame);

			
			uiSkin.customImg.startDrag(new Rectangle(0,0,500,500));
			e.stopPropagation();
			
		}
		private function stopDragImg(e:Event):void
		{
			uiSkin.customImg.stopDrag();
			
			Laya.timer.clear(this,followFrame);

			
		}
		private function followFrame():void
		{
			uiSkin.imgframe.width = uiSkin.customImg.width;
			uiSkin.imgframe.height = uiSkin.customImg.height;
			uiSkin.imgframe.x = uiSkin.customImg.x;
			uiSkin.imgframe.y = uiSkin.customImg.y;
			uiSkin.imgframe.rotation = uiSkin.customImg.rotation;
			
			uiSkin.dragBox.x = uiSkin.customImg.x - uiSkin.customImg.width/2 - 5;
			uiSkin.dragBox.y = uiSkin.customImg.y- uiSkin.customImg.height/2 - 5;
			//uiSkin.dragBox.rotation = uiSkin.customImg.rotation;
			
			
			uiSkin.rotateBox.x = uiSkin.customImg.x + uiSkin.customImg.height/2*Math.sin(uiSkin.customImg.rotation/180 * Math.PI);
			uiSkin.rotateBox.y = uiSkin.customImg.y - uiSkin.customImg.height/2*Math.cos(uiSkin.customImg.rotation/180 * Math.PI);
			
			//trace("rotatebox:" + uiSkin.rotateBox.x + "," + uiSkin.rotateBox.y);
			uiSkin.rotateBox.rotation = uiSkin.customImg.rotation;
			
			
			


		}
		private function onStartResize(e:Event):void
		{
			e.stopPropagation();
			
			uiSkin.dragBox.startDrag();
			downPos.x = uiSkin.dragBox.x;
			downPos.y = uiSkin.dragBox.y;
			
			Laya.timer.frameLoop(1,this,onUpdateSize);
			
		}
		
		private function onUpdateSize():void
		{
			var xdiff:int =(downPos.x - uiSkin.dragBox.x)*2 ;
			var ydiff:int =  (downPos.y - uiSkin.dragBox.y)*2;
			
			if(uiSkin.customImg.width+xdiff < 10)
			{
				uiSkin.dragBox.x = uiSkin.customImg.width - uiSkin.dragBox.width/2;
				uiSkin.dragBox.y = uiSkin.customImg.height - uiSkin.dragBox.width/2;
				uiSkin.dragBox.stopDrag();
				Laya.timer.clear(this,onUpdateSize);
				
				return;
			}
			if(uiSkin.customImg.height+ydiff < 10)
			{
				uiSkin.dragBox.x = uiSkin.customImg.width - uiSkin.dragBox.width/2;
				uiSkin.dragBox.y = uiSkin.customImg.height - uiSkin.dragBox.width/2;
				uiSkin.dragBox.stopDrag();
				Laya.timer.clear(this,onUpdateSize);
				
				return;
			}
			
			
			uiSkin.customImg.width = uiSkin.customImg.width+xdiff >= 10?uiSkin.customImg.width+xdiff:10;
		
			uiSkin.customImg.height = uiSkin.customImg.height+ydiff >= 10?uiSkin.customImg.height+ydiff:10;
			
			uiSkin.dragBox.x = uiSkin.customImg.x - uiSkin.customImg.width/2- 5;
			uiSkin.dragBox.y = uiSkin.customImg.y- uiSkin.customImg.height/2 - 5;
			
			uiSkin.imgframe.width = uiSkin.customImg.width;
			uiSkin.imgframe.height = uiSkin.customImg.height;
			uiSkin.imgframe.x = uiSkin.customImg.x;
			uiSkin.imgframe.y = uiSkin.customImg.y;
			
			uiSkin.rotateBox.x = uiSkin.customImg.x + uiSkin.customImg.height/2*Math.sin(uiSkin.customImg.rotation/180 * Math.PI);
			uiSkin.rotateBox.y = uiSkin.customImg.y - uiSkin.customImg.height/2*Math.cos(uiSkin.customImg.rotation/180 * Math.PI);
			
			
			downPos.x = uiSkin.dragBox.x;
			downPos.y = uiSkin.dragBox.y;
			
		}
		private function onStopResize(e:Event):void
		{
			e.stopPropagation();
			
			uiSkin.dragBox.stopDrag();
			Laya.timer.clear(this,onUpdateSize);
			
		}
		
		private function onStartRotate(e:Event):void
		{
			e.stopPropagation();
			
			uiSkin.rotateBox.startDrag();
			downPos.x = uiSkin.rotateBox.x;
			downPos.y = uiSkin.rotateBox.y;
			
			Laya.timer.frameLoop(1,this,onUpdateRotateion);
		}
		
		private function onUpdateRotateion():void
		{
			var mousePoint:Point = new Point(Laya.stage.mouseX,Laya.stage.mouseY);
			
			var localpoint:Point = uiSkin.globalToLocal(mousePoint);
			
			var angle:Number = Math.atan2(uiSkin.customImg.y - localpoint.y,uiSkin.customImg.x - localpoint.x);
			
			trace("locapt:" + localpoint.x + "," + localpoint.y);
			trace("angle:" + angle);
			uiSkin.customImg.rotation = angle/Math.PI * 180 - 90;
			
			uiSkin.imgframe.rotation = uiSkin.customImg.rotation;
			
			uiSkin.dragBox.x = uiSkin.customImg.x - uiSkin.customImg.width/2 - 5;
			uiSkin.dragBox.y = uiSkin.customImg.y- uiSkin.customImg.height/2 - 5;
			//uiSkin.dragBox.rotation = uiSkin.customImg.rotation;
								
			
			uiSkin.rotateBox.x = uiSkin.customImg.x + uiSkin.customImg.height/2*Math.sin(uiSkin.customImg.rotation/180 * Math.PI);
			uiSkin.rotateBox.y = uiSkin.customImg.y - uiSkin.customImg.height/2*Math.cos(uiSkin.customImg.rotation/180 * Math.PI);
			uiSkin.rotateBox.rotation = uiSkin.customImg.rotation;

		}
		
		private function onStopRotate(e:Event):void
		{
			e.stopPropagation();
			uiSkin.rotateBox.stopDrag();
			Laya.timer.clear(this,onUpdateRotateion);

		}
		public override function onDestroy():void
		{
			Laya.timer.clearAll(this);
		}
		
	}
}
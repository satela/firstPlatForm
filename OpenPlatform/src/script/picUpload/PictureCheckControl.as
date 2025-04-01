package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.picManager.PicCheckPanelUI;
	
	public class PictureCheckControl extends Script
	{
		private var uiSkin:PicCheckPanelUI;
		
		public var param:Object;
		public var picvo:PicInfoVo;
		
		public function PictureCheckControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as PicCheckPanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onClosePanel);
			uiSkin.mainpanel.on(Event.CLICK,this,onClosePanel);
			uiSkin.mainpanel.vScrollBarSkin = "";
			
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

			var longside:int = 0;
			if(uiSkin.height - 100 > 800)
			{
				longside = 800;
			}
			else
				longside = uiSkin.height - 100;

			
			uiSkin.yixingimg.visible = false;
			
			if(param is Array)
			{
				 picvo = param[0];
				var yixingimg:String =  param[1];
				var scalex:Number = param[2];
			}
			else
				picvo = param as PicInfoVo;

			if(param != null)
			{
				this.uiSkin.img.skin = HttpRequestUtil.biggerPicUrl + picvo.fid +  picvo.tailFix;
				
				if(picvo.picWidth > picvo.picHeight)
				{
					this.uiSkin.img.width = longside;
					
					this.uiSkin.img.height = longside/picvo.picWidth * picvo.picHeight;
					
				}
				else
				{
					this.uiSkin.img.height = longside;
					this.uiSkin.img.width = longside/picvo.picHeight * picvo.picWidth;
					
				}0
				this.uiSkin.img.y = (uiSkin.height - uiSkin.img.height)/2;
				
				
				uiSkin.fileName.text = picvo.directName;
				uiSkin.fileType.text = "文件格式：" + picvo.picClass.toUpperCase();
				uiSkin.colorSpace.text = "颜色模式：" + picvo.colorspace.toUpperCase();
				uiSkin.dpi.text = "文件精度：" + picvo.dpi + "dpi";

				uiSkin.sizetxt.text = "文件尺寸：" + picvo.picPhysicWidth + "*" + picvo.picPhysicHeight;
				
				
				if(yixingimg != null)
				{
					uiSkin.yixingimg.visible = true;
					uiSkin.yixingimg.skin = yixingimg;
					uiSkin.yixingimg.width = this.uiSkin.img.width;
					uiSkin.yixingimg.height = this.uiSkin.img.height;
					uiSkin.yixingimg.scaleX = scalex;
					uiSkin.yixingimg.y = this.uiSkin.img.y;

				}
			}
			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
		}
		
		private function onResizeBrower():void
		{
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			var longside:int = 0;
			if(uiSkin.height - 100 > 800)
			{
				longside = 800;
			}
			else
				longside = uiSkin.height - 100;

			
			if(picvo.picWidth > picvo.picHeight)
			{
				this.uiSkin.img.width = longside;
				
				this.uiSkin.img.height = longside/picvo.picWidth * picvo.picHeight;
				
			}
			else
			{
				this.uiSkin.img.height = longside;
				this.uiSkin.img.width = longside/picvo.picHeight * picvo.picWidth;
				
			}
			
			uiSkin.yixingimg.width = this.uiSkin.img.width;
			uiSkin.yixingimg.height = this.uiSkin.img.height;
			
			this.uiSkin.img.y = (uiSkin.height - uiSkin.img.height)/2;
			uiSkin.yixingimg.y = this.uiSkin.img.y;
		}
		
		public override function onDestroy():void
		{
			Laya.loader.clearTextureRes(HttpRequestUtil.biggerPicUrl + (param as PicInfoVo).fid + ".jpg");
		}
		private function onClosePanel():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.closeView(ViewManager.VIEW_PICTURE_CHECK);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
	}
}
package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import ui.inuoView.MatAndProcEffectPanelUI;
	
	public class ImageEffectControlller extends Script
	{
		private var uiSkin:MatAndProcEffectPanelUI;
		
		public var param:Object;
		public function ImageEffectControlller()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as MatAndProcEffectPanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onClosePanel);
			uiSkin.mainpanel.on(Event.CLICK,this,onClosePanel);
			uiSkin.mainpanel.vScrollBarSkin = "";
			
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			uiSkin.img.on(Event.LOADED,this,onLoadedImg);

			uiSkin.img.skin = param.url;
			uiSkin.titlelbl.text = param.title;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
		}
		private function onLoadedImg(e:Event):void
		{
			if(this.destroyed)
				return;
			if(uiSkin.img.width < uiSkin.contentPanel.width)
			{
				uiSkin.img.x = (uiSkin.contentPanel.width - uiSkin.img.width)/2;
			}
		}
		private function onClosePanel():void
		{
			ViewManager.instance.closeView(ViewManager.PRODUCT_PROC_EFFECT_PANEL);
		}
	}
}
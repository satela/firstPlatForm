package utils
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Tween;
	
	import script.ViewManager;
	
	import ui.common.PicturePopDialogUI;
	
	public class PicturePopUpController extends Script
	{
		private var uiSkin:PicturePopDialogUI;
		public var param:Object;
		public function PicturePopUpController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as PicturePopDialogUI;
			
			uiSkin.mainview.scaleX = 0.2;
			uiSkin.mainview.scaleY = 0.2;
			
			Tween.to(uiSkin.mainview,{scaleX:1,scaleY:1},300,Ease.backOut);
			
			uiSkin.closebtn.on(Event.CLICK,this,onCloseScene);
			
			uiSkin.msgtxt.text = param.msg;
			uiSkin.tipimg.skin = param.picurl;
			
			if(param.ok != null)
				uiSkin.okbtn.label = param.ok;
			if(param.cancel != null)
				uiSkin.cancelbtn.label = param.cancel;
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			uiSkin.mainpanel.height = Browser.height;
			uiSkin.mainpanel.width = Browser.width;
			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmHandler);
			uiSkin.cancelbtn.on(Event.CLICK,this,onCancelHandler);
			
		}
		private function onResizeBrower():void
		{
			uiSkin.mainpanel.height = Browser.height;
			uiSkin.mainpanel.width = Browser.width;
			
		}
		private function onConfirmHandler():void
		{
			// TODO Auto Generated method stub
			if(param.callback != null)
				(param.callback as Function).call(param.caller,true);
			onCloseScene();
		}
		
		private function onCancelHandler():void
		{
			// TODO Auto Generated method stub
			if(param.callback != null)
				(param.callback as Function).call(param.caller,false);
			onCloseScene();
		}
		
		private function onCloseScene():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_POPUPDIALOG_WITH_PICTURE);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
		}
	}
}
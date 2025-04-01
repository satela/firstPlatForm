package utils
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Tween;
	
	import script.ViewManager;
	
	import ui.PopUpDialogUI;
	
	public class PopUpWindowControl extends Script
	{
		private var uiSkin:PopUpDialogUI;
		public var param:Object;
		public function PopUpWindowControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as PopUpDialogUI;
			
			uiSkin.mainview.scaleX = 0.2;
			uiSkin.mainview.scaleY = 0.2;
			
			Tween.to(uiSkin.mainview,{scaleX:1,scaleY:1},300,Ease.backOut);
			
			uiSkin.closebtn.on(Event.CLICK,this,onCloseScene);
			
			uiSkin.tips.visible = param.tips != null;
			if(param.tips != null)
				uiSkin.tips.text = param.tips;
			
			uiSkin.msgtxt.text = param.msg;
			if(param.ok != null)
				uiSkin.okbtn.label = param.ok;
			if(param.cancel != null)
				uiSkin.cancelbtn.label = param.cancel;
			if(param.noCancel)
			{
				uiSkin.cancelbtn.visible = false;

			}
			uiSkin.btnSp.x = (640 - uiSkin.btnSp.getBounds().width)/2;

			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight * Laya.stage.width/Browser.clientWidth;
			uiSkin.mainview.y = (uiSkin.height - uiSkin.mainview.height)/2 + uiSkin.mainview.height/2;
			

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmHandler);
			uiSkin.cancelbtn.on(Event.CLICK,this,onCancelHandler);

		}
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			uiSkin.mainview.y = (uiSkin.height - uiSkin.mainview.height)/2 + uiSkin.mainview.height/2;
		

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
			if(param.callback != null)
				(param.callback as Function).call(param.caller,false);
			
			ViewManager.instance.closeView(ViewManager.VIEW_POPUPDIALOG);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
	}
}
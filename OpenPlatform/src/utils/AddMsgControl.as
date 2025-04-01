package utils
{
	import laya.components.Script;
	import laya.events.Event;
	
	import script.ViewManager;
	
	import ui.order.AddCommentPanelUI;
	
	public class AddMsgControl extends Script
	{
		private var uiSkin:AddCommentPanelUI;
		
		public var param:Object;
		public function AddMsgControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AddCommentPanelUI;
			this.uiSkin.inputmsg.maxChars = 50;
			this.uiSkin.btnok.on(Event.CLICK,this,onClickOk);
			this.uiSkin.btncancel.on(Event.CLICK,this,onCloseView);
			if(param && param.msg != null)
			{
				this.uiSkin.inputmsg.text = param.msg;
			}
		}
		
		private function onClickOk():void
		{
			if(param.callback != null)
				(param.callback as Function).call(param.caller,uiSkin.inputmsg.text);
			onCloseView();
		}
		private function onCloseView():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.closeView(ViewManager.VIEW_ADD_MESSAGE);
		}
	}
}
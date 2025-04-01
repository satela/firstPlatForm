package script.characterpaint
{
	
	import laya.components.Script;
	import laya.events.Event;
	
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	import script.order.PaintOrderControl;
	
	import ui.characterpaint.CharactTypePanelUI;
	
	public class CharacterTypeChooseControl extends Script
	{
		private var uiSkin:CharactTypePanelUI;
		public function CharacterTypeChooseControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as CharactTypePanelUI;
			
			uiSkin.panel_main.vScrollBarSkin = "";
			uiSkin.panel_main.hScrollBarSkin = "";
			
			this.uiSkin.closebtn.on(Event.CLICK,this,closeView);
			
			this.uiSkin.qiegebtn.on(Event.CLICK,this,onShowOrderPanel);
			
			this.uiSkin.glowbtn.disabled = true;
			this.uiSkin.ironbtn.disabled = true;
			
			
		}
		
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_CHARACTER_TYPE_PANEL);
		}
		
		private function onShowOrderPanel():void
		{
			PaintOrderModel.instance.orderType = OrderConstant.CUTTING;
			ViewManager.instance.openView(ViewManager.VIEW_CARVING_ORDER_PANEL,true);
		}
	}
}
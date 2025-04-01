package script.prodCustomer
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import ui.prodCustom.CustomEditPanelUI;
	import ui.prodCustom.ProdEditItemUI;
	
	public class CustomerEditController extends Script
	{
		private var uiSkin:CustomEditPanelUI;
		public function CustomerEditController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as CustomEditPanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onCloseView);
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			for(var i:int=0;i < 6;i++)
			{
				var proditem:ProdEditItemUI = new ProdEditItemUI();
				uiSkin.prodVBox.addChild(proditem);
			}

		}
		
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_PRODUCT_CUSTOMIZATION_PANEL);
			
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);

		}
		
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
	}
}
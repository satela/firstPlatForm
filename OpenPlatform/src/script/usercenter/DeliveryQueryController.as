package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import script.ViewManager;
	import script.usercenter.item.DeliveryPackageCell;
	
	import ui.usercenter.DeliveryQueryPanelUI;
	
	public class DeliveryQueryController extends Script
	{
		private var uiSkin:DeliveryQueryPanelUI;
		public var param:Object;
		
		public function DeliveryQueryController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as DeliveryQueryPanelUI;
			
			uiSkin.packageList.vScrollBarSkin = "";
			
			uiSkin.packageList.itemRender = DeliveryPackageCell;
			uiSkin.packageList.repeatX = 1;
			uiSkin.packageList.spaceY = 0;
			
			uiSkin.packageList.renderHandler = new Handler(this, updatePackageList);
			uiSkin.packageList.selectEnable = false;
			
			if(param != null)
			{
				for(var i=0;i < param.length;i++)
					param[i].packageName = "包裹-"  + param[i].deliverySn;
			}
			uiSkin.packageList.array = param;
			
			uiSkin.closebtn.on(Event.CLICK,this,onCloseView);
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			
		}
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
		}
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.DELIVERY_PACKAGE_PANEL);
		}
		private function updatePackageList(cell:DeliveryPackageCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
	}
}
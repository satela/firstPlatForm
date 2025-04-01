package script.prodCustomer
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import script.ViewManager;
	
	import ui.prodCustom.CustomerProdCategoryPanelUI;
	import script.prodCustomer.item.ProdCategoryCell;
	
	public class CustomerProdCategoryController extends Script
	{
		private var uiSkin:CustomerProdCategoryPanelUI;
		public function CustomerProdCategoryController()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as CustomerProdCategoryPanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onCloseView);
			
			uiSkin.categoryList.itemRender = ProdCategoryCell;
			
			uiSkin.categoryList.vScrollBarSkin = "";
			uiSkin.categoryList.repeatX = 8;
			uiSkin.categoryList.spaceY = 20;
			uiSkin.categoryList.spaceX = 40;
			uiSkin.categoryList.renderHandler = new Handler(this, updateCategoryItem);

			var arr:Array = [];
			for(var i:int=0;i<50;i++)
			{
				var catdata:Object = {};
				catdata.cateName = "T恤" + i;
				arr.push(catdata);

			}
			uiSkin.categoryList.array = arr;	
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		private function onResizeBrower():void
		{
			
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			uiSkin.categoryList.refresh();
		}
		private function updateCategoryItem(cell:ProdCategoryCell):void
		{
			cell.setData(cell.dataSource);
		}
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_PRODUCT_CATEGORY_PANEL);
			
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
			
		}
		override public function onDestroy():void
		{
			
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower)
				
		}
	}
}
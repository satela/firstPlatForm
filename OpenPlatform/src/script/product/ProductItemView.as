package script.product
{
	import laya.events.Event;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import ui.product.ProductItemUI;
	
	public class ProductItemView extends ProductItemUI
	{
		private var purl:String;
		private var pdata;
		public function ProductItemView()
		{
			super();
		}
		
		public function setData(prodata:Object):void
		{
			this.pimg.skin = "product/p" + (1 + prodata.pid) + ".jpg";
			purl = prodata.url;
			pdata = prodata;
			
			this.pimg.on(Event.CLICK,this,onJumptoTaobao);
		}
		
		private function onJumptoTaobao():void
		{
			//Browser.window.open(purl,null,null,true);
			ViewManager.instance.openView(ViewManager.VIEW_BUY_PRODUCT_VIEW,false,pdata);
		}
	}
}
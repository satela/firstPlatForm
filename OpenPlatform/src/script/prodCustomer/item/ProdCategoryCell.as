package script.prodCustomer.item
{
	import laya.events.Event;
	
	import script.ViewManager;
	
	import ui.prodCustom.ProdCategoryItemUI;
	
	public class ProdCategoryCell extends ProdCategoryItemUI
	{
		private var categoryData:Object;
		public function ProdCategoryCell()
		{
			super();
			
			this.frame.visible = false;
			this.on(Event.MOUSE_OVER,this,function(){
				this.frame.visible = true;
				
			});
			
			
			this.on(Event.MOUSE_OUT,this,function(){
				this.frame.visible = false;
				
			});
			
			this.on(Event.DOUBLE_CLICK,this,onChooseCategory);
		}
		
		public function setData(data:*):void
		{
			this.categoryName.text = data.cateName;
		}
		
		private function onChooseCategory():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_PRODUCT_CHOOSE_PANEL,true,categoryData);
		}
	}
}
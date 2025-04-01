package script.prodCustomer.item
{
	import laya.events.Event;
	
	import model.prodCustomerModel.ProdCutomerItemVo;
	
	import script.ViewManager;
	
	import ui.prodCustom.ProdCategoryItemUI;
	
	public class ProdCell extends ProdCategoryItemUI
	{
		private var prodVo:ProdCutomerItemVo;
		public function ProdCell()
		{
			super();
			
			this.frame.visible = false;
			this.on(Event.MOUSE_OVER,this,function(){
				this.frame.visible = true;
				
			});
			
			
			this.on(Event.MOUSE_OUT,this,function(){
				this.frame.visible = false;
				
			});
			
			this.on(Event.DOUBLE_CLICK,this,onChooseProd);
		}
		
		public function setData(data:*):void
		{
			this.categoryName.text = data.cateName;
		}
		
		private function onChooseProd():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_PRODUCT_CUSTOMIZATION_PANEL,true,prodVo);
		}
		
	}
}
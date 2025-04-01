package script.product
{
	import model.orderModel.MatetialClassVo;
	
	import ui.product.ProductCateItemUI;
	
	public class ProductCategoryItem extends ProductCateItemUI
	{
		public var matvo:MatetialClassVo;
		public function ProductCategoryItem()
		{
			super();
		}
		
		public function setData(product:MatetialClassVo):void
		{
			matvo = product;
			this.catebtn.label = product.matclassname;
		}
		
		public function set ShowSelected(sel:Boolean):void
		{
			this.catebtn.selected = sel;
		}
	}
}
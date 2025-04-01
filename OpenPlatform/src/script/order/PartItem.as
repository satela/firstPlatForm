package script.order
{
	//配件ui
	import model.orderModel.PartItemVo;
	
	import ui.order.PartsItemUI;
	
	public class PartItem extends PartsItemUI
	{
		public var partItemvo:PartItemVo;
		public function PartItem(partvo:PartItemVo)
		{
			partItemvo = partvo;
			super();
		}
		
		private function initView():void
		{
			this.pname.text = partItemvo.partName;
			
			this.psize.text = partItemvo.partSize;
			
		}
	}
}
package script.order
{
	import model.orderModel.PaintOrderModel;
	import model.users.FactoryInfoVo;
	
	import ui.order.TabChooseBtnUI;
	
	public class FactoryChooseBtn extends TabChooseBtnUI
	{
		public var factorydata:FactoryInfoVo;
		public function FactoryChooseBtn()
		{
			super();
		}
		
		public function setData(facvo:FactoryInfoVo):void
		{
			factorydata = facvo;
			this.selbtn.label = factorydata.name;
			this.selbtn.skin = "commers/btn3.png";
			setSelected(factorydata == PaintOrderModel.instance.selectFactoryInMat);
		}
		
		public function setSelected(sel:Boolean):void
		{
			this.selbtn.selected = sel;
		}
	}
}
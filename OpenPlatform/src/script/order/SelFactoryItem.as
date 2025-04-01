package script.order
{
	import laya.events.Event;
	
	import model.orderModel.PaintOrderModel;
	import model.users.FactoryInfoVo;
	
	import ui.order.OrderAddressItemUI;
	import ui.order.OrderItemUI;
	
	public class SelFactoryItem extends OrderAddressItemUI
	{
		public var factoryvo:FactoryInfoVo;
		public function SelFactoryItem()
		{
			super();
		}
		
		public function setData(data:Object):void
		{
			factoryvo = data as FactoryInfoVo;
			this.addresstxt.text = factoryvo.name + "(" + factoryvo.addr+ ")";
			if(PaintOrderModel.instance.selectFactoryAddress != null && PaintOrderModel.instance.selectFactoryAddress.indexOf(factoryvo) >= 0)
				ShowSelected = true;
			else
				ShowSelected = false;
			
			this.on(Event.CLICK,this,onClickSelect);
			//ShowSelected =PaintOrderModel.instance.selectFactoryAddress == factoryvo;
		}
		
		private function onClickSelect():void
		{
			if(!this.btnsel.selected)
			{
				if(PaintOrderModel.instance.selectFactoryAddress == null)
				{
					PaintOrderModel.instance.selectFactoryAddress = [];
				}
				if(PaintOrderModel.instance.selectFactoryAddress.indexOf(factoryvo) < 0)
					PaintOrderModel.instance.selectFactoryAddress.push(factoryvo);
				
			}
			else
			{
				if(PaintOrderModel.instance.selectFactoryAddress != null && PaintOrderModel.instance.selectFactoryAddress.indexOf(factoryvo) >= 0)
				{
					PaintOrderModel.instance.selectFactoryAddress.splice(PaintOrderModel.instance.selectFactoryAddress.indexOf(factoryvo),1);
				}
			}
			ShowSelected = !this.btnsel.selected;
		}
		public function set ShowSelected(value:Boolean):void
		{
			this.btnsel.selected = value;
			this.selCheck.selected = value;
			
		}
	}
}
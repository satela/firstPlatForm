package script.order
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.PaintOrderModel;
	import model.users.AddressVo;
	
	import ui.order.OrderAddressItemUI;
	
	public class SelAddressItem extends OrderAddressItemUI
	{
		public var address:AddressVo;
		
		
		public function SelAddressItem()
		{
			super();
		}
		
		public function setData(data:Object):void
		{
			address = data as AddressVo;
			this.addresstxt.text = address.addressDetail;
			
			this.btnSetDefault.visible = Userdata.instance.defaultAddId != address.id;
			this.defaultMark.visible = Userdata.instance.defaultAddId == address.id;
			
			if(address.customerId > 0)
				this.btnSetDefault.visible = false;
			
			this.btnSetDefault.on(Event.CLICK,this,this.setDefaultAdd);
			ShowSelected = false;
			//ShowSelected = address == PaintOrderModel.instance.selectAddress;
		}
		
		private function setDefaultAdd():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setDefaultaddress,this,defaultAddressBack,JSON.stringify({"id":address.id}),"post");
		}
		private function defaultAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.defaultAddId = address.id;
				EventCenter.instance.event(EventCenter.UPDATE_MYADDRESS_LIST);
			}
		}
		public function set ShowSelected(value:Boolean):void
		{
			this.btnsel.selected = value;
			this.selCheck.selected = value;
					
		}
	}
}
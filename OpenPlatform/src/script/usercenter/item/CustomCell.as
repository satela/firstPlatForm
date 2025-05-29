package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.users.CustomVo;
	
	import script.ViewManager;
	
	import ui.usercenter.items.CustomeItemUI;
	
	public class CustomCell extends CustomeItemUI
	{
		private var customData:CustomVo;
		
		public function CustomCell()
		{
			super();
			this.deleteTxt.on(Event.CLICK,this,onDelete);
			this.updateInfoTxt.on(Event.CLICK,this,onEditCustomer);

			this.addressTxt.on(Event.CLICK,this,onSelectAddress);
			this.updateInfoTxt.visible = true;
		}
		
		public function setData(data:CustomVo):void
		{
			customData = data;
			this.customName.text = customData.customerName;
			this.phoneNumber.text = customData.mobileNumber;
			this.selectImg.visible = false;
			this.businessManlbl.text = customData.salerName;
			this.balancelbl.text = customData.balanceMoney.toFixed(2);
			this.discountlbl.text = customData.discount;
			
			this.defaultPayType.text = Constast.PAY_TYPE_NAME[customData.defaultPayment - 1];
			

		}
		
		public function selected(id:int):void
		{
			this.selectImg.visible = this.customData != null && this.customData.id == id;
		}
		
		private function onEditCustomer():void
		{
			EventCenter.instance.event(EventCenter.EDIT_CUSTOMER_INFO,customData);

		}
		
		
		private function onDelete():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除【" + customData.customerName + "】客户吗?",caller:this,callback:confirmDelete});
		}
		
		
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteCustomer,this,deleteCustomerback,JSON.stringify({"id":customData.id}),"post");

			}
		}
		
		private function deleteCustomerback(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.UPDATE_CUSTOMER_LIST);
			}
		}
		private function onSelectAddress():void
		{
			EventCenter.instance.event(EventCenter.SELECT_CUSTOMER,this.customData);
		}
	}
}
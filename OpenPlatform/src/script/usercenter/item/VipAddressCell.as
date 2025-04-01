package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	
	import ui.usercenter.VipAddressItemUI;
	
	public class VipAddressCell extends VipAddressItemUI
	{
		private var addressVo:VipAddressVo;
		public function VipAddressCell()
		{
			super();
			
			this.checksel.on(Event.CHANGE,this,selectData);
			
		}
		
		public function setData(data:*):void
		{
			addressVo = data;
			this.checksel.selected = addressVo.selected;
			
			this.conName.text = addressVo.receiverName;
			
			this.phonetxt.text = addressVo.phone;
			
			this.detailaddr.text = addressVo.proCityArea;
			
			
			
						
			this.btnDel.on(Event.CLICK,this,onDeleteAddr);
			this.btnedit.on(Event.CLICK,this,onEditAddr);
			

		}
		
		private function onDeleteAddr():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除该地址吗？",caller:this,callback:confirmDelete});
			
		}
		
		private function confirmDelete(result:Boolean):void
		{
			if(result)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,delMyAddressBack,"opt=delete&id=" + addressVo.id,"post");
			
		}
		
		private function delMyAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				//Userdata.instance.deleteAddr(result.id);
				EventCenter.instance.event(EventCenter.UPDATE_MYADDRESS_LIST);
				
			}
		}
		
		private function onEditAddr():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADD_NEW_ADDRESS,false,{url:HttpRequestUtil.vipAddressManageUrl,address:addressVo});
			
		}
		
		private function selectData():void
		{
			if(this.addressVo != null)
			{
				this.addressVo.selected = this.checksel.selected;
				
				EventCenter.instance.event(EventCenter.CHANGE_ADDRESS_SELECTED_STATE,addressVo);
			}
		}
		
		public function changeSelectState(select:Boolean):void
		{
			if(this.addressVo != null)
			{
				this.checksel.selected = select;
				this.addressVo.selected = select;
			}
		}
	}
}
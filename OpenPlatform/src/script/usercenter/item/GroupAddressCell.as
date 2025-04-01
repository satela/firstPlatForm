package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	
	import ui.usercenter.GroupAddressItemUI;
	
	public class GroupAddressCell extends GroupAddressItemUI
	{
		private var addressVo:VipAddressVo;
		public function GroupAddressCell()
		{
			super();
			
			this.checksel.on(Event.CHANGE,this,selectData);
			
			this.btnDel.on(Event.CLICK,this,onDel);
		}
		
		public function setData(data:*):void
		{
			addressVo = data;
			//this.
			this.checksel.selected = addressVo.selected;
			
			
			this.conName.text = addressVo.receiverName;
			
			this.phonetxt.text = addressVo.phone;
			
			this.detailaddr.text = addressVo.proCityArea;
			

		}
		
		private function selectData():void
		{
			if(this.addressVo != null)
			this.addressVo.selected = this.checksel.selected;
		}
		
		public function changeSelectState(select:Boolean):void
		{
			if(this.addressVo != null)
			{
				this.checksel.selected = select;
				this.addressVo.selected = select;
			}
			
		}
		private function onDel():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:onConfirmDel,msg:"确定移出该地址吗？"});
		}
		private function onConfirmDel(b:Boolean):void
		{
			if(b)
			{
				EventCenter.instance.event(EventCenter.DELETE_ADDRESS_FROM_GROUP,[addressVo.id]);

			}
		}
	}
}
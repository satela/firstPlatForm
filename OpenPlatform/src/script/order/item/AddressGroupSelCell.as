package script.order.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.users.AddressGroupVo;
	
	import ui.usercenter.AddressGroupSelItemUI;
	
	public class AddressGroupSelCell extends AddressGroupSelItemUI
	{
		private var groupVo:AddressGroupVo;

		public function AddressGroupSelCell()
		{
			super();
			this.on(Event.CLICK,this,onSelectGroup);
		}
		
		public function setData(data:*):void
		{
			groupVo = data;
			this.btn.label = groupVo.groupName + "(" + groupVo.count + ")";
			this.sel.selected = groupVo.selected;

		}
		
		private function onSelectGroup():void
		{
			this.groupVo.selected = !this.groupVo.selected;
			this.sel.selected = this.groupVo.selected;
			EventCenter.instance.event(EventCenter.CHANGE_ADDRESS_GROUP_SELECTED_STATE,[this,this.groupVo]);
		}
		
	}
}
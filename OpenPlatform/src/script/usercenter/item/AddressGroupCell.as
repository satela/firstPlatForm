package script.usercenter.item
{
	
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.events.Keyboard;
	
	import model.HttpRequestUtil;
	import model.users.AddressGroupVo;
	
	import script.ViewManager;
	
	import ui.usercenter.AddressGroupItemUI;
	
	public class AddressGroupCell extends AddressGroupItemUI
	{
		private var groupVo:AddressGroupVo;
		public function AddressGroupCell()
		{
			super();
			//this.textName.maxChars = 8;
			this.deletbtn.visible = false;
			this.on(Event.MOUSE_OVER,this,onMouseOverHandler);
			this.on(Event.MOUSE_OUT,this,onMouseOutHandler);
			this.deletbtn.on(Event.CLICK,this,onclickDelete);

			this.on(Event.DOUBLE_CLICK,this,showGroupMgr);
			
			//this.textName.on(Event.FOCUS,this,onChangeName);
			//this.textName.on(Event.KEY_UP,this,onChangeName);

		}
		
		public function setData(data:*):void
		{
			groupVo = data;
			this.btn.label = groupVo.groupName + "(" + groupVo.count + ")";
		}
		
		private function onChangeName(e:Event):void
		{
			//if(e.keyCode == Keyboard.ENTER)
			//	trace("change" + this.textName.text);
		}
		private function onMouseOverHandler():void
		{
			this.deletbtn.visible = true;
		}
		
		private function onMouseOutHandler():void
		{
			this.deletbtn.visible = false;
		}
		
		private function onclickDelete():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:confirmDelete,msg:"确定删除" + groupVo.groupName + "分组吗？"});
		}
		
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressGroupManageUrl,this,delGroupBack,"opt=delete&id=" + groupVo.groupId,"post");

			}
		}
		private function delGroupBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				//Userdata.instance.deleteAddr(result.id);
				EventCenter.instance.event(EventCenter.UPDATE_ADDRESS_GROUP_LIST);
				
			}
		}
		private function showGroupMgr():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADDRESS_GROUP_MGR_PANEL,false,groupVo);

		}
	}
}
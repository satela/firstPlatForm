package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	
	import ui.usercenter.OrganizeMemberItemUI;
	
	public class MemberItem extends OrganizeMemberItemUI
	{
		private var memberdata:Object;
		public function MemberItem()
		{
			super();
			
			this.movebtn.on(Event.CLICK,this,onMoveMember);
			this.deletebtn.on(Event.CLICK,this,onDeleteMember);
			this.authoritytxt.on(Event.CLICK,this,onSetAuthority);
			//this.authoritytxt.visible = false;


		}
		private function onDeleteMember():void
		{
			
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除" + memberdata.mobileNumber + "吗？",caller:this,callback:confirmDelete});
			
			
		}
		
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				var params:Object = {"deptId":"0","userId" :memberdata.userId};
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.moveOrganizeMembers,this,ondeleteMemberBack,JSON.stringify(params),"post");
				
			}
		}
		
		private function ondeleteMemberBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.DELETE_DEPT_MEMBER);
			}
		}
		
		private function onSetAuthority():void
		{
			EventCenter.instance.event(EventCenter.SET_MEMEBER_AUTHORITY,memberdata);

		}
		private function onMoveMember():void
		{
			EventCenter.instance.event(EventCenter.MOVE_MEMBER_DEPT,memberdata);
		}
		public function setData(data:*):void
		{
			memberdata = data;
			this.nickname.text = data.nickName;
			this.account.text = data.mobileNumber;
			this.jointime.text = data.createdAt;
		}
	}
}
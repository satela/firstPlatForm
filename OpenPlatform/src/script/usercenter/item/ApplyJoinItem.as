package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	
	import ui.usercenter.ApplyJoinItemUI;
	
	public class ApplyJoinItem extends ApplyJoinItemUI
	{
		private var joindata:Object;
		public function ApplyJoinItem()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			joindata = data;
			this.account.text = data.mobileNumber;
			
			this.msgtxt.text = data.msg;
			this.reqdate.text = data.createdAt;
			
			this.agreebtn.on(Event.CLICK,this,onAgreeJoin);
			this.refusebtn.on(Event.CLICK,this,onRefuseJoin);

		}
		
		private function onAgreeJoin():void
		{
			EventCenter.instance.event(EventCenter.AGREE_JOIN_REQUEST,joindata);
		}
		
		private function onRefuseJoin():void
		{
			var param:Object = {"id":joindata.id, "action":"2"};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.handleJoinOrganizeRequest,this,onhandleBack,JSON.stringify(param),"post");
		}
		
		private function onhandleBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.REFRESH_JOIN_REQUEST);
			}
		}
	}
}
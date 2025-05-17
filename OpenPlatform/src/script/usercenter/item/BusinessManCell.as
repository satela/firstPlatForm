package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.users.BusinessManVo;
	
	import script.ViewManager;
	
	import ui.usercenter.items.BusinessManItemUI;
	
	public class BusinessManCell extends BusinessManItemUI
	{
		private var manvo:BusinessManVo;
		public function BusinessManCell()
		{
			super();
			this.deleteTxt.on(Event.CLICK,this,ondelte);
								
			
		}
		
		private function ondelte():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除" + manvo.name + "吗？",caller:this,callback:confirmDelete});

		}
		public function setData(data:BusinessManVo):void
		{
			manvo = data;
			this.businessName.text = data.name;
			this.phoneNumber.text = data.mobileNumber;
			
		}
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteBusinessMan,this,deleteBusinessback,JSON.stringify({"id":manvo.id}),"post");

			}
		}
		
		private function deleteBusinessback(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.UPDATE_BUSINESSMAN_LIST);
			}
		}
		
	}
}
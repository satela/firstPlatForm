package script.prefabScript
{
	import laya.components.Script;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	import script.usercenter.UserMainControl;
	
	import utils.UtilTool;
	
	public class TopBannerControl extends Script
	{
		private var uiSkin:Box;
		public function TopBannerControl()
		{
			super();
		}
		override public function onEnable():void {
			
			uiSkin = this.owner as Box;
			
			var firstPage:Text = uiSkin.getChildByName("firstPage") as Text;
			var username:Text = uiSkin.getChildByName("userName") as Text;
			var logout:Text = uiSkin.getChildByName("logout") as Text;

			var myorder:Text = uiSkin.getChildByName("myorder") as Text;

			
			if(Userdata.instance.isLogin) 
				username.text = Userdata.instance.userAccount;
			else
				username.text = "未登录";
			
			firstPage.on(Event.CLICK,this,showFirstPage);
			logout.on(Event.CLICK,this,showLogOut);
			
			myorder.on(Event.CLICK,this,showOrderList);

		}
		
		override public function onStart():void
		{
			

		}
		
		private function showOrderList():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true,UserMainControl.MY_ORDER);
		}
		
		private function showFirstPage():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
		}
		private function showLogOut():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginOutUrl,this,onLoginOutBack,"","post");

		}
		private function onLoginOutBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				UtilTool.setLocalVar("useraccount","");
				UtilTool.setLocalVar("userpwd","");
				UtilTool.setLocalVar("userToken","");

				Userdata.instance.isLogin = false;
				Userdata.instance.resetData();
				ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
				
			}
		}
	}
}
package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Label;
	import laya.ui.View;
	import laya.utils.Browser;
	import laya.utils.Mouse;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.usercenter.AddressGroupPanelUI;
	import ui.usercenter.AddressMgrPanelUI;
	import ui.usercenter.ApplyJoinMgrPanelUI;
	import ui.usercenter.ChargeActivityPanelUI;
	import ui.usercenter.ChargePanelUI;
	import ui.usercenter.EnterPrizeInfoPaneUI;
	import ui.usercenter.InvoiceManagerPanelUI;
	
	import ui.usercenter.TransactionPanelUI;
	import ui.usercenter.UserMainPanelUI;
	
	public class UserMainControl extends Script
	{
		private var uiSkin:UserMainPanelUI;
		
		private var viewArr:Array;
		private var btntxtArr:Array;
		
		private var curView:View;
		private var titleTxt:Array;
		
		public var param:Object;
		
		public static const MY_ORDER:int = 3;
		
		private var curViewIndex:int = -1;
		public function UserMainControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as UserMainPanelUI;
			
			uiSkin.panel_main.vScrollBarSkin = "";
			uiSkin.panel_main.hScrollBarSkin = "";

			//uiSkin.sp_container.autoSize = true;
			//uiSkin.firstpage.on(Event.CLICK,this,onBackToMain);
			viewArr = [EnterPrizeInfoPaneUI,AddressMgrPanelUI,null,null,null,ChargePanelUI,TransactionPanelUI,null,null,null,ApplyJoinMgrPanelUI,ChargeActivityPanelUI,AddressGroupPanelUI];
			
			
			
			btntxtArr = [];
			titleTxt = ["企业资料","收货地址","购物车","我的订单","发票管理","账户充值","我的账单","","","组织管理","申请列表","活动充值","地址管理"];
			for(var i:int=0;i < 12;i++)
			{
				if(i != 2)
				{
					uiSkin["btntxt" + i].on(Event.CLICK,this,onShowEditView,[i]);
					uiSkin["btntxt" + i].on(Event.MOUSE_OVER,this,onMouseOverHandler);
					uiSkin["btntxt" + i].on(Event.MOUSE_OUT,this,onMouseOutHandler);

				}
				btntxtArr.push(uiSkin["btntxt" + i]);

			}
			if(param != null && param is int)
				onShowEditView(param as int);
			else
				onShowEditView(0);
			//(uiSkin.panel_main).height = Browser.height;// - 20;
			//(uiSkin.panel_main).width = Browser.width;// - 20;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			if(Userdata.instance.accountType != Constast.ACCOUNT_CREATER)
			{
				uiSkin.btntxt9.removeSelf();
				uiSkin.btntxt10.removeSelf();
				
			}
			if(Userdata.instance.accountType == Constast.ACCOUNT_EMPLOYEE && Userdata.instance.privilege != null && Userdata.instance.privilege[Constast.PRIVILEGE_CHECK_TRANSACTION] == "0")
				uiSkin.btntxt6.removeSelf();
				
			//uiSkin.btntxt9.visible = Userdata.instance.accountType == Constast.ACCOUNT_CREATER;
			//uiSkin.btntxt10.visible = Userdata.instance.accountType == Constast.ACCOUNT_CREATER;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.PAUSE_SCROLL_VIEW,this,onPauseScroll);
			
			EventCenter.instance.on(EventCenter.SHOW_CHARGE_VIEW,this,showCharge);


		}
		
		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			//uiSkin.panel_main.height = Browser.height;// - 50;
			//uiSkin.panel_main.width = Browser.width;// - 20;
			//trace("uiski wid:" + uiSkin.panel_main.width);
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		private function onMouseOutHandler():void
		{
			// TODO Auto Generated method stub
			Mouse.cursor = "auto";
		}
		
		private function onMouseOverHandler():void
		{
			// TODO Auto Generated method stub
			Mouse.cursor = "hand";

		}
		
		private function onPauseScroll(scoll:Boolean):void
		{
			if(scoll)
				uiSkin.panel_main.vScrollBar.target = uiSkin.panel_main;
			else
				uiSkin.panel_main.vScrollBar.target = null;
		}
		
		private function showCharge():void
		{
			onShowEditView(5);
		}
		private function onShowEditView(index:int):void
		{
			if(index == 8)
			{
				ViewManager.instance.openView(ViewManager.VIEW_CHANGEPWD);
				return;
			}
			if(index == 7)
			{
				ViewManager.instance.openView(ViewManager.VIEW_PICMANAGER,true);
				return;
			}
			
			if(curViewIndex == index)
				return;
			curViewIndex = index;
			
			uiSkin.toptitle.text = titleTxt[index];
			uiSkin.bannertitile.text= "/ " + titleTxt[index];
			while(uiSkin.sp_container.numChildren > 0)
			{
				(uiSkin.sp_container.getChildAt(0)).destroy(true);
				uiSkin.sp_container.removeChildAt(0);

			}
			for(var i:int=0;i < btntxtArr.length;i++)
			{
				if(btntxtArr[i] != null)
				{
					(btntxtArr[i] as Label).color = "#262B2E";
					(btntxtArr[i] as Label).alpha = 0.8;
				}
			}
			btntxtArr[index].color = "#52B232";
			btntxtArr[index].alpha = 1;

			if(viewArr[index])
			{
				curView = new viewArr[index]();
				curView.on(Event.RESIZE,this,onLoadComplete);
				uiSkin.sp_container.addChild(curView);
				uiSkin.sp_container.height = curView.height;
			}
			else
				uiSkin.sp_container.height = 0;
			uiSkin.panel_main.refresh();
			uiSkin.panel_main.scrollTo(0,0);
		}
		
		private function onLoadComplete():void
		{
			// TODO Auto Generated method stub
			if(curView)
			{
				uiSkin.sp_container.height = curView.height;
				uiSkin.panel_main.refresh();
			}
		}		
		
		private function onBackToMain():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.PAUSE_SCROLL_VIEW,this,onPauseScroll);
			EventCenter.instance.off(EventCenter.SHOW_CHARGE_VIEW,this,showCharge);

		}
	}
}
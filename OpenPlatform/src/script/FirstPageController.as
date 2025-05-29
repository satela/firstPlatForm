package script
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Label;
	import laya.ui.View;
	import laya.utils.Browser;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	
	import ui.FirstPagePanelUI;
	import ui.inuoView.MyWorkPanelUI;
	import ui.inuoView.PicManagerPanelUI;
	import ui.orderList.CustomerTransactionPanelUI;
	import ui.orderList.OrderListPanelUI;
	import ui.orderList.StatisticalAnalyPanelUI;
	import ui.usercenter.AccountSettingPanelUI;
	import ui.usercenter.ChargePanelUI;
	import ui.usercenter.CustomManagerPanelUI;
	import ui.usercenter.EnterPrizeInfoPaneUI;
	
	import utils.UtilTool;
	
	public class FirstPageController extends Script
	{
		private var uiSkin:FirstPagePanelUI;
		
		private var menuBtnOriginX:int = 62;
		
		private var menuBtnList:Array;
		
		private var curShrinkState:int = 0;
		
		private var viewArr:Array;
		private var curView:View;
		private var curViewIndex:int = -1;

		public function FirstPageController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as FirstPagePanelUI;
			//uiSkin.mainPanel.vScrollBarSkin = "";
			
			uiSkin.leftMenuPanel.vScrollBarSkin = "";
			uiSkin.contentPanel.vScrollBarSkin = "";

			uiSkin.accountlbl.text = Userdata.instance.userName;// + Userdata.instance.userAccount;
			viewArr = [MyWorkPanelUI,PicManagerPanelUI,OrderListPanelUI,EnterPrizeInfoPaneUI,ChargePanelUI,AccountSettingPanelUI,CustomManagerPanelUI,CustomerTransactionPanelUI,StatisticalAnalyPanelUI];
			
			menuBtnList = [uiSkin.workBtn,uiSkin.picBtn,uiSkin.orderbtn,uiSkin.companyBtn,uiSkin.moneyBtn,uiSkin.settingBtn,uiSkin.customBtn,uiSkin.transactionBtn,uiSkin.statisticalBtn];
			
			for(var i:int=0;i < menuBtnList.length;i++)
			{
				menuBtnList[i].on(Event.CLICK,this,onClickMenu,[i]);
				menuBtnList[i].getChildByName("menuName").on(Event.CLICK,this,onClickMenu,[i]);
			}
			uiSkin.shrinkBtn.on(Event.CLICK,this,onShrink);
			switchLeftPanelState();
			onClickMenu(0);
				
			uiSkin.gotoFirst.on(Event.CLICK,this,function(){
				
				if((curView.scene is MyWorkPanelUI) == false)
				{
					curViewIndex = -1;
					onClickMenu(0);
				
				}

			});
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.SHOW_CONTENT_PANEL,this,changeContentPanel);
			EventCenter.instance.on(EventCenter.UPDAE_USER_NAME,this,updateUserName);

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressListUrl,this,getMyAddressBack,"page=1",null,null);
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMaintainMsg,this,ongetMaintianBack,"","");
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null,null);

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getPlatformConfig,this,getPlatformConfig,null,null,null);

			
			//EventCenter.instance.on(EventCenter.PAUSE_SCROLL_VIEW,this,onPauseScroll);
			//if(Userdata.instance.step == "0")
			//{
			//	ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否观看下单流程教学",ok:"观看",caller:this,callback:showTeaching});
				
			//}


			uiSkin.exitBtn.on(Event.CLICK,this,onExit);
		}
		
		private function showTeaching(b:Boolean):void
		{
			if(b)
			{
				//ViewManager.instance.openView(ViewManager.VIEW_PLAY_VIDEO_PANEL);

			}
		}
		private function onResizeBrower():void
		{
			
			uiSkin.height = Browser.clientHeight * Laya.stage.width/Browser.clientWidth;
			
		}
		
		private function onPauseScroll(scoll:Boolean):void
		{
			if(scoll)
				uiSkin.mainPanel.vScrollBar.target = uiSkin.mainPanel;
			else
				uiSkin.mainPanel.vScrollBar.target = null;
		}
		private function getMyAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.initMyAddress(result.data.expressList as Array);
				Userdata.instance.defaultAddId = result.data.defaultId;
			}
			else if(result.code == "1058" || result.code　== "404")
			{
				//ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);
				ViewManager.instance.openView(ViewManager.VIEW_REGPANEL,true);

			}
		}
		private function getCompanyInfoBack(data:Object):void
		{
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				
				Userdata.instance.isVipCompany = result.data.vip == "1";
				Userdata.instance.checkJumpUrl();
					
				Userdata.instance.dirId = result.data.dirId;
				Userdata.instance.paymentQrCode = result.data.paymentQrCode;
				
				Userdata.instance.company = result.data.name;
				Userdata.instance.companyShort = result.data.shortName;
				Userdata.instance.founderPhone = result.data.founderMobileNumber;
				
			}
		}
		
		private function getPlatformConfig(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.setPlatformConfig(result.data);
					
			}
		}
		
		private function ongetMaintianBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(this.destroyed)
				return;
			
			if(result.status == 0)
			{
				if(result.state == null)
				{
					result.state = 0;
				}
				if(result.state > 0)
				{
					(this.owner["maintaintxt"] as Label).visible = true;
					(this.owner["maintaintxt"] as Label).text = result.msg
				}
			}
			
		}
		
		private function onShrink():void
		{
			if(curShrinkState == 0)
				curShrinkState = 1;
			else
				curShrinkState = 0;
			Userdata.instance.shrinkState = curShrinkState;
			
			EventCenter.instance.event(EventCenter.FIRST_PAGE_SHRINK,[curShrinkState]);
			uiSkin.arrow.scaleX = curShrinkState == 0 ? 1:-1;
			switchLeftPanelState();
			
		}
		
		private function switchLeftPanelState():void
		{
			
			uiSkin.leftMenuPanel.width = curShrinkState == 0 ? 296 : 120;
			uiSkin.coverbg.visible = curShrinkState;
			uiSkin.contentPanel.left = curShrinkState == 0 ? 296 : 120;
			
			for(var i:int=0;i < menuBtnList.length;i++)
			{
				menuBtnList[i].x = curShrinkState == 0 ? menuBtnOriginX:42;
				menuBtnList[i].getChildByName("menuName").visible = curShrinkState ==0;
				
			}
			uiSkin.headimg.x =curShrinkState == 0 ? menuBtnOriginX :(uiSkin.leftMenuPanel.width - uiSkin.headimg.width)/2;
			uiSkin.accountlbl.x = curShrinkState == 0 ?menuBtnOriginX : (uiSkin.leftMenuPanel.width - uiSkin.accountlbl.textField.textWidth)/2;
			uiSkin.exitBtn.text = curShrinkState == 0 ? "退出登录":"退出";
			uiSkin.exitBtn.x = curShrinkState == 0 ? menuBtnOriginX :(uiSkin.leftMenuPanel.width - uiSkin.exitBtn.width)/2;;				
				
			uiSkin.shrinkBtn.x = curShrinkState == 0 ? 268:100;
			
		}
		
		private function onClickMenu(index:int):void
		{
			if(curViewIndex == index)
				return;
			curViewIndex = index;
			
			
			while(uiSkin.contentPanel.numChildren > 0)
			{		
				
				uiSkin.contentPanel.removeChildAt(0);
				
			}
			if(curView)
				curView.destroy(true);
			
			
			for(var i:int=0;i < menuBtnList.length;i++)
			{
				if(menuBtnList[i] != null)
				{
					menuBtnList[i].selected = false;
					(menuBtnList[i].getChildByName("menuName") as Label).color = Constast.CMYK_WHITE;
				}
			}
			menuBtnList[index].selected = true;
			(menuBtnList[index].getChildByName("menuName") as Label).color = Constast.CMYK_BLACK;

			if(viewArr[index])
			{
				curView = new viewArr[index]();
				curView.on(Event.RESIZE,this,onLoadComplete);
				uiSkin.contentPanel.addChild(curView);
				uiSkin.contentPanel.height = curView.height;
			}
			else
				uiSkin.contentPanel.height = 0;
			uiSkin.mainPanel.refresh();
			uiSkin.mainPanel.scrollTo(0,0);
		
		}
		
		private function changeContentPanel(viewName:View,index:int=0,paramdata:*=null):void
		{
			if(viewArr.indexOf(viewName) >=0)
			{
				curViewIndex = -1;
				onClickMenu(viewArr.indexOf(viewName));
			}
			else
			{
				curViewIndex = index;
				
				while(uiSkin.contentPanel.numChildren > 0)
				{		
					
					uiSkin.contentPanel.removeChildAt(0);
					
				}
				if(curView)
					curView.destroy(true);
				
				for(var i:int=0;i < menuBtnList.length;i++)
				{
					if(menuBtnList[i] != null)
					{
						menuBtnList[i].selected = false;
						(menuBtnList[i].getChildByName("menuName") as Label).color = Constast.CMYK_WHITE;
					}
				}
				menuBtnList[index].selected = true;
				(menuBtnList[index].getChildByName("menuName") as Label).color = Constast.CMYK_BLACK;
				
				
				curView = new viewName();
				if(paramdata)
					curView.param = paramdata;
				
				curView.on(Event.RESIZE,this,onLoadComplete);
				uiSkin.contentPanel.addChild(curView);
				//uiSkin.contentPanel.height = curView.height;
				
				uiSkin.mainPanel.refresh();
				uiSkin.mainPanel.scrollTo(0,0);
				
				
			}
		}
		private function onLoadComplete():void
		{
			// TODO Auto Generated method stub
			if(curView)
			{
				uiSkin.contentPanel.height = curView.height;
				uiSkin.mainPanel.refresh();
			}
		}		
		
		private function onExit():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginOutUrl,this,onLoginOutBack,"","post");

		}
		
		private function onLoginOutBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				UtilTool.setLocalVar("userToken","");
				//UtilTool.setLocalVar("userpwd","");
				PaintOrderModel.instance.resetData();
				DirectoryFileModel.instance.resetData();
				Userdata.instance.isLogin = false;
				Userdata.instance.resetData();
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
				
			}
		}
		
		private function updateUserName():void
		{
			uiSkin.accountlbl.text = Userdata.instance.userName;// + Userdata.instance.userAccount;

		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.PAUSE_SCROLL_VIEW,this,onPauseScroll);
			EventCenter.instance.off(EventCenter.SHOW_CONTENT_PANEL,this,changeContentPanel);
			EventCenter.instance.off(EventCenter.UPDAE_USER_NAME,this,updateUserName);

		}
	}
}
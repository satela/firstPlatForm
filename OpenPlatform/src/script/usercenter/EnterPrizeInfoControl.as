package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Input;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.List;
	import laya.ui.Panel;
	import laya.ui.View;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.ErrorCode;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	import model.users.BusinessManVo;
	import model.users.CityAreaVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	import script.usercenter.item.BusinessManCell;
	
	import ui.usercenter.AddressMgrPanelUI;
	import ui.usercenter.ChargePanelUI;
	import ui.usercenter.EnterPrizeInfoPaneUI;
	
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class EnterPrizeInfoControl extends Script
	{
		private var uiSkin:EnterPrizeInfoPaneUI;
		
		private var proid:String = "";
		private var cityid:String = "";
		private var areaid:String = "";
		private var townid:String = "";
		
		private var policyName:String = "";
		
		public function EnterPrizeInfoControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as EnterPrizeInfoPaneUI;
//			uiSkin.provList.itemRender = CityAreaItem;
//			uiSkin.provList.repeatX = 1;
//			uiSkin.provList.spaceY = 2;
//			
//			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
//			uiSkin.provList.selectEnable = true;
//			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
//			uiSkin.provList.refresh();
//			uiSkin.cityList.itemRender = CityAreaItem;
//			uiSkin.cityList.repeatX = 1;
//			uiSkin.cityList.spaceY = 2;
//			
//			uiSkin.cityList.selectEnable = true;
//			
//			uiSkin.cityList.renderHandler = new Handler(this, updateCityList);
//			uiSkin.cityList.selectHandler = new Handler(this, selectCity);
//			
//			
//			uiSkin.areaList.itemRender = CityAreaItem;
//			uiSkin.areaList.selectEnable = true;
//			uiSkin.areaList.repeatX = 1;
//			uiSkin.areaList.spaceY = 2;
//			
//			uiSkin.areaList.renderHandler = new Handler(this, updateCityList);
//			uiSkin.areaList.selectHandler = new Handler(this, selectArea);
//			
//			uiSkin.townList.itemRender = CityAreaItem;
//			uiSkin.townList.selectEnable = true;
//			uiSkin.townList.repeatX = 1;
//			uiSkin.townList.spaceY = 2;
//			
//			uiSkin.townList.renderHandler = new Handler(this, updateCityList);
//			uiSkin.townList.selectHandler = new Handler(this, selectTown);
//			
//
//
//			uiSkin.areabox.visible = false;
//			uiSkin.provbox.visible = false;
//			uiSkin.citybox.visible = false;
//			uiSkin.townbox.visible = false;
//			uiSkin.on(Event.CLICK,this,hideAddressPanel);
			
			uiSkin.changeCompanyInfo.on(Event.CLICK,this,function(){
				
				ViewManager.instance.openView(ViewManager.VIEW_EDIT_COMPANY_INFO_PANEL);
			})
			
			var addrMgr:AddressMgrPanelUI = new AddressMgrPanelUI();
			uiSkin.rightpanel.addChild(addrMgr);
			addrMgr.addComponent(AddressMgrControl);

			//addrMgr.x = 600;
			
			

			Browser.window.uploadApp = this;
			
			uiSkin.addBusinessManPanel.visible = false;
			uiSkin.addBusinessman.on(Event.CLICK,this,function(){
				
				uiSkin.addBusinessManPanel.visible = true;
			});
			
			uiSkin.closeAdd.on(Event.CLICK,this,function(){
				
				uiSkin.addBusinessManPanel.visible = false;
			});
			
			uiSkin.confrimAddMan.on(Event.CLICK,this,confirmAddBusinessMan);
			
			
			uiSkin.businessList.repeatX = 1;
			uiSkin.businessList.spaceY = 0;
			uiSkin.businessList.itemRender = BusinessManCell;
			uiSkin.businessList.renderHandler = new Handler(this, updateBusinessManList);
			uiSkin.businessList.selectEnable = false;
			uiSkin.businessList.array = [];
			
			uiSkin.businessName.maxChars = 8;
			uiSkin.contactPhone.restrict = "0-9";
			uiSkin.contactPhone.maxChars = 11;
			
			
			//uiSkin.leaveGroupBtn.visible = false;
			uiSkin.leaveGrpPanel.visible = false;
			uiSkin.closeLeaveBtn.on(Event.CLICK,this,function(){
				
				uiSkin.leaveGrpPanel.visible = false;
				
			});
			uiSkin.leaveGroupBtn.on(Event.CLICK,this,onLeaveGroupRequest);
			uiSkin.verifyCode.restrict = "0-9";
			uiSkin.verifyCode.maxChars = 8;
			
			uiSkin.confirmLeave.on(Event.CLICK,this,confirmLeaveGroupNow);
			
			//uiSkin.chongzhi1.on(Event.CLICK,this,onCharge);

//			if(!ChinaAreaModel.hasInit)
//			{
//				WaitingRespond.instance.showWaitingView(500000);
//				Laya.loader.load([{url:"res/xml/addr.xml",type:Loader.XML}], Handler.create(this, initView), null, Loader.ATLAS);
//			}
//			else
//				initView();

			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAuditInfo ,this,getCompanyInfo,null,"post");
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);
			EventCenter.instance.on(EventCenter.UPDATE_COMPANY_INFO,this,updateCompanyInfo);
			EventCenter.instance.on(EventCenter.UPDATE_BUSINESSMAN_LIST,this,getBusinessmanList);

			getBusinessmanList();
		}
		
		private function updateCompanyInfo():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);

		}
		
		private function changeCompanyInfoBack(datastr:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(datastr as String);
			if(result.status == 0)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");

			}
		}
		
		private function getCompanyInfoBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				policyName = ""
				Userdata.instance.isVipCompany = result.vip == "1";
				//Userdata.instance.factoryMoney = 0;
				
				Userdata.instance.money = Number(result.data.balance);
				
				
				Userdata.instance.factoryMoney =  Number(result.data.factoryBalance);
				

			
				
				uiSkin.companyName.text = result.data.name;
				uiSkin.companyAddr.text = result.data.addr;
				uiSkin.reditCode.text = result.data.idCode;
				//uiSkin.txt_license.text = "";
				uiSkin.shortName.text = result.data.shortName;
				
				Userdata.instance.company = result.data.name;
				Userdata.instance.companyShort = result.data.shortName;
				Userdata.instance.founderPhone = result.data.founderMobileNumber;

				proid = (result.data.regionId as String).slice(0,2) + "0000";
				cityid = (result.data.regionId as String).slice(0,4) + "00";
				areaid = (result.data.regionId as String).slice(0,6);
				townid = result.data.regionId;								
				
				//uiSkin.leaveGroupBtn.visible = true;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);

			}
			else if(result.status == 205)
			{
			}
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);

		}	
		
		
		private function initView(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var arealist:Array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			
			if(proid  != "")
			{
				for(var i:int=0;i < arealist.length;i++)
				{
					if(arealist[i].id == proid)
					{
						policyName = arealist[i].areaName + " " ;
						break;
					}
				}
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+proid ,this,getCityListBack,null,null);

			
		}

		private function getCityListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var arealist:Array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			
			if(cityid  != "")
			{
				for(var i:int=0;i < arealist.length;i++)
				{
					if(arealist[i].id == cityid)
					{
						policyName = policyName + arealist[i].areaName + " " ;
						break;
					}
				}
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+cityid ,this,getAreaListBack,null,null);
			
			
		}
		
		private function getAreaListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var arealist:Array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			
			if(areaid  != "")
			{
				for(var i:int=0;i < arealist.length;i++)
				{
					if(arealist[i].id == areaid)
					{
						policyName = policyName + arealist[i].areaName + " " ;
						break;
					}
				}
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+areaid ,this,getTownListBack,null,null);
			
			
		}
		
		private function getTownListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var arealist:Array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			
			if(townid  != "")
			{
				for(var i:int=0;i < arealist.length;i++)
				{
					if(arealist[i].id == townid)
					{
						policyName = policyName + arealist[i].areaName + " " ;
						uiSkin.companyAddr.text = policyName + uiSkin.companyAddr.text;
						break;
					}
				}
			}
			
			
			
		}
		
		private function onLeaveGroupRequest():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:showLeavePanel,msg:"退出公司将清除相关数据，是否确定退出公司？",delayTime:6});
		}
		private function showLeavePanel(b:Boolean):void
		{
			if(b)
			{
				//uiSkin.leaveGrpPanel.visible = true;				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.leaveGroupUrl ,this,leaveGroupBack,null,"post");

			}
		}
		
//		private function confirmLeaveGroupNow():void
//		{
//			if(uiSkin.verifyCode.text == "")
//			{
//				ViewManager.showAlert("请输入验证码");
//				return;
//			}
//			var parm:String = "code=" + uiSkin.verifyCode.text;
//			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.leaveGroupUrl ,this,leaveGroupBack,parm,"post");
//			
//		}
		
		private function leaveGroupBack(data:*):void
		{
			var result:Object = JSON.parse(data);
			if(result.code == "0")
			{
				ViewManager.showAlert("退出公司成功");
				//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
				UtilTool.setLocalVar("userToken","");
				//UtilTool.setLocalVar("userpwd","");
				PaintOrderModel.instance.resetData();
				DirectoryFileModel.instance.resetData();
				Userdata.instance.isLogin = false;
				Userdata.instance.resetData();
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
			}
		}
		
		private function updateBusinessManList(cell:BusinessManCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function confirmAddBusinessMan():void
		{
			if(uiSkin.businessName.text == "")
			{
				ViewManager.showAlert("请输入业务员姓名");
				return;
			}
			if(uiSkin.contactPhone.text.length < 11)
			{
				ViewManager.showAlert("请输入正确的联系电话");
				return;
			}
			
			var requestStr:Object = {};
			requestStr.mobileNumber = uiSkin.contactPhone.text;
			requestStr.name =  uiSkin.businessName.text;
			
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addBusinessMan,this,addBusinessback,JSON.stringify(requestStr),"post");
			
		}
		
		private function addBusinessback(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				getBusinessmanList();
			}
			uiSkin.addBusinessManPanel.visible = false;
		}
		private function getBusinessmanList():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listBusinessMan,this,getBusinessManBack,null,null);

		}
		private function getBusinessManBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var mans:Array = result.data as Array;
			var businessMan:Array = [];
			for(var i:int=0;i < mans.length;i++)
				businessMan.push(new BusinessManVo(mans[i]));
			uiSkin.businessList.array = businessMan;
			
		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_COMPANY_INFO,this,updateCompanyInfo);
			EventCenter.instance.off(EventCenter.UPDATE_BUSINESSMAN_LIST,this,getBusinessmanList);

		}
	}
}
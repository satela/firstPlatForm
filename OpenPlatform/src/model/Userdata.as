package model
{
	import laya.utils.Browser;
	
	import model.users.AddressVo;
	
	import script.ViewManager;
	
	import ui.usercenter.AddressMgrPanelUI;

	public class Userdata
	{
		public var version:String = "";
		private static var _instance:Userdata;
		
		public var curRandomStr:String;
		
		public var userId:int;
		public var userSession:String;
		
		public var userAccount:String;
		
		public var token:String = "";
		
		public var founderPhone:String;
		
		public var userName:String = "";
		
		public var company:String;
		public var companyShort:String;
		
		public var isVipCompany:Boolean = false;
		public var dirId:String;

		public var addressList:Array = [];
		public var defaultAddId:String = "";//默认收货地址
		
		public var money:Number;
		
		public var actMoney:Number;//活动返现
		
		public var frezeMoney:Number;
		
		public var factoryMoney:Number;//代充余额
		public var isLogin:Boolean = false;
		
		public var defaultAddrid:String = "0";
		
		public var loginTime:Number = 0;
		
		//public var  accountType get;//1 公司创建者  0 公司职员
		
	
		public var privilege:Array;//用户权限
		
		public var hashowact:Boolean = false;
		
		public var hasBuySorage:int = 60;
		
		public var storageBuyDate:Number = 0;
		
		public var storageExpiredDate:Number = 0;;
		
		public var orderAmoutRatio:Number = 0;
		
		public var ignoreDelivery:Boolean = false;//忽略配送

		public var shrinkState:int = 0;//主页左边展开还是收起
		
		public var inOrdering:Boolean = false;
		
		public var step:String = "0";//是否新手
		
		public var firstOrder:String = "0";//是否首单
		
		public var configVersion:String;

		public var clientCode:String;
		
		public var webCode:String;
		
		public var orgAudit:Boolean = false;//是否需要审核注册公司
		public var orgAuditState:int = -1;//公司审核状态 -1 没有提交审核 0 审核中 1 审核通过 2 审核拒绝
		public var defaultManufactureSelected = true;
		public var orderBasePrice:Number = 2;
		public var paymentQrCode:String = "";//二维码收款图片
		
		public static function get instance():Userdata
		{
			if(_instance == null)
				_instance = new Userdata();
			return _instance;
		}
		public function Userdata()
		{
			
		}
		
		public function resetData():void
		{
			addressList = [];
			isLogin = false;
			money = 0;
			actMoney = 0;
			frezeMoney = 0;
			accountType = 0;
			company = null;
			companyShort = null;
			token = "";
			inOrdering = false;
			privilege =[];
			paymentQrCode = "";
		}
		
		public function get accountType():int
		{
			if(privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0)
				return 1
			else
				return 0;
		}
		public function set accountType(value:int):void
		{
			
		}
		
		public function initMyAddress(adddata:Array):void
		{
			addressList = [];
			for(var i:int=0;i < adddata.length;i++)
			{
				addressList.push(new AddressVo(adddata[i]));
				addressList[i].customerId = 0;

			}			
			
		}
		
		public function canAddNewAddress():Boolean
		{
//			for(var i:int=0;i < addressList.length;i++)
//			{
//				if(addressList[i].status == 0)
//					return false;
//			}
			
			return true;
		}
		public function addNewAddress(adddata:Object):void
		{
			if(addressList == null)
				addressList = [];
			addressList.push(new AddressVo(adddata));

		}
		
		public function get passedAddress():Array
		{
			if(addressList == null || addressList.length == 0)
				addressList = [];
		
				return addressList;			
			
		}

		
		public function updateAddress(adddata:Object):void
		{
			for(var i:int=0;i < addressList.length;i++)
			{
				if(addressList[i].id == adddata.id)
				{
					addressList[i] = new AddressVo(adddata);
					break;
				}
			}
		}
		public function deleteAddr(id:String):void
		{
			for(var i:int=0;i < addressList.length;i++)
			{
				if(addressList[i].id == id)
				{
					addressList.splice(i,1);
					break;
				}
			}
		}
		
		public function getDefaultAddress():AddressVo
		{
			var validAddList:Array = passedAddress;
			
			if(validAddList == null || validAddList.length == 0)
				return null;
			else
			{
				for(var i:int=0;i < validAddList.length;i++)
				{
					if(validAddList[i].id == defaultAddId)
						return validAddList[i];
				}
			}
			
			return validAddList[0];
		}
		
		public function isHidePrice():Boolean
		{
			if(privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0)
				return false;
			else if(privilege.indexOf(Constast.DISPLAY_ORDER_PRICE) >= 0)
				return false;
			else
				return true;
		}
		
		public function storageNoDel():Boolean
		{
			return hasBuySorage > 0 && (storageBuyDate + 24*3600*1000*365 )  > (new Date()).getTime();
			
		}
		//获取上个月订单占比
		public function getLastMonthRatio(caller:* = null,callfun:Function = null):void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryFee,this,function(data:*){
				
				var result:Object = JSON.parse(data as String);
				
				if(result.code == "0")
				{
					if(parseFloat(result.zone_last_month) != 0)
						Userdata.instance.orderAmoutRatio = parseFloat(result.group_last_month)/parseFloat(result.zone_last_month)*100;
					else
						Userdata.instance.orderAmoutRatio = 0;
					
					if(caller && callfun) callfun.call(caller);

				}
				
			},null,null);			
		}
		
		public function setPlatformConfig(configlist:Array):void
		{
			if(configlist)
			{
				for(var i:int=0;i < configlist.length;i++)
				{
					if(configlist[i].code == "BASE_PRICE")
						orderBasePrice = parseFloat(configlist[i].value);
					else if(configlist[i].code == "MANUFACTURER_SELECTED")
						defaultManufactureSelected = configlist[i].value == "0";
					
				}
			}
		}
		public function checkJumpUrl():void
		{
			var pageurl:String = Browser.window.location.href;
			if(pageurl.indexOf("cmyk") < 0)
			{
				return;
			}
			if(pageurl.indexOf("super") < 0 && Userdata.instance.isVipCompany)
			{
				ViewManager.showAlert("超级企业账号请前往www.cmyk.vip/super下单");
				Browser.window.open("about:self","_self").location.href = "https://cmyk.vip/super";
				
			}
			
			if(pageurl.indexOf("super") >= 0 && !Userdata.instance.isVipCompany)
			{
				ViewManager.showAlert("普通企业账号请前往www.cmyk.vip下单");
				Browser.window.open("about:self","_self").location.href = "https://cmyk.vip/";
			}
		}
		
	}
}
package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.List;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.ChinaAreaModel;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.AddressVo;
	import model.users.CityAreaVo;
	import model.users.CustomVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	
	import ui.order.AddCommentPanelUI;
	import ui.usercenter.NewAddressPanelUI;
	
	import utils.UtilTool;
	
	public class AddressEditControl extends Script
	{
		private var uiSkin:NewAddressPanelUI;
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		
		private var param:Object;
		private var address:AddressVo;
		
		private var isAddOrEdit:Boolean = true;//true add false edit
		private var hasinit:Boolean = false;
		
		private var httpUrl:String;
		private var customer:CustomVo;
		private var deliveryList:Array;
		public function AddressEditControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as NewAddressPanelUI;
			
			httpUrl = param.url;
			customer = param.customer;
			
			if( param.address != null)
			{
				isAddOrEdit = false;
				address = param.address;
			}
			
			//uiSkin.mainpanel.vScrollBarSkin = "";
			//uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
			uiSkin.input_username.maxChars = 8;
			uiSkin.input_phone.maxChars = 20;
			uiSkin.input_phone.restrict = "0-9" + "-";
			uiSkin.input_address.maxChars = 50;
			
			uiSkin.provList.itemRender = CityAreaItem;
			uiSkin.provList.vScrollBarSkin = "";
			uiSkin.provList.repeatX = 1;
			uiSkin.provList.spaceY = 2;
			
			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
			uiSkin.provList.selectEnable = true;
			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
			uiSkin.provList.array = [];
			//uiSkin.provList.array = ChinaAreaModel.instance.getAllProvince();
			//uiSkin.provList.refresh();
			uiSkin.cityList.itemRender = CityAreaItem;
			uiSkin.cityList.vScrollBarSkin = "";
			uiSkin.cityList.repeatX = 1;
			uiSkin.cityList.spaceY = 2;
			
			uiSkin.cityList.selectEnable = true;
			
			uiSkin.cityList.renderHandler = new Handler(this, updateCityList);
			uiSkin.cityList.selectHandler = new Handler(this, selectCity);
			
			
			uiSkin.areaList.itemRender = CityAreaItem;
			uiSkin.areaList.vScrollBarSkin = "";
			uiSkin.areaList.selectEnable = true;
			uiSkin.areaList.repeatX = 1;
			uiSkin.areaList.spaceY = 2;
			
			uiSkin.areaList.renderHandler = new Handler(this, updateCityList);
			uiSkin.areaList.selectHandler = new Handler(this, selectArea);
			
			uiSkin.townList.itemRender = CityAreaItem;
			uiSkin.townList.vScrollBarSkin = "";
			uiSkin.townList.selectEnable = true;
			uiSkin.townList.repeatX = 1;
			uiSkin.townList.spaceY = 2;
			
			uiSkin.townList.renderHandler = new Handler(this, updateCityList);
			uiSkin.townList.selectHandler = new Handler(this, selectTown);
			uiSkin.cityList.array = [];
			uiSkin.areaList.array = [];
			uiSkin.townList.array = [];

			
			uiSkin.btnSelProv.on(Event.CLICK,this,onShowProvince);
			uiSkin.btnSelCity.on(Event.CLICK,this,onShowCity);
			uiSkin.btnSelArea.on(Event.CLICK,this,onShowArea);
			uiSkin.btnSelTown.on(Event.CLICK,this,onShowTown);
			
			//uiSkin.bgimg.alpha = 0.9;
			uiSkin.areabox.visible = false;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.townbox.visible = false;
			
			
			
			if(isAddOrEdit == false)
			{
				uiSkin.input_username.text = address.receiverName;
				uiSkin.input_phone.text = address.phone;
				uiSkin.input_address.text = address.address;
				
				
				
			}
			uiSkin.on(Event.CLICK,this,hideAddressPanel);
			
			this.uiSkin.btnok.on(Event.CLICK,this,onSubmitAdd);
			this.uiSkin.btncancel.on(Event.CLICK,this,onCloseView);
			
			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId=0" ,this,initAddr,null,null);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			uiSkin.getDeliveryList.on(Event.CLICK,this,function(){
				
				if(zoneid != null)
				{
					var params:String = "clientCode=" + Userdata.instance.clientCode + "&addrId="+zoneid + "&webCode=" + Userdata.instance.webCode;
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeaultDeliveryList + params ,this,getDeliveryListBack,null,null);
				
				}

				
			})
				
			if((customer != null && customer.id != "0") || !isAddOrEdit)
			{
				uiSkin.deliveryBox.visible = true;
			}
			else
				uiSkin.deliveryBox.visible = false;

			
		}
		
		private function startDragPanel(e:Event):void
		{			
			//if(e.target == uiSkin.techcontent.vScrollBar.slider.bar || e.target == uiSkin.techcontent.hScrollBar.slider.bar)
			//	return;
			
			uiSkin.dragImg.startDrag();//new Rectangle(0,0,Browser.width,Browser.height));
			e.stopPropagation();
		}
		private function stopDragPanel():void
		{
			uiSkin.dragImg.stopDrag();
		}
		
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
		}
		
		private function getDeliveryListBack(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			var allDelviery:Array = result as Array;
			if(allDelviery != null)
			{
				var deliveryStr:String = "";
				var defaultIndex:int = -1;
				for(var i:int=0;i < allDelviery.length;i++)
				{
					deliveryStr += allDelviery[i].name;
					if(i < allDelviery.length - 1)
						deliveryStr += ",";
					if(address != null && address.defaultDeliveryType == allDelviery[i].name)
						defaultIndex = i;

				}
				uiSkin.defaulDeliveryType.labels = deliveryStr;
				if(deliveryStr.length > 0)
					uiSkin.defaulDeliveryType.selectedIndex = defaultIndex >=0?defaultIndex:0;
				else
				{
					uiSkin.defaulDeliveryType.labels = " ";
					uiSkin.defaulDeliveryType.selectedIndex = 0;
				}
				deliveryList = allDelviery;
			}
		}
		private function hideAddressPanel(e:Event):void
		{
			if(e.target is List)
				return;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			
		}
		private function onShowProvince(e:Event):void
		{
			uiSkin.provbox.visible = true;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			
			e.stopPropagation();
		}
		private function onShowCity(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = true;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			
			e.stopPropagation();
		}
		private function onShowArea(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = true;
			uiSkin.townbox.visible = false;
			e.stopPropagation();
		}
		
		private function onShowTown(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = true;
			e.stopPropagation();
		}
		
		private function updateCityList(cell:CityAreaItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function initAddr(data:String):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			uiSkin.provList.array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			var selpro:int = 0;
			if(isAddOrEdit == false)
			{
				var curprov:Array = address.preAddName.split(" ");
				if(curprov[0] != null)
				{
					for(var i:int=0;i < uiSkin.provList.array.length;i++)
					{
						if(uiSkin.provList.array[i].areaName == curprov[0])
						{
							selpro = i;
							break;
						}
					}
				}
			}
			selectProvince(selpro);
			//			var addvo:AddressVo = param as AddressVo;
			//			
			//			uiSkin.townList.array = ChinaAreaModel.instance.getAllArea(addvo.searchZoneid);
			//			
			//			uiSkin.towntxt.text =  ChinaAreaModel.instance.getAreaName(addvo.zoneid);
			//			
			//			var cityid:String = ChinaAreaModel.instance.getParentId(addvo.searchZoneid);
			//			uiSkin.areaList.array = ChinaAreaModel.instance.getAllArea(cityid);
			//			
			//			uiSkin.areatxt.text =  ChinaAreaModel.instance.getAreaName(addvo.searchZoneid);
			//			
			//			uiSkin.citytxt.text =  ChinaAreaModel.instance.getAreaName(cityid);
			//
			//			 cityid = ChinaAreaModel.instance.getParentId(cityid);
			//			uiSkin.cityList.array = ChinaAreaModel.instance.getAllArea(cityid);			
			//			
			//			uiSkin.province.text = ChinaAreaModel.instance.getAreaName(cityid);
			//			uiSkin.input_username.text = addvo.receiverName;
			//			uiSkin.input_phone.text = addvo.phone;
			//			uiSkin.input_address.text = addvo.address;
			///zoneid = uiSkin.provList.array[0].id;
			
		}
		private function selectProvince(index:int):void
		{
			province = uiSkin.provList.array[index];
			uiSkin.provbox.visible = false;
			uiSkin.province.text = province.areaName;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=" + province.id ,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.cityList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
				var cityindex:int = 0;
				if(isAddOrEdit == false && hasinit == false)
				{
					var curprov:Array = address.preAddName.split(" ");
					if(curprov[1] != null)
					{
						for(var i:int=0;i < uiSkin.cityList.array.length;i++)
						{
							if(uiSkin.cityList.array[i].areaName == curprov[1])
							{
								cityindex = i;
								break;
							}
						}
					}
				}
				
				uiSkin.citytxt.text = uiSkin.cityList.array[cityindex].areaName;
				uiSkin.cityList.selectedIndex = cityindex;
				selectCity(cityindex);
				//zoneid = uiSkin.cityList.array[0].id;
				
			},null,null);
			
			//trace(province);
			//province = uiSkin.provList.cells[index].cityname;
			
			
			//			uiSkin.areaList.array = ChinaAreaModel.instance.getAllArea(uiSkin.cityList.array[0].id);
			//			uiSkin.areaList.refresh();
			//			
			//			uiSkin.areatxt.text = uiSkin.areaList.array[0].areaName;
			//			uiSkin.areaList.selectedIndex = -1;
			//			
			//			uiSkin.townList.array = ChinaAreaModel.instance.getAllArea(uiSkin.areaList.array[0].id);
			//			
			//			
			//			uiSkin.towntxt.text = uiSkin.townList.array[0].areaName;
			//			uiSkin.townList.selectedIndex = -1;
			//			companyareaId = uiSkin.townList.array[0].id;
			
		}
		
		private function selectCity(index:int):void
		{
			uiSkin.citybox.visible = false;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId=" + uiSkin.cityList.array[index].id,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.areaList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
				
				var cityindex:int = 0;
				if(isAddOrEdit == false && hasinit == false)
				{
					var curprov:Array = address.preAddName.split(" ");
					if(curprov[2] != null)
					{
						for(var i:int=0;i < uiSkin.areaList.array.length;i++)
						{
							if(uiSkin.areaList.array[i].areaName == curprov[2])
							{
								cityindex = i;
								break;
							}
						}
					}
				}
				
				uiSkin.areatxt.text = uiSkin.areaList.array[cityindex].areaName;
				uiSkin.areaList.selectedIndex = cityindex;
				selectArea(cityindex);
				
				areaid = uiSkin.areaList.array[cityindex].id;
				
				
			},null,null);
			
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			
			//			uiSkin.areaList.array = ChinaAreaModel.instance.getAllArea(uiSkin.cityList.array[index].id);
			//			uiSkin.areaList.refresh();
			//			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			//			uiSkin.areatxt.text = "";
			//			uiSkin.areatxt.text = uiSkin.areaList.array[0].areaName;
			//			uiSkin.areaList.selectedIndex = -1;
			//			
			//			uiSkin.townList.array = ChinaAreaModel.instance.getAllArea(uiSkin.areaList.array[0].id);
			//			
			//			uiSkin.towntxt.text = uiSkin.townList.array[0].areaName;
			//			uiSkin.townList.selectedIndex = -1;
			//			
			//			companyareaId = uiSkin.townList.array[0].id;
			
			
		}
		
		private function selectArea(index:int):void
		{
			if( index == -1 )
				return;
			
			areaid  = uiSkin.areaList.array[index].id;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=" + uiSkin.areaList.array[index].id ,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				var result:Object = JSON.parse(data as String);
				
				uiSkin.btnSelTown.visible = result.data.length > 0;
				if(result.data.length == 0)
				{
					zoneid = areaid;
					
					var params:String = "clientCode=" + Userdata.instance.clientCode + "&addrId="+ zoneid + "&webCode=" + Userdata.instance.webCode;
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeaultDeliveryList + params ,this,getDeliveryListBack,null,null);
					
					return;
				}
					
				uiSkin.townList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);				
				
				uiSkin.townList.refresh();
				
				var cityindex:int = 0;
				if(isAddOrEdit == false && hasinit == false)
				{
					var curprov:Array = address.preAddName.split(" ");
					if(curprov[3] != null)
					{
						for(var i:int=0;i < uiSkin.townList.array.length;i++)
						{
							if(uiSkin.townList.array[i].areaName == curprov[3])
							{
								cityindex = i;
								break;
							}
						}
					}
				}
				
				uiSkin.towntxt.text = uiSkin.townList.array[cityindex].areaName;
				//uiSkin.townList.selectedIndex = cityindex;
				zoneid = uiSkin.townList.array[cityindex].id;
				
				var params:String = "clientCode=" + Userdata.instance.clientCode + "&addrId="+ zoneid + "&webCode=" + Userdata.instance.webCode;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeaultDeliveryList + params ,this,getDeliveryListBack,null,null);
				//companyareaId = uiSkin.townList.array[0].id;
				
			},null,null);
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;
			
			uiSkin.areabox.visible = false;
			//			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;
			//			
			//			uiSkin.townList.array = ChinaAreaModel.instance.getAllArea(uiSkin.areaList.array[index].id);
			//			uiSkin.townList.refresh();
			//			uiSkin.towntxt.text = uiSkin.townList.array[0].areaName;
			//			uiSkin.townList.selectedIndex = -1;
			//			companyareaId = uiSkin.townList.array[0].id;
			
			
		}
		
		private function selectTown(index:int):void
		{
			if( index == -1 )
				return;
			
			hasinit = true;
			
			uiSkin.townbox.visible = false;
			uiSkin.towntxt.text = uiSkin.townList.array[index].areaName;
			zoneid = uiSkin.townList.array[index].id;
			
			var params:String = "clientCode=" + Userdata.instance.clientCode + "&addrId="+ zoneid + "&webCode=" + Userdata.instance.webCode;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeaultDeliveryList + params ,this,getDeliveryListBack,null,null);
			
			//companyareaId = uiSkin.townList.array[index].id;
			
		}
		
		private function onSubmitAdd():void
		{
			// TODO Auto Generated method stub
			if(uiSkin.input_username.text == "")
			{
				ViewManager.showAlert("请填写收货人姓名");
				return;
			}
			if(uiSkin.input_phone.text == "" || uiSkin.input_phone.text.length < 11)
			{
				ViewManager.showAlert("请填写正确的收货人电话");
				return;
			}
			if(uiSkin.input_address.text == "")
			{
				ViewManager.showAlert("请填写具体的地址");
				return;
			}
			
			if(UtilTool.hasForbidenChars(uiSkin.input_address.text))
			{
				ViewManager.showAlert("地址中不能包含\\、*、/、#、\"、制表符等特殊字符");
				return;
			}
			
			var thirdid:String = areaid;
			var fullcityname:String = uiSkin.province.text + " " + uiSkin.citytxt.text + " " + uiSkin.areatxt.text + " " + (uiSkin.btnSelTown.visible?uiSkin.towntxt.text:"");
			var requestStr:Object = {};
			requestStr.cnee = uiSkin.input_username.text;
			requestStr.mobileNumber =  uiSkin.input_phone.text;
			requestStr.region = zoneid + "|" + thirdid;
			requestStr.addr = uiSkin.input_address.text;
			requestStr.regionName = fullcityname;
			if(customer != null)
				requestStr.customerId = customer.id;
			if(uiSkin.defaulDeliveryType.selectedIndex >= 0 && deliveryList != null)
			{
				if(deliveryList[uiSkin.defaulDeliveryType.selectedIndex] != null)
					requestStr.defaultDelivery = deliveryList[uiSkin.defaulDeliveryType.selectedIndex].name;
			}
//			"cnee=" + uiSkin.input_username.text + "&mobileNumber=" + uiSkin.input_phone.text + "&zone=" + zoneid + "|" + thirdid +
//				"&addr=" + uiSkin.input_address.text + "&zoneName=" + fullcityname;
			if(isAddOrEdit == false)
				requestStr.id=  address.id;
			if(isAddOrEdit)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + httpUrl,this,addAddressback,JSON.stringify(requestStr),"post");
			else
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + httpUrl,this,addAddressback,JSON.stringify(requestStr),"post");

			
			
			//ViewManager.instance.closeView(ViewManager.VIEW_ADD_NEW_ADDRESS);
		}
		private function addAddressback(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				if(customer == null)
				{
					if(isAddOrEdit)
						Userdata.instance.addNewAddress(result.data);
					//else
					//	Userdata.instance.updateAddress(result.data);
				}
				EventCenter.instance.event(EventCenter.UPDATE_MYADDRESS_LIST,Userdata.instance.addressList[Userdata.instance.addressList.length - 1]);

				
				onCloseView();
			}
		}
		
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_ADD_NEW_ADDRESS);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
		}
		
	}
}
package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.List;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	import model.users.AddressGroupVo;
	import model.users.AddressVo;
	import model.users.CustomVo;
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	import script.order.item.AddressGroupSelCell;
	import script.usercenter.item.AddressGroupCell;
	import script.usercenter.item.CitySearchItem;
	import script.usercenter.item.VipAddressCell;
	import script.usercenter.item.VipAddressNoEditCell;
	
	import ui.order.SelectPackAddresstPanelUI;
	import ui.usercenter.AddressListPanelUI;
	
	public class SelectPackAddressController extends Script
	{
		private var uiSkin:SelectPackAddresstPanelUI;
		
		private var tabBtns:Array = [];
		private var curTabIndex:int = -1;
		
		private var hasSelectAddress:Object;
		private var hasSelectGroup:Object;

		private var curPage:int = 1;
		private var totalPage:int = 1;
		
		private var addressPageSize = 20;
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		
		private var grpCurPage:int = 1;
		private var grpTotalPage = 1;
		private var hasinit = false;
		private var pageSize:int = 50;
		
		private var param:Object;
		private var MAX_NUM:int = 100;
		
		private var curCustomer:CustomVo;
		
		public function SelectPackAddressController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as SelectPackAddresstPanelUI;
			
			curCustomer = param as CustomVo;
			if(curCustomer == null || curCustomer.id == "0")
				uiSkin.groupTab.visible = false;
			
			tabBtns.push(uiSkin.addressTab);
			tabBtns.push(uiSkin.groupTab);
			uiSkin.addressTab.on(Event.CLICK,this,clickTabBtn,[0]);
			uiSkin.groupTab.on(Event.CLICK,this,clickTabBtn,[1]);
			
			//地址列表
			uiSkin.addressList.itemRender = VipAddressNoEditCell;
			uiSkin.addressList.repeatX = 1;
			uiSkin.addressList.spaceY = 0;
			
			uiSkin.addressList.renderHandler = new Handler(this, updateAddressList);
			uiSkin.addressList.selectEnable = false;
			hasSelectAddress= {};
			
			var arr:Array = [];
			
			uiSkin.addressList.array = arr;
			
			uiSkin.selectall.on(Event.CHANGE,this,changeSelectedAll);
			uiSkin.searchInput.text = "";
			uiSkin.searchInput.maxChars = 8;
			
			uiSkin.selectNum.text = "0";
			
			uiSkin.provList.itemRender = CitySearchItem;
			uiSkin.provList.vScrollBarSkin = "";
			uiSkin.provList.repeatX = 1;
			uiSkin.provList.spaceY = 2;
			
			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
			uiSkin.provList.selectEnable = true;
			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
			uiSkin.provList.array = [{id:0,areaName:"空"}];
			
			//uiSkin.provList.array = ChinaAreaModel.instance.getAllProvince();
			//uiSkin.provList.refresh();
			uiSkin.cityList.itemRender = CitySearchItem;
			uiSkin.cityList.vScrollBarSkin = "";
			uiSkin.cityList.repeatX = 1;
			uiSkin.cityList.spaceY = 2;
			
			uiSkin.cityList.selectEnable = true;
			
			uiSkin.cityList.renderHandler = new Handler(this, updateCityList);
			uiSkin.cityList.selectHandler = new Handler(this, selectCity);
			uiSkin.cityList.array = [{id:0,areaName:"空"}];
			
			
			uiSkin.areaList.itemRender = CitySearchItem;
			uiSkin.areaList.vScrollBarSkin = "";
			uiSkin.areaList.selectEnable = true;
			uiSkin.areaList.repeatX = 1;
			uiSkin.areaList.spaceY = 2;
			
			uiSkin.areaList.renderHandler = new Handler(this, updateCityList);
			uiSkin.areaList.selectHandler = new Handler(this, selectArea);
			uiSkin.areaList.array = [{id:0,areaName:"空"}];
			
			uiSkin.btnSelProv.on(Event.CLICK,this,onShowProvince);
			uiSkin.btnSelCity.on(Event.CLICK,this,onShowCity);
			uiSkin.btnSelArea.on(Event.CLICK,this,onShowArea);
			
			//uiSkin.bgimg.alpha = 0.9;
			uiSkin.areabox.visible = false;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.on(Event.CLICK,this,hideAddressPanel);
			uiSkin.prePage.on(Event.CLICK,this,onPrevPage);
			uiSkin.nextPage.on(Event.CLICK,this,onNextPage);
			uiSkin.searchInput.maxChars = 20;
			uiSkin.searchbtn.on(Event.CLICK,this,onSearchAddress);
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+ "parentId=0",this,initAddr,null,null);
			
			//分组
			hasSelectGroup = {};
			uiSkin.groupList.itemRender = AddressGroupSelCell;
			uiSkin.groupList.repeatX = 6;
			uiSkin.groupList.spaceY = 20;
			uiSkin.groupList.spaceX = 5;
			
			uiSkin.groupList.renderHandler = new Handler(this, updateGroupList);
			uiSkin.groupList.selectEnable = false;
			
			arr = [];
			uiSkin.searchGroupInput.text = "";
			uiSkin.groupList.array = arr;
			
			uiSkin.searchGroupInput.maxChars = 20;
			
			uiSkin.pageNum.text = "1/1";
			
			uiSkin.gpPrevPage.on(Event.CLICK,this,onGpPrevPage);
			uiSkin.gpNextPage.on(Event.CLICK,this,onGpNextPage);
			uiSkin.searchGrpBtn.on(Event.CLICK,this,onSearchGroup);
			uiSkin.closebtn.on(Event.CLICK,this,closeView);
			uiSkin.okbtn.on(Event.CLICK,this,onOkBtn);
			clickTabBtn(0);
			updateList();
			EventCenter.instance.on(EventCenter.CHANGE_ADDRESS_SELECTED_STATE,this,addressSelected);
			EventCenter.instance.on(EventCenter.CHANGE_ADDRESS_GROUP_SELECTED_STATE,this,addressGroupSelected);

			
		}
		private function clickTabBtn(index:int):void
		{
			if(curTabIndex == index)
				return;
			if(curTabIndex >= 0)
				(tabBtns[curTabIndex] as Button).selected = false;
			
			(tabBtns[index] as Button).selected = true;
			curTabIndex = index;
			uiSkin.addressbox.visible = index == 0;
			uiSkin.groupBox.visible = index == 1;
			
			
			if(index == 1 && hasinit == false)
			{
				hasinit = true;
				refreshGroupList();
			}
			
		}
		private function updateAddressList(cell:VipAddressCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		
		private function changeSelectedAll():void
		{
			for(var i:int=0;i < uiSkin.addressList.array.length;i++)
			{
				uiSkin.addressList.array[i].selected = uiSkin.selectall.selected;
				if(uiSkin.addressList.array[i].selected && !hasSelectAddress.hasOwnProperty(uiSkin.addressList.array[i].id))
				{
					hasSelectAddress[uiSkin.addressList.array[i].id] = uiSkin.addressList.array[i];
				}
				else if(!uiSkin.addressList.array[i].selected && hasSelectAddress.hasOwnProperty(uiSkin.addressList.array[i].id))
				{
					delete hasSelectAddress[uiSkin.addressList.array[i].id];
				}
			}
			
			for(i=0;i < uiSkin.addressList.cells.length;i++)
			{
				if(i < uiSkin.addressList.array.length)
					(uiSkin.addressList.cells[i] as VipAddressCell).changeSelectState(uiSkin.selectall.selected);
			}
			refreshNum();
		}
		private function addressSelected(address:VipAddressVo):void
		{
			if(address.selected && !hasSelectAddress.hasOwnProperty(address.id)  && address != null)
				hasSelectAddress[address.id] = address;
			else if(!address.selected && hasSelectAddress.hasOwnProperty(address.id))
				
			{
				delete hasSelectAddress[address.id];

			}
			refreshNum();
		}
		private function refreshNum():void
		{
			var num:int = 0;
			for(var key:* in hasSelectAddress)
				num++;
			for(var key:* in hasSelectGroup)
				num += hasSelectGroup[key].count;
			
			uiSkin.selectNum.text = num + "";
		}
		
		private function updateCityList(cell:CityAreaItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function initAddr(data:String):void
		{
			var result:Object = JSON.parse(data as String);
			
			(result.data as Array).unshift({id:0,areaName:"空"});
			
			uiSkin.provList.array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			//var selpro:int = 0;
			
			//selectProvince(selpro);
			
			
		}
		private function selectProvince(index:int):void
		{
			province = uiSkin.provList.array[index];
			uiSkin.provbox.visible = false;
			uiSkin.province.text = province.areaName;
			
			uiSkin.cityList.selectedIndex = 0;
			this.selectCity(0);
			if(province.id == 0)
			{
				
				uiSkin.cityList.array = [{id:0,areaName:"空"}];
				return;
				
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId=" + province.id,this,function(data:String)
			{
				var result:Object = JSON.parse(data as String);
				
				(result.data as Array).unshift({id:0,areaName:"空"});
				
				uiSkin.cityList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
				
				
			},null,null);
			
			
			
		}
		
		private function selectCity(index:int):void
		{
			uiSkin.citybox.visible = false;
			
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			
			uiSkin.areaList.selectedIndex = 0;
			
			this.selectArea(0);
			
			if(uiSkin.cityList.array[index].id == 0)
			{
				uiSkin.areaList.array = [{id:0,areaName:"空"}];
				
				return;
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=" + uiSkin.cityList.array[index].id,this,function(data:String)
			{
				var result:Object = JSON.parse(data as String);
				
				(result.data as Array).unshift({id:0,areaName:"空"});
				
				uiSkin.areaList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
								
				
			},null,null);
			
			
			
		}
		
		private function selectArea(index:int):void
		{
			if( index == -1 )
				return;
			
			areaid  = uiSkin.areaList.array[index].id;
			
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;
			
			uiSkin.areabox.visible = false;
			
			
		}
		private function onShowProvince(e:Event):void
		{
			uiSkin.provbox.visible = true;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			
			e.stopPropagation();
		}
		private function onShowCity(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = true;
			uiSkin.areabox.visible = false;
			
			e.stopPropagation();
		}
		private function onShowArea(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = true;
			e.stopPropagation();
		}
		
		private function onPrevPage():void
		{
			if(curPage <= 1)
				return;
			curPage--;
			//hasSelectAddress = {};
			updateList();
		}
		
		private function onNextPage():void
		{
			if(curPage >= totalPage)
				return;
			curPage++;
			//hasSelectAddress = {};
			
			updateList();
		}
		private function hideAddressPanel(e:Event):void
		{
			if(e.target is List)
				return;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			
		}
		
		private function onSearchAddress():void
		{
			curPage = 1;
			updateList();
		}
		private function updateList():void
		{
			var addr:String = "";
			if(uiSkin.provList.selectedIndex > 0)
			{
				addr += uiSkin.province.text;
				if(uiSkin.cityList.selectedIndex > 0)
					addr +=" " + uiSkin.citytxt.text;
				if(uiSkin.areaList.selectedIndex > 0)
					addr += " " + uiSkin.areatxt.text;
			}
			
			
			if(curCustomer == null || curCustomer.id == "0")
			{
				if(Userdata.instance.passedAddress.length == 0)
				{
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressListUrl,this,getMyAddressBack,"page=1",null,null);
					
				}
				else
					uiSkin.addressList.array = Userdata.instance.passedAddress;
			}
			else
				updateCustomeList();
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,getMyAddressBack,"opt=list&page=" + curPage +"&hidden=0&addr=" + addr + "&keyword=" + uiSkin.searchInput.text,"post");
			
		}
		
		private function updateCustomeList():void
		{
			var addr:String = "";
			if(uiSkin.areaList.selectedIndex > 0)
			{
				addr = uiSkin.areaList.array[uiSkin.areaList.selectedIndex].id;
				
			}
			else if(uiSkin.cityList.selectedIndex > 0)
				addr = uiSkin.cityList.array[uiSkin.cityList.selectedIndex].id;
			else if(uiSkin.provList.selectedIndex > 0)
				addr = uiSkin.provList.array[uiSkin.provList.selectedIndex].id;
			
			var paramdata:String = "customerId=" + curCustomer.id + "&pageNo=" + curPage + "&pageSize=" + addressPageSize + "&region=" + addr + "&keyword=" + uiSkin.searchInput.text;
				
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listCustomerAddress + paramdata,this,getCustomerAddressBack,null,null,null);
			
		}
		private function getCustomerAddressBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//Userdata.instance.initMyAddress(result.data.expressList as Array);
				//Userdata.instance.defaultAddId = result.data.defaultId;
				
				var addressList:Array = [];
				for(var i:int=0;i < result.data.expressList.length;i++)
				{
					addressList.push(new AddressVo(result.data.expressList[i]));
					addressList[i].customerId = curCustomer.id;
					addressList[i].customerName = curCustomer.customerName;
					addressList[i].defaultPayType = curCustomer.defaultPayment;
					
				}			
				
				totalPage = Math.ceil(result.data.totalCount/pageSize);
				if(totalPage < 1)
					totalPage = 1;
				uiSkin.pageNum.text = curPage + "/" + totalPage;
				
				
				//var tempAdd:Array = Userdata.instance.addressList;
				
				uiSkin.addressList.array = addressList;
				
				
			}
		}
		
		private function getMyAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				var addressList = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					addressList.push(new VipAddressVo(result.data[i]));
					addressList[i].selected = hasSelectAddress.hasOwnProperty(addressList[i].id);
						
				}			
				
				//var tempAdd:Array = Userdata.instance.addressList;
				//tempAdd.sort(compareAddress);
				uiSkin.addressList.array = addressList;
				totalPage = result.totalpage;
				if(totalPage < 1)
					totalPage = 1;
				uiSkin.pageNum.text = curPage + "/" + totalPage;
				//refreshNum();
				
			}
		}
		
		//分组
		private function updateGroupList(cell:AddressGroupCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onSearchGroup():void
		{
			grpCurPage = 1;
			refreshGroupList();
		}
		private function addressGroupSelected(groupcell:AddressGroupSelCell,group:AddressGroupVo):void
		{
			if(group.selected && !hasSelectGroup.hasOwnProperty(group.groupId)  && group != null)
				hasSelectGroup[group.groupId] = group;
			else if(!group.selected && hasSelectGroup.hasOwnProperty(group.groupId))
				
			{
				delete hasSelectGroup[group.groupId];
				
			}
			refreshNum();
		}
		
		private function onCloseView(viewname:String):void
		{
			if(viewname == ViewManager.VIEW_ADDRESS_GROUP_MGR_PANEL)
			{
				refreshGroupList();
			}
		}
		private function refreshGroupList():void
		{
			var paramdata:String = "customerId=" + curCustomer.id + "&name=" + uiSkin.searchGroupInput.text + "&pageNo=" + grpCurPage + "&pageSize=" + pageSize;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressGroupManageList+paramdata,this,listGroupBack,null,null);
			
		}
		
		private function listGroupBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var groupList = [];
				for(var i:int=0;i < result.data.expressGroupList.length;i++)
				{
					groupList.push(new AddressGroupVo(result.data.expressGroupList[i]));
				}			
				
				//var tempAdd:Array = Userdata.instance.addressList;
				//tempAdd.sort(compareAddress);
				uiSkin.groupList.array = groupList;
				grpTotalPage = Math.ceil(result.data.totalCount/pageSize);
				if(grpTotalPage < 1)
					grpTotalPage = 1;
				
				uiSkin.grPageNum.text = grpCurPage + "/" + grpTotalPage;
			}
		}
		
		private function onGpPrevPage():void
		{
			if(grpCurPage <= 1)
				return;
			grpCurPage--;
			refreshGroupList();
		}
		
		private function onGpNextPage():void
		{
			if(grpCurPage >= grpTotalPage)
				return;
			grpCurPage++;
			refreshGroupList();
		}
		
		private function onOkBtn():void
		{
			
			var selectgroup:Array= [];
			for(var key:* in hasSelectGroup)
				selectgroup.push(key);
			var postdata:Object = {"expressGroupIds":selectgroup};
			
			if(selectgroup.length > 0)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listGroupsAddress,this,getGroupAddressBack,JSON.stringify(postdata),"post");

			}
			else
				sendAddressToPackage([]);
		}
		
		private function getGroupAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var addressList = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					addressList.push(new VipAddressVo(result.data[i]));
				}
				sendAddressToPackage(addressList);
			}
		}
		
		private function sendAddressToPackage(addrList:Array):void
		{
			var arr:Array = [];
			for(var key:* in hasSelectAddress)
				arr.push(hasSelectAddress[key]);
			addrList = addrList.concat(arr);
			if(PaintOrderModel.instance.packageList.length + addrList.length > MAX_NUM)
			{
				ViewManager.showAlert("一次下单最多添加" + MAX_NUM + "个包裹，当前包裹数量为" + (PaintOrderModel.instance.packageList.length + addrList.length) + "个");
				return;
			}
			EventCenter.instance.event(EventCenter.SELECT_PACK_ADDRESS_OK,[addrList]);
			closeView();
		}
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PACK_ADDRESS_PANEL);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.CHANGE_ADDRESS_SELECTED_STATE,this,addressSelected);
			EventCenter.instance.off(EventCenter.CHANGE_ADDRESS_GROUP_SELECTED_STATE,this,addressGroupSelected);

		}
	}
}
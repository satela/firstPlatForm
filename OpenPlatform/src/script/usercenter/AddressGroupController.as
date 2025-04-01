package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.List;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.AddressGroupVo;
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	import script.usercenter.item.AddressGroupCell;
	import script.usercenter.item.CitySearchItem;
	import script.usercenter.item.VipAddressCell;
	
	import ui.usercenter.AddressGroupPanelUI;
	
	public class AddressGroupController extends Script
	{
		private var uiSkin:AddressGroupPanelUI;
		
		private var tabBtns:Array = [];
		private var curTabIndex:int = -1;
		private var curPage:int = 1;
		private var totalPage:int = 1;
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		
		
		private var grpCurPage:int = 1;
		private var grpTotalPage = 1;
		private var hasinit = false;
		
		public function AddressGroupController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AddressGroupPanelUI;
			
			//地址列表
			uiSkin.addressList.itemRender = VipAddressCell;
			uiSkin.addressList.repeatX = 1;
			uiSkin.addressList.spaceY = 0;
			
			uiSkin.addressList.renderHandler = new Handler(this, updateAddressList);
			uiSkin.addressList.selectEnable = false;
			
			var arr:Array = [];
//			for(var i:int=0;i < 20;i++)
//			{
//				arr.push(new VipAddressVo({"selected":false,"zone":"101|110"}));
//			}
			uiSkin.addressList.array = arr;

			tabBtns.push(uiSkin.addressTab);
			tabBtns.push(uiSkin.groupTab);

			uiSkin.selectall.on(Event.CHANGE,this,changeSelectedAll);
			uiSkin.delBatchBtn.on(Event.CLICK,this,batchDeleteAddr);
			uiSkin.searchInput.maxChars = 8;
			
			uiSkin.addressList.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.addressList.on(Event.MOUSE_OUT,this,resumeParentScroll);

			
			uiSkin.addressTab.on(Event.CLICK,this,clickTabBtn,[0]);
			uiSkin.groupTab.on(Event.CLICK,this,clickTabBtn,[1]);
			uiSkin.addAddress.on(Event.CLICK,this,showAddAddressPanel);
			uiSkin.searchInput.text = "";
			
			uiSkin.provList.itemRender = CitySearchItem;
			uiSkin.provList.vScrollBarSkin = "";
			uiSkin.provList.repeatX = 1;
			uiSkin.provList.spaceY = 2;
			
			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
			uiSkin.provList.selectEnable = true;
			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
			uiSkin.provList.array = [{id:0,areaname:"空"}];
			
			//uiSkin.provList.array = ChinaAreaModel.instance.getAllProvince();
			//uiSkin.provList.refresh();
			uiSkin.cityList.itemRender = CitySearchItem;
			uiSkin.cityList.vScrollBarSkin = "";
			uiSkin.cityList.repeatX = 1;
			uiSkin.cityList.spaceY = 2;
			
			uiSkin.cityList.selectEnable = true;
			
			uiSkin.cityList.renderHandler = new Handler(this, updateCityList);
			uiSkin.cityList.selectHandler = new Handler(this, selectCity);
			uiSkin.cityList.array = [{id:0,areaname:"空"}];

			
			uiSkin.areaList.itemRender = CitySearchItem;
			uiSkin.areaList.vScrollBarSkin = "";
			uiSkin.areaList.selectEnable = true;
			uiSkin.areaList.repeatX = 1;
			uiSkin.areaList.spaceY = 2;
			
			uiSkin.areaList.renderHandler = new Handler(this, updateCityList);
			uiSkin.areaList.selectHandler = new Handler(this, selectArea);
			uiSkin.areaList.array = [{id:0,areaname:"空"}];

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
			uiSkin.searchAddressBtn.on(Event.CLICK,this,onSearchAddress);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer ,this,initAddr,"parentid=0","post");

			
			//地址分组
			uiSkin.groupList.itemRender = AddressGroupCell;
			uiSkin.groupList.repeatX = 6;
			uiSkin.groupList.spaceY = 20;
			uiSkin.groupList.spaceX = 5;

			uiSkin.groupList.renderHandler = new Handler(this, updateGroupList);
			uiSkin.groupList.selectEnable = false;
			
			 arr = [];
			uiSkin.searchGroupInput.text = "";
			uiSkin.groupList.array = arr;
			uiSkin.createGroupBox.visible = false;
			uiSkin.addGroup.on(Event.CLICK,this,onshowCreateGroup);
			uiSkin.closeNewGroup.on(Event.CLICK,this,oncloseCreateGroup);
			uiSkin.newGroupName.maxChars = 8;
			uiSkin.searchGroupInput.maxChars = 20;
			uiSkin.confirmCreateGroup.on(Event.CLICK,this,createGroupNow);
			
			uiSkin.gpPrevPage.on(Event.CLICK,this,onGpPrevPage);
			uiSkin.gpNextPage.on(Event.CLICK,this,onGpNextPage);
			uiSkin.searchGrpBtn.on(Event.CLICK,this,onSearchGroup);

			EventCenter.instance.on(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);
			EventCenter.instance.on(EventCenter.UPDATE_ADDRESS_GROUP_LIST,this,refreshGroupList);

			EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,onCloseView);

			clickTabBtn(0);
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,getMyAddressBack,"opt=list&page=1&hidden=0&addr=&keyword=","post");


		}
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
		}
		
		//地址列表代码开始
		
		private function updateAddressList(cell:VipAddressCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		
		private function changeSelectedAll():void
		{
			for(var i:int=0;i < uiSkin.addressList.array.length;i++)
			{
				uiSkin.addressList.array[i].selected = uiSkin.selectall.selected;
			}
			
			for(i=0;i < uiSkin.addressList.cells.length;i++)
			{
				(uiSkin.addressList.cells[i] as VipAddressCell).changeSelectState(uiSkin.selectall.selected);
			}
		}
		
		private function batchDeleteAddr():void
		{
			var deleteIds:Array = [];
			for(var i:int=0;i < uiSkin.addressList.array.length;i++)
			{
				if(uiSkin.addressList.array[i].selected)
					deleteIds.push(uiSkin.addressList.array[i].id);
			}
			if(deleteIds.length <=0 )
			{
				ViewManager.showAlert("未选择要删除的地址");
				return;
			}
			
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:confirmDelete,msg:"确定删除这" + deleteIds.length + "条地址吗？"});
		}
		
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				var deleteIds:Array = [];
				for(var i:int=0;i < uiSkin.addressList.array.length;i++)
				{
					if(uiSkin.addressList.array[i].selected)
						deleteIds.push(uiSkin.addressList.array[i].id);
				}
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,deleteAddressBack,"opt=delete&id=" + deleteIds.join(","),"post");

			}
		}
		
		private function deleteAddressBack(data:*):void{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				this.updateList();
			}
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
			uiSkin.createGroupBox.visible = false;
			
			uiSkin.addAddress.visible = index == 0;
			uiSkin.addGroup.visible = index == 1;
			
			if(index == 1 && hasinit == false)
			{
				hasinit = true;
				refreshGroupList();
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
				}			
				
				//var tempAdd:Array = Userdata.instance.addressList;
				//tempAdd.sort(compareAddress);
				uiSkin.addressList.array = addressList;
				totalPage = result.totalpage;
				if(totalPage < 1)
					totalPage = 1;
				
				uiSkin.pageNum.text = curPage + "/" + totalPage;
			}
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
				
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,getMyAddressBack,"opt=list&page=" + curPage +"&hidden=0&addr=" + addr + "&keyword=" + uiSkin.searchInput.text,"post");
			
		}
		
		private function updateCityList(cell:CityAreaItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function initAddr(data:String):void
		{
			var result:Object = JSON.parse(data as String);
			
			(result.status as Array).unshift({id:0,areaname:"空"});
			
			uiSkin.provList.array = result.status as Array;//ChinaAreaModel.instance.getAllProvince();
			//var selpro:int = 0;
			
			//selectProvince(selpro);
			
			
		}
		private function selectProvince(index:int):void
		{
			province = uiSkin.provList.array[index];
			uiSkin.provbox.visible = false;
			uiSkin.province.text = province.areaname;
			
			uiSkin.cityList.selectedIndex = 0;
			this.selectCity(0);
			if(province.id == 0)
			{
				
				uiSkin.cityList.array = [{id:0,areaname:"空"}];
				return;
				
			}

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer ,this,function(data:String)
			{
				var result:Object = JSON.parse(data as String);
				
				(result.status as Array).unshift({id:0,areaname:"空"});

				uiSkin.cityList.array = result.status as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
//				var cityindex:int = 0;
//				
//				uiSkin.citytxt.text = uiSkin.cityList.array[cityindex].areaname;
//				uiSkin.cityList.selectedIndex = cityindex;
//				selectCity(cityindex);
				//zoneid = uiSkin.cityList.array[0].id;
				
			},"parentid=" + province.id,"post");
			
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
			
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaname;

			uiSkin.areaList.selectedIndex = 0;

			this.selectArea(0);

			if(uiSkin.cityList.array[index].id == 0)
			{
				uiSkin.areaList.array = [{id:0,areaname:"空"}];

				return;
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer ,this,function(data:String)
			{
				var result:Object = JSON.parse(data as String);
				
				(result.status as Array).unshift({id:0,areaname:"空"});

				uiSkin.areaList.array = result.status as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
				
//				var cityindex:int = 0;
//				
//				
//				uiSkin.areatxt.text = uiSkin.areaList.array[cityindex].areaname;
//				uiSkin.areaList.selectedIndex = cityindex;
//				selectArea(cityindex);
//				
//				areaid = uiSkin.areaList.array[cityindex].id;
				
				
			},"parentid=" + uiSkin.cityList.array[index].id,"post");
			
			
		
		}
		
		private function selectArea(index:int):void
		{
			if( index == -1 )
				return;
			
			areaid  = uiSkin.areaList.array[index].id;
			
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaname;
			
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
			updateList();
		}
		
		private function onNextPage():void
		{
			if(curPage >= totalPage)
				return;
			curPage++;
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
		
		private function showAddAddressPanel():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADD_NEW_ADDRESS,false,{url:HttpRequestUtil.vipAddressManageUrl});
		}
		//地址列表代码结束
		private function updateGroupList(cell:AddressGroupCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onshowCreateGroup():void
		{
			uiSkin.createGroupBox.visible = true;
		}
		private function oncloseCreateGroup():void
		{
			uiSkin.createGroupBox.visible = false;
		}
		
		private function createGroupNow():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressGroupManageUrl,this,createGroupBack,"opt=insert&name=" + uiSkin.newGroupName.text,"post");
		}
		private function createGroupBack(data:String):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				refreshGroupList();
			}
			oncloseCreateGroup();
		}
		
		private function onSearchGroup():void
		{
			grpCurPage = 1;
			refreshGroupList();
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
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressGroupManageUrl,this,listGroupBack,"opt=list&page=" + grpCurPage + "&keyword=" + uiSkin.searchGroupInput.text,"post");

		}
		
		private function listGroupBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				var groupList = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					groupList.push(new AddressGroupVo(result.data[i]));
				}			
				
				//var tempAdd:Array = Userdata.instance.addressList;
				//tempAdd.sort(compareAddress);
				uiSkin.groupList.array = groupList;
				grpTotalPage = result.totalpage;
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
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);
			EventCenter.instance.off(EventCenter.UPDATE_ADDRESS_GROUP_LIST,this,refreshGroupList);
			EventCenter.instance.off(EventCenter.CLOSE_PANEL_VIEW,this,onCloseView);

		}
		
	}
}
package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.List;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.AddressGroupVo;
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	import script.usercenter.item.CitySearchItem;
	import script.usercenter.item.VipAddressCell;
	import script.usercenter.item.VipAddressNoEditCell;
	
	import ui.usercenter.AddressListPanelUI;
	
	public class AddressListController extends Script
	{
		private var uiSkin:AddressListPanelUI;
		
		private var hasSelectAddressId:Array;
		
		private var curPage:int = 1;
		private var totalPage:int = 1;
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		
		private var param:Object;
		private var grpVo:AddressGroupVo;

		public function AddressListController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AddressListPanelUI;
			
			grpVo = param as AddressGroupVo;
			//地址列表
			uiSkin.addressList.itemRender = VipAddressNoEditCell;
			uiSkin.addressList.repeatX = 1;
			uiSkin.addressList.spaceY = 0;
			
			uiSkin.addressList.renderHandler = new Handler(this, updateAddressList);
			uiSkin.addressList.selectEnable = false;
			hasSelectAddressId = [];
			
			var arr:Array = [];
			
			uiSkin.addressList.array = arr;
			
			uiSkin.selectall.on(Event.CHANGE,this,changeSelectedAll);
			uiSkin.searchInput.maxChars = 8;
			
			uiSkin.selectNum.text = "0";
			
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
			uiSkin.searchbtn.on(Event.CLICK,this,onSearchAddress);
			uiSkin.okbtn.on(Event.CLICK,this,onAddAddress);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer ,this,initAddr,"parentid=0","post");
			
			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			
			uiSkin.closebtn.on(Event.CLICK,this,closeView);
			updateList();
			EventCenter.instance.on(EventCenter.CHANGE_ADDRESS_SELECTED_STATE,this,addressSelected);

		}
		
		private function updateAddressList(cell:VipAddressCell,index:int):void
		{
			cell.setData(cell.dataSource);
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

		private function changeSelectedAll():void
		{
			for(var i:int=0;i < uiSkin.addressList.array.length;i++)
			{
				uiSkin.addressList.array[i].selected = uiSkin.selectall.selected;
				if(uiSkin.addressList.array[i].selected && hasSelectAddressId.indexOf(uiSkin.addressList.array[i].id) < 0)
				{
					hasSelectAddressId.push(uiSkin.addressList.array[i].id);
				}
				else if(!uiSkin.addressList.array[i].selected && hasSelectAddressId.indexOf(uiSkin.addressList.array[i].id) >= 0)
				{
					var index:int = hasSelectAddressId.indexOf(uiSkin.addressList.array[i].id);
					hasSelectAddressId.splice(index,1);
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
			if(address.selected && hasSelectAddressId.indexOf(address.id) < 0  && address != null)
				hasSelectAddressId.push(address.id);
			else if(!address.selected && hasSelectAddressId.indexOf(address.id) >= 0)

			{
				var index:int = hasSelectAddressId.indexOf(address.id);
				hasSelectAddressId.splice(index,1);
			}
			refreshNum();
		}
		private function refreshNum():void
		{
			uiSkin.selectNum.text = hasSelectAddressId.length + "";
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
			hasSelectAddressId = [];
			updateList();
		}
		
		private function onNextPage():void
		{
			if(curPage >= totalPage)
				return;
			curPage++;
			hasSelectAddressId = [];

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
			var hidden:int = uiSkin.hidebtn.selected ? 1:0;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,getMyAddressBack,"opt=list&page=" + curPage +"&hidden=" + hidden +"&addr=" + addr + "&keyword=" + uiSkin.searchInput.text,"post");
			
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
				refreshNum();

			}
		}
		
		private function onAddAddress():void
		{
			if(hasSelectAddressId.length > 0)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.insertGroupAddress,this,addAddressBack,"opt=add&id=" + grpVo.groupId + "&ids=" + hasSelectAddressId.join(","),"post");

			}
			else
			{
				ViewManager.showAlert("请选择需要添加的地址！");
			}
			
		}
		
		private function addAddressBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				EventCenter.instance.event(EventCenter.INSERT_ADDRESS_TO_GROUP,[result.totalcount]);
				closeView();
			}
		}
		
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_ADDRESS_LIST_PANEL);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.CHANGE_ADDRESS_SELECTED_STATE,this,addressSelected);

		}
	}
}
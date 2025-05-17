package script.usercenter
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.List;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.BusinessManVo;
	
	import script.login.CityAreaItem;
	import script.usercenter.item.CitySearchItem;
	
	import ui.orderList.StatisticalAnalyPanelUI;
	
	public class StatisticalAnalyController extends Script
	{
		private var uiSkin:StatisticalAnalyPanelUI;
		
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		
		private var businessManlist:Array;
		private var orderManlist:Array;
		
		private var tabBtns:Array;
		private var curTabIndex:int = -1;

		public function StatisticalAnalyController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as StatisticalAnalyPanelUI;
			
			uiSkin.customListPanel.visible = false;
			uiSkin.curCustomName.text = "全部";
			
			uiSkin.curCustomName.editable = false;
			
			uiSkin.showCustomList.on(Event.CLICK,this,function(){
				
				uiSkin.customListPanel.visible = !uiSkin.customListPanel.visible;
			});
			tabBtns = [];
			tabBtns.push(uiSkin.customerTab);
			tabBtns.push(uiSkin.productTab);
			tabBtns.push(uiSkin.areaTab);

			
			uiSkin.yearComBox.labels = "2026,2025,2024";
			
			uiSkin.monthComBox.labels = "全年,01,02,03,04,05,06,07,08,09,10,11,12";
			
			var curdate:Date = new Date();
			//var curMont:String = (curdate.getMonth()+1) >= 10?(curdate.getMonth()+1).toString():("0" + (curdate.getMonth()+1));						
			uiSkin.yearComBox.selectedLabel = curdate.getFullYear() + "";
			uiSkin.monthComBox.selectedIndex = 0;
			
			
			
			uiSkin.customerTab.on(Event.CLICK,this,clickTabBtn,[0]);
			uiSkin.productTab.on(Event.CLICK,this,clickTabBtn,[1]);
			uiSkin.areaTab.on(Event.CLICK,this,clickTabBtn,[2]);

			
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
			
			
			uiSkin.townList.itemRender = CitySearchItem;
			uiSkin.townList.vScrollBarSkin = "";
			uiSkin.townList.selectEnable = true;
			uiSkin.townList.repeatX = 1;
			uiSkin.townList.spaceY = 2;
			
			uiSkin.townList.renderHandler = new Handler(this, updateCityList);
			uiSkin.townList.selectHandler = new Handler(this, selectTown);
			uiSkin.townList.array = [{id:0,areaName:"空"}];
			
			
			uiSkin.btnSelProv.on(Event.CLICK,this,onShowProvince);
			uiSkin.btnSelCity.on(Event.CLICK,this,onShowCity);
			uiSkin.btnSelArea.on(Event.CLICK,this,onShowArea);
			uiSkin.btnSelTown.on(Event.CLICK,this,onShowTown);

			//uiSkin.bgimg.alpha = 0.9;
			uiSkin.areabox.visible = false;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.on(Event.CLICK,this,hideAddressPanel);
			clickTabBtn(0);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId=0" ,this,initAddr,null,null);

			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listBusinessMan,this,getBusinessManBack,null,null);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listOrderMakers,this,getOrderMakersBack,null,null);
				
				
		}
		
		private function clickTabBtn(index:int):void
		{
			if(curTabIndex == index)
				return;
			if(curTabIndex >= 0)
				(tabBtns[curTabIndex] as Button).selected = false;
			
			(tabBtns[index] as Button).selected = true;
			curTabIndex = index;
			uiSkin.customerQueryBox.visible = index == 0;
			uiSkin.productQueryBox.visible = index == 1;
			uiSkin.areaQueryBox.visible = index == 2;
			
			
			
			
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
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=" + province.id,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				var result:Object = JSON.parse(data as String);
				
				(result.data as Array).unshift({id:0,areaName:"空"});
				
				uiSkin.cityList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
				//				var cityindex:int = 0;
				//				
				//				uiSkin.citytxt.text = uiSkin.cityList.array[cityindex].areaName;
				//				uiSkin.cityList.selectedIndex = cityindex;
				//				selectCity(cityindex);
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
			
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			
			uiSkin.areaList.selectedIndex = 0;
			
			this.selectArea(0);
			
			if(uiSkin.cityList.array[index].id == 0)
			{
				uiSkin.areaList.array = [{id:0,areaName:"空"}];
				
				return;
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId=" + uiSkin.cityList.array[index].id,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				(result.data as Array).unshift({id:0,areaName:"空"});
				
				uiSkin.areaList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
				
				//				var cityindex:int = 0;
				//				
				//				
				//				uiSkin.areatxt.text = uiSkin.areaList.array[cityindex].areaName;
				//				uiSkin.areaList.selectedIndex = cityindex;
				//				selectArea(cityindex);
				//				
				//				areaid = uiSkin.areaList.array[cityindex].id;
				
				
			},null,null);
			
			
			
		}
		
		private function selectArea(index:int):void
		{
			if( index == -1 )
				return;
			
			areaid  = uiSkin.areaList.array[index].id;
			
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;
			
			uiSkin.areabox.visible = false;
			
			uiSkin.townList.selectedIndex = 0;
			
			this.selectTown(0);
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId=" + uiSkin.areaList.array[index].id,this,function(data:String)
			{
				if(uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				(result.data as Array).unshift({id:0,areaName:"空"});
				
				uiSkin.townList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.townList.refresh();
				
				//				var cityindex:int = 0;
				//				
				//				
				//				uiSkin.areatxt.text = uiSkin.areaList.array[cityindex].areaName;
				//				uiSkin.areaList.selectedIndex = cityindex;
				//				selectArea(cityindex);
				//				
				//				areaid = uiSkin.areaList.array[cityindex].id;
				
				
			},null,null);
			
			
		}
		
		private function selectTown(index:int):void
		{
			if( index == -1 )
				return;
			
			areaid  = uiSkin.townList.array[index].id;
			
			
			uiSkin.towntxt.text = uiSkin.townList.array[index].areaName;
			
			uiSkin.townbox.visible = false;
			
			
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
		
		private function getBusinessManBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var mans:Array = result.data as Array;
			var businessMan:Array = [];
			var businessManName:String="全部";
			if(mans.length > 0)
				businessManName += ",";
			for(var i:int=0;i < mans.length;i++)
			{
				businessMan.push(new BusinessManVo(mans[i]));
				
				businessManName += businessMan[i].name+"_" + businessMan[i].mobileNumber;
				if(i < mans.length - 1)
					businessManName +=",";
			}
			uiSkin.businessCombo.labels = businessManName;
			uiSkin.businessCombo.selectedIndex = 0;
			businessManlist = businessMan;
			
			
		}
		
		private function getOrderMakersBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var mans:Array = result.data as Array;
			var businessMan:Array = [];
			var userName:String="全部";
			if(mans.length > 0)
				userName += ",";
			for(var i:int=0;i < mans.length;i++)
			{
				//businessMan.push(new BusinessManVo(mans[i]));
				
				userName += mans[i].nickName+"_" + mans[i].mobileNumber;
				if(i < mans.length - 1)
					userName +=",";
			}
			uiSkin.orderPlaceCombo.labels = userName;
			uiSkin.orderPlaceCombo.selectedIndex = 0;
			orderManlist = mans;
		}
		
	}
}
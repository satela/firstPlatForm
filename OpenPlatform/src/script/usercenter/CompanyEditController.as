package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.List;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	
	import ui.usercenter.CompanyInfoEditPanelUI;
	
	import utils.UtilTool;
	
	public class CompanyEditController extends Script
	{
		private var uiSkin:CompanyInfoEditPanelUI;
		
		private var province:Object;
		
		private var companyareaId:String;
		
		
		private var proid:String = "";
		private var cityid:String = "";
		private var areaid:String = "";
		private var townid:String = "";
		private var hasInit:Boolean = false;
		
		public function CompanyEditController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as CompanyInfoEditPanelUI;
			
			
			uiSkin.provList.itemRender = CityAreaItem;
			uiSkin.provList.repeatX = 1;
			uiSkin.provList.spaceY = 2;
			uiSkin.provList.vScrollBarSkin = "";

			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
			uiSkin.provList.selectEnable = true;
			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
			uiSkin.provList.refresh();
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
			
			uiSkin.provList.array = [];
			uiSkin.cityList.array = [];
			uiSkin.areaList.array = [];
			uiSkin.townList.array = [];
			
			uiSkin.btnSelProv.on(Event.CLICK,this,onShowProvince);
			uiSkin.btnSelCity.on(Event.CLICK,this,onShowCity);
			uiSkin.btnSelArea.on(Event.CLICK,this,onShowArea);
			uiSkin.btnSelTown.on(Event.CLICK,this,onShowTown);

			uiSkin.areabox.visible = false;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.townbox.visible = false;
			uiSkin.on(Event.CLICK,this,hideAddressPanel);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);

			uiSkin.btncancel.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.VIEW_EDIT_COMPANY_INFO_PANEL);
				
			});
			
			uiSkin.btnok.on(Event.CLICK,this,onSaveCompanyInfo);
			
		}
		private function getCompanyInfoBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.input_companyName.text = result.data.name;
				uiSkin.input_address.text = result.data.addr;
				uiSkin.reditCode.text = result.data.idCode;
				uiSkin.input_shortName.text = result.data.shortName;
				
				proid = (result.data.regionId as String).slice(0,2) + "0000";
				cityid = (result.data.regionId as String).slice(0,4) + "00";
				areaid = (result.data.regionId as String).slice(0,6);
				townid = result.data.regionId;								
				
			}
			else if(result.status == 205)
			{
			}
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);
			
		}	
		private function initView(data:Object):void
		{
			//WaitingRespond.instance.hideWaitingView();
			var result:Object = JSON.parse(data as String);
			
			uiSkin.provList.array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			var selpro:int = 0;
			if(hasInit == false)
			{
				//var auditproid:String = UtilTool.getLocalVar("proid","0");
				
				if(proid  != "")
				{
					for(var i:int=0;i < uiSkin.provList.array.length;i++)
					{
						if(uiSkin.provList.array[i].id == proid)
						{
							selpro = i;
							break;
						}
					}
				}
			}
			
			selectProvince(selpro);
		}
		
		
		
		private function onSaveCompanyInfo():void
		{
			// TODO Auto Generated method stub
			
			if(uiSkin.input_companyName.text == "")
			{
				ViewManager.showAlert("请填写企业名称");

			}
			if(UtilTool.hasForbidenChars(uiSkin.input_companyName.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;
				
			}
			
			if(uiSkin.input_shortName.text == "")
			{
				ViewManager.showAlert("请填写企业简称");
				return;
			}
			
			if(UtilTool.hasForbidenChars(uiSkin.input_shortName.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;

			}
			if(UtilTool.hasForbidenChars(uiSkin.input_address.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;

			}
			if(uiSkin.reditCode.text == "")
			{
				ViewManager.showAlert("请填写统一社会征信代码");
				return;
			}
			
			var params:Object = {};
			params.name = uiSkin.input_companyName.text;
			params.shortName = uiSkin.input_shortName.text;
			params.regionId = companyareaId;
			params.addr = uiSkin.input_address.text;
			params.idCode = uiSkin.reditCode.text;


			//Browser.window.createGroup({urlpath:HttpRequestUtil.httpUrl + HttpRequestUtil.createGroup, cname:uiSkin.input_companyname.text,cshortname:uiSkin.shortname.text,czoneid:companyareaId,caddr:uiSkin.detail_addr.text,reditcode:uiSkin.reditcode.text,file:curYyzzFile});

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateCompanyInfo,this,onSaveCompnayBack,JSON.stringify(params),"post");
		}
		
		private function onSaveCompnayBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.UPDATE_COMPANY_INFO);
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
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);

		}
		private function onShowProvince(e:Event):void
		{
			uiSkin.provbox.visible = true;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
			e.stopPropagation();
		}
		private function onShowCity(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = true;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);

			e.stopPropagation();
		}
		private function onShowArea(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = true;
			uiSkin.townbox.visible = false;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);

			e.stopPropagation();
		}
		
		private function onShowTown(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = true;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);

			e.stopPropagation();
		}
		
		private function updateCityList(cell:CityAreaItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function selectProvince(index:int):void
		{
			if(uiSkin.provList.array[index] == null)
				return;
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			province = uiSkin.provList.array[index];
			uiSkin.provbox.visible = false;
			uiSkin.province.text = province.areaName;

			proid = province.id;
			
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+proid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.citytxt == null || uiSkin.destroyed)
					return;
				var result:Object = JSON.parse(data as String);
				
				uiSkin.cityList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
					
					if(cityid  != "")
					{
						for(var i:int=0;i < uiSkin.cityList.array.length;i++)
						{
							if(uiSkin.cityList.array[i].id == cityid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.citytxt.text = uiSkin.cityList.array[selpro].areaName;
				//uiSkin.cityList.selectedIndex = selpro;
				selectCity(selpro);
				
			},null,null);
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);


		}
		
		private function selectCity(index:int):void
		{
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			uiSkin.citybox.visible = false;
			
			cityid = uiSkin.cityList.array[index].id;

			var tempid = cityid;
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+tempid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.areatxt == null || uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.areaList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
									
					if(areaid != "")
					{
						for(var i:int=0;i < uiSkin.areaList.array.length;i++)
						{
							if(uiSkin.areaList.array[i].id == areaid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.areatxt.text = uiSkin.areaList.array[selpro].areaName;
				//uiSkin.areaList.selectedIndex = selpro;
				selectArea(selpro);

				
			},null,null);
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);


			
		}
		
		private function selectArea(index:int):void
		{
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);

			if( index == -1 )
				return;
			areaid = uiSkin.areaList.array[index].id;

			var tempid = areaid;
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer +"parentId="+tempid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.towntxt == null || uiSkin.destroyed)
					return;
				
								
				var result:Object = JSON.parse(data as String);
				
				uiSkin.btnSelTown.visible = result.data.length > 0;
				if(result.data.length == 0)
				{
					companyareaId = areaid;
					return;
				}
				
				uiSkin.townList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.townList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
					
					if(townid != "")
					{
						for(var i:int=0;i < uiSkin.townList.array.length;i++)
						{
							if(uiSkin.townList.array[i].id == townid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.towntxt.text = uiSkin.townList.array[selpro].areaName;
				//uiSkin.townList.selectedIndex =selpro;
				companyareaId = uiSkin.townList.array[selpro].id;

				
			},null,null);
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;

			uiSkin.areabox.visible = false;

			
		}
		
		private function selectTown(index:int):void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			hasInit = true;

			if( index == -1 )
				return;
			uiSkin.townbox.visible = false;
			uiSkin.towntxt.text = uiSkin.townList.array[index].areaName;
			companyareaId = uiSkin.townList.array[index].id;
			townid = companyareaId;
		}
		
	
	}
}
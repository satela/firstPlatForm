package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.BusinessManVo;
	import model.users.CustomVo;
	
	import script.ViewManager;
	import script.usercenter.item.CustomCell;
	
	import ui.order.AddCommentPanelUI;
	import ui.usercenter.AddressMgrPanelUI;
	import ui.usercenter.CustomManagerPanelUI;
	
	public class CustomManagerController extends Script
	{
		private var uiSkin:CustomManagerPanelUI;
		
		private var curPage:int = 1;
		private var totalPage:int = 1;

		private var pageSize:int = 20;
		
		private var addOrEdit:int = 0;
		private var curCustomer:CustomVo;
		private var businessManlist:Array;

		//private var 
		public function CustomManagerController()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as CustomManagerPanelUI;
			
			uiSkin.customeList.itemRender = CustomCell;
			
			//uiSkin.addlist.vScrollBarSkin = "";
			uiSkin.customeList.repeatX = 1;
			uiSkin.customeList.spaceY = 0;
			
			uiSkin.customeList.renderHandler = new Handler(this, updateCustomeList);
			uiSkin.customeList.selectEnable = true;
			uiSkin.customeList.selectHandler = new Handler(this,onSelectCustom);
			uiSkin.customeList.array = [];
			
			var addrMgr:AddressMgrPanelUI = new AddressMgrPanelUI();
			uiSkin.addressPanel.addChild(addrMgr);
			addrMgr.addComponent(CustomerAddressMgr);
			//addrMgr.x = 600;
			
			uiSkin.customInfoBox.visible = false;
			uiSkin.addCustome.on(Event.CLICK,this,onShowCustomInfoBox);
			
			uiSkin.customName.maxChars = 10;
			
			uiSkin.customPhone.restrict = "0-9";
			uiSkin.customPhone.maxChars = 11;
			
			uiSkin.closeAddBtn.on(Event.CLICK,this,onHideCustomInfoBox);
			
			uiSkin.prevPage.on(Event.CLICK,this,onLastPage);
			uiSkin.nextPage.on(Event.CLICK,this,onNextPage);
			uiSkin.searchBtn.on(Event.CLICK,this,function(){
				
				curPage = 1;
				getCustomerList();
				
			});
			uiSkin.payType.selectedIndex = 0;
			
			uiSkin.confirmAddCustom.on(Event.CLICK,this,onAddCustomer);
			EventCenter.instance.on(EventCenter.UPDATE_CUSTOMER_LIST,this,updateCustomlist);
			EventCenter.instance.on(EventCenter.EDIT_CUSTOMER_INFO,this,editCustomer);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listBusinessMan,this,getBusinessManBack,null,null);

			getCustomerList();

		}
		
		private function getBusinessManBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			
			var mans:Array = result.data as Array;
			var businessMan:Array = [];
			var businessManName:String="";
			for(var i:int=0;i < mans.length;i++)
			{
				businessMan.push(new BusinessManVo(mans[i]));
				
				businessManName += businessMan[i].name+"_" + businessMan[i].mobileNumber;
				if(i < mans.length - 1)
					businessManName +=",";
			}
			uiSkin.businessMan.labels = businessManName;
			
			businessManlist = businessMan;
		
			
		}
		
		private function getCustomerList():void
		{
			var params:String = "pageNo=" + curPage + "&pageSize=" + pageSize + "&customerName=" + uiSkin.searchInput.text;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listCustomer + params,this,listCustomerBack,null,null);

		}
		
		private function updateCustomlist():void
		{
			uiSkin.customeList.selectedIndex = -1;
			getCustomerList();
			EventCenter.instance.event(EventCenter.SELECT_CUSTOMER,null);

		}
		private function listCustomerBack(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var arr:Array = [];
				for(var i:int=0;i < result.data.customers.length;i++)
				{
					arr.push(new CustomVo(result.data.customers[i]));
				}
				totalPage = Math.ceil(result.data.totalCount/pageSize);
				if(totalPage < 1)
					totalPage = 1;
				
				uiSkin.customeList.array = arr;
				
				uiSkin.pageText.text = curPage + "/" + totalPage;
			}
		}
		
		private function onLastPage():void
		{
			if(curPage > 1 )
			{
				curPage--;
				getCustomerList();
			}
		}
		private function onNextPage():void
		{
			if(curPage < totalPage )
			{
				curPage++;
				getCustomerList();
			}
		}
		
		private function onAddCustomer():void
		{
			if(uiSkin.customName.text == "")
			{
				ViewManager.showAlert("请输入客户名称");
				return;
			}
			if(uiSkin.customPhone.text.length < 11)
			{
				ViewManager.showAlert("请输入正确的联系电话");
				return;
			}
			
			var requestStr:Object = {};
			requestStr.mobileNumber = uiSkin.customPhone.text;
			requestStr.customerName =  uiSkin.customName.text;
			if(uiSkin.businessMan.selectedIndex >= 0)
			{
				requestStr.salerId = businessManlist[uiSkin.businessMan.selectedIndex].id.toString();
			}
			else
				requestStr.salerId = "0";
			requestStr.defaultPayment = uiSkin.payType.selectedIndex + 1;
			if(addOrEdit == 1 && curCustomer != null)
				requestStr.id = curCustomer.id;
			
			if(addOrEdit == 0)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addCustomer,this,addCustomerback,JSON.stringify(requestStr),"post");
			else
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateCustomer,this,updateCustomer,JSON.stringify(requestStr),"post");

			
		}
		
		private function addCustomerback(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				getCustomerList();
			}
			uiSkin.customInfoBox.visible = false;
		}
		
		private function updateCustomer(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				getCustomerList();
			}
			uiSkin.customInfoBox.visible = false;

		}
		private function editCustomer(cusdata:CustomVo):void
		{
			addOrEdit = 1;
			uiSkin.customInfoBox.visible = true;;
			curCustomer = cusdata;
			uiSkin.customPhone.text = curCustomer.mobileNumber;
			uiSkin.customPhone.editable = false;
			uiSkin.customName.text = curCustomer.customerName;
			uiSkin.payType.selectedIndex = curCustomer.defaultPayment - 1;
			
			for(var i:int=0;i < businessManlist.length;i++)
			{
				if(businessManlist[i].id == curCustomer.salerId)
				{
					uiSkin.businessMan.selectedIndex = i;
					break;
				}
			}
			
		}
		private function onShowCustomInfoBox():void
		{
			uiSkin.customInfoBox.visible = true;;
			uiSkin.customPhone.text = "";
			 uiSkin.customName.text = "";
			 uiSkin.customPhone.editable = true;

			 addOrEdit = 0;
		}
		
		private function onHideCustomInfoBox():void
		{
			uiSkin.customInfoBox.visible = false;;
			
		}
		
		private function updateCustomeList(cell:CustomCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onSelectCustom(index:int):void
		{
			if(index == -1)
				return;
			
			var sel:CustomVo = uiSkin.customeList.array[index];
			
			Laya.timer.once(100,this,function(){
				
				for(var i:int=0;i < uiSkin.customeList.cells.length;i++)
				{
					(uiSkin.customeList.cells[i] as CustomCell).selected(sel.id);
				}
				EventCenter.instance.event(EventCenter.SELECT_CUSTOMER,sel);

			});
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_CUSTOMER_LIST,this,updateCustomlist);
			EventCenter.instance.off(EventCenter.EDIT_CUSTOMER_INFO,this,editCustomer);

		}
		
	}
}
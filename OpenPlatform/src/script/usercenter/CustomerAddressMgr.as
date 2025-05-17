package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.AddressGroupVo;
	import model.users.AddressVo;
	import model.users.CustomVo;
	
	import script.ViewManager;
	import script.usercenter.item.AddressGroupCell;
	import script.usercenter.item.CustomerAddressCell;
	
	import ui.usercenter.AddressMgrPanelUI;
	
	public class CustomerAddressMgr extends Script
	{
		private var customerVo:CustomVo;
		//private var param:Object;
		
		private var addressPage:int = 1;
		private var addressTotalPage:int = 1;
		private var addressPageSize = 20;
		
		private var tabBtns:Array = [];
		private var curTabIndex:int = -1;
		
		private var grpCurPage:int = 1;
		private var grpTotalPage = 1;
		private var pageSize:int = 50;
		
		private var hasinit = false;

		private var uiSkin:AddressMgrPanelUI;
		public function CustomerAddressMgr()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as AddressMgrPanelUI;
			uiSkin.addlist.itemRender = CustomerAddressCell;
			
			//uiSkin.customerBox.visible = false;

			//uiSkin.groupTab.visible = false;
			tabBtns.push(uiSkin.addressTab);
			tabBtns.push(uiSkin.groupTab);
			
			uiSkin.addressTab.on(Event.CLICK,this,clickTabBtn,[0]);
			uiSkin.groupTab.on(Event.CLICK,this,clickTabBtn,[1]);
			
			//uiSkin.addlist.vScrollBarSkin = "";
			uiSkin.addlist.repeatX = 1;
			uiSkin.addlist.spaceY = 0;
			
			uiSkin.addlist.renderHandler = new Handler(this, updateAddressList);
			uiSkin.addlist.selectEnable = false;
			
			var temparr:Array = [];
			//			for(var i:int=0;i < 6;i++)
			//			{
			//				var addvo:AddressVo = new AddressVo();
			//				temparr.push(addvo);
			//			}
			uiSkin.addlist.array = temparr;
			
			uiSkin.btnaddAddress.on(Event.CLICK,this,onClickAdd);
			
			uiSkin.prevBtn.on(Event.CLICK,this,onAddressPrevPage);
			uiSkin.nextBtn.on(Event.CLICK,this,onAddressNextPage);
			
			//if(Userdata.instance.addressList.length <= 0)
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressListUrl,this,getMyAddressBack,"page=1",null,null);
			//else
			//	uiSkin.addlist.array = Userdata.instance.addressList;
			
			uiSkin.numAddress.text = "已经保存0条地址";
			
			uiSkin.addlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.addlist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			
			
			//地址分组
			uiSkin.groupList.itemRender = AddressGroupCell;
			uiSkin.groupList.repeatX = 6;
			uiSkin.groupList.spaceY = 20;
			uiSkin.groupList.spaceX = 5;
			
			uiSkin.groupList.renderHandler = new Handler(this, updateGroupList);
			uiSkin.groupList.selectEnable = false;
			var arr:Array = [];

			
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
			
			clickTabBtn(0);

			EventCenter.instance.on(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);

			EventCenter.instance.on(EventCenter.SELECT_CUSTOMER,this,selectCustomer);
			EventCenter.instance.on(EventCenter.UPDATE_ADDRESS_GROUP_LIST,this,refreshGroupList);

		}
		
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
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
			
			
			
			if(index == 1 && hasinit == false)
			{
				hasinit = true;
				refreshGroupList();
			}
			
		}
		private function selectCustomer(customer:CustomVo):void
		{
			if(customer == null)
			{
				this.customerVo = null;
				uiSkin.customerBox.visible = false;
				uiSkin.addlist.array = [];
				uiSkin.numAddress.text = "已经保存0条地址";
				return;
			}
			uiSkin.customerBox.visible = true;
			this.customerVo = customer;
			uiSkin.customerBox.visible = true;
			uiSkin.customeName.text = customerVo.customerName;
			updateList();
			refreshGroupList();
		}
		
		private function onAddressPrevPage():void
		{
			if(addressPage <= 1)
				return;
			addressPage--;
			updateList();
		}
		
		private function onAddressNextPage():void
		{
			if(addressPage >= addressTotalPage)
				return;
			addressPage++;
			updateList();
		}
		
		private function updateList():void
		{
			//uiSkin.addlist.array = Userdata.instance.addressList;
			//uiSkin.numAddress.text = "已经保存" + Userdata.instance.addressList.length + "条地址";
			var paramdata:String = "customerId=" + customerVo.id + "&pageNo=" + addressPage + "&pageSize=" + addressPageSize
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listCustomerAddress + paramdata,this,getMyAddressBack,null,null,null);
			
		}
		private function getMyAddressBack(data:Object):void
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
				}			
				
				addressTotalPage = Math.ceil(result.data.totalCount/addressPageSize);
				if(addressTotalPage < 1)
					addressTotalPage = 1;
				uiSkin.addressPageTxt.text = addressPage + "/" + addressTotalPage;
				
				//var tempAdd:Array = Userdata.instance.addressList;
				addressList.sort(compareAddress);
				uiSkin.addlist.array = addressList;
				uiSkin.numAddress.text = "已经保存" + result.data.totalCount + "条地址";

				
			}
		}
		
		private function compareAddress(a:AddressVo,b:AddressVo):int
		{
			//			if(a.status != b.status)
			//			{
			//				if(a.status == 1)
			//					return -1;
			//				else if(b.status == 1)
			//					return 1;
			//				else if(a.status < b.status)
			//					return -1;
			//				else
			//					return 1;
			//					
			//			}
			//			else
			return parseInt(a.id) < parseInt(b.id) ? -1:1;
		}
		private function onClickAdd():void
		{
			// TODO Auto Generated method stub
			//if(Userdata.instance.canAddNewAddress())
			//{
			if(customerVo == null)
			{
				ViewManager.showAlert("请先选择需要添加地址的客户");
				return;
			}
				ViewManager.instance.openView(ViewManager.VIEW_ADD_NEW_ADDRESS,false,{url:HttpRequestUtil.addCustomerAddress,customer:customerVo});
			//}
			//else
			//{
			//	ViewManager.showAlert("有地址在等待审核状态，禁止添加新地址，你可删除待审核地址或等待审核通过后重新添加");
			//}
		}
		
		private function updateAddressList(cell:CustomerAddressCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		//地址分组
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
			var postdata:Object = {};
			if(uiSkin.newGroupName.text.length <= 0)
			{
				ViewManager.showAlert("请输入分组名");
				return;
			}
			postdata.name = uiSkin.newGroupName.text;
			
			postdata.customerId = customerVo.id;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressGroupManageUrl,this,createGroupBack,JSON.stringify(postdata),"post");
		}
		private function createGroupBack(data:String):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
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
			if(customerVo == null)
			{
				ViewManager.showAlert("请先选择客户");
				return;
			}
			
			var paramdata:String = "customerId=" + customerVo.id + "&name=" + uiSkin.searchGroupInput.text + "&pageNo=" + grpCurPage + "&pageSize=" + pageSize;
			
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
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);
			EventCenter.instance.off(EventCenter.SELECT_CUSTOMER,this,selectCustomer);
			EventCenter.instance.off(EventCenter.UPDATE_ADDRESS_GROUP_LIST,this,refreshGroupList);

			
		}
	}
}
package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.AddressGroupVo;
	import model.users.VipAddressVo;
	
	import script.ViewManager;
	import script.usercenter.item.GroupAddressCell;
	import script.usercenter.item.VipAddressCell;
	
	import ui.usercenter.AddrGroupDetailPanelUI;
	import ui.usercenter.GroupAddressItemUI;
	
	public class AddrGroupMgrController extends Script
	{
		private var uiSkin:AddrGroupDetailPanelUI;

		private var param:Object;
		private var grpVo:AddressGroupVo;

		private var curPage:int = 1;
		private var totalPage:int = 1;
		private var pageSize:int = 30;
		
		private var province:Object;
		
		private var zoneid:String;
		private var areaid:String;
		private var hasSelectAddressId:Array;

		public function AddrGroupMgrController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AddrGroupDetailPanelUI;
			
			grpVo = param as AddressGroupVo;
			updateName();
			//地址列表
			uiSkin.addressList.itemRender = GroupAddressCell;
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
			
			uiSkin.selectall.on(Event.CHANGE,this,changeSelectedAll);
			uiSkin.delBatchBtn.on(Event.CLICK,this,batchDeleteAddr);
			uiSkin.searchInput.maxChars = 8;
			
			uiSkin.closebtn.on(Event.CLICK,this,closeView);
			uiSkin.addAddrbtn.on(Event.CLICK,this,showAddressList);
			
			uiSkin.prePage.on(Event.CLICK,this,onPrevPage);
			uiSkin.nextPage.on(Event.CLICK,this,onNextPage);
			uiSkin.searchInput.maxChars = 20;
			uiSkin.searchbtn.on(Event.CLICK,this,onSearchAddress);
			
			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			
			EventCenter.instance.on(EventCenter.INSERT_ADDRESS_TO_GROUP,this,refreshList);
			EventCenter.instance.on(EventCenter.DELETE_ADDRESS_FROM_GROUP,this,deleteAddress);
			updateList();
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl,this,getMyAddressBack,"opt=list&page=" + curPage + "&hidden=0&id=" + grpVo.groupId + "&addr="  + "&keyword=" + uiSkin.searchInput.text,"post");

			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listGroupsAddress,this,getMyAddressBack,"id=104,105","post");

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
		
		private function updateName():void
		{
			uiSkin.grpName.text= grpVo.groupName + "(" + grpVo.count + ")";
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
					deleteIds.push(uiSkin.addressList.array[i]);
			}
			if(deleteIds.length <=0 )
			{
				ViewManager.showAlert("未选择要删除的地址");
				return;
			}
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:onConfirmDel,msg:"确定移出这" + deleteIds.length +  "个地址吗？"});

		}
		
		private function onConfirmDel(b:Boolean):void
		{
			if(b)
			{
				var deleteIds:Array = [];
				for(var i:int=0;i < uiSkin.addressList.array.length;i++)
				{
					if(uiSkin.addressList.array[i].selected)
						deleteIds.push(uiSkin.addressList.array[i].id);
				}
				
				var postdata:Object = {};
				postdata.expressGroupId = grpVo.groupId;
				postdata.expressIds = deleteIds;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.removeGroupAddress,this,adddeleteBack,JSON.stringify(postdata),"post");
				
			}
		}
		private function getMyAddressBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var addressList = [];
				for(var i:int=0;i < result.data.expressList.length;i++)
				{
					addressList.push(new VipAddressVo(result.data.expressList[i]));
				}			
				
				//var tempAdd:Array = Userdata.instance.addressList;
				//tempAdd.sort(compareAddress);
				uiSkin.addressList.array = addressList;
				totalPage = Math.ceil(result.data.totalCount/pageSize);
				if(totalPage < 1)
					totalPage = 1;
				uiSkin.pageNum.text = curPage + "/" + totalPage;
				
				
			}
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
		private function onSearchAddress():void
		{
			curPage = 1;
			updateList();
		}
		
		private function deleteAddress(addId:String):void
		{
			var postdata:Object = {};
			postdata.expressGroupId = grpVo.groupId;
			postdata.expressIds = [addId];
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.removeGroupAddress,this,adddeleteBack,JSON.stringify(postdata),"post");

		}
		private function adddeleteBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				this.grpVo.count = parseInt(result.data.expressCount);
				updateName();
				updateList();
				
			}
		}
		private function refreshList(num:int):void
		{
			this.grpVo.count = num;
			updateName();
			updateList();
		}
		private function updateList():void
		{
//			var addr:String = "";
//			if(uiSkin.provList.selectedIndex > 0)
//			{
//				addr += uiSkin.province.text;
//				if(uiSkin.cityList.selectedIndex > 0)
//					addr +=" " + uiSkin.citytxt.text;
//				if(uiSkin.areaList.selectedIndex > 0)
//					addr += " " + uiSkin.areatxt.text;
//			}
			
			var paramdata:String = "expressGroupId=" + grpVo.groupId + "&mobileNumber=" + uiSkin.searchInput.text + "&pageNo=" + curPage + "&pageSize=" + pageSize;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.vipAddressManageUrl + paramdata,this,getMyAddressBack,null,null);
			
		}
		
		private function showAddressList():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADDRESS_LIST_PANEL,false,grpVo);
		}
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_ADDRESS_GROUP_MGR_PANEL);
			EventCenter.instance.event(EventCenter.CLOSE_PANEL_VIEW,ViewManager.VIEW_ADDRESS_GROUP_MGR_PANEL);

		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.INSERT_ADDRESS_TO_GROUP,this,refreshList);
			EventCenter.instance.off(EventCenter.DELETE_ADDRESS_FROM_GROUP,this,deleteAddress);
		}
	}
}
package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.AddressVo;
	
	import script.ViewManager;
	
	import ui.usercenter.AddressMgrPanelUI;
	
	public class AddressMgrControl extends Script
	{
		private var uiSkin:AddressMgrPanelUI;
		public function AddressMgrControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AddressMgrPanelUI;
			uiSkin.addlist.itemRender = CompanyAddressItem;
			
			uiSkin.addressTab.visible = false;
			uiSkin.groupTab.visible = false;
			uiSkin.groupBox.visible = false;
			uiSkin.customerBox.visible = false;
			
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
			uiSkin.defaultDelivery.visible = false;
			
			uiSkin.btnaddAddress.on(Event.CLICK,this,onClickAdd);
			
			//if(Userdata.instance.addressList.length <= 0)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressListUrl,this,getMyAddressBack,"page=1",null,null);
			//else
			//	uiSkin.addlist.array = Userdata.instance.addressList;
			
			uiSkin.numAddress.text = "已经保存" + Userdata.instance.addressList.length + "条地址";
			
			uiSkin.addlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.addlist.on(Event.MOUSE_OUT,this,resumeParentScroll);


			EventCenter.instance.on(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);

		}
		
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
		}
		
		private function updateList():void
		{
			//uiSkin.addlist.array = Userdata.instance.addressList;
			//uiSkin.numAddress.text = "已经保存" + Userdata.instance.addressList.length + "条地址";
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressListUrl,this,getMyAddressBack,"page=1",null,null);

		}
		private function getMyAddressBack(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.initMyAddress(result.data.expressList as Array);
				Userdata.instance.defaultAddId = result.data.defaultId;

				var tempAdd:Array = Userdata.instance.addressList;
				tempAdd.sort(compareAddress);
				uiSkin.addlist.array = Userdata.instance.addressList;
				
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
			if(Userdata.instance.canAddNewAddress())
			{
				ViewManager.instance.openView(ViewManager.VIEW_ADD_NEW_ADDRESS,false,{url:HttpRequestUtil.addressAddUrl});
			}
			else
			{
				ViewManager.showAlert("有地址在等待审核状态，禁止添加新地址，你可删除待审核地址或等待审核通过后重新添加");
			}
		}
		
		private function updateAddressList(cell:CompanyAddressItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_MYADDRESS_LIST,this,updateList);

		}
	}
}
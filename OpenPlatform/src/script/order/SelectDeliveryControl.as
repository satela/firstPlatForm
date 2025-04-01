package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.orderModel.DeliveryTypeVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.SelectDeliveryPanelUI;
	
	public class SelectDeliveryControl extends Script
	{
		private var uiSkin:SelectDeliveryPanelUI;
		
		public var param:Object;
		
		public var tempSelect:DeliveryTypeVo;
		public function SelectDeliveryControl()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as SelectDeliveryPanelUI;
			
			uiSkin.list_delivery.itemRender = DeliveryTypeItem;
			uiSkin.list_delivery.vScrollBarSkin = "";
			uiSkin.list_delivery.selectEnable = true;
			uiSkin.list_delivery.spaceY = 8;
			uiSkin.list_delivery.renderHandler = new Handler(this, updateAddressItem);
			
			uiSkin.list_delivery.selectHandler = new Handler(this,onSlecteDelivery);
			
			//			var temparr:Array = [];
			//			var addrs:Array = ["130921100","210905002","371323"];
			//			for(var i:int=0;i < 3;i++)
			//			{
			//				var fvo:FactoryInfoVo = new FactoryInfoVo({addr:addrs[i],name:"测试地址1"});
			//				temparr.push(fvo);
			//			}
			uiSkin.list_delivery.array = [];
			
			uiSkin.cancelbtn.on(Event.CLICK,this,onCloseView);
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmSelectAddress);
			
			if(param != null)
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + param + "&addr_id=" + PaintOrderModel.instance.selectAddress.zoneid,this,onGetDeliveryBack,null,null);

		}
		
		private function onGetDeliveryBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.deliveryList = [];
				for(var i:int=0;i < result.length;i++)
				{
					var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(result[i]);
					if(tempdevo.delivery_name == OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
						tempSelect = tempdevo;
					PaintOrderModel.instance.deliveryList.push(tempdevo);
				}
				if(tempSelect == null && PaintOrderModel.instance.deliveryList.length > 0)
					tempSelect = PaintOrderModel.instance.deliveryList[0];
					
				//uiSkin.list_delivery.array = PaintOrderModel.instance.deliveryList;
				Laya.timer.once(10,null,function()
				{
				var cells:Vector.<Box> = uiSkin.list_delivery.cells;
				for(var i:int=0;i < cells.length;i++)
				{
					(cells[i] as DeliveryTypeItem).ShowSelected = (cells[i] as DeliveryTypeItem).deliveryVo == tempSelect;
				}
				});
			}
		}
		
		private function onSlecteDelivery(index:int):void
		{
			// TODO Auto Generated method stub
			for each(var item:DeliveryTypeItem in uiSkin.list_delivery.cells)
			{
				item.ShowSelected = item.deliveryVo == uiSkin.list_delivery.array[index];
			}
			tempSelect = uiSkin.list_delivery.array[index];
		}
		
		private function updateAddressItem(cell:SelAddressItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onConfirmSelectAddress(index:int):void
		{
			// TODO Auto Generated method stub
			if(tempSelect != null)
			{
				PaintOrderModel.instance.selectDelivery = tempSelect;
				EventCenter.instance.event(EventCenter.SELECT_DELIVERY_TYPE);
			}
			onCloseView();
		}
		
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_SELECT_DELIVERY_TYPE);
		}
	}
}
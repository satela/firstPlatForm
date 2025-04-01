package script.order
{
	
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	import model.orderModel.PaintOrderModel;
	import model.users.FactoryInfoVo;
	
	import script.ViewManager;
	
	import ui.order.SelectFactoryPanelUI;
	
	public class SelectFactoryControl extends Script
	{
		private var uiSkin:SelectFactoryPanelUI;
		
		private var tempaddress:FactoryInfoVo;

		public function SelectFactoryControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as SelectFactoryPanelUI;
			
			uiSkin.list_address.itemRender = SelFactoryItem;
			uiSkin.list_address.vScrollBarSkin = "";
			uiSkin.list_address.selectEnable = false;
			uiSkin.list_address.spaceY = 8;
			uiSkin.list_address.renderHandler = new Handler(this, updateAddressItem);
			
			//uiSkin.list_address.selectHandler = new Handler(this,onSlecteAddress);
			
			uiSkin.list_address.array = PaintOrderModel.instance.outPutAddr;
		//	tempaddress = PaintOrderModel.instance.selectFactoryAddress;
//			Laya.timer.once(10,null,function()
//			{
//				var cells:Vector.<Box> = uiSkin.list_address.cells;
//				for(var i:int=0;i < cells.length;i++)
//				{
//					(cells[i] as SelFactoryItem).ShowSelected = (cells[i] as SelFactoryItem).factoryvo == PaintOrderModel.instance.selectFactoryAddress;
//					
//					//uiSkin.list_address.selectedIndex = i;
//				}
//			});
			
			uiSkin.cancelbtn.on(Event.CLICK,this,onCloseView);
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmSelectAddress);
		}
		
		private function onSlecteAddress(index:int):void
		{
			// TODO Auto Generated method stub
			if(uiSkin.list_address.array[index] == tempaddress)
				return;
			for each(var item:SelAddressItem in uiSkin.list_address.cells)
			{
				item.ShowSelected = item.address == uiSkin.list_address.array[index];
			}
			tempaddress = uiSkin.list_address.array[index];
		}
		
		private function updateAddressItem(cell:SelAddressItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onConfirmSelectAddress(index:int):void
		{
			// TODO Auto Generated method stub
//			if(tempaddress != null)
//			{
//				PaintOrderModel.instance.selectFactoryAddress = tempaddress;
//				EventCenter.instance.event(EventCenter.SELECT_OUT_ADDRESS);
//			}
			onCloseView();
		}
		
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_SELECT_FACTORY);
		}
	}
}
package script.prodCustomer
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.PaintOrderModel;
	import model.prodCustomerModel.ProdCondtionVo;
	import model.prodCustomerModel.ProdParamVo;
	
	import script.ViewManager;
	
	import ui.prodCustom.ProdChoosePanelUI;
	import script.prodCustomer.item.ProdCell;
	import script.prodCustomer.item.ProdParamCell;
	
	public class ProdChooseController extends Script
	{
		private var uiSkin:ProdChoosePanelUI;
		public function ProdChooseController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ProdChoosePanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onCloseView);
			
			uiSkin.prodList.itemRender = ProdCell;
			
			uiSkin.prodList.repeatX = 8;
			uiSkin.prodList.spaceY = 20;
			uiSkin.prodList.spaceX = 40;
			uiSkin.prodList.renderHandler = new Handler(this, updateProdItem);
			uiSkin.prodList.vScrollBarSkin = "";

			uiSkin.conditionList.itemRender = ProdParamCell;
			
			uiSkin.conditionList.repeatX = 1;
			uiSkin.conditionList.spaceY = 10;
			uiSkin.conditionList.renderHandler = new Handler(this, updateParamItem);
			
			//uiSkin.conditionList.vScrollBarSkin = "";

			var arr:Array = [];
			for(var i:int=0;i<50;i++)
			{
				var catdata:Object = {};
				catdata.cateName = "T恤" + i;
				arr.push(catdata);
				
			}
			uiSkin.prodList.array = arr;	
			
			var conarr:Array = [];
			var paramVo:ProdParamVo = new ProdParamVo();
			paramVo.paramName = "颜色";
			paramVo.paramList = [];
			var prodCon:ProdCondtionVo = new ProdCondtionVo();
			prodCon.lblName = "红色";
			prodCon.value = "#FF0000";
			
			paramVo.paramList.push(prodCon);
			
			var prodCon:ProdCondtionVo = new ProdCondtionVo();
			prodCon.lblName = "黑色";
			prodCon.value = "#FF0000";
			
			paramVo.paramList.push(prodCon);
			
			conarr.push(paramVo);
			
			
			var paramVo:ProdParamVo = new ProdParamVo();
			paramVo.paramName = "尺码";
			paramVo.paramList = [];
			var prodCon:ProdCondtionVo = new ProdCondtionVo();
			prodCon.lblName = "S";
			prodCon.value = "s";
			
			paramVo.paramList.push(prodCon);
			
			var prodCon:ProdCondtionVo = new ProdCondtionVo();
			prodCon.lblName = "M";
			prodCon.value = "m";
			
			paramVo.paramList.push(prodCon);
			
			conarr.push(paramVo);
			
			uiSkin.conditionList.array= conarr;
			
			
			
			uiSkin.myaddresstxt.on(Event.CLICK,this,onShowSelectAddress);
			if(Userdata.instance.getDefaultAddress() != null)
			{
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + Userdata.instance.getDefaultAddress().zoneid + "&manufacturer_type=喷印输出中心",this,onGetOutPutAddress,null,null);
				uiSkin.myaddresstxt.text = Userdata.instance.getDefaultAddress().addressDetail;
				PaintOrderModel.instance.selectAddress = Userdata.instance.getDefaultAddress();
			}
			EventCenter.instance.on(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
		}
		
		private function onShowSelectAddress():void
		{
			// TODO Auto Generated method stub
			
			
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_ADDRESS);
		}
		
		private function onSelectedSelfAddress():void
		{
			if(PaintOrderModel.instance.selectAddress)
			{
				uiSkin.myaddresstxt.text = PaintOrderModel.instance.selectAddress.addressDetail;
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + PaintOrderModel.instance.selectAddress.zoneid + "&manufacturer_type=喷印输出中心",this,onGetOutPutAddress,null,null);
			}
		}
		
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_PRODUCT_CHOOSE_PANEL);
			
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
			
		}
		
		private function updateProdItem(cell:ProdCell):void
		{
			cell.setData(cell.dataSource);
		}
		private function updateParamItem(cell:ProdParamCell):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onResizeBrower():void
		{
			
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			uiSkin.prodList.refresh();
		}
		override public function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower)
			
		}
		
	}
}
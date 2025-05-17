package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	import script.usercenter.item.OrderPriceSettingItem;
	
	import ui.usercenter.SellPriceSettingPanelUI;
	
	public class OrderPriceSettingController extends Script
	{
		private var uiSkin:SellPriceSettingPanelUI;
		
		public var param:Object;
		private var orderdata;
		public function OrderPriceSettingController()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as SellPriceSettingPanelUI;
			
			uiSkin.orderoanel.vScrollBarSkin = "";
			
			//uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			var status:int = parseInt(param.status);
			
			
			
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			uiSkin.orderSn.text = param.id;
			
			 orderdata = JSON.parse(param.detail);
			var allproduct:Array = orderdata.orderItemList as Array;
			
			this.uiSkin.deliveryCost.text = orderdata.shippingFee;

			if(orderdata.moneyPaid != null)
				this.uiSkin.moneyPaidlbl.text = Number(orderdata.moneyPaid).toFixed(2);
			else
				this.uiSkin.moneyPaidlbl.text = Number(orderdata.money_paidStr).toFixed(2);
			
			if(Userdata.instance.isHidePrice())
			{
				this.uiSkin.moneyPaidlbl.text = "***";
			}
			
			allproduct.sort(sortProduct);
			
			
			uiSkin.orderbox.itemRender = OrderPriceSettingItem;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.orderbox.repeatX = 1;
			uiSkin.orderbox.spaceY = 2;
			
			uiSkin.orderbox.renderHandler = new Handler(this, updateOrderList);
			uiSkin.orderbox.selectEnable = false;
			
			
			var productArr:Array = [];
			for(var i:int=0;i < allproduct.length;i++)
			{
				allproduct[i].orderId = param.id;
			
				
			}
			
			
			uiSkin.orderbox.array = allproduct;
			
			
			uiSkin.orderbox.size(uiSkin.orderbox.width,uiSkin.orderbox.getBounds().height);
			uiSkin.closebtn.on(Event.CLICK,this,onCloseView);
			uiSkin.layoutCost.on(Event.INPUT,this,updateSellPrice);
			uiSkin.designCost.on(Event.INPUT,this,updateSellPrice);
			uiSkin.deliveryCost.on(Event.INPUT,this,updateSellPrice);
			uiSkin.otherCost.on(Event.INPUT,this,updateSellPrice);
			uiSkin.okbtn.on(Event.CLICK,this,onSettingConfirm);
			uiSkin.shareBtn.on(Event.CLICK,this,onShare);
			
			uiSkin.layoutCost.text = (orderdata.installationFee != null && orderdata.installationFee != "")?orderdata.installationFee:"0";
			uiSkin.designCost.text = (orderdata.designFee != null && orderdata.designFee != "")?orderdata.designFee:"0";
			uiSkin.deliveryCost.text = (orderdata.deliveryFee != null && orderdata.designFee != "")?orderdata.deliveryFee:"0";
			uiSkin.otherCost.text = (orderdata.otherFee != null && orderdata.otherFee != "")?orderdata.otherFee:"0";
			uiSkin.sellPrice.text = (orderdata.totalSalesPrice != null && orderdata.totalSalesPrice != "")?orderdata.totalSalesPrice:"0";

			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.UPDATE_ORDER_PRICE,this,updateSellPrice);
			updateSellPrice();
		}
		
		private function onShare():void
		{
			Browser.window.open("about:self","_blank").location.href = Browser.window.location + "?" + "orderID="+ param.id;

		}
		public function updateOrderList(cell:OrderPriceSettingItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
		}
		private function sortProduct(a:Object,b:Object):int
		{
			if(parseInt(a.itemSeq) > parseInt(b.itemSeq))
				return 1;
			else
				return -1;
		}
		private function refrshVbox():void
		{
			uiSkin.orderbox.refresh();
			
			uiSkin.orderbox.size(uiSkin.orderbox.width,uiSkin.orderbox.getBounds().height);
			//uiSkin.orderbox.height = uiSkin.orderbox.getBounds().height;
		}
		
		private function updateSellPrice():void
		{
			var productPrice:Number = 0;
			var arr:Array = uiSkin.orderbox.array;
			for(var i:int=0;i < arr.length;i++)
			{
				productPrice += (arr[i].totalSalesPrice != null && arr[i].totalSalesPrice != "")?parseFloat(uiSkin.orderbox.array[i].totalSalesPrice):(Number(arr[i].itemPrice) * Number(arr[i].itemNumber));
			}
			
			var layoutPrice:Number = parseFloat(this.uiSkin.layoutCost.text);
			var designPrice:Number = parseFloat(this.uiSkin.designCost.text);
			var deliveryPrice:Number = parseFloat(this.uiSkin.deliveryCost.text);
			var otherPrice:Number = parseFloat(this.uiSkin.otherCost.text);
			
		
			
			this.uiSkin.sellPrice.text = (productPrice + layoutPrice+deliveryPrice+designPrice+otherPrice).toFixed(2);
			
			

		}
		
		private function onSettingConfirm():void
		{
			if(this.uiSkin.layoutCost.text == "" || this.uiSkin.designCost.text == "" || this.uiSkin.deliveryCost.text == "" || this.uiSkin.otherCost.text == "" )
			{
				ViewManager.showAlert("价格不能为空，请输入正确的价格费用。");
				return;
				
			}
			orderdata.totalSalesPrice = this.uiSkin.sellPrice.text;
			orderdata.installationFee = parseFloat(this.uiSkin.layoutCost.text).toFixed(2);
			orderdata.designFee = parseFloat(this.uiSkin.designCost.text).toFixed(2);
			orderdata.deliveryFee = parseFloat(this.uiSkin.deliveryCost.text).toFixed(2);
			orderdata.otherFee = parseFloat(this.uiSkin.otherCost.text).toFixed(2);
			
			var arr:Array = [orderdata];
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateOrderSellPrice,this,onUpdateOrderBack,JSON.stringify(arr),"post");



		}
		
		private function onUpdateOrderBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.instance.closeView(ViewManager.ORDER_PRICE_SETTING_PANEL);
				EventCenter.instance.event(EventCenter.DELETE_ORDER_BACK);
				onCloseView();
			}
		}
		private function onCloseView():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			ViewManager.instance.closeView(ViewManager.ORDER_PRICE_SETTING_PANEL);
			EventCenter.instance.off(EventCenter.UPDATE_ORDER_PRICE,this,updateSellPrice);

		}
	}
}
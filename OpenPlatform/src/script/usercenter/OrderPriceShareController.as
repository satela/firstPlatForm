package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	
	import script.usercenter.item.OrderPriceSettingItem;
	import script.usercenter.item.OrderPriceShareItem;
	import script.usercenter.item.OrderPriceSharePhoneItem;
	
	import ui.usercenter.SellPriceSharePanelUI;
	
	public class OrderPriceShareController extends Script
	{
		private var uiSkin:SellPriceSharePanelUI;
		
		public var param:Object;
		private var orderdata;
		public function OrderPriceShareController()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as SellPriceSharePanelUI;
			
			uiSkin.orderoanel.vScrollBarSkin = "";
			
			//uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			//var status:int = parseInt(param.status);
			
			
			
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			uiSkin.orderSn.text = param.id;
			uiSkin.qrCodeImg.skin = param.qrCode;
			uiSkin.qrCodeImg.on(Event.LOADED,this,onLoadedImg);

			
			if(typeof(Browser.window.orientation) != "undefined")
			{	
				uiSkin.orderbox.itemRender = OrderPriceSharePhoneItem;
			
			}
			else
				uiSkin.orderbox.itemRender = OrderPriceShareItem;

			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.orderbox.repeatX = 1;
			uiSkin.orderbox.spaceY = 2;
			
			uiSkin.orderbox.renderHandler = new Handler(this, updateOrderList);
			uiSkin.orderbox.selectEnable = false;
			
			uiSkin.layoutCost.editable= false;
			uiSkin.designCost.editable = false;
			uiSkin.deliveryCost.editable = false;
			uiSkin.otherCost.editable = false;
			
			uiSkin.orderbox.size(uiSkin.orderbox.width,uiSkin.orderbox.getBounds().height);
//			uiSkin.layoutCost.on(Event.INPUT,this,updateSellPrice);
//			uiSkin.designCost.on(Event.INPUT,this,updateSellPrice);
//			uiSkin.deliveryCost.on(Event.INPUT,this,updateSellPrice);
//			uiSkin.otherCost.on(Event.INPUT,this,updateSellPrice);
			

			uiSkin.orderbox.array = [];

			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			var params:Object = {"token":"0da2c261-c89d-4a25-ae27-560027cb77cc","orderId":param.id};
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderDetailById,this,oGetOrderBack,JSON.stringify(params),"post");
			
		//	updateSellPrice();
		}
		
	
		private function oGetOrderBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
							
					orderdata = JSON.parse(result.data.detail);
					var allproduct:Array = orderdata.orderItemList as Array;
					
					this.uiSkin.deliveryCost.text = orderdata.shippingFee;
					
					if(orderdata.moneyPaid != null)
						this.uiSkin.moneyPaidlbl.text = Number(orderdata.moneyPaid).toFixed(2);
					else
						this.uiSkin.moneyPaidlbl.text = Number(orderdata.money_paidStr).toFixed(2);
					
					allproduct.sort(sortProduct);
					
					uiSkin.customeNameTxt.text = result.data.customerName;
					
					
					
					var productArr:Array = [];
					for(var i:int=0;i < allproduct.length;i++)
					{
						allproduct[i].orderId = param.id;
						
						
					}
		
				
				uiSkin.orderbox.array = allproduct;
				
				uiSkin.layoutCost.text = (orderdata.installationFee != null && orderdata.installationFee != "")?orderdata.installationFee:"0";
				uiSkin.designCost.text = (orderdata.designFee != null && orderdata.designFee != "")?orderdata.designFee:"0";
				uiSkin.deliveryCost.text = (orderdata.deliveryFee != null && orderdata.designFee != "")?orderdata.deliveryFee:"0";
				uiSkin.otherCost.text = (orderdata.otherFee != null && orderdata.otherFee != "")?orderdata.otherFee:"0";
				uiSkin.sellPrice.text = (orderdata.totalSalesPrice != null && orderdata.totalSalesPrice != "")?orderdata.totalSalesPrice:"0";
				
			}
		}
		public function updateOrderList(cell:OrderPriceSettingItem):void
		{
			cell.setData(cell.dataSource);
		}
		private function onLoadedImg(e:Event):void
		{
			var text = Laya.loader.getRes(param.qrCode);
			
			var imgwidth:Number = text.width;
			var imgheight:Number = text.height;
			if(imgwidth > imgheight)
			{
				uiSkin.qrCodeImg.width = 250;
				uiSkin.qrCodeImg.height = 250*imgheight/imgwidth;
				
			}
			else
			{
				uiSkin.qrCodeImg.height = 250;
				uiSkin.qrCodeImg.width = 250*imgwidth/imgheight;
			}
			
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
		
		
				
	}
}
package script.usercenter.item
{
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	
	import ui.usercenter.DeliveryPackageItemUI;
	
	public class DeliveryPackageCell extends DeliveryPackageItemUI
	{
		private var deliveryData:Object;
		public function DeliveryPackageCell()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			deliveryData = data;
			this.btn.label = data.packageName;
			
			var params:Object = {"orderSn":deliveryData.deliverySn};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.queryDeliverySn,this,onGetOrderNumberBack,JSON.stringify(params),"post");
			
			this.btn.on(Event.CLICK,this,showDeliveryMap);
		}
		
		private function onGetOrderNumberBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				if(result.data.data.expressname != null)
				{
					this.btn.label = deliveryData.packageName + "\n" + result.data.data.expressname + "\n订单号:" + result.data.data.kuaidinum;
				}
			}
		}
		private function showDeliveryMap(data:*):void
		{
			var params:Object = {"orderSn":deliveryData.deliverySn};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.queryDeliveryMap,this,onGetOrderDeliveryBack,JSON.stringify(params),"post");

			
		}
		
		private function onGetOrderDeliveryBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var url:String = result.data.data.trailUrl;
				if(url == null || url == "")
				{
					ViewManager.showAlert("已打包，待取件");
					return;
				}
				Browser.window.open(url,null,null,true);
			}
		}
	}
	
}
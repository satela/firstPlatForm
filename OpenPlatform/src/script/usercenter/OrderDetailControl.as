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
	
	import ui.usercenter.OrderDetailPanelUI;
	
	import utils.UtilTool;
	
	public class OrderDetailControl extends Script
	{
		private var uiSkin:OrderDetailPanelUI;
		
		public var param:Object;
		
		public function OrderDetailControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as OrderDetailPanelUI;
			
			uiSkin.orderoanel.vScrollBarSkin = "";

			//uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			var status:int = parseInt(param.status);
			
			if(status == 0)
			{
				uiSkin.orderState.text = "未支付";
				uiSkin.orderState.color = "#FF0000";

			}
			else if(status == 10)
			{
				uiSkin.orderState.text = "支付中";
				uiSkin.orderState.color = "#52B232";

				countDownPayTime();
				Laya.timer.loop(1000,this,countDownPayTime);
			}
			else if(status == 1)
			{
				uiSkin.orderState.text = "已支付排产成功";
				
				uiSkin.orderState.color = "#52B232";

			}
			else if(status == 102 || status == 103)
			{
				uiSkin.orderState.text = "已支付排产中";
				uiSkin.orderState.color = "#0022EE";

			}
				
			else if(status == 4)
			{
				uiSkin.orderState.text = "已撤单";
				uiSkin.orderState.color = "#52B232";

			}
			else if(status == 100)
			{
				uiSkin.orderState.text = "已支付排产失败";				
				uiSkin.orderState.color = "#EE4400";

			}
				
			else
			{
				uiSkin.orderState.text = "订单异常";
				uiSkin.orderState.color = "#52B232";

			}
			
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			
			uiSkin.orderSn.text = param.id;

			var orderdata:Object = JSON.parse(param.detail);
			var allproduct:Array = orderdata.orderItemList as Array;
			
			if(orderdata.moneyPaid != null)
				this.uiSkin.moneyPaidlbl.text = Number(orderdata.moneyPaid).toFixed(2);
			else
				this.uiSkin.moneyPaidlbl.text = Number(orderdata.money_paidStr).toFixed(2);
			
			if(Userdata.instance.isHidePrice())
			{
				this.uiSkin.moneyPaidlbl.text = "***";
			}
			
			allproduct.sort(sortProduct);
			uiSkin.outputtxt.text = orderdata.manufacturerName;

			uiSkin.orderbox.autoSize = true;
			
			if(orderdata.logistic_code != null && orderdata.logistic_code != "")
				uiSkin.comondeltype.text = orderdata.logistic_code.split("#")[1];
			else
				uiSkin.comondeltype.text = "";
			
			
			uiSkin.orderbox.itemRender = QuestOrderItem;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.orderbox.repeatX = 1;
			uiSkin.orderbox.spaceY = 2;
			
			uiSkin.orderbox.renderHandler = new Handler(this, updateOrderList);
			uiSkin.orderbox.selectEnable = false;
			
			
			uiSkin.urgentdelType.text = "";
			var productArr:Array = [];
			for(var i:int=0;i < allproduct.length;i++)
			{
				allproduct[i].orderId = param.id;
				//var product:QuestOrderItem = new QuestOrderItem();
//				uiSkin.orderbox.addChild(product);
//				product.y = product.height*i ;
//				product.setData(allproduct[i],param.or_id);
//				product.adjustHeight = refrshVbox;
//				product.caller = this;
				if(allproduct[i].isUrgent == 1 && allproduct[i].logistics_type != null && allproduct[i].logistics_type != "")
				{
					uiSkin.urgentdelType.text =  allproduct[i].logistics_type.split("#")[1];
				}
								
			}
			
			this.uiSkin.prodNum.text = allproduct.length + "";
			this.uiSkin.orderTime.text = param.createdAt;
			this.uiSkin.address.text = orderdata.packageList[0].addr;
			
			uiSkin.orderbox.array = allproduct;
			
			
			uiSkin.orderbox.size(uiSkin.orderbox.width,uiSkin.orderbox.getBounds().height);
			uiSkin.closebtn.on(Event.CLICK,this,onCloseView);
			uiSkin.deliveryState.on(Event.CLICK,this,onGetDeliveryState);

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		private function countDownPayTime():void
		{
			if(param.payDate != null)
			{
				
				var ordertime:Date = new Date(Date.parse(UtilTool.convertDateStr(param.payDate)));
				
				
				var lefttime:Number = Math.ceil((ordertime.getTime() - (new Date()).getTime())/1000);
				
				if(lefttime > 0)
				{
					var str:String = UtilTool.getCountDownString(lefttime);
					uiSkin.orderState.text = "支付中(" + str + "后可继续支付)";
				}
				else
				{
					
					uiSkin.orderState.text =  "未支付";
					Laya.timer.clear(this,countDownPayTime);
					uiSkin.orderState.color = "#FF0000";
					
				}
				
			}
		}
		
		public function updateOrderList(cell:QuestOrderItem):void
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
		
		private function onGetDeliveryState():void
		{
			var requestdata:String = "orderSn=" + this.param.id ;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderDeliveryState + requestdata,this,onGetStateBack,null,null);
		}
		
		private function onGetStateBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result != null && result.deliveryList.length > 0)
			{
				ViewManager.instance.openView(ViewManager.DELIVERY_PACKAGE_PANEL,false,result.deliveryList);

			}
			else
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"生产未完成，未查询到物流信息"});
			}
			

		}
		private function onCloseView():void
		{
			Laya.timer.clear(this,countDownPayTime);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			ViewManager.instance.closeView(ViewManager.VIEW_ORDER_DETAIL_PANEL);

		}
	}
}
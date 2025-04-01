package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.ChooseDeliveryTimePanelUI;
	import ui.usercenter.OrderListItemUI;
	
	import utils.TimeManager;
	import utils.TipsUtil;
	import utils.UtilTool;
	
	public class OrderCheckListItem extends OrderListItemUI
	{
		private var orderdata:Object;
		public function OrderCheckListItem()
		{
			super();
		}
		
		
		public function setData(data:Object):void
		{
			orderdata = data;
			//var orderdetal:Object = JSON
			this.orderid.text = orderdata.id;
			this.ordertime.text = orderdata.createdAt;

			var status:int = parseInt(orderdata.status);
			this.retrybtn.visible = false;

			this.deletebtn.visible = false;
			this.deleteorder.visible = false;
			Laya.timer.clearAll(this);

			if(status == 0)
			{
				this.orderstatus.text = "未支付";
				this.orderstatus.color = "#FF0000";
				this.payagain.visible = true;
				var orderinfo:Object = JSON.parse(orderdata.detail);
				if(orderdata.createdAt != null)
					var ordertime:Date = new Date(Date.parse(UtilTool.convertDateStr(orderdata.createdAt)));
				else
					 ordertime = new Date(Date.parse(UtilTool.convertDateStr(orderinfo.pay_timeStr)));

				var passtime:Number = (new Date()).getTime() - ordertime.getTime() + 8 * 3600 * 1000;
			
				
				this.deleteorder.visible = passtime > 3600 * 24 * 5 * 1000;
			}
			else if(status == 10)
			{
				this.orderstatus.text = "支付中";
				this.orderstatus.color = "#52B232";
				this.payagain.visible = false;
				countDownPayTime();
				Laya.timer.loop(1000,this,countDownPayTime);
				
				var ordertime:Date = new Date(Date.parse(UtilTool.convertDateStr(orderdata.createdAt)));
				
				
				var passtime:Number = (new Date()).getTime() - ordertime.getTime() + 8 * 3600 * 1000;
				
				
				this.deleteorder.visible = passtime > 3600 * 24 * 5 * 1000;
				
			}
			else if(status == 1)
			{
				this.orderstatus.text = "已支付排产成功";
				this.orderstatus.color = "#52B232";
				this.payagain.visible = false;
				this.deletebtn.visible = true;

			}
			else if(status == 102 || status == 103)
			{
				this.orderstatus.text = "已支付排产中";
				this.orderstatus.color = "#0022EE";
				this.payagain.visible = false;
				
				this.deletebtn.visible = false;
				//this.retrybtn.visible = true;
			}
			
			else if(status == 4)
			{
				this.orderstatus.text = "已撤单";
				this.orderstatus.color = "#52B232";
				this.payagain.visible = false;
				this.deletebtn.visible = false;
			}
			else if(status == 100)
			{
				this.orderstatus.text = "已支付排产失败";
				this.orderstatus.color = "#EE4400";
				this.payagain.visible = false;
				this.deletebtn.visible = true;
				this.retrybtn.visible = true;
				this.deletebtn.visible = true;

			}
			
			else
			{
				this.orderstatus.text = "订单异常";
				this.orderstatus.color = "#52B232";
				this.payagain.visible = false;
			}
			try
			{
				var detail:Object = JSON.parse(orderdata.detail);
				if(detail.moneyPaid != null)
					this.paymoney.text = Number(detail.moneyPaid).toFixed(2);
				else
					this.paymoney.text = Number(detail.money_paidStr).toFixed(2);
				

				this.productnum.text = detail.orderItemList.length + "";
				
				if(Userdata.instance.isHidePrice())
					this.paymoney.text = "****";
				//this.paymoney.visible = Userdata.instance.accountType == 1;
				
				this.detailbtn.on(Event.CLICK,this,onShowDetail);
				this.deletebtn.on(Event.CLICK,this,onClickDelete);
				this.payagain.on(Event.CLICK,this,onClickPay);
				this.retrybtn.on(Event.CLICK,this,onClickRetry);
				this.deleteorder.on(Event.CLICK,this,onClickDeleteOrder);

			}
			catch(e)
			{
				
			}
			
			TipsUtil.getInstance().addTips(this.deletebtn,"未开始生产的订单可原价撤回");

		}
		
		private function countDownPayTime():void
		{
			if(orderdata.payDate != null)
			{
				
				var ordertime:Date = new Date(Date.parse(UtilTool.convertDateStr(orderdata.payDate)));
				
				
				var lefttime:Number = Math.ceil((ordertime.getTime() - (new Date()).getTime())/1000);
				
				if(lefttime > 0)
				{
					var str:String = UtilTool.getCountDownString(lefttime);
					this.orderstatus.text = "支付中(" + str + "后可继续支付)";
				}
				else
				{
					this.payagain.visible = true;
					this.orderstatus.text =  "未支付";
					Laya.timer.clear(this,countDownPayTime);
					this.orderstatus.color = "#FF0000";

				}
			
			}
		}
		private function onShowDetail():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ORDER_DETAIL_PANEL,false,orderdata);
		}
		
		private function onClickDelete():void
		{
		//	HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.sendInvoiceRequest,this,getInvoinceBack,null,"post");

			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"订单撤回之后将无法恢复，确定删除吗？",caller:this,callback:confirmDelete,ok:"确定",cancel:"取消"});

		}
		
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				var status:int = parseInt(orderdata.status);

				if(status == 100)
				{
					var prams:Object = {"orderSn":orderdata.id};
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.cancelExceptOrder,this,deleteExceptOrderBack,JSON.stringify(prams),"post");
					return;
				}
					//var detail:Object = JSON.parse(orderdata.or_text);
					
					//var orderdataStr:Object = {"order_sn":orderdata.or_id,"Client_Code":"CL10200","Refund_amount":Number(detail.money_paidStr).toFixed(2)};
					var orderdataStr:Object = {"orderSn":orderdata.id};
					//var param:String = "orderid=" + orderdata.or_id;
					
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.cancelOrder,this,deleteOrderBack,JSON.stringify(orderdataStr),"post");
			}
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.cancelOrder,this,deleteOrderBack,param,"post");

		}
		
		private function onClickDeleteOrder():void
		{

			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"订单删除之后将无法恢复，确定删除吗？",caller:this,callback:confirmDeleteOrders,ok:"确定",cancel:"取消"});	

		}
		private function getInvoinceBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
		}
		private function confirmDeleteOrders(b:Boolean):void
		{
			if(b)
			{
				var params:String = "id=" + orderdata.id;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteOrderList,this,deleteOrderListBack,params,"post");
			}
		}
		private function deleteOrderListBack(data:*):void
		{
			EventCenter.instance.event(EventCenter.DELETE_ORDER_BACK);

		}
		private function deleteExceptOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				EventCenter.instance.event(EventCenter.DELETE_ORDER_BACK);
			}
			else
			{
				ViewManager.showAlert("订单取消失败");
			}
			
		}
		private function deleteOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.data.code == 0)
			{
				EventCenter.instance.event(EventCenter.DELETE_ORDER_BACK);
			}
			else if( result.data.code == 1)
			{
				var detail:Object = JSON.parse(orderdata.detail);

				ViewManager.showAlert("订单已开始生产，请联系厂家取消订单，联系电话" + detail.contact_phone);
			}
			else
			{
				//var detail:Object = JSON.parse(orderdata.or_text);
				
				//ViewManager.showAlert("订单已开始生产，请联系厂家取消订单，联系电话" + detail.contact_phone);
				ViewManager.showAlert("撤回订单失败");
			}
		}
		
		private function onClickPay():void
		{
			
//			var orderinfo:Object = JSON.parse(orderdata.or_text);
//			
//			ViewManager.instance.openView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL,false,{amount:Number(orderinfo.money_paidStr),orderid:[orderdata.or_id]});


			var orderinfo:Object = JSON.parse(orderdata.detail);
			var ordertime:Date = new Date(Date.parse(UtilTool.convertDateStr(orderinfo.payTime)));
			
			var passtime:Number = (new Date()).getTime() - ordertime.getTime() + 8 * 3600 * 1000;
			if(passtime > 3600 * 24 * 5 * 1000)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"超过5天的订单不能重新支付"});
				return;
			}
			
			if(PaintOrderModel.instance.allManuFacutreMatProcPrice[orderinfo.manufacturerCode] == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getManuFactureMatProcPrice + orderinfo.manufacturerCode,this,function(dataStr:*):void{
					
					PaintOrderModel.instance.initManuFacuturePrice(orderinfo.manufacturerCode,dataStr);
					
					
					requestAvailableDate(orderinfo);
					
					
					
				},null,null);
			}
			else
			{
				requestAvailableDate(orderinfo);

			}
						

		}
		
		private function requestAvailableDate(orderinfo:Object):void
		{
		
			var itemlist:Array = orderinfo.orderItemList;
			for(var i:int=0;i < itemlist.length;i++)
			{
				delete itemlist[i].lefttime;
				delete itemlist[i].deliveryDate ;
				delete itemlist[i].isUrgent;

			}
			PaintOrderModel.instance.finalOrderData = [orderinfo];
			
			var defaultPrefer:String = UtilTool.getLocalVar("timePrefer","2");
			if(parseInt(defaultPrefer) < 2)
				defaultPrefer = "2";
			PaintOrderModel.instance.curTimePrefer = parseInt(defaultPrefer);
			
			var datas:String = PaintOrderModel.instance.getOrderCapcaityData(orderinfo,PaintOrderModel.instance.curTimePrefer);
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,datas,"post");
			
		}
		
		private function ongetAvailableDateBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var alldates:Array = result as Array;
//				for(var i:int=0;i < alldates.length;i++)
//				{
//					
//					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn] = {};
//					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList = [];
//					
//					var orderdata:Object = PaintOrderModel.instance.getSingleProductOrderData(alldates[i].orderItem_sn);
//					
//					var currentdate:String = alldates[i].current_date;
//					
//					if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
//					{
//						orderdata.delivery_date = alldates[i].default_deliveryDate;
//						
//						orderdata.is_urgent = (orderdata.delivery_date == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT);
//						orderdata.lefttime = 150;
//					}
//					
//					for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
//					{
//						if(alldates[i].deliveryDateList[j].urgent == false)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.is_urgent == false)
//							{
//								orderdata.discount = alldates[i].deliveryDateList[j].discount;
//							}
//						}
//						else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.is_urgent)
//							{
//								orderdata.discount = alldates[i].deliveryDateList[j].discount;
//							}
//							
//							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].urgentDate = alldates[i].deliveryDateList[j];
//						}
//						
//						
//					}										
//					
//				}
				
				for(var i:int=0;i < alldates.length;i++)
				{
					
					var currentdate:String = alldates[i].current_date;
					
					var curtime:Number = Date.parse(currentdate.replace("-","/"));
					TimeManager.instance.serverDate = curtime/1000;
					
					currentdate = currentdate.split(" ")[0];
					
					PaintOrderModel.instance.currentDayStr = currentdate;
					
					
					
					var orderdataList:Array = PaintOrderModel.instance.getProductOrderDataList(alldates[i].orderItem_sn);
					
					for(var k:int=0;k < orderdataList.length;k++)
					{
						var orderdata:Object = orderdataList[k];
						
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn] = {};
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList = [];
						
						if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
						{
							orderdata.deliveryDate  = alldates[i].default_deliveryDate;
							
							orderdata.isUrgent = (orderdata.deliveryDate  == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT)?1:0;
							orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
						}
						
						for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
						{
							if(alldates[i].deliveryDateList[j].urgent == false)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
								
								if(orderdata.deliveryDate  == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent == false)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
							}
							else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								if(orderdata.deliveryDate  == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate = alldates[i].deliveryDateList[j];
							}
							
							
						}										
					}
				}
				
				//ViewManager.instance.openView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL,false,{orders:PaintOrderModel.instance.finalOrderData[0].orderItemList,delaypay:true});
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[ChooseDeliveryTimePanelUI,0,{orders:PaintOrderModel.instance.finalOrderData[0].orderItemList,delaypay:true,firstOrder:this.orderdata.kind==1}]);

			}
		}
		
		private function onClickRetry():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.payExceptOrder,this,payMoneyBack,"orderid=" + orderdata.or_id,"post");

		}
		
		private function payMoneyBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				ViewManager.showAlert("订单排产成功");
				EventCenter.instance.event(EventCenter.PAY_ORDER_SUCESS);
				
			}
			else
			{
				ViewManager.showAlert("订单排产失败，您可以撤回订单，重新下单");
			}
		}
	}
}
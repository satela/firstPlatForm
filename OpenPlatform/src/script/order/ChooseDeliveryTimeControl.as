package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.RadioGroup;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.DeliveryTypeVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	
	import script.ViewManager;
	
	import ui.inuoView.MyWorkPanelUI;
	import ui.inuoView.items.MatCategoryItemUI;
	import ui.order.ChooseDeliveryTimePanelUI;
	
	import utils.TimeManager;
	import utils.UtilTool;
	
	public class ChooseDeliveryTimeControl extends Script
	{
		private var uiSkin:ChooseDeliveryTimePanelUI;
		
		private var param:Object;
		
		private var orderDatas:Array;
		
		private var delaypay:Boolean = false;
		
		private var requestnum:int = 0;
		
		private var curclicknum:int = 0;
		
		private var FORBIDTIME:Array = [0,30000,60000,180000];
		
		private var canoccypay:Boolean = true;
		
		private var leftforbidtime:int = 0;
		
		private var placeorderNum:int = 0;
		
		private var manufactcodeStr:String;
		private var searchzoneid:String;
		
		private var retryTime:int = 0;
		
		private var curSelectedManufacture:String;
		
		private var firstOrder:Boolean = false;
		
		public function ChooseDeliveryTimeControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ChooseDeliveryTimePanelUI;
			
			uiSkin.title.text = OrderConstant.orderName[PaintOrderModel.instance.orderType] + "下单";
			
			uiSkin.orderlist.itemRender = ChooseDelTimeOrderItem;
			uiSkin.orderlist.selectEnable = false;
			uiSkin.orderlist.spaceY = 2;
			uiSkin.orderlist.renderHandler = new Handler(this, updateOrderItem);
			
			uiSkin.deliveryTypelist.itemRender = DeliverySelCell;
			uiSkin.deliveryTypelist.selectEnable = false;
			uiSkin.deliveryTypelist.spaceY = 2;
			uiSkin.deliveryTypelist.renderHandler = new Handler(this, updateDelvieryItem);
			uiSkin.deliveryTypelist.array = [];
			
			uiSkin.savebtn.on(Event.CLICK,this,onSaveOrder);
			uiSkin.paybtn.on(Event.CLICK,this,onPayOrder);
			//uiSkin.closebtn.on(Event.CLICK,this,onGiveUpOrder);

			//uiSkin.paybtn.on(Event.CLICK,this,onPayOrder);

			orderDatas = param.orders as Array;
			delaypay = param.delaypay;
			firstOrder = param.firstOrder;
			
			uiSkin.savebtn.visible = !delaypay;
			
			uiSkin.orderlist.array = orderDatas;
			
			uiSkin.timepreferRdo.selectedIndex = PaintOrderModel.instance.curTimePrefer - 2;
			
			//uiSkin.confirmpreferbtn.on(Event.CLICK,this,resetTimePrefer);
			uiSkin.setdefaultbtn.on(Event.CLICK,this,setDefaultTimePrefer);
			uiSkin.timepreferRdo.on(Event.CHANGE,this,resetTimePrefer);
			
			//PaintOrderModel.instance.curCommmonDeliveryType = "";
			//PaintOrderModel.instance.curUrgentDeliveryType = "";
			
			//uiSkin.commondelType.labels = "";
			//uiSkin.urgentdeltype.labels = "";
			
			var manufactcodes:Array = [];
			//var searchzoneid:String = "";
			for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
			{
				manufactcodes.push(PaintOrderModel.instance.finalOrderData[i].manufacturerCode);
				searchzoneid = PaintOrderModel.instance.finalOrderData[i].addressId;
				
				var manucell:MatCategoryItemUI = new MatCategoryItemUI();
				manucell.selbtn.label = PaintOrderModel.instance.finalOrderData[i].manufacturerName;
				manucell.selfIcon.visible = false;
				
				manucell.selbtn.width = manucell.selbtn.text.textWidth + 40;
				manucell.width = manucell.selbtn.width;
				
				uiSkin.manufatureList.addChild(manucell);
				if(i==0)
				{
					manucell.selbtn.selected = true;
					curSelectedManufacture = PaintOrderModel.instance.finalOrderData[i].manufacturerCode;
				}
				
				
				//break;
			}
			
			manufactcodeStr = manufactcodes.toString();
			
			
			if(PaintOrderModel.instance.deliveryList == null || PaintOrderModel.instance.deliveryList.length < manufactcodes.length)
			{
				var params:Object = "manufacturerList="+manufactcodes.toString() + "&addr_id=" + searchzoneid;

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + params,this,onGetDeliveryBack,null,null);

				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + manufactcode + "&addr_id=" + searchzoneid,this,onGetDeliveryBack,null,null);
			}
			else
				initDeliveryInfo();
			
	

			var total:Number = 0;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var ordermoney:Number = Number(orderDatas[i].itemPrice) * Number(orderDatas[i].itemNumber);
				
				ordermoney = parseFloat(ordermoney.toFixed(1));

				total += ordermoney;
			}
			
			uiSkin.rawprice.text = PaintOrderModel.instance.rawPrice + "元";
			if(param.delaypay)
			{
				uiSkin.rawprice.text = PaintOrderModel.instance.finalOrderData[0].moneyPaid + "元";

			}
			uiSkin.disocuntprice.text = total.toFixed(1) + "元";
			uiSkin.totalprice.text = total.toFixed(1) + "元";
			uiSkin.delmoney.text = "0元";
			
			uiSkin.countdown.visible = false;
			uiSkin.productNum.text = orderDatas.length + "";
			if(Userdata.instance.isHidePrice())
			{
				uiSkin.disocuntprice.text = "***";
				uiSkin.totalprice.text = "***";
				
				uiSkin.delmoney.text =  "***";
				uiSkin.rawprice.text =  "***";

			}
			
			
			uiSkin.firstDiscount.visible = Userdata.instance.firstOrder == "1" || firstOrder;

			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			Laya.timer.loop(1000,this,onCountDownTime);
			
			EventCenter.instance.on(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE,this,updatePrice);
			EventCenter.instance.on(EventCenter.BATCH_CHANGE_OCCUPY_DATE,this,retryBatchOccupy);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			//uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			initDeliveryDateLabel();
			updatePrice();
			
			EventCenter.instance.on(EventCenter.FIRST_PAGE_SHRINK,this,updateDeliveryDateBox);
			updateDeliveryDateBox(Userdata.instance.shrinkState);
			
			//ViewManager.instance.setViewVisible(ViewManager.VIEW_PAINT_ORDER,true);

			//uiSkin.
			
			
		}
		
		private function updateDeliveryDateBox(state:int):void
		{
			if(state == 0)
				uiSkin.deliverdateBoc.space = 50;
			else
				uiSkin.deliverdateBoc.space = 95;

		}
		private function onResizeBrower():void
		{
			
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private function initDeliveryDateLabel():void
		{
			var nextfivedays:Array = UtilTool.getNextFiveDays(PaintOrderModel.instance.currentDayStr + " 00:00:00");
			
			for(var i=0;i < nextfivedays.length;i++)
			{
				uiSkin["deliveryDate" + i].text = nextfivedays[i];
			}
		}
		private function retryGetDelivery():void
		{
			var params:Object = "manufacturerList="+ manufactcodeStr.toString() + "&addr_id=" + searchzoneid;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + params,this,onGetDeliveryBack,null,null);
			
		}
		private function onGetDeliveryBack(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.deliveryList = {};
				
				for(var i:int=0;i < result.length;i++)
				{
					var deliverys:Array = result[i].deliveryList;
					PaintOrderModel.instance.deliveryList[result[i].manufacturer_code] = [];
					for(var j:int=0;j < deliverys.length;j++)
					{
						var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(deliverys[j]);
						tempdevo.belongManuCode = result[i].manufacturer_code;
						
						PaintOrderModel.instance.deliveryList[result[i].manufacturer_code].push(tempdevo);
						
						if(tempdevo.delivery_name == OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
						{
							
							PaintOrderModel.instance.selectDelivery = tempdevo;
						}
					}
					
				}
				initDeliveryInfo();
			}
		}
		
		private function initDeliveryInfo():void
		{
			if(PaintOrderModel.instance.getDeliveryList()[0].deliveryVoArr == null || PaintOrderModel.instance.getDeliveryList()[0].deliveryVoArr.length == 0)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"当前收货地址没有配送服务，请重新选择收货地址下单"});
			}
			
			
			//uiSkin.deliveryTypelist.bottom = 90 + 50 * (PaintOrderModel.instance.getDeliveryList().length - 1);

			uiSkin.deliveryTypelist.array = PaintOrderModel.instance.getDeliveryList();
			//uiSkin.deliveryTypelist.height = 50 * PaintOrderModel.instance.getDeliveryList().length;
			
			//uiSkin.orderlist.bottom = 130 + 50 * (PaintOrderModel.instance.getDeliveryList().length - 1);
			//uiSkin.orderlist.refresh();
			var arr:Array = PaintOrderModel.instance.getDeliveryList();
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].manufacturer_code == curSelectedManufacture)
				{
					var temp:Array = [];
					temp.push(arr[i]);
					uiSkin.deliveryTypelist.array = temp;
					break;
				}
			}
			
		}
		
		private function showMaufactureList():void
		{
			for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
			{
				//manufactcodes.push(PaintOrderModel.instance.finalOrderData[i].manufacturerCode);
				//searchzoneid = PaintOrderModel.instance.finalOrderData[i].addressId;
				//break;
				var manucell:MatCategoryItemUI = new MatCategoryItemUI();
				manucell.selbtn.label = PaintOrderModel.instance.finalOrderData[i].manufacturerName;
				manucell.selfIcon.visible = false;
			}
			
		}
		private function onCountDownTime():void
		{
			var arr:Array = orderDatas;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				if(orderDatas[i].isUrgent == 1  ||  orderDatas[i].deliveryDate  != null)
				{
					if(orderDatas[i].lefttime > 0)
					{
						orderDatas[i].lefttime--;
						if(orderDatas[i].lefttime == 0)
						{
							orderDatas[i].isUrgent = 0;
							orderDatas[i].deliveryDate  = null;
							orderDatas[i].outtime = true;
							//retryGetAvailableDate(orderDatas[i]);
						}
					}
				}
			}
			if(leftforbidtime > 0)
			{
				leftforbidtime--;
				uiSkin.countdown.text = "（" + leftforbidtime + "秒之后可重新选择交付策略）";
				uiSkin.countdown.visible = true;
			}
			else
			{
				uiSkin.countdown.visible = false;

			}
		}
		
		private function retryBatchOccupy(itemsn:String,manucode:String,prodcode:String,isurgent:int,deliverydate:String,discount:Number):void
		{
				
			//var datas:String = PaintOrderModel.instance.getSingleOrderItemCapcaityData(orderdata);
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,{data:datas},"post");
			
			var params:String = "orderItem_sn=" + itemsn + "&manufacturer_code=" + manucode + "&prod_code=" + prodcode + "&isUrgent=" + isurgent + "&delivery_date=" + deliverydate;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.preOccupyCapacity + params,this,function(data:*){
				
				var result:Object = JSON.parse(data as String);
				if(!result.hasOwnProperty("status"))
				{
					//var alldates:Array = result as Array;
					
					if(result.feedBack == 1)
					{
						
						
						var orderdataList:Array = PaintOrderModel.instance.getProductOrderDataList(itemsn);
						
						for(var i:int=0;i < orderdataList.length;i++)
						{
							var orderdata:Object = orderdataList[i];
							orderdata.outtime = false;
							orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
							
							orderdata.isUrgent = isurgent;
							orderdata.deliveryDate  = deliverydate;
							orderdata.discount = discount;
						}
					}					
					else
					{
						var orderdataList:Array = PaintOrderModel.instance.getProductOrderDataList(itemsn);
						
						for(var i:int=0;i < orderdataList.length;i++)
						{
							var orderdata:Object = orderdataList[i];
							orderdata.isUrgent = 0;
							orderdata.deliveryDate  = null;
							orderdata.discount = 1;
						}
						
					}
						
					uiSkin.orderlist.array = orderDatas;
					updatePrice();
				}
				
				},null,null);
			

		}
		
		private function onOccupyCapacityBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{		
				
				uiSkin.orderlist.array = orderDatas;
				updatePrice();
			}
		}
		
		private function updatePrice():void
		{
			var deliveryCells:Vector.<Box> = uiSkin.deliveryTypelist.cells;
			
			for(var i:int=0;i < deliveryCells.length;i++)
			{
				(deliveryCells[i] as DeliverySelCell).refreshRadio();
			}
			var total:Number = 0;
			var commomitemManuNum:Array = [];
			var urgentitemManuNum:Array = [];
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var ordermoney:Number = 0;//Number(orderDatas[i].item_priceStr) * Number(orderDatas[i].item_number);
				
				var disoucntprocessPrice:Number = orderDatas[i].discountProcessPrice * orderDatas[i].itemNumber;
				var materialPrice:Number = orderDatas[i].materialPrice * orderDatas[i].itemNumber;
				
				//var nowprices:Number = parseFloat((disoucntprocessPrice + materialPrice).toFixed(1));
				var deldiscount:Number = 1;
				if(orderDatas[i].isUrgent == 1 || orderDatas[i].deliveryDate  != null)
				{
					deldiscount = orderDatas[i].discount;
					
				}
				ordermoney = disoucntprocessPrice * deldiscount+ materialPrice;
				
				//报表数据
				orderDatas[i].matCost =  orderDatas[i].one_mat_cost * orderDatas[i].itemNumber;
				orderDatas[i].matCost = orderDatas[i].matCost.toFixed(2);
				
				orderDatas[i].procCost =  orderDatas[i].one_proc_cost * orderDatas[i].itemNumber;
				orderDatas[i].procCost = orderDatas[i].procCost.toFixed(2);
				
				orderDatas[i].grossMargin = orderDatas[i].oneNoDiscountGrossMargin * orderDatas[i].itemNumber + orderDatas[i].oneDiscountGrossMargin * orderDatas[i].itemNumber * deldiscount;
				
				orderDatas[i].grossMargin = orderDatas[i].grossMargin.toFixed(2);
				
				orderDatas[i].taxFee = ordermoney - parseFloat(orderDatas[i].matCost) - parseFloat(orderDatas[i].procCost) - parseFloat(orderDatas[i].grossMargin);
				orderDatas[i].taxFee = orderDatas[i].taxFee.toFixed(1);
				
				
				
				var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderDatas[i].orderItemSn);
				if(orderDatas[i].isUrgent == 1 && urgentitemManuNum.indexOf(manucode) < 0)
				{
					urgentitemManuNum.push(manucode);
				}
				else if(orderDatas[i].isUrgent == 0 && commomitemManuNum.indexOf(manucode) < 0)
				{
					commomitemManuNum.push(manucode);

				}
				ordermoney = parseFloat(ordermoney.toFixed(1));
				
				
				total += ordermoney;
			}
			
			var commondelprice:Number = 0;//PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.curCommmonDeliveryType) * commomitemManuNum.length;
			var urgentdelprice:Number = 0;//PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.curUrgentDeliveryType) * urgentitemManuNum.length;
			if(PaintOrderModel.instance.deliveryList != null)
			{
				for(i=0;i < commomitemManuNum.length;i++)
				{
					if(i==0)
						commondelprice += PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.deliveryList[commomitemManuNum[i]],PaintOrderModel.instance.curCommmonDeliveryType[commomitemManuNum[i]]);
					else if(PaintOrderModel.instance.curCommmonDeliveryType[commomitemManuNum[i]] != null && PaintOrderModel.instance.curCommmonDeliveryType[commomitemManuNum[i]] !=  PaintOrderModel.instance.curCommmonDeliveryType[commomitemManuNum[0]])
						commondelprice += PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.deliveryList[commomitemManuNum[i]],PaintOrderModel.instance.curCommmonDeliveryType[commomitemManuNum[i]]);

				}
				
				for(i=0;i < urgentitemManuNum.length;i++)
				{
					urgentdelprice += PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.deliveryList[urgentitemManuNum[i]],PaintOrderModel.instance.curUrgentDeliveryType[urgentitemManuNum[i]]);
				}
			}
			
			//if(hasUrgentOrderItem() == false)
			//	urgentdelprice = 0;

			//if(hasCommonOrderItem() == false)
			//	commondelprice = 0;
			
			uiSkin.delmoney.text = (commondelprice + urgentdelprice).toFixed(1) + "元";
			uiSkin.disocuntprice.text = total.toFixed(1) + "元";
			var totals:Number = parseFloat((commondelprice + urgentdelprice).toFixed(1)) + parseFloat(total.toFixed(1));
			
			if(totals < 2*PaintOrderModel.instance.finalOrderData.length)
				totals = 2*PaintOrderModel.instance.finalOrderData.length;
			
			uiSkin.totalprice.text = totals.toFixed(1) + "元";
			if(Userdata.instance.firstOrder == "1" || firstOrder)
			{
				var freshMoney:Number = totals - Constast.FRESH_DISCOUNT;
				if(freshMoney < 1)
					freshMoney = 1;
				uiSkin.totalprice.text = freshMoney.toFixed(1) + "元";

			}
			
			for(var i:int=0;i < uiSkin.deliveryTypelist.cells.length;i++)
			{
				(uiSkin.deliveryTypelist.cells[i] as DeliverySelCell).refreshLabel();
			}
			if(Userdata.instance.isHidePrice())
			{
				uiSkin.disocuntprice.text = "***";
				uiSkin.totalprice.text = "***";
				
				uiSkin.delmoney.text =  "***";
				uiSkin.rawprice.text =  "***";
				
			}
		}
		
		private function onPayOrder():void
		{
			//trace("oderdara:" + JSON.stringify(PaintOrderModel.instance.finalOrderData));
			
//			var arr:Array = getOrderData();
//			if(arr == null)
//				return;
//			uiSkin.paybtn.mouseEnabled = false;
//			
//			if(delaypay)
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateOrder,this,onUpdateOrderBack,{data:JSON.stringify(arr)},"post");
//			else				
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.placeOrder,this,onPlaceOrderBack,{data:JSON.stringify(arr)},"post");
			
			var searchzoneid:String = "";
			for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
			{
				searchzoneid = PaintOrderModel.instance.finalOrderData[i].addressId;
				break;
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + searchzoneid + "&manufacturer_type=喷印输出中心"+ "&client_code=" + Userdata.instance.clientCode,this,onGetOutPutAddress,null,null);

			

		}
		
		private function onGetOutPutAddress(data:*):void
		{
			if(uiSkin.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var factories:Array = result as Array;
				for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
				{
					var hasfactory:Boolean = false;
					for(var j:int=0;j < factories.length;j++)
					{
						if(PaintOrderModel.instance.finalOrderData[i].manufacturerCode == factories[j].org_code)
						{
							hasfactory = true;
						}
					}
					if(hasfactory == false)
					{
						ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"当前的输出中心无效，请重新下单。"});
						return;
					}
				}
				
				var arr:Array = getOrderData();
				if(arr == null)
					return;
				
				var idnum:String = arr[0].placeorderNum;
				if(arr == null)
					return;
				uiSkin.paybtn.mouseEnabled = false;
	
				if(delaypay)
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateOrder,this,onUpdateOrderBack,JSON.stringify(arr),"post");
				else				
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.placeOrder,this,onPlaceOrderBack,JSON.stringify(arr),"post");
			}
			
		}
		
		private function onUpdateOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.showAlert("下单成功");
				var totalmoney:Number = 0;
				var allorders:Array = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					var orderdata:Object = result.data[i];
					totalmoney += Number(orderdata.moneyPaid);
					allorders.push(orderdata.orderSn);
				}
				
				if(Userdata.instance.firstOrder == "1" || firstOrder)
				{
					var totalmoney:Number = totalmoney - Constast.FRESH_DISCOUNT;
					if(totalmoney < 1)
						totalmoney = 1;
					
				}
				
				var paylefttime:int = getPayLeftTime();
				if(paylefttime > 0)
					ViewManager.instance.openView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL,false,{amount:Number(totalmoney.toFixed(2)),orderid:allorders,lefttime:paylefttime});
				else
					ViewManager.showAlert("支付超时，请重新选择交付时间");
				
			}
			uiSkin.paybtn.mouseEnabled = true;


		}
		private function onPlaceOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.showAlert("下单成功");
				var totalmoney:Number = 0;
				var allorders:Array = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					var orderdata:Object = result.data[i];
					totalmoney += Number(orderdata.moneyPaid);
					allorders.push(orderdata.orderSn);
				}
				
				if(Userdata.instance.firstOrder == "1" || firstOrder)
				{
					var totalmoney:Number = totalmoney - Constast.FRESH_DISCOUNT;
					if(totalmoney < 1)
						totalmoney = 1;
					
				}
				//Userdata.instance.firstOrder = "0";
				var paylefttime:int = getPayLeftTime();
				if(paylefttime > 0)
					ViewManager.instance.openView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL,false,{amount:Number(totalmoney.toFixed(2)),orderid:allorders,lefttime:paylefttime});
				else
					ViewManager.showAlert("支付超时，请重新选择交付时间");
				
			}
			uiSkin.paybtn.mouseEnabled = true;

		}
		
		private function getPayLeftTime():int
		{
			var arr:Array = orderDatas;
			var leftime:int = 0;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				if(orderDatas[i].isUrgent == 1  ||  orderDatas[i].deliveryDate  != null)
				{
					if(orderDatas[i].lefttime < leftime || leftime == 0)
					{
						leftime = orderDatas[i].lefttime;
					}
				}
			}
			
			return leftime;
		}
		
		private function resetDeliveryTime():void
		{
			for(var i:int=0;i < orderDatas.length;i++)
			{
				orderDatas[i].isUrgent = 0;
				orderDatas[i].deliveryDate  = null;
				
				orderDatas[i].outtime = false;
				orderDatas[i].lefttime = 0;
				
				orderDatas[i].discount = 1;
				
			}
			uiSkin.orderlist.array = orderDatas;
			updatePrice();
			
			
		}
		
		
		
		private function setDefaultTimePrefer():void
		{
			UtilTool.setLocalVar("timePrefer",uiSkin.timepreferRdo.selectedIndex+2);
			ViewManager.showAlert("设置成功");
		}
		private function resetTimePrefer():void
		{
			
			if(canoccypay == false)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"您操作的太频繁了，请稍后再试"});
				//uiSkin.timepreferRdo.selectedIndex = PaintOrderModel.instance.curTimePrefer - 1;
				return;
			}
			canoccypay = false;
			curclicknum++;
			
			uiSkin.timepreferRdo.mouseEnabled = false;
			if(curclicknum > 3)
				curclicknum = 3;
			
			leftforbidtime = FORBIDTIME[curclicknum]/1000;
			
			Laya.timer.once(FORBIDTIME[curclicknum],this,enableClickOccupy);
			var arr:Array = PaintOrderModel.instance.finalOrderData;
			
			requestnum = 0;
			
			PaintOrderModel.instance.curTimePrefer = uiSkin.timepreferRdo.selectedIndex + 2;

			resetDeliveryTime();
			//if(PaintOrderModel.instance.curTimePrefer == uiSkin.timepreferRdo.selectedIndex + 1)
			//	return;

			for(var i:int=0;i < arr.length;i++)
			{
				
				
				var datas:String = PaintOrderModel.instance.getOrderCapcaityData(arr[i],uiSkin.timepreferRdo.selectedIndex + 2);
				
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAllAvailableDateBack,datas,"post");
				
				
			}
			//ViewManager.instance.openView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL,false,orderDatas);
			//PaintOrderModel.instance.packageList = new Vector.<PackageVo>();
			
		}
		
		private function enableClickOccupy():void
		{
			canoccypay = true;
			uiSkin.timepreferRdo.mouseEnabled = true;

		}
		private function ongetAllAvailableDateBack(data:*):void
		{
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
//					orderdata.delivery_date = null;
//					orderdata.isUrgent = false;
//					
//					var currentdate:String = alldates[i].current_date;
//					
//					var curtime:Number = Date.parse(currentdate.replace("-","/"));
//					TimeManager.instance.serverDate = curtime/1000;
//					
//					currentdate = currentdate.split(" ")[0];
//					PaintOrderModel.instance.currentDayStr = currentdate;
//
//					
//					if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
//					{
//						orderdata.delivery_date = alldates[i].default_deliveryDate;
//						
//						orderdata.isUrgent = (orderdata.delivery_date == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT);
//						
//						orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
//
//					}
//					
//					for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
//					{
//						if(alldates[i].deliveryDateList[j].urgent == false)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent==false)
//							{
//								orderdata.discount = alldates[i].deliveryDateList[j].discount;
//							}
//							
//							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
//						}
//						else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent)
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
				requestnum++;
				if(requestnum == PaintOrderModel.instance.finalOrderData.length)
				{
					uiSkin.orderlist.array = orderDatas;
					updatePrice();
				}
				initDeliveryDateLabel();
			}
		}
		
		private function getOrderData():Array
		{
			var manuarr:Array = PaintOrderModel.instance.finalOrderData;
			
			
			for(var i:int=0;i < manuarr.length;i++)
			{
				var itemlist:Array = manuarr[i].orderItemList;
				var packagelist:Array = manuarr[i].packageList;

				var totalprice:Number = 0;
				
				//manuarr[i].logistic_code  = commondelName;
				
				//manuarr[i].paydelay = delaypay?1:0;
				
				manuarr[i].placeorderNum = itemlist[0].orderItemSn;
				
				var hascommonDelItem:Boolean = false;
				var hsurgentDelItem:Boolean = false;
				
				if(PaintOrderModel.instance.hasCommonOrderItem(manuarr[i].manufacturerCode) && UtilTool.stringIsEmpty(PaintOrderModel.instance.curCommmonDeliveryType[manuarr[i].manufacturerCode]))
				{
					if(retryTime <= 1)
					{
						Laya.timer.frameOnce(10,this,retryGetDelivery);
						retryTime++;
					}
					else
						ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"请选择普通配送方式"});
					
					return null;
				}
				
				if(PaintOrderModel.instance.hasUrgentOrderItem(manuarr[i].manufacturerCode) && UtilTool.stringIsEmpty(PaintOrderModel.instance.curUrgentDeliveryType[manuarr[i].manufacturerCode]))
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"请选择加急配送方式"});
					return null;
				}
				
				var commondelName:String = PaintOrderModel.instance.getDeliveryOrgCode(PaintOrderModel.instance.deliveryList[manuarr[i].manufacturerCode]) + "#" + PaintOrderModel.instance.curCommmonDeliveryType[manuarr[i].manufacturerCode];
				var urgentdelName:String = PaintOrderModel.instance.getDeliveryOrgCode(PaintOrderModel.instance.deliveryList[manuarr[i].manufacturerCode]) + "#" + PaintOrderModel.instance.curUrgentDeliveryType[manuarr[i].manufacturerCode];
				
				var commondelprice:Number = PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.deliveryList[manuarr[i].manufacturerCode],PaintOrderModel.instance.curCommmonDeliveryType[manuarr[i].manufacturerCode]);
				var urgentdelprice:Number = PaintOrderModel.instance.getDeliveryPrice(PaintOrderModel.instance.deliveryList[manuarr[i].manufacturerCode],PaintOrderModel.instance.curUrgentDeliveryType[manuarr[i].manufacturerCode]);
				
				if(PaintOrderModel.instance.hasCommonOrderItem(manuarr[i].manufacturerCode))
					manuarr[i].logistic_code  = commondelName;
				else
					manuarr[i].logistic_code = "";
				
				for(var k:int=0;k < packagelist.length;k++)
				{
					packagelist[k].logisticCode = manuarr[i].logistic_code;
				}
				for(var j:int=0;j < itemlist.length;j++)
				{
					if(itemlist[j].isUrgent == null || (itemlist[j].isUrgent == false && itemlist[j].deliveryDate  == null))
					{
						ViewManager.showAlert("有产品未设置交货时间");
						return null;
					}
					
					if(itemlist[j].discount == null)
					{
						ViewManager.showAlert("请重新选择交货时间");
						return null;
					}
					
					if(itemlist[j].isUrgent == 1)
					{
						itemlist[j].logistics_type = urgentdelName;
						hsurgentDelItem = true
					}
					else
					{
						delete itemlist[j].logistics_type;
						hascommonDelItem = true;
					}
					
					var ordermoney:Number = 0;//Number(itemlist[j].item_priceStr) * Number(itemlist[j].item_number) * itemlist[j].discount;
					
					var disoucntprocessPrice:Number = itemlist[j].discountProcessPrice * itemlist[j].itemNumber;
					var materialPrice:Number = itemlist[j].materialPrice * itemlist[j].itemNumber;
					
					//var nowprices:Number = parseFloat((disoucntprocessPrice + materialPrice).toFixed(1));
					var deldiscount:Number = 1;
					if(orderDatas[i].isUrgent == 1 || orderDatas[i].deliveryDate  != null)
					{
						deldiscount = itemlist[j].discount;
						
					}
					ordermoney = disoucntprocessPrice * deldiscount+ materialPrice;
					
					ordermoney = parseFloat(ordermoney.toFixed(1));
					itemlist[j].actualAmount = ordermoney.toString();
						
					totalprice += ordermoney;
					
					
					
				}
				manuarr[i].orderAmount = totalprice;
				
				
				if( (manuarr[i].orderAmount as Number) < 2)
				{
					manuarr[i].orderAmount = 2.00;
					//var itemarr:Array = odata.orderItemList;
					if(itemlist.length > 0)
					{
						var eachprice:Number = Number((2/itemlist.length).toFixed(2));
						
						var overflow:Number = 2 - eachprice*itemlist.length;
						for(var j:int=0;j < itemlist.length;j++)
						{
							if(j==0)
								itemlist[j].itemPrice = (((eachprice + overflow)/itemlist[j].itemNumber) as Number).toFixed(2);
							else
								itemlist[j].itemPrice =  ((eachprice/itemlist[j].itemNumber) as Number).toFixed(2);
						}
					}									
					
				}
				if(i != 0 && PaintOrderModel.instance.curCommmonDeliveryType[manuarr[i].manufacturerCode] == PaintOrderModel.instance.curCommmonDeliveryType[manuarr[0].manufacturerCode])
					commondelprice = 0;
				
				manuarr[i].shippingFee = (commondelprice * (hascommonDelItem?1:0) + urgentdelprice * (hsurgentDelItem?1:0) as Number).toFixed(1);
				manuarr[i].moneyPaid = (manuarr[i].orderAmount + commondelprice * (hascommonDelItem?1:0) + urgentdelprice * (hsurgentDelItem?1:0)).toFixed(1);
				
				manuarr[i].orderAmount = (manuarr[i].orderAmount).toFixed(1);
			}
		
			for(var i:int=0;i < manuarr.length;i++)
			{
				var itemlist:Array = manuarr[i].orderItemList;
				for(var j:int=0;j < itemlist.length;j++)
				{										
					delete itemlist[j].outtime;
					//delete itemlist[j].discount;
										
				}
			}
			var arr:Array = PaintOrderModel.instance.finalOrderData;
			
			return arr;
		}
		private function onSaveOrder():void
		{
			if(Userdata.instance.companyShort == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo ,this,function(data:Object){
					
					if(this.destroyed)
						return;
					var result:Object = JSON.parse(data as String);
					
					if(result.status == 0)
					{
						Userdata.instance.company = result.data.name;
						Userdata.instance.companyShort = result.data.shortName;
						Userdata.instance.founderPhone = result.data.founderMobileNumber;

					}
					
					onSaveOrder();		
				}
					,null,null);	
				
				return;
			}
			
			var arr:Array = PaintOrderModel.instance.finalOrderData;
			
			
			if(arr == null)
				return;
			uiSkin.savebtn.mouseEnabled = false;
			
			
			
			for(var i:int=0;i < arr.length;i++)
			{
				var itemlist:Array = arr[i].orderItemList;
				var totalprice:Number = 0;
				
				//manuarr[i].logistic_code  = commondelName;
				
				//manuarr[i].paydelay = delaypay?1:0;
				
				arr[i].placeorderNum = itemlist[0].orderItemSn;
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.placeOrder,this,onSaveOrderBack,JSON.stringify(arr),"post");
		}
		
		private function onSaveOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[MyWorkPanelUI,0]);

				ViewManager.showAlert("保存订单成功，您可以到我的订单继续支付");

			}
			else
				uiSkin.savebtn.mouseEnabled = true;

		}
		
		private function onGiveUpOrder():void
		{
			if(!delaypay)
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定关闭页面不保存订单吗？",caller:this,callback:confirmClose,ok:"确定",cancel:"取消"});
			else
			{
				ViewManager.instance.closeView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL);
				
			}

		}
		
		private function confirmClose(b:Boolean):void
		{
			if(b)
			{
				ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
			}
		}
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL);
		}
		private function updateOrderItem(cell:ChooseDelTimeOrderItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function updateDelvieryItem(cell:DeliverySelCell):void
		{
			cell.setData(cell.dataSource);

		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE,this,updatePrice);
			EventCenter.instance.off(EventCenter.BATCH_CHANGE_OCCUPY_DATE,this,retryBatchOccupy);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.FIRST_PAGE_SHRINK,this,updateDeliveryDateBox);

			PaintOrderModel.instance.resetData();
			Laya.timer.clearAll(this);

		}
	}
}
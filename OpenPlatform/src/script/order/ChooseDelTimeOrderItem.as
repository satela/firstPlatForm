package script.order
{
	import eventUtil.EventCenter;
	
	import laya.display.Graphics;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.CheckBox;
	import laya.ui.Label;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	
	import script.ViewManager;
	
	import ui.order.SimpleOrderItemUI;
	
	import utils.UtilTool;
	
	public class ChooseDelTimeOrderItem extends SimpleOrderItemUI
	{
		public var orderdata:Object;
		
		private var curselectIndex:int = -1;
		public function ChooseDelTimeOrderItem()
		{
			super();
			
			for(var i:int=0;i < 5;i++)
			{
				this["deltime" + i].on(Event.CLICK,this,onSelectTime,[i]);
			}
			
			this.urgentcheck.on(Event.CLICK,this,onClickUrgent);
			Laya.timer.loop(1000,this,countDownPayTime);
			
			EventCenter.instance.on(EventCenter.FIRST_PAGE_SHRINK,this,updateDeliveryBox);
			updateDeliveryBox(Userdata.instance.shrinkState);

		}
		
		private function updateDeliveryBox(state:int):void
		{
			if(state == 0)
			{
				this.dateBox.space = 25;
				this.linebox.space = 132;
				
			}
			else
			{
				this.dateBox.space = 70;
				this.linebox.space = 178;

			}
			
			this.dateBox.refresh();
		}
		private function onSelectTime(index:int):void
		{
			//selectTime = index;
			
			//discount = PaintOrderModel.instance.getDiscountByDate(selectTime);
			
			//updatePrice();
			
			
				if(this["deltime"+index].selected)
					return;
				
				resetDeliveryTime();
	
				var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderdata.orderItemSn);
				
				curselectIndex = index;
				var disounct:Number = 0;
				var deliverydate:String = "";
				if(orderdata.batchOrderItemSn == "")
				{
					deliverydate  = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList[index].availableDate;
				}
				else
				{
					 deliverydate = PaintOrderModel.instance.availableDeliveryDates[orderdata.batchOrderItemSn].deliveryDateList[index].availableDate;
					 disounct = PaintOrderModel.instance.availableDeliveryDates[orderdata.batchOrderItemSn].deliveryDateList[curselectIndex].discount

				}

				
				
			if(orderdata.batchOrderItemSn == "")
			{
					
				var params:String = "orderItem_sn=" + orderdata.orderItemSn + "&manufacturer_code=" + manucode + "&prod_code=" + orderdata.conponent.prodCode + "&isUrgent=0&delivery_date=" + deliverydate;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.preOccupyCapacity + params,this,onOccupyCapacityBack,null,null);
			}
			else
			{
				var paramdata:Array = [orderdata.batchOrderItemSn,manucode,orderdata.conponent.prodCode,0,deliverydate,disounct];
				EventCenter.instance.event(EventCenter.BATCH_CHANGE_OCCUPY_DATE,paramdata);
				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"批量操作的产品不能单独选择交付日期"});
			}

			
		}
		
		private function resetDeliveryTime():void
		{
			orderdata.isUrgent = 0;
			orderdata.deliveryDate  = null;
			
			orderdata.outtime = false;
			orderdata.lefttime = 0;
			
			orderdata.discount = 1;
			
			for(var i:int=0;i < 5;i++)
			{
				this["deltime"+i].selected = false;
				//this["timeback"+i].visible = false;
			}
			
			this.urgentcheck.selected = false;
			this.urgentcheck.disabled = false;
			
			this.urgentback.visible = this.urgentcheck.selected;
		}
		private function onOccupyCapacityBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data);
			if(!result.hasOwnProperty("status"))
			{
				if(result.feedBack == 1)
				{
					for(var i:int=0;i < 5;i++)
					{
						this["deltime"+i].selected = i == curselectIndex;
						//this["timeback"+i].visible = this["deltime"+i].selected;

					}
					
					this.urgentcheck.selected = false;
					this.urgentcheck.disabled = false;
					this.urgentback.visible = this.urgentcheck.selected;

					orderdata.outtime = false;
					orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
										
					
					orderdata.isUrgent = 0;
					orderdata.deliveryDate  = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList[curselectIndex].availableDate;
					if(orderdata.fixedDiscount)
						orderdata.discount = 1;
					else
						orderdata.discount = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList[curselectIndex].discount;
					
				}
				else
				{
	
					orderdata.isUrgent = 0;
					orderdata.deliveryDate  = null;
					orderdata.discount = 1;

					//resetDeliveryDates();
					retryGetAvailableDate();
				}
				updatePrice();
				EventCenter.instance.event(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE);

			}
		}
		
		private function retryGetAvailableDate():void
		{
			
			var datas:String = PaintOrderModel.instance.getSingleOrderItemCapcaityData(orderdata);
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,datas,"post");
			
		}
		
		private function ongetAvailableDateBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var alldates:Array = result as Array;
				for(var i:int=0;i < alldates.length;i++)
				{
					
					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn] = {};
					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList = [];
					
					for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
					{
						if(alldates[i].deliveryDateList[j].urgent == false)
						{
							if(alldates[i].deliveryDateList[j].discount == 0)
								alldates[i].deliveryDateList[j].discount = 1;
							
							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
						}
						else
						{
							if(alldates[i].deliveryDateList[j].discount == 0)
								alldates[i].deliveryDateList[j].discount = 1;
							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].urgentDate = alldates[i].deliveryDateList[j];
						}
					}	
					
					
					
					
				}
				if(this.destroyed)
					return;
				
				resetDeliveryDates();
				
			}
		}
		
		private function onClickUrgent():void
		{
			
				var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderdata.orderItemSn);
				
				resetDeliveryTime();
				//curselectIndex = index;
				
				var deliverydate:String = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate.availableDate;
				
				var disounct:Number = 0;
				var deliverydate:String = "";
				if(orderdata.batchOrderItemSn != "")
				{
					
					 deliverydate = PaintOrderModel.instance.availableDeliveryDates[orderdata.batchOrderItemSn].urgentDate.availableDate;
					 disounct = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate.discount;
					
				}
				
			if(orderdata.batchOrderItemSn == "")
			{
				var params:String = "orderItem_sn=" + orderdata.orderItemSn + "&manufacturer_code=" + manucode + "&prod_code=" + orderdata.conponent.prodCode + "&isUrgent=1&delivery_date=" + deliverydate;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.preOccupyCapacity + params,this,onOccupyUrgentCapacityBack,null,null);
			}
			else
			{
				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"批量操作的产品不能单独选择交付日期"});
				//this.urgentcheck.selected = false;
				
				var paramdata:Array = [orderdata.batchOrderItemSn,manucode,orderdata.conponent.prodCode,1,deliverydate,disounct];
				EventCenter.instance.event(EventCenter.BATCH_CHANGE_OCCUPY_DATE,paramdata);

			}
			
		}
		
		private function onOccupyUrgentCapacityBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data);
			if(!result.hasOwnProperty("status"))
			{
				if(result.feedBack == 1)
				{
					for(var i:int=0;i < 5;i++)
					{
						this["deltime"+i].selected = false;
						//this["timeback"+i].visible = false;

					}
					
					this.urgentcheck.selected = true;
					this.urgentcheck.disabled = true;
					this.urgentback.visible = this.urgentcheck.selected;

					orderdata.outtime = false;
					orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
					
					
					orderdata.isUrgent = 1;
					orderdata.deliveryDate  = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate.availableDate;
					if(orderdata.fixedDiscount)
						orderdata.discount = 1;
					else
						orderdata.discount = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate.discount;
					
				}
				else
				{
//					PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].deliveryDateList = result.newDateList;
//					
//					PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn] = {};
//					//PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].canUrgent = false;
//					PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].deliveryDateList = [];
//					
//					for(var j:int=0;j < result.newDateList.length;j++)
//					{
//						if(result.newDateList[j].urgent == false)
//						{
//							if(result.newDateList[j].discount == 0)
//								result.newDateList[j].discount = 1;
//							
//							PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].deliveryDateList.push(result.newDateList[j]);
//						}
//						else
//						{
//							if(result.newDateList[j].discount == 0)
//								result.newDateList[j].discount = 1;
//							
//							PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].urgentDate = result.newDateList[j];
//						}
//					}	
					orderdata.isUrgent = 0;
					orderdata.deliveryDate  = null;
					orderdata.discount = 1;
					retryGetAvailableDate();
					//resetDeliveryDates();
				}
				updatePrice();
				EventCenter.instance.event(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE);
				
			}
		}
		
		public function setData(data:*):void
		{
			orderdata = data;
			this.numindex.text = data.itemSeq.toString();
			
			this.fileimg.skin = data.conponent.thumbnailsPath;

			this.circle.visible = false;
			this.rectangle.visible = false;
			
			var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderdata.orderItemSn);
			
			if(data.conponent.filename == "圆形灯箱产品")
				this.circle.visible = true;
			else
				this.rectangle.visible = true;
			
			
			//this.backsp.graphics.drawRect(0,0, 1260,86,OrderConstant.OUTPUT_COLOR[PaintOrderModel.instance.getManuFactureIndex(manucode)]);
			
			
			//data.orderItem_sn = data.item_seq.toString();
			//data.isUrgent = 0;
			//data.delivery_date = "2020-10-7";
			
			var size:Array = data.conponent.LWH.split("/");

			var picwidth:Number = parseFloat(size[0]);
			var picheight:Number = parseFloat(size[1]);

			if(picwidth > picheight)
			{
				this.fileimg.width = 155;					
				this.fileimg.height = 155/picwidth * picheight;
				
			}
			else
			{
				this.fileimg.height = 155;
				this.fileimg.width = 155/picheight * picwidth;
				
			}
			this.manufacName.text = PaintOrderModel.instance.getManufacturerNameBySn(data.orderItemSn);
			this.filenametxt.text = data.conponent.filename;
			
			this.mattext.text = data.conponent.prodName;
			
			
			this.picwidth.text = size[0];
			this.picheight.text = size[1];
			this.radius.text =  size[0];

			//this.proctext.text = data.techStr;
			
			//this.pricetext.text = data.item_number * parseFloat(data.item_priceSt) + "";
			
			var techstr:String =  "";
			if(data.conponent.procInfoList != null)
			{
				for(var i:int=0;i < data.conponent.procInfoList.length;i++)
					techstr += data.conponent.procInfoList[i].procDescription + "-";
			}
			
			this.proctext.text = techstr.substr(0,techstr.length - 1);
			
			//this.pricetext.text = (Number(data.item_priceStr) * Number(data.item_number)).toFixed(2);
			
			
			this.numtxt.text = data.itemNumber + "";
			
			resetDeliveryDates();
			
			updatePrice();
		}
		
		private function updatePrice():void
		{
			var rawprice:Number = Number(orderdata.itemPrice) * Number(orderdata.itemNumber);
			
			var disoucntprocessPrice:Number = orderdata.discountProcessPrice  * orderdata.itemNumber;
			var materialPrice:Number = orderdata.materialPrice * orderdata.itemNumber;
			
			//var nowprices:Number = parseFloat((disoucntprocessPrice + materialPrice).toFixed(1));
			
			
			
			if(orderdata.isUrgent == 1 || orderdata.deliveryDate  != null)
			{
				this.pricetext.text = (disoucntprocessPrice*orderdata.discount + materialPrice).toFixed(1);

			}
			
			else
				this.pricetext.text = rawprice.toFixed(1);
			if(Userdata.instance.isHidePrice())
				this.pricetext.text = "***";
			
		}
		
		public function resetDeliveryDates():void
		{
			for(var i:int=0;i < 5;i++)
			{
				//this["deltime" + i].visible = false;
				this["deltime" + i].selected = false;
				//this["timeback"+i].visible = false;
				this["gray"+i].visible = true;
			}
			
			var deliverydatas:Array = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList;
			
			var nextfivedays:Array = UtilTool.getNextFiveDays(PaintOrderModel.instance.currentDayStr + " 00:00:00");
			
			for(i=0;i < nextfivedays.length;i++)
			{
				
				
				
				//this["deltime" + i].label = nextfivedays[i] + "";
				//this["deltime" + i].visible = true;
				
				(this["deltime" + i] as Button).disabled = true;
				this["discount" + i].text = "1";
				for(var j:int=0;j < deliverydatas.length;j++)
				{
					if(deliverydatas[j].discount >= 1)
						this["deltime" + i].label = deliverydatas[j].discount + "";
					else
						this["deltime" + i].label = deliverydatas[j].discount*100 + "折";
					
					var datestr:String = UtilTool.getNextDayStr((deliverydatas[j].availableDate as String) + " 00:00:00");
					if(datestr ==  nextfivedays[i])
					{
						
						
						(this["deltime" + i] as Button).disabled = false;
						var discountprice:Number = getPayDicountStr(deliverydatas[j].discount);
						if(discountprice > 0)
						{
							(this["discount" + i] as Label).color = "#FF0000";
							this["discount" + i].text = "+" + getPayDicountStr(deliverydatas[j].discount);
						}
						else
						{
							(this["discount" + i] as Label).color = "#569356";
							this["discount" + i].text = "" + getPayDicountStr(deliverydatas[j].discount);
						}
						this["gray"+i].visible = false;

						break;

					}
				}
				
				if((this["deltime" + i] as Button).disabled && deliverydatas.length < 5)
				{
					deliverydatas.splice(i,0,0);
				}
				if(orderdata.deliveryDate  != null)
				{
					
					var deliverydate:String = UtilTool.getNextDayStr((orderdata.deliveryDate ) + " 00:00:00");

					if(deliverydate == nextfivedays[i] && orderdata.isUrgent != true)
					{
						this["deltime" + i].selected = true;
						//this["timeback"+i].visible = this["deltime"+i].selected;
					}
				}
				
			}
			

			this.urgentcheck.visible = PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate != null;
			
			this.urgentdiscount.visible = this.urgentcheck.visible;

			if(this.urgentcheck.visible)
			{
				var discountprice:Number = getPayDicountStr(PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate.discount);
				if(discountprice > 0)
				{
					this.urgentdiscount.color = "#FF0000";
					this.urgentdiscount.text = "￥+" + getPayDicountStr(deliverydatas[j].discount);
				}
				else
				{
					this.urgentdiscount.color = "#569356";
					this.urgentdiscount.text = "￥" + getPayDicountStr(deliverydatas[j].discount);
				}
				//this.urgentdiscount.text = getPayDicountStr(PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].urgentDate.discount);
				
			}
			
			this.urgentcheck.selected = orderdata.isUrgent == 1;
			if(this.urgentcheck.selected)
				this.urgentcheck.disabled = true;
			else
				this.urgentcheck.disabled = false;
			this.urgentback.visible = this.urgentcheck.selected;


		}
		private function countDownPayTime():void
		{
			if(orderdata != null)
			{
				if(orderdata.isUrgent == 1  ||  orderdata.deliveryDate  != null)
				{
					this.paycountdown.text = UtilTool.getCountDownString(orderdata.lefttime);
				}
				else if(orderdata.outtime)
					this.paycountdown.text = "支付超时";
				else
					this.paycountdown.text = "00:00";

			}
		}
		
		private function getPayDicountStr(discount:Number):Number
		{
			
			//if(discount < 1)
			//{
				if(orderdata.fixedDiscount)
					discount = 1;
				
				var disoucntprocessPrice:Number = orderdata.discountProcessPrice * discount * orderdata.itemNumber;
				var materialPrice:Number = orderdata.materialPrice * orderdata.itemNumber;
				
				var nowprices:Number = parseFloat((disoucntprocessPrice + materialPrice).toFixed(1));
				
				var rawprice:Number = Number(orderdata.itemPrice) * Number(orderdata.itemNumber);

				var discountprice:Number =  nowprices - parseFloat(rawprice.toFixed(1));
				return parseFloat(discountprice.toFixed(1));
				
				//return discount*100 + "折";
//			}
//			else if(discount == 1)
//			{
//				return discount + "";
//			}
//			else
//			{
//				return discount + "倍";
//			}
		}
	}
}
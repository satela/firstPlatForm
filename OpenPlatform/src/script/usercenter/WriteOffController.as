package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.CustomVo;
	import model.users.CustomerTransactionVo;
	
	import script.ViewManager;
	import script.usercenter.item.WriteOffOrderCell;
	
	import ui.orderList.WriteOffOrderPanelUI;
	
	import utils.UtilTool;
	
	public class WriteOffController extends Script
	{
		private var uiSkin:WriteOffOrderPanelUI;
		
		private var curpage:int = 1;
		
		private var totalPage:int = 1;
		private var dateInput:Object; 
		private var dateInput2:Object; 
		
		private var curCustomer:CustomVo;
		
		private var picList:Array;
		private var base64Arr:Array;
		private var excelData:Array = [];
		
		private var hasSelectedOrder:Object;
		private var param:Object;
		
		public function WriteOffController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as WriteOffOrderPanelUI;
						
			curCustomer = param as curCustomer;
			
			uiSkin.totalWriteMoney.text = curCustomer.balanceMoney.toFixed(2) + "元";
			
			uiSkin.orderList.itemRender = WriteOffOrderCell;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.orderList.repeatX = 1;
			uiSkin.orderList.spaceY = 2;
			
			uiSkin.orderList.renderHandler = new Handler(this, updateOrderList);
			uiSkin.orderList.selectEnable = false;
			uiSkin.orderList.array = [];
			
			//uiSkin.yearCombox.labels = "2019年,2020年,2021年,2022年,2023年,2024年,2025年";
			//uiSkin.monthCombox.labels = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"].join(",");
			
			//uiSkin.yearCombox.scrollBarSkin = "";
			
			uiSkin.orderList.mouseThrough = true;
			Laya.timer.frameLoop(1,this,updateDateInputPos);
			
			var curdate:Date = new Date();
			//var curmonth:int = (new Date()).getMonth();
			
			
			//uiSkin.yearCombox.selectedIndex = curyear - 2019;
			//uiSkin.monthCombox.selectedIndex = curmonth;
			var lastday:Date = new Date(curdate.getTime() - 24 * 3600 * 1000);
			
			var paramdata:String = "beginDate=" + UtilTool.formatFullDateTime(lastday,false) + " 00:00:00&endDate=" + UtilTool.formatFullDateTime(new Date(),false) + " 23:59:59&option=1&page=1&cleared=0&salerId=0&customerPayment=-1&userId=0&customerId=" + curCustomer.id;
			//if(curmonth + 1 < 10 )
			//	param = "begindate=" + curyear + "0" + (curmonth + 1) + "enddate=" + curyear + "0" + (curmonth + 1) + "&type=2&curpage=1";
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderRecordList+paramdata,this,onGetOrderListBack,null,null);
			//.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderRecordList + paramdata,this,onGetOrderListBack,null,null);
			//uiSkin.lastyearbtn.on(Event.CLICK,this,onLastYear);
			//uiSkin.nextyearbtn.on(Event.CLICK,this,onNextYear);
			
			//uiSkin.lastmonthbtn.on(Event.CLICK,this,onLastMonth);
			//uiSkin.nextmonthbtn.on(Event.CLICK,this,onNextMonth);
			
			
			uiSkin.lastpage.on(Event.CLICK,this,onLastPage);
			uiSkin.nextpage.on(Event.CLICK,this,onNextPage);
			
			
			
			uiSkin.selectMoney.text = "0元";
			//uiSkin.totalWriteMoney.text = "0元";
			
			
			uiSkin.orderList.on(Event.MOUSE_DOWN,this,onMouseDwons);
			
			uiSkin.orderList.on(Event.MOUSE_UP,this,onMouseUpHandler);
			uiSkin.selectall.on(Event.CLICK,this,onSelectAll);
			uiSkin.closeBtn.on(Event.CLICK,this,function(){
				ViewManager.instance.closeView(ViewManager.WRITE_OFF_ORDER_PANEL);
			});
			uiSkin.btnsearch.on(Event.CLICK,this,queryOrderList);
			
			EventCenter.instance.on(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.on(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.CHANGE_WRITEOFF_ORDER_SELECTED,this,changeSelectedOrder);

			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

			uiSkin.orderList.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.orderList.on(Event.MOUSE_OUT,this,resumeParentScroll);
			uiSkin.confirmBtn.on(Event.CLICK,this,onConfirmWriteOff);
			
			Laya.stage.on(Event.MOUSE_UP,this,onMouseUpHandler);
			
			EventCenter.instance.on(EventCenter.DELETE_ORDER_BACK,this,getOrderListAgain);
			hasSelectedOrder = {};
			
			this.initDateSelector();
		}
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
		}
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
		}
		private function onshowInputDate(viewname:String):void
		{
			//if(dateInput != null && (viewname == ViewManager.VIEW_ORDER_DETAIL_PANEL || viewname == ViewManager.VIEW_SELECT_PAYTYPE_PANEL || viewname == ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL || viewname == ViewManager.VIEW_CHANGEPWD ))
			if(ViewManager.instance.getTopViewName() == ViewManager.WRITE_OFF_ORDER_PANEL)
			{
				dateInput.hidden = false;
				dateInput2.hidden = false;
				
			}
		}
		
		private function onHideInputDate():void
		{
			if(dateInput != null)
			{
				dateInput.hidden = true;
				dateInput2.hidden = true;
				
			}
		}
		
		private function initDateSelector():void
		{
			var curdate:Date = new Date((new Date()).getTime() -  24 * 3600 * 1000);
			
			var lastdate:Date = new Date();
			
			//trace(UtilTool.formatFullDateTime(curdate,false));
			//trace(UtilTool.formatFullDateTime(nextmonth,false));
			
			//var curyear:int = (new Date()).getFullYear();
			//var curmonth:int = (new Date()).getMonth();
			
			
			dateInput = Browser.document.createElement("input");
			
			dateInput.style="filter:alpha(opacity=100);opacity:100;left:795px;top:240";
			
			dateInput.style.width = 222/Browser.pixelRatio;
			dateInput.style.height = 44/Browser.pixelRatio;
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else			
			
			dateInput.type ="date";
			dateInput.style.position ="absolute";
			dateInput.style.zIndex = 999;
			dateInput.style.color = "#003dc6";
			dateInput.style.border ="2px solid #003dc6";
			dateInput.style.borderRadius  ="5px";
			
			dateInput.value = UtilTool.formatFullDateTime(curdate,false);
			Browser.document.body.appendChild(dateInput);//添加到舞台
			
			dateInput.onchange = function(datestr):void
			{
				if(dateInput.value == "")
					return;
				var curdata:Date = new Date(dateInput.value);
				var nextdate:Date = new Date(dateInput2.value);
				
				if(nextdate.getTime() - curdata.getTime() > 30 * 24 * 3600 * 1000)
				{
					nextdate =  new Date(curdata.getTime() + 30 * 24 * 3600 * 1000);
					
					dateInput2.value = UtilTool.formatFullDateTime(nextdate,false);
				}
				else if(nextdate.getTime() - curdata.getTime() < 0 )
				{
					dateInput2.value = UtilTool.formatFullDateTime(curdata,false);
					
				}
				//trace(UtilTool.formatFullDateTime(curdata,false));
			}
			
			dateInput2 = Browser.document.createElement("input");
			
			dateInput2.style="filter:alpha(opacity=100);opacity:100;left:980px;top:240";
			
			dateInput2.style.width = 222/Browser.pixelRatio;
			dateInput2.style.height = 44/Browser.pixelRatio;
			dateInput2.style.color = "#003dc6";
			dateInput2.style.border ="2px solid #003dc6";
			dateInput2.style.borderRadius  ="5px";
			
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else			
			
			dateInput2.type ="date";
			dateInput2.style.position ="absolute";
			dateInput2.style.zIndex = 999;
			Browser.document.body.appendChild(dateInput2);//添加到舞台
			dateInput2.value = UtilTool.formatFullDateTime(lastdate,false);
			
			dateInput2.onchange = function(datestr):void
			{
				if(dateInput2.value == "")
					return;
				//trace("选择的日期：" + datestr);
				var curdata:Date = new Date(dateInput2.value);
				var lastdate:Date = new Date(dateInput.value);
				
				if(curdata.getTime() - lastdate.getTime() > 30 * 24 * 3600 * 1000)
				{
					lastdate =  new Date(curdata.getTime() - 30 * 24 * 3600 * 1000);
					
					dateInput.value = UtilTool.formatFullDateTime(lastdate,false);
				}
				else if(curdata.getTime() - lastdate.getTime() < 0 )
				{
					dateInput.value = UtilTool.formatFullDateTime(curdata,false);
					
				}
				
			}
		}
		
		private function updateDateInputPos():void
		{
			if(dateInput != null)
			{
				//verifycode.style.top = 548 - uiSkin.mainpanel.vScrollBar.value + "px";
				var pt:Point = uiSkin.ordertime.localToGlobal(new Point(uiSkin.ordertime.x,uiSkin.ordertime.y),true);
				
				var scaleNum:Number = Browser.clientWidth/1920;
				
				var offset:Number = 0;
				
				
				dateInput.style.width = scaleNum * 222/Browser.pixelRatio;
				dateInput.style.height = scaleNum * 44/Browser.pixelRatio;
				
				dateInput.style.fontSize = 24*scaleNum;
				dateInput2.style.fontSize = 24*scaleNum;
				
				
				
				dateInput2.style.width = scaleNum * 222/Browser.pixelRatio;
				dateInput2.style.height = scaleNum * 44/Browser.pixelRatio;
				
				
				dateInput.style.top = (pt.y - 70)*scaleNum + "px";
				dateInput.style.left = (pt.x + 95)*scaleNum +  "px";
				
				dateInput2.style.top = (pt.y - 70)*scaleNum + "px";
				dateInput2.style.left = (pt.x + 370)*scaleNum +  "px";
			}
			
		}
		
		
		private function onLastPage():void
		{
			if(curpage > 1 )
			{
				curpage--;
				getOrderListAgain();
			}
		}
		private function onNextPage():void
		{
			if(curpage < totalPage )
			{
				curpage++;
				getOrderListAgain();
			}
		}
		
		private function queryOrderList():void
		{
			curpage = 1;
			getOrderListAgain();
		}
		
		
		
		private function getOrderListAgain()
		{
			//var curdata:Date = new Date(dateInput2.value);
			//var lastdate:Date = new Date(dateInput.value);
			
			var param:String = "beginDate=" + dateInput.value + " 00:00:00&endDate=" + dateInput2.value + " 23:59:59&option=" + 1 + "&page=" + curpage;
			if(curCustomer != null)
				param +="&customerId=" + curCustomer.id;
			else
				param +="&customerId=-1";
			
			param +="&cleared=0&salerId=0&customerPayment=-1&userId=0";
				
			//if(curmonth + 1 < 10 )
			//	param = "begindate=" + curyear + "0" + (curmonth + 1) + "enddate=" + curyear + "0" + (curmonth + 1) + "&type=2&curpage=1";
			
			//if(uiSkin.monthCombox.selectedIndex + 1 >= 10)
			//	var param:String = "date=" + (2019 + uiSkin.yearCombox.selectedIndex) + (uiSkin.monthCombox.selectedIndex + 1) + "&curpage=" + curpage;
			//else
			//	 param = "date=" + (2019 + uiSkin.yearCombox.selectedIndex) +  "0" + (uiSkin.monthCombox.selectedIndex + 1) + "&curpage=" + curpage;
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderRecordList + param,this,onGetOrderListBack,null,null);
		}
		private function onMouseDwons(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
			
		}
		private function onMouseUpHandler(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
		}
		
		
		private function onGetOrderListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			if (data == null || data == "")
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var totalNum:int = parseInt(result.data.totalCount);
				totalPage = Math.ceil(totalNum/100);
				if(totalPage < 1)
					totalPage = 1;
				
//				uiSkin.ordertotalNum.text = totalNum + "";
//				if(result.data.totalAmount != null)
//					uiSkin.ordertotalMoney.text = result.data.totalAmount + "元";
//				else
//					uiSkin.ordertotalMoney.text = "0元";
//				
//				if(Userdata.instance.isHidePrice())
//					uiSkin.ordertotalMoney.text = "****";
				
				uiSkin.pagenum.text = curpage + "/" + totalPage;
				for(var i:int=0;i < result.data.orders.length;i++)
				{
					result.data.orders[i].selected = hasSelectedOrder.hasOwnProperty(result.data.orders[i].id);
					if(hasSelectedOrder.hasOwnProperty(result.data.orders[i].id))
						result.data.orders[i].writeOffMoney = hasSelectedOrder[result.data.orders[i].id];
					else
						result.data.orders[i].writeOffMoney = 0;
				}
				uiSkin.orderList.array = (result.data.orders as Array);
			}
			else
				ViewManager.showAlert("获取订单失败");
		}
		public function updateOrderList(cell:WriteOffOrderCell):void
		{
			cell.setData(cell.dataSource);
		}
		private function onSelectAll():void
		{
			
			var orderlist:Array = uiSkin.orderList.array;
			for(var i:int=0;i < orderlist.length;i++)
			{
				var orderdata:Object = orderlist[i];
				orderdata.selected = uiSkin.selectall.selected;
				
				if(orderdata && orderdata.selected)
				{
					if(!hasSelectedOrder.hasOwnProperty(orderdata.id))
					{
						var detail:Object = JSON.parse(orderdata.detail);
						
						var sellprice:Number = (detail.totalSalesPrice != null && detail.totalSalesPrice != "")?Number(detail.totalSalesPrice):Number(detail.moneyPaid);
						hasSelectedOrder[orderdata.id] = sellprice;
						orderdata.writeOffMoney = sellprice;
						
						//(uiSkin.orderList.cells[i] as WriteOffOrderCell).setWriteOffMoney(sellprice);
					}
				}
				else if(orderdata && !orderdata.selected)
				{
					if(hasSelectedOrder.hasOwnProperty(orderdata.id))
					{
						delete hasSelectedOrder[orderdata.id];
					}
				}
			}
			
			for(var i:int=0;i < uiSkin.orderList.cells.length;i++)
			{
				orderdata = (uiSkin.orderList.cells[i] as WriteOffOrderCell).orderdata;
				(uiSkin.orderList.cells[i] as WriteOffOrderCell).setSelected(uiSkin.selectall.selected);
				if(orderdata && hasSelectedOrder[orderdata.id] != null)
					(uiSkin.orderList.cells[i] as WriteOffOrderCell).setWriteOffMoney(hasSelectedOrder[orderdata.id]);
				else if(orderdata)
					(uiSkin.orderList.cells[i] as WriteOffOrderCell).setWriteOffMoney(0);

			}
			
			
			updateSelectedPrice();
		}
		
		private function changeSelectedOrder(orderdata:Object):void
		{
			if(hasSelectedOrder.hasOwnProperty(orderdata.id))
			{
				orderdata.selected = false;
				orderdata.writeOffMoney = 0;
				delete hasSelectedOrder[orderdata.id];

			}
			else
			{
				var total:Number = 0;
				for each(var price in hasSelectedOrder)
				{
					total += price;
				}
				if(total >= curCustomer.balance)
				{
					ViewManager.showAlert("已选订单金额已超过客户金额");
					return;
				}
				else
				{
					var detail:Object = JSON.parse(orderdata.detail);

					var sellprice:Number = (detail.totalSalesPrice != null && detail.totalSalesPrice != "")?Number(detail.totalSalesPrice):Number(detail.moneyPaid);
					//if(sellprice < (curCustomer.balanceMoney - total))
					orderdata.writeOffMoney = sellprice;
					//else
					//	orderdata.writeOffMoney = curCustomer.balanceMoney - total;
					orderdata.selected = true;
					
					hasSelectedOrder[orderdata.id] = orderdata.writeOffMoney;
					
				}
			}
			for(var i:int=0;i < uiSkin.orderList.cells.length;i++)
			{
				var orderdata1:Object = (uiSkin.orderList.cells[i] as WriteOffOrderCell).orderdata;
				
				if(orderdata1 != null && orderdata1.id == orderdata.id)
					(uiSkin.orderList.cells[i] as WriteOffOrderCell).setWriteOffMoney(orderdata.writeOffMoney);				
				
			}
			updateSelectedPrice();
		}
		
		private function updateSelectedPrice():void
		{
			var total:Number = 0;
			for each(var price in hasSelectedOrder)
			{
				total += price;
			}
			
			uiSkin.selectMoney.text = total.toFixed(2) + "元";
		}
		
		private function onConfirmWriteOff():void
		{
			if(curCustomer == null)
			{
				ViewManager.showAlert("未选择客户");
				return;
			}
			var total:Number = 0;
			for each(var price in hasSelectedOrder)
			{
				total += price;
			}
			if(total == 0)
			{
				ViewManager.showAlert("未选择销账订单");
				return;
			}
			if(total > curCustomer.balanceMoney)
			{
				ViewManager.showAlert("销账金额大于客户余额，请重新选择订单。");
				return;
			}
			var postdata:Array = [];
			for(var id:String in hasSelectedOrder)
				postdata.push(id);
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.writeOffOrders,this,writeOffback,JSON.stringify(postdata),"post");

		}

		private function writeOffback(data:*):void
		{
			if (data == null || data == "")
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				ViewManager.instance.closeView(ViewManager.WRITE_OFF_ORDER_PANEL);
				EventCenter.instance.event(EventCenter.UPDATE_CUSTOMER_BALANCE,result.data);

			}
		}
		public override function onDestroy():void
		{
			Laya.stage.off(Event.MOUSE_UP,this,onMouseUpHandler);
			Laya.timer.clearAll(this);
			if(dateInput != null)
			{
				Browser.document.body.removeChild(dateInput);//添加到舞台
				Browser.document.body.removeChild(dateInput2);//添加到舞台
			}
			EventCenter.instance.off(EventCenter.DELETE_ORDER_BACK,this,getOrderListAgain);
			
			EventCenter.instance.off(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.off(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.CHANGE_WRITEOFF_ORDER_SELECTED,this,changeSelectedOrder);

		}
	}
}
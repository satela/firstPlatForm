package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.CustomVo;
	import model.users.CustomerTransactionVo;
	
	import script.ViewManager;
	import script.usercenter.item.CustomerTransacCell;
	
	import ui.orderList.CustomerTransactionPanelUI;
	
	import utils.UtilTool;
	
	public class CustomerTransactController extends Script
	{
		private var uiSkin:CustomerTransactionPanelUI;
		
		private var curpage:int = 1;
		
		private var totalPage:int = 1;
		private var dateInput:Object; 
		private var dateInput2:Object; 
		
		private var dateInputCharge:Object; 

		private var curCustomer:CustomVo;
		
		private var picList:Array;
		private var base64Arr:Array;
		private var excelData:Array = [];
		
		private var pageSize:int = 30;
		public function CustomerTransactController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as CustomerTransactionPanelUI;
			
			//uiSkin.orderList.visible = false;
			//uiSkin.curCustomName.text = Userdata.instance.company;
			
			uiSkin.customListPanel.visible = false;

			uiSkin.curCustomName.editable = false;
			uiSkin.customerName.editable = false;
			uiSkin.showCustomList.on(Event.CLICK,this,function(){
				
				uiSkin.customListPanel.visible = !uiSkin.customListPanel.visible;
			})
			
			uiSkin.addChargePanel.visible = false;
			uiSkin.addChargeBtn.on(Event.CLICK,this,function(){
				
				if(curCustomer == null)
				{
					ViewManager.showAlert("请先选择客户");
					return;
				}
				uiSkin.addChargePanel.visible = true;
				uiSkin.customerName.text = curCustomer.customerName;
				onHideInputDate();
				dateInputCharge.hidden = false;

				
			});
			
			uiSkin.writeoffBtn.on(Event.CLICK,this,onWriteOffOrder);
			
			uiSkin.closeCharge.on(Event.CLICK,this,function(){
				
				uiSkin.addChargePanel.visible = false;
				dateInputCharge.hidden = true;
				onshowInputDate(null);
				
				
			});
			
			uiSkin.confirmAdd.on(Event.CLICK,this,confirmAddCharge);
			
			uiSkin.commentInput.maxChars = 20;
			
			uiSkin.orderList.itemRender = CustomerTransacCell;
			
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
			//var lastday:Date = new Date(curdate.getTime() - 24 * 3600 * 1000);
			
			//var param:String = "beginDate=" + UtilTool.formatFullDateTime(lastday,false) + " 00:00:00&endDate=" + UtilTool.formatFullDateTime(new Date(),false) + " 23:59:59&option=2&page=1";
			//if(curmonth + 1 < 10 )
			//	param = "begindate=" + curyear + "0" + (curmonth + 1) + "enddate=" + curyear + "0" + (curmonth + 1) + "&type=2&curpage=1";
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderRecordList,this,onGetOrderListBack,param,"post");
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderRecordList + param,this,onGetOrderListBack,null,null);
			
			//uiSkin.lastyearbtn.on(Event.CLICK,this,onLastYear);
			//uiSkin.nextyearbtn.on(Event.CLICK,this,onNextYear);
			
			//uiSkin.lastmonthbtn.on(Event.CLICK,this,onLastMonth);
			//uiSkin.nextmonthbtn.on(Event.CLICK,this,onNextMonth);
			
			
			uiSkin.lastpage.on(Event.CLICK,this,onLastPage);
			uiSkin.nextpage.on(Event.CLICK,this,onNextPage);
			
		
			
			uiSkin.paytype.selectedIndex = 0;
			
			uiSkin.paytype.on(Event.CHANGE,this,queryOrderList);
			
			uiSkin.orderList.on(Event.MOUSE_DOWN,this,onMouseDwons);
			
			uiSkin.orderList.on(Event.MOUSE_UP,this,onMouseUpHandler);
			
			
			uiSkin.btnsearch.on(Event.CLICK,this,queryOrderList);
			//uiSkin.exportExcel.on(Event.CLICK,this,exportExcel);
			
			EventCenter.instance.on(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.on(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
			
			uiSkin.orderList.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.orderList.on(Event.MOUSE_OUT,this,resumeParentScroll);
			
			Laya.stage.on(Event.MOUSE_UP,this,onMouseUpHandler);
			
			EventCenter.instance.on(EventCenter.SELECT_CUSTOMER,this,onSelectCustomer);
			EventCenter.instance.on(EventCenter.DELETE_CUSTOMER_TRANSACTION,this,getOrderListAgain);
			EventCenter.instance.on(EventCenter.CUSTOMER_LIST_INIT_SUCESS,this,onCustomerlistInitSucess);
			EventCenter.instance.on(EventCenter.UPDATE_CUSTOMER_BALANCE,this,updateCurCustomer);

			
			this.initDateSelector();
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
			if(ViewManager.instance.getTopViewName() == ViewManager.VIEW_FIRST_PAGE && !uiSkin.addChargePanel.visible)
			{
				dateInput.hidden = false;
				dateInput2.hidden = false;
				
			}
			if(uiSkin.addChargePanel.visible)
				dateInputCharge.hidden = false;

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
			
			dateInput.style.width = 222;///Browser.pixelRatio;
			dateInput.style.height = 44;///Browser.pixelRatio;
			
			
			
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
			
			dateInput2.style.width = 222;///Browser.pixelRatio;
			dateInput2.style.height = 44;///Browser.pixelRatio;
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
				
			dateInputCharge = Browser.document.createElement("input");
			
			dateInputCharge.style="filter:alpha(opacity=100);opacity:100;left:795px;top:240";
			
			dateInputCharge.style.width = 322;///Browser.pixelRatio;
			dateInputCharge.style.height = 44;///Browser.pixelRatio;
			
			
			
			dateInputCharge.type ="datetime-local";
			dateInputCharge.style.position ="absolute";
			dateInputCharge.style.zIndex = 999;
			dateInputCharge.style.color = "#003dc6";
			dateInputCharge.style.border ="2px solid #003dc6";
			dateInputCharge.style.borderRadius  ="5px";
			
			//trace("time:" + UtilTool.formatFullDateTime(curdate,true).replace(" ","T"));
			
			dateInputCharge.value = UtilTool.formatFullDateTime(curdate,true).replace(" ","T");
			Browser.document.body.appendChild(dateInputCharge);
			dateInputCharge.hidden = true;
		}
		
		private function updateDateInputPos():void
		{
			if(dateInput != null)
			{
				//verifycode.style.top = 548 - uiSkin.mainpanel.vScrollBar.value + "px";
				var pt:Point = uiSkin.ordertime.localToGlobal(new Point(uiSkin.ordertime.x,uiSkin.ordertime.y),true);
				
				var scaleNum:Number = Browser.clientWidth/1920;
				
				var offset:Number = 0;
				
				
				dateInput.style.width = scaleNum * 222;///Browser.pixelRatio;
				dateInput.style.height = scaleNum * 44;///Browser.pixelRatio;
				
				dateInput.style.fontSize = 24*scaleNum;
				dateInput2.style.fontSize = 24*scaleNum;
				
				
				
				dateInput2.style.width = scaleNum * 222;///Browser.pixelRatio;
				dateInput2.style.height = scaleNum * 44;///Browser.pixelRatio;
				
				
				dateInput.style.top = (pt.y - 121)*scaleNum + "px";
				dateInput.style.left = (pt.x + 65)*scaleNum +  "px";
				
				dateInput2.style.top = (pt.y - 121)*scaleNum + "px";
				dateInput2.style.left = (pt.x + 330)*scaleNum +  "px";
				
				 pt = uiSkin.ordertime.localToGlobal(new Point(uiSkin.getmoneyDate.x,uiSkin.getmoneyDate.y),true);
				 
				 dateInputCharge.style.width = scaleNum * 330;///Browser.pixelRatio;
				 dateInputCharge.style.height = scaleNum * 44;///Browser.pixelRatio;
				 
				 dateInputCharge.style.fontSize = 24*scaleNum;
				 dateInputCharge.style.fontSize = 24*scaleNum;
				 
				 dateInputCharge.style.top = (pt.y - 20)*scaleNum + "px";
				 dateInputCharge.style.left = (pt.x + 307)*scaleNum +  "px";
				 
				
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
		
		private function onCustomerlistInitSucess(custom:CustomVo):void
		{
			if(custom != null && curCustomer == null)
			{
				curCustomer = custom;
				uiSkin.curCustomName.text = custom.customerName + "(" + Constast.PAY_TYPE_NAME[custom.defaultPayment - 1] + ")";
				uiSkin.balanceTxt.text = "客户余额:" + curCustomer.balanceMoney.toFixed(2) + "元";
				getOrderListAgain();
			}
		}
		private function onSelectCustomer(custom:CustomVo):void
		{
			if(curCustomer != null && curCustomer.id == custom.id)
				return;
			
			curCustomer = custom;
			uiSkin.curCustomName.text = custom.customerName + "(" + Constast.PAY_TYPE_NAME[custom.defaultPayment - 1] + ")";
			uiSkin.balanceTxt.text = "客户余额:" + curCustomer.balanceMoney.toFixed(2) + "元";

			getOrderListAgain();
		}
		
		private function getOrderListAgain()
		{
			//var curdata:Date = new Date(dateInput2.value);
			//var lastdate:Date = new Date(dateInput.value);
			
			var param:String = "beginDate=" + dateInput.value + " 00:00:00&endDate=" + dateInput2.value + " 23:59:59&transactionType=" + uiSkin.paytype.selectedIndex + "&pageNo=" + curpage + "&pageSize=" + pageSize;
			if(curCustomer != null)
				param +="&customerId=" + curCustomer.id;
			//if(curmonth + 1 < 10 )
			//	param = "begindate=" + curyear + "0" + (curmonth + 1) + "enddate=" + curyear + "0" + (curmonth + 1) + "&type=2&curpage=1";
			
			//if(uiSkin.monthCombox.selectedIndex + 1 >= 10)
			//	var param:String = "date=" + (2019 + uiSkin.yearCombox.selectedIndex) + (uiSkin.monthCombox.selectedIndex + 1) + "&curpage=" + curpage;
			//else
			//	 param = "date=" + (2019 + uiSkin.yearCombox.selectedIndex) +  "0" + (uiSkin.monthCombox.selectedIndex + 1) + "&curpage=" + curpage;
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.collectionList + param,this,onGetOrderListBack,null,null);
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
				totalPage = Math.ceil(totalNum/pageSize);
				if(totalPage < 1)
					totalPage = 1;
				
				
				
				uiSkin.pagenum.text = curpage + "/" + totalPage;
				uiSkin.payMoney.text = result.data.receivableAccount;
				uiSkin.totalSellMoney.text = result.data.totalReceivableAccount;

				var arr:Array = [];
				for(var i:int=0;i < result.data.customerTransactions.length;i++)
				{
					var vo:CustomerTransactionVo = new CustomerTransactionVo(result.data.customerTransactions[i]);
					arr.push(vo);
					
				}
				uiSkin.orderList.array = arr;
			}
			else
				ViewManager.showAlert("获取流水失败");
		}
		public function updateOrderList(cell:OrderCheckListItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		
		
		private function confirmAddCharge():void
		{
			if(uiSkin.transactionNum.text == "")
			{
				ViewManager.showAlert("请填写流水号");
				dateInputCharge.hidden = true;
				return;				
			}
			if(uiSkin.getMoney.text == "")
			{
				ViewManager.showAlert("请填写收款金额");
				dateInputCharge.hidden = true;

				return;				
			}
			
			var params:Object = {};
			params.customerId = curCustomer.id;
			params.amount = uiSkin.getMoney.text;
			params.serialNo = uiSkin.transactionNum.text;
			params.channel = uiSkin.channel.selectedLabel;
			params.comment = uiSkin.commentInput.text;
			params.collectTime = dateInputCharge.value.replace("T"," ");
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addCollection,this,addcollectback,JSON.stringify(params),"post");
			
			
		}
		
		private function addcollectback(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				getOrderListAgain();
				uiSkin.addChargePanel.visible = false;
				dateInputCharge.hidden = true;
				onshowInputDate(null);
			}
		}
		
		private function onWriteOffOrder():void
		{
			if(curCustomer == null)
			{
				ViewManager.showAlert("请先选择客户");
				return;
			}
			ViewManager.instance.openView(ViewManager.WRITE_OFF_ORDER_PANEL,false,curCustomer);
		}
		
		private function updateCurCustomer(data:Object):void
		{
			if(curCustomer.id == data.id)
			{
				curCustomer.balance = data.balance;
				curCustomer.balanceMoney = parseFloat(curCustomer.balance);
				uiSkin.balanceTxt.text = "客户余额:" + curCustomer.balanceMoney.toFixed(2)+"元";
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
				Browser.document.body.removeChild(dateInputCharge);//添加到舞台
			}
			EventCenter.instance.off(EventCenter.DELETE_ORDER_BACK,this,getOrderListAgain);
			
			//EventCenter.instance.off(EventCenter.PAY_ORDER_SUCESS,this,onRefreshOrder);
			EventCenter.instance.off(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.off(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
			EventCenter.instance.off(EventCenter.SELECT_CUSTOMER,this,onSelectCustomer);
			EventCenter.instance.off(EventCenter.DELETE_CUSTOMER_TRANSACTION,this,getOrderListAgain);
			EventCenter.instance.off(EventCenter.CUSTOMER_LIST_INIT_SUCESS,this,onCustomerlistInitSucess);
			EventCenter.instance.off(EventCenter.UPDATE_CUSTOMER_BALANCE,this,updateCurCustomer);

		}
	}
}
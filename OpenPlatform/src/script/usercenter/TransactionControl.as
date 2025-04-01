package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	import script.usercenter.item.TransactionListItem;
	
	import ui.usercenter.TransactionPanelUI;
	
	import utils.UtilTool;
	
	public class TransactionControl extends Script
	{
		private var uiSkin:TransactionPanelUI;
		private var curpage:int = 1;
		
		private var totalPage:int = 1;
		private var dateInput:Object; 
		private var dateInput2:Object;
		
		public function TransactionControl()
		{
			super();
		}
		
		
		override public function onStart():void
		{
			uiSkin = this.owner as TransactionPanelUI;
			
			uiSkin.transactionlist.itemRender = TransactionListItem;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.transactionlist.repeatX = 1;
			uiSkin.transactionlist.spaceY = 5;
			
			uiSkin.transactionlist.renderHandler = new Handler(this, updateTransactList);
			uiSkin.transactionlist.selectEnable = false;
			uiSkin.transactionlist.array = [];
			//EventCenter.instance.on(EventCenter.PAY_ORDER_SUCESS,this,onRefreshOrder);
			
			uiSkin.prebtn.on(Event.CLICK,this,onLastPage);
			uiSkin.nextbtn.on(Event.CLICK,this,onNextPage);
			uiSkin.btnsearch.on(Event.CLICK,this,queryOrderList);

			uiSkin.transactionlist.on(Event.MOUSE_DOWN,this,onMouseDwons);
			
			uiSkin.transactionlist.on(Event.MOUSE_UP,this,onMouseUpHandler);
			uiSkin.transactionlist.on(Event.MOUSE_OVER,this,onMouseDwons);
			uiSkin.transactionlist.on(Event.MOUSE_OUT,this,onMouseUpHandler);
			
			Laya.stage.on(Event.MOUSE_UP,this,onMouseUpHandler);

			//uiSkin.yearCombox.scrollBarSkin = "";
			
			uiSkin.moneytxt.text = "--";
			
			uiSkin.transactionlist.mouseThrough = true;
			Laya.timer.frameLoop(1,this,updateDateInputPos);
			var curdate:Date = new Date();

			var lastday:Date = new Date(curdate.getTime() - 24 * 3600 * 1000);
			
			var param:String = "begindate=" + UtilTool.formatFullDateTime(lastday,false) + " 00:00:00&enddate=" + UtilTool.formatFullDateTime(new Date(),false) + " 23:59:59&type=0&curpage=1";
			//if(curmonth + 1 < 10 )
			//	param = "begindate=" + curyear + "0" + (curmonth + 1) + "enddate=" + curyear + "0" + (curmonth + 1) + "&type=2&curpage=1";
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.queryTransaction,this,onGetTransactionBack,param,"post");
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");

			this.initDateSelector();

		}
		private function getCompanyInfoBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				Userdata.instance.money = Number(result.balance);
				Userdata.instance.actMoney = Number(result.activity_balance);
				Userdata.instance.frezeMoney = Number(result.activity_locked_balance);
				
				uiSkin.moneytxt.text = Userdata.instance.money.toString() + "元";
				if(Userdata.instance.isHidePrice())
				{
					uiSkin.moneytxt.text = "****";
				}
			}
		}
		
		
		private function onMouseDwons(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
			
		}
		private function onMouseUpHandler(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
		}

		
		private function queryOrderList():void
		{
			curpage = 1;
			getOrderListAgain();
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
		
		private function getOrderListAgain()
		{
			var curdata:Date = new Date(dateInput2.value);
			var lastdate:Date = new Date(dateInput.value);
			
			var param:String = "begindate=" + dateInput.value + " 00:00:00&enddate=" + dateInput2.value + " 23:59:59&type=" +0 + "&curpage=" + curpage;
					
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.queryTransaction,this,onGetTransactionBack,param,"post");
		}
		
		private function onGetTransactionBack(data:Object):void
		{
			if (data == null || data == "")
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				var totalNum:int = result.total;
				totalPage = Math.ceil(totalNum/30);
				if(totalPage < 1)
					totalPage = 1;
				
				
				uiSkin.itemNum.text = totalNum + "";
				
				uiSkin.pagetxt.text = curpage + "/" + totalPage;
				uiSkin.transactionlist.array = (result.data as Array);
				
				uiSkin.payamount.text = result.outamount + "元";
				uiSkin.reatryamount.text = result.inamount + "元";

				
				if(Userdata.instance.isHidePrice())
				{
					uiSkin.payamount.text = "****";
					uiSkin.reatryamount.text = "****";

				}
				
			}
			else
				ViewManager.showAlert("获取账单失败");
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
			
			dateInput.style.width = 150/Browser.pixelRatio;
			dateInput.style.height = 20/Browser.pixelRatio;
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else			
			
			dateInput.type ="date";
			dateInput.style.position ="absolute";
			dateInput.style.zIndex = 999;
			dateInput.value = UtilTool.formatFullDateTime(curdate,false);
			Browser.document.body.appendChild(dateInput);//添加到舞台
			
			dateInput.onchange = function(datestr):void
			{
				if(dateInput.value == "")
					return;
				var curdata:Date = new Date(dateInput.value);
				var nextdate:Date = new Date(dateInput2.value);
				
				if(nextdate.getTime() - curdata.getTime() > 31 * 24 * 3600 * 1000)
				{
					nextdate =  new Date(curdata.getTime() + 31 * 24 * 3600 * 1000);
					
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
			
			dateInput2.style.width = 150/Browser.pixelRatio;
			dateInput2.style.height = 20/Browser.pixelRatio;
			
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
				
				if(curdata.getTime() - lastdate.getTime() > 31 * 24 * 3600 * 1000)
				{
					lastdate =  new Date(curdata.getTime() - 31 * 24 * 3600 * 1000);
					
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
				var pt:Point = uiSkin.ordertime.localToGlobal(new Point(uiSkin.ordertime.x,uiSkin.ordertime.y),true);
				
				var scaleNum:Number = Browser.clientWidth/1920;
				
				var offset:Number = 0;
				
				
				dateInput.style.width = scaleNum * 150/Browser.pixelRatio;
				dateInput.style.height = scaleNum * 20/Browser.pixelRatio;
				
				dateInput2.style.width = scaleNum * 150/Browser.pixelRatio;
				dateInput2.style.height = scaleNum * 20/Browser.pixelRatio;
				
				
				dateInput.style.top = (pt.y - 15)*scaleNum + "px";
				dateInput.style.left = (pt.x + 5+ offset)*scaleNum +  "px";
				
				dateInput2.style.top = (pt.y - 15)*scaleNum + "px";
				dateInput2.style.left = (pt.x + 190 + offset)*scaleNum +  "px";
				
			}
			
		}
		public function updateTransactList(cell:TransactionListItem):void
		{
			cell.setData(cell.dataSource);
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
			
		}
	}
}
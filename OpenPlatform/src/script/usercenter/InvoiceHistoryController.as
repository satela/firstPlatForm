package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Image;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	import script.usercenter.item.InvoiceHistoryCell;
	
	import ui.usercenter.InvoiceHistoryPanelUI;
	
	import utils.UtilTool;
	
	public class InvoiceHistoryController extends Script
	{
		private var uiSkin:InvoiceHistoryPanelUI;
		private var dateInput:Object; 
		private var dateInput2:Object; 
		
		public function InvoiceHistoryController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as InvoiceHistoryPanelUI;
			
			uiSkin.invoicelist.itemRender = InvoiceHistoryCell;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.invoicelist.repeatX = 1;
			uiSkin.invoicelist.spaceY = 2;
			
			uiSkin.invoicelist.renderHandler = new Handler(this, updateInvoiceList);
			uiSkin.invoicelist.selectEnable = false;
			uiSkin.invoicelist.array = [];
			
			uiSkin.closebtn.on(Event.CLICK,this,closeView);
			initDateSelector();
			
			uiSkin.dragimg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragimg.on(Event.MOUSE_UP,this,stopDragPanel);
			
			//var param:String= "bgnDate=2022-04-01 00:00:00&endDate=2022-05-31 00:00:00";
			Laya.timer.frameLoop(1,this,updateDateInputPos);

			EventCenter.instance.on(EventCenter.UPDATE_INVOICE_LIST,this,requestInvoiceList);

			
		}
		private function startDragPanel(e:Event):void
		{			
			
			(uiSkin.dragimg as Image).startDrag();//new Rectangle(0,0,Browser.width,Browser.height));
			e.stopPropagation();
		}
		private function stopDragPanel():void
		{
			(uiSkin.dragimg as Image).stopDrag();
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
				
				if(nextdate.getTime() - curdata.getTime() > 360 * 24 * 3600 * 1000)
				{
					nextdate =  new Date(curdata.getTime() + 360 * 24 * 3600 * 1000);
					
					dateInput2.value = UtilTool.formatFullDateTime(nextdate,false);
				}
				else if(nextdate.getTime() - curdata.getTime() < 0 )
				{
					dateInput2.value = UtilTool.formatFullDateTime(curdata,false);
					
				}
				requestInvoiceList();
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
			
			requestInvoiceList();

			dateInput2.onchange = function(datestr):void
			{
				if(dateInput2.value == "")
					return;
				//trace("选择的日期：" + datestr);
				var curdata:Date = new Date(dateInput2.value);
				var lastdate:Date = new Date(dateInput.value);
				
				if(curdata.getTime() - lastdate.getTime() > 360 * 24 * 3600 * 1000)
				{
					lastdate =  new Date(curdata.getTime() - 360 * 24 * 3600 * 1000);
					
					dateInput.value = UtilTool.formatFullDateTime(lastdate,false);
				}
				else if(curdata.getTime() - lastdate.getTime() < 0 )
				{
					dateInput.value = UtilTool.formatFullDateTime(curdata,false);
					
				}
				requestInvoiceList();
			}
		}
		
		private function updateDateInputPos():void
		{
			if(dateInput != null)
			{
				//verifycode.style.top = 548 - uiSkin.mainpanel.vScrollBar.value + "px";
				var pt:Point = uiSkin.ordertime.localToGlobal(new Point(uiSkin.ordertime.x,uiSkin.ordertime.y),true);
				
				var offset:Number = 0;
				if(Browser.width > Laya.stage.width)
					offset = (Browser.width - Laya.stage.width)/2;
				
				dateInput.style.top = (pt.y - 25)/Browser.pixelRatio + "px";
				dateInput.style.left = (pt.x + 15/Browser.pixelRatio + offset)/Browser.pixelRatio +  "px";
				
				dateInput2.style.top = (pt.y - 25)/Browser.pixelRatio + "px";
				dateInput2.style.left = (pt.x + 205 + offset)/Browser.pixelRatio +  "px";
				
				//trace("pos:" + pt.x + "," + pt.y);
				//verifycode.style.left = 950 -  uiSkin.mainpanel.hScrollBar.value + "px";
				
			}
			
		}
		
		private function requestInvoiceList()
		{
			var param:String = "bgnDate=" + dateInput.value + " 00:00:00&endDate=" + dateInput2.value + " 23:59:59";
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listInvoice ,this,listBack,param,"post");

		}
		
		private function listBack(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data);
			if(result.status == 0)
			{
				uiSkin.invoicelist.array = result.data;
			}
		}
		public function updateInvoiceList(cell:InvoiceHistoryCell):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_INVOICE_HISTORY_PANEL);
		}
		
		public override function onDestroy():void
		{
			
			if(dateInput != null)
			{
				Browser.document.body.removeChild(dateInput);//添加到舞台
				Browser.document.body.removeChild(dateInput2);//添加到舞台
			}
			EventCenter.instance.off(EventCenter.UPDATE_INVOICE_LIST,this,requestInvoiceList);

		}
		
	}
}
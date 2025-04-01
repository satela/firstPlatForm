package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.users.AddressVo;
	import model.users.FactoryBillData;
	
	import script.ViewManager;
	import script.usercenter.item.InvoiceDetailItem;
	import script.usercenter.item.InvoiceItemCell;
	
	import ui.usercenter.InvoiceManagerPanelUI;
	
	import utils.UtilTool;
	
	public class InvoiceManager extends Script
	{
		
		private var uiSkin:InvoiceManagerPanelUI;
		
		private var curpage:int = 1;
		
		private var totalPage:int = 1;
		private var dateInput:Object; 
		private var dateInput2:Object; 
		
		private var address:AddressVo;
		
		private var curbillList:Array;
		
		private var postAddress:String;
		
		public function InvoiceManager()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as InvoiceManagerPanelUI;
			
			uiSkin.invoicelist.itemRender = InvoiceItemCell;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.invoicelist.repeatX = 1;
			uiSkin.invoicelist.spaceY = 2;
			
			uiSkin.invoicelist.renderHandler = new Handler(this, updateInvoiceList);
			uiSkin.invoicelist.selectEnable = false;
			uiSkin.invoicelist.array = [];
			
			uiSkin.detaillist.itemRender = InvoiceDetailItem;
			
			//uiSkin.orderList.vScrollBarSkin = "";
			uiSkin.detaillist.repeatX = 1;
			uiSkin.detaillist.spaceY = 2;
			
			uiSkin.detaillist.renderHandler = new Handler(this, updateInvoiceDetailList);
			uiSkin.detaillist.selectEnable = false;
			uiSkin.detaillist.array = [];
			
			Laya.timer.frameLoop(1,this,updateDateInputPos);
			
			this.uiSkin.detailbox.visible = false;
			this.uiSkin.enterprizeInfoPanel.visible = false;
			
			this.uiSkin.companyInfoBtn.on(Event.CLICK,this,onShowEnterPrizeInfo);
			this.uiSkin.updateOK.on(Event.CLICK,this,onUpdateEnterPrizeInfo);
			
			this.uiSkin.detailBtn.on(Event.CLICK,this,onShowDetailPanel);
			this.uiSkin.closedetail.on(Event.CLICK,this,onCloseDetail);
			this.uiSkin.adressBtn.on(Event.CLICK,this,showAddressPanle);
			
			this.uiSkin.queryBtn.on(Event.CLICK,this,reuqestCostList);
			this.uiSkin.confirmInvoiceBtn.on(Event.CLICK,this,confirmRequestInvoice);
			
			this.uiSkin.invoiceHistory.on(Event.CLICK,this,showHistory);
			uiSkin.companyName.text = "";
			uiSkin.taxNumber.text = "";
			uiSkin.bankName.text = "";
			
			uiSkin.bankName.maxChars = 100;
			uiSkin.companyName.maxChars = 20;
			uiSkin.taxNumber.maxChars = 20;
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getInvoiceEnterInfo ,this,getEnterInfo,null,"post");

			this.initDateSelector();
			EventCenter.instance.on(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.on(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
			EventCenter.instance.on(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedAddress);
			EventCenter.instance.on(EventCenter.INVOICE_SELECTED_CHANGE,this,updateSummary);

		}
		
		private function getEnterInfo(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data);
			if(result.status == 0)
			{
				uiSkin.companyName.text = result.data[0].name;
				uiSkin.taxNumber.text = result.data[0].code;
				uiSkin.bankName.text = result.data[0].bank;
				postAddress = result.data[0].addr;
			}
		}
		
		private function showHistory():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_INVOICE_HISTORY_PANEL);
		}
		private function onShowEnterPrizeInfo():void
		{
			uiSkin.enterprizeInfoPanel.visible = true;
		}
		
		private function onUpdateEnterPrizeInfo():void
		{
			uiSkin.enterprizeInfoPanel.visible = false;

		}
		
		private function onShowDetailPanel():void
		{
			this.uiSkin.detailbox.visible = true;
			if(curbillList != null)
			{
				uiSkin.detaillist.array = curbillList;
			}
			onHideInputDate();
		}
		
		private function onCloseDetail():void
		{
			this.uiSkin.detailbox.visible = false;
			onshowInputDate("");
		}
		
		private function showAddressPanle():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_ADDRESS,false);
		}
		private function onshowInputDate(viewname:String):void
		{
			//if(dateInput != null && (viewname == ViewManager.VIEW_ORDER_DETAIL_PANEL || viewname == ViewManager.VIEW_SELECT_PAYTYPE_PANEL || viewname == ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL || viewname == ViewManager.VIEW_CHANGEPWD ))
			if(ViewManager.instance.getTopViewName() == ViewManager.VIEW_USERCENTER)
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
		
		public function updateInvoiceList(cell:InvoiceItemCell):void
		{
			cell.setData(cell.dataSource);
		}
		
		public function updateInvoiceDetailList(cell:InvoiceDetailItem):void
		{
			cell.setData(cell.dataSource);

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
				
				if(curdata.getTime() - lastdate.getTime() > 360 * 24 * 3600 * 1000)
				{
					lastdate =  new Date(curdata.getTime() - 360 * 24 * 3600 * 1000);
					
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
				
				var offset:Number = 0;
				if(Browser.width > Laya.stage.width)
					offset = (Browser.width - Laya.stage.width)/2;
				
				dateInput.style.top = (pt.y - 15)/Browser.pixelRatio + "px";
				dateInput.style.left = (pt.x + 15/Browser.pixelRatio + offset)/Browser.pixelRatio +  "px";
				
				dateInput2.style.top = (pt.y - 15)/Browser.pixelRatio + "px";
				dateInput2.style.left = (pt.x + 205 + offset)/Browser.pixelRatio +  "px";
				
				//trace("pos:" + pt.x + "," + pt.y);
				//verifycode.style.left = 950 -  uiSkin.mainpanel.hScrollBar.value + "px";
				
			}
			
		}
		
		private function reuqestCostList():void
		{
			//var curdata:Date = new Date(dateInput2.value);
			//var lastdate:Date = new Date(dateInput.value);
			
			var param:String = "bgnDate=" + dateInput.value + " 00:00:00&endDate=" + dateInput2.value + " 23:59:59";
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDailyCost ,this,getBillBack,param,"post");

		}
		
		private function getBillBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data);
			if(result.status == 0)
			{
				curbillList = result.data;
				
				var billarr:Array = result.data;
				var facData:Object = {};
				var arr:Array = [];
				for(var i:int=0;i < billarr.length;i++)
				{
					if(facData.hasOwnProperty(billarr[i].fc_id))
					{
						facData[billarr[i].fc_id].amount += parseFloat(billarr[i].fct_amount);
					}
					else
					{
						var billdata:FactoryBillData = new FactoryBillData();
						billdata.fcId = billarr[i].fc_id;
						billdata.fcName = billarr[i].fc_name;
						billdata.amount = parseFloat(billarr[i].fct_amount);
						billdata.startTime = dateInput.value;
						billdata.endTime = dateInput2.value;

						facData[billarr[i].fc_id] = billdata;
						arr.push(billdata);
					}
				}
				uiSkin.invoicelist.array = arr;
				Laya.timer.frameOnce(2,this,updateSummary);
			}
		}
		
		private function updateSummary():void
		{
			var arr:Array = uiSkin.invoicelist.array;
			var selectInvoice:Array = [];
			var amount:Number = 0;
			for(var i:int=0;i < arr.length;i++)
			{
				var invoicedata:FactoryBillData = arr[i] as FactoryBillData;
				if(invoicedata != null && invoicedata.selected)
				{
					selectInvoice.push(invoicedata);
					amount += invoicedata.amount;
				}
				
			}
			uiSkin.invoiceNum.text = selectInvoice.length + "";
			uiSkin.totalMoney.text = amount.toFixed(1);
		}
		private function confirmRequestInvoice():void
		{
			if(uiSkin.companyName.text == "" || uiSkin.taxNumber.text == "" || uiSkin.bankName.text == "")
			{
				ViewManager.showAlert("请填写企业信息");
				onShowEnterPrizeInfo();
				return;
			}
			if(postAddress == null || postAddress == "")
			{
				ViewManager.showAlert("请选择邮寄地址");
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_ADDRESS);
				return;

			}
			if(uiSkin.invoicelist.array == null || uiSkin.invoicelist.array.length == 0)
			{
				return;
			}
			var arr:Array = uiSkin.invoicelist.array;
			var selectInvoice:Array = [];
			var amount:Number = 0;
			for(var i:int=0;i < arr.length;i++)
			{
				var invoicedata:FactoryBillData = arr[i] as FactoryBillData;
				if(invoicedata != null && invoicedata.selected)
				{
					selectInvoice.push(invoicedata);
					amount += invoicedata.amount;
				}
				
			}
			if(selectInvoice.length == 0)
			{
				ViewManager.showAlert("未选择任何需要申请的发票");
				return;
			}
			var tips = "请确认发票信息："+ "企业名称：" + uiSkin.companyName.text + "，企业纳税号：" + uiSkin.taxNumber.text + "，企业开户行：" + uiSkin.bankName.text + "，发票邮寄地址：" +
				        postAddress + "，发票总金额：" + amount.toFixed(1) + "元";
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:tips,caller:this,callback:confirmOpen});
			
			

		}
		private function confirmOpen(b:Boolean):void
		{
			if(b)
			{
				var enterinfo:String = "";
				enterinfo += "name=" + uiSkin.companyName.text + "&addr=" + postAddress + "&bank=" + uiSkin.bankName.text + "&code=" + uiSkin.taxNumber.text;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateInvoiceEnterInfo ,this,updateInfoBack,enterinfo,"post");
			}
		}
		private function updateInfoBack(data:*):void
		{
					
			var result:Object = JSON.parse(data);
			if(result.status == 0)
			{
				var arr:Array = uiSkin.invoicelist.array;
				var selectManu:String = "";
				var amount:Number = 0;
				var begindate:String = "";
				var enddate:String = "";
				for(var i:int=0;i < arr.length;i++)
				{
					var invoicedata:FactoryBillData = arr[i] as FactoryBillData;
					if(invoicedata != null && invoicedata.selected)
					{
						begindate = invoicedata.startTime;
						enddate = invoicedata.endTime;
						selectManu += invoicedata.fcId + ",";
					}
					
				}
				var param = "idList=" + selectManu.substr(0,selectManu.length-1) + "&bgnDate=" + begindate + "&endDate=" + enddate;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.applyInvoice ,this,applyBack,param,"post");
			}
		}
		private function applyBack(data:*):void
		{
					
			var result:Object = JSON.parse(data);
			if(result.status == 0)
			{
				ViewManager.showAlert("申请成功，请等待开票");
				reuqestCostList();
			}
		}
		private function onSelectedAddress(data:AddressVo):void
		{
			address = data;
			postAddress = address.addressDetail;
			//trace(data.addressDetail);
		}
		
		public override function onDestroy():void
		{
			Laya.timer.clearAll(this);
			
			if(dateInput != null)
			{
				Browser.document.body.removeChild(dateInput);//添加到舞台
				Browser.document.body.removeChild(dateInput2);//添加到舞台
			}
			EventCenter.instance.off(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedAddress);
			EventCenter.instance.off(EventCenter.INVOICE_SELECTED_CHANGE,this,updateSummary);

			EventCenter.instance.off(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputDate);
			EventCenter.instance.off(EventCenter.OPEN_PANEL_VIEW,this,onHideInputDate);
		}
		
	}
}
package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	
	import ui.usercenter.InvoiceHistoryItemUI;
	
	public class InvoiceHistoryCell extends InvoiceHistoryItemUI
	{
		private  var invoicedata:Object;
		public function InvoiceHistoryCell()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			this.invoicedata = data;
//			this.invoicedata.isFinished = 1;
//			this.invoicedata.downloadInfo = "https://www.baidu.com";
//			this.invoicedata.isDigitalInvoice = true;
			
			this.companyname.text = data.invoiceName;
			this.addr.text = data.customerAddr;
			this.bank.text = data.customerBankInfo;
			this.statetxt.text = ["开票中","开票成功","开票失败"][data.isFinished];
			this.amounttxt.text = "￥" + data.invoiceAmount + "元";
			if(data.isFinished == 1 && data.isDigitalInvoice)
			{
				this.loadtxt.visible= true;
				this.loadtxt.on(Event.CLICK,this,onDownLoad);
			}
			else
			{
				this.loadtxt.visible= false;
			}
			
			this.cancetxt.visible = data.isFinished == 2;
			this.cancetxt.on(Event.CLICK,this,onCancelInvoice);

		}
		
		private function onDownLoad():void
		{
			Browser.window.open("about:self","_blank").location.href  = this.invoicedata.downloadInfo;

		}
		
		private function onCancelInvoice():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.cancelInvoice ,this,cancelInvoiceBack,"id=" + invoicedata.requestNo,"post");
		}
		
		private function cancelInvoiceBack(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(result.status== 0)
			{
				EventCenter.instance.event(EventCenter.UPDATE_INVOICE_LIST);

			}
		}
	}
}
package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.users.FactoryBillData;
	
	import ui.usercenter.InvoiceItemUI;
	
	public class InvoiceItemCell extends InvoiceItemUI
	{
		public var billData:FactoryBillData;
		public function InvoiceItemCell()
		{
			super();
		}
		
		public function setData(data:FactoryBillData):void
		{
			this.manufacture.text = data.fcName;
			this.datetxt.text = data.startTime + "至" + data.endTime;
			this.money.text = "￥" + data.amount.toFixed(1) + "元";
			this.statetxt.text = "待开票";
			this.selcheck.selected = true;
			
			this.selcheck.on(Event.CHANGE,this,changeSel);
			
			billData = data;
			billData.selected = true;
		}
		
		public function changeSel():void
		{
			billData.selected = this.selcheck.selected;
			EventCenter.instance.event(EventCenter.INVOICE_SELECTED_CHANGE);

		}
	}
}
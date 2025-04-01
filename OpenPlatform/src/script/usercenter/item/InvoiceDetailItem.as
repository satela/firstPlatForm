package script.usercenter.item
{
	import flashx.textLayout.operations.PasteOperation;
	
	import model.users.FactoryBillData;
	
	import ui.usercenter.InvoiceDailyItemUI;
	
	public class InvoiceDetailItem extends InvoiceDailyItemUI
	{
		public function InvoiceDetailItem()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			this.manufacture.text = data.fc_name;
			this.timetxt.text = data.fct_date.split(" ")[0];
			this.money.text = "￥" + data.fct_amount +"元";
			this.state.text = ["未开票","开票中","已开票"][parseInt(data.fct_state)];
			this.state.color = ["#DD0000","#223344","#00FF00"][parseInt(data.fct_state)];
		}
	}
}
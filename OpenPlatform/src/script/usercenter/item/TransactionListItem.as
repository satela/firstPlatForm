package script.usercenter.item
{
	import model.Constast;
	import model.Userdata;
	
	import ui.usercenter.TransactionItemUI;
	
	public class TransactionListItem extends TransactionItemUI
	{
		public function TransactionListItem()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			this.transtype.text = Constast.TYPE_NAME[data.type];
			this.transtime.text = data.date;
			
			this.amounttxt.text = data.amount + "";
			
			if(Userdata.instance.isHidePrice())
				this.amounttxt.text = "****";
			
			this.orderinfo.text = "";
			if(data.orid != "0")
				this.orderinfo.text = "订单号:" + data.orid;
		}
	}
}
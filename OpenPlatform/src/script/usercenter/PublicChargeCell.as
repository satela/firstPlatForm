package script.usercenter
{
	import ui.usercenter.PublicChargeRecordItemUI;
	
	public class PublicChargeCell extends PublicChargeRecordItemUI
	{
		public function PublicChargeCell()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			this.chargemoney.text = data.checkAmount + "";
			
			this.transfermoney.text = data.amount + "";
			this.confirmtime.text = data.logDate + "";
			if(data.status.toString() == "0")
				this.chargetime.text = "";
			else
				this.chargetime.text = data.checkDate + "";
			if(data.status.toString() == "0")
			{
				this.state.text = "待确认";
				this.state.color = "#223322";
			}
			else if(data.status.toString() == "1")
			{
				this.state.text = "已确认";
				this.state.color = "#003dc6";
			}
			if(data.status.toString() == "2")
			{
				this.state.text = "已拒绝";
				this.state.color = "#FF1122";
			}
			//this.state.text = data.rar_date + "";
		}
		
		
	}
}
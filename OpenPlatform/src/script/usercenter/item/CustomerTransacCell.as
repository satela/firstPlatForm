package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.users.CustomerTransactionVo;
	
	import script.ViewManager;
	
	import ui.usercenter.items.CustomerTransacItemUI;
	
	public class CustomerTransacCell extends CustomerTransacItemUI
	{
		private var transactionVo:CustomerTransactionVo;
		public function CustomerTransacCell()
		{
			super();
			this.deleteBtn.on(Event.CLICK,this,onDeleteTransaction);
			//this.xiaozhang.on(Event.CLICK,this,onWriteOff);
		}
		
		public function setData(data:CustomerTransactionVo):void
		{
			transactionVo = data;
			
			this.customerNamelbl.text = transactionVo.customerName;
			this.transacNum.text = transactionVo.transactionSn;
			this.transacType.text = transactionVo.transactionTypeName;
			this.transactDate.text = transactionVo.transactionTime;
			this.money.text = transactionVo.amount;
			this.transactName.text = transactionVo.transactionChannel;
			this.userNamelbl.text = transactionVo.userName;
			this.commentlbl.text = transactionVo.comment;
			
			this.deleteBtn.visible = transactionVo.transactionType == "2";
		}
		
		private function onWriteOff():void
		{
			ViewManager.instance.openView(ViewManager.WRITE_OFF_ORDER_PANEL,false,transactionVo);
		}
		private function onDeleteTransaction():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除该条收款记录吗？",caller:this,callback:confirmDelete});
		}
		private function confirmDelete(b:Boolean):void
		{
			if(b)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteCollection,this,deletecollectback,JSON.stringify({"id":transactionVo.id}),"post");

			}
		}
		private function deletecollectback(data:*):void
		{
						
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.DELETE_CUSTOMER_TRANSACTION);
			}
		}
	}
}
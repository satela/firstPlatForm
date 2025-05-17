package script.usercenter.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import ui.usercenter.WriteOffOrderItemUI;
	
	public class WriteOffOrderCell extends WriteOffOrderItemUI
	{
		public var orderdata:Object;

		public function WriteOffOrderCell()
		{
			super();
			this.selectBox.on(Event.CLICK,this,changeSelected);
		}
		
		public function setData(data:Object):void
		{
			orderdata = data;
			//var orderdetal:Object = JSON
			this.orderid.text = orderdata.id;
			this.ordertime.text = orderdata.createdAt;
			
			this.selectBox.selected = orderdata.selected;
			
			try
			{
				var detail:Object = JSON.parse(orderdata.detail);
				
				this.sellPrice.text = (detail.totalSalesPrice != null && detail.totalSalesPrice != "")?detail.totalSalesPrice:Number(detail.moneyPaid).toFixed(2);
				
				this.productnum.text = detail.orderItemList.length + "";
				
				this.WriteoffMoney.text = orderdata.writeOffMoney.toFixed(2);
				this.unWriteOffMoney.text = (parseFloat(this.sellPrice.text) - orderdata.writeOffMoney).toFixed(2);
				
			}
			catch(e)
			{
				
			}
			
			
		}
		
		private function changeSelected():void
		{
			EventCenter.instance.event(EventCenter.CHANGE_WRITEOFF_ORDER_SELECTED,orderdata);
		}
		public function setWriteOffMoney(money:Number):void
		{
			orderdata.writeOffMoney = money;
			this.WriteoffMoney.text = money.toFixed(2);
			this.unWriteOffMoney.text = (parseFloat(this.sellPrice.text) - money).toFixed(2);
		}
		public function setSelected(sel:Boolean):void
		{
			if(orderdata != null)
			{
				this.selectBox.selected = sel;
				orderdata.selected = sel;
				if(sel)
				{
					setWriteOffMoney(Number(this.sellPrice.text));
				}
				else
					setWriteOffMoney(0);
			}
		}
	}
}
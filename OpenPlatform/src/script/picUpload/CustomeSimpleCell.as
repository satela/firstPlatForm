package script.picUpload
{
	import laya.events.Event;
	
	import model.Constast;
	import model.users.CustomVo;
	
	import ui.inuoView.items.CustomPicCellUI;
	
	public class CustomeSimpleCell extends CustomPicCellUI
	{
		private var customerVo:CustomVo;
		public function CustomeSimpleCell()
		{
			super();
			this.btmLine.visible = false;
			this.on(Event.MOUSE_OVER,this,function(){
				this.btmLine.visible = true;
				
			});
			
			this.on(Event.MOUSE_OUT,this,function(){
				this.btmLine.visible = false;
				
			});
			
		}
		
		public function setData(data:CustomVo):void
		{
			customerVo = data;
			this.customName.text = customerVo.customerName;
			if(parseInt(customerVo.id) > 0)
			{
				this.customName.text += "(" + Constast.PAY_TYPE_NAME[customerVo.defaultPayment - 1] + ")";
			}
			this.phoneNum.text = customerVo.mobileNumber;
		}
	}
}
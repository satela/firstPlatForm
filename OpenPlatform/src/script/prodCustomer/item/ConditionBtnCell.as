package script.prodCustomer.item
{
	import laya.events.Event;
	
	import model.prodCustomerModel.ProdCondtionVo;
	
	import ui.prodCustom.ConditionButtonUI;
	
	public class ConditionBtnCell extends ConditionButtonUI
	{
		private var conditionVo:ProdCondtionVo;
		public function ConditionBtnCell()
		{
			super();
		}
		
		public function setData(cond:ProdCondtionVo):void
		{
			conditionVo = cond;
			
			this.btn.label = cond.lblName;
			
			this.btn.on(Event.CLICK,this,function(){
				
				conditionVo.selected =  !conditionVo.selected;
				this.btn.selected = conditionVo.selected;
			});
		}
	}
}
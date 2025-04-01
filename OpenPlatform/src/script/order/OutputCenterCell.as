package script.order
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.orderModel.OrderConstant;
	import model.users.FactoryInfoVo;
	
	import ui.order.OutPutCenterUI;
	
	public class OutputCenterCell extends OutPutCenterUI
	{
		private var factoryVo:FactoryInfoVo;
		public function OutputCenterCell(factdata:FactoryInfoVo,index:int)
		{
			super();
			
			factoryVo = factdata;
			//checkselect.on(Event.CHANGE,this,onSelectFactory);
			checkselect.selected = true;
			
			qqContact.on(Event.CLICK,this,onClickOpenQQ);
			factorytxt.text = factdata.name;
			holaday.text = "";
			outicon.skin = "commers/" + OrderConstant.OUTPUT_ICON[index];
			holaday.visible = factdata.promotion_desc != "";
			if(factdata.promotion_desc != "")
			{
				holaday.text = "(" + factdata.promotion_desc + ")";
			}
			this.on(Event.CLICK,this,onSelectFactory);
		}
		
		private function onClickOpenQQ():void
		{
			window.open('tencent://message/?uin=10987654321');
		}
		
		private function onSelectFactory():void
		{
			checkselect.selected = !checkselect.selected;
			factoryVo.isSelected = checkselect.selected;
			
			EventCenter.instance.event(EventCenter.UPDATE_SELECTED_FACTORY_PRODCATEGORY);
		}
		
	}
}
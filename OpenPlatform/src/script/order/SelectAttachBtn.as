package script.order
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.orderModel.AttchCatVo;
	
	import ui.order.TabChooseBtnUI;
	
	public class SelectAttachBtn extends TabChooseBtnUI
	{
		public var attachCatVo:AttchCatVo;
		public function SelectAttachBtn()
		{
			super();
		}
		
		public function setData(matName:Object):void
		{
			attachCatVo = matName as AttchCatVo;
			this.selbtn.label = attachCatVo.accessory_name;
			
			var textwdth:int = this.selbtn.text.textWidth + 40;
			
			this.width = textwdth;
			
			this.selbtn.width = textwdth;
			
			this.selbtn.on(Event.DOUBLE_CLICK,this,onSelectSure);
			this.selfIcon.visible= attachCatVo.is_belongtoClient;
			//this.selbtn.selected = false;
			//this.selbtn.on(Event.CLICK,this,ShowSelected);
		}
		
		private function onSelectSure():void
		{
			EventCenter.instance.event(EventCenter.ADD_TECH_ATTACH,attachCatVo);

		}
		public function ShowSelected(sel:Boolean):void
		{
			this.selbtn.selected = sel;
			
		}
	}
}
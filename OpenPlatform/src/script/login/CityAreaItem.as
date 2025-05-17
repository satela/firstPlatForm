package script.login
{
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.users.CityAreaVo;
	
	import ui.login.CityAreaItemUI;
	
	public class CityAreaItem extends CityAreaItemUI
	{
		public var areaVo:Object;
		public function CityAreaItem()
		{
			super();
//			if(typeof(Browser.window.orientation) != "undefined")
//			{
//				this.width = 300;
//			}
//			else
//			{
//				this.width = 252;
//
//			}
			this.on(Event.MOUSE_OVER,this,onMouseOver);
			this.on(Event.MOUSE_OUT,this,onMouseOut);
			bg.visible = false;

		}
		
		private function onMouseOver():void
		{
			bg.visible = true;
		}
		private function onMouseOut():void
		{
			bg.visible = false;
		}
		public function setData(areavo:Object):void
		{
			areaVo = areavo;
			productname.text = areaVo.areaName;
		}
	}
}
package script.uiTool
{
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Mouse;
	
	public class BtnMouseCusor extends Script
	{
		private var uiSkin:Sprite;
		
		public function BtnMouseCusor()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiSkin = this.owner as Sprite;
			
			uiSkin.on(Event.MOUSE_OVER,this,function(){
				
				Mouse.cursor = "hand";
				
			});
			uiSkin.on(Event.MOUSE_OUT,this,function(){
				
				Mouse.cursor = "auto";
				
			});
		}
	}
}
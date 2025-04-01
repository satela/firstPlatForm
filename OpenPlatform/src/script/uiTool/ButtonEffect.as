package script.uiTool
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Mouse;
		
	public class ButtonEffect extends Script
	{
		private  var uiSkin:Button;
		public function ButtonEffect()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiSkin = this.owner as Button;
			
			uiSkin.on(Event.MOUSE_OVER,this,function(){
				
				Mouse.cursor = "hand";
				
			});
			
			uiSkin.on(Event.MOUSE_OUT,this,function(){
				
				Mouse.cursor = "auto";
				uiSkin.scaleX = 1;
				uiSkin.scaleY = 1;

			});
			
			uiSkin.on(Event.MOUSE_DOWN,this,function(){
				
				uiSkin.scaleX = 0.8;
				uiSkin.scaleY = 0.8;

				
			});
			
			uiSkin.on(Event.MOUSE_UP,this,function(){
				
				uiSkin.scaleX = 1;
				uiSkin.scaleY = 1;
				
			});
			
			
			
		}
	}
}
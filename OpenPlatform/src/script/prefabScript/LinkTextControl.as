package script.prefabScript
{
	//import flash.ui.MouseCursor;
	
	import laya.components.Script;
	import laya.display.Text;
	import laya.events.Event;
	import laya.utils.Mouse;
	
	import model.Constast;
	
	public class LinkTextControl extends Script
	{
		private var txt:Text;
		
		/** @prop {name:undercolor,tips:"下划线颜色",type:String}*/
		//public var undercolor:String = "#222222";
		/** @prop {name:txttype,tips:"类型",type:int}*/
		public var txttype:int = 0;//0 有下划线 1 无下划线
		public var ypos:Number;
		public function LinkTextControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			txt = this.owner as Text;
			if(txttype == 0)
			{
				txt.underline = true;
				txt.underlineColor = Constast.CMYK_GREEN;
			}
			ypos = txt.y;
			
			txt.on(Event.MOUSE_OVER,this,onMouseOverHandler);
			txt.on(Event.MOUSE_OUT,this,onMouseOutHandler);
			txt.on(Event.MOUSE_DOWN,this,onMouseDownHandler);
			txt.on(Event.CLICK,this,onMouseClickHandler);

		}
		
		private function onMouseClickHandler():void
		{
			Mouse.cursor = "auto";
		}
		private function onMouseDownHandler():void
		{
			if(txttype == 1)
			{
				txt.color = "#74F79B";
			}
		}
		private function onMouseOutHandler():void
		{
			// TODO Auto Generated method stub
			Mouse.cursor = "auto";
			if(txttype == 1)
			{
				txt.y = ypos;
				txt.color = "#EDFFEC";
			}
		}
		
		private function onMouseOverHandler():void
		{
			// TODO Auto Generated method stub
			Mouse.cursor = "hand";
			if(txttype == 1)
			{
				txt.y = ypos - 1;
				txt.color = "#FFFFFF";
			}
			
		}
		public override function onDestroy():void
		{
			Mouse.cursor = "auto";
		}
	}
}
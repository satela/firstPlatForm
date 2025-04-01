package script.uiTool
{
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.GlowFilter;
	import laya.ui.Button;
	import laya.utils.Mouse;
	
	public class GlowButton extends Script
	{
		private var uiView:Sprite;
		
		private var glowfilter:GlowFilter;
		
		public var offsetx:Number;
		public var offsety:Number;
		public var glowColor:String;
		public var blur:int;
		
		/** @prop {name:glowColor,tips:"发光颜色",type:String}*/
		//public var glowColor:String = "#223333";//
		
		/** @prop {name:blur,tips:"强度",type:int}*/
		//public var blur:int = "#223333";//
		
		/** @prop {name:offsetx,tips:"横向偏移",type:int}*/
		//public var offsetx:int = 2;//
		
		/** @prop {name:offsety,tips:"纵向偏移",type:int}*/
		//public var offsety:int = 2;//
		
		public function GlowButton()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiView = this.owner as Sprite;
			glowfilter= new GlowFilter(glowColor,blur,offsetx,offsety);
			uiView.on(Event.MOUSE_OVER,this,function(){
				Mouse.cursor = "hand";
				uiView.filters = [glowfilter];
			});
			
			uiView.on(Event.MOUSE_OUT,this,function(){
				Mouse.cursor = "auto";
				uiView.filters = null;
			});
			
		}
	}
}
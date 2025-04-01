package script.uiTool
{
	import laya.components.Script;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.HBox;

	public class AvgLayHBox extends Script
	{
		private var uiView:HBox;
		
		private var lastwidth:Number = 0;
		
		public function AvgLayHBox()
		{
			super();
		}
		override public function onEnable():void {
			
			uiView = this.owner as HBox;
			lastwidth = uiView.width;
			
			uiView.on(Event.RESIZE,this,onResize);
		}
		
		private function onResize(e:Event):void
		{
			if(lastwidth == uiView.width)
				return;
			
			lastwidth = uiView.width;
			
			var totallength:Number = 0;
			for(var i:int=0;i < uiView.numChildren;i++)
			{
				totallength += (uiView.getChildAt(i) as Sprite).width;
			}
			
			uiView.space = (uiView.width - totallength)/(uiView.numChildren -1);
			
			trace("size change:" + uiView.space + "," + uiView.width);
			//e.stopPropagation();
			
		}
	}
}
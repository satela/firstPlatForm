package utils
{
	import laya.display.Node;
	import laya.events.Event;
	import laya.filters.GlowFilter;
	
	import ui.common.TipPanelUI;

	public class TipsUtil
	{
		public static var _instance:TipsUtil;
		public var tipspanel:TipPanelUI;
		private var tipsMsg:String = "";
		public static function getInstance():TipsUtil
		{
			if(_instance == null)
				_instance = new TipsUtil();
			return _instance;
		}
		public function TipsUtil()
		{
			tipspanel = new TipPanelUI();
			tipspanel.htmltxt.style.fontSize = 18;
			tipspanel.htmltxt.style.font = "SimHei";
			var glowfilter= new GlowFilter("#B1B1B1",5,2,2);
			tipspanel.filters = [glowfilter];
			//tipspanel.htmltxt.innerHTML = "<span color='#262B2E' size='20'>应付：</span>";
			//tipspanel.htmltxt.contextHeight;
		}
		
		public function addTips(container:Node,tips:String):void
		{
			container.on(Event.MOUSE_OVER,this,showTips);
			container.on(Event.MOUSE_MOVE,this,showTips);
			container.on(Event.MOUSE_OUT,this,removeTips);
			tipspanel.htmltxt.innerHTML = tips;
			
			tipspanel.backimg.width = tipspanel.htmltxt.contextWidth + 20;
			tipspanel.backimg.height = tipspanel.htmltxt.contextHeight + 20;

		}
		public function addGlobalTips(tips:String):void
		{
			Laya.stage.on(Event.MOUSE_OVER,this,showTips);
			Laya.stage.on(Event.MOUSE_MOVE,this,showTips);
			Laya.stage.on(Event.MOUSE_OUT,this,removeTips);
			tipspanel.htmltxt.innerHTML = tips;
			tipspanel.backimg.width = tipspanel.htmltxt.contextWidth + 20;
			tipspanel.backimg.height = tipspanel.htmltxt.contextHeight + 20;
		}
		public function stopGlobalTips():void
		{
			Laya.stage.off(Event.MOUSE_OVER,this,showTips);
			Laya.stage.off(Event.MOUSE_MOVE,this,showTips);
			Laya.stage.off(Event.MOUSE_OUT,this,removeTips);
			removeTips(null);
			
		}
		
		public function updateTips(tips:String):void
		{
			tipspanel.htmltxt.innerHTML = tips;
			tipspanel.backimg.width = tipspanel.htmltxt.contextWidth + 20;
			tipspanel.backimg.height = tipspanel.htmltxt.contextHeight + 20;
		}
		public function showTips(e:Event):void
		{
			if(tipspanel.parent == null)
			{
				Laya.stage.addChild(tipspanel);				
			}
			tipspanel.x = e.stageX + 10;
			tipspanel.y = e.stageY + 10;
		}
		public function removeTips(e:Event):void
		{
			if(tipspanel.parent != null)
			{
				tipspanel.removeSelf();				
			}
		}
	}
}
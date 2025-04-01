package utils
{
	import laya.utils.Browser;
	
	import ui.WaitRespondPanelUI;

	public class WaitingRespond
	{
		private static var _instance:WaitingRespond;
		private static var gui:WaitRespondPanelUI;
		public function WaitingRespond()
		{
		}
		
		public  static function get instance():WaitingRespond
		{
			if(_instance == null)
			{
				_instance = new WaitingRespond();
				initView();
			}
			
			return _instance;
		}
		
		private  static function initView():void
		{
			gui = new WaitRespondPanelUI();

		}
		
		public function showWaitingView(requesTime:int = 15000):void
		{
			if(gui.parent == null)
			{
				Laya.stage.addChild(gui);
			}
			Laya.timer.clear(WaitingRespond,rotatecircle);
			Laya.timer.clear(WaitingRespond,requestTimeOut);
			Laya.timer.loop(10,WaitingRespond,rotatecircle);
			Laya.timer.once(requesTime,WaitingRespond,requestTimeOut);

			gui.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private static function rotatecircle():void
		{
			gui.zhuanq.rotation += 10;
		}
		
		private static function requestTimeOut():void
		{
			if(gui.parent != null)
				Laya.stage.removeChild(gui);
			Laya.timer.clear(WaitingRespond,rotatecircle);
		}
		
		public function hideWaitingView():void
		{
			if(gui.parent != null)
				Laya.stage.removeChild(gui);
			Laya.timer.clear(WaitingRespond,rotatecircle);
			Laya.timer.clear(WaitingRespond,requestTimeOut);
		}
	}
}



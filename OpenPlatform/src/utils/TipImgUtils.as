package utils
{
	import laya.events.Event;
	import laya.filters.GlowFilter;
	
	import ui.common.TipPicturePanelUI;

	public class TipImgUtils
	{	
		
		public static var _instance:TipsUtil;
		public var tipspanel:TipPicturePanelUI;
		private var tipsMsg:String = "";
		public static function getInstance():TipImgUtils
		{
			if(_instance == null)
				_instance = new TipImgUtils();
			return _instance;
		}
		public function TipImgUtils()
		{
			tipspanel = new TipPicturePanelUI();
			tipspanel.htmltxt.style.fontSize = 18;
			tipspanel.htmltxt.style.font = "SimHei";
			var glowfilter= new GlowFilter("#B1B1B1",5,2,2);
			tipspanel.filters = [glowfilter];
			//tipspanel.htmltxt.innerHTML = "<span color='#262B2E' size='20'>应付：</span>";
			//tipspanel.htmltxt.contextHeight;
		}
		
		public function setTipsContent(tips:String,imgurl:String):void
		{
			tipspanel.htmltxt.innerHTML = tips;
			tipspanel.img.skin = imgurl;
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
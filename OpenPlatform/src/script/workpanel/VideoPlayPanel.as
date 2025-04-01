package script.workpanel
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.renders.Render;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import ui.inuoView.VideoPlayPanelUI;
	
	public class VideoPlayPanel extends Script
	{
		private var uiSkin:VideoPlayPanelUI;
		private var divElement:Object;
		private var videoElement:Object;

		public function VideoPlayPanel()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as VideoPlayPanelUI;
			uiSkin.closebtn.on(Event.CLICK,this,closeVideo);
			creatVideo();
		}
		
		private function creatVideo(){
			
			if(typeof(Browser.window.videojs) == "undefined")
			{
				script = Browser.document.createElement("script");
				script.src = "videoTool/video.min.js";
				script.onload = function(){
					//
					//Browser.window.createossClient(clientParam);
					//onClickBegin();
					initVideo();
					
				}
				script.onerror = function(e){
					
					trace("error" + e);
					
					//加载错误函数
				}
				Browser.document.body.appendChild(script);
			}
			else
			{
				initVideo();
			}

			
		}
		
		private function initVideo():void
		{
			if(this.destroyed)
				return;
			
			divElement = Browser.createElement("video");
			divElement.id = "myVideo";
			divElement.className = "video-js vjs-big-play-centered vjs-fluid";
			
			divElement.style = "position: absolute;top:50%;left:50%;transform: translate(-50%,-50%);";
			
			
			Browser.document.body.appendChild(divElement);         
			Browser.window.initTeachingVideo();
		}
		private function closeVideo():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_PLAY_VIDEO_PANEL);
		}
		public override function onDestroy():void
		{
			//Browser.document.body.removeChild(divElement);    
			Browser.window.disposeVideo();
		}
		
	}
}
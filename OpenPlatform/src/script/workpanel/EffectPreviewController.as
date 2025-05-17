package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import ui.inuoView.EffectPreviewPanelUI;
	
	public class EffectPreviewController extends Script
	{
		private var uiSkin:EffectPreviewPanelUI;
		
		private static var u3ddiv:Object;
		private static var script:*;
		private static var scriptpr:*;
		public var param:Object;
		public function EffectPreviewController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as EffectPreviewPanelUI; 
			u3ddiv = Browser.document.querySelector("#unity-container");
			u3ddiv.style.display = "";

			uiSkin.closeBtn.on(Event.CLICK,this,closeView);
			Browser.document.body.appendChild(u3ddiv);
			Browser.window.layaCaller = this;

			initU3dWeb();
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			onResizeBrower();
		}
		
		
		private function initU3dWeb():void
		{
			Browser.window.Unity3dWeb.createUnity();
			
		}
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.EFFECT_PREVIEW_PANEL);
			
		}
		private function onResizeBrower():void
		{
			
			var scaleNum:Number = Browser.clientWidth/1920;
			
			u3ddiv.style.left = 40 * scaleNum;
			
			u3ddiv.style.top = 40 * scaleNum;
			
			u3ddiv.style.bottom = 40 * scaleNum;
			u3ddiv.style.right = 40 * scaleNum;

			
		}
		
		private function unityIsReady():void
		{
			trace("unity is ready:" + JSON.stringify(param));
			if(param != null)
			{
				Browser.window.Unity3dWeb.sendProcInfo(JSON.stringify(param));
			}
			
		}
		
		public override function onDestroy():void
		{
			if(u3ddiv != null)
			{
				
				Browser.window.Unity3dWeb.stopRender();
				
				Browser.window.Unity3dWeb.setSceneActive("0");
				
				u3ddiv.style.display = "none";
				EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
				
				
			}
		}
		
	}
}
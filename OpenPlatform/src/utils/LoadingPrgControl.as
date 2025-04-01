package utils
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	
	import script.ViewManager;
	
	import ui.login.LoadingPanelUI;
	
	public class LoadingPrgControl extends Script
	{
		private var uiSkin:LoadingPanelUI;
		public function LoadingPrgControl()
		{
			super();
		}
		override public function onStart():void
		{
			uiSkin = this.owner as LoadingPanelUI;
			uiSkin.prg.value = 0;
			uiSkin.prgtxt.text = "0%";
			EventCenter.instance.on(EventCenter.UPDATE_LOADING_PROGRESS,this,onUpdatePrg);
			
		}
		
		private function onUpdatePrg(prgs:Number):void
		{
			// TODO Auto Generated method stub
			console.log("prg rec:" + prgs);
			uiSkin.prg.value = prgs;
			uiSkin.prgtxt.text = Math.floor(prgs*100) + "%";
			
			if(prgs>= 1)
			{
				ViewManager.instance.closeView(ViewManager.VIEW_LOADING_PRO);
			}
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.UPDATE_LOADING_PROGRESS,this,onUpdatePrg);

		}
	}
}
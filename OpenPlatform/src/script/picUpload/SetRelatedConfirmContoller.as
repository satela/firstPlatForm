package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Tween;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.inuoView.SetRelatedConfirmPanelUI;
	
	public class SetRelatedConfirmContoller extends Script
	{
		private var uiSkin:SetRelatedConfirmPanelUI;
		private var param:Object;
		
		private var caller:*;
		private var callBack:Function;
		
		public function SetRelatedConfirmContoller()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as SetRelatedConfirmPanelUI;
			
			uiSkin.mainview.scaleX = 0.2;
			uiSkin.mainview.scaleY = 0.2;
			Tween.to(uiSkin.mainview,{scaleX:1,scaleY:1},300,Ease.backOut);

			var picinfovoFront:PicInfoVo = param[0];
			var picinfovoRelate:PicInfoVo = param[1];
			var relateType:int = param[2];

			caller = param[3];
			callBack = param[4];
			
			if(picinfovoFront.picWidth > picinfovoFront.picHeight)
			{
				this.uiSkin.originPic.width = 180;					
				this.uiSkin.originPic.height = 180/picinfovoFront.picWidth * picinfovoFront.picHeight;
				this.uiSkin.relatedPic.width = this.uiSkin.originPic.width ;
				this.uiSkin.relatedPic.height = this.uiSkin.originPic.height ;

				
			}
			else
			{
				this.uiSkin.originPic.height = 180;
				this.uiSkin.originPic.width = 180/picinfovoFront.picHeight * picinfovoFront.picWidth;
				this.uiSkin.relatedPic.width = this.uiSkin.originPic.width ;
				this.uiSkin.relatedPic.height = this.uiSkin.originPic.height ;
			}
			
			uiSkin.originPic.skin = HttpRequestUtil.smallerrPicUrl + picinfovoFront.fid + ".jpg";
			uiSkin.relatedPic.skin = HttpRequestUtil.smallerrPicUrl + picinfovoRelate.fid + ".jpg";
			
			uiSkin.relatename.text = ["异形","反面","局部铺白"][relateType];
			uiSkin.msgtxt.text = "是否关联" + ["异形","反面","局部铺白"][relateType] + "图形？";
			uiSkin.closebtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL);
				
			});
				
			uiSkin.okbtn.on(Event.CLICK,this,function(){
				

				if(caller != null && callBack != null)
					callBack.call(caller,true);
				ViewManager.instance.closeView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL);

			})
			uiSkin.cancelbtn.on(Event.CLICK,this,function(){
				
				if(caller != null && callBack != null)
					callBack.call(caller,false);
				ViewManager.instance.closeView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL);

			});
			uiSkin.height = Browser.clientHeight * Laya.stage.width/Browser.clientWidth;
			uiSkin.mainview.y = (uiSkin.height - uiSkin.mainview.height)/2+ uiSkin.mainview.height/2;
			
			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			uiSkin.mainview.y = (uiSkin.height - uiSkin.mainview.height)/2+ uiSkin.mainview.height/2;
			
			
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		
	}
}
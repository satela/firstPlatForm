package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.order.item.AICutImageCell;
	
	import ui.order.CbcPreViewPanelUI;
	
	import utils.UtilTool;
	
	public class CbcPreviewController extends Script
	{
		private var uiSkin:CbcPreViewPanelUI;
		
		private var param:Object;

		private var picBox:Object;
		
		private var picInfo:PicInfoVo;
		
		private var hasRetry:Boolean = false;

		public function CbcPreviewController()
		{
			super();
		}
		override public function onStart():void
		{
			
			uiSkin = this.owner as CbcPreViewPanelUI; 
			
			uiSkin.waittingPanel.visible = false;
			
			uiSkin.imgList.itemRender = AICutImageCell;
			
			//uiSkin.memberlist.vScrollBarSkin = "";
			uiSkin.imgList.repeatX = 4;
			uiSkin.imgList.spaceX = 7;
			
			uiSkin.imgList.renderHandler = new Handler(this, updateImageList);
			uiSkin.imgList.selectEnable = false;
			uiSkin.imgList.array = [];
			
			uiSkin.loadingTips.visible = false;
			uiSkin.rollTip.visible = false;
			
			uiSkin.closeBtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.VIEW_CBC_PREVIEW_PANEL);
				Browser.window.showCbc(false);
				
			});
			uiSkin.okbtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.VIEW_CBC_PREVIEW_PANEL);
				Browser.window.showCbc(false);
				
			});
			
			picInfo = param[param.length - 1];
			
			picBox = Browser.window.document.getElementById('picBox');
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			onResizeBrower();
			EventCenter.instance.on(EventCenter.UPDATE_RELATED_PIC,this,updateCbcEffect);
			initCbcDiv();
			
			

				
		}
		private function onResizeBrower():void
		{
			
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			var scale:Number = Browser.clientWidth/Laya.stage.width;
			
			if(scale < 1)
				picBox.style.zoom = scale*100 + "%";
			else
				picBox.style.zoom = "100%";
			
		}
		
		private function updateCbcEffect(relatedType:String,fileid:String):void
		{
			this.picInfo[relatedType] = fileid;
			
			var piclist:Array = [];
			piclist.push(this.picInfo.fid);
			piclist.push(this.picInfo.partWhiteFid);
			if(this.picInfo.backFid == "0")
				piclist.push(this.picInfo.fid);
			else
				piclist.push(this.picInfo.backFid);
			piclist.push(this.picInfo.yixingFid);
			
			var ids:Array = ["frontImg","maskImg","backImg"];
			for(var i:int=0;i<3;i++)
			{
				if(piclist[i] != null && piclist[i] != "" && piclist[i] != "0")
				{
					Browser.window.readLocalImg(HttpRequestUtil.biggerPicUrl + piclist[i] + ".jpg",ids[i],i==1);
					
				}
				else
					Browser.window.readLocalImg("",ids[i],i==1);
			}
			if(piclist[3] != null && piclist[3] != "" && piclist[3] != "0")
			{
				Browser.window.setMaskImg(HttpRequestUtil.biggerPicUrl + piclist[3] + ".jpg");
				
			}
			else
				Browser.window.setMaskImg("");

			uiSkin.imgList.refresh();
		}
		public function initCbcDiv():void
		{
			
			Browser.window.showCbc(true);
			var piclist:Array = param as Array;
			var ids:Array = ["frontImg","maskImg","backImg"];
			for(var i:int=0;i<3;i++)
			{
				if(piclist[i] != null && piclist[i] != "" && piclist[i] != "0")
				{
					Browser.window.readLocalImg(HttpRequestUtil.biggerPicUrl + piclist[i] + ".jpg",ids[i],i==1);
					
				}
			}
			if(piclist[3] != null && piclist[3] != "" && piclist[3] != "0")
			{
				Browser.window.setMaskImg(HttpRequestUtil.biggerPicUrl + piclist[3] + ".jpg");
				
			}
		}
		
		
		private function updateImageList(cell:AICutImageCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.UPDATE_RELATED_PIC,this,updateCbcEffect);

		}
		
	}
}
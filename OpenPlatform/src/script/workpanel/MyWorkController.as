package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.workpanel.items.LatestPicItem;
	
	import ui.inuoView.MyWorkPanelUI;
	import ui.inuoView.OrderTypePanelUI;
	import ui.inuoView.PicManagerPanelUI;
	
	import utils.UtilTool;
	
	public class MyWorkController extends Script
	{
		private var uiSkin:MyWorkPanelUI;
		
		public function MyWorkController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as MyWorkPanelUI;
			uiSkin.mainpanel.vScrollBarSkin = "";
			
			uiSkin.picList.itemRender = LatestPicItem;
			//uiSkin.picList.vScrollBarSkin = "";
			uiSkin.picList.selectEnable = false;
			uiSkin.picList.spaceY = 4;
			uiSkin.picList.repeatX = 8;
			uiSkin.picList.spaceX = 20;

			uiSkin.picList.renderHandler = new Handler(this, updatePicItem);
			uiSkin.picList.array  =[];
			
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			var shortName:String = json["shortName"];
			uiSkin.title.text = "欢迎登录" + shortName + "广告自助下单系统";
			
			uiSkin.discountMs.text = uiSkin.discountMs.text.replace("品赋阳光",shortName);
			
			uiSkin.upgradeStorage.on(Event.CLICK,this,function(){
				
				ViewManager.instance.openView(ViewManager.VIEW_BUY_STORAGE_PANEL);
				
			});
			uiSkin.orderBtn.on(Event.CLICK,this,function(){
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[OrderTypePanelUI,0]);
				
			});
			
			uiSkin.uploadBtn.on(Event.CLICK,this,function(){
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[PicManagerPanelUI,1]);
				
			});
			
			uiSkin.teaching.on(Event.CLICK,this,function(){
				
				//ViewManager.instance.openView(ViewManager.VIEW_PLAY_VIDEO_PANEL);
				
			});
			
			uiSkin.addWechat.on(Event.CLICK,this,function(){
				
				var postdata:Object = {};
				postdata.title = "企业微信";
				postdata.url = "bigpic/enterWeChat.jpg";
				
				ViewManager.instance.openView(ViewManager.PRODUCT_PROC_EFFECT_PANEL,false,postdata);
				
				
			});
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,onGetLeftCapacitBack,null,null);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getLatestPictures,this,onGetLatestPic,null,null);

		}
		
		private function updatePicItem(cell:LatestPicItem):void 
		{
			cell.setData(cell.dataSource);
		}
		
		private function onGetLeftCapacitBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			if(result.code == "0")
			{
				var  size:Number = parseInt(result.data.storageUsedSize)/1024/1024;
				var maxsize:int = parseInt(result.data.storageDefaultSize)/1000/1000;
				Userdata.instance.hasBuySorage = result.data.storageSize;
				
				if(Userdata.instance.hasBuySorage > 0)
					maxsize = Userdata.instance.hasBuySorage;
				
				if( parseInt(result.data.storageUsedSize) < parseInt(result.data.storageDefaultSize))
					uiSkin.capacityProgress.value = parseInt(result.data.storageUsedSize)/parseInt(result.data.storageDefaultSize);
				else
					uiSkin.capacityProgress.value = 1;
				
				uiSkin.leftCapacityLbl.text = size.toFixed(0) + "M/" + maxsize + "G";
				
				if(Userdata.instance.hasBuySorage > 0)
				{
					//Userdata.instance.storageBuyDate = new Date(Date.parse(UtilTool.convertDateStr(result.storage_date))).getTime();
					
					//Userdata.instance.storageExpiredDate = new Date(Date.parse(UtilTool.convertDateStr(result.expire_date))).getTime();
				}
			}
		}
		
		private function onGetLatestPic(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			if(result.code == "0")
			{
				var arr:Array = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					var pic:PicInfoVo = new PicInfoVo(result.data[i],1);
					arr.push(pic);
				}
				
				this.uiSkin.picList.array = arr;
			}
		}
	}
}
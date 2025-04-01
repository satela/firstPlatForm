package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.picManager.BuyStoragePanelUI;
	
	import utils.UtilTool;
	
	public class BuyStorageController extends Script
	{
		private var uiSkin:BuyStoragePanelUI;
		private var curmoney:Number = 0;
		public function BuyStorageController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as BuyStoragePanelUI; 
			
			uiSkin.cancelbtn.on(Event.CLICK,this,onCloseView);
			
			uiSkin.paybtn.on(Event.CLICK,this,onBuyStorage);
			uiSkin.storagetype.selectHandler = new Handler(this,onSelectStorage);
			
			if(Userdata.instance.hasBuySorage > 0)
				uiSkin.storagetype.selectedIndex = (Userdata.instance.hasBuySorage - 50)/10;
			else
				uiSkin.storagetype.selectedIndex = 0;
			
			if(Userdata.instance.hasBuySorage > 0)
			{
				uiSkin.curStorageTxt.text = Userdata.instance.hasBuySorage + "G";
				uiSkin.outtime.text = UtilTool.formatFullDateTime( new Date(Userdata.instance.storageExpiredDate));
			}
			else
			{
				uiSkin.curStorageTxt.text = "未购买";
				uiSkin.outtimebox.visible = false;
			}
			updateMoney();
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);


		}
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
			
		}
		private function onSelectStorage(index:int):void
		{
			var chooseStorage:int = 50 + 10 * index;

			if(chooseStorage < Userdata.instance.hasBuySorage)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"不能降低存储空间"});
				
				
				Laya.timer.frameOnce(2,this,function(){
					uiSkin.storagetype.selectedIndex = (Userdata.instance.hasBuySorage - 50)/10;
				});
				
			}
			
			updateMoney();
		}
		
		private function updateMoney():void
		{
			curmoney = 0;
			var chooseStorage:int = 50 + 10 * (uiSkin.storagetype.selectedIndex);				

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.extendStoragePrice + "size=" + chooseStorage,this,onGetPriceBack,null,null);

//			var chooseStorage:int = 50 + 10 * (uiSkin.storagetype.selectedIndex);
//			if(Userdata.instance.hasBuySorage > 0)
//			{
//				var passtime:int = Math.ceil(((new Date()).getTime() - Userdata.instance. storageBuyDate+ 8 * 3600 * 1000)/(3600*24*1000));
//				
//				var usermoney:Number = 0;
//				
//				if(passtime < 365)
//				{				
//					 usermoney = Constast.STORAGE_PRICE[Userdata.instance.hasBuySorage.toString()]/365 * passtime;
//				}
//				else
//				{
//					usermoney = Constast.STORAGE_PRICE[Userdata.instance.hasBuySorage.toString()];
//				}
//				
//				var needmoney:Number = Constast.STORAGE_PRICE[chooseStorage.toString()] + usermoney - Constast.STORAGE_PRICE[Userdata.instance.hasBuySorage.toString()];
//				
//				uiSkin.paymoney.text = Math.ceil(needmoney).toString() + "元";
//			}
//			else
//			{
//				uiSkin.paymoney.text = Constast.STORAGE_PRICE[chooseStorage.toString()] + "元";
//			}
		}
		
		private function onGetPriceBack(res:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(res);
			if(result.code == "0")
			{
				uiSkin.paymoney.text = result.data + "元";
				curmoney = parseInt(result.data);
			}
			
		}
		private function onBuyStorage():void
		{
			if(uiSkin.storagetype.selectedIndex >= 0 && curmoney > 0)
			{
				ViewManager.instance.closeView(ViewManager.VIEW_BUY_STORAGE_PANEL);
				var chooseStorage:int = 50 + 10 * (uiSkin.storagetype.selectedIndex);				
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL,false,{amount:curmoney,size:chooseStorage});

			}
			
		}
		
		private function onBuyBack(result:*):void
		{
			
			
			
		}
		private function onCloseView():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			ViewManager.instance.closeView(ViewManager.VIEW_BUY_STORAGE_PANEL);
		}
	}
}
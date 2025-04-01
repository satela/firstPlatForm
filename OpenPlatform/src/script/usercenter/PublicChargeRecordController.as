package script.usercenter
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	
	import ui.usercenter.PublicChargeRecordPanelUI;
	
	public class PublicChargeRecordController extends Script
	{
		private var uiSkin:PublicChargeRecordPanelUI;
		
		private var param:Object;
		private var curpage:int = 1;
		private var totalpage:int = 1;
		public function PublicChargeRecordController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as PublicChargeRecordPanelUI;
			
			
			uiSkin.recordlist.itemRender = PublicChargeCell;
			
			//uiSkin.applylist.vScrollBarSkin = "";
			uiSkin.recordlist.repeatX = 1;
			uiSkin.recordlist.spaceY = 5;
			
			uiSkin.recordlist.renderHandler = new Handler(this, updateRecordList);
			uiSkin.recordlist.selectEnable = false;
			
			uiSkin.recordlist.array = new Array(12);
			
			uiSkin.closebtn.on(Event.CLICK,this,closePanel);
			
			uiSkin.recordlist.array = [];
			
			uiSkin.prevbtn.on(Event.CLICK,this,onLastPage);
			uiSkin.nextbtn.on(Event.CLICK,this,onNextPage);
			
			var postdata:String = "page=1";
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getpublicChargeRequestList + postdata,this,getchargeRecordBack,null,null);
			
		}
		
		
		private function onLastPage():void
		{
			if(curpage > 1 )
			{
				curpage--;
				var postdata:String = "page=" + curpage;

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getpublicChargeRequestList+ postdata,this,getchargeRecordBack,null,null);
			}
		}
		private function onNextPage():void
		{
			if(curpage < totalpage )
			{
				curpage++;
				var postdata:String = "page=" + curpage;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getpublicChargeRequestList+ postdata,this,getchargeRecordBack,null,null);
			}
		}
		
		
		private function getchargeRecordBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.recordlist.array = result.data.infos;
				totalpage = Math.ceil(result.data.totalCount/30);
				if(totalpage == 0)
					totalpage = 1;
				
				uiSkin.pagetxt.text = curpage + "/" + totalpage;
			}
		}
		private function updateRecordList(cell:PublicChargeCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function closePanel():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_PUBLIC_CHARGE_RECORD_PANEL);
			
		}
		
	}
}
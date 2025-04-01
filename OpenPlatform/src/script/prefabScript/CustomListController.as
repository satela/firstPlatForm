package script.prefabScript
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Input;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.ui.Panel;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.CustomVo;
	
	import script.picUpload.CustomeSimpleCell;
	
	public class CustomListController extends Script
	{
		private var uiSkin:Panel;
		private var customlist:List;
		private var customNameInput:Input;
		private var searchBtn:Button;

		private var prevPage:Button;
		private var nextPage:Button;
		private var pageTxt:Label;
		
		private var curPage:int = 1;
		private var totalPage:int = 1;
		
		private var pageSize:int = 20;
		
		public function CustomListController()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiSkin = this.owner as Panel;

			customNameInput = uiSkin.getChildByName("searchCustomName") as Input;
			searchBtn = uiSkin.getChildByName("searchBtn") as Button;
			prevPage = uiSkin.getChildByName("pageBox").getChildByName("prevPage") as Button;
			nextPage = uiSkin.getChildByName("pageBox").getChildByName("nextPage") as Button;
			pageTxt = uiSkin.getChildByName("pageBox").getChildByName("pageTxt") as Label;

			
			customlist = uiSkin.getChildByName("customeList") as List;
			
			customlist.itemRender = CustomeSimpleCell;
			//uiSkin.picList.scrollBar.autoHide = true;
			customlist.selectEnable = true;
			customlist.spaceY = 1;
			customlist.renderHandler = new Handler(this, updateCustomeItem);
			customlist.selectHandler = new Handler(this,onSelectCustomer);
			
			prevPage.on(Event.CLICK,this,onLastPage);
			nextPage.on(Event.CLICK,this,onNextPage);
			searchBtn.on(Event.CLICK,this,function(){
				
				curPage = 1;
				getCustomerList();
				
			});
			
			customNameInput.maxChars = 10;
			
			customlist.array = [];
			getCustomerList();
		}
		
		private function onSelectCustomer(index:int):void
		{
			var custome:CustomVo = this.customlist.array[index];
			
			EventCenter.instance.event(EventCenter.SELECT_CUSTOMER,custome);
			uiSkin.visible = false;
		}
		private function updateCustomeItem(cell:CustomeSimpleCell):void 
		{
			cell.setData(cell.dataSource);
		}
		
		private function getCustomerList():void
		{
			var params:String = "pageNo=" + curPage + "&pageSize=" + pageSize + "&customerName=" + customNameInput.text;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listCustomer + params,this,listCustomerBack,null,null);
			
		}
		
		private function listCustomerBack(data:*):void
		{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var arr:Array = [];
				for(var i:int=0;i < result.data.customers.length;i++)
				{
					arr.push(new CustomVo(result.data.customers[i]));
				}
				totalPage = Math.ceil(result.data.totalCount/pageSize);
				if(totalPage < 1)
					totalPage = 1;
				
				if(curPage == 1)
				{
					arr.unshift(new CustomVo({"customerName":Userdata.instance.company,"id":"0","mobileNumber":Userdata.instance.founderPhone}));
				}
				customlist.array = arr;

				pageTxt.text = curPage + "/" + totalPage;
			}
		}
		
		private function onLastPage():void
		{
			if(curPage > 1 )
			{
				curPage--;
				getCustomerList();
			}
		}
		private function onNextPage():void
		{
			if(curPage < totalPage )
			{
				curPage++;
				getCustomerList();
			}
		}
	}
}
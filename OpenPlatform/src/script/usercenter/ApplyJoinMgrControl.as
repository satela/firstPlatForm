package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	import script.usercenter.item.ApplyJoinItem;
	
	import ui.usercenter.ApplyJoinMgrPanelUI;
	
	public class ApplyJoinMgrControl extends Script
	{
		private var uiSkin:ApplyJoinMgrPanelUI;
		private var curRequest:Object;
		
		private var allOrganize:Array;
		public function ApplyJoinMgrControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ApplyJoinMgrPanelUI;
			uiSkin.applylist.itemRender = ApplyJoinItem;
			
			//uiSkin.applylist.vScrollBarSkin = "";
			uiSkin.applylist.repeatX = 1;
			uiSkin.applylist.spaceY = 5;
			
			uiSkin.applylist.renderHandler = new Handler(this, updateApplyList);
			uiSkin.applylist.selectEnable = false;
			
			uiSkin.distributePanel.visible = false;
			
			
			uiSkin.applylist.array = [];
			
			uiSkin.applylist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.applylist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			uiSkin.closedistribute.on(Event.CLICK,this,onCloseDistributePanel);
			uiSkin.confirmJoin.on(Event.CLICK,this,onAgreeJoin);
			
			uiSkin.closeBtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.APPLY_JOIN_LIST_PANEL);
			})

			EventCenter.instance.on(EventCenter.AGREE_JOIN_REQUEST,this,showDistribute);
			EventCenter.instance.on(EventCenter.REFRESH_JOIN_REQUEST,this,refreshRequest);

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getJoinOrganizeRequest,this,onGetJoinRequestBack,null,null);

		}
		
		private function refreshRequest():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getJoinOrganizeRequest,this,onGetJoinRequestBack,null,null);
		}
		private function onGetJoinRequestBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.applylist.array = result.data;
			}
		}
		
		private function showDistribute(data:Object):void
		{
			curRequest = data;
			uiSkin.distributePanel.visible = true;
			if(allOrganize == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMyOrganize,this,onGetAllOrganizeBack,null,null);
			}
		}
		
		private function onGetAllOrganizeBack(data:*):void{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				allOrganize = result.data;
				var arr:Array = [];
				for(var i:int=0;i < result.data.length;i++)
				{
					arr.push(result.data[i].name);
				}
				//trace("arr:" + arr.length);
				uiSkin.deptbox.labels = arr.join(",");
			}
		}
		
		private function onAgreeJoin():void
		{
			if(curRequest == null)
				return;
			if(uiSkin.deptbox.selectedIndex < 0)
			{
				ViewManager.showAlert("请选择要分配到的组织");
				return;
			}
			var param:Object = {"id":curRequest.id , "action":"1","deptId" : allOrganize[uiSkin.deptbox.selectedIndex].id};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.handleJoinOrganizeRequest,this,onhandleBack,JSON.stringify(param),"post");

		}
		
		private function onhandleBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getJoinOrganizeRequest,this,onGetJoinRequestBack,null,null);
				uiSkin.distributePanel.visible = false;
				ViewManager.showAlert("操作成功");
			}
		}
		private function onCloseDistributePanel():void
		{
			uiSkin.distributePanel.visible = false;
		}
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
		}
		
		private function updateApplyList(cell:ApplyJoinItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.AGREE_JOIN_REQUEST,this,showDistribute);			
			EventCenter.instance.off(EventCenter.REFRESH_JOIN_REQUEST,this,refreshRequest);

		}
		
	}
}
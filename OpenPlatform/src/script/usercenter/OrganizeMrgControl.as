package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.Const;
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.CheckBox;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	import script.usercenter.item.MemberItem;
	import script.usercenter.item.OrganizeItem;
	
	import ui.usercenter.AccountSettingPanelUI;
	
	public class OrganizeMrgControl extends Script
	{
		private var uiSkin:AccountSettingPanelUI;
		
		private var curMemberdata:Object;
		
		private var previlegeCheckBoxlst:Array;
		public function OrganizeMrgControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as AccountSettingPanelUI;
			
			
			uiSkin.changeName.on(Event.CLICK,this,onConfirmChangeName);
			uiSkin.userName.maxChars = 6;
			uiSkin.userName.text = Userdata.instance.userName;
			
			uiSkin.organizelist.itemRender = OrganizeItem;
			
			uiSkin.organizelist.vScrollBarSkin = "";
			uiSkin.organizelist.repeatX = 7;
			uiSkin.organizelist.spaceY = 5;
			uiSkin.organizelist.spaceX = 15;
			
			uiSkin.organizelist.renderHandler = new Handler(this, updateOrganizeList);
			uiSkin.organizelist.selectEnable = true;
			uiSkin.organizelist.selectHandler = new Handler(this,selectOrganize);
			uiSkin.organizelist.array = [];

			uiSkin.memberlist.itemRender = MemberItem;
			
			//uiSkin.memberlist.vScrollBarSkin = "";
			uiSkin.memberlist.repeatX = 1;
			uiSkin.memberlist.spaceY = 5;

			uiSkin.memberlist.renderHandler = new Handler(this, updateMemberList);
			uiSkin.memberlist.selectEnable = false;
			
			uiSkin.distributePanel.visible = false;
			
			
			var temparr:Array = [];
			
			uiSkin.memberlist.array = temparr;
			
			uiSkin.createOrganizePanel.visible = false;
			
			uiSkin.setAuthorityPanel.visible = false;
			uiSkin.closeauthoritybtn.on(Event.CLICK,this,onCloseAuthorityPanel);
			uiSkin.confirmauthoritybtn.on(Event.CLICK,this,updateMemberAuthority);

			uiSkin.createOrganize.on(Event.CLICK,this,showCretePanel);
			
			uiSkin.organizeNameInput.maxChars = 6;
			uiSkin.createBtnOk.on(Event.CLICK,this,onConfirmCreateOrganize);
			uiSkin.memberlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.memberlist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			
			uiSkin.moveOkbtn.on(Event.CLICK,this,onMoveMemberSure);
			uiSkin.closeDist.on(Event.CLICK,this,onCloseDistribute);
			uiSkin.btncloseCreate.on(Event.CLICK,this,onCloseCreate);
			uiSkin.applyListBtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.openView(ViewManager.APPLY_JOIN_LIST_PANEL);
			});

			previlegeCheckBoxlst = [uiSkin.order_submit,uiSkin.order_submit_with_balances,uiSkin.order_price_display,uiSkin.order_list_self,uiSkin.order_list_org,uiSkin.asset_log_list];
			
			uiSkin.organizeBox.visible = Userdata.instance.privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0;
			if(Userdata.instance.privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMyOrganize,this,onGetAllOrganizeBack,null,null);
			
			EventCenter.instance.on(EventCenter.DELETE_ORGANIZE_BACK,this,refreshOrganize);
			EventCenter.instance.on(EventCenter.MOVE_MEMBER_DEPT,this,moveMember);
			EventCenter.instance.on(EventCenter.DELETE_DEPT_MEMBER,this,refreshOrganizeMemebers);
			
			EventCenter.instance.on(EventCenter.SET_MEMEBER_AUTHORITY,this,setMemberAuthority);

			

		}
		
		private function onGetAllOrganizeBack(data:*):void{
			
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				if(result.data.length > 0)
				{
					uiSkin.organizelist.array = result.data;
					if(result.data.length > 0)
					{
						uiSkin.organizelist.selectedIndex = 0;
						(uiSkin.organizelist.cells[0] as OrganizeItem).selected = true;
					}
			}
			}
			
		}
		private function refreshOrganize():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMyOrganize,this,onGetAllOrganizeBack,null,null);

		}
		
		private function showCretePanel():void
		{
			uiSkin.createOrganizePanel.visible = true;
		}
		
		private function onConfirmCreateOrganize():void
		{
			if(uiSkin.organizeNameInput.text == "")
			{
				ViewManager.showAlert("请输入组织名称");
				return;
			}
			
			var param:Object = {"name": uiSkin.organizeNameInput.text};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createOrganize,this,onCreateBack,JSON.stringify(param),"post");

			uiSkin.createOrganizePanel.visible = false;
		}
		
		private function onCreateBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMyOrganize,this,onGetAllOrganizeBack,null,null);
			}
		}
		private function pauseParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
		}
		private function resumeParentScroll():void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
		}
		
		private function updateMemberList(cell:MemberItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function updateOrganizeList(cell:OrganizeItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function selectOrganize(index:int):void
		{
			for each(var item:OrganizeItem in uiSkin.organizelist.cells)
			{
				item.setselected(uiSkin.organizelist.array[index].id);
			}
			
			var params:String = "deptId="+uiSkin.organizelist.array[index].id;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrganizeMembers + params,this,onGetOrganizeMembersBack,null,null);

			
						
		}
		
		private function onGetOrganizeMembersBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.memberlist.array = result.data;
			}
		}
		
		private function moveMember(data:Object):void
		{
			curMemberdata = data;
			uiSkin.distributePanel.visible = true;
			
			var allOrganize:Array = uiSkin.organizelist.array;
			var arr:Array = [];
			for(var i:int=0;i < allOrganize.length;i++)
			{
				arr.push(allOrganize[i].name);
			}
			
			uiSkin.organizeCom.labels = arr.join(",");
			uiSkin.organizeCom.selectedIndex = 0;
			//trace("arr:" + arr.length);
			
		}
		
		private function setMemberAuthority(data:Object):void
		{
			curMemberdata = data;
						
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrganizeMemberAuthority+"userId=" + curMemberdata.userId,this,onGetOrganizeMemberAuthBack,null,null);

			
		}
		
		private function onGetOrganizeMemberAuthBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				if(curMemberdata)
				{
					if(result.data != null && result.data.length > 0)
					{
												
						uiSkin.accoutname.text = "设置账号：" + curMemberdata.mobileNumber + " 的权限";
						uiSkin.setAuthorityPanel.visible = true;
						for(var i:int=0;i < 6;i++)
						{
							(previlegeCheckBoxlst[i] as CheckBox).selected = ( result.data.indexOf(Constast.PREVILIGE_LIST[i]) >= 0);
						}
					
					}
				
				}
				
			}
		}
		
		
		private function onCloseAuthorityPanel():void
		{
			uiSkin.setAuthorityPanel.visible = false;

		}
		
		private function updateMemberAuthority():void
		{
			var postdata:Array = [];
			postdata.uid = curMemberdata.uid;
			
			for(var i:int=0;i < 6;i++)
			{
				if(previlegeCheckBoxlst[i].selected)
				{
					postdata.push(Constast.PREVILIGE_LIST[i]);
				}
			}
			uiSkin.setAuthorityPanel.visible = false;

			var params:Object = {"permissions":postdata,"userId":curMemberdata.userId};
			//var params:String = "dept=" + todept + "&uid=" + curMemberdata.uid;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setOrganizeMemberAuthority,this,onUpdateOrganizeMemberAuthBack,JSON.stringify(params),"post");
		}
		
		private function onUpdateOrganizeMemberAuthBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				ViewManager.showAlert("设置成功");
			}
			else
			{
				ViewManager.showAlert("设置失败");

			}
		}
		private function onCloseDistribute():void
		{
			uiSkin.distributePanel.visible = false;
		}
		private function onMoveMemberSure():void
		{
			if(curMemberdata == null)
				return;
			if(uiSkin.organizeCom.selectedIndex < 0)
			{
				ViewManager.showAlert("请选择要移动到的组织");
				return;
			}
			
			var todept:String = uiSkin.organizelist.array[uiSkin.organizeCom.selectedIndex].id;
			if(curMemberdata.deptId == todept)
			{
				ViewManager.showAlert("该用户已经在这个组织里");
				return;
			}
			
			var params:Object = {"deptId":todept,"userId" :curMemberdata.userId};
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.moveOrganizeMembers,this,onMoveOrganizeMemberBack,JSON.stringify(params),"post");
		}
		
		private function onCloseCreate():void
		{
			this.uiSkin.createOrganizePanel.visible = false;
		}
		private function onMoveOrganizeMemberBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var params:String = "deptId=" + uiSkin.organizelist.array[uiSkin.organizelist.selectedIndex].id;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrganizeMembers + params,this,onGetOrganizeMembersBack,null,null);
			}
			uiSkin.distributePanel.visible = false;

		}
		
		private function refreshOrganizeMemebers():void
		{
			var params:String = "deptId=" + uiSkin.organizelist.array[uiSkin.organizelist.selectedIndex].id;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrganizeMembers + params,this,onGetOrganizeMembersBack,null,null);
		}
		
		private function onConfirmChangeName():void
		{
			if(uiSkin.userName.text == "")
			{
				return;
			}
			
			var username:Object = {"userName":uiSkin.userName.text};
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateUserName,this,onUpdateUserNameBack,JSON.stringify(username),"post");

		}
		
		private function onUpdateUserNameBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.userName = uiSkin.userName.text;
				EventCenter.instance.event(EventCenter.UPDAE_USER_NAME);
			}
		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.DELETE_ORGANIZE_BACK,this,refreshOrganize);
			EventCenter.instance.off(EventCenter.MOVE_MEMBER_DEPT,this,moveMember);
			EventCenter.instance.off(EventCenter.DELETE_DEPT_MEMBER,this,refreshOrganizeMemebers);
			EventCenter.instance.off(EventCenter.SET_MEMEBER_AUTHORITY,this,setMemberAuthority);

		}
	}
}
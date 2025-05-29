package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.Const;
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.CheckBox;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	import script.usercenter.item.MemberItem;
	import script.usercenter.item.OrganizeItem;
	
	import ui.usercenter.AccountSettingPanelUI;
	
	import utils.UtilTool;
	
	public class OrganizeMrgControl extends Script
	{
		private var uiSkin:AccountSettingPanelUI;
		
		private var curMemberdata:Object;
		
		private var previlegeCheckBoxlst:Array;
		
		private var isUploading:Boolean = false;
		private var clientParam:Object;
		private var callbackparam:Object; //服务器回调参数

		
		private var file:Object;
		private var ossFileName:String;//服务器指定的文件名

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
			uiSkin.uploadQrCodeImg.on(Event.CLICK,this,onUploadQrCode);
			uiSkin.applyListBtn.on(Event.CLICK,this,function(){
				
				ViewManager.instance.openView(ViewManager.APPLY_JOIN_LIST_PANEL);
			});
			Browser.window.uploadApp = this;
			uiSkin.myQrCodeImg.skin = Userdata.instance.paymentQrCode;
			uiSkin.myQrCodeImg.on(Event.LOADED,this,onLoadedImg);
			uiSkin.deleteQrCodeImg.on(Event.CLICK,this,onDeleteQrcodeImg);
			initFileOpen();
			previlegeCheckBoxlst = [uiSkin.order_submit,uiSkin.order_submit_with_balances,uiSkin.order_price_display,uiSkin.order_list_self,uiSkin.order_list_org,uiSkin.asset_log_list];
			
			uiSkin.organizeBox.visible = Userdata.instance.privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0;
			if(Userdata.instance.privilege.indexOf(Constast.ADMIN_PREVILIGE) >= 0)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMyOrganize,this,onGetAllOrganizeBack,null,null);
			
			EventCenter.instance.on(EventCenter.DELETE_ORGANIZE_BACK,this,refreshOrganize);
			EventCenter.instance.on(EventCenter.MOVE_MEMBER_DEPT,this,moveMember);
			EventCenter.instance.on(EventCenter.DELETE_DEPT_MEMBER,this,refreshOrganizeMemebers);
			
			EventCenter.instance.on(EventCenter.SET_MEMEBER_AUTHORITY,this,setMemberAuthority);

			

		}
		
		private function initFileOpen():void
		{
			file = Browser.document.createElement("input");
			
			file.style="filter:alpha(opacity=0);opacity:0;width: 100;height:34px;left:395px;top:-248";
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else
			//file.multiple="multiple";
			
			file.accept = ".jpg,.jpeg,.png";
			file.type ="file";
			file.style.position ="absolute";
			file.style.zIndex = 999;
			Browser.document.body.appendChild(file);//添加到舞台
			file.onchange = function(e):void
			{			
				if(file.files[0] == null)
					return;
				
				if(file.files[0] != null && file.files[0].type == "image/jpg" || file.files[0].type == "image/jpeg" || file.files[0].type == "image/png")
				{
					if(file.files[0].size > 500*1024)
					{
						ViewManager.showAlert("图片大小不能超过500K");
						return;
					}
				}
				else
				{
					ViewManager.showAlert("请选择jpg或者png图片");
					return;
				}
				
				if(isUploading)
					return;
				getSendRequest();
			};
			
			Browser.window.uploadHandle = this;							
			
		}
		
		private function onUploadQrCode():void
		{
			file.click();

		}
		
		private function getSendRequest():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.authorUploadUrl,this,onGetAuthor,null,null);
		}
		private function onGetAuthor(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var authordata:Object = JSON.parse(data as String);
			if(authordata == null || authordata.data == null)
				return;
			clientParam = {};
			clientParam.accessKeyId = authordata.data.accessKeyId;
			clientParam.accessKeySecret = authordata.data.accessKeySecret;
			clientParam.stsToken = authordata.data.securityToken;
			//clientParam.endpoint = "oss-cn-hangzhou.aliyuncs.com";			
			//clientParam.bucket = "original-image";
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			
			clientParam.endpoint = "oss-cn-hangzhou.aliyuncs.com";			
			clientParam.bucket = json["bucket"];
			
			trace("oss:" + typeof(Browser.window.OSS));
			if(typeof(Browser.window.OSS) == "undefined")
			{
				script = Browser.document.createElement("script");
				script.src = "aliOss.min.js";
				script.onload = function(){
					//
					Browser.window.createossClient(clientParam);
					onBeginUpload();
					
				}
				script.onerror = function(e){
					
					trace("error" + e);
					
					//加载错误函数
				}
				Browser.document.body.appendChild(script);
			}
				
			else
			{
				Browser.window.createossClient(clientParam);
				onBeginUpload();
			}
		}
		
		private function onBeginUpload():void
		{
			
			if(file.files[0] != null )
			{
				//var params:Object = {};
				//params.dirId = "0";
				//params.name = file.files[0].name;
				
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.noticeServerPreUpload,this,onReadyToUpload,JSON.stringify(params),"post");
				uploadFileImmediate();

			}
			
		}
		
//		private function onReadyToUpload(data:Object):void
//		{
//			if(this.destroyed)
//				return;
//			
//			var result:Object = JSON.parse(data as String);
//			if(result.code == "0")
//			{
//				callbackparam = {};
//				
//				callbackparam.url = "";
//				callbackparam.body = result.data.callbackBody;
//				callbackparam.contentType = 'application/x-www-form-urlencoded';
//				
//				var arr:Array = (file.files[0].name as String).split(".");
//				
//				ossFileName = result.data.objectName + "." + (arr[arr.length - 1] == null ?"jpg":arr[arr.length - 1]);
//				uploadFileImmediate();
//			}
//			
//		}
		private function uploadFileImmediate():void
		{
			if(file.files[0] != null)
			{
				isUploading = true;
				
				var arr:Array = (file.files[0].name as String).split(".");
								
				ossFileName = UtilTool.uuid() + "." + (arr[arr.length - 1] == null ?"jpg":arr[arr.length - 1]);
				trace("filename:" + ossFileName);
				Browser.window.ossUpload({file:file.files[0]},0,null,ossFileName);
				
				//Browser.window.uploadPic({urlpath:HttpRequestUtil.httpUrl + HttpRequestUtil.uploadPic, path:DirectoryFileModel.instance.curSelectDir.dpath,file:fileListData[curUploadIndex]});
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.uploadPic,this,onCompleteUpload,{path:"0|11|",file:file.files[0]},"post",onProgressHandler);
			}
			
		}
		
		private function onProgressHandler(e:Object,pro:Object):void
		{
			
		}
		private function onCompleteUpload(e:Object):void
		{
			
			isUploading = false;
			var params:Object = {"fileName":ossFileName};
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.noticeServerQrcodeComplete,this,onNoticeComplete,JSON.stringify(params),"post");
		}
		private function onDeleteQrcodeImg():void
		{
			isUploading = false;
			var params:Object = {"fileName":""};
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.noticeServerQrcodeComplete,this,onNoticeComplete,JSON.stringify(params),"post");
		}
		private function onNoticeComplete(data:*):void{
						
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.paymentQrCode = result.data;
				if(this.destroyed)
					return;
				uiSkin.myQrCodeImg.skin = Userdata.instance.paymentQrCode;
				
			}
		}
		
		private function onLoadedImg(e:Event):void
		{
			var text = Laya.loader.getRes(Userdata.instance.paymentQrCode);
			if(text == null)
				return;
			
			var imgwidth:Number = text.width;
			var imgheight:Number = text.height;
			if(imgwidth > imgheight)
			{
				uiSkin.myQrCodeImg.width = 150;
				uiSkin.myQrCodeImg.height = 150*imgheight/imgwidth;

			}
			else
			{
				uiSkin.myQrCodeImg.height = 150;
				uiSkin.myQrCodeImg.width = 150*imgwidth/imgheight;
			}

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
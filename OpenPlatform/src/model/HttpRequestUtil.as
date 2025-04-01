package model
{
	import laya.events.Event;
	import laya.net.HttpRequest;
	import laya.ui.View;
	import laya.utils.Browser;
	
	import script.ViewManager;
	
	import utils.UtilTool;
	import utils.WaitingRespond;

	public class HttpRequestUtil
	{
		private static var _instance:HttpRequestUtil;
		
		public static var httpUrl:String =  "http://www.cmyk.com.cn/scfy/" ;//	"http://47.98.218.56/scfy/"; //"http://dhs3iy.natappfree.cc/";//
		
		public static const registerUrl:String = "sys/registerUser?";
		
		public static const loginInUrl:String = "sys/login?";///"account/login?";/ phone= code= 或pwd= mode(0 密码登陆 1 验证码登陆);
		public static const enterUrl:String = "sys/userEnter?";//只需要token

		
		public static const loginOutUrl:String = "sys/logout?";//"account/logout?";//登出

		
		public static const getVerifyCode:String = "sys/getMobileSmsCode?";
			
		

		public static const createDirectory:String = "fs/dir/create?";//"dir/create?";
		public static const deleteDirectory:String = "fs/dir/delete?";//"dir/remove?";
		public static const getDirectoryList:String = "fs/list?";//"dir/list?";
		//public static const uploadPic:String = "file/add";
		public static const deletePic:String = "fs/file/delete?";
		
		
		public static const getChangePwdCode:String = "account/getcode?";
		public static const changePwdReqUrl:String = "sys/updatePassword?";

		public static const createGroup:String = "sys/registerOrg?";//cname,cshortname,czoneid,caddr,cyyzz


		public static const addressManageUrl:String = "group/opt-group-express?";//1 delete 2 update 3 insert 4 list 5 default
		
		public static const addressListUrl:String = "org/express/list?"; //地址列表

		public static const addressAddUrl:String = "org/express/add?"; //地址增加
		public static const addressUpdateUrl:String = "org/express/list?"; //地址列表
		public static const addressDeleteUrl:String = "org/express/delete?"; //地址删除
		public static const setDefaultaddress:String = "org/express/setDefault?"; //默认地址


//		public static const biggerPicUrl:String = "https://large-thumbnail-image.oss-cn-hangzhou.aliyuncs.com/";
//		public static const smallerrPicUrl:String = "https://small-thumbnail-image.oss-cn-hangzhou.aliyuncs.com/";
//		
//		public static const originPicPicUrl:String = "https://original-image.oss-cn-hangzhou.aliyuncs.com/";
//		
		public static var biggerPicUrl:String = "https://pfyg-thumbnail-large-img.oss-cn-hangzhou.aliyuncs.com/";
		public static  var smallerrPicUrl:String = "https://pfyg-thumbnail-small-img.oss-cn-hangzhou.aliyuncs.com/";
		
		public static  var originPicPicUrl:String = "https://pfyg-normal-image.oss-cn-hangzhou.aliyuncs.com/";
		


		public static const addCompanyInfo:String = "group/create?"; //name=,addr=
		
		public static const getAuditInfo:String = "group/get-request?";//获取企业信息

		public static const getOuputAddr:String = "business/manufacturers?";//client_code=CL10600&";//addr_id=120106";获取输出工厂地址
		public static const getProdCategory:String = "business/prodcategory?";//client_code=CL10600&";//addr_id=120106";获取工厂材料列表 SCFY001

		//public static const getProdList:String = "business/prodlist?client_code=CL10200&addr_id=";//addr_id,prodCat_name=纸&;获取工厂材料列表

		//public static const getProcessCatList:String = "business/processcatlist?prod_code=";//

		public static const getProcessFlow:String = "business/procflowlist?manufacturer_code=";//procCat_name= //获取工艺流
		
		public static const GetAccCatlist:String = "business/acccatlist?";//prod_code=，proc_name= //获取附件类名称

		public static const GetAccessorylist:String = "business/accessorylist?";//manufacturer_code=，accessoryCat_name= //获取附件类列表

		public static const getDeliveryList:String = "business/deliverylist?";//=SPSC00100&addr_id=330700";//获取配送列表

		public static const placeOrder:String =   "order/submit";// "business/placeorder?";//下单接口

		public static const updateOrder:String = "order/update?";//更新订单接口

		
		public static const cancelOrder:String = "order/cancel?";//取消订单
		
		public static const authorUploadUrl:String = "fs/sts";//"file/authinfo";//上传请求凭证
		public static const noticeServerPreUpload:String = "fs/file/prepareUpload?";//"file/preupload?";//上传前通知服务器 path,fname 
		
		public static const getAddressFromServer:String = "sys/areaInfo?";//"group/get-addr-list?";//查询地址 parentid
		
		public static const abortUpload:String = "file/abortadd?";//主动终止上传
		
		public static const getMerchandiseList:String = "business/merchandiselist?client_code=CL10600&";

		public static const getManuFactureMatProcPrice:String = "business/getmatprocprice?manufacturer_code=";
		
		//获取订单状态
		public static const getOrderState:String = "business/getOrderItemStatus?";
		public static const getOrderDeliveryState:String = "business/getDeliveryOrder?";

		//充值
		public static const getCompanyInfo:String = "org/getInfo";//"group/get-info?";//账户信息
		
		
		public static const cancelExceptOrder:String = "group/cancel-exception-order?";//取消异常订单
		
		public static const payExceptOrder:String = "group/pay-exception-order?";//重试异常订单

		
		public static const chargeRequest:String = "order/pay?";// "group/recharge?";//扫码支付
		public static const recharge:String = "org/recharge?";// ;//账户充值

		//对公充值
		public static const publicChargeRequest:String  = "org/corporateRecharge?";//
		public static const getpublicChargeRequestList:String  = "org/getCorporateRechargeList?";//
		
		
		//public static const orderOnlinePay:String = "group/recharge?";//订单在线支付  orderid 在线支付 

		public static const payOrderByMoney:String = "order//payWithBal?";//余额支付orderid


		public static const getOrderRecordList:String = "order/list?";//查询订单 date = 201910 curpage=1
		
		public static const deleteOrderList:String = "account/delete-unpaid-order?";//删除订单


		public static const changeCompanyName:String = "group/update_group?";//修改公司名

		//组织相关
		public static const getMyOrganize:String = "org/dept/list?";//获取所有组织

		public static const createOrganize:String = "org/dept/add?";//创建组织

		public static const deleteOrganize:String = "org/dept/del?";//删除组织

		public static const joinOrganize:String = "sys/joinOrg?";//加入组织

		public static const getJoinOrganizeRequest:String = "org/getJoinList?";//申请列表

		public static const handleJoinOrganizeRequest:String = "org/handleJoinReq?";//处理申请
		
		public static const getOrganizeMembers:String = "org/dept/listMember?";//获取组织里的人

		public static const moveOrganizeMembers:String = "org/dept/setMember?";//移动组织里的人
		
		public static const setOrganizeMemberAuthority:String = "org/setPrivilege?";//设置权限

		public static const getOrganizeMemberAuthority:String = "org/getPrivilege?";//获取权限

		
		public static const setYixingRelated:String = "fs/img/setMask";//"file/set-mask-image?";//设置异形关联图片
		public static const setFanmianRelated:String = "fs/img/setBack";//"file/set-back-image?";//设置反面关联图片
		public static const setPartWhiteRelated:String = "fs/img/setPartWhite";//"file/set-partwhite-image?";//设置局部铺白关联图片

		public static const queryTransaction:String = "account/listmoneylog";
		
		//充值活动
		public static const getChargeActivity:String = "group/get-activities?"; //获取正在进行的活动
		public static const joinChargeActivity:String = "group/join-activity?"; //参与进行的活动
		public static const payChargeActivity:String = "group/pay-activity?"; //活动付款
		public static const getChargeActivityRecord:String = "group/get-joined-activities?"; //活动记录
		public static const groupChargeActivity:String = "account/recharge-activity-confirm-before?"; //对公转账充值活动

		public static const cancelChargeActivityRecord:String = "group/refund-activity?"; //退款

		
		public static const getDeliveryTimeList:String = "business/getAvailebleDeliveryDates?";
		public static const preOccupyCapacity:String = "business/setCapacityPreOccupy?";

		public static const getProductUids:String = "order/reserveItemSn?";
		
		
		public static const extendStorage:String = "fs/payForStorage?";

		public static const extendStoragePrice:String  = "fs/getStoragePrice?";
		
		public static const payextendStorage:String  = "fs/payForStorage?";
		
		public static const getMaintainMsg:String  = "account/getnotice?";
		
		public static const getDeliveryFee:String  = "group/get-delivery-fee?";//获取配送费

		
		public static const getDeliveryFeeConfig:String  = "business/dynamicdeliveryfee?customer_code=";//获取配送费配置
		
		public static const getDailyCost:String = "group/get-factory-bill";//获取每日支付列表

		public static const getInvoiceEnterInfo:String = "group/get-invoice-info";//获取发票企业信息
		public static const updateInvoiceEnterInfo:String = "group/update-invoice-info";//更新发票企业信息

		public static const applyInvoice:String = "group/apply-invoice";//更新发票企业信息
		
		public static const listInvoice:String = "group/list-invoice";//更新发票企业信息

		public static const cancelInvoice:String = "group/cancel-invoice";//撤销申请发票

		public static const vipAddressManageUrl:String = "group/opt-vip-express?";//1 delete 2 update 3 insert 4 list 5 default
		public static const vipAddressGroupManageUrl:String = "group/opt-vip-addr-group?";//1 delete 2 update 3 insert 4 list 5 default
		
		public static const insertGroupAddress:String = "group/opt-vip-addr-group-rel?";//添加地址到分组
		public static const removeGroupAddress:String = "group/opt-vip-addr-group-rel/remomve?";//从分组移除地址
		
		public static const listGroupAddress:String = "group/get-group-addr?";//分组地址列表
		public static const listGroupsAddress:String = "group/list-all-group-addr?";//获取多个分组下的地址列表
		
		public static const addErrorLog:String = "group/add-error-log?";//报错日志

		public static const getProductCategoryDefault:String = "account/get-product-default-category?";//获取材料分类默认值
		//public static const setProductCategoryDefault:String = "account/add-product-default-category?";//获取材料分类默认值
		public static const updateProductCategoryDefault:String = "account/update-product-default-category?";//获取材料分类默认值

		public static const leaveGroupUrl:String = "account/leave-group?";//退出公司

		public static const getFactoryFreezeBalance:String = "business/getToBeTopupAmount?customer_code=";//获取工厂代充冻结余额



		/*新接口*/
		public static const getProdListNew:String = "business/listProduct?webCode=001&addressId=";//获取产品列表clientCode
		public static const getProcFlowNew:String = "business/getProcFlow?prodCode=";//获取工艺流
		public static const getProdDiscount:String = "business/getProdDiscount?webCode=001&";//获取工艺流
		public static const getProdAttribute:String = "business/getProdAttributes?prod_code=";//获取产品属性，衍生产品
		
		public static const updateCompanyInfo:String = "org/update?";//更新公司信息

		
		public static const getLatestPictures:String = "fs/getLatestFile?";//获取最近上传图片
		
		public static const updateUserName:String = "sys/updateUserName?";//

		
		public static const getAllAiFiles:String = "fs/getAiFile?";//

		public static const queryDeliveryMap:String = "order/delivery?";
		public static const queryDeliverySn:String = "order/deliveryRecord?";

		

		public static const sendInvoiceRequest:String = "sys/requestInvoice?";

		public static const getClientOrderSource:String = "business/getClientOrderSources?";
		
		public static const getModelProducts:String = "business/getModelProduct?";//获取模型产品 clientCode,orgList[orgCode,orgPriority],pageNum,pageSize,addrID,customerCode		
		
		public static const getModelProductData:String = "business/getModelProdData?"; //获取模型数据
		

		public static var photoAiHttpUrl:String =  "http://139.224.203.146:8083" ;
		
		public static var getModelDetail:String =  "/model/modelDetail?" ;

		public static var getTemplateInfo:String =  "/template/getTemplateById?" ;

		public static var uploadMaterial:String =  "/material/uploadMaterial?" ;//上传素材
		public static var replaceMaterials:String =  "/template/replaceMaterials?" ;//替换元素
		public static var getModelOrderDetail:String =  "/model/getModelOrderDetail?" ;//获取下单数据

		//客户管理
		public static var addCustomer:String =  "org/customer/add?" ;//添加客户
		public static var updateCustomer:String =  "org/customer/update?" ;//添加客户
		public static var listCustomer:String =  "org/customer/paging?" ;//添加客户
		public static var deleteCustomer:String =  "org/customer/delete?" ;//添加客户
		
		public static var addCustomerAddress:String =  "org/customer/express/add?" ;//添加客户地址

		public static var updateCustomerAddress:String =  "org/customer/express/update?" ;//添加客户地址
		public static var deleteCustomerAddress:String =  "org/customer/express/delete?" ;//添加客户地址
		public static var listCustomerAddress:String =  "org/customer/express/list?" ;//添加客户地址



		public static function get instance():HttpRequestUtil
		{
			if(_instance == null)
				_instance = new HttpRequestUtil();
			return _instance;
		}
		
		public function HttpRequestUtil()
		{
			
		}
		
		private function newRequest(url:String,caller:Object=null,complete:Function=null,param:Object=null,requestType:String="text",onProgressFun:Function = null):void{
			
			var request:HttpRequest=new HttpRequest();
			request.on(Event.PROGRESS, this, function(e:Object)
			{
				if(onProgressFun != null)
					onProgressFun(e);
			});
			request.on(Event.COMPLETE, this,onRequestCompete,[caller, complete,request]);
			
			//var self:HttpModel=this;
			function checkOver(url:String,caller:Object,complete:Function,param:Object,requestType:String,request:HttpRequest){
				onHttpRequestError(url,caller,complete,param,requestType,request);
			}
			Laya.timer.once(60000,request,checkOver,[url,caller,complete,param,requestType,request]);			
					
			request.on(Event.ERROR, this, onHttpRequestError,[url,caller,complete,param,requestType,request]);
			
			if(param!=null){
				if(param is String){
					
				}else if(param is ArrayBuffer){
					
				}else{
					var query:Array=[];
					for(var k in param){
						
						query.push(k+"="+encodeURIComponent(param[k]));
					}
					param=query.join("&");
				}
			}
			console.log(url+param);
			request["retrytime"]=0;
			request.send(url, param, requestType?'post':'get', "text");
		}
		
		private function onHttpRequestError(url:String,caller:Object,complete:Function,param:Object,requestType:String,request:HttpRequest,e:Object=null):void
		{
			//ViewManager.showAlert("您的网络出了个小差，请重试！");
			var data:Object = {'status':10001};
			//ViewManager.showAlert("网络出了个小差，请重试！");
			if(caller&&complete)complete.call(caller,JSON.stringify(data));
		}
		
		private function onHttpRequestProgress(e:Object=null):void
		{
			trace(e)
		}
		
		private function onRequestCompete(caller:Object,complete:Function,request:HttpRequest,data:Object):void
		{
			//requetTime--;
			//if(requetTime <= 0)
			WaitingRespond.instance.hideWaitingView();

			try
			{
				var result:Object = JSON.parse(data as String);
				if(result && result.hasOwnProperty("code"))
				{
					if(result.code != "0")
					{
						//if(ErrorCode.ErrorTips.hasOwnProperty(result.code))
						//{
							if(result.message != null)
							{
								ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{tips:result.message,msg:"请求错误"});

							}
							else
							{
								ViewManager.showAlert(ErrorCode.ErrorTips[result.status]);
								
							}
						//}
						if(result.code == "203" || result.code == "210")
						{
							ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
						}
					}
				}
			}
			catch(err:Error)
			{
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
				return;
			}
			Laya.timer.clearAll(request);
			// TODO Auto Generated method stub
			if(caller&&complete)complete.call(caller,data);
			request.offAll();
		}
		
		public  function Request(url:String,caller:Object=null,complete:Function=null,param:Object=null,type:String="get",onProgressFun:Function = null,showwaiting:Boolean=true):void{
			
			var logtime:String = UtilTool.getLocalVar("loginTime","");
			if(Userdata.instance.loginTime != 0 && logtime != Userdata.instance.loginTime.toString())
			{
				ViewManager.showAlert("不能同时登陆两个账号，请重新登录");
				Userdata.instance.isLogin = false;
				
				UtilTool.setLocalVar("useraccount","");
				UtilTool.setLocalVar("userpwd","");
				
				Browser.window.location.reload();
				//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
				
				return;
			}
			
			if(showwaiting)
			{
				//requetTime++;
				WaitingRespond.instance.showWaitingView();
			}
			newRequest(url,caller,complete,param,type);
		}
		// --- Static Functions ------------------------------------------------------------------------------------------------------------------------------------ //
		public  function RequestBin(url:String,caller:Object=null,complete:Function=null,param:Object=null):void{
			newRequest(url,caller,complete,param,"arraybuffer");
		}
		
	}
}
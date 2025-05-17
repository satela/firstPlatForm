package script
{
	import adobe.utils.CustomActions;
	
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.ui.View;
	import laya.utils.Browser;
	
	import model.Constast;
	
	import ui.FirstPagePanelUI;
	import ui.LoginViewUI;
	import ui.PaintOrderPanelUI;
	import ui.PicManagePanelUI;
	import ui.PopUpDialogUI;
	import ui.PopUpPhoneDialogUI;
	import ui.common.PicturePopDialogUI;
	import ui.inuoView.CreateFolderPanelUI;
	import ui.inuoView.EffectPreviewPanelUI;
	import ui.inuoView.MatAndProcEffectPanelUI;
	import ui.inuoView.MaterialAdProcFlowPanelUI;
	import ui.inuoView.OrderTypePanelUI;
	import ui.inuoView.RelatedPicChoosePanelUI;
	import ui.inuoView.SetRelatedConfirmPanelUI;
	import ui.inuoView.VideoPlayPanelUI;
	import ui.login.LoadingPanelUI;
	import ui.login.LogPanelUI;
	import ui.login.LogPhonePanelUI;
	import ui.login.RegisterPanelUI;
	import ui.login.RegisterPhonePanelUI;
	import ui.login.ResetPwdPanelUI;
	import ui.order.AddCommentPanelUI;
	import ui.order.AverageCutPanelUI;
	import ui.order.CbcPreViewPanelUI;
	import ui.order.ChooseDeliveryTimePanelUI;
	import ui.order.ConfirmOrderPanelUI;
	import ui.order.DakouPanelUI;
	import ui.order.InputCutNumPanelUI;
	import ui.order.MoreProductPanelUI;
	import ui.order.PackageOrderPanelUI;
	import ui.order.PackagePanelUI;
	import ui.order.SelectAddressPanelUI;
	import ui.order.SelectAttchPanelUI;
	import ui.order.SelectDeliveryPanelUI;
	import ui.order.SelectFactoryPanelUI;
	import ui.order.SelectMaterialPanelUI;
	import ui.order.SelectPackAddresstPanelUI;
	import ui.order.SelectPicPanelUI;
	import ui.orderList.WriteOffOrderPanelUI;
	import ui.picManager.BuyStoragePanelUI;
	import ui.picManager.PicCheckPanelUI;
	import ui.prodCustom.CustomEditPanelUI;
	import ui.prodCustom.CustomerProdCategoryPanelUI;
	import ui.prodCustom.ProdChoosePanelUI;
	import ui.product.BuyProductPanelUI;
	import ui.product.ProductMarketPanelUI;
	import ui.product.ProductOrderPanelUI;
	import ui.uploadpic.UpLoadPanelUI;
	import ui.usercenter.AddrGroupDetailPanelUI;
	import ui.usercenter.AddressListPanelUI;
	import ui.usercenter.ApplyJoinMgrPanelUI;
	import ui.usercenter.CompanyInfoEditPanelUI;
	import ui.usercenter.DeliveryQueryPanelUI;
	import ui.usercenter.InvoiceHistoryPanelUI;
	import ui.usercenter.NewAddressPanelUI;
	import ui.usercenter.OrderDetailPanelUI;
	import ui.usercenter.PublicChargeRecordPanelUI;
	import ui.usercenter.SellPriceSettingPanelUI;
	import ui.usercenter.UserMainPanelUI;

	public class ViewManager
	{
		private static var _instance:ViewManager;
		
		private var viewContainer:Sprite;
		
		private var openViewList:Object;
		
		public static const VIEW_FIRST_PAGE:String = "VIEW_FIRST_PAGE"; //首页页面

		public static const VIEW_lOGPANEL:String = "VIEW_lOGPANEL"; //登陆页面
		public static const VIEW_REGPANEL:String = "VIEW_REGPANEL";//注册界面;
		public static const VIEW_CHANGEPWD:String = "VIEW_CHANGEPWD";//注册界面;

		public static const VIEW_MYPICPANEL:String = "VIEW_MYPICPANEL";//图片资源管理界面

		public static const VIEW_PICMANAGER:String = "VIEW_PICMANAGER";//图片管理下单界面

		public static const VIEW_PICTURE_CHECK:String = "VIEW_PICTURE_CHECK";//图片预览

		public static const VIEW_PAINT_ORDER:String = "VIEW_PAINT_ORDER";//喷印下单

		public static const VIEW_USERCENTER:String = "VIEW_USERCENTER";//用户中心

		public static const VIEW_SELECT_ADDRESS:String = "VIEW_SELECT_ADDRESS";//选择收货地址
		
		public static const VIEW_SELECT_FACTORY:String = "VIEW_SELECT_FACTORY";//选择输出中心
		public static const VIEW_SELECT_PIC_TO_ORDER:String = "VIEW_SELECT_PIC_TO_ORDER";//添加喷印图片界面

		public static const VIEW_SELECT_MATERIAL:String = "VIEW_SELECT_MATERIAL";//选择材料界面
		public static const VIEW_ADD_MESSAGE:String = "VIEW_ADD_MESSAGE";//添加备注
		public static const VIEW_SELECT_DELIVERY_TYPE:String = "VIEW_SELECT_DELIVERY_TYPE";//选择配送方式 快递
		public static const VIEW_SELECT_ATTACH:String = "VIEW_SELECT_ATTACH";//选择配件界面

		public static const INPUT_CUT_NUM:String = "INPUT_CUT_NUM";//输入裁切数
		public static const AVG_CUT_VIEW:String = "AVG_CUT_VIEW";//等份裁切

		public static const VIEW_PRODUCT_VIEW:String = "VIEW_PRODUCT_VIEW";//商品界面
		public static const VIEW_BUY_PRODUCT_VIEW:String = "VIEW_BUY_PRODUCT_VIEW";//购买商品界面

		
		public static const VIEW_LOADING_PRO:String = "VIEW_LOADING_PRO";//加载界面

		public static const VIEW_ADD_NEW_ADDRESS:String = "VIEW_ADD_NEW_ADDRESS";//添加收货地址
		
		public static const VIEW_ORDER_DETAIL_PANEL:String = "VIEW_ORDER_DETAIL_PANEL";//订单详情查询界面
		
		public static const VIEW_SELECT_PAYTYPE_PANEL:String = "VIEW_SELECT_PAYTYPE_PANEL";//选择支付方式界面

		public static const VIEW_CHARACTER_DEMONSTRATE_PANEL:String = "VIEW_CHARACTER_DEMONSTRATE_PANEL";//字牌展示界面

		public static const VIEW_CHARACTER_TYPE_PANEL:String = "VIEW_CHARACTER_TYPE_PANEL";//字牌类型选择界面
		
		public static const VIEW_CHOOSE_DELIVERY_TIME_PANEL:String = "VIEW_CHOOSE_DELIVERY_TIME_PANEL";//选择交付时间界面


		public static const VIEW_PACKAGE_ORDER_PANEL:String = "VIEW_PACKAGE_ORDER_PANEL";//订单打包设置界面

		public static const VIEW_DAKOU_PANEL:String = "VIEW_DAKOU_PANEL";//正上方打扣设置界面


		public static const VIEW_CARVING_ORDER_PANEL:String = "VIEW_CARVING_ORDER_PANEL";//字牌下单主界面
		
		public static const VIEW_ACTIVITY_ADVETISE_PANEL:String = "VIEW_ACTIVITY_ADVETISE_PANEL";//活动广告


		public static const VIEW_POPUPDIALOG:String = "VIEW_POPUPDIALOG";//确认框
		public static const VIEW_POPUPDIALOG_WITH_PICTURE:String = "VIEW_POPUPDIALOG_WITH_PICTURE";//带图片的确认框

		
		public static const VIEW_CHARGE_RECORD_PANEL:String = "VIEW_CHARGE_RECORD_PANEL";//活动记录

		public static const VIEW_BUY_STORAGE_PANEL:String = "VIEW_BUY_STORAGE_PANEL";//购买存储空间

		public static const VIEW_INVOICE_HISTORY_PANEL:String = "VIEW_INVOICE_HISTORY_PANEL";//发票记录
		
		public static const VIEW_ADDRESS_GROUP_MGR_PANEL:String = "VIEW_ADDRESS_GROUP_MGR_PANEL";//地址分组管理界面
		
		public static const VIEW_PACKAGE_ORDER_VIP_PANEL:String = "VIEW_PACKAGE_ORDER_VIP_PANEL";//新分包界面
		
		public static const VIEW_ADDRESS_LIST_PANEL:String = "VIEW_ADDRESS_LIST_PANEL";//地址列表界面
		
		public static const VIEW_SELECT_PACK_ADDRESS_PANEL:String = "VIEW_SELECT_PACK_ADDRESS_PANEL";//选择打包地址

		public static const VIEW_PUBLIC_CHARGE_RECORD_PANEL:String = "VIEW_PUBLIC_CHARGE_RECORD_PANEL";//对公充值
		public static const VIEW_MORE_PRODUCT_PANEL:String = "VIEW_MORE_PRODUCT_PANEL";//更多材料
		
		public static const VIEW_CBC_PREVIEW_PANEL:String = "VIEW_CBC_PREVIEW_PANEL";//彩白彩预览
		
		public static const VIEW_PRODUCT_CATEGORY_PANEL:String = "VIEW_PRODUCT_CATEGORY_PANEL";//成品定制分类界面
		public static const VIEW_PRODUCT_CHOOSE_PANEL:String = "VIEW_PRODUCT_CHOOSE_PANEL";//成品定制条件选择界面

		public static const VIEW_PRODUCT_CUSTOMIZATION_PANEL:String = "VIEW_PRODUCT_CUSTOMIZATION_PANEL";//成品定制编辑界面


		public static const VIEW_CREATE_FOLDER_PANEL:String = "VIEW_CREATE_FOLDER_PANEL";//新建文件夹
		public static const VIEW_ORDER_TYPE_PANEL:String = "VIEW_ORDER_TYPE_PANEL";//下单类型界面
		public static const VIEW_SET_RELATED_CONFIRM_PANEL:String = "VIEW_SET_RELATED_CONFIRM_PANEL";//设置关联图片确认界面

		
		public static const VIEW_SET_MATERIAL_PROCESS_PANEL:String = "VIEW_SET_MATERIAL_PROCESS_PANEL";//设置材料及工艺界面
		public static const VIEW_EDIT_COMPANY_INFO_PANEL:String = "VIEW_EDIT_COMPANY_INFO_PANEL";//修改公司信息

		public static const VIEW_PLAY_VIDEO_PANEL:String = "VIEW_PLAY_VIDEO_PANEL";//视频播放

		public static const EFFECT_PREVIEW_PANEL:String = "EFFECT_PREVIEW_PANEL";//效果预览

		public static const DELIVERY_PACKAGE_PANEL:String = "DELIVERY_PACKAGE_PANEL";//物流包裹
		public static const APPLY_JOIN_LIST_PANEL:String = "APPLY_JOIN_LIST_PANEL";//申请加入组织列表
		public static const RELATED_PIC_CHOOSE_PANEL:String = "RELATED_PIC_CHOOSE_PANEL";//关联图片选择界面
		public static const PRODUCT_PROC_EFFECT_PANEL:String = "PRODUCT_PROC_EFFECT_PANEL";//材料工艺效果图界面

		public static const ORDER_PRICE_SETTING_PANEL:String = "ORDER_PRICE_SETTING_PANEL";//订单售价设置界面

		public static const WRITE_OFF_ORDER_PANEL:String = "WRITE_OFF_ORDER_PANEL";//订单销账界面

		
		public var viewDict:Object;
		private var curZorder:int = 0;
		public static function get instance():ViewManager
		{
			if(_instance == null)
				_instance = new ViewManager();
			return _instance;
		}
		
		public function ViewManager()
		{
			viewContainer = new Sprite();
			
			Laya.stage.addChild(viewContainer);
			
			//var screenHeight:int = window.screen.height;
			//var screenWidth:int = window.screen.width;
			
			//if(screenHeight < 1080)
			//	viewContainer.scaleY = screenHeight/1080;
			
			//if(screenWidth < 1920)
			//{
				//viewContainer.scaleX = screenWidth/1920;
				//viewContainer.x = (1920 - screenWidth)/2;
			//}

			
			openViewList = {};
			
			viewDict = new Object();
			
			viewDict[VIEW_FIRST_PAGE] = FirstPagePanelUI;

			if(typeof(Browser.window.orientation) != "undefined")
			{				
				viewDict[VIEW_lOGPANEL] = LogPhonePanelUI;
				viewDict[VIEW_REGPANEL] = RegisterPhonePanelUI;
				viewDict[VIEW_POPUPDIALOG] = PopUpPhoneDialogUI;

			}
			else
			{
				viewDict[VIEW_lOGPANEL] = LogPanelUI;
				viewDict[VIEW_REGPANEL] = RegisterPanelUI;
				viewDict[VIEW_POPUPDIALOG] = PopUpDialogUI;

			}
			
			viewDict[VIEW_CHANGEPWD] = ResetPwdPanelUI;
			viewDict[VIEW_MYPICPANEL] = UpLoadPanelUI;
			viewDict[VIEW_USERCENTER] = UserMainPanelUI;
			viewDict[VIEW_PICTURE_CHECK] = PicCheckPanelUI;
			viewDict[VIEW_POPUPDIALOG_WITH_PICTURE] = PicturePopDialogUI;


			viewDict[VIEW_SELECT_ADDRESS] = SelectAddressPanelUI;
			viewDict[VIEW_SELECT_FACTORY] = SelectFactoryPanelUI;
			viewDict[VIEW_SELECT_PIC_TO_ORDER] = SelectPicPanelUI;
			viewDict[VIEW_SELECT_MATERIAL] = SelectMaterialPanelUI;
			viewDict[VIEW_SELECT_DELIVERY_TYPE] = SelectDeliveryPanelUI;
			viewDict[VIEW_SELECT_ATTACH] = SelectAttchPanelUI;
			viewDict[INPUT_CUT_NUM] = InputCutNumPanelUI;
			viewDict[AVG_CUT_VIEW] = AverageCutPanelUI;

			viewDict[VIEW_ADD_MESSAGE] = AddCommentPanelUI;
			viewDict[VIEW_ADD_NEW_ADDRESS] = NewAddressPanelUI;
			viewDict[VIEW_LOADING_PRO] = LoadingPanelUI;
			
			viewDict[VIEW_PRODUCT_VIEW] = ProductOrderPanelUI;// ProductMarketPanelUI;//
			viewDict[VIEW_BUY_PRODUCT_VIEW] = BuyProductPanelUI;
			viewDict[VIEW_ORDER_DETAIL_PANEL] = OrderDetailPanelUI;
			viewDict[VIEW_SELECT_PAYTYPE_PANEL] = ConfirmOrderPanelUI;
			//viewDict[VIEW_CHARACTER_DEMONSTRATE_PANEL] = CharacterPaintUI;
			//viewDict[VIEW_CHARACTER_TYPE_PANEL] = CharactTypePanelUI;
			//viewDict[VIEW_CARVING_ORDER_PANEL] = CarvingOrderPanelUI;
			viewDict[VIEW_CHOOSE_DELIVERY_TIME_PANEL] = ChooseDeliveryTimePanelUI;
			viewDict[VIEW_PACKAGE_ORDER_PANEL] = PackagePanelUI;
			//viewDict[VIEW_ACTIVITY_ADVETISE_PANEL] = ChargeAdvertisePanelUI;
			viewDict[VIEW_DAKOU_PANEL] = DakouPanelUI;
			//viewDict[VIEW_CHARGE_RECORD_PANEL] = ChargeActRecordPanelUI;;

			viewDict[VIEW_BUY_STORAGE_PANEL] = BuyStoragePanelUI;;
			viewDict[VIEW_INVOICE_HISTORY_PANEL] = InvoiceHistoryPanelUI;;
			viewDict[VIEW_ADDRESS_GROUP_MGR_PANEL] = AddrGroupDetailPanelUI;
			viewDict[VIEW_PACKAGE_ORDER_VIP_PANEL] = PackageOrderPanelUI;
			viewDict[VIEW_ADDRESS_LIST_PANEL] = AddressListPanelUI;
			
			viewDict[VIEW_SELECT_PACK_ADDRESS_PANEL] = SelectPackAddresstPanelUI;
			viewDict[VIEW_PUBLIC_CHARGE_RECORD_PANEL] = PublicChargeRecordPanelUI;
			viewDict[VIEW_MORE_PRODUCT_PANEL] = MoreProductPanelUI;
			viewDict[VIEW_CBC_PREVIEW_PANEL] = CbcPreViewPanelUI;
			
			viewDict[VIEW_CREATE_FOLDER_PANEL] = CreateFolderPanelUI;
			viewDict[VIEW_ORDER_TYPE_PANEL] = OrderTypePanelUI;
			viewDict[VIEW_SET_RELATED_CONFIRM_PANEL] = SetRelatedConfirmPanelUI;
			viewDict[VIEW_SET_MATERIAL_PROCESS_PANEL] = MaterialAdProcFlowPanelUI;
			
			viewDict[VIEW_EDIT_COMPANY_INFO_PANEL] = CompanyInfoEditPanelUI;
			viewDict[VIEW_PLAY_VIDEO_PANEL] = VideoPlayPanelUI;
			
			viewDict[EFFECT_PREVIEW_PANEL] = EffectPreviewPanelUI;
			viewDict[DELIVERY_PACKAGE_PANEL] = DeliveryQueryPanelUI;
			viewDict[APPLY_JOIN_LIST_PANEL] = ApplyJoinMgrPanelUI;
			viewDict[RELATED_PIC_CHOOSE_PANEL] = RelatedPicChoosePanelUI;
			viewDict[PRODUCT_PROC_EFFECT_PANEL] = MatAndProcEffectPanelUI;
			viewDict[ORDER_PRICE_SETTING_PANEL] = SellPriceSettingPanelUI;
			
			viewDict[WRITE_OFF_ORDER_PANEL] = WriteOffOrderPanelUI;

			
//			viewDict[VIEW_PRODUCT_CUSTOMIZATION_PANEL] = CustomEditPanelUI;
//			viewDict[VIEW_PRODUCT_CATEGORY_PANEL] = CustomerProdCategoryPanelUI;
//			
//			viewDict[VIEW_PRODUCT_CHOOSE_PANEL] = ProdChoosePanelUI;

		}
		
		public static function showAlert(mesg:String):void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:mesg,noCancel:true});
			
			//Browser.window.alert(mesg);

		}
		public function openView(viewClass:String,closeOther:Boolean=false,params:Object = null):void
		{
			
			
			if(closeOther)
			{
				for each(var oldview in openViewList)
				{
					if(oldview != null)
					{
						viewContainer.removeChild(oldview);
						(oldview as View).destroy(true);
					}
					
				}
				openViewList = {};
			}
			
			if(viewDict[viewClass] == null)
				return;
			
			EventCenter.instance.event(EventCenter.OPEN_PANEL_VIEW,viewClass);
			
			if(openViewList[viewClass] != null)
			{
				closeView(viewClass);
				//return;
			}
				
			
			var view:View = new viewDict[viewClass]();
			view.param = params;
			view.zOrder = curZorder++;
//			var control:Script = view.getComponent(Script);
//			if(control != null)
//			control["param"] = params;
			
			viewContainer.addChild(view);
			openViewList[viewClass] = view;
		}
		
		public function closeView(viewClass:String):void
		{
			if(openViewList[viewClass] == null)
			{
				return;
				showAlert("不存在的界面");
			}
			viewContainer.removeChild(openViewList[viewClass]);
			(openViewList[viewClass] as View).destroy(true);
			openViewList[viewClass] = null;
			delete openViewList[viewClass];
			EventCenter.instance.event(EventCenter.COMMON_CLOSE_PANEL_VIEW,viewClass);

		}
		
		public function setViewVisible(viewname:String,visble:Boolean):void
		{
			if(openViewList[viewname] != null)
				(openViewList[viewname] as View).visible = visble;
		}
		
		public function getTopViewName():String
		{
			var curview:View = viewContainer.getChildAt(viewContainer.numChildren - 1) as View;
			
			var viewname:String = "";
			for(var viewclass in openViewList)
			{
				if(openViewList[viewclass] == curview)
				{
					viewname = viewclass;
					break;
				}
			}
			
			return viewname;
		}
	}
}
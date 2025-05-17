//
//全局消息注册与发送，用事件机制完成
//
package eventUtil
{
	
	import laya.events.EventDispatcher;
	
	/**客户端内部事件的派发和接受用这个*/
	public class EventCenter extends EventDispatcher 
	{
		public static const LOGIN_SUCESS:String = "LOGIN_SUCESS";
		
		public static const SELECT_FOLDER:String = "SELECT_FOLDER";
		
		public static const UPDATE_FILE_LIST:String = "UPDATE_FILE_LIST";
		
		public static const UPLOAD_FILE_SUCESS:String = "UPLOAD_FILE_SUCESS";

		public static const SELECT_PIC_ORDER:String = "SELECT_PIC_ORDER";
		
		public static const UPDATE_SELECT_FOLDER:String = "UPDATE_SELECT_FOLDER";

		public static const SELECT_ORDER_ADDRESS:String = "SELECT_ORDER_ADDRESS";
		public static const SELECT_OUT_ADDRESS:String = "SELECT_OUT_ADDRESS";//选择输出工厂
		
		public static const SELECT_DELIVERY_TYPE:String = "SELECT_DELIVERY_TYPE";//选择配送方式
		
		
		public static const ADD_PIC_FOR_ORDER:String = "ADD_PIC_FOR_ORDER";//新增图片下单
		public static const DELETE_PIC_ORDER:String = "DELETE_PIC_ORDER";//删除订单图片
		
		public static const SHOW_SELECT_TECH:String = "SHOW_SELECT_TECH";//打开选择工艺界面
		public static const UPDATE_ORDER_ITEM_TECH:String = "UPDATE_ORDER_ITEM_TECH";//选择工艺结束
		
		public static const ADJUST_PIC_ORDER_TECH:String = "ADJUST_PIC_ORDER_TECH";//自适应下单工艺修改
		
		
		public static const UPDATE_LOADING_PROGRESS:String = "UPDATE_LOADING_PROGRESS";//刷新加载进度
		
		public static const UPDATE_MYADDRESS_LIST:String = "UPDATE_MYADDRESS_LIST";//刷新我的地址列表
		
		public static const CANCAEL_UPLOAD_ITEM:String = "CANCAEL_UPLOAD_ITEM";//删除一个上传文件
		public static const RE_UPLOAD_FILE:String = "RE_UPLOAD_FILE";//重新上传文件
		
		public static const ADD_TECH_ATTACH:String = "ADD_TECH_ATTACH";//增加配件
		
		public static const BROWER_WINDOW_RESIZE:String = "BROWER_WINDOW_RESIZE";//浏览器窗口大小改变
		
		public static const BATCH_CHANGE_PRODUCT_NUM:String = "BATCH_CHANGE_PRODUCT_NUM";//批量修改数量
		
		public static const PAUSE_SCROLL_VIEW:String = "PAUSE_SCROLL_VIEW";//暂停滚动
		
		
		public static const OPEN_PANEL_VIEW:String = "OPEN_PANEL_VIEW";//打开界面消息
		public static const COMMON_CLOSE_PANEL_VIEW:String = "COMMON_CLOSE_PANEL_VIEW";//关闭界面消息
		
		public static const CLOSE_PANEL_VIEW:String = "CLOSE_PANEL_VIEW";//关闭界面消息
		public static const SHOW_CHARGE_VIEW:String = "SHOW_CHARGE_VIEW";//充值
		
		public static const PAY_ORDER_SUCESS:String = "PAY_ORDER_SUCESS";//支付成功
		
		public static const CANCEL_PAY_ORDER:String = "CANCEL_PAY_ORDER";//取消支付
		
		public static const CANCEL_CHOOSE_ATTACH:String = "CANCEL_CHOOSE_ATTACH";//取消选择附件
		
		public static const PRODUCT_DELETE_GOODS:String = "PRODUCT_DELETE_GOODS";//删除成品商品
		
		public static const PRODUCT_ADD_GOODS:String = "PRODUCT_ADD_GOODS";//加入成品商品到购物车
		
		public static const DELETE_ORDER_BACK:String = "DELETE_ORDER_BACK";//删除订单 返回
		
		
		public static const DELETE_ORGANIZE_BACK:String = "DELETE_ORGANIZE_BACK";//删除组织 返回
		
		public static const AGREE_JOIN_REQUEST:String = "AGREE_JOIN_REQUEST";//同意加入组织
		
		public static const REFRESH_JOIN_REQUEST:String = "REFRESH_JOIN_REQUEST";//刷新请求列表
		
		public static const MOVE_MEMBER_DEPT:String = "MOVE_MEMBER_DEPT";//移动组织成员
		public static const DELETE_DEPT_MEMBER:String = "DELETE_DEPT_MEMBER";//删除组织成员
		
		public static const SET_MEMEBER_AUTHORITY:String = "SET_MEMEBER_AUTHORITY";//设置权限
		
		
		public static const START_SELECT_YIXING_PIC:String = "START_SELECT_YIXING_PIC";//开始选择异形切割图
		public static const STOP_SELECT_RELATE_PIC:String = "STOP_SELECT_RELATE_PIC";//结束选择关联图
		public static const START_SELECT_BACK_PIC:String = "START_SELECT_BACK_PIC";//开始选择反面图
		public static const START_SELECT_PARTWHITE_PIC:String = "START_SELECT_PARTWHITE_PIC";//开始选择局部铺白图

		public static const UPDATE_PRICE_BY_DELIVERYDATE:String = "UPDATE_PRICE_BY_DELIVERYDATE";//更新价格，选择交货时间
		
		public static const CANCEL_CHARGE_RECORD:String  = "CANCEL_CHARGE_RECORD";
		
		public static const BATCH_CHANGE_OCCUPY_DATE:String  = "BATCH_CHANGE_OCCUPY_DATE";
		
		public static const UPDATE_SELECTED_FACTORY_PRODCATEGORY:String  = "UPDATE_SELECTED_FACTORY_PRODCATEGORY";
		
		public static const HIDE_U3D_DIV:String = "HIDE_U3D_DIV";//隐藏3d画面
		public static const SELECT_CARVING_ITEM:String = "SELECT_CARVING_ITEM";
		
		
		public static const INVOICE_SELECTED_CHANGE:String = "INVOICE_SELECTED_CHANGE";
		
		public static const UPDATE_INVOICE_LIST:String = "UPDATE_INVOICE_LIST";
		
		public static const SELECT_DAKOU_CELL:String = "SELECT_DAKOU_CELL";
		public static const BATCH_EDIT_DAKOU_CELL:String = "BATCH_EDIT_DAKOU_CELL";
		
		public static const CHANGE_ADDRESS_SELECTED_STATE:String = "CHANGE_ADDRESS_SELECTED_STATE";
		public static const CHANGE_ADDRESS_GROUP_SELECTED_STATE:String = "CHANGE_ADDRESS_GROUP_SELECTED_STATE";
		
		public static const UPDATE_ADDRESS_GROUP_LIST:String = "UPDATE_ADDRESS_GROUP_LIST";
		public static const INSERT_ADDRESS_TO_GROUP:String = "INSERT_ADDRESS_TO_GROUP";
		public static const DELETE_ADDRESS_FROM_GROUP:String = "DELETE_ADDRESS_FROM_GROUP";
		
		
		public static const UPDATE_PACKAGE_ORDER_ITEM_COUNT:String = "UPDATE_PACKAGE_ORDER_ITEM_COUNT";
		
		public static const SELECT_PACK_ADDRESS_OK:String = "SELECT_PACK_ADDRESS_OK";
		
		public static const DELETE_PACKAGE_ITEM:String = "DELETE_PACKAGE_ITEM";
		
		public static const SET_DEFAULT_PRODUCT:String = "SET_DEFAULT_PRODUCT";//设置默认材料
		
		public static const CREATE_FOLDER_SUCESS:String = "CREATE_FOLDER_SUCESS";//创建文件夹返回
		
		public static const SHOW_CONTENT_PANEL:String = "SHOW_CONTENT_PANEL";//修改首页右侧界面内容

		public static const FIRST_PAGE_SHRINK:String = "FIRST_PAGE_SHRINK";//首页收起展开变化

		
		public static const SELECT_PROCESS:String = "SELECT_PROCESS";//选择工艺
		public static const SHOW_MATERIAL_LIST_PANEL:String = "SHOW_MATERIAL_LIST_PANEL";//选择材料界面打开

		public static const SELECT_NEW_PROCESS:String = "SELECT_NEW_PROCESS";//刷新工艺列表界面
		
		public static const CHOOSE_PROCESS_ITEM:String = "CHOOSE_PROCESS_ITEM";//重新点击已选择的工艺

		public static const UPDATE_COMPANY_INFO:String = "UPDATE_COMPANY_INFO";//更新公司信息
		public static const UPDAE_USER_NAME:String = "UPDAE_USER_NAME";//更新用户名
		public static const UPDATE_RELATED_PIC:String = "UPDATE_RELATED_PIC";//更新关联图片效果

		
		//客户删除
		public static const UPDATE_CUSTOMER_LIST:String = "UPDATE_CUSTOMER_LIST";//
		public static const SELECT_CUSTOMER:String = "SELECT_CUSTOMER";//
		public static const EDIT_CUSTOMER_INFO:String = "EDIT_CUSTOMER_INFO";//

		
		public static const UPDATE_ORDER_PRICE:String = "UPDATE_ORDER_PRICE";//

		public static const DELETE_CUSTOMER_TRANSACTION:String = "DELETE_CUSTOMER_TRANSACTION";//
		public static const CUSTOMER_LIST_INIT_SUCESS:String = "CUSTOMER_LIST_INIT_SUCESS";//
		public static const CHANGE_WRITEOFF_ORDER_SELECTED:String = "CHANGE_WRITEOFF_ORDER_SELECTED";//

		public static const UPDATE_BUSINESSMAN_LIST:String = "UPDATE_BUSINESSMAN_LIST";//

		public static const UPDATE_CUSTOMER_BALANCE:String = "UPDATE_CUSTOMER_BALANCE";//更新客户余额

		private static var _eventCenter:EventCenter;
		
		
		
		public static function get instance():EventCenter
		{
			if(_eventCenter == null)
			{
				_eventCenter = new EventCenter(new SingleForcer());
			}
			
			return _eventCenter;
		}
		
		public function EventCenter(force:SingleForcer)
		{
			
		}
		
	}
}

class SingleForcer{}

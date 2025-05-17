package model
{
	public class Constast
	{
		public static const ACCOUNT_CREATER:int = 1;//公司创建者
		public static const ACCOUNT_EMPLOYEE:int = 0;//公司职员
		
		public static const PRIVILEGE_PAYORDER_BY_SCAN:int = 1;//扫码支付权限
		public static const PRIVILEGE_PAYORDER_BY_AMOUNT:int  = 2;//余额支付权限
		public static const PRIVILEGE_HIDE_PRICE:int= 3;//隐藏价格

		public static const PRIVILEGE_CHECK_ORDERS:int= 4;//查看订单
		
		public static const PRIVILEGE_CHECK_TRANSACTION:int = 5;//查看账单


		public static const TYPE_NAME:Object = {"0":"","1":"充值","2":"账户余额支付订单","3":"退款","5":"取消异常订单","6":"直接支付订单","7":"撤单退款","8":"活动充值","10":"活动余额支付订单","11":"11扫码支付扩容","12":"余额支付扩容","13":"活动余额支付扩容","17":"撤单退款","77":"活动充值退款","100":"代客充值","101":"代充余额支付订单"};

		
		public static const ORDER_TIME_PREFER_URGENT = 1;//加急当天
		
		public static const ORDER_TIME_PREFER_EARLY = 2;//交期优先
		
		public static const STORAGE_PRICE:Object={"50":300,"60":360,"70":420,"80":480,"90":540,"100":600};
		
		public static const STORAGE_DAY_PRICE:Number = 0.5;
		
		public static const CMYK_GREEN:String = "#003DC6";
		
		public static const CMYK_BLACK:String = "#0";
		public static const CMYK_WHITE:String = "#FFFFFF";
		
		public static const FRESH_DISCOUNT:Number = 24;

		public static const ADMIN_PREVILIGE:String = "admin:org:manage";
		public static const DISPLAY_ORDER_PRICE:String = "order:price:display";
		public static const PAY_ORDER_ONLINE:String = "order:submit";//扫码支付权限
		public static const PAY_ORDER_BY_MONEY:String = "order:submit-with-balances";//余额支付

		public static const PREVILIGE_LIST:Array= ["order:submit","order:submit-with-balances","order:price:display","order:list:self","order:list:org","asset:log:list"];
		

		public static const PAY_TYPE_NAME:Array = ["预充","月结","现金"];

	}
}
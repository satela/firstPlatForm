package model.users
{
	import model.HttpRequestUtil;
	import model.orderModel.PaintOrderModel;

	public class FactoryInfoVo
	{
		public var addr:String = "";
		
		public var name:String = "";
		
		public var org_code:String = "";
		public var contactor:String = "";

		public var contact_phone:String = "";
		
		public var manu_priority:int = 0;//优先级
		
		public var isSelected:Boolean = true;
		
		public var promotion_desc:String= "";//代课充值活动信息
		
		public function FactoryInfoVo(fvo:Object)
		{
			for(var key in fvo)
				this[key] = fvo[key];
			if(PaintOrderModel.instance.allManuFacutreMatProcPrice[org_code] == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getManuFactureMatProcPrice + org_code,this,function(dataStr:*):void{
					
					PaintOrderModel.instance.initManuFacuturePrice(org_code,dataStr);
					
				},null,null);
			}
		}
	}
}
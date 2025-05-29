package model.users
{
	public class CustomVo
	{
		public var id:String;
		public var customerName:String;
		public var mobileNumber:String;
		public var salesmanId:String;

		public var businessManId:String;
		public var businessManName:String;
		public var businessManPhone:String;
		
		public var defaultPayment:int = 0;
		
		public var dirId:String;
		public var balance:String;
		public var salerName:String;
		public var salerId:String;
		public var balanceMoney:Number;
		public var discount:String;//客户折扣

		public function CustomVo(data:Object)
		{
			if(data != null)
			{
				for(var key in data)
				{
					if(this.hasOwnProperty(key))
						this[key] = data[key];
				}
				balanceMoney = parseFloat(balance);
			}
		}
	}
}
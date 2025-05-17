package model.users
{
	public class CustomerTransactionVo
	{
		public var id:String;
		public var customerId:String;
		public var customerName:String;
		public var userName:String;
		public var amount:String;
		public var transactionId:String;
		public var transactionSn:String;
		public var transactionType:String;
		public var transactionTypeName:String;
		public var transactionChannel:String;
		public var transactionTime:String;
		public var comment:String;

		public function CustomerTransactionVo(data:Object)
		{
			if(data != null)
			{
				for(var key in data)
				{
					if(this.hasOwnProperty(key))
						this[key] = data[key];
				}
			}
		}
	}
}
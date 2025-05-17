package model.users
{
	public class AddressGroupVo
	{
		public var groupId:int;
		public var groupName:String;
		public var count:int = 0;
		
		public var customerId:String;
		
		
		public var selected:Boolean = false;
		public function AddressGroupVo(data:Object)
		{
			groupId = data.id;
			groupName = data.name;
			count = parseInt(data.expressCount);	
			customerId = data.customerId;
		}
	}
}
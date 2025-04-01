package model.users
{
	public class CustomVo
	{
		public var id:int;
		public var customerName:String;
		public var mobileNumber:String;
		public var salesmanId:String;

		public var dirId:String;
		public function CustomVo(data:Object)
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
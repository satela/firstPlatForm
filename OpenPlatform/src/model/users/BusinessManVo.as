package model.users
{
	public class BusinessManVo
	{
		public var name:String;
		public var id:String;
		public var mobileNumber:String;
		public function BusinessManVo(data:Object)
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
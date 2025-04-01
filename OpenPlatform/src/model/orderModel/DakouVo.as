package model.orderModel
{
	public class DakouVo
	{
		public var finalWidth:Number;
		public var finalHeight:Number; 
		public var fid:String;
		
		public var orderitemvo:PicOrderItemVo; 
		
		public var holeMargin:Number = 1;

		public var leftHoles:Array = [];
		public var rightHoles:Array = [];
		public var upHoles:Array = [];
		public var bottomHoles:Array = [];

		
		public function DakouVo()
		{
		}
		
		
	}
}
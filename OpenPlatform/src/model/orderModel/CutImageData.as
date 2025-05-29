package model.orderModel
{
	//超幅拼接数据
	public class CutImageData
	{
		public var orderitemvo:PicOrderItemVo;
		
		public var finalWidth:Number;
		public var finalHeight:Number;
		public var fid:String;
		public var maxwidth :Number;
		public var maxlength :Number;
		public var border :Number;
		public var cutLength:Array = [];//可选择的切割长度
		public function CutImageData()
		{
		}
	}
}
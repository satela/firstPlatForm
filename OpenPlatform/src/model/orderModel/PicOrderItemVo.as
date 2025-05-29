package model.orderModel
{
	import model.picmanagerModel.PicInfoVo;

	public class PicOrderItemVo
	{
		public var indexNum:int;
		public var picinfo:PicInfoVo;
		
		public var materialID:int;//材料id
		
		public var materialName:String;//材料名称
		
		public var orderData:Object; //最早下单的数据
		
		public var orderPrice:Number = 0;//该单的单价
		
		public var noDiscountOrderPrice:Number = 0;//该单不打折的单价

		public var manufacturer_code:String;//输出中心编码
		public var manufacturer_name:String;//输出中心编码

		public var productVo:ProductVo;
		
//		public var editWidth:Number;
//		
//		public var editHeight:Number;
//
//		public var technolegs:Array;
		
		public var techStr:String = "";
		
		//public var vipPrice:Number;
		
		//public var price:Number;
		
		//public var paitNum:int = 1;//下单数量
		
	//	public var totalPrice:Number;
		
		public var comment:String = "";
		
		public var cuttype:int = 0;//裁切类型
		public var hCutnum:int = 0;//横向裁切数
		public var vCutnum:int = 0;//纵向裁切数

		public var cutDirect:int = 0;// 
		public var hEachCutLength:Array;//横向裁切长度列表
		public var vEachCutLength:Array;//纵向裁切长度列表

		public var horiCutNum:int = 1;
		public var verCutNum:int = 1;
		
		//public var dakouNum:int = 1;
		//public var dkleftpos:int = 5;//左边打扣位置
		
		//public var dkrightpos:int = 50;//右边打扣位置
		//public var holeMargin:Number = 1;
		
		public var holeList:Array = [];
//		public var rightHoles:Array = [];
//		public var upHoles:Array = [];
//		public var bottomHoles:Array = [];

		public var type:int = 0;
		
		public static const PAINT_ITEM:int = 0;
		public static const LAILIAO_ITEM:int = 1;
		public static const DENGXIANG_ITEM:int = 2;

		public function PicOrderItemVo(picvo:PicInfoVo,orderType = 0)
		{
			picinfo = picvo;
			type = orderType;
			
		}
	}
}
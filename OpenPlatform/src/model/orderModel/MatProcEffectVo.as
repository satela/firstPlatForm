package model.orderModel
{
	public class MatProcEffectVo
	{
		public var finalWidth:Number;
		public var finalHeighth:Number;
		
		public var imageUrl:String;
		
		public var yixingImageUrl:String;
		
		public var partWhiteImageUrl:String;
		
		public var matType:int = 1;
		
		//public var partWhite:Boolean;
		public var backImageUrl:String;

		public var whiteFillType:int = 0;
		public var colorType:int = 0;
		
		public var imageType:int = 0;
		

		public var mirrorImage:int = 1;
		public static const WHITE_FILL_TYPE_NONE = 0;
		public static const WHITE_FILL_TYPE_FULL_WHITE = 1;//满铺白
		public static const WHITE_FILL_TYPE_PART_WHITE = 2;//局部铺白
		public static const WHITE_FILL_TYPE_COLOR_WHITE = 3;//有色铺白
		
		public static const COLOR_TYPE_NONE = 0;
		public static const COLOR_TYPE_FULL_COLOR = 1;//全彩
		public static const COLOR_TYPE_COLOR_WHITE = 2;//彩白
		public static const COLOR_TYPE_COLOR_WHITE_COLOR = 3;//彩白彩
		public static const COLOR_TYPE_WHITE_COLOR = 4;//白彩
		public static const COLOR_TYPE_PURE_WHITE = 5;//纯白

		public static const IMAGE_TYPE_NONE = 0;
		public static const IMAGE_TYPE_JPG = 1;//
		public static const IMAGE_TYPE_JPEG = 2;//
		public static const IMAGE_TYPE_PNG = 3;//


		public function MatProcEffectVo()
		{
		}
	}
}
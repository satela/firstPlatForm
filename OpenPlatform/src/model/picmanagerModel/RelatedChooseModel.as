package model.picmanagerModel
{
	public class RelatedChooseModel
	{
		private static var _instance:RelatedChooseModel;
		
		public var curOriginFile:PicInfoVo;
		
		public var curRelatedFile:PicInfoVo;

		public function RelatedChooseModel()
		{
		}
		
		public static function get instance():RelatedChooseModel
		{
			if(_instance == null)
				_instance = new RelatedChooseModel();
			return _instance;
		}
		
		public function resetData():void
		{
			curOriginFile = null;
			curRelatedFile = null;
		}
		
	}
}
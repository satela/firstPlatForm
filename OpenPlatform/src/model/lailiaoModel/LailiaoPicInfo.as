package model.lailiaoModel
{
	import model.picmanagerModel.PicInfoVo;
	
	public class LailiaoPicInfo extends PicInfoVo
	{
		public function LailiaoPicInfo(fileinfo:Object, dtype:int,prodName:String)
		{
			super(fileinfo, dtype);
			this.fid = "-1";
			this.picPhysicWidth = 100;
			this.picPhysicHeight = 100;
			this.connectnum = 0;
			this.iswhitebg = false;
			this.relatedPicWidth = 0;
			this.relatedRoadLength = 0;
			this.relatedRoadNum = 0;
			this.roadLength = 0;
			this.roadNum = 0;
			this.directName = prodName;

		}
	}
}
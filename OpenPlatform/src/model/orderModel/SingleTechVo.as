package model.orderModel
{
	public class SingleTechVo
	{
		public var techId:int = 0;
		public var techName:String = "蓝色包边";
		
		public var needAttach:Boolean = false;
		
		public function SingleTechVo()
		{
			var index:int = Math.floor(5*Math.random());
			techName = ["蓝色包边","3毫米PVC板","不裁剪","中金边","画面正上方打孔"][index];
		}
	}
}
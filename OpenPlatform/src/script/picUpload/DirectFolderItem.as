package script.picUpload
{
	
	import laya.events.Event;
	
	import model.picmanagerModel.PicInfoVo;
	
	import ui.picManager.DirectItemUI;
	
	public class DirectFolderItem extends DirectItemUI
	{
		private var isSeleted:Boolean = false;
		
		public var directData:PicInfoVo;
		
		public function DirectFolderItem()
		{
			super();
		}
		
		public function setData(filedata:Object):void
		{
			directData = filedata as PicInfoVo;
			this.foldname.text = (filedata as PicInfoVo).directName;
			
			this.on(Event.MOUSE_OVER,this,onMouseOver);
			this.on(Event.MOUSE_OUT,this,onMouseOut);
			//this.on(Event.CLICK,this,onMouseClick);

		}
		
		
		
		public function set ShowSelected(value:Boolean):void
		{
			isSeleted = value;
			if(value)
				this.foldname.color = "#FF0000";
			else				
				this.foldname.color = "#FFFFFF";

		}
		private function onMouseOut():void
		{
			if(isSeleted)
				return;
			// TODO Auto Generated method stub
			this.foldname.color = "#FFFFFF";

		}
		
		private function onMouseOver():void
		{
			if(isSeleted)
				return;
			// TODO Auto Generated method stub
			this.foldname.color = "#FF0000";
		}
	}
}
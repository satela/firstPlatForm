package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import ui.uploadpic.UpLoadItemUI;
	
	public class FileUpLoadItem extends UpLoadItemUI
	{
		public var fileobj:Object;
		private var fileSize:Number;
		private var unit:String;
		public function FileUpLoadItem()
		{
			super();
		}
		
		public function setData(filedata:Object):void
		{
			fileobj = filedata;
			this.filename.text = filedata.name;
			this.prog.text = "0%";
			this.finishimg.visible = false;
			var mm:int =  Math.floor(filedata.size/(1024*1024));
			//var kk:Number = (filedata.size%(1024*1024))/1024;
			//var bytes:
			var sizestr:String = "";
			if(mm > 0)
			{
				sizestr = (filedata.size/(1024*1024)).toFixed(2).toString() + "m";
				fileSize = (filedata.size/(1024*1024));
				unit = "m";

			}
			else
			{
				sizestr = ((filedata.size/1024).toFixed(2)).toString() + "k";
				fileSize = filedata.size/1024;
				unit = "k";

			}
			
				
			this.reUploadBtn.visible = false;

			this.unnormal.visible = filedata.unNormal;
			//this.prgbar.width = 0;
			this.prog.text = 0 + unit + "/" + fileSize.toFixed(2) + unit;;
			this.btncancel.on(Event.CLICK,this,onCancelUpload);
			this.reUploadBtn.on(Event.CLICK,this,onReUpload);

			updateProgress();
		}
		
		public function showReUploadbtn():void
		{
			this.reUploadBtn.visible = true;
		}
		
		private function onReUpload():void
		{
			EventCenter.instance.event(EventCenter.RE_UPLOAD_FILE,this);

		}
		private function onCancelUpload():void
		{
			EventCenter.instance.event(EventCenter.CANCAEL_UPLOAD_ITEM,this);
		}
		public function updateProgress(isbegin:Boolean = false):void
		{
			if(fileobj == null)
				return;
			
			if(isbegin)
			{
				this.isuploading.color = "#BF6A2C";
				this.isuploading.text = "正在上传...";

			}
			
			var pp:Number = Number(fileobj.progress);
			if(pp >= 100)
			{
				pp = 100;
				this.finishimg.visible = true;
				this.prog.visible = false;
			}
			else
				this.prog.visible = true;
			this.prgbar.width = pp/100 * 1614;
			
			var curfinish:String = (fileSize * pp/100).toFixed(2) + unit;
			this.prog.text = curfinish + "/" + fileSize.toFixed(2) + unit;;
		}
	}
}
package script.prefabScript
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.TextInput;
	
	public class CmykInputControl extends Script
	{
		private var uiSkin:Image;
		private var input:TextInput;
		private var del:Button;
		public function CmykInputControl()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiSkin = this.owner as Image;
			 input = uiSkin.getChildByName("inputTxt") as TextInput;
			
			  del = uiSkin.getChildByName("delBtn") as Button;
			 del.on(Event.CLICK,this,function(e:Event){
				 
				 if(input.editable)
				 {
					 input.text = "";
					 e.stopPropagation();
					 input.focus = true;
				 }
			 });
			 del.visible = false;

			input.on(Event.BLUR,this,onFocusOut);
			input.on(Event.FOCUS,this,onFocus);
			input.on(Event.INPUT,this,function(){
				
					del.visible = input.text != "";
			});

		}
		
		public function showError(msg:String):void
		{
			(uiSkin.getChildByName("errorlbl") as Label).visible = true;
			(uiSkin.getChildByName("errorlbl") as Label).text = msg;
		}
		private function onFocus(e:Event):void
		{
			uiSkin.skin = "commers/inputfocus.png";
			del.visible = input.text != "";
		}
		private function onFocusOut(e:Event):void
		{
			Laya.timer.once(500,this,function(){
				if(del != null)
					del.visible = false;
			
			});
				
			uiSkin.skin =  "commers/inputbg.png";
		
		}
	}
}
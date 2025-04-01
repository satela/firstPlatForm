package script.order
{	
	import laya.events.Event;
	import laya.ui.TextInput;
	
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import ui.order.OrderPackageItemUI;
	import ui.usercenter.OderDetailPanelUI;
	
	public class OrderPackItem extends OrderPackageItemUI
	{
		public var orderdata:Object;
		public function OrderPackItem()
		{
			super();
			
			this.numinput0.type = "";
			this.numinput0.restrict = "0-9";
			this.numinput0.mouseEnabled = false;
			
			for(var i:int=1;i < OrderConstant.packagemaxCout;i++)
			{
				this["box"+i].visible = false;
				
				(this["numinput"+i] as TextInput).type = "";
				(this["numinput"+i] as TextInput).restrict = "0-9";
				
				(this["numinput"+i] as TextInput).on(Event.INPUT,this,onChangeNums,[i]);
				
				(this["numinput"+i] as TextInput).on(Event.FOCUS,this,onSelectInput,[i]);
				

				
				this["addbtn"+i].on(Event.CLICK,this,onaddnum,[i]);
				this["subbtn"+i].on(Event.CLICK,this,onsubnum,[i]);

			}
			
			this.averagebtn.on(Event.CLICK,this,onAverageNum);
		}
		
		public function setData(data:*):void
		{
			
			//this.numindex.text = data.item_seq.toString();
			
			orderdata = data;
			
			this.fileimg.skin = data.previewImage_path;
			
			
			var size:Array = data.LWH.split("/");
			
			var picwidth:Number = parseFloat(size[0]);
			var picheight:Number = parseFloat(size[1]);
			
			if(picwidth > picheight)
			{
				this.fileimg.width = 100;					
				this.fileimg.height = 100/picwidth * picheight;
				
			}
			else
			{
				this.fileimg.height = 100;
				this.fileimg.width = 100/picheight * picwidth;
				
			}
			
			this.filenametxt.text = data.filename;
			
			this.mattext.text = data.prod_name;
			
			for(var i:int=0;i < OrderConstant.packagemaxCout;i++)
			{
				//this["box"+i].visible = false;
				
				(this["numinput"+i] as TextInput).text = data.numlist[i] + ""
											
			}
							
			
		}
		
		private function onAverageNum():void
		{
			var total:int = 0;
			for(var i:int=0;i < orderdata.numlist.length;i++)
				total += orderdata.numlist[i];
			
			var average:int = Math.floor(total/PaintOrderModel.instance.packageList.length);
			var left:int = total - average*PaintOrderModel.instance.packageList.length;
			
			orderdata.numlist[0] = average + left;
			for(var i:int=1;i < PaintOrderModel.instance.packageList.length;i++)
				orderdata.numlist[i] = average;
			
			for(var i:int=0;i < OrderConstant.packagemaxCout;i++)
			{				
				this["numinput" + i].text = orderdata.numlist[i] + "";
			}
			
		}
		
		private function onChangeNums(index:int):void
		{
			var curnumInput:TextInput = (this["numinput" + index] as TextInput);
			
			if(curnumInput.text == "")
			{
				curnumInput.text = "0";
			}
			var curnum:int = parseInt(curnumInput.text);
			
			var othertotal:int = 0;
			
			var maxnum:int = orderdata.numlist[0] + orderdata.numlist[index];
			if(curnum > maxnum)
			{
				curnum = maxnum;
			
				orderdata.numlist[0] = 0;
				orderdata.numlist[index] = curnum;
				
				this.numinput0.text = "0";
				curnumInput.text = curnum + "";
			}
			else
			{
				orderdata.numlist[0] = maxnum - curnum;
				orderdata.numlist[index] = curnum;
				
				this.numinput0.text = orderdata.numlist[0] + "";

			}
		}
		
		
		private function onSelectInput(index:int):void
		{
			(this["numinput" + index] as TextInput).select();
		}
		
		public function addpacakge():void
		{
			var curpackcount:int = PaintOrderModel.instance.packageList.length - 1;
			
			this["box"+curpackcount].visible = true;
			
			this["numinput" + curpackcount].text = "0";
		}
		public function deletepack(packindex:int):void
		{
			if(orderdata == null)
				return;
			
			
			for(var i:int=0;i < OrderConstant.packagemaxCout;i++)
			{				
				this["box"+i].visible = i < PaintOrderModel.instance.packageList.length;
				this["numinput" + i].text = orderdata.numlist[i] + "";
			}
		}
		private function onaddnum(index:int):void
		{
			if(orderdata.numlist[0] > 0)
			{
				var curnum:int = parseInt(this["numinput" + index].text);
				curnum++;
				
				orderdata.numlist[index]  = curnum;
					
				this["numinput" + index].text = curnum + "";
				
				var firstnum:int = parseInt(this.numinput0.text);
				firstnum--;
				orderdata.numlist[0]  = firstnum;

				this.numinput0.text = firstnum +"";
			}
		}
		
		private function onsubnum(index:int):void
		{
			
				var curnum:int = parseInt(this["numinput" + index].text);
				if(curnum < 1)
					return;
				
				curnum--;
				orderdata.numlist[index]  = curnum;

				this["numinput" + index].text = curnum + "";
				
				var firstnum:int = parseInt(this.numinput0.text);
				firstnum++;
				orderdata.numlist[0]  = firstnum;

				this.numinput0.text = firstnum + "";
			
		}
		
	}
}
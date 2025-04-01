package script.order
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.ui.TextInput;
	
	import model.orderModel.PackageItem;
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.PackageEditItemUI;
	import ui.order.PackageNumItemUI;
	
	public class PackageEditCell extends PackageEditItemUI
	{
		private var packageVo:PackageVo;
		public function PackageEditCell()
		{
			super();
			
			this.deletebtn.on(Event.CLICK,this,onDeletePackage);
			this.comment.maxChars = 16;
			this.comment.on(Event.INPUT,this,onChangeComment);
		}
		private function onChangeComment():void
		{
			packageVo.packageName = this.comment.text;
		}
		public function setData(data:*):void
		{
			packageVo = data;
			this.addresstxt.text = packageVo.address.receiverName + "-" + packageVo.address.phone;
			
			this.comment.text = packageVo.packageName;
			
			while(this.itembox.numChildren > 0)
			this.itembox.removeChildAt(0);
			for(var i:int=0;i < packageVo.itemlist.length;i++)
			{
				var numitem:PackageNumItemUI = new PackageNumItemUI();
				numitem.numInput.text = packageVo.itemlist[i].itemCount + "";
				
				if(PaintOrderModel.instance.packageList.indexOf(packageVo) == 0 || PaintOrderModel.instance.packageList.indexOf(packageVo) == 1)
				{
					numitem.numInput.editable = false;
					numitem.addBtn.visible = false;
					numitem.subBtn.visible = false;

				}
				else
				{
					numitem.numInput.editable = true;
					numitem.addBtn.visible = true;
					numitem.subBtn.visible = true;
				}

				numitem.addBtn.on(Event.CLICK,this,onaddnum,[numitem.numInput,packageVo.itemlist[i]]);
				numitem.subBtn.on(Event.CLICK,this,onsubnum,[numitem.numInput,packageVo.itemlist[i]]);
				
				numitem.numInput.on(Event.INPUT,this,onChangeNums,[numitem.numInput,packageVo.itemlist[i]]);
				
				numitem.numInput.on(Event.FOCUS,this,onSelectInput,[numitem.numInput]);
				
				this.itembox.addChild(numitem);
			}
			
			this.cutline.height = 140*packageVo.itemlist.length + 110;
		}
		
		private function onaddnum(textInput:TextInput,packageItem:PackageItem):void
		{
			var firstpackage:PackageVo = PaintOrderModel.instance.packageList[1];
			for(var i:int=0;i < firstpackage.itemlist.length;i++)
			{
				if(firstpackage.itemlist[i].itemId == packageItem.itemId)
				{
					if(firstpackage.itemlist[i].itemCount > 0)
					{
						var curnum:int = parseInt(textInput.text);
						curnum++;
						
						packageItem.itemCount  = curnum;
						
						textInput.text = curnum + "";
						
						firstpackage.itemlist[i].itemCount--;
						
						EventCenter.instance.event(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT);
					}
					break;
				}
			}
		}
			
		
		private function onsubnum(textInput:TextInput,packageItem:PackageItem):void
		{
			
			var curnum:int = parseInt(textInput.text);
			if(curnum < 1)
				return;
			
			curnum--;
			packageItem.itemCount  = curnum;
			
			textInput.text = curnum + "";
			
			var firstpackage:PackageVo = PaintOrderModel.instance.packageList[1];
			for(var i:int=0;i < firstpackage.itemlist.length;i++)
			{
				if(firstpackage.itemlist[i].itemId == packageItem.itemId)
				{
					firstpackage.itemlist[i].itemCount++;
					break;

				}
			}
			EventCenter.instance.event(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT);

		}
		
		private function onChangeNums(curnumInput:TextInput,packageItem:PackageItem):void
		{
			
			
			if(curnumInput.text == "")
			{
				curnumInput.text = "0";
			}
			var curnum:int = parseInt(curnumInput.text);
			if(curnum < 0)
				curnum = 0;
			
			var othertotal:int = 0;
			var firstpackage:PackageVo = PaintOrderModel.instance.packageList[1];
			for(var i:int=0;i < firstpackage.itemlist.length;i++)
			{
				if(firstpackage.itemlist[i].itemId == packageItem.itemId)
				{
					var maxnum:int = packageItem.itemCount + firstpackage.itemlist[i].itemCount;
					if(curnum > maxnum)
					{
						curnum = maxnum;
						
						firstpackage.itemlist[i].itemCount = 0;
						packageItem.itemCount = curnum;
						
						
						curnumInput.text = curnum + "";
					}
					else
					{
						firstpackage.itemlist[i].itemCount = maxnum - curnum;
						packageItem.itemCount = curnum;
						
						curnumInput.text = curnum + "";
						
					}
					break;

				}
			}
			EventCenter.instance.event(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT);

		}
		
		
		private function onSelectInput(textInput:TextInput):void
		{
			textInput.select();
		}
		
		
		public function updateNum():void
		{
			for(var i:int=0;i < itembox.numChildren;i++)
			{
				(itembox.getChildAt(i) as PackageNumItemUI).numInput.text = packageVo.itemlist[i].itemCount + "";
			}
		}
		
		private function onDeletePackage():void
		{
			var index:int = PaintOrderModel.instance.packageList.indexOf(this.packageVo);
			if(index == 0)
			{
				ViewManager.showAlert("第一个包裹不能删");
				return;
			}
			var pack:PackageVo = PaintOrderModel.instance.packageList[1];
			if(index == 1 && PaintOrderModel.instance.packageList.length > 2)
				pack = PaintOrderModel.instance.packageList[2];
			else if(index == 1 && PaintOrderModel.instance.packageList.length <= 2)
				pack = PaintOrderModel.instance.packageList[0];
			for(var i:int=0;i < pack.itemlist.length;i++)
			{
				
				pack.itemlist[i].itemCount += this.packageVo.itemlist[i].itemCount;
				
			}
			PaintOrderModel.instance.packageList.splice(index,1);
			
			EventCenter.instance.event(EventCenter.DELETE_PACKAGE_ITEM);
		}
	}
}
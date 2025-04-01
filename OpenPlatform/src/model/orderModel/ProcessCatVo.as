package model.orderModel
{
	import model.HttpRequestUtil;
	
	import script.order.PicOrderItem;

	//工艺类vo
	public class ProcessCatVo
	{
		public var procCat_Seq: int = 0;// 工艺类顺序
		public var procCat_Name: String = "";// 工艺类名称

		public var selected:Boolean = false;
		public var nextMatList:Vector.<MaterialItemVo>;
		public function ProcessCatVo(data:Object)
		{
			for(var key in data)
			{
				if(this.hasOwnProperty(key))
				this[key] = data[key];
			}
			
//			var manufacturecode = PaintOrderModel.instance.curSelectMat.manufacturer_code;
//			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProcessFlow + manufacturecode + "&procCat_name=" + procCat_Name,this,function(data:Object):void{
//				
//				var result:Object = JSON.parse(data as String);
//				if(!result.hasOwnProperty("status"))
//				{
//					Laya.timer.once(100,this,function(){
//					PaintOrderModel.instance.curSelectProcList = result as Array;
//					initProcFlow(result);});
//					//onClickMat(parentitem,processCatvo);
//				}
//				
//			},null,null);
		}
		
		public function cloneData(product:ProductVo,picorder:PicOrderItem):ProcessCatVo
		{
			var process:ProcessCatVo = new ProcessCatVo(this);
			
			var materialList:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
			for(var i:int=0;i < this.nextMatList.length;i++)
			{
				materialList.push(this.nextMatList[i].cloneData(product,picorder));
			}
			process.nextMatList = materialList;
			return process;
			
		}
		
		public function initProcFlow(flowdata:Object):void
		{
			var proclist:Array = flowdata as Array;
			nextMatList = new Vector.<MaterialItemVo>();
			for(var i:int=0;i < proclist.length;i++)
			{
				//if(proclist[i].procLvl  == 1)
				{
					if(proclist[i].is_startProc == "是")
						nextMatList.push(new MaterialItemVo(proclist[i]));
				}
			}
//			for(var i:int=0;i < nextMatList.length;i++)
//			{
//				if(nextMatList[i].is_mandatory == 1)
//				{
//					nextMatList[i].selected = true;
//					break;
//				}
//			}
		}
		
		public function get isMandatory():Boolean
		{
			if(nextMatList == null)
				return false;
			for(var i:int=0;i < nextMatList.length;i++)
			{
				if(nextMatList[i].nextProcRequired == 1)
					return true;
			}
			return false;
		}
		public function resetData():void
		{
			selected = false;
			if(nextMatList != null)
			{
				for(var i:int=0;i < nextMatList.length;i++)
				{
					nextMatList[i].resetData();
				}
			}
		}
	}
}
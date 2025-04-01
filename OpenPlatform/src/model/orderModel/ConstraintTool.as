package model.orderModel
{	
	
	import script.order.PicOrderItem;

	public class ConstraintTool
	{
		public static const PIC_WIDTT:String = "width";//宽度
		public static const PIC_HEIGHT:String = "height";//高度
		public static const PIC_LENGTH:String = "length";//周长
		public static const PIC_AREA:String = "area";//周长
		public static const LONG_SIDE:String = "long_side";//长边
		public static const SHORT_SIDE:String = "short_side";//窄边

		public static const IMAGE_FILE_TYPE:String = "img_file_type";//窄边

		
		public static const GREATER:String = "1";//大于等于
		public static const LESS:String = "2";//小于等于
		public static const EQUAL:String = "3";//等于

		public static const UNEQUAL:String = "4";//不等于
		
		public static const CONTAIN:String = "5";//包含
		
		public static const UNCONTAIN:String = "6";//不包含

		


		public static const RESULT_VALUE_HIDE:String = "1";//隐藏
		
		public static const RESULT_VALUE_FREEZE:String = "2";//冻结
		
		public static const RESULT_VALUE_SELETED:String = "3";//必须

		public static const RESULT_VALUE_NORMAL:String = "4";//正常显示

		public static const CONSTRAINT_TYPE_MATERIAL:int = 1;//材料配件限制条件
		public static const CONSTRAINT_TYPE_PROCESS:int = 2;//工艺限制条件
		public static const CONSTRAINT_TYPE_PIC:int = 3;//图片限制条件

		public function ConstraintTool()
		{
		}
		
		public static function procShowType(accocessCondition:Array,constaint:Array,procCondition:Array,picorderItem:PicOrderItem,procTree:Array=null,extraValue:Number=0):String
		{
			
			
			var materialCondtionResult:int = -1;
			if(accocessCondition.length > 0)
				materialCondtionResult = getConditionResult(accocessCondition,CONSTRAINT_TYPE_MATERIAL,picorderItem,procTree,extraValue)?1:0;
			
			var procCondtionResult:int = -1;
			if(procCondition.length > 0)
				procCondtionResult = getConditionResult(procCondition,CONSTRAINT_TYPE_PROCESS,picorderItem,procTree,extraValue)?1:0;
			
			var picCondtionResult:int = -1;
			if(constaint.length > 0)
				picCondtionResult = getConditionResult(constaint,CONSTRAINT_TYPE_PIC,picorderItem,procTree,extraValue)?1:0;
			
			if(materialCondtionResult + procCondtionResult + picCondtionResult == -3)
				return RESULT_VALUE_NORMAL;
			else if(materialCondtionResult == 1)
				return accocessCondition[0].result;
			else if(procCondtionResult == 1)
				return procCondition[0].result;
			else if(picCondtionResult == 1)
				return constaint[0].result;
			else if(materialCondtionResult == 0 && accocessCondition[0].result == RESULT_VALUE_NORMAL)
				return RESULT_VALUE_FREEZE;
			else if(procCondtionResult == 0 && procCondition[0].result == RESULT_VALUE_NORMAL)
				return RESULT_VALUE_FREEZE;
			else if(picCondtionResult == 0 && constaint[0].result == RESULT_VALUE_NORMAL)
				return RESULT_VALUE_FREEZE;
			else
				return RESULT_VALUE_NORMAL;
			
			//return false;
		}
		
		
		private static function getConditionResult(conditionList:Array,constraiType:int,picorderItem:PicOrderItem,procTree:Array=null,extraValue:Number=0):Boolean
		{
			var groupResult:Object = {};
			for(var i:int=0;i < conditionList.length;i++)
			{
				var reslut:Boolean = getSingleConditionResult(conditionList[i],constraiType,picorderItem,procTree,extraValue);
				if(groupResult.hasOwnProperty(conditionList[i].group))
				{
					groupResult[conditionList[i].group].push(reslut);
				}
				else
				{
					groupResult[conditionList[i].group] = [];
					groupResult[conditionList[i].group].push(reslut);
				}
					
			}
			var reslutArray:Array = [];
			for each(var group in groupResult)
			{
				reslutArray.push(group.indexOf(false) < 0);
			}
			
			return reslutArray.indexOf(true) >= 0;
			
		}
		
		private static function getSingleConditionResult(constraint:ProcConstainVo,constraiType:int,picorderItem:PicOrderItem,procTree:Array=null,extraValue:Number=0):Boolean
		{
			if(constraint.key == IMAGE_FILE_TYPE)
			{
				if(constraint.operator == EQUAL)
					return picorderItem.ordervo.picinfo.picClass.toUpperCase() == constraint.value.toUpperCase();
				else
					return picorderItem.ordervo.picinfo.picClass.toUpperCase() != constraint.value.toUpperCase();
			}
			var param:Number = getValue(constraint.key,picorderItem,procTree) + extraValue;
			if(constraint.operator == GREATER)
			{
				return param >= Number(constraint.value);									
			}
			else if(constraint.operator == LESS)
			{
				return param <= Number(constraint.value);									
			}
			else if(constraint.operator == EQUAL)
			{
				return param == Number(constraint.value);									
			}
			else if(constraint.operator == UNEQUAL)
			{
				return param != Number(constraint.value);							
			}
			else if(constraint.operator == CONTAIN && constraiType == 1)
			{
				return containAttachOrMaterial(constraint.matCode,procTree);
			}
			else if(constraint.operator == UNCONTAIN && constraiType == 1)
			{
				return !containAttachOrMaterial(constraint.matCode,procTree);
			}
			else if(constraint.operator == CONTAIN && constraiType == 2)
			{
				return containProcess(constraint.procCode,procTree);
			}
			else if(constraint.operator == UNCONTAIN && constraiType == 2)
			{
				return !containProcess(constraint.procCode,procTree);
			}
			
			return false;
		}
		
		private static function containAttachOrMaterial(prodCode:String,procTree:Array):Boolean
		{
			var allAttchList:Array = getAttach(procTree);
			return allAttchList.indexOf(prodCode) >= 0;
			
		}
		
		private static function getAttach(procTree:Array):Array
		{
			var allAttchList:Array = [];

			for(var i:int=0;i < procTree.length;i++)
			{
				
					if(procTree[i].selectAttachVoList != null && procTree[i].selectAttachVoList.length >0 )
						allAttchList.push(procTree[i].selectAttachVoList[0].accessory_code);
				
			}
			return allAttchList;
		}
		
		private static function containProcess(procCode:String,procTree:Array):Boolean
		{
			var allProcess:Array = getProcess(procTree);
			return allProcess.indexOf(procCode) >= 0;
			
		}
		
		private static function getProcess(procTree:Array):Array
		{
			var allProcessList:Array = [];
			
			for(var i:int=0;i < procTree.length;i++)
			{
				
					
					 allProcessList.push(procTree[i].procCode);
					//allProcessList = allProcessList.concat(getProcess(procTree[i].nextMatList));
				
			}
			return allProcessList;
		}
		
		private static function getValue(key:String,picorderItem:PicOrderItem,procTree:Array):Number
		{
			if(key == LONG_SIDE)
			{
				return Math.max(picorderItem.finalWidth,picorderItem.finalHeight);
			}
			else if(key == PIC_WIDTT)
			{
				return picorderItem.finalWidth;
			}
			else if(key == PIC_HEIGHT)
			{
				return picorderItem.finalHeight;
			}
			else if(key == PIC_LENGTH)
			{
				return 2*(picorderItem.finalWidth + picorderItem.finalHeight);
			}
			else if(key == PIC_AREA)
			{
				return picorderItem.finalWidth * picorderItem.finalHeight;
			}
			else if(key == SHORT_SIDE)
			{
				return Math.min(picorderItem.finalWidth,picorderItem.finalHeight);
			}
			
			return 0;
		}
	}
}
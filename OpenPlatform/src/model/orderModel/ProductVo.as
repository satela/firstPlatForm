package model.orderModel
{
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.MaterialItemVo;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.order.PicOrderItem;
	
	import utils.UtilTool;

	//产品列表 vo
	public class ProductVo
	{
		public var  prodCode:String = "";//  产品编码
		public var  prodName:String = "";// 产品名称
		public var  minLength:Number = 0;//  最小长度
		public var  maxLength: Number = 0;//  最大长度
		public var  minWidth: Number = 0;//  最小宽度
		public var  maxWidth: Number = 0;//  最大宽度
		public var  materialCode: String = "";//  材料编码
		public var  materialName: String = "";//  材料名称
		public var  materialColor: String = "";//  颜色
		public var  materialBrand: String = "";//  材料品牌
		public var materialSupplier: String = "";//  材料供应商
		public var measureUnit: String = "";// 计量单位
		public var unitWeight: Number = 0;//  单位重量
		public var manufacturerCode: String = "";//  输出中心编码
		public var manufacturerName: String = "";//  输出中心名称
		public var unitPrice: Number = 0;//  材料单位价格
		public var taxFee: Number = 0;//  单位附加金额
		public var isAssembledProd:Boolean = false;
		public var manufacturerId:int;
		
		public var prodNumber:int;

		public var prodImage:String;
		public var materialWidth:Number = 0;
		public var materialLength:Number = 0;
		
		public var materialThickness:Number = 0;
		
		public var priceLvl1:Number = -1;
		public var priceLvl2:Number = 0;
		public var priceLvl3:Number = 0;
		public var priceLvl4:Number = 0;
		public var priceLvl5:Number = 0;
		
		public var discount1:Number = 1;
		public var discount2:Number = 1;
		public var discount3:Number = 1;
		public var discount4:Number = 1;
		public var discount5:Number = 1;
		
		public var uniqueCode:String = "";
		public var isClientProd:Boolean;
		public var procFeeRatio:Number = 1;
		public var measure_method:String;
		public var districtPriceRatio:Number = 1;//地区折扣
		public var customerPriceRatio:Number = 1;//客户折扣
		public var isFixedCustomerRatio:Boolean = false;//是否对客户固定折扣 
		
		public var procTreeList:Array;//工艺流程树列表
		
		private var hasDoublePrint:int = 1; //如果有双面打印的工艺，这个等于2，用于主材料计算价格
		
		public var merchanList:Array = [];
		
		public var priority:int = 0; //优先级，由所属输出中心优先级决定
		public function ProductVo(data:Object)
		{
			for(var key in data)
				this[key] = data[key];
			//is_fixedcustomerratio = true;
		}
		
		public function cloneData(picorderitem:PicOrderItem):ProductVo
		{
			var prod:ProductVo = new ProductVo(this);
			
			var procTreeList:Array = [];
			for(var i:int=0;i < this.procTreeList.length;i++)
			{
				procTreeList.push(this.procTreeList[i].cloneData(this,picorderitem));
			}
			prod.procTreeList = procTreeList;
			
			return prod;
		}
		
		public function getTechDes(ignoreWidth:Boolean,picwidth:Number=0,picheight:Number=0):String
		{
			if(procTreeList == null)
				return "";
			var techstr:String = "";
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					techstr += procTreeList[i].procName + "-";
					var childtech:String = getTechStr(procTreeList[i].nextMatList,ignoreWidth,picwidth,picheight);
					if(childtech != "")
						techstr +=  childtech.substr(0,childtech.length - 1);
					techstr += "-";
				}
				
				//techstr += ",";
			}
			if(techstr.length > 0)
				return techstr.substring(0,techstr.length - 1);
			else
				return "";
		}
		
		/**
		 *获取所有已选工艺 
		 * @return 
		 * 
		 */		
		public function getAllSelectedTech():Array
		{
			var temp:Array = [];
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					//techstr += prcessCatList[i].procCat_Name;
					temp.push(procTreeList[i]);
					var childtech:Array = getChildSelectedTech(procTreeList[i].nextMatList);
					temp = temp.concat(childtech);
				}
				
			}
			
			return temp;
		}
		
		private function getChildSelectedTech(arr:Vector.<MaterialItemVo>):Array
		{
			var temp:Array = [];
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					temp.push(arr[i]);
					temp = temp.concat(getChildSelectedTech(arr[i].nextMatList));
				}
			}
			return temp;
		}
		private function getTechStr(arr:Vector.<MaterialItemVo>,ignoreWidth:Boolean,picwidth:Number,picheight:Number):String
		{
			//var arr:Vector.<MaterialItemVo> = PaintOrderModel.instance.curSelectMat.nextMatList;
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) <0  || ignoreWidth || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >= 0 && picwidth + border > this.materialWidth && picheight + border> this.materialWidth))
					{
						var peijian:String = "";
						if(arr[i].selectAttachVoList != null)
						{
							for(var j:int=0;j < arr[i].selectAttachVoList.length;j++)
							{
								peijian += arr[i].selectAttachVoList[j].accessory_name + ",";
							}
						}
						if(peijian != "")
							return arr[i].procName + "(" + peijian.substr(0,peijian.length-1) + ")" +  "-" + getTechStr(arr[i].nextMatList,ignoreWidth,picwidth,picheight);
						else 
							return arr[i].procName +  UtilTool.getAttachDesc(arr[i]) +  "-" + getTechStr(arr[i].nextMatList,ignoreWidth,picwidth,picheight);
					}
					else
						return  getTechStr(arr[i].nextMatList,ignoreWidth,picwidth,picheight);
						
				}
			}
			return "";
		}
		
		public function getTotalPrice(picwidth:Number,picheight:Number,ignoreOther:Boolean = false,picinfovo:PicOrderItemVo = null,nodiscount:Boolean=false):Number
		{
				
			//var prices:Number = UtilTool.getProcessPrice(picwidth,picheight,measure_unit,unit_price + additional_unitfee,0);	
			var prices:Number = UtilTool.getProcessPrice(picwidth,picheight,measureUnit,unitPrice,0);;
				
					
			//hasDoublePrint = 1;
			
			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			

			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					
					//allprices = allprices.concat(getTechPrice(procTreeList[i],picwidth,picheight,ignoreOther,picinfovo,haselectTech));
					allprices = allprices.concat(getTechPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech));					

				}
				
			}
			
			
			var discount:Number = this.getDiscount(PaintOrderModel.instance.getProductTotalPrice(this.manufacturerCode,this.prodCode));
			if(nodiscount)
				discount = 1;

			for(i=0;i < allprices.length;i++)
			{
				prices +=  allprices[i].processPrice;
				if(allprices[i].unitGross != "" && allprices[i].unitGross != null)
				{
					if(isFixedCustomerRatio)
						prices +=  allprices[i].unitGross*customerPriceRatio;
					else
						prices +=  allprices[i].unitGross* discount*districtPriceRatio*customerPriceRatio;
				}
			}
			
			var allAttachprices:Array = [];
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
												
					//allAttachprices = allAttachprices.concat(getTechnoDiscountPrice(procTreeList[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,haselectTech));	
					allAttachprices = allAttachprices.concat(getTechnoDiscountPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech));					

				}
				
			}
			
			for(i=0;i < allAttachprices.length;i++)
			{
				prices +=  allAttachprices[i];
			}
			
			prices = prices * ( 1 + taxFee);

			if(prices < 0.15)
				prices = 0.15;
			
			
			return parseFloat(prices.toFixed(2));
		}
		
		public function getDiscountProcessPrice(picwidth:Number,picheight:Number,ignoreOther:Boolean = false,picinfovo:PicOrderItemVo = null):Number
		{
			var price:Number = 0;
			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					
					//allprices = allprices.concat(getTechPrice(procTreeList[i],picwidth,picheight,ignoreOther,picinfovo,haselectTech));
					allprices = allprices.concat(getTechPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech));					

				}
				
			}
			
			//prices *= hasDoublePrint;
			
			var discount:Number = this.getDiscount(PaintOrderModel.instance.getProductTotalPrice(this.manufacturerCode,this.prodCode));
			if(isFixedCustomerRatio)
				discount = 1;
			
			for(i=0;i < allprices.length;i++)
			{
				//price +=  allprices[i] * discount;
				if(allprices[i].unitGross != "" && allprices[i].unitGross != null)
					price +=  allprices[i].unitGross* discount;
			}
			if(isFixedCustomerRatio)
				price = price * ( 1 + taxFee)*customerPriceRatio;
			else
				price = price * ( 1 + taxFee)*districtPriceRatio*customerPriceRatio;


			return parseFloat(price.toFixed(2));;
		}
		//获取工艺价格
		public function getProcessPrice(picwidth:Number,picheight:Number,picinfovo:PicOrderItemVo = null):Number
		{
			
			var	prices:Number = 0;
			
			
			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					//allprices = allprices.concat(getNeedDiscountTechPrice(procTreeList[i],picwidth,picheight,false,picinfovo,haselectTech));	
					allprices = allprices.concat(getNeedDiscountTechPrice(tempTree,picwidth,picheight,false,picinfovo,haselectTech));					

				}
				
			}
			//prices *= hasDoublePrint;
			
			for(i=0;i < allprices.length;i++)
			{
				//prices +=  allprices[i].processPrice;
				if(allprices[i].unitGross != "" && allprices[i].unitGross != null)
					prices +=  allprices[i].unitGross;			}
			
			return prices;
		}
		
		private function getDiscount(total:Number):Number
		{
			if(total < 1)
				total = 1;
			
			var steps:int = 5;
			for(var i:int=1;i < 5;i++)
			{
				if(total >= this["priceLvl" + i] && total < this["priceLvl" + (i+1)])
				{
					var discount:Number = this["discount" + i] + (total - this["priceLvl" + i])*(this["discount" + (i+1)] - this["discount" + i] ) /(this["priceLvl" + (i+1)] - this["priceLvl" + i]);
					
					return discount;
				}
			}
			if(total < this.priceLvl1)
				return this.discount1;
			else
				return this.discount5;
			
		}
		private function getTechPrice(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,ignoreOther,picinfovo:PicOrderItemVo,techlist:Array):Array
		{
			var prices:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);

			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width && picheight*100 + border > this.mat_width))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var totalprice:Number = 0;
						var gross:Number = 0;
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							attachvo = arr[i].selectAttachVoList[0];
						
						var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(this.manufacturerCode,arr[i].procCode,this.materialCode,attachvo,techlist);
						var manufacturerProdPrice:Object = PaintOrderModel.instance.getProdProceessDate(this.manufacturerCode,arr[i].procCode);

						if(priceInfo != null && priceInfo.length == 4 && manufacturerProdPrice != null && manufacturerProdPrice.has_discount)
						{
							
							arr[i].measure_unit = priceInfo[0];
							arr[i].baseprice = priceInfo[1];
							arr[i].preProc_Price = priceInfo[2];
							//						if(arr[i].preProc_Price > 0 && arr[i].measure_unit == OrderConstant.MEASURE_UNIT_AREA)
							//							totalprice = arr[i].preProc_Price * area;
							//						else if(arr[i].preProc_Price > 0)
							//						{						
							//							totalprice = arr[i].preProc_Price * perimeter;
							//						}
							if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING)
							{
								if(OrderConstant.yiXingCutProcess(arr[i].procCode))
								{
									totalprice = UtilTool.getYixingPrice(picinfovo.picinfo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getYixingPrice(picinfovo.picinfo,0,priceInfo[3],picwidth,picheight);
								}
								else if(arr[i].procCode == OrderConstant.AVGCUT_TECHNO)
								{
									totalprice = UtilTool.getAvgCutPrice(picinfovo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross = UtilTool.getAvgCutPrice(picinfovo,0,priceInfo[3],picwidth,picheight);

								}
								else if(arr[i].attachmentList.indexOf(OrderConstant.NEED_PAITING_AREA) >=0)
								{
									//if(arr[i].preProc_Code == OrderConstant.PART_LAYOUT_WHITE || arr[i].preProc_Code == OrderConstant.PART_LAYOUT_WHITE_UV)
									if(OrderConstant.whitePartProcess(arr[i].procCode))
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.partWhiteUnWhiteRatio,picwidth,picheight);
									else
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
									
									if(priceInfo[3] != null && priceInfo[3] != "")
									{
										//gross = UtilTool.getPaintingPrice(priceInfo[3],0,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
										
									}

									
										
								}
								else
								{
									totalprice = UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
								}
							}
							else
							{
								totalprice = UtilTool.getCarvingPrice(picinfovo.picinfo.area,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);

							}
							
							
						}
						

						prices.push({"processPrice":totalprice*this.procFeeRatio,"unitGross":gross*this.procFeeRatio});
					}
					
					prices = prices.concat(getTechPrice(arr[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,techlist));
				}
			}
			return prices;
		}
		
		//获取工艺附件价格及不打折的工艺价格
		private function getTechnoDiscountPrice(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,ignoreOther,picinfovo:PicOrderItemVo,techlist:Array):Array
		{
			var prices:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width && picheight*100 + border > this.mat_width))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var totalprice:Number = 0;
						
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							attachvo = arr[i].selectAttachVoList[0];
						
						var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(this.manufacturerCode,arr[i].procCode,this.materialCode,attachvo,techlist);
						var manufacturerProdPrice:Object = PaintOrderModel.instance.getProdProceessDate(this.manufacturerCode,arr[i].procCode);

						if(priceInfo != null && priceInfo.length == 4)
						{
							
							arr[i].measure_unit = priceInfo[0];
							arr[i].baseprice = priceInfo[1];
							arr[i].preProc_Price = priceInfo[2];
							
							if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING && manufacturerProdPrice != null && !manufacturerProdPrice.has_discount)
							{
								if(OrderConstant.yiXingCutProcess(arr[i].procCode))
								{
									totalprice = UtilTool.getYixingPrice(picinfovo.picinfo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										totalprice +=  UtilTool.getYixingPrice(picinfovo.picinfo,0,priceInfo[3],picwidth,picheight);
								}
								else if(arr[i].procCode == OrderConstant.AVGCUT_TECHNO)
								{
									totalprice = UtilTool.getAvgCutPrice(picinfovo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										totalprice += UtilTool.getAvgCutPrice(picinfovo,0,priceInfo[3],picwidth,picheight);
									
								}
								else if(arr[i].attachmentList.indexOf(OrderConstant.NEED_PAITING_AREA) >=0)
								{
									if(OrderConstant.whitePartProcess(arr[i].procCode))
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.partWhiteUnWhiteRatio,picwidth,picheight);
									else
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
									
									if(priceInfo[3] != null && priceInfo[3] != "")
									{
										//gross = UtilTool.getPaintingPrice(priceInfo[3],0,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
										totalprice +=  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);										
										
									}
								}
								else
								{
									totalprice = UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
									if(priceInfo[3] != null && priceInfo[3] != "")
										totalprice +=  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
								}
							}
							else if(PaintOrderModel.instance.orderType == OrderConstant.CUTTING)
							{
								totalprice = UtilTool.getCarvingPrice(picinfovo.picinfo.area,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
								
							}
						
							//乘以来料加工的折扣（只有个人的procfee_ratio可能不是等于1）,配件不需要乘以这个折扣，工艺才需要
							totalprice *= this.procFeeRatio;
							
							if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0 &&  !arr[i].selectAttachVoList[0].is_belongtoClient)
							{
								if(!UtilTool.isMeasureUnitByNum(arr[i].selectAttachVoList[0].measure_unit))
									totalprice += UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].selectAttachVoList[0].accessory_price,0);
								else if(!ignoreOther)
									totalprice += UtilTool.getProcessPrice(picwidth,picheight,arr[i].selectAttachVoList[0].measure_unit,arr[i].selectAttachVoList[0].accessory_price,0);
								
								
							}
							
							
						}
						prices.push(totalprice);
					}
					
					prices = prices.concat(getTechnoDiscountPrice(arr[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,techlist));
				}
			}
			return prices;
		}
		
		//计算需要参与折扣的工艺总价
		private function getNeedDiscountTechPrice(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,ignoreOther,picinfovo:PicOrderItemVo,techlist:Array):Array
		{
			var prices:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var totalprice:Number = 0;
						var gross:Number = 0;
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							attachvo = arr[i].selectAttachVoList[0];
						
						
						var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(this.manufacturerCode,arr[i].procCode,this.materialCode,attachvo,techlist);
						
						var manufacturerProdPrice:Object = PaintOrderModel.instance.getProdProceessDate(this.manufacturerCode,arr[i].procCode);
						if(priceInfo != null && priceInfo.length == 4 && manufacturerProdPrice != null && manufacturerProdPrice.has_discount)
						{
							
							arr[i].measure_unit = priceInfo[0];
							arr[i].baseprice = priceInfo[1];
							arr[i].preProc_Price = priceInfo[2];
							//						if(arr[i].preProc_Price > 0 && arr[i].measure_unit == OrderConstant.MEASURE_UNIT_AREA)
							//							totalprice = arr[i].preProc_Price * area;
							//						else if(arr[i].preProc_Price > 0)
							//						{						
							//							totalprice = arr[i].preProc_Price * perimeter;
							//						}
							if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING)
							{
								if(OrderConstant.yiXingCutProcess(arr[i].procCode))
								{
									totalprice = UtilTool.getYixingPrice(picinfovo.picinfo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getYixingPrice(picinfovo.picinfo,0,priceInfo[3],picwidth,picheight);
								}
								else if(arr[i].procCode == OrderConstant.AVGCUT_TECHNO)
								{
									totalprice = UtilTool.getAvgCutPrice(picinfovo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross = UtilTool.getAvgCutPrice(picinfovo,0,priceInfo[3],picwidth,picheight);
									
								}
								else if(arr[i].attachmentList.indexOf(OrderConstant.NEED_PAITING_AREA))
								{
									//if(arr[i].preProc_Code == OrderConstant.PART_LAYOUT_WHITE || arr[i].preProc_Code == OrderConstant.PART_LAYOUT_WHITE_UV)
									if(OrderConstant.whitePartProcess(arr[i].procCode))
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.partWhiteUnWhiteRatio,picwidth,picheight);
									else
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
									
									if(priceInfo[3] != null && priceInfo[3] != "")
									{
										//gross = UtilTool.getPaintingPrice(priceInfo[3],0,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
										
									}
								}
								else
								{
									totalprice = UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
								}
							}
							else
							{
								totalprice = UtilTool.getCarvingPrice(picinfovo.picinfo.area,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
								
							}
							if(priceInfo[3] != null && priceInfo[3] != "")
								gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
							//附件不参与计算
							
						}
						
						prices.push({"processPrice":totalprice*this.procFeeRatio,"unitGross":gross*this.procFeeRatio});

						//if(arr[i].baseprice != 0)
						//	totalprice += arr[i].baseprice;
						//prices.push(totalprice);
					}
					
					prices = prices.concat(getNeedDiscountTechPrice(arr[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,techlist));
				}
			}
			return prices;
		}
		
		private function getMaterialProInfoList(arr:Vector.<MaterialItemVo>,picinfo:PicInfoVo,picwidth:Number,picheight:Number,orderitemvo:PicOrderItemVo):Array
		{
			var prolist:Array = [];
			if(arr == null)
				return [];
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);

			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width  && picheight*100 + border > this.mat_width))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var procname:String = arr[i].procName + UtilTool.getAttachDesc(arr[i]);
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							procname += "(" + arr[i].selectAttachVoList[0].accessory_name + ")";
						if(OrderConstant.yiXingCutProcess(arr[i].procCode))
						{
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath: HttpRequestUtil.originPicPicUrl + picinfo.yixingFid + "." + picinfo.yixingPicClass});						
						
						}
						else if(OrderConstant.backSideUnSame(arr[i].procCode))
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath: HttpRequestUtil.originPicPicUrl + picinfo.backFid + "." + picinfo.backPicClass});
						else if(OrderConstant.whitePartProcess(arr[i].procCode))
						{
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath: HttpRequestUtil.originPicPicUrl + picinfo.partWhiteFid + "." + picinfo.partWhitePicClass});
							
						}
						
						else if(arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0)
						{
							var procname:String = arr[i].procName + "(" + ["V","H"][orderitemvo.cuttype] + "-" +  orderitemvo.cutnum+ "-" + orderitemvo.eachCutLength.join(";") +")";//["竖拼裁切","横拼裁切"][orderitemvo.cuttype] + "(" + orderitemvo.cutnum+")";
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath:arr[i].attchMentFileId});
						}
						else if(arr[i].attachmentList.indexOf(OrderConstant.AVERAGE_CUTOFF) >=0)
						{
							var procname:String = procname + "(H-" + orderitemvo.horiCutNum + ",V-" + orderitemvo.verCutNum+  ")";
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath:arr[i].attchMentFileId});
						}
						else if(arr[i].attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >=0)
						{
							//if(orderitemvo.dakouNum == 1)
							//	var procname:String = procname + "(" + orderitemvo.dakouNum + "-" + orderitemvo.dkleftpos.toFixed(2)+ ")";
							//else
							var holesposStr:String="";
							for(var m=0;m < orderitemvo.holeList.length;m++)
							{
								holesposStr +="(" + orderitemvo.holeList[m].x.toFixed(1) + "," + orderitemvo.holeList[m].y.toFixed(1) + ");";
							}
							procname = procname + holesposStr;

							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath:arr[i].attchMentFileId});
						}
						else
							prolist.push({procCode:arr[i].procCode,procDescription:procname,procAttachPath:arr[i].attchMentFileId});
					}

						
					prolist = prolist.concat(getMaterialProInfoList(arr[i].nextMatList,picinfo,picwidth,picheight,orderitemvo));
					
				}
				
			}
			return prolist;
		}
		
		public function getProInfoList(picinfo:PicInfoVo,picwidth:Number,picheight:Number,orderitemvo:PicOrderItemVo):Array
		{
			var arr:Array = [];
			
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					//arr.push({proc_Code:prcessCatList[i].procCat_Name,proc_description:prcessCatList[i].procCat_Name,proc_attachpath:""});
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					
					//arr = arr.concat(getMaterialProInfoList(procTreeList[i],picinfo,picwidth,picheight,orderitemvo));
					arr = arr.concat(getMaterialProInfoList(tempTree,picinfo,picwidth,picheight,orderitemvo));

				}
			}
			return arr;
		}
		
		public function getOrderSingleWeight(picwidth:Number,picheight:Number,picinfovo:PicOrderItemVo = null):Number
		{
			
			//var prices:Number = UtilTool.getProcessPrice(picwidth,picheight,measure_unit,unit_price + additional_unitfee,0);			
			var weight:Number = UtilTool.getMaterialWight(picwidth,picheight,measureUnit,unitWeight);			
			
			//hasDoublePrint = 1;
			
			var allAttachWeight:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			allAttachWeight = allAttachWeight.concat(getAttachWeight(procTreeList,picwidth,picheight,picinfovo,haselectTech));					

//			for(var i:int=0;i < procTreeList.length;i++)
//			{
//				if(procTreeList[i].selected)
//				{
//					allAttachWeight = allAttachWeight.concat(getAttachWeight(procTreeList[i],picwidth,picheight,picinfovo,haselectTech));					
//				}
//				
//			}

			for(var i=0;i < allAttachWeight.length;i++)
			{
				
				weight += allAttachWeight[i];					
				
				
			}
			
			return parseFloat(weight.toFixed(2));
		}
		
		private function getAttachWeight(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,picinfovo:PicOrderItemVo,techlist:Array):Array
		{
			var weight:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width && picheight*100 + border > this.mat_width))
					//if( arr[i].attachmentList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].attachmentList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
						{
							attachvo = arr[i].selectAttachVoList[0];																			
							var attachweight:Number = UtilTool.getMaterialWight(picwidth,picheight,attachvo.measure_unit,attachvo.unit_weight);									
							weight.push(attachweight);
						}
							
					}
					weight = weight.concat(getAttachWeight(arr[i].nextMatList,picwidth,picheight,picinfovo,techlist));

				}
									
			}
						
			return weight;
		}

		public function checkCurTechValid():Boolean
		{
			var techArr:Array = getAllSelectedTech();
			for(var i:int=0;i < techArr.length;i++)
			{
				if( techArr[i].preProc_attachmentTypeList != null && techArr[i].preProc_attachmentTypeList != "" && techArr[i].preProc_attachmentTypeList.toLocaleUpperCase() != OrderConstant.ATTACH_NO && techArr[i].preProc_attachmentTypeList.toLocaleUpperCase() != OrderConstant.ATTACH_PEIJIAN)
				{
					if(techArr[i].attchFileId == null || techArr[i].attchFileId == "")
					{
						ViewManager.showAlert("有工艺未选择合适的附件图片");
						return false;
					}
				}
			}
			
			return true;
		}
		
		public function getMaterialPrice(picwidth:Number,picheight:Number,ignoreOther:Boolean = false,picinfovo:PicOrderItemVo = null):Number
		{
			//主材料价格
			var prices:Number = UtilTool.getProcessPrice(picwidth,picheight,measureUnit,unitPrice,0);
			
			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			
			
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					//allprices = allprices.concat(getAttachPrice(procTreeList[i],picwidth,picheight,ignoreOther,picinfovo,haselectTech));	
					allprices = allprices.concat(getAttachPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech));					

				}
				
			}
			
			for(i=0;i < allprices.length;i++)
			{
				prices +=  allprices[i];
				
			}
			
			return prices;
		}
		
		public function getAllAttachPrice(picwidth:Number,picheight:Number,ignoreOther:Boolean = false,picinfovo:PicOrderItemVo = null):Number
		{
			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			var prices:Number = 0;
			
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					//allprices = allprices.concat(getAttachPrice(procTreeList[i],picwidth,picheight,ignoreOther,picinfovo,haselectTech));	
					allprices = allprices.concat(getAttachPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech,true));					
					
				}
				
			}
			
			for(i=0;i < allprices.length;i++)
			{
				prices +=  allprices[i];
				
			}
			
			return prices;
		}
		
		//获取附件价格  justMatPrice 是否只要材料配件的价格
		private function getAttachPrice(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,ignoreOther,picinfovo:PicOrderItemVo,techlist:Array,justMatPrice:Boolean=false):Array
		{
			var prices:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected && (!justMatPrice || arr[i].attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >= 0))
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width && picheight*100 + border > this.mat_width))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var totalprice:Number = 0;
						
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							attachvo = arr[i].selectAttachVoList[0];
						
						var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(this.manufacturerCode,arr[i].procCode,this.materialCode,attachvo,techlist);
						
						if(priceInfo != null && priceInfo.length == 4)
						{
							
							arr[i].measure_unit = priceInfo[0];
							arr[i].baseprice = priceInfo[1];
							arr[i].preProc_Price = priceInfo[2];
							
							
							if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0 &&  !arr[i].selectAttachVoList[0].is_belongtoClient)
							{
								if(!UtilTool.isMeasureUnitByNum(arr[i].selectAttachVoList[0].measure_unit))
									totalprice += UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].selectAttachVoList[0].accessory_price,0);
								else if(!ignoreOther)
									totalprice += UtilTool.getProcessPrice(picwidth,picheight,arr[i].selectAttachVoList[0].measure_unit,arr[i].selectAttachVoList[0].accessory_price,0);
								
								
							}
							
							
						}
						prices.push(totalprice);
					}
					
					prices = prices.concat(getAttachPrice(arr[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,techlist));
				}
			}
			return prices;
		}
		
		//h获取工艺及毛利润金额
		public function getProcessAndGrossPrices(picwidth:Number,picheight:Number,ignoreOther:Boolean = false,picinfovo:PicOrderItemVo = null):Array
		{
			var procprices:Number = 0;
			var discountGrossMargin:Number = 0;
			var noDiscountGrossMargin:Number = 0;

			var allprices:Array = [];
			var haselectTech:Array = getAllSelectedTech();
			
			var discount:Number = this.getDiscount(PaintOrderModel.instance.getProductTotalPrice(this.manufacturerCode,this.prodCode));

			if(isFixedCustomerRatio)
				discount = 1;
			
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					var tempTree:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					tempTree.push(procTreeList[i]);
					
					//allprices = allprices.concat(getProcPrice(procTreeList[i],picwidth,picheight,ignoreOther,picinfovo,haselectTech));	
					allprices = allprices.concat(getProcPrice(tempTree,picwidth,picheight,ignoreOther,picinfovo,haselectTech));					

				}
				
			}
			
			for(i=0;i < allprices.length;i++)
			{
				procprices +=  allprices[i].processPrice;
				
				if(allprices[i].unitGross != "" && allprices[i].unitGross != null && allprices[i].discount)
				{
					discountGrossMargin +=  allprices[i].unitGross * discount;
				}
				else if(allprices[i].unitGross != "" && allprices[i].unitGross != null && !allprices[i].discount)
				{
					noDiscountGrossMargin += allprices[i].unitGross;
				}
			}
			//procprices = procprices*district_priceratio*customer_priceratio;
			if(isFixedCustomerRatio)
				discountGrossMargin = discountGrossMargin*customerPriceRatio;
			else
				discountGrossMargin = discountGrossMargin*districtPriceRatio*customerPriceRatio;

			//noDiscountGrossMargin = noDiscountGrossMargin*district_priceratio*customer_priceratio;

			return [procprices,discountGrossMargin,noDiscountGrossMargin];
		}
		//获取工艺价格（打折不打折加起来)
		private function getProcPrice(arr:Vector.<MaterialItemVo>,picwidth:Number,picheight:Number,ignoreOther,picinfovo:PicOrderItemVo,techlist:Array):Array
		{
			var prices:Array = [];
			if(arr == null)
				return [];
			
			var border:Number = UtilTool.getBorderDistance(this.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].selected)
				{
					//if( arr[i].preProc_attachmentTypeList.toUpperCase() !=  OrderConstant.CUTOFF_H_V || (arr[i].preProc_attachmentTypeList.toUpperCase() == OrderConstant.CUTOFF_H_V && picwidth*100 + border > this.mat_width && picheight*100 + border > this.mat_width))
					if( arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) < 0 || (arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0 && picwidth*100 + border > this.materialWidth && picheight*100 + border > this.materialWidth))
					{
						var totalprice:Number = 0;
						var gross:Number = 0;
						var attachvo:AttchCatVo;
						if(arr[i].selectAttachVoList != null && arr[i].selectAttachVoList.length > 0)
							attachvo = arr[i].selectAttachVoList[0];
						
						var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(this.manufacturerCode,arr[i].procCode,this.materialCode,attachvo,techlist);
						var manufacturerProdPrice:Object = PaintOrderModel.instance.getProdProceessDate(this.manufacturerCode,arr[i].procCode);
						
						if(priceInfo != null && priceInfo.length == 4 && manufacturerProdPrice != null)
						{
							
							arr[i].measure_unit = priceInfo[0];
							arr[i].baseprice = priceInfo[1];
							arr[i].preProc_Price = priceInfo[2];
							//						if(arr[i].preProc_Price > 0 && arr[i].measure_unit == OrderConstant.MEASURE_UNIT_AREA)
							//							totalprice = arr[i].preProc_Price * area;
							//						else if(arr[i].preProc_Price > 0)
							//						{						
							//							totalprice = arr[i].preProc_Price * perimeter;
							//						}
							if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING)
							{
								if(OrderConstant.yiXingCutProcess(arr[i].procCode))
								{
									totalprice = UtilTool.getYixingPrice(picinfovo.picinfo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getYixingPrice(picinfovo.picinfo,0,priceInfo[3],picwidth,picheight);
								}
								else if(arr[i].procCode == OrderConstant.AVGCUT_TECHNO)
								{
									totalprice = UtilTool.getAvgCutPrice(picinfovo,arr[i].baseprice,arr[i].preProc_Price,picwidth,picheight);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross = UtilTool.getAvgCutPrice(picinfovo,0,priceInfo[3],picwidth,picheight);
									
								}
								else if(arr[i].attachmentList.indexOf(OrderConstant.NEED_PAITING_AREA) >=0)
								{
									if(OrderConstant.whitePartProcess(arr[i].procCode))
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.partWhiteUnWhiteRatio,picwidth,picheight);
									else
										totalprice = UtilTool.getPaintingPrice(arr[i].preProc_Price,arr[i].baseprice,picinfovo.picinfo.unwhiteratio,picwidth,picheight);
									
									if(priceInfo[3] != null && priceInfo[3] != "")
									{
										//gross = UtilTool.getPaintingPrice(priceInfo[3],0,picinfovo.picinfo.unwhiteratio,picwidth,picheight);										
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);

									}
								}
								else
								{
									totalprice = UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
									if(priceInfo[3] != null && priceInfo[3] != "")
										gross =  UtilTool.getProcessPrice(picwidth,picheight,arr[i].measure_unit,priceInfo[3],0);
								}
							}
							else
							{
								totalprice = UtilTool.getCarvingPrice(picinfovo.picinfo.area,arr[i].measure_unit,arr[i].preProc_Price,arr[i].baseprice);
								
							}
						}
						if(manufacturerProdPrice != null)
							prices.push({"processPrice":totalprice*this.procFeeRatio,"unitGross":gross*this.procFeeRatio,"discount":manufacturerProdPrice.has_discount});
						else
							prices.push({"processPrice":totalprice*this.procFeeRatio,"unitGross":gross*this.procFeeRatio,"discount":0});

					}
					
					prices = prices.concat(getProcPrice(arr[i].nextMatList,picwidth,picheight,ignoreOther,picinfovo,techlist));
				}
			}
			return prices;
		}
		
		public function getProductDiscount(callback:Function,caller:*):void
		{
			if(this.priceLvl1 == -1)
			{
				var params:String = "prodCode="+this.prodCode + "&customerCode=" + Userdata.instance.userAccount + "&manufacturerCode=" + this.manufacturerCode + "&addressId=" + PaintOrderModel.instance.selectAddress.zoneid+"&clientCode="+Userdata.instance.clientCode;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdDiscount + params,this,function(data:String){
					
					var result:Object = JSON.parse(data as String);
					if(!result.hasOwnProperty("status"))
					{
						for(var key in result)
							this[key] = result[key];
						
					}
					if(callback != null)
						callback.call(caller);
					
				},null,null);
			}
			else
			{
				if(callback != null)
					callback.call(caller);
			}
			
			
		}
		public function resetData():void
		{
			if(procTreeList != null)
			{
				for(var i:int=0;i < procTreeList.length;i++)
				{
					procTreeList[i].resetData();
				}
			}
		}
		
		public function getFirstTechMeasureUnit():String
		{
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					if(procTreeList[i].measure_unit.indexOf("平方米") >= 0)
						return OrderConstant.MEASURE_UNIT_AREA;
					else
						return "米";
				}
			}
			return OrderConstant.MEASURE_UNIT_AREA;
		}
		public function getTotalMeasureNum(picwidth:Number,picheight:Number):Number
		{
			for(var i:int=0;i < procTreeList.length;i++)
			{
				if(procTreeList[i].selected)
				{
					return UtilTool.getMaterialWight(picwidth,picheight,procTreeList[i].measure_unit,1);
					
				}
			}
			return 1;
		}
	}
}
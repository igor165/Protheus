#Include "PROTHEUS.ch" 
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#include 'MATI940.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI940
Mensagem unica de exportacao da instrucao normatica SINTEGRA - EXPORTSINTEGRA

@param cXml Xml passado para a rotina
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return lRet indica se a mensagem foi processada com sucesso
@return cXmlRet Xml de retorno da funcao

@author Fabio Vessoni Santana
@since 25/05/2015
@version MP12 
/*/
//-------------------------------------------------------------------
Function MATI940( cXml, nType, cTypeMsg ) 
Local cXmlRet				:= ''
Local cErroXml			:= ""
Local cWarnXml			:= ""
Local aParam				:={}
Local oXmlMata940:=''
Local nPorta:=0
Local nPonto:=0
Local cAdress:=''
Local cUser:=''
Local cPassw:=''
Local cFile:=''
Local lRet:=.T.
Local cMarca := ""
Local cAuxDePara := ""

Do Case 
	 //verificação do tipo de transação
	Case  nType == TRANS_RECEIVE 
		If (cTypeMsg == EAI_MESSAGE_WHOIS )
			cXmlRet := '1.000'
		ElseIF ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			oXmlMata940 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If oXmlMata940 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPADRESS') != Nil
					nPonto:=AT(":",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text)//vem IP:Porta
					nPorta:=Val(SubSTR(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text,nPonto+1))
					cAdress:=SubSTR(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPAdress:Text,1,nPonto-1)
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPUSER') != Nil
						cUser:=oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPUser:Text
						If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FTPPASSWORD') != Nil
							cPassw:=oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FTPPassWord:Text
						Else
							cXmlRet+='<Message type="ERROR" code="c2">'+STR0001+'</Message>'//É obrigatório informar a senha do  usuario FTP para gravação do arquivo TXT.
							lRet:=.F.
						Endif
					Else 
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0002+'</Message>'//É obrigatório informar o usuario FTP para gravação do arquivo TXT.
						lRet:=.F.
					Endif
				Else
					cXmlRet+='<Message type="ERROR" code="c2">'+STR0003+'</Message>'//É obrigatório informar o endereço FTP para gravação do arquivo TXT.
					lRet:=.F.
				Endif
				If lRet							
					If Type("oXmlMata940:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
						cMarca := oXmlMata940:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf    

					//Data Inicial    					  
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_INITIALDATE') != Nil
						aAdd(aParam,{"MV_PAR01",StoD(STRTran(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_InitialDate:Text,'-'))})
					Else
						aAdd(aParam,{"MV_PAR01",Ctod("")})
					Endif

					//Data Final    
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FINALDATE') != Nil
						aAdd(aParam,{"MV_PAR02",StoD(STRTran(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FinalDate:Text,'-'))})
					Else
						aAdd(aParam,{"MV_PAR02",Ctod("")})
					Endif

					//LayOut 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_LAYOUT') != Nil
						aAdd(aParam,{"MV_PAR03",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Layout:Text})
					Else
						aAdd(aParam,{"MV_PAR03",""})
					Endif

					//Arquivo Destino  
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TARGETFILE') != Nil
						cFile := oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetFile:Text
						aAdd(aParam,{"MV_PAR04",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetFile:Text})
					Else
						aAdd(aParam,{"MV_PAR04",AllTrim( GetSrvProfString( "StartPath" , "" ) )})
					Endif

					//Finalidade 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PURPOSE') != Nil
						aAdd(aParam,{"MV_PAR05",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Purpose:Text)})
					Else
						aAdd(aParam,{"MV_PAR05",1})
					Endif

					//UF Origem/Destino 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address,'_STATE') != Nil
						aAdd(aParam,{"MV_PAR06",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:_State:Text})
					Else
						aAdd(aParam,{"MV_PAR06",""})
					Endif

					//Processa UF    
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PROCESSSTATE') != Nil
						aAdd(aParam,{"MV_PAR07",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessState:Text)})
					Else
						aAdd(aParam,{"MV_PAR07",1})
					Endif

					//Numero do Livro 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TAXRECORDNUMBER') != Nil
						aAdd(aParam,{"MV_PAR08",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_TaxRecordNumber:Text})
					Else
						aAdd(aParam,{"MV_PAR08",""})
					Endif

					//Equipamento 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_EQUIPMENT') != Nil
						aAdd(aParam,{"MV_PAR09",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Equipment:Text})
					Else
						aAdd(aParam,{"MV_PAR09",""})
					Endif

					//Gera Inventario 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEINVENTORY') != Nil
						aAdd(aParam,{"MV_PAR10",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateInventory:Text)})
					Else
						aAdd(aParam,{"MV_PAR10",1})
					Endif

					//Notas Fiscais  
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_INVOICES') != Nil
						aAdd(aParam,{"MV_PAR11",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Invoices:Text)})
					Else
						aAdd(aParam,{"MV_PAR11",1})
					Endif

					//Gera Reg.60I e 60D 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE60I60D') != Nil
						aAdd(aParam,{"MV_PAR12",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate60I60D:Text)})
					Else
						aAdd(aParam,{"MV_PAR12",1})
					Endif																		
					
					//Drive Destino  
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TARGETDRIVE') != Nil
						aAdd(aParam,{"MV_PAR13",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_TargetDrive:Text})
					Else
						aAdd(aParam,{"MV_PAR13",""})
					Endif						
					
					//Transportadora
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CARRIERINTERNALID') != Nil
						If !Empty(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_CarrierInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SA4', 'A4_COD', oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_CarrierInternalId:Text)
							aAdd(aParam,{"MV_PAR14",cAuxDePara})
						Else
						 	If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CARRIERCODE') != Nil
						 		aAdd(aParam,{"MV_PAR14",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text})
						 	Endif
						Endif
					ElseIf XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CARRIERCODE') != Nil
					  	aAdd(aParam,{"MV_PAR14",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_CarrierCode:Text})
					Else
						aAdd(aParam,{"MV_PAR14",""})												  	
					Endif								
					
					//Data de Fechamento
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CLOSINGDATE') != Nil
						aAdd(aParam,{"MV_PAR15",StoD(STRTran(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ClosingDate:Text,'-'))})
					Else
						aAdd(aParam,{"MV_PAR15",Ctod("")})
					Endif						
					
					//Gera Registro 60R 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE60R') != Nil
						aAdd(aParam,{"MV_PAR16",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate60R:Text)})
					Else
						aAdd(aParam,{"MV_PAR16",1})
					Endif	
					
					//Gera Registro 61R
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE61R') != Nil
						aAdd(aParam,{"MV_PAR17",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate61R:Text)})
					Else
						aAdd(aParam,{"MV_PAR17",1})
					Endif	
					
					//Gera NF Produtor
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MANUFACTUREINVOICE') != Nil
						aAdd(aParam,{"MV_PAR18",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ManufactureInvoice:Text)})
					Else
						aAdd(aParam,{"MV_PAR18",1})
					Endif	
					
					//Meio magnetico
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_MAGNETICMEAN') != Nil
						aAdd(aParam,{"MV_PAR19",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_MagneticMean:Text)})
					Else
						aAdd(aParam,{"MV_PAR19",1})
					Endif																									
					
					//Fator de bloco 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_BLOCKINGFACTOR') != Nil
						aAdd(aParam,{"MV_PAR20",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_BlockingFactor:Text})
					Else
						aAdd(aParam,{"MV_PAR20",""})
					Endif	
					
					//Natureza Operacoes 
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TRANSACTCLASSES') != Nil
						aAdd(aParam,{"MV_PAR21",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_TransactClasses:Text)})
					Else
						aAdd(aParam,{"MV_PAR21",1})
					Endif							
					
					//Destaca PIS/COFINS
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_OUTLINEPISCOFINS') != Nil
						aAdd(aParam,{"MV_PAR22",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_OutlinePISCOFINS:Text)})
					Else
						aAdd(aParam,{"MV_PAR22",1})
					Endif							
					
					//NF De
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMINVOICE') != Nil
						aAdd(aParam,{"MV_PAR23",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromInvoice:Text})
					Else
						aAdd(aParam,{"MV_PAR23",""})
					Endif	
					
					//NF Ate
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOINVOICE') != Nil
						aAdd(aParam,{"MV_PAR24",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToInvoice:Text})
					Else
						aAdd(aParam,{"MV_PAR24",""})
					Endif																						

					//Filial de
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCHINTERNALID') != Nil
						If !Empty(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranchInternalId:Text,Len(cFilAnt)))
							aAdd(aParam,{"MV_PAR25",cAuxDePara})
						Else
						 	If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCH') != Nil
						 		aAdd(aParam,{"MV_PAR25",PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranch:Text,Len(cFilAnt))})
						 	Endif
						Endif
					ElseIf XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_FROMBRANCH') != Nil
					  	aAdd(aParam,{"MV_PAR25",PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_FromBranch:Text,Len(cFilAnt))})
					Else
						aAdd(aParam,{"MV_PAR25",""})												  	
					Endif	

					//Filial Ate
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCHINTERNALID') != Nil
						If !Empty(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranchInternalId:Text)
							cAuxDePara := CFGA070Int(cMarca, 'SM0', 'M0_FILIAL', PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranchInternalId:Text,Len(cFilAnt)))
							aAdd(aParam,{"MV_PAR26",cAuxDePara})
						Else
						 	If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCH') != Nil
						 		aAdd(aParam,{"MV_PAR26",PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranch:Text,Len(cFilAnt))})
						 	Endif
						Endif
					ElseIf XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_TOBRANCH') != Nil
					  	aAdd(aParam,{"MV_PAR26",PAdr(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToBranch:Text,Len(cFilAnt))})
					Else
						aAdd(aParam,{"MV_PAR26",""})												  	
					Endif	

					//Consolidação na mesma UF
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CONSOLIDATIONSTATE') != Nil
						aAdd(aParam,{"MV_PAR27",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ConsolidationState:Text)})
					Else
						aAdd(aParam,{"MV_PAR27",1})
					Endif							
					
					//Filtro Tipo Produto
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTTYPEFILTER') != Nil
						aAdd(aParam,{"MV_PAR28",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductTypeFilter:Text})
					Else
						aAdd(aParam,{"MV_PAR28",""})
					Endif	
					
					//Produto De
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTFROM') != Nil
						aAdd(aParam,{"MV_PAR29",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductFrom:Text})
					Else
						aAdd(aParam,{"MV_PAR29",""})
					Endif	
					
					//Produto Ate
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTTO') != Nil
						aAdd(aParam,{"MV_PAR30",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductTo:Text})
					Else
						aAdd(aParam,{"MV_PAR30",""})
					Endif	
					
					//Armazem De
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_WAREHOUSEFROM') != Nil
						aAdd(aParam,{"MV_PAR31",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseFrom:Text})
					Else
						aAdd(aParam,{"MV_PAR31",""})
					Endif	
					
					//Armazem Ate
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_STORAGEUNTIL') != Nil
						aAdd(aParam,{"MV_PAR32",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_StorageUntil:Text})
					Else
						aAdd(aParam,{"MV_PAR32",""})
					Endif																															
					
					//Prods.c/Saldo Neg.
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTNEGATIVEBALANCE') != Nil
						aAdd(aParam,{"MV_PAR33",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductNegativeBalance:Text)})
					Else
						aAdd(aParam,{"MV_PAR33",1})
					Endif		
					
					//Prods.c/Saldo Zera.
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTZEROBALANCE') != Nil
						aAdd(aParam,{"MV_PAR34",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductZeroBalance:Text)})
					Else
						aAdd(aParam,{"MV_PAR34",1})
					Endif	
					
					//Prods.c/Saldo Poder 3.
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTPOWERBALANCE') != Nil
						aAdd(aParam,{"MV_PAR35",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductPowerBalance:Text)})
					Else
						aAdd(aParam,{"MV_PAR35",1})
					Endif	
					
					//Prods.c/Custo Zera.
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PRODUCTZEROCOST') != Nil
						aAdd(aParam,{"MV_PAR36",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductZeroCost:Text)})
					Else
						aAdd(aParam,{"MV_PAR36",1})
					Endif	
					
					//Gera 88 MG
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE88') != Nil
						aAdd(aParam,{"MV_PAR37",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate88:Text)})
					Else
						aAdd(aParam,{"MV_PAR37",1})
					Endif																														
					
					//Data 88
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_DATE88') != Nil
						aAdd(aParam,{"MV_PAR38",StoD(STRTran(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Date88:Text,'-'))})
					Else
						aAdd(aParam,{"MV_PAR38",Ctod("")})
					Endif							
					
					//Gera Relat. Rest. MG
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATEMGREPORT') != Nil
						aAdd(aParam,{"MV_PAR39",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_GenerateMGReport:Text)})
					Else
						aAdd(aParam,{"MV_PAR39",1})
					Endif	

					//Saldo Processo
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_PROCESSBALANCE') != Nil
						aAdd(aParam,{"MV_PAR40",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProcessBalance:Text)})
					Else
						aAdd(aParam,{"MV_PAR40",1})
					Endif	
					
					//Lista MOD Processo
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_LISTPROCESSMOD') != Nil
						aAdd(aParam,{"MV_PAR41",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListProcessMOD:Text)})
					Else
						aAdd(aParam,{"MV_PAR41",1})
					Endif	
					
					//Seleciona Filiais
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_SELECTBRANCHES') != Nil
						aAdd(aParam,{"MV_PAR42",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_SelectBranches:Text)})
					Else
						aAdd(aParam,{"MV_PAR42",1})
					Endif	
					
					//Gera registro 60I
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE60I') != Nil
						aAdd(aParam,{"MV_PAR43",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate88:Text)})
					Else
						aAdd(aParam,{"MV_PAR43",1})
					Endif	
					
					//Gera reg. Tipo 88 Det. 06
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE8806') != Nil
						aAdd(aParam,{"MV_PAR44",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate8806:Text)})
					Else
						aAdd(aParam,{"MV_PAR44",1})
					Endif	
					
					//Gera reg. 8827 e 8828
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE8827') != Nil
						aAdd(aParam,{"MV_PAR45",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate8827:Text)})
					Else
						aAdd(aParam,{"MV_PAR45",1})
					Endif	
					
					//Gera reg. 8830
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE8830') != Nil
						aAdd(aParam,{"MV_PAR46",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate8830:Text)})
					Else
						aAdd(aParam,{"MV_PAR46",1})
					Endif	
					
					//Simples Nacional
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_SIMPLETAXTNSYSTEM') != Nil
						aAdd(aParam,{"MV_PAR47",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_SimpleTaxtnSystem:Text)})
					Else
						aAdd(aParam,{"MV_PAR47",1})
					Endif																																																							
					
					//Arq. Periodo Atual
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_CURRENTPERIODFILE') != Nil
						aAdd(aParam,{"MV_PAR48",oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_CurrentPeriodFile:Text})
					Else
						aAdd(aParam,{"MV_PAR48",""})
					Endif							
					
					//Gera reg. 53 (Entradas)
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE53') != Nil
						aAdd(aParam,{"MV_PAR49",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate53:Text)})
					Else
						aAdd(aParam,{"MV_PAR49",1})
					Endif	
					
					//Gera reg. 88DV
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_GENERATE88DV') != Nil
						aAdd(aParam,{"MV_PAR50",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_Generate88DV:Text)})
					Else
						aAdd(aParam,{"MV_PAR50",1})
					Endif	
					
					//Aglutina seleção por CNPJ+IE
					If XmlChildEx(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent,'_AGGLUTSELECTION') != Nil
						aAdd(aParam,{"MV_PAR51",Val(oXmlMata940:_TotvsMessage:_BusinessMessage:_BusinessContent:_AgglutSelection:Text)})
					Else
						aAdd(aParam,{"MV_PAR51",1})
					Endif																			

					//Chamo a funcao do SINTEGRA, para gerar o arquivo												
					Mata940(aParam)
						
					If FTPCONNECT(cAdress ,nPorta ,cUser , cPassw )
						cArqu:=GetSrvProfString("STARTPATH","")  
						cArqu+= cFile //arquivo sem o diretorio. Para o upload, é necessario estar dentro do \System.
						
						FTPSETPASV(.F.)		
						IF !FTPUPLOAD( cArqu,cFile)
							IF !FTPUPLOAD( cArqu,cFile)//forço a entrada, tentando duas vezes
								lRet:=.F.
								cXmlRet+='<Message type="ERROR" code="c2">'+STR0004+'</Message>'//Não foi possível a carga do arquivo no FTP. Verifique as permissões e tente novamente.
							Endif
						Endif
						
						If lRet

							//Apago o arquivo gerado na pasta system e mantenho somente o arquivo gerado no FTP
							If File(cArqu)
								FErase(cArqu)
							EndIF
							
							cXmlRet+= "<File>"+_noTags(cAdress + ":"+cValtoChar(nPorta) + "/" + cFile)+"</File>"
						EndIf
							
						FTPDisconnect()
					Else
						lRet:=.F.
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0005+'</Message>'//Não foi possível a conexão com o servidor FTP informado. Verifique.
					Endif			

				Endif
			Else
				cXmlRet+='<Message type="ERROR" code="c2">'+STR0006+'</Message>'//Foram encontrados erros na mensagem XML recebida que impossibilitam o seu processamento.
				lRet:=.F.
			Endif
		Endif
EndCase

cXmlRet:=EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }

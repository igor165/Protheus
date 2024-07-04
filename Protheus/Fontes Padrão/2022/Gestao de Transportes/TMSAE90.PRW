#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oNfe 
Static __oCopy

/*{Protheus.doc} TMSAE90

Função que cria uma tela aonde se pode ser alterados algun campos para a carta de correção eletronica para CTe

@author Fabio Marchiori Sampaio	
@since 03/12/13
@version 1.0
*/

Function TMSAE90()

	Private lUsaColab := .F.

   	lUsaColab := UsaColaboracao("2")
	If lUsaColab
		//-- TOTVS Colaboracao 2.0
		lUsaColab := ColCheckUpd()
		If !lUsaColab
			MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
		EndIf
	EndIf

   	FWExecView("Carta de Correções CCe", 'TMSAE90', 4, , {|| .T. } )

Return NIL
  
//-------------------------------------------------------------------

Static Function ModelDef()
	
	Local oModel  		:= Nil
	Local oStruVal		:= StrModVal(1)	// Struc dos Dados com o  Valores do CTE
	Local oStruCTE 	:= StrModCTE(1)	// Struct dos Dados do CTE
	Local oStrucNF 	:= StrModNF(1)		// Struct dos Dados da NF
	Local oStrucVeic	:= StrModVeic(1)	// Struct dos Dados do Veiculo
	Local oStrucMot	:= StrModMot(1)	// Struct dos Dados do Motorista	
	Local oStrucinfQ	:= StrModinfQ(1)	// Struct dos Dados da quantidades da Carga do CT-e	
	Local oStrucPeri	:= StrModPeri(1)	// Struct dos Dados de Produtos Perigos
	Local oStrucLacre	:= StrModLacre(1)	// Struct dos Dados de Lacres

	oModel := MPFormModel():New("TMSAE90", /*bPreValid*/, {|oModel|PosVldMdl(oModel)}, {|oModel|XmlCCeCTe(oModel)} /*bCommit*/, ZeraVarSt()/*bCancel*/)

	oModel:SetVldActivate({|oModel| PreValid(oModel)})
	
	oModel:AddFields("TMSAE90_01", Nil,oStruCTE , /*bPre*/, /*bPost*/, { | oModel, lLoad | retContCTE( oModel, lLoad ) }/*bLoad*/)

	oModel:AddGrid( 'DETAIL_CTE'		, 'TMSAE90_01', oStruVal, 	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | loadGridCTE( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_NF'		, 'TMSAE90_01', oStrucNF, 	/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | loadGridNF( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_VEIC'	, 'TMSAE90_01', oStrucVeic, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { | oModel, lLoad | loadGridVeic( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_MOT'		, 'TMSAE90_01', oStrucMot, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/	, { | oModel, lLoad | loadGridMot( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_INFQ'	, 'TMSAE90_01', oStrucinfQ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/	, { | oModel, lLoad | loadGridinfQ( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_PERIG'	, 'TMSAE90_01', oStrucPeri, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/	, { | oModel, lLoad | loadGridPeri( oModel, lLoad ) } /*BLoad*/ )
	oModel:AddGrid( 'DETAIL_LACRE'	, 'TMSAE90_01', oStrucLacre, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,{ | oModel, lLoad | loadGridLacre( oModel, lLoad ) } /*BLoad*/ )

	oModel:SetDescription("Parâmetros")
	oModel:GetModel("TMSAE90_01"):SetDescription("Carta de Correção CT-e")
	oModel:GetModel("DETAIL_CTE"):SetDescription("CTE - Emitidos")
	oModel:GetModel("DETAIL_NF"):SetDescription("Notas Transportadas")
	oModel:GetModel("DETAIL_VEIC"):SetDescription("Veículos do CTE")
	oModel:GetModel("DETAIL_MOT"):SetDescription("Motorista da Viagem")
	oModel:GetModel("DETAIL_INFQ"):SetDescription("Inf. de Quantidades da Carga")
	oModel:GetModel("DETAIL_PERIG"):SetDescription("Produtos Perigosos")		
	oModel:GetModel("DETAIL_LACRE"):SetDescription("Lacre")

	oModel:GetModel( "DETAIL_VEIC" ):SetOptional( .T. )
	oModel:GetModel( "DETAIL_MOT" ):SetOptional( .T. )
	oModel:GetModel( "DETAIL_INFQ" ):SetOptional( .T. )
	oModel:GetModel( "DETAIL_PERIG" ):SetOptional( .T. )
	oModel:GetModel( "DETAIL_LACRE" ):SetOptional( .T. )
		
	oModel:SetPrimaryKey({"REM_XNOME"})

	oModel:SetActivate({||BuildCopy()})
	
Return oModel

/*
Função que irá realizar uma copia do modelo atual, para depois comparar com que foi alterado.

@author Fabio Marchiori Sampaio	/ Rodrigo Tecnologia
@since 17/01/14
@version 1.0
*/
Static Function BuildCopy()

__oCopy := ModelDef()

__oCopy:SetActivate({||.T.})
__oCopy:SetOperation(4)
__oCopy:Activate()

Return .T.

//------------------------------------------------------------------------------------------------

Static Function ViewDef()
  
	Local oView   		:= Nil 
	Local oStruVal		:= StrModVal(2) // Struc dos Valores do CTE
	Local oStruCTE    	:= StrModCTE(2) // Struct dos Dados do CTE
	Local oStrucNF  	:= StrModNF(2) // Struct dos Dados da NF
	Local oStrucVeic	:= StrModVeic(2)	// Struct dos Dados do Veiculo
	Local oStrucMot		:= StrModMot(2)	// Struct dos Dados do Motorista
	Local oStrucinfQ	:= StrModinfQ(2)	// Struct dos Dados das informações de quantidade da Carga
	Local oStrucPeri	:= StrModPeri(2)	// Struct dos Dados Produtos Perigosos	
	Local oStrucLacre	:= StrModLacre(2)	// Struct dos Dados Produtos Perigosos
	Local oModel  		:= FWLoadModel("TMSAE90") 

	oView:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("TMSAE90_01" , oStruCTE, /*cLinkID*/ )

   	oView:AddGrid('VIEW_CTE'	,oStruVal,"DETAIL_CTE")
   	oView:AddGrid('VIEW_DTC'	,oStrucNF,"DETAIL_NF")
   	oView:AddGrid('VIEW_VEIC',oStrucVeic,"DETAIL_VEIC")
   	oView:AddGrid('VIEW_MOT',oStrucMot,"DETAIL_MOT")
   	oView:AddGrid('VIEW_INFQ',oStrucinfQ,"DETAIL_INFQ")
   	oView:AddGrid('VIEW_PERIG',oStrucPeri,"DETAIL_PERIG")
   	oView:AddGrid('VIEW_LACRE',oStrucLacre,"DETAIL_LACRE")   	

	oView:CreateHorizontalBox( "MASTER"			, 55,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
   	oView:CreateHorizontalBox( "DETAIL"			, 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ ) 
	oView:CreateHorizontalBox( "DETAIL_CTE"	, 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_NF"  	, 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAIL_VEIC"	, 100,,,"IDFOLDER","IDSHEET03" )
	oView:CreateHorizontalBox( "DETAIL_MOT"	, 100,,,"IDFOLDER","IDSHEET04" )
	oView:CreateHorizontalBox( "DETAIL_INFQ"	, 100,,,"IDFOLDER","IDSHEET05" )
	oView:CreateHorizontalBox( "DETAIL_PERIG"	, 100,,,"IDFOLDER","IDSHEET06" )
	oView:CreateHorizontalBox( "DETAIL_LACRE"	, 100,,,"IDFOLDER","IDSHEET07" )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","CTE")						//"CTE"
	oView:AddSheet("IDFOLDER","IDSHEET02","Notas")					//"Notas"
	oView:AddSheet("IDFOLDER","IDSHEET03","Veículos")				//"Veiculos"	
	oView:AddSheet("IDFOLDER","IDSHEET04","Motoristas")				//"Motoristas"
	oView:AddSheet("IDFOLDER","IDSHEET05","Qtd. Inf. Carga CT-e")	//"Qtd. Inf. Carga CT-e "	
	oView:AddSheet("IDFOLDER","IDSHEET06","Prod. Perigosos")		//"Produtos Perigosos"	
	oView:AddSheet("IDFOLDER","IDSHEET07","Lacre")					//"Lacre"

	oView:SetOwnerView("TMSAE90_01"	,"MASTER")
	oView:SetOwnerView("VIEW_CTE"	,"DETAIL_CTE")
	oView:SetOwnerView("VIEW_DTC"	,"DETAIL_NF")
	oView:SetOwnerView("VIEW_VEIC"	,"DETAIL_VEIC")
	oView:SetOwnerView("VIEW_MOT"	,"DETAIL_MOT")
	oView:SetOwnerView("VIEW_INFQ"	,"DETAIL_INFQ")	
	oView:SetOwnerView("VIEW_PERIG"	,"DETAIL_PERIG")
	oView:SetOwnerView("VIEW_LACRE"	,"DETAIL_LACRE")	
	
	oView:AddIncrementField("VIEW_CTE"		,"DETAIL_CTE")
	oView:AddIncrementField("VIEW_DTC"		,"DETAIL_NF")
	oView:AddIncrementField("VIEW_VEIC"	,"DETAIL_VEIC")	
	oView:AddIncrementField("VIEW_MOT"		,"DETAIL_MOT")
	oView:AddIncrementField("VIEW_INFQ"	,"DETAIL_INFQ")
	oView:AddIncrementField("VIEW_PERIG"	,"DETAIL_PERIG")
	oView:AddIncrementField("VIEW_LACRE"	,"DETAIL_LACRE")

Return oView

/*
Função que irá retornar o conteudo da Tag do CT-e já transmitido

@author Fabio Marchiori Sampaio	/ Flavio Vicco
@since 04/12/13
@version 1.0
*/

Static Function retContTag(cVar)

	Local cRet  		:= ""
	Local aXml 		:= {}
	Local cIdEnt		:= ""
	Local cModalidade	:= ""
	Local cVersaoCTE	:= ""
	Local cAviso 		:= ""
	Local cErro 		:= ""

	Default cVar 		:= ""
	
	If Type("lUsaColab") == "U" 
		Private lUsaColab := UsaColaboracao("2")
	EndIf
	
	If ValType(Onfe) == "U"
		If !lUsaColab
			TMSSpedNFe(@cIdEnt,@cModalidade,@cVersaoCTE,lUsaColab)
		EndIf
		aNotas := {}
		aadd(aNotas,{})
		aAdd(Atail(aNotas),.F.)
	
		aadd(Atail(aNotas),"S")
		aAdd(Atail(aNotas),"")
		aAdd(Atail(aNotas),DT6->DT6_SERIE) //SERIE
		aAdd(Atail(aNotas),DT6->DT6_DOC) //Documento
		aadd(Atail(aNotas),"")
		aadd(Atail(aNotas),"")
	
		If lUsaColab
			//-- TOTVS Colaboracao 2.0
			aXml := TMSColXML(aNotas,@cModalidade,lUsaColab)
		Else
			aXml := TMSGetXML(@cIdEnt,aNotas,@cModalidade)
		EndIf
		oNfe := XmlParser(aXML[1][2],"_",@cAviso,@cErro)
	EndIf
	
	If Type(cVar) <> "U"
		If 	ValType(cVar+":TEXT") == "C"
			cRet := &(cVar+":TEXT")
		EndIf
	EndIf	

Return(cRet)

/*
Função que irá Gerar o XML para envio da Carta de Correção para CTe

@author Fabio Marchiori Sampaio
@since 04/12/13                

@version 1.0
*/

Static Function XmlCCeCTe(oModel)

Local aDiff 	:= oModel:Compare(__oCopy)
Local lRet		:= .F.

If XmlCCe(aDiff)
	ZeraVarSt()
	lRet := .T.                  
Else
	oModel:SetErrorMessage(,,,,"CC-e","Não e possível apagar um conteúdo já enviado, somente alterar.")
	lRet := .F.
EndIf

Return(lRet)

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} CamposCTE
Criação do array para o objeto Struct dos Dados do CTE
Uso restrito

@sample
CamposCTE()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CamposCTE()
Local acampos

// Os tamanhos dos campos foram criados com base na manual da SEFAZ CTE Versão 2.0

aCampos :={ ;
{"Nome do Emitente" 					,"EMIT_XNOME"	  			 	,"C",60	 ,0,"@!"						,"Emiten" ," "		   			, TMSAE90Whe("emit","xNome")			,"emit"			, 	"xNome"	,"G", "01" ,{|| ValidCampo("EMIT")}		   					,"  "		,																, 	{}		},; 
{"Nome Fantasia" 						,"EMIT_NOME_FANT"			 	,"C",60 	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("emit","xFant") 			,"emit"			, 	"xFant"	,"G", "02" ,{|| ValidCampo("EMIT")}		  					,"  "		,																, 	{}		},; 
{"CNPJ/CPF Remetente"				,"EMIT_CNPJ" 	  			 	,"C",14 	 ,0,"@!" 						,"Emiten" ," "		   	 		, .F. 										,"emit"			,	"CNPJ"		,"G", "03" ,													,"  "		,																, 	{}		},; 
{"Inscrição Estadual"				,"EMIT_IE"		  			 	,"C",14	 ,0,"@!"						,"Emiten" ," "			 		, .F. 										,"emit"			,	"IE"		,"G", "04" ,													,"  "		,																, 	{}		},;
{"End Remetente"    	   				,"EMIT_XLGR"   	    	 	,"C",255	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("enderEmit","xLgr") 		,"enderEmit" 		,	"xLgr"		,"G", "05" ,{|| ValidCampo("EMIT")}							,"  "		,																, 	{}		},;
{"Numero"				    			,"EMIT_NRO" 		        	,"C",10 	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("enderEmit","nro") 		,"enderEmit" 		,	"nro"		,"G", "06" ,{|| ValidCampo("EMIT")}	  						,"  "		,																, 	{}		},;
{"Complemento"			    		,"EMIT_XCPL" 		   		 	,"C",60 	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("enderEmit","xCpl") 		,"enderEmit" 		,	"xCpl"		,"G", "07" ,{|| ValidCampo("EMIT")}	  						,"  "		,																, 	{}		},;
{"Bairro"				   	 			,"EMIT_XBAIRRO"	        	,"C",60 	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("enderEmit","xBairro") 	,"enderEmit" 		,	"xBairro"	,"G", "08" ,{|| ValidCampo("EMIT")}			   				,"  "		,																, 	{}		},;
{"CEP" 					    		,"EMIT_CEP"       		 	,"C",8  	 ,0,"@!"						,"Emiten" ," "		   	 		, TMSAE90Whe("enderEmit","CEP") 		,"enderEmit" 		,	"CEP"		,"G", "09" ,{|| ValidCampo("EMIT")}							,"  "		,																, 	{}		},;
{"Cód. Mun"              			,"EMIT_CMUN"		      	 	,"C",7 	 ,0,"@!"						,"Emiten" ," "		   	 		, TMSAE90Whe("enderEmit","cMun") 		,"enderEmit" 		,	"cMun"		,"G", "10" ,{|| ValidCampo("EMIT")}							,"CC2CCE"	,																,	{}		},;
{"Municipio"              			,"EMIT_XMUN"		        	,"C",60 	 ,0,"@!"						,"Emiten" ," "		   	 		, TMSAE90Whe("enderEmit","xMun") 		,"enderEmit" 		,	"xMun"		,"G", "11" ,{|| ValidCampo("EMIT")}							,"  "		,																, 	{}		},;
{"Estado" 				    			,"EMIT_UF"				  	 	,"C",2  	 ,0,"@!"						,"Emiten" ," "			 		, .F. 										,"enderEmit" 		,	"UF"		,"G", "12" ,													,"  "		,																, 	{}		},;
{"Fone"								,"EMIT_FONE"				 	,"C",14 	 ,0,"@!"						,"Emiten" ," "			 		, TMSAE90Whe("enderEmit","Fone") 		,"enderEmit"		,	"Fone"		,"G", "13" ,{|| ValidCampo("EMIT")}							,"  "		,																, 	{}		},;
{"Nome do Rementente" 				,"REM_XNOME"	  			 	,"C",60	 ,0,"@!"						,"Remete" ," "		   			, TMSAE90Whe("rem","xNome") 			,"rem"				, 	"xNome"	,"G", "01" ,{|| ValidCampo("REM")}		   					,"  "		,																, 	{}		},; 
{"Nome Fantasia" 						,"REM_NOME_FANT"			 	,"C",60 	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("rem","xFant") 			,"rem"				, 	"xFant"	,"G", "02" ,{|| ValidCampo("REM")}		   					,"  "		,																, 	{}		},; 
{"CNPJ/CPF Remetente"				,"REM_CNPJ" 	  			 	,"C",14    ,0,"@!" 						,"Remete" ," "		   	 		, .F. 										,"rem"				,	"CNPJ"		,"G", "03" ,													,"  "		,																, 	{}		},; 
{"Inscrição Estadual"				,"REM_IE"		  			 	,"C",14    ,0,"@!"						,"Remete" ," "			 		, .F. 										,"rem"				,	"IE"		,"G", "04" ,													,"  "		,																, 	{}		},;
{"Fone"								,"REM_FONE"				 	,"C",14 	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("rem","Fone") 				,"rem"				,	"Fone"		,"G", "05" ,{|| ValidCampo("REM")}							,"  "		,																, 	{}		},;
{"End Remetente"    	   				,"REM_XLGR"   	    	 	,"C",255	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("enderReme","xLgr") 		,"enderReme" 		,	"xLgr"		,"G", "06" ,{|| ValidCampo("REM")}							,"  "		,																, 	{}		},;
{"Numero"				    			,"REM_NRO" 		        	,"C",10 	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("enderReme","nro") 		,"enderReme" 		,	"nro"		,"G", "07" ,{|| ValidCampo("REM")}	  						,"  "		,																, 	{}		},;
{"Complemento"			    		,"REM_XCPL" 		   		 	,"C",60 	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("enderReme","xCpl") 		,"enderReme" 		,	"xCpl"		,"G", "08" ,{|| ValidCampo("REM")}	  						,"  "		,																, 	{}		},;
{"Bairro"				    			,"REM_XBAIRRO"	        	,"C",60 	 ,0,"@!"						,"Remete" ," "			 		, TMSAE90Whe("enderReme","xBairro") 	,"enderReme" 		,	"xBairro"	,"G", "09" ,{|| ValidCampo("REM")}			   				,"  "		,																, 	{}		},;
{"CEP" 					    		,"REM_CEP"       		 	 	,"C",8  	 ,0,"@!"						,"Remete" ," "		   	 		, TMSAE90Whe("enderReme","CEP") 		,"enderReme" 		,	"CEP"		,"G", "10" ,{|| ValidCampo("REM")}							,"  "		,																, 	{}		},;
{"Cód. Mun"              			,"REM_CMUN"		      	 	,"C",7 	 ,0,"@!"						,"Remete" ," "		   	 		, TMSAE90Whe("enderReme","cMun") 		,"enderReme" 		,	"cMun"		,"G", "11" ,{|| ValidCampo("REM")}							,"CC2CCE"	,																, 	{}		},;
{"Municipio"              			,"REM_XMUN"		        	,"C",60 	 ,0,"@!"						,"Remete" ," "		   	 		, TMSAE90Whe("enderReme","xMun") 		,"enderReme" 		,	"xMun"		,"G", "12" ,{|| ValidCampo("REM")}							,"  "		,																, 	{}		},;
{"Estado" 				    			,"REM_UF"				  	 	,"C",2  	 ,0,"@!"						,"Remete" ," "			 		, .F. 										,"enderReme" 		,	"UF"		,"G", "13" ,													,"  "		,																, 	{}		},;
{"Pais"								,"REM_XPAIS"			  	 	,"C",60 	 ,0,"@!"						,"Remete" ," "			 		, .F. 										,"enderReme" 		,	"xPais"	,"G", "14" ,													,"  "		,																, 	{}		},;
{"Nome do Destinatario"				,"DEST_XNOME" 			 	,"C",60	 ,0,"@!"	   					,"Destina"," "					, TMSAE90Whe("dest","xNome") 			,"dest"			,	"xNome"	,"G", "01" ,{|| ValidCampo("DEST")}							,"  "		,																, 	{}		},;
{"CNPJ Destinatario"	  				,"DEST_CNPJ" 				 	,"C",14    ,0,"@!"						,"Destina"," "			 	 	, .F.										,"dest"			,	"CNPJ"		,"G", "02" ,		   											,"  "		,																, 	{}		},;
{"Inscrição Estadual" 				,"DEST_IE"					 	,"C",14 	 ,0,"@!"						,"Destina"," "		   	 	 	, .F. 										,"dest"			,	"IE"		,"G", "03" ,			   										,"  "		,																, 	{}		},;
{"Fone"								,"DEST_FONE"				 	,"C",14 	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("dest","fone") 			,"dest"			,	"fone"		,"G", "04" ,{|| ValidCampo("DEST")}			   				,"  "		,																, 	{}		},;
{"End Destinatario"					,"DEST_XLGR"			  	 	,"C",255	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","xLgr") 		,"enderDest" 		,	"xLgr"		,"G", "05" ,{|| ValidCampo("DEST")}							,"  "		,																, 	{}		},;
{"Numero"				    			,"DEST_NRO" 		   		 	,"C",10 	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","nro") 		,"enderDest" 		,	"nro"		,"G", "06" ,{|| ValidCampo("DEST")}							,"  "		,																, 	{}		},;
{"Complemento"			    		,"DEST_XCPL" 		   		 	,"C",60 	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","xCpl") 		,"enderDest" 		,	"xCpl"		,"G", "07" ,{|| ValidCampo("DEST")}							,"  "		,																, 	{}		},;
{"Bairro"				   	 			,"DEST_XBAIRRO"			 	,"C",60 	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","xBairro") 	,"enderDest" 		,	"xBairro"	,"G", "08" ,{|| ValidCampo("DEST")}	 						,"  "		,																, 	{}		},;
{"CEP"					    			,"DEST_CEP"	 			 	,"C",8  	 ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","CEP") 		,"enderDest" 		,	"CEP"		,"G", "09" ,{|| ValidCampo("DEST")}							,"  "		,																, 	{}		},;
{"Cód. Mun"              			,"DEST_CMUN"		    	 	,"C",7 	 ,0,"@!"						,"Destina"," "		   	     	, TMSAE90Whe("enderDest","cMun") 		,"enderDest" 		,	"cMun"		,"G", "10" ,{|| ValidCampo("DEST")}							,"CC2CCE"	,																, 	{}		},;
{"Municipio"			    			,"DEST_XMUN"				 	,"C",60    ,0,"@!"						,"Destina"," "			 	 	, TMSAE90Whe("enderDest","xMun") 		,"enderDest" 		,	"xMun"		,"G", "11" ,{|| ValidCampo("DEST")}							,"  "	    ,																, 	{}		},;
{"Estado"				    			,"DEST_UF"		   			 	,"C",2  	 ,0,"@!"						,"Destina"," "			 	 	, .F. 										,"enderDest" 		,	"UF"		,"G", "12" ,													,"  "		,																, 	{}		},;
{"Pais"								,"DEST_XPAIS"		   		 	,"C",60 	 ,0,"@!"						,"Destina"," "			 	 	, .F. 										,"enderDest" 		,	"xPais"	,"G", "13" ,													,"  "		,																, 	{}		},;
{"Nome do Consignatário"				,"CON_XNOME" 				 	,"C",60 	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("toma4","xNome") 			,"toma4"	    	,	"xNome"	,"G", "01" ,{|| ValidCampo("CONSI")}						,"  "		,																, 	{}		},;
{"CNPJ Devedor"						,"CON_CNPJ" 				 	,"C",14    ,0,"@!"						,"Consign"," "			 	 	, .F. 										,"toma4"	    	,	"CNPJ"		,"G", "02" ,													,"  "		,																, 	{}		},;
{"Inscrição Estadual"				,"CON_IE"					 	,"C",14 	 ,0,"@!"						,"Consign"," "			 	 	, .F. 										,"toma4"	    	,	"IE"		,"G", "03" ,										   			,"  "		,																, 	{}		},;
{"Fone"								,"CON_FONE"				 	,"C",14 	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("toma4","fone") 			,"toma4"	    	,	"fone"		,"G", "04" ,{|| ValidCampo("CONSI")}			 			,"  "		,																, 	{}		},;
{"End Devedor"						,"CON_XLGR"	   	  		 	,"C",255	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("enderToma","xLgr") 		,"enderToma" 		,	"xLgr"		,"G", "05" ,{|| ValidCampo("CONSI")}			  			,"  "		,																, 	{}		},;
{"Numero"				    			,"CON_NRO" 		    	 	,"C",10 	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("enderToma","nro") 		,"enderToma" 		,	"nro"		,"G", "06" ,{|| ValidCampo("CONSI" )}						,"  "		,																, 	{}		},;
{"Complemento"			   			,"CON_XCPL" 		    	 	,"C",60 	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("enderToma","xCpl") 		,"enderToma" 		,	"xCpl"		,"G", "07" ,{|| ValidCampo("CONSI")}						,"  "		,																, 	{}		},;
{"Bairro"				    			,"CON_XBAIRRO"	   	   	 	,"C",60 	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("enderToma","xBairro") 	,"enderToma" 		,	"xBairro"	,"G", "08" ,{|| ValidCampo("CONSI")} 			 			,"  "		,																, 	{}		},;
{"CEP"					    			,"CON_CEP"		   	   		 	,"C",8  	 ,0,"@!"						,"Consign"," "			 	 	, TMSAE90Whe("enderToma","CEP") 		,"enderToma" 		,	"CEP"		,"G", "09" ,{|| ValidCampo("CONSI")}			   			,"  "		,																, 	{}		},;
{"Cód. Mun"              			,"CON_CMUN"			   	 	,"C",7 	 ,0,"@!"						,"Consign"," "		   	 		, TMSAE90Whe("enderReme","cMun") 		,"enderReme" 		,	"cMun"		,"G", "10" ,{|| ValidCampo("CONSI")}						,"CC2CCE"  ,																, 	{}		},;
{"Municipio"			    			,"CON_XMUN"		   	   	 	,"C",60 	 ,0,"@!"						,"Consign"," "				 	, TMSAE90Whe("enderToma","xMun") 		,"enderToma" 		,	"xMun"		,"G", "11" ,{|| ValidCampo("CONSI")}						,"  "		,																, 	{}		},;
{"Estado"				    			,"CON_UF"		   	   	   	 	,"C",2  	 ,0,"@!"						,"Consign"," "			 	 	, .F. 										,"enderToma" 		,	"UF"		,"G", "12" ,										   			,"  "      ,																, 	{}		},;
{"Nome do Expedidor"	    			,"EXPED_XNOME" 			 	,"C",60 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("exped","xNome") 			,"exped"			,	"xNome"	,"G", "01" ,{|| ValidCampo("EXPED")}						,"  "		,																, 	{}		},;
{"CNPJ Expedidor" 					,"EXPED_CNPJ" 			 	,"C",14 	 ,0,"@!"						,"LocCole","LocExpedi"	 		, .F. 										,"exped"			,	"CNPJ"		,"G", "02" ,													,"  "		,																, 	{}		},;
{"Inscrição Estadual"				,"EXPED_IE"				 	,"C",14 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, .F. 										,"exped"			,	"IE"		,"G", "03" ,										   			,"  "		,																, 	{}		},;
{"Fone"				   				,"EXPED_FONE"			   	 	,"C",14 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("exped","fone") 			,"exped"			,	"fone"		,"G", "04" ,{|| ValidCampo("EXPED")}			   			,"  "		,																, 	{}		},;
{"End Remetente"		    			,"EXPED_XLGR"	   			 	,"C",255	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("enderExped","xLgr") 		,"enderExped"		,	"xLgr"		,"G", "05" ,{|| ValidCampo("EXPED")}			   			,"  "		,																, 	{}		},;
{"Numero" 				    			,"EXPED_NRO"    	   		 	,"C",10 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("enderExped","nro") 		,"enderExped"		,	"nro"		,"G", "06" ,{|| ValidCampo("EXPED")}			   			,"  "		,																, 	{}		},;
{"Complemento" 			    		,"EXPED_XCPL"   	   		 	,"C",60 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("enderExped","xCpl") 		,"enderExped"		,	"xCpl"		,"G", "07" ,{|| ValidCampo("EXPED")}			  			,"  "		,																, 	{}		},;
{"Bairro" 				    			,"EXPED_XBAIRRO"	  		 	,"C",60 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("enderExped","xBairro") 	,"enderExped"		,	"xBairro"	,"G", "08" ,{|| ValidCampo("EXPED")}		 				,"  "		,																, 	{}		},;
{"CEP" 					    		,"EXPED_CEP"	   	   		 	,"C",8  	 ,0,"@!"						,"LocCole","LocExpedi"	 		, TMSAE90Whe("enderExped","CEP") 		,"enderExped"		,	"CEP"		,"G", "09" ,{|| ValidCampo("EXPED")}			   			,"  "		,																, 	{}		},;
{"Cód. Mun"              			,"EXPED_CMUN"		    	 	,"C",7 	 ,0,"@!"						,"LocCole","LocExpedi"	 		, TMSAE90Whe("enderExped","cMun") 		,"enderExped" 	,	"cMun"		,"G", "10" ,{|| ValidCampo("EXPED")}						,"CC2CCE"	,																, 	{}		},;
{"Municipio"			    			,"EXPED_XMUN"   	   		 	,"C",60 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, TMSAE90Whe("enderExped","xMun") 		,"enderExped"		,	"xMun"		,"G", "11" ,{|| ValidCampo("EXPED")}			   			,"  "		,																, 	{}		},;
{"Estado"				    			,"EXPED_UF"	   	   		 	,"C",2  	 ,0,"@!"						,"LocCole","LocExpedi"		 	, .F. 										,"enderExped"		,	"UF"		,"G", "12" ,										   			,"  "		,																, 	{}		},;
{"Pais"								,"EXPED_XPAIS"	   		 	,"C",60 	 ,0,"@!"						,"LocCole","LocExpedi"		 	, .F. 										,"enderExped"		,	"xPais"	,"G", "13" ,													,"  "		,																, 	{}		},;
{"Nome: Local Coleta"  				,"LOCCOLETA_XNOME" 	   	 	,"C",60 	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","xNome") 		,"locColeta" 		,	"xNome"	,"G", "01" ,{|| ValidCampo("LOCCOLETA")}					,"  "		,																, 	{}		},;
{"CNPJ Destinatario"	    			,"LOCCOLETA_CNPJ" 	   	 	,"C",14 	 ,0,"@!"						,"LocCole","OrigColet"		 	, .F. 										,"locColeta" 		,	"CNPJ"		,"G", "02" ,													,"  "		,																, 	{}		},;
{"Inscrição Estadual"				,"LOCCOLETA_IE"		   	 	,"C",14 	 ,0,"@!"						,"LocCole","OrigColet"		 	, .F. 										,"locColeta" 		,	"IE"		,"G", "03" ,													,"  "		,																, 	{}		},;
{"End Destinatario" 	    			,"LOCCOLETA_XLGR"	   		 	,"C",255	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","xLgr") 		,"locColeta" 		,	"xLgr"		,"G", "04" ,{|| ValidCampo("LOCCOLETA")}					,"  "		,																, 	{}		},;
{"Numero"				    			,"LOCCOLETA_NRO" 			 	,"C",10 	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","nro") 		,"locColeta" 		,	"nro"		,"G", "05" ,{|| ValidCampo("LOCCOLETA")}					,"  "		,																, 	{}		},;
{"Complemento"						,"LOCCOLETA_COMPL" 		 	,"C",60 	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","xCpl") 		,"locColeta" 		,	"xCpl"		,"G", "06" ,{|| ValidCampo("LOCCOLETA")}					,"  "		,																, 	{}		},;
{"Bairro"				    			,"LOCCOLETA_XBAIRRO"		 	,"C",60 	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","xBairro") 	,"locColeta" 		,	"xBairro"	,"G", "07" ,{|| ValidCampo("LOCCOLETA")}					,"  "	    ,																, 	{}		},;
{"Cód. Mun"              			,"LOCCOLETA_CMUN"			 	,"C",7 	 ,0,"@!"						,"LocCole","OrigColet"	 		, TMSAE90Whe("locColeta","cMun") 		,"locColeta" 		,	"cMun"		,"G", "09" ,{|| ValidCampo("LOCCOLETA")}					,"CC2CCE"  ,																, 	{}		},;
{"Municipio"			    			,"LOCCOLETA_XMUN"	   		 	,"C",60 	 ,0,"@!"						,"LocCole","OrigColet"		 	, TMSAE90Whe("locColeta","xMun") 		,"locColeta" 		,	"xMun"		,"G", "10" ,{|| ValidCampo("LOCCOLETA")}					,"  "	    ,																, 	{}		},;
{"Estado"				    			,"LOCCOLETA_UF"	   		 	,"C",2  	 ,0,"@!"						,"LocCole","OrigColet"		 	, .F. 										,"locColeta" 		,	"UF"		,"G", "11" ,													,"  "	    ,																, 	{}		},;
{"Nome"								,"RECEB_XNOME" 			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 		 	, TMSAE90Whe("locEnt","xNome") 			,"enderReceb"		,	"xNome"	,"G", "01" ,{|| ValidCampo("RECEB","xNome")}	    		,"  "	    ,																, 	{}		},;
{"CNPJ Destinatario"	    			,"RECEB_CNPJ" 			 	,"C",14 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	 		, .F. 										,"enderReceb"		,	"CNPJ"		,"G", "02" ,													,"  "	    ,																, 	{}		},;
{"End Destinatario" 	    			,"RECEB_XLGR"		   		 	,"C",255	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	     	, TMSAE90Whe("locEnt","xLgr") 			,"enderReceb"		,	"xLgr"		,"G", "03" ,{|| ValidCampo("RECEB","xLgr")}				,"  "	    ,																, 	{}		},;
{"Numero"				    			,"RECEB_NRO" 				 	,"C",10 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	     	, TMSAE90Whe("locEnt","nro") 			,"enderReceb"		,	"nro"		,"G", "04" ,{|| ValidCampo("RECEB","nro")}				,"  "	    ,																, 	{}		},;
{"Complemento"			   		 	,"RECEB_XCPL" 			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	  		, TMSAE90Whe("locEnt","xCpl") 			,"enderReceb"		,	"xCpl"		,"G", "05" ,{|| ValidCampo("RECEB","xCpl")}				,"  "	    ,																, 	{}		},;
{"Bairro"				    			,"RECEB_XBAIRRO"			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	    	, TMSAE90Whe("locEnt","xBairro") 		,"enderReceb"		,	"xBairro"	,"G", "06" ,{|| ValidCampo("RECEB","xBairro")}			,"  "	    ,																, 	{}		},;
{"Cód. Mun"              			,"RECEB_CMUN"	   	   		 	,"C",7 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 	 		, TMSAE90Whe("locEnt","cMun") 			,"enderReceb"		,	"cMun"		,"G", "07" ,{|| ValidCampo("RECEB","cMun")}				,"CC2CCE"  ,																, 	{}		},;
{"Municipio"			    			,"RECEB_XMUN"		   		 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 		 	, TMSAE90Whe("locEnt","xMun") 			,"enderReceb"		,	"xMun"		,"G", "08" ,{|| ValidCampo("RECEB","xMun")} 				,"  "	    ,																, 	{}		},;
{"Estado"				    			,"RECEB_UF"					,"C",2  	 ,0,"@!"						,"LocEnt" ,"LocEntPres" 		 	, .F. 										,"enderReceb"		,	"UF"		,"G", "09" ,										 			,"  "	    ,																, 	{}		},;
{"Nome"				   				,"LOCENT_XNOME" 			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, TMSAE90Whe("locEnt","xNome") 			,"locEnt"			,	"xNome"	,"G", "01" ,{|| ValidCampo("LOCENT")}						,"  "	    ,																, 	{}		},;
{"CNPJ Destinatario"	    			,"LOCENT_CNPJ" 			 	,"C",14 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, .F. 										,"locEnt"			,	"CNPJ"		,"G", "02" ,													,"  "	    ,																, 	{}		},;
{"End Destinatario"	   				,"LOCENT_XLGR"		     	,"C",255	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, TMSAE90Whe("locEnt","xLgr") 			,"locEnt"			,	"xLgr"		,"G", "03" ,{|| ValidCampo("LOCENT")}						,"  "	    ,																, 	{}		},;
{"Numero"				    			,"LOCENT_NRO" 			 	,"C",10 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 	 		, TMSAE90Whe("locEnt","nro") 			,"locEnt"			,	"nro"		,"G", "04" ,{|| ValidCampo("LOCENT")}			   			,"  "	    ,																, 	{}		},;
{"Complemento"			    		,"LOCENT_XCPL" 			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, TMSAE90Whe("locEnt","xCpl") 			,"locEnt"			,	"xCpl"		,"G", "05" ,{|| ValidCampo("LOCENT")}						,"  "	    ,																, 	{}		},;
{"Bairro"			    				,"LOCENT_XBAIRRO"			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, TMSAE90Whe("locEnt","xBairro") 		,"locEnt"			,	"xBairro"	,"G", "06" ,{|| ValidCampo("LOCENT")}		 				,"  "	    ,																, 	{}		},;
{"Cód. Mun"              			,"LOCENT_CMUN"			 	,"C",7 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 	 		, TMSAE90Whe("locEnt","cMun") 			,"locEnt" 			,	"cMun"		,"G", "07" ,{|| ValidCampo("LOCENT")}						,"CC2CCE"  ,																, 	{}		},;
{"Municipio"			   				,"LOCENT_XMUN"			 	,"C",60 	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, TMSAE90Whe("locEnt","xMun") 			,"locEnt"			,	"xMun"		,"G", "08" ,{|| ValidCampo("LOCENT")}						,"  "	    ,																, 	{}  	},;
{"Estado" 				    			,"LOCENT_UF"	   		     	,"C",2  	 ,0,"@!"						,"LocEnt" ,"LocEntRece" 		 	, .F. 										,"locEnt"			,	"UF"		,"G", "09" ,													,"  "	    ,																, 	{}		},;
{"Responsável pelo Seguro" 			,"RESP_SEG"	   		     	,"C",1  	 ,0,"@!"						,"Seguro" ," " 				 	, TMSAE90Whe("seg","respSeg") 			,"seg"				,	"respSeg"	,"C", "01" ,{|| ValidCampo("SEG")}							,"  "	    ,																, 	{"0=Remetente","1=Expedidor","2=Recebedor","3=Destinatário","4=Emitente do CT-e", "5=Tomador de Serviço"}	},;
{"Nome Seguradora" 					,"NOME_SEG"	   		     	,"C",30 	 ,0,"@!"						,"Seguro" ," " 	   			 	, TMSAE90Whe("seg","xSeg") 				,"seg"				,	"xSeg"		,"G", "02" ,{|| ValidCampo("SEG")}							,"  "	    ,																, 	{}		},;
{"Número Apólice" 					,"NUM_APOL"	   		     	,"C",20  	 ,0,"@!"						,"Seguro" ," " 			 		, TMSAE90Whe("seg","nApol") 			,"seg"				,	"nApol"	,"G", "03" ,{|| ValidCampo("SEG")}							,"  "	    ,																, 	{}		},;
{"Valor Carga" 						,"V_CARGA"	   		       	,"N",14  	 ,2,"@E 999,999,999.99"	  	,"Seguro" ," " 			 		, TMSAE90Whe("seg","vCarga") 			,"seg"  			,	"vCarga"	,"G", "04" ,{|| ValidCampo("SEG")}							,"  "	    ,																, 	{}		},;
{"Produto Predominate"				,"PROD_PRED"				 	,"C",60	 ,0,"@!"						,"DetProd","ProdPred"		 	, TMSAE90Whe("infCarga","proPred") 	,"infCarga"		,	"proPred"  ,"G", "01" ,{|| ValidCampo("PROPRED")}						,"  "	    ,																, 	{}		},;
{"Valor Total da Carga"				,"VAL_TOT_CARGA"			 	,"N",14	 ,2,"@E 999,999,999.99"		,"DetProd","ProdPred" 		 	, TMSAE90Whe("infCarga","vCarga") 		,"infCarga"		,	"vCarga"	,"G", "02" ,{|| ValidCampo("PROPRED")}						,"  "	    ,																, 	{}		},;
{"Outras Características da Carga"	,"CARC_CARGA"				 	,"C",30	 ,0,"@!"						,"DetProd","ProdPred" 		 	, TMSAE90Whe("infCarga","xOutCat") 	,"infCarga"		,	"xOutCat"	,"G", "03" ,{|| ValidCampo("PROPRED")}						,"  "	    ,																, 	{}		},;
{"CNPJ / CPF"							,"CNPJ_ANT"				 	,"C",14	 ,0,"@!"						,"DocTAnt","DocAnt" 			 	, .F. 										,"emiDocAnt"		,	"CNPJ"		,"G", "01" ,													,"  "	    ,																, 	{}		},;
{"Inscrição Estadual"				,"IE_ANT"					 	,"C",14	 ,0,"@!"						,"DocTAnt","DocAnt" 			 	, .F. 										,"emiDocAnt"		,	"IE"		,"G", "02" ,													,"  "	    ,																, 	{}		},;
{"UF"									,"UF_ANT"					 	,"C",2	 	 ,0,"@!"						,"DocTAnt","DocAnt" 		 		, .F. 										,"emiDocAnt"		,	"UF"		,"G", "03" ,													,"  "	    ,																, 	{}		},;
{"Nome"								,"NOME_ANT"				 	,"C",60	 ,0,"@!"						,"DocTAnt","DocAnt" 			 	, TMSAE90Whe("emiDocAnt","xNome") 		,"emiDocAnt"		,	"xNome"	,"G", "04" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{}		},;
{"Tipo Doc de Transp Anterior"		,"TP_DOC_ANT"				 	,"C",2		 ,0,"@!"						,"DocTAnt","DocAnt" 		 		, TMSAE90Whe("idDocAntPap","tpDoc") 	,"idDocAntPap"	,	"tpDoc"	,"G", "05" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{"00=CTRC","01=CTAC","02=ACT","03=NF Modelo 7","04=NF Modelo 27","05=Conhecimento Aéreo Nacional","06=CTMC","07=ATRE","08=DTA (Despacho de Transito Aduaneiro)","09=Conhecimento Aéreo Internacional","10=Conhecimento - Carta de Porte Internacional","11=Conhecimneto Avulso","12=TIF (Transporte Internacional Ferroviários)","99=Outros"}		},;
{"Doc Transp Anterior"				,"DOC_ANT"					 	,"C",20	 ,0,"@!"						,"DocTAnt","DocAnt" 		 	 	, TMSAE90Whe("idDocAntPap","nDoc") 	,"idDocAntPap"	,	"nDoc"		,"G", "06" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{}		},;
{"Serie Transp Anterior"				,"SER_DOC_ANT"			 	,"C",3		 ,0,"@!"						,"DocTAnt","DocAnt" 		 		, TMSAE90Whe("idDocAntPap","serie") 	,"idDocAntPap"	,	"serie"	,"G", "07" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{}		},;
{"Dt Emis. Transp Anterior"			,"EMI_DOC_ANT"			 	,"D",8		 ,0,"@!"						,"DocTAnt","DocAnt" 		 		, TMSAE90Whe("idDocAntPap","dEmi") 	,"idDocAntPap"	,	"dEmi"		,"G", "08" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{}		},;		
{"Chave Doc Transp Anterior"		,"CHV_DOC_ANT"			 	,"C",44	 ,0,"@!"						,"DocTAnt","DocAnt" 			 	, TMSAE90Whe("idDocAntEle","chave") 	,"idDocAntEle"	,	"chave"	,"G", "09" ,{|| ValidCampo("TRANSANT")}					,"  "	    ,																, 	{}		}   ,;		
{"Obs. do CTe"						,"COMPL_CTE_OBS"			 	,"M",256	 ,0,"@!"						,"CompCTe"," " 			 	 	, TMSAE90Whe("compl","xObs") 			,"compl"			,	"xObs"		,"M", "01" , 													,"  "	    ,																, 	{}		}}		

Return acampos   

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModCTE
Criação do objeto Struct dos Dados do CTE
Uso restrito

@sample
StrModCTE()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function StrModCTE(nOp)

Local aCampos 		:= CamposCTE()
Local aAux			:= {}
Local nCont 		:= 1 
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(				;
	"ZZZZ"							,;      // [01] Alias da tabela
	{ "REM_XNOME"}					,;      // [02] Array com os campos que correspondem a primary key
	"CTE Dados"					)       // [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;               // [01] Ordem do indice
	"REM_XNOME"	, ;               // [02] ID
	"REM_XNOME"	, ;               // [03] Chave do indice
	"CTE dados"	, ;               // [04] Descrição do indice //"Calculo01"
	''              , ;               // [05] Expressão de lookUp dos campos de indice
	''              , ;               // [06] Nickname do indice
	.T.              )                // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][1]			, ;              // [01] Titulo do campo
		aCampos[nCont][1]			, ;              // [02] ToolTip do campo
		aCampos[nCont][2]			, ;              // [03] Id do Field
		aCampos[nCont][3]			, ;              // [04] Tipo do campo
		aCampos[nCont][4]			, ;              // [05] Tamanho do campo
		aCampos[nCont][5]			, ;              // [06] Decimal do campo
		aCampos[nCont][16]		, ;			     // [07] Code-block de validação do campo
		aCampos[nCont][14]		, ;              // [08] Code-block de validação When do campo
		aCampos[nCont][17]		, ;              // [09] Lista de valores permitido do campo
		.F.							, ;              // [10] Indica se o campo tem preenchimento obrigatório
									, ;              // [11] Code-block de inicializacao do campo
		.F.							, ;              // [12] Indica se trata-se de um campo chave 
		.F.							, ;              // [13] Indica se o campo pode receber valor em uma operação de update. 
		.F.							, ;              // [14] Indica se o campo é virtual
		, )

		nCont++
	End


	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'EMIT_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'EMIT_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("EMIT_UF")+SubStr(FwFldGet("EMIT_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'REM_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'REM_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("REM_UF")+SubStr(FwFldGet("REM_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'DEST_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'DEST_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("DEST_UF")+SubStr(FwFldGet("DEST_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'CON_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'CON_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("CON_UF")+SubStr(FwFldGet("CON_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'EXPED_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'EXPED_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("CON_UF")+SubStr(FwFldGet("EXPED_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'LOCCOLETA_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'LOCCOLETA_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("LOCCOLETA_UF")+SubStr(FwFldGet("LOCCOLETA_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------
	
		aAux := FwStruTrigger(;
		'RECEB_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'RECEB_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("RECEB_UF")+SubStr(FwFldGet("RECEB_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	//------------------------------------------------------------------
	//------------------------------------------------------------------

		aAux := FwStruTrigger(;
		'LOCENT_CMUN'                    										,; // Campo de Dominio (tem que existir no Model)
		'LOCENT_XMUN'                 											,; // Campo de ContraDominio (tem que existir no Model)
		'Posicione("CC2",1,xFilial("CC2")+FwFldGet("LOCENT_UF")+SubStr(FwFldGet("LOCENT_CMUN"),3,5),"CC2->CC2_MUN")' 	,; // Regra de Preenchimento
											                       				 ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
												                   				 ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											                       				 ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
													  							,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
														           				 )  // Condição para execução do gatilho (Opcional)
		 
		//  aAux tem o conteudo
		// [01] Id do campo de origem
		// [02] Id do campo de destino
		// [03] Bloco de codigo de validação da execução do gatilho
		// [04] Bloco de codigo de execução do gatilho
		oStruct:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()                                      

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][2]			, ;                // [01] Campo
		aCampos[nCont][13]		, ;                // [02] Ordem
		aCampos[nCont][1]			, ;                // [03] Titulo
		aCampos[nCont][1]			, ;                // [04] Descricao
		NIL							, ;                // [05] Help
		aCampos[nCont][11]		, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]			, ;                // [07] Picture
		NIL							, ;                // [08] PictVar
		aCampos[nCont][15]		, ;                // [09] F3
		aCampos[nCont][9]			, ;                // [10] Editavel
   		aCampos[nCont][7]			, ;                // [11] Folder
		aCampos[nCont][8]			, ;                // [12] Group
		aCampos[nCont][17]		, ;                // [13] Lista Combo
		NIL							, ;                // [14] Tam Max Combo
		"" 							, ;                // [15] Inic. Browse
		NIL							)				   // [16] Virtual

		nCont++
	End

	aFolder := {{"Emiten"		,"Emitente"	     	 	}	,;
				{"Remete"		,"Remetente"       	 	}	,;
				{"Destina"		,"Destinatário"      		}	,;
				{"Consign"		,"Consignatário"   	  	}   ,;
				{"LocCole"		,"Local de Coleta"  		}	,;
				{"LocEnt"		,"Local de Entrega"		}	,;
				{"DetProd"		,"Detalhes do Produto" 	}	,;
				{"DocTAnt"		,"Transporte Anterior" 	}	,;
				{"Seguro"		,"Dados do Seguro"		}	,;
				{"CompCTe"		,"Dados Compl. CTe"		}}

	For nCont := 1 to Len(aFolder)
		oStruct:AddFolder(aFolder[nCont][1],aFolder[nCont][2])
	Next nCont

	oStruct:AddGroup("OrigColet", "Local Coleta"		, "LocCole", 2) // "Destino Recebedor"
	oStruct:AddGroup("LocExpedi", "Expedidor"			, "LocCole", 2) // "Destino Prestador"	

	oStruct:AddGroup("LocEntRece", "Local Entrega"	, "LocEnt", 2) // "Destino Recebedor"
	oStruct:AddGroup("LocEntPres", "Recebedor"			, "LocEnt", 2) // "Destino Prestador"	
	
	oStruct:AddGroup("DocAnt"	, "Documento do Transporte Anterior"		, "DocTAnt", 2) // "Documento do Transporte Anterior Redesp"                                         		
	oStruct:AddGroup("ProdPred"	, "Produto Predominante"						, "DetProd", 2) // "Produto Predominante"

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CamposNF
Criação do array para o objeto Struct dos Dados da Nota Fiscal
Uso restrito

@sample
CamposNF()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CamposNF()
Local aCampos := {}

	// As Funções CampCompl, CamposNFe, CamposNF e CampOutros devem sempre conter os mesmos tamanhos de array, e as mesmas posições.
	aCampos:= { ;
	{"N. Doc"			, "NUMNFC_DTC"	   		    ,     "C", 20  						,0,PesqPict('DTC','DTC_NUMNFC')				,"","",.T.,"infNF" ,"nDoc"		,FWBuildFeature(STRUCT_FEATURE_VALID," NaoVazio()")	, "01", "G",	{}		},;
	{"Serie"			, "SERNFC_DTC"	   		    ,     "C", TamSX3('DTC_SERNFC')[1]  ,0,PesqPict('DTC','DTC_SERNFC')				,"","",.T.,"infNF" ,"serie"		,	   												, "02", "G",	{}		},;
	{"Emissão" 			, "EMINFC_DTC"	    		,     "D", TamSX3('DTC_EMINFC')[1]  ,0,PesqPict('DTC','DTC_EMINFC')				,"","",.T.,"infNF" ,"dEmi"		,FWBuildFeature(STRUCT_FEATURE_VALID," NaoVazio()")	, "03", "G",	{}		},;
	{"Vl. Tot. Produto"	, "VALPRO_DTC"	   		    ,     "N", TamSX3('DTC_VALOR')[1]  	,2,PesqPict('DTC','DTC_VALOR') 				,"","",.T.,"infNF" ,"vProd"		,FWBuildFeature(STRUCT_FEATURE_VALID," NaoVazio()")	, "04", "G",	{}		},;
	{"Vl. Tot. NF"		, "VALNF_DTC"	   		    ,     "N", TamSX3('DTC_VALOR')[1]  	,2,PesqPict('DTC','DTC_VALOR')			    ,"","",.T.,"infNF" ,"vNF"		,FWBuildFeature(STRUCT_FEATURE_VALID," NaoVazio()")	, "05", "G",	{}		},;
	{"Cod. Fiscal"		, "CF_DTC" 					, 	  "N", 4 					 	,0,"@E 9999"			 					,"","",.T.,"infNF" ,"nCFOP"  	,	   												, "06", "G",	{}		},;
	{"Base ICMS"		, "BASICM_DTC"				, 	  "N", TamSX3('DTC_BASICM')[1]  ,2,PesqPict('DTC','DTC_BASICM')				,"","",.T.,"infNF" ,"vBC"  		,	   												, "07", "G",	{}		},;
	{"Vlr. ICMS"	   	, "VALICM_DTC"				, 	  "N", TamSX3('DTC_VALICM')[1]  ,2,PesqPict('DTC','DTC_VALICM')				,"","",.T.,"infNF" ,"vICMS"  	,													, "08", "G",	{}		},;
	{"Base ST Tran"		, "BASESU_DTC"				, 	  "N", TamSX3('DTC_BASESU')[1]  ,2,PesqPict('DTC','DTC_BASESU')				,"","",.T.,"infNF" ,"vBCST"  	,	   												, "09", "G",	{}		},;
	{"Val. ST Tran"		, "VALIST_DTC"	  			, 	  "N", TamSX3('DTC_VALICM')[1]  ,2,PesqPict('DTC','DTC_VALICM')				,"","",.T.,"infNF" ,"vICMS"  	,	   												, "10", "G",	{}		}}

Return (aCampos)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModNF
Criação do objeto Struct dos Dados da Nota Fiscal
Uso restrito

@sample
StrModCTE()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModNF(nOp)

Local aCampos 	:= {}
Local nCont 	:= 1      
Local cTipoNF	:= ""
Local oStruct   

oNfe	:= Nil //Limpa o Objeto oNfe
cTipoNF	:= retconttag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC") // Recarrega o objeto oNfe
aCampos := tipoNF()

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(		;
	"XXXX"					,;		// [01] Alias da tabela
	{ "NUMNFC_DTC" }      ,;		// [02] Array com os campos que correspondem a primary key
	"NF Dados"				)		// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01              , ;                 // [01] Ordem do indice
	"NUMNFC_DTC"   , ;           		// [02] ID
	"NUMNFC_DTC"   , ;           		// [03] Chave do indice
	"NF dados"        	  , ;           // [04] Descrição do indice //"Calculo01"
	''                    , ;           // [05] Expressão de lookUp dos campos de indice
	''                    , ;           // [06] Nickname do indice
	.T.              )                  // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)
       
   		oStruct:AddField( ;
		aCampos[nCont][1]					, ;              // [01] Titulo do campo
		aCampos[nCont][1]					, ;              // [02] ToolTip do campo
		aCampos[nCont][2]					, ;              // [03] Id do Field
		aCampos[nCont][3]					, ;              // [04] Tipo do campo
		aCampos[nCont][4]					, ;              // [05] Tamanho do campo
		aCampos[nCont][5]					, ;              // [06] Decimal do campo
		aCampos[nCont][12]				, ;              // [07] Code-block de validação do campo
											, ;              // [08] Code-block de validação When do campo
		aCampos[nCont][15]				, ;              // [09] Lista de valores permitido do campo
		.F.									, ;              // [10] Indica se o campo tem preenchimento obrigatório
											, ;              // [11] Code-block de inicializacao do campo
		.F.									, ;              // [12] Indica se trata-se de um campo chave 
		.F.									, ;              // [13] Indica se o campo pode receber valor em uma operação de update. 
		.F.									, ;              // [14] Indica se o campo é virtual
		, )
		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)
  
		oStruct:AddField( 			   ;
		aCampos[nCont][2]			, ;					// [01] Campo
		aCampos[nCont][13]		, ;					// [02] Ordem
		aCampos[nCont][1]			, ;					// [03] Titulo
		aCampos[nCont][1]			, ;					// [04] Descricao
		NIL							, ;					// [05] Help
		aCampos[nCont][14]		, ;					// [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]			, ;					// [07] Picture
   		NIL							, ;					// [08] PictVar
		NIL							, ;					// [09] F3
		aCampos[nCont][9]			, ;					// [10] Editavel
		NIL							, ;					// [11] Folder
		NIL							, ;					// [12] Group
		aCampos[nCont][15]		, ;					// [13] Lista Combo
		0							, ;					// [14] Tam Max Combo
		""							, ;					// [15] Inic. Browse
		NIL                		    	)               // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CamposVal
Criação do array para o objeto Struct dos Dados da Nota Fiscal
Uso restrito

@sample
CamposVal()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CamposVal()
Local aCampos := {}

	aCampos:= { ;
	{"N. CTE"			, "DOC_DT6"					,     "C", 9   							,0,"@!", .F.,{ || .T. },,,,"G"	,,,,								},;
	{"Serie"			, "SERIE_DT6"	   		   	,     "C", 3   					    	,0,"@!", .F.,{ || .T. },,,,"G"	,,,,								},;
	{"Emissão" 			, "DTEMI_DT6"				,     "D", TamSX3('DT6_DATEMI')[1]		,0,PesqPict('DT6','DT6_DATEMI')	, .F.,{ || .T. },,,,"G",,,,	},;
	{"Cd.Mun Ini"		, "MUNINI_DT6"				,     "C", 7   							,0,"@!"							, .T.,{ ||NaoVazio() .And. TMAE90Trig("MUNINI_DT6")},,"ide","cMunIni","N","07","CC2CCE",,								},;
	{"UF Mun Ini"		, "UFINI_DT6"	   		   	,     "C", 2   					    	,0,"@!", .F.,{ || .T. },,,,"G"	,,,,								},;
	{"Mun. Inicio"		, "XMUNINI_DT6"				,     "C", 60   						,0,"@!"							, .T.,,,"ide","xMunIni","C","60",,,								},;
	{"Cd.Mun Fim"		, "MUNFIM_DT6"				,     "C", 7   							,0,"@!"							, .T.,{ ||NaoVazio() .And. TMAE90Trig("MUNFIM_DT6") },,"ide","cMunFim","G",,"CC2CCE",,								},;
	{"UF Mun Fim"		, "UFFIM_DT6"	   		   	,     "C", 2   					    	,0,"@!", .F.,{ || .T. },,,,"G"	,,,,								},;
	{"Mun. Fim"			, "XMUNFIM_DT6"				,     "C", 60   						,0,"@!"							, .F.,,,"ide","xMunFim","C","60",,,								},;	
	{"Vl. Pres. Serv."	, "VALTOT_DT6"	   	    	,     "N", TamSX3('DT6_VALTOT')[1]		,2,PesqPict('DT6','DT6_VALTOT')	, .F.,{ || .T. },,,,"G",,,,	},;
	{"Chave CTE"		, "CHVCTE_DT6"	   	    	,     "C", TamSX3('DT6_CHVCTE')[1] 		,0,PesqPict('DT6','DT6_CHVCTE')	, .F.,{ || .T. },,,,"G",,,,	},;
	{"Tipo Serviço"   	, "TPSERV_DT6"	   	    	,     "C", 1 							,0,"@!"							, .T.,,,"ide","tpServ"	,"C", "01" ,,{"0=Normal","1=Subcontratação","2=Redespacho","3=Redespacho Intermediário","4=Serviço Vinculado a Multimodal"}		},;
	{"CFOP"				, "CFOP_SD2"		    	,     "C", TamSX3('D2_CF')[1] 			,0,PesqPict('SD2','D2_CF')		, .T.,{ ||NaoVazio()},,"ide","CFOP" 	,"G",,,,},;
	{"MSG Fiscal"		, "MSG_FISCAL"	  		   	,     "M", 100							,0,"@!"							, .T.,{ ||NaoVazio()},,"imp","infAdFisco" 	,"M",,,,}}
	
Return (aCampos)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModVal
Criação do objeto Struct dos com os valores do CTE
Uso restrito

@sample
StrModVal()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModVal(nOp)
Local aCampos := CamposVal()
Local nCont := 1
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(                      ;
	"KKKK"                                 , ;     // [01] Alias da tabela
	{ "XTC_NUMNFC" }               		, ;   	// [02] Array com os campos que correspondem a primary key
	"NF Dados"                            )       // [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01              , ;                 // [01] Ordem do indice
	"XTC_NUMNFC"   , ;           		// [02] ID
	"XTC_NUMNFC"   , ;           		// [03] Chave do indice
	"NF dados"        	  , ;           // [04] Descrição do indice //"Calculo01"
	''                    , ;           // [05] Expressão de lookUp dos campos de indice
	''                    , ;           // [06] Nickname do indice
	.T.              )                  // [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

   		oStruct:AddField( ;
		aCampos[nCont][1]                  , ;              	// [01] Titulo do campo
		aCampos[nCont][1]                  , ;              	// [02] ToolTip do campo
		aCampos[nCont][2]                  , ;              	// [03] Id do Field
		aCampos[nCont][3]						, ;              	// [04] Tipo do campo
		aCampos[nCont][4]                  , ;              	// [05] Tamanho do campo
		aCampos[nCont][5]						, ;              	// [06] Decimal do campo
		aCampos[nCont][8]						, ;					// [07] Valid do campo
		, {}, .F., , .F., .F., aCampos[nCont][7] , , )
		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][2]			, ;                // [01] Campo
		Alltrim(STR(nCont))		, ;                // [02] Ordem
		aCampos[nCont][1]			, ;                // [03] Titulo
		aCampos[nCont][1]			, ;                // [04] Descricao
		NIL							, ;                // [05] Help
		aCampos[nCont][12] 		, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]			, ;                // [07] Picture
		NIL							, ;                // [08] PictVar
		aCampos[nCont][14]			, ;                // [09] F3
		aCampos[nCont][7]			, ;                // [10] Editavel
		NIL							, ;                // [11] Folder
		NIL							, ;                // [12] Group
		aCampos[nCont][15]		, ;                // [13] Lista Combo
		NIL							, ;                // [14] Tam Max Combo
		""							, ;                // [15] Inic. Browse
		NIL								)               // [16] Virtual



		nCont++
	End

EndIf

Return oStruct

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} retContCTE
Retorna o conteudo dos campos
Uso restrito

@sample
retContCTE()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function retContCTE(oModel, lLoad) 

Local nX
Local aCarga 			:= {}
Local aTmp 			:= {}
Local raCampos 		:= CamposCTE()
Local nV_Carga			:= 0
Local nV_Tot_Carga	:= 0

Local dEmi_Doc_Ant := ""
// Todo campo incluido na função CamposCTE(), deve ser obrigatoriamente incluido na função retContCTE.

For nX := 1 to Len(raCampos)                               	
	Do Case
		Case raCampos[nX][2] == "EMIT_XNOME"   
		  	aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_XNOME")) 
		  	aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_NOME_FANT"   
		  	aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_XFANT")) 
		  	aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_CNPJ"
			aAdd(aTmp, RetConCNPJ("EMIT"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_IE"   
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_IE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_XLGR"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XLGR"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_NRO" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_NRO"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  					
		Case raCampos[nX][2] == "EMIT_XCPL" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XCPL"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  					
		Case raCampos[nX][2] == "EMIT_XBAIRRO"	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XBAIRRO"))				
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "EMIT_CEP"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CEP"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 					
		Case raCampos[nX][2] == "EMIT_XMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EMIT_CMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EMIT_UF"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    				
		Case raCampos[nX][2] == "EMIT_FONE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_FONE")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   									
		Case raCampos[nX][2] == "REM_XNOME"   
		  	aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_XNOME")) 
		  	aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_NOME_FANT"   
		  	aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_XFANT")) 
		  	aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_CNPJ"
			aAdd(aTmp, RetConCNPJ("REM"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_IE"   
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_IE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_XLGR"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XLGR"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_NRO" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_NRO"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  					
		Case raCampos[nX][2] == "REM_XCPL" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XCPL"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  					
		Case raCampos[nX][2] == "REM_XBAIRRO"	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XBAIRRO"))				
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "REM_CEP"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_CEP"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 					
		Case raCampos[nX][2] == "REM_XMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "REM_CMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_CMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "REM_UF"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_UF"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    				
		Case raCampos[nX][2] == "REM_XPAIS"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XPAIS")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))					
		Case raCampos[nX][2] == "REM_FONE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_FONE")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   									
		Case raCampos[nX][2] == "DEST_XNOME" 						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_XNOME")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))							
		Case raCampos[nX][2] == "DEST_CNPJ" 						
			aAdd(aTmp, RetConCNPJ("DEST"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			   			
		Case raCampos[nX][2] == "DEST_IE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_IE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  	 		 	   			
		Case raCampos[nX][2] == "DEST_XLGR"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XLGR"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  			
		Case raCampos[nX][2] == "DEST_NRO" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_NRO")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      			
		Case raCampos[nX][2] == "DEST_XCPL" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XCPL")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      			
		Case raCampos[nX][2] == "DEST_XBAIRRO"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XBAIRRO"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "DEST_CEP"	 			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      			
		Case raCampos[nX][2] == "DEST_CMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_CMUN"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      			
		Case raCampos[nX][2] == "DEST_XMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      			
		Case raCampos[nX][2] == "DEST_UF"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    	   			
		Case raCampos[nX][2] == "DEST_XPAIS"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XPAIS")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "DEST_FONE"						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_FONE"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  						
		Case raCampos[nX][2] == "CON_XNOME" 						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME"))	 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))		
		Case raCampos[nX][2] == "CON_CNPJ" 						
			aAdd(aTmp, RetConCNPJ("CON"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			
		Case raCampos[nX][2] == "CON_IE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_IE"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			
		Case raCampos[nX][2] == "CON_XLGR"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XLGR"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))		
		Case raCampos[nX][2] == "CON_NRO" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_NRO"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    		
		Case raCampos[nX][2] == "CON_XCPL" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XCPL"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    		
		Case raCampos[nX][2] == "CON_XBAIRRO"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XBAIRRO"))	
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))		
		Case raCampos[nX][2] == "CON_CEP"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CEP"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    		
		Case raCampos[nX][2] == "CON_XMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XMUN"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 		
		Case raCampos[nX][2] == "CON_CMUN"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CMUN"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 		
		Case raCampos[nX][2] == "CON_UF"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "CON_FONE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_FONE"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			
		Case raCampos[nX][2] == "EXPED_XNOME" 						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_XNOME")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))						
		Case raCampos[nX][2] == "EXPED_CNPJ" 						
			aAdd(aTmp, RetConCNPJ("EXPED")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	 		   				
		Case raCampos[nX][2] == "EXPED_IE"							
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_IE"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	 		 				
		Case raCampos[nX][2] == "EXPED_XLGR"	   		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XLGR"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  			
		Case raCampos[nX][2] == "EXPED_NRO" 			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_NRO")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EXPED_XCPL" 			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XCPL")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EXPED_XBAIRRO"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XBAIRRO"))	
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))		
		Case raCampos[nX][2] == "EXPED_CEP"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CEP")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  			
		Case raCampos[nX][2] == "EXPED_XMUN"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EXPED_CMUN"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "EXPED_UF"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  				
		Case raCampos[nX][2] == "EXPED_XPAIS"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XPAIS")) 	 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			
		Case raCampos[nX][2] == "EXPED_FONE"						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_EXPED:_FONE"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  								
		Case raCampos[nX][2] == "LOCCOLETA_XNOME" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XNOME"))	  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			
		Case raCampos[nX][2] == "LOCCOLETA_CNPJ" 				
			aAdd(aTmp, RetConCNPJ("LOCCOLETA"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	 			 
		Case raCampos[nX][2] == "LOCCOLETA_IE"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_IE")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 	 		 	
		Case raCampos[nX][2] == "LOCCOLETA_XLGR"		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_XLGR")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   
		Case raCampos[nX][2] == "LOCCOLETA_NRO" 		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_NRO"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    		
		Case raCampos[nX][2] == "LOCCOLETA_COMPL" 	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_NRO"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 		
		Case raCampos[nX][2] == "LOCCOLETA_XBAIRRO"	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_XBAIRRO"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	
		Case raCampos[nX][2] == "LOCCOLETA_XMUN"		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_XMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   	
		Case raCampos[nX][2] == "LOCCOLETA_CMUN"		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_CMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   	
		Case raCampos[nX][2] == "LOCCOLETA_UF"		
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_UF")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   	
		Case raCampos[nX][2] == "LOCCOLETA_XPAIS"	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_ENDERDEST:_XPAIS"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  
		Case raCampos[nX][2] == "LOCCOLETA_FONE"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_FONE"))    
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))			 			
		Case raCampos[nX][2] == "LOCENT_XNOME" 				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XNOME"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))				
		Case raCampos[nX][2] == "LOCENT_CNPJ" 				
			aAdd(aTmp, RetConCNPJ("LOCENT"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	 			
		Case raCampos[nX][2] == "LOCENT_IE"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_IE")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 	 		 	
		Case raCampos[nX][2] == "LOCENT_XLGR"				    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XLGR"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 			
		Case raCampos[nX][2] == "LOCENT_NRO" 				    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_NRO"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      				
		Case raCampos[nX][2] == "LOCENT_XCPL" 				    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XCPL"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))      				
		Case raCampos[nX][2] == "LOCENT_XBAIRRO"				
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XBAIRRO")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 			
		Case raCampos[nX][2] == "LOCENT_XMUN"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XMUN"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "LOCENT_CMUN"					
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CMUN"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))   			
		Case raCampos[nX][2] == "LOCENT_UF"	   		    	
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_UF"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "RECEB_XNOME" 						
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_XNOME")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))					
		Case raCampos[nX][2] == "RECEB_CNPJ" 						
			aAdd(aTmp, RetConCNPJ("RECEB"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	 					
		Case raCampos[nX][2] == "RECEB_IE"				   			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_IE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))  	 		   			
		Case raCampos[nX][2] == "RECEB_XLGR"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR"))   
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX])) 		
		Case raCampos[nX][2] == "RECEB_NRO" 			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     	
		Case raCampos[nX][2] == "RECEB_XCPL" 			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XCPL")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     	
		Case raCampos[nX][2] == "RECEB_XBAIRRO"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO"))	 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))	
		Case raCampos[nX][2] == "RECEB_XMUN"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    	
		Case raCampos[nX][2] == "RECEB_CMUN"			
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_CMUN")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))    	
		Case raCampos[nX][2] == "RECEB_UF"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "RESP_SEG"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_SEG:_RESPSEG"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "NOME_SEG"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_SEG:_XSEG"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "NUM_APOL"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAPOL"))  
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "V_CARGA"	   		    
			nV_Carga := retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_SEG:_VCARGA")
			aAdd(aTmp, val(nV_Carga))
		Case raCampos[nX][2] == "VAL_TOT_CARGA"	   		    
			nV_Tot_Carga := retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA")
			aAdd(aTmp, val(nV_Tot_Carga))
		Case raCampos[nX][2] == "PROD_PRED"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_PROPRED"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "CARC_CARGA"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_XOUTCAT"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "CNPJ_ANT"	   		    
			aAdd(aTmp, RetConCNPJ("ANT")) 
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "IE_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "UF_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_UF"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "NOME_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_XNOME"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "TP_DOC_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT:_IDDOCANTPAP:_TPDOC"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "DOC_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT:_IDDOCANTPAP:_NDOC"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "SER_DOC_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT:_IDDOCANTPAP:_SERIE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))     				
		Case raCampos[nX][2] == "EMI_DOC_ANT"	   		    
			dEmi_Doc_Ant := retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT:_IDDOCANTPAP:_DEMI")
			dEmi_Doc_Ant := stod(SubStr(dEmi_Doc_Ant, 1,4) + SubStr(dEmi_Doc_Ant, 6,2) + SubStr(dEmi_Doc_Ant, 9,2))
			aAdd(aTmp, dEmi_Doc_Ant)
		Case raCampos[nX][2] == "CHV_DOC_ANT"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM::_DOCANT:_EMIDOCANTELE:_CHAVE"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
		Case raCampos[nX][2] == "COMPL_CTE_OBS"	   		    
			aAdd(aTmp, retContTag("oNfe:_CTE:_INFCTE:_COMPL:_xObs"))
			aTmp[nX] += space(raCampos[nX][4] - len(aTmp[nX]))
	End Case
Next nx         

aCarga := {aTmp,0}

Return aCarga
//------------------------------------------------------------------------------------------------
/*
{Protheus.doc} loadGridNF
Retorna o conteudo do grid para as NF transportadas
Uso restrito

@sample
loadGridNF()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
*/                             
//------------------------------------------------------------------------------------------------
Static Function loadGridNF(oGridModel, lCopy)

	Local aLoad 			:= {}
	Local nCont			:= 1     
	//TAG INFNF
	Local cNumDoc			:=	""
	Local cSerie			:=	""
	Local dtHorEmi 		:= 	""
	Local nValProd 		:= 	0
	Local nValNF 			:= 	""
	Local nCodFiscal		:=  ""
	Local nBaseIcms		:=	0
	Local nVlrIcms    		:=	0
	Local nBasSTTran  	:=	0
	Local nValSTTran  	:=	0
	// TAG INFNFE
	Local cChaveNFe   	:=	""
	//Tag INFOUTROS
	Local cTipoOrig		:= ""
	Local cNumOutros		:= ""
	Local cDtEmiOutros	:= ""

    //TAG INFNF
	If  (Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF") <> 'U')
		If (ValType(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF)  =='A')
           For nCont := 1 to len(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF)
				// Carrega Variaveis
		    	cNumDoc			:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_NDOC")
		   		cSerie			:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_SERIE")
				dtHorEmi 		:= 	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_DEMI")
			   	dtHorEmi 		:= 	stod(SubStr(dtHorEmi, 1,4) + SubStr(dtHorEmi, 6,2) + SubStr(dtHorEmi, 9,2))
			    nValProd 		:= 	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_VPROD"))
			    nValNF	 		:= 	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_VPROD")) 
				nCodFiscal		:=  retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_nCFOP")
                nBaseIcms   	:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_vBC"))
                nVlrIcms    	:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_vICMS"))
                nBasSTTran  	:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_vBCST"))
                nValSTTran  	:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF["+CVALTOCHAR(nCont)+"]:_vICMS"))
                
			   	// Adiciona dados no grid.
			    aAdd(aLoad,{0, 			;
			    	{Padr(cNumDoc,20), 	;
			   		Padr(cSerie,3), 		;
			   		dtHorEmi, 				;
			   		nValProd, 				;
					nValNF,				;
					val(nCodFiscal),			;
        	        nBaseIcms,  			;
            	    nVlrIcms,   			;
                	nBasSTTran, 			;
	                nValSTTran, 			;
    		   		}})
		   Next                                                                                   
		Else
			// Carrega Variaveis
	    	cNumDoc		:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC")
	   		cSerie			:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE")
			dtHorEmi		:= 	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_DEMI")
		   	dtHorEmi		:= 	stod(SubStr(dtHorEmi, 1,4) + SubStr(dtHorEmi, 6,2) + SubStr(dtHorEmi, 9,2))
		    nValProd		:= 	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_VPROD"))
		    nValNF			:= 	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_VPROD")) 
			nCodFiscal		:=  retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_nCFOP")
   			nBaseIcms		:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_vBC"))
            nVlrIcms		:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_vICMS"))
            nBasSTTran		:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_vBCST"))
            nValSTTran		:=	val(retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_vICMS"))
                
		   	// Adiciona dados no grid.
		    aAdd(aLoad,{0, 			;
		    	{Padr(cNumDoc,20), 	;
		   		Padr(cSerie,3),		;
		   		dtHorEmi,				;
		   		nValProd,				;
				nValNF,				;
				val(nCodFiscal),			;
        	    nBaseIcms,				;
            	nVlrIcms,				;
                nBasSTTran,			;
                nValSTTran,			;
    	     	}})

		EndIf
	EndIf		
    //Tag INFNFE
	If  (Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") <> 'U')
		If (ValType(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)  =='A')
           For nCont := 1 to len(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)
				// Carrega Variaveis                  
                cChaveNFe   :=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE["+CVALTOCHAR(nCont)+"]:_chave")
			   	// Adiciona dados no grid.
			    aAdd(aLoad,{0, 	;
    	            {cChaveNFe}})
		   Next                                                                                   
		Else
			// Carrega Variaveis
            cChaveNFe   :=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_chave")
		   	// Adiciona dados no grid.
			    aAdd(aLoad,{0,{	;
    	            cChaveNFe}})
		EndIf
	EndIf		
    //Tag INFOUTROS
	If  (Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS") <> 'U')
		If (ValType(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS)  =='A')
           For nCont := 1 to len(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS)
				// Carrega Variaveis                  
                cTipoOrig		:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+CVALTOCHAR(nCont)+"]:_TPDOC")
                cNumOutros		:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+CVALTOCHAR(nCont)+"]:_NDOC")
				cDtEmiOutros	:= 	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS["+CVALTOCHAR(nCont)+"]:_DEMI")
			   	cDtEmiOutros	:= 	stod(SubStr(cDtEmiOutros, 1,4) + SubStr(cDtEmiOutros, 6,2) + SubStr(cDtEmiOutros, 9,2))

			   	// Adiciona dados no grid.
			    aAdd(aLoad,{0, 	;
    	            {cTipoOrig, Padr(cNumOutros,20) , cDtEmiOutros}})
		   Next                                                                                   
	Else
			// Carrega Variaveis
   			cTipoOrig   	:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_TPDOC")
      		cNumOutros   	:=	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC")
			cDtEmiOutros	:= 	retContTag("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_DEMI")
		   	cDtEmiOutros	:= 	stod(SubStr(cDtEmiOutros, 1,4) + SubStr(cDtEmiOutros, 6,2) + SubStr(cDtEmiOutros, 9,2))
		   	// Adiciona dados no grid.
			    aAdd(aLoad,{0, 	;
    	            {cTipoOrig, Padr(cNumOutros,20) , cDtEmiOutros}})
		EndIf
	EndIf		

	// Para CTE de Complemento
	If  Type( "oNFE:_CTE:_INFCTE:_INFCTECOMP") <> 'U'	
	   	// Adiciona dados no grid.
		    aAdd(aLoad,{0,{	;
    	            "CTE DE COMPLEMENTO"}})
	EndIf		
	
	// Para CTE de MultiModal
	If Type( "oNFE:_CTE:_INFCTE:_IDE:_TPSERV") <> 'U' .And. oNFE:_CTE:_INFCTE:_IDE:_TPSERV:TEXT == '4'	
	   // Adiciona dados no grid.
		aAdd(aLoad,{0,{	;
    	            retContTag("oNFE:_CTE:_INFCTE:_IDE:_refCTE")}})
	EndIf		

Return (aLoad)

/*/{Protheus.doc} loadGridCTE
Retorna o conteudo do grid para os valores do CTE
Uso restrito

@sample
loadGridCTE()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridCTE(oGridModel, lCopy)
	
	Local aLoad 	:= {}
    Local nCTE		:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_NCT")
    Local cSerie    := retContTag("oNFE:_CTE:_INFCTE:_IDE:_SERIE")
    Local dtHorEmi	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_DHEMI") 
    Local nVlPrest	:= val(retContTag("oNFE:_CTE:_INFCTE:_VPREST:_VTPREST"))     
    Local cChaveCte	:= substr(retContTag("oNFE:_CTE:_INFCTE:_ID"), 4, 47) 
    Local cCFOP		:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_CFOP")
    Local cTpServ	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_TPSERV")
    Local cMSGFis	:= retContTag("oNFE:_CTE:_INFCTE:_IMP:_INFADFISCO")
    Local cMunIni   := retContTag("oNFE:_CTE:_INFCTE:_IDE:_CMUNINI")
    Local cMunFim   := retContTag("oNFE:_CTE:_INFCTE:_IDE:_CMUNFIM")
	Local cUFIni	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_UFINI")
	Local cXMunIni	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_XMUNINI")
	Local cXMunFim	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_XMUNFIM")
	Local cUFFim	:= retContTag("oNFE:_CTE:_INFCTE:_IDE:_UFFIM")

	nCTE 		:= strZero(val(nCTE), 9,0)
	dtHorEmi 	:= SubStr(dtHorEmi, 9,2) + "/" + SubStr(dtHorEmi, 6,2) + "/" + SubStr(dtHorEmi, 1,4) + " - " + SubStr(dtHorEmi, 12,5)    

   	aAdd(aLoad,{0,{nCTE, cSerie, dtHorEmi, cMunIni, cUFIni, cXMunIni, cMunFim, cUFFim, cXMunFim, nVlPrest, cChaveCte,cTpServ,cCFOP,cMSGFis}})

Return (aLoad)

/*
{Protheus.doc} XMLCCe
Função para a Geração do XML, para envio ao TSS
Uso restrito

@sample
XMLCCe()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
*/
///------------------------------------------------------------------------------------------------
Static Function XMLCCe(aDiff)

Local cXml			:= ""
Local aCTe			:= {} 
Local nCont			:= 0    
Local nX			:= 1
Local aAltGrid	 	:= {}
Local aAltFields	:= {}
Local lRet			:= .F.    
Local lRetFields	:= .F.
Local lRetGrid		:= .F.
Local cCnpj			:= SM0->M0_CGC
Local cUF			:= Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cData			:= Dtos(Date())
Local cHora			:= Time()
Local aUf			:= {}
Local nPosUf		:= 0
Local cDhEvento		:= ""
Local cChvNfe		:= DT6->DT6_CHVCTE
Local cIdEvento		:= ""
Local cCodOrgao		:= ""
Local cSeqEven		:= "01"
Local cAmbiente		:= "2"
Local cVerLayout	:= "1.00"
Local cVerLayEven	:= "1.00"
Local cVerEven		:= "1.00"
Local cVerCCe		:= "1.00"
Local cHrVerao		:= "2"
Local cHorario		:= "2"

Local lHVerao		:=.F.							// Horario de Verão    .F. sem horario de verão/ .T. com horario de verão
Local lErpHverao	:= GetNewPar("MV_HVERAO",.F.)	// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não /

	// Dados do CTe
	dbSelectArea("SF2")
	dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	MsSeek(DT6->(DT6_FILORI+DT6_DOC+DT6_SERIE))
	aCTe := {	SF2->F2_CHVNFE,;	//01-Chave da Nfe
				SF2->(RECNO()),;	//02-Recno 
				SF2->F2_SERIE ,;	//03-Serie
				SF2->F2_DOC    }	//04-Cte

	If lUsaColab
		cAmbiente   := ColGetPar("MV_AMBICTE","")
		cVerLayout  := ColGetPar("MV_VLAYCTE","2.00")
		cVerLayEven := ColGetPar("MV_EVENCTE","2.00")
		cVerEven    := ColGetPar("MV_LAYOCTE","2.00")
		cVerCCe     := ColGetPar("MV_VERSCTE","2.00")
		cHrVerao    := ColGetPar("MV_HRVERAO","2")
		cHorario    := ColGetPar("MV_HORARIO","2")
		cSeqEven := ColSeqCCe(aCte)
		If cSeqEven == "00"
			cSeqEven := "01"
		EndIf
		// Montagem do ID do evento
		cIdEvento := "ID"+"110110"+cChvNfe+cSeqEven
		// TAG raiz
		cXml += '<eventoCTe versao="'+cVerLayEven+'" xmlns="http://www.portalfiscal.inf.br/cte">'
		cXml += '<infEvento Id="'+cIdEvento+'">'
		// Data e Hora do Evento - Formato: 2011-07-27T14:17:00-03:00 (UTC)
		If FindFunction("FwTimeUF")
			If cHrVerao == "1"			//1-Sim ### 2-Nao
				lHVerao   :=.T.
			else
				lHVerao   :=.F.
			EndIf
			If cHorario == "1"		//Fernando de Noronha
				cUF  := "FERNANDO DE NORONHA"
			EndIf
			If !lErpHverao
				lErpHverao := lHVerao
			Endif
			aData := FwTimeUF(cUF,,lErpHVerao)
			cdata := aData[1]
			cData := Dtos(Date())
			cData := Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)
			cHora := aData[2]
		Else
			cData := Substr(cData,1,4)+"-"+Substr(cData,5,2)+"-"+Substr(cData,7,2)
			cHora := Time()
		EndIf
		If cVerLayEven = "3.00"
			cDHEvento := colDtHrUTC()
		Else
			cDHEvento := cData
			cDHEvento += "T"
			cDHEvento += cHora
		EndIf
		// Tabela do IBGE
		aUf := SpedTabIBGE()
		// Codigo do Orgao
		nPosUf := aScan(aUf,{|x| Upper(x[1]) == cUF})
		If nPosUf > 0
			cCodOrgao := aUf[nPosUf][4]
		EndIf
		// Codigo do Orgao - Tabela IBGE
		cXml += "<cOrgao>" + cCodOrgao + "</cOrgao>"
		// Ambiente: 1-Producao ### 2-Homologacao
		cXml += "<tpAmb>" + cAmbiente + "</tpAmb>"
		// CNPJ do autor do Evento
		cXml += "<CNPJ>" + cCnpj + "</CNPJ>"
		// Chave de Acesso do CT-e vinculado ao Evento
		cXml +=	"<chCTe>" + cChvNfe + "</chCTe>"
		// Data e Hora do evento no formato AAAA-MM-DDThh:mm:ss
		cXml += "<dhEvento>" + cDHEvento + "</dhEvento>"
		// Tipo do Evento
		cXml += "<tpEvento>110110</tpEvento>"
		// Sequencia do evento
		cXml += "<nSeqEvento>" + cValToChar(Val(cSeqEven)) + "</nSeqEvento>"
		// Informacoes do evento especifico + versao leiaute especifico do evento
		cXml += '<detEvento versaoEvento="'+cVerCCe+'">'
		cXml += "<evCCeCTe>"
		cXml += "<descEvento>"+"Carta de Correcao"+"</descEvento>"
	Else
		cXml :=	"<envEvento>"
		cXml +=	"<eventos>"
		cXml +=	"<detEvento>"
		cXml +=	"<tpEvento>110110</tpEvento>"
		cXml +=	"<chNFe>" + cChvNfe + "</chNFe>"
	EndIf

	For nCont := 1 to Len(aDiff)
		If aDiff[nCont][2] == 'F'	// Campos da Fields
			aAltFields := AltFields(aDiff, nCont)
			If Len(aAltFields) >=1
				lRetFields := .T.
				For	nX := 1 to Len(aAltFields)
					cXml +=	Iif(lUsaColab,"<infCorrecao>"  ,"<correcao>")
					cXml +=	Iif(lUsaColab,"<grupoAlterado>","<grupo>") + aAltFields[nX][1][1] + Iif(lUsaColab,"</grupoAlterado>","</grupo>")
					cXml +=	Iif(lUsaColab,"<campoAlterado>","<campo>") + aAltFields[nX][1][2] + Iif(lUsaColab,"</campoAlterado>","</campo>")
					cXml +=	Iif(lUsaColab,"<valorAlterado>","<valor>") + NoAcentoCte(ConvType(aAltFields[nX][1][3])) + Iif(lUsaColab,"</valorAlterado>","</valor>")
					cXml +=	Iif(lUsaColab,"</infCorrecao>" ,"</correcao>")
				Next
			Else
				lRetFields := .F.
			EndIf
		Else  //aDiff[nCont][2] == 'G'	// Campos da Grid
			aAltGrid := AltGrid(aDiff, nCont)
			If 	Len(aAltGrid) >= 1
				lRetGrid := .T.
				For	nX := 1 to Len(aAltGrid)
					cXml +=	Iif(lUsaColab,"<infCorrecao>"    ,"<correcao>")
					cXml +=	Iif(lUsaColab,"<grupoAlterado>"  ,"<grupo>") + aAltGrid[nX][1][1] + Iif(lUsaColab,"</grupoAlterado>","</grupo>")
					cXml += Iif(lUsaColab,"<campoAlterado>"  ,"<campo>") + aAltGrid[nX][1][2] + Iif(lUsaColab,"</campoAlterado>","</campo>")
					cXml +=	Iif(lUsaColab,"<valorAlterado>"  ,"<valor>") + NoAcentoCte(ConvType(aAltGrid[nX][1][3])) + Iif(lUsaColab,"</valorAlterado>","</valor>")
					cXml +=	Iif(lUsaColab,"<nroItemAlterado>","<item>") + SubStr('0' + CVALTOCHAR(aAltGrid[nX][1][4]),1,2) + Iif(lUsaColab,"</nroItemAlterado>","</item>")
					cXml +=	Iif(lUsaColab,"</infCorrecao>"   ,"</correcao>")
				Next
			Else
				lRetGrid := .F.
			EndIf
		EndIF
	Next nCont

	If lUsaColab
		// Condicoes de uso da carta de correcao - texto fixo
		cXml += "<xCondUso>"
		cXml += "A Carta de Correcao e disciplinada pelo Art. 58-B do CONVENIO/SINIEF 06/89: Fica permitida a utilizacao de carta de correcao, para regularizacao de erro ocorrido na emissao de documentos fiscais relativos a prestacao de servico de transporte, desde que o erro nao esteja relacionado com: I - as variaveis que determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da prestacao;II - a correcao de dados cadastrais que implique mudanca do emitente, tomador, remetente ou do destinatario;III - a data de emissao ou de saida."
		cXml += "</xCondUso>"
		cXml += '</evCCeCTe>'
		cXml +=	"</detEvento>"
		cXml += "</infEvento>"
		cXml += "</eventoCTe>"
	Else
		cXml +=	"</detEvento>"
		cXml +=	"</eventos>"
		cXml +=	"</envEvento>"
	EndIf
	
	If lRetFields .or. lRetGrid
		If (SpedCCeCTe(cXml, aCTe))
			SpedCCeMnt("SF2",SF2->(RECNO()),3,.T.)
			lRet := .T.
		EndIf
	EndIf

Return (lRet)

/*{Protheus.doc} ZeraVarSt

Função para zera as variaveis statics

@author Fabio Marchiori Sampaio	
@since 03/12/13
@version 1.0
*/
Static Function ZeraVarSt()

__oCopy 	:= Nil
oNfe 		:= Nil
oStrucNF 	:= Nil

Return()

/*{Protheus.doc} PreValid

Função que verifica se e um lote eletronico e o CTE já foi transmitido.

@author Fabio Marchiori Sampaio	
@since 17/01/14
@version 1.0
*/
Static Function PreValid(oModel)
Local lRet 			:= .T.
Local cVersaoCTE	:= ""

oNfe		:= Nil //Limpa o Objeto oNfe
cVersaoCTE	:= retconttag("oNFE:_CTE:_INFCTE:_VERSAO") // Recarrega a versao do CTE

If cVersaoCTE == '1.04'
	Help( ,, 'HELP',, "Documento foi gerado na versão 1.04 não será possível gerar a carta de correção.", 1, 0)      
	lRet := .F.
EndIf

If DT6->DT6_IDRCTE <> '100'
	Help( ,, 'HELP',, "Documento não é um conhecimento eletrônico, ou não foi transmitido", 1, 0)      
	lRet := .F.
EndIf

If AllTrim(DT6->DT6_FILDOC) <> AllTrim(SM0->M0_CODFIL)
	Help( ,, 'HELP',, "CTE Não pertence a filial selecionada !! Favor selecionar a filial do CTE.", 1, 0)      
	lRet := .F.
EndIf

If Empty(cVersaoCTE) 
	Help( ,, 'HELP',, "XML Não foi encontrado na base de dados.", 1, 0)      
	lRet := .F.
EndIf

If DT6->DT6_STATUS $ ('B')
	Help( ,, 'HELP',, "Foi solicitado o cancelamento do CT-e, está aguadando retorno da SEFAZ", 1, 0)      
	lRet := .F.
EndIf

If DT6->DT6_STATUS $ ('C')
	Help( ,, 'HELP',, "Cancelamento do CT-e, está autorizado na SEFAZ, não será possível gerar a CC-e", 1, 0)      
	lRet := .F.
EndIf

If DT6->DT6_STATUS $ ('D')
	Help( ,, 'HELP',, "Cancelamento do CT-e, não está autorizado na SEFAZ, verifique com o fiscal o que ocorreu.", 1, 0)      
	lRet := .F.
EndIf

oNfe		:= Nil //Limpa o Objeto oNfe

Return (lRet)

/*{Protheus.doc} AltGrid

Função que irá retornar um array com as alterações da grid..

@author Fabio Marchiori Sampaio	
@since 17/01/14
@version 1.0
*/
Static Function AltGrid(aDiff, nPosDiff)

	Local aCampos		:= {}
	Local aCamposNF 	:= CamposNF()
	Local aCamposNFe 	:= CamposNFe() 
	Local aCamposVeic	:= CamposVeic()
	Local aCamposMot	:= CamposMot()
	Local aCamposInfQ := CamposInfQ()
	Local aCamposPeri	:= CamposPeri()
	Local aCamposLacr	:= CampLacre()
	Local aCamposVAL	:= CamposVal()

	Local nCont 		:= 1   
	Local nX			:= 1
	Local nY			:= 1
	Local aRet			:= {}
	
	aEval(aCamposNF,		{|x| AAdd(aCampos,x)})
	aEval(aCamposNFe,		{|x| AAdd(aCampos,x)})
	aEval(aCamposVeic,	{|x| AAdd(aCampos,x)})
	aEval(aCamposMot,		{|x| AAdd(aCampos,x)})
	aEval(aCamposInfQ,	{|x| AAdd(aCampos,x)})
	aEval(aCamposPeri,	{|x| AAdd(aCampos,x)})
	aEval(aCamposLacr,	{|x| AAdd(aCampos,x)})
	aEval(aCamposVAL,		{|x| AAdd(aCampos,x)})

	For nX := 1 to Len(aDiff[nPosDiff][3])
		For nY := 1 to Len(aDiff[nPosDiff][3][nX][3])     
			For nCont := 1 to Len(aCampos)
		   		If aDiff[nPosDiff][3][nX][3][ny][1] == aCampos[nCont][2] 
  					If !Empty(aDiff[nPosDiff][3][nX][3][nY][2])
  						aAdd(aRet, {{aCampos[nCont][10],aCampos[nCont][11],aDiff[nPosDiff][3][nX][3][nY][2], aDiff[nPosDiff][3][nX][1]}})
		   			EndIf
		   		EndIf 
   			Next nCont	
		Next nY
	Next nX				

Return(aRet)                  

/*{Protheus.doc} AltFields 

Função que irá retornar um array com as alterações dos campos..

@author Fabio Marchiori Sampaio	
@since 17/01/14
@version 1.0
*/
Static Function AltFields(aDiff, nPosDiff)

	Local aRet			:= {}               
	Local nCont			:= 1
	Local nX			:= 1
	Local aCamposCTE	:= CamposCTE()
		
	For nX := 1 to Len(aDiff[nPosDiff][3])
		For nCont := 1 to Len(aCamposCTE)
	   		If aDiff[nPosDiff][3][nX][1] == aCamposCTE[nCont][2] 
  				If !Empty(aDiff[nPosDiff][3][nX][2])
  					aAdd(aRet, {{aCamposCTE[nCont][10],aCamposCTE[nCont][11],aDiff[nPosDiff][3][nX][2]}})
  				EndIf
	   		EndIf 
		Next nCont	
	Next nX				

Return(aRet)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tipoNF
Função que verifica se a nota e eletronica ou manual
Uso restrito

@sample
tipoNF()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function tipoNF()

	Local aRet := {}
	                
	If Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") <> 'U'	
		aRet := CamposNFe()
	EndIf
	If Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF") <> 'U'	
		aRet := CamposNF()
	EndIf
	If Type( "oNFE:_CTE:_INFCTE:_INFCTECOMP") <> 'U'	
		aRet := CampCompl()
	EndIf	
	If Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS") <> 'U'	
		aRet := CampOutros()
	EndIf		
	If Type( "oNFE:_CTE:_INFCTE:_IDE:_TPSERV") <> 'U' .And. oNFE:_CTE:_INFCTE:_IDE:_TPSERV:TEXT == '4'	
		aRet := CampRefCte()
	EndIf
Return(aRet)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CamposNF
Criação do array para o objeto Struct dos Dados da Nota Fiscal Eletronica
Uso restrito

@sample
CamposNF()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CamposNFe()
Local aCampos := {}
       
	// As Funções CampCompl, CamposNFe, CamposNF e CampOutros devem sempre conter os mesmos tamanhos de array, e as mesmas posições.
	aCampos:= { ;
	{"Chave NF-e"			, "NFEID_DTC"				, 	  "C", TamSX3('DTC_NFEID')[1]   ,0,PesqPict('DTC','DTC_NFEID')				,"","",.F.,"infNFE","chave"  	,,"01", "G",	{}		}}	

Return (aCampos)


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CampRefCte
Criação do array para o objeto Struct dos Dados do CT-e Multimodal
Uso restrito

@sample
CampRefCte()

@author Felipe Marques Barbieri.
@since 03/03/17
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CampRefCte()
Local aCampos := {}
       
	// As Funções CampCompl, CamposNFe, CamposNF e CampOutros devem sempre conter os mesmos tamanhos de array, e as mesmas posições.
	aCampos:= { ;
	{"Chave Doc. Anterior"			, "NFEID_DTC"				, 	  "C", TamSX3('DTC_CTEANT')[1]   ,0,PesqPict('DTC','DTC_CTEANT')				,"","",.F.,"ide","refCTE"  	,,"01", "G",	{}		}}	

Return (aCampos)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CampCompl
Criação do array para o objeto Struct dos CTEs de Complemento
Uso restrito

@sample
CampCompl()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CampCompl()
Local aCampos := {}

	// As Funções CampCompl, CamposNFe, CamposNF e CampOutros devem sempre conter os mesmos tamanhos de array, e as mesmas posições.
	aCampos:= { ;
	{"CTE de Complemento"			, "COMPL_DTC"				, 	  "C", 20   ,0,"@!"				,"","",.F.,"",""  	,,"01", "G",	{}		}}	

Return (aCampos)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ConvType

Uso restrito

@sample
ConvType()

@author  Microsiga
@since 
@version 
/*///------------------------------------------------------------------------------------------------

Static Function ConvType(xValor)

Local   cNovo := ""

Do Case
	Case ValType(xValor)=="N"
		cNovo := AllTrim(Str(xValor))
	Case ValType(xValor)=="D"
		cNovo := SubStr(Dtos(xValor),1,4)+"-"+SubStr(Dtos(xValor),5,2)+"-"+SubStr(Dtos(xValor),7,2)  	
	Case ValType(xValor)=="C"
		cNovo := AllTrim(xValor)
EndCase

Return(cNovo)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetConCNPJ
Retorna o codigo do CNPJ ou CPF
Uso restrito

@sample
RetConCNPJ()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function RetConCNPJ(cVar)

Local cRet	:= ""

Do Case
	Case cVar == "REM"
		If (Type("oNfe:_CTE:_INFCTE:_REM:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_REM:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_CPF") 
		EndIf
	Case cVar == "DEST"	 
		If (Type("oNfe:_CTE:_INFCTE:_DEST:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_DEST:_CNPJ")	 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_DEST:_CPF") <> "U")   
			cRet := retContTag("oNfe:_CTE:_INFCTE:_DEST:_CPF")
		EndIf 	
	Case cVar == "CON"	 
		If (Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ")	 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CPF") <> "U")   
			cRet := retContTag("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CPF")
		EndIf 	
	Case cVar == "EMIT"
		If (Type("oNfe:_CTE:_INFCTE:_EMIT:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_EMIT:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_CPF") 
		EndIf
	Case cVar == "ANT"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_CPF") 
		EndIf
	Case cVar == "EXPED"
		If (Type("oNfe:_CTE:_INFCTE:_EXPED:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_EXPED:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_EXPED:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_EXPED:_CPF") 
		EndIf
	Case cVar == "LOCCOLETA"
		If (Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CPF") 
		EndIf
	Case cVar == "LOCENT"
		If (Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CPF") 
		EndIf
	Case cVar == "RECEB"
		If (Type("oNfe:_CTE:_INFCTE:_RECEB:_CNPJ")  <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_RECEB:_CNPJ") 
		EndIf
		If (Type("oNfe:_CTE:_INFCTE:_RECEB:_CPF") <> "U")
			cRet := retContTag("oNfe:_CTE:_INFCTE:_RECEB:_CPF") 
		EndIf

EndCase		
		If !Empty(cRet)
			If Len(AllTrim(cRet)) < 14
				cRet := Transform(cRet,"@R 999.999.999-99999" )
			Else
				cRet := Transform(cRet,"@R 99.999.999/9999-99")
			EndIf      
		EndIf			

Return(cRet)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidCampo
habilita ou desabilita o campo
Uso restrito

@sample
ValidCampo()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function ValidCampo(cVar, cTag)

Local lRet		:= .T.  
Default cVar	:= " "

If oNfe = Nil	
	RetContTag("oNFE:_CTE:_INFCTE") // Recarrega o objeto oNfe	
EndIf

Do Case
	Case cVar == "EMIT"
		If (Type("oNfe:_CTE:_INFCTE:_EMIT") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "REM"
		If (Type("oNfe:_CTE:_INFCTE:_REM") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "DEST"
		If (Type("oNfe:_CTE:_INFCTE:_DEST") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "CONSI"
		If (Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "EXPED"
		If (Type("oNfe:_CTE:_INFCTE:_EXPED:_XNOME") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "LOCCOLETA"
		If (Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "RECEB"
		If cTag = "xNome" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_XNOME") = 'U') 
			Return .F.					
		EndIf		
		If cTag = "xLgr" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR") = 'U')  
			Return .F.					
		EndIf			
		If cTag = "nro" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO") = 'U') 
			Return .F.					
		EndIf			
		If cTag = "xCpl" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XCPL") = 'U') 
			Return .F.					
		EndIf			
		If cTag = "xBairro" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO") = 'U')	 
			Return .F.					
		EndIf			
		If cTag = "xMun" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN") = 'U') 
			Return .F.					
		EndIf			
		If cTag = "cMun" .And. (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_CMUN") = 'U')
			Return .F.					
		EndIf			
	Case cVar == "LOCENT"
		If (Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "SEG"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_SEG") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "PROPRED"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "TRANSANT"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "COMPL"
		If (Type("oNfe:_CTE:_INFCTE:_COMPL:_xObs") = 'U')
			lRet := .F.
		EndIf
EndCase		

Return(lRet)
//---------------------------------------------------------------------------------------------------
/*{Protheus.doc} VldCpoGrid
habilita ou desabilita o campo
Uso restrito

@sample
VldCpoGrid()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function VldCpoGrid(cVar)

Local lRet 		:= .T.  
Default cVar		:= " "

If oNfe = Nil	
	RetContTag("oNFE:_CTE:_INFCTE") // Recarrega o objeto oNfe	
EndIf

Do Case
	Case cVar == "VEIC"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "MOT"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "INFQ"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "PERI"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI") = 'U')
			lRet := .F.
		EndIf
	Case cVar == "LACR"
		If (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") = 'U')
			lRet := .F.
		EndIf
EndCase

Return(lRet)


/*/{Protheus.doc} StrModVeic
Criação do objeto Struct dos com os dos veiculos
Uso restrito

@sample
StrModVeic()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function StrModVeic(nOp)
Local aCampos := CamposVeic()
Local nCont := 1
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(			;
	"VVVV"						, ;		// [01] Alias da tabela
	{ "VEIC_CINT" }			, ;		// [02] Array com os campos que correspondem a primary key
	"Veiculos"					)		// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;			// [01] Ordem do indice
	"VEIC_CINT"	, ;			// [02] ID
	"VEIC_CINT"	, ;			// [03] Chave do indice
	"VEIC_CINT"	, ;			// [04] Descrição do indice //"Calculo01"
	''				, ;			// [05] Expressão de lookUp dos campos de indice
	''				, ;			// [06] Nickname do indice
	.T.              )			// [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

   		oStruct:AddField( ;
		aCampos[nCont][1]			, ;			// [01] Titulo do campo
		aCampos[nCont][1]			, ;			// [02] ToolTip do campo
		aCampos[nCont][2]			, ;			// [03] Id do Field
		aCampos[nCont][3]			, ;			// [04] Tipo do campo
		aCampos[nCont][4]			, ;			// [05] Tamanho do campo
		aCampos[nCont][5]			, ;			// [06] Decimal do campo
									, ;         // [07] Code-block de validação do campo
		aCampos[nCont][13]		, ;         // [08] Code-block de validação When do campo
		aCampos[nCont][15]		, ;         // [09] Lista de valores permitido do campo
		.F.							, ;         // [10] Indica se o campo tem preenchimento obrigatório
									, ;         // [11] Code-block de inicializacao do campo
		.F.							, ;         // [12] Indica se trata-se de um campo chave
		.F.							, ;         // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.							, ;         // [14] Indica se o campo é virtual
		 , )
		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( 			   ;
		aCampos[nCont][2]				, ;                // [01] Campo
		aCampos[nCont][12]		   	, ;                // [02] Ordem
		aCampos[nCont][1]				, ;                // [03] Titulo
		aCampos[nCont][1]				, ;                // [04] Descricao
		NIL								, ;                // [05] Help
		aCampos[nCont][14]		  	, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]				, ;                // [07] Picture
		NIL								, ;                // [08] PictVar
		NIL								, ;                // [09] F3
		aCampos[nCont][9]				, ;                // [10] Editavel
		NIL								, ;                // [11] Folder
		NIL								, ;                // [12] Group
		aCampos[nCont][15]			, ;                // [13] Lista Combo
		0								, ;                // [14] Tam Max Combo
		""								, ;                // [15] Inic. Browse
		NIL								)			    	// [16] Virtual

		nCont++
	End

EndIf

Return oStruct


/*/{Protheus.doc} CamposVeic
Criação do array para o objeto Struct dos Dados dos Veiculos
Uso restrito

@sample
CamposVeic()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function CamposVeic()
Local aCampos := {}

	aCampos:= { ;
	{"Renavam"					,"VEIC_RENAVAM"	,     "C", 11   ,0,"@!"					,"","",.T.	,"veic",	"RENAVAM"	,"02",	{|| VldCpoGrid("VEIC")} , "G", {}									},;
	{"Placa"					,"VEIC_PLACA"		,     "C", 7   	 ,0,"@!"					,"","",.T.	,"veic",	"placa"	,"03",	{|| VldCpoGrid("VEIC")} , "G", {}									},;  
	{"Tara"					,"VEIC_TARA"		,     "N", 6   	 ,0,"@E 999,999,999.99" 	,"","",.T.	,"veic",	"tara"		,"04",	{|| VldCpoGrid("VEIC")} , "G", {}									},;   
	{"Capacidade KG"			,"VEIC_CAPKG"		,     "N", 6   	 ,0,"@E 999,999,999.99"	,"","",.T.	,"veic",	"capKG"	,"05",	{|| VldCpoGrid("VEIC")} , "G", {}									},;  
	{"Capacidade M3"			,"VEIC_CAPM3"		,     "N", 10   ,0,"@E 999,999,999.99"	,"","",.T.	,"veic",	"capM3"	,"06",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 
	{"Tipo Proprietário"		,"VEIC_TPPROP"	,     "C", 1   	 ,0,"@!"					,"","",.T.	,"veic",	"tpProp"	,"07",	{|| VldCpoGrid("VEIC")} , "C", {"P=Próprio", "T=Terceiro"}		},; 
	{"Tipo Veículo"			,"VEIC_TPVEIC"	,     "C", 1   	 ,0,"@!"					,"","",.T.	,"veic",	"tpVeic"	,"08",	{|| VldCpoGrid("VEIC")} , "C", {"0=Tração","1=Reboque"}			},; 
	{"Tipo Rodado"			,"VEIC_TPROD"		,     "C", 2   	 ,0,"@!"					,"","",.T.	,"veic",	"tpRod"	,"09",	{|| VldCpoGrid("VEIC")} , "C", {"00=Não Aplicável","01=Truck","02=Toco","03=Cavalo Mecânico","04=VAN","05=Utilitário","06=Outros"}		},; 
	{"Tipo Carroceria"		,"VEIC_TPCAR"		,     "C", 2   	 ,0,"@!"					,"","",.T.	,"veic",	"tpCar"	,"10",	{|| VldCpoGrid("VEIC")} , "C", {"00=Não Aplicável","02=Fechada/Baú","03=Granelera","04=Porta Container","05=Sider"}		},; 
	{"Estado" 					,"VEIC_UF"			,     "C", 2   	 ,0,"@!"					,"","",.T.	,"veic",	"UF"		,"11",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 
	{"Nome Proprietário" 		,"PROP_NOME"		,     "C", 60   ,0,"@!"					,"","",.T.	,"prop",	"xNome"	,"12",	{|| VldCpoGrid("VEIC")} , "G", {}									},;
	{"CPF"						,"PROP_CPF"		,     "C", 11   ,0,"@!"					,"","",.T.	,"prop", 	"CPF"		,"13",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 
	{"CNPJ"					,"PROP_CNPJ"		,     "C", 14   ,0,"@!"					,"","",.T.	,"prop", 	"CNPJ"		,"14",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 
	{"RNTRC"					,"PROP_RNTRC"		,     "C", 8   	 ,0,"@!"					,"","",.T.	,"prop", 	"RNTRC"	,"15",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 
	{"IE"						,"PROP_IE" 		,     "C", 14   ,0,"@!"					,"","",.T.	,"prop", 	"IE"		,"16",	{|| VldCpoGrid("VEIC")} , "G", {}									},;
	{"Estado"					,"PROP_UF" 		,     "C", 2   	 ,0,"@!"					,"","",.T.	,"prop", 	"UF"		,"17",	{|| VldCpoGrid("VEIC")} , "G", {}									},; 	
	{"Tipo Proprietário" 		,"PROP_TPPROP"	,     "C", 1   	 ,0,"@!"					,"","",.T.	,"prop", 	"tpProp"	,"18",	{|| VldCpoGrid("VEIC")} , "C", {"0=TAC - Agregado","1=TAC Independente","2=Outros"}		}}
	


Return (aCampos)

/*/{Protheus.doc} loadGridVeic
Retorna o conteudo do grid para os valores do CTE
Uso restrito

@sample
loadGridVeic()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridVeic(oGridModel, lCopy)

	Local aLoad		:={}
	Local nCont		:= 1
	//TAG VEIC
	Local cRenavam		:= ""
	Local cPlaca		:= ""
	Local cTara		:= ""
	Local cCapacKG		:= ""
	Local cCapacM3		:= ""
	Local cTipPropVe	:= ""
	Local cTipVeic		:= ""
	Local cTipRoda		:= ""
	Local cTipCar		:= ""
	Local cUFVeic		:= ""
	//TAG PROP
	Local cNomProp		:= ""
	Local cCPF			:= ""
	Local cCNPJ		:= ""
	Local cRNTRC		:= ""
	Local cIE			:= ""
	Local cUFProp		:= ""
	Local cTipProp		:= ""

 //TAG VEIC
	If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC") <> "U")
		If TYPE("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC") == "A"
           For nCont := 1 to len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC)
				// Carrega Variaveis

                //TAG VEIC
				cRenavam	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_RENAVAM")
				cPlaca		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PLACA")  
				cTara	   	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_TARA")   
				cCapacKG	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_CAPKG")  
				cCapacM3	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_CAPM3") 
				cTipPropVe	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_TPPROP") 
				cTipVeic	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_TPVEIC") 
				cTipRoda	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_TPROD") 
				cTipCar	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_TPCAR") 
				cUFVeic	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_UF") 
                //TAG PROP
				cNomProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_XNOME") 
				cCPF		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_CPF") 
				cCNPJ		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_CNPJ") 
				cRNTRC		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_RNTRC") 	
				cIE			:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_IE")
				cUFProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_UF")
				cTipProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+CVALTOCHAR(nCont)+"]:_PROP:_TPPROP")
			
				aAdd(aLoad,{0,{cRenavam, cPlaca, val(cTara), val(cCapacKG), val(cCapacM3), cTipPropVe, cTipVeic, cTipRoda, cTipCar, cUFVeic, ;
				Padr(cNomProp,60), Padr(cCPF,11),	Padr(cCNPJ,14), Padr(cRNTRC,8), Padr(cIE,14),	Padr(cUFProp,2), cTipProp}})		
			
			Next nCont
		Else
            //TAG VEIC
			cRenavam	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_RENAVAM")
			cPlaca		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA")  
			cTara	   	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TARA")   
			cCapacKG	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_CAPKG")  
			cCapacM3	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_CAPM3") 
			cTipPropVe	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP") 
			cTipVeic	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC") 
			cTipRoda	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPROD") 
			cTipCar	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPCAR") 
			cUFVeic	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF") 
             //TAG PROP
			cNomProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_XNOME") 
			cCPF		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_CPF") 
			cCNPJ		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_CNPJ") 
			cRNTRC		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_RNTRC") 	
			cIE			:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_IE")
			cUFProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_UF")
			cTipProp	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_TPPROP")
		
			aAdd(aLoad,{0,{cRenavam, cPlaca, val(cTara), val(cCapacKG), val(cCapacM3), cTipPropVe, cTipVeic, cTipRoda, cTipCar, cUFVeic, ;
			Padr(cNomProp,60), Padr(cCPF,11),	Padr(cCNPJ,14), Padr(cRNTRC,8), Padr(cIE,14),	Padr(cUFProp,2), cTipProp}})		
	
		EndIf
	EndIf			 	

Return(aLoad)
	  	
/*/{Protheus.doc} loadGridMot
Retorna o conteudo do grid para os valores de motorista CTE
Uso restrito

@sample
loadGridMot()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridMot(oGridModel, lCopy)

Local aLoad 	:= {}
Local nCont	:= 1
Local cNomMot	:= ""
Local cCPF		:= ""      

	If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") <> "U")
		If TYPE("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") == "A"
           For nCont := 1 to len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC)
				// Carrega Variaveis

                //TAG MOTORISTA
				cNomMot	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+CVALTOCHAR(nCont)+"]:_XNOME")  
				cCPF		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO["+CVALTOCHAR(nCont)+"]:_CPF")
			
				aAdd(aLoad,{0,{padr(cNomMot,60), cCPF}})		
			
			Next nCont
		Else
            //TAG MOTORISTA
			cNomMot	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME")  
			cCPF		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF")
	
			aAdd(aLoad,{0,{padr(cNomMot,60), cCPF}})		
		
		EndIf
	Else
		aAdd(aLoad,{0,{cNomMot, cCPF}})	
	EndIf			 	

Return(aLoad)

/*/{Protheus.doc} StrModMot
Criação do objeto Struct dos com os dos motoristas
Uso restrito

@sample
StrModMot()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModMot(nOp)
Local aCampos := CamposMot()
Local nCont := 1
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(			;
	"MMMM"						, ;		// [01] Alias da tabela
	{ "MOT_NOME" }				, ;		// [02] Array com os campos que correspondem a primary key
	"Motorista"				)		// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;			// [01] Ordem do indice
	"MOT_NOME"		, ;			// [02] ID
	"MOT_NOME"		, ;			// [03] Chave do indice
	"MOT_NOME"		, ;			// [04] Descrição do indice //"Calculo01"
	''				, ;			// [05] Expressão de lookUp dos campos de indice
	''				, ;			// [06] Nickname do indice
	.T.              )			// [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

   		oStruct:AddField( ;
		aCampos[nCont][1]			, ;			// [01] Titulo do campo
		aCampos[nCont][1]			, ;			// [02] ToolTip do campo
		aCampos[nCont][2]			, ;			// [03] Id do Field
		aCampos[nCont][3]			, ;			// [04] Tipo do campo
		aCampos[nCont][4]			, ;			// [05] Tamanho do campo
		aCampos[nCont][5]			, ;			// [06] Decimal do campo
									, ;         // [07] Code-block de validação do campo
		aCampos[nCont][13]		, ;         // [08] Code-block de validação When do campo
		{}							, ;         // [09] Lista de valores permitido do campo
		.F.							, ;         // [10] Indica se o campo tem preenchimento obrigatório
									, ;         // [11] Code-block de inicializacao do campo
		.F.							, ;         // [12] Indica se trata-se de um campo chave
		.F.							, ;         // [13] Indica se o campo pode receber valor em uma operação de update.
		.F.							, ;         // [14] Indica se o campo é virtual
		 , )
		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( 			   ;
		aCampos[nCont][2]				, ;                // [01] Campo
		aCampos[nCont][12]			, ;                // [02] Ordem
		aCampos[nCont][1]				, ;                // [03] Titulo
		aCampos[nCont][1]				, ;                // [04] Descricao
		NIL								, ;                // [05] Help
		'G'								, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]				, ;                // [07] Picture
		NIL								, ;                // [08] PictVar
		NIL								, ;                // [09] F3
		aCampos[nCont][9]				, ;                // [10] Editavel
		NIL								, ;                // [11] Folder
		NIL								, ;                // [12] Group
		NIL								, ;                // [13] Lista Combo
		0								, ;                // [14] Tam Max Combo
		""								, ;                // [15] Inic. Browse
		NIL								)			    	// [16] Virtual

		nCont++
	End

EndIf

Return oStruct

/*/{Protheus.doc} CamposMot
Criação do array para o objeto Struct dos Dados dos Motoristas
Uso restrito

@sample
CamposMot()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function CamposMot()
Local aCampos := {}

	aCampos:= { ;
	{"Nome Motorista" 		,"MOT_NOME"		,     "C", 60   ,0,"@!","","",.T. 	,"moto",	"xNome"	,"01" ,	 {|| VldCpoGrid("MOT")}	},; 
	{"CPF Motorista"			,"MOT_CPF"			,     "C", 11   ,0,"@!","","",.T.	,"moto",	"CPF"		,"02" , {|| VldCpoGrid("MOT")}	}}

Return (aCampos)

/*/{Protheus.doc} CamposInfQ
Criação do array para o objeto Struct dos Dados das informações de quantidade da carga
Uso restrito

@sample
CamposInfQ()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function CamposInfQ()
Local aCampos := {}

	aCampos:= { ;
	{"Cód. Unidade Medida"				,"UNI_MED"					 ,"C",2	 	 ,0,"@!"						,"","" 		 , .T. ,"infQ"			,	"cUnid"	,"C", "01" ,{|| VldCpoGrid("INFQ")}				,{"00=M3","01=KG","02=TON","03=UNIDADE","04=LITROS","05=MMBTU"}		},;
	{"Tipo da Medida"						,"TIP_MEDIDA"				 ,"C",20	 ,0,"@!	"						,"","" 		 , .T. ,"infQ"			,	"tpMed"	,"G", "02" ,{|| VldCpoGrid("INFQ")}				,{}		},;
	{"Quantidade"							,"QUANT_CAR"				 ,"N",15	 ,4,"@E 999,999,9999.9999"	,"","" 		 , .T. ,"infQ"			,	"qCarga"	,"G", "03" ,{|| VldCpoGrid("INFQ")}				,{}		}}

Return (aCampos)							

/*/{Protheus.doc} StrModinfQ
Criação do objeto Struct dos Dados das informações de quantidades da Carga do CT-e
Uso restrito

@sample
StrModinfQ()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function StrModinfQ(nOp)

Local aCampos := CamposInfQ()
Local nCont := 1 
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(				;
	"ZZYY"							,;      // [01] Alias da tabela
	{ "UNI_MED"}					,;      // [02] Array com os campos que correspondem a primary key
	"TAG InfQ"					)       	// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;				// [01] Ordem do indice
	"UNI_MED"		, ;				// [02] ID
	"UNI_MED"		, ;				// [03] Chave do indice
	"TAG InfQ"		, ;				// [04] Descrição do indice //"Calculo01"
	''				, ;				// [05] Expressão de lookUp dos campos de indice
	''              , ;				// [06] Nickname do indice
	.T.              )				// [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][1]			, ;              // [01] Titulo do campo
		aCampos[nCont][1]			, ;              // [02] ToolTip do campo
		aCampos[nCont][2]			, ;              // [03] Id do Field
		aCampos[nCont][3]			, ;              // [04] Tipo do campo
		aCampos[nCont][4]			, ;              // [05] Tamanho do campo
		aCampos[nCont][5]			, ;              // [06] Decimal do campo
									, ;			     // [07] Code-block de validação do campo
		aCampos[nCont][14]		, ;              // [08] Code-block de validação When do campo
		aCampos[nCont][15]		, ;              // [09] Lista de valores permitido do campo
		.F.							, ;              // [10] Indica se o campo tem preenchimento obrigatório
									, ;              // [11] Code-block de inicializacao do campo
		.F.							, ;              // [12] Indica se trata-se de um campo chave 
		.F.							, ;              // [13] Indica se o campo pode receber valor em uma operação de update. 
		.F.							, ;              // [14] Indica se o campo é virtual
		, )

		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()                                      

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][2]			, ;                // [01] Campo
		aCampos[nCont][13]		, ;                // [02] Ordem
		aCampos[nCont][1]			, ;                // [03] Titulo
		aCampos[nCont][1]			, ;                // [04] Descricao
		NIL							, ;                // [05] Help
		aCampos[nCont][11]		, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]			, ;                // [07] Picture
		NIL							, ;                // [08] PictVar
		NIL							, ;                // [09] F3
		aCampos[nCont][9]			, ;                // [10] Editavel
   		aCampos[nCont][7]			, ;                // [11] Folder
		aCampos[nCont][8]			, ;                // [12] Group
		aCampos[nCont][15]		, ;                // [13] Lista Combo
		NIL							, ;                // [14] Tam Max Combo
		"" 							, ;                // [15] Inic. Browse
		NIL							)				   // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

/*/{Protheus.doc} loadGridInfQ
Retorna o conteudo do grid para os valores da TAG INFQ
Uso restrito

@sample
loadGridInfQ()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridInfQ(oGridModel, lCopy)

Local aLoad 			:= {}
Local nCont			:= 1
Local cUniMed			:= ""
Local cTipMedida		:= ""      
Local cQuantCar		:= ""

	If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ") <> "U")
		If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ") == "A"
           For nCont := 1 to len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ)
				// Carrega Variaveis

                //TAG INFQ
				cUniMed		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ["+CVALTOCHAR(nCont)+"]:_CUNID")  
				cTipMedida		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ["+CVALTOCHAR(nCont)+"]:_TPMED")
				cQuantCar		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ["+CVALTOCHAR(nCont)+"]:_QCARGA")
				
				aAdd(aLoad,{0,{cUniMed, cTipMedida, val(cQuantCar)}})		
			
			Next nCont
		Else
            //TAG INFQ
			cUniMed		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_CUNID")  
			cTipMedida		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_TPMED")
			cQuantCar		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA")
		
			aAdd(aLoad,{0,{cUniMed, cTipMedida, val(cQuantCar)}})		
		
		EndIf
	Else
		aAdd(aLoad,{0,{cUniMed, cTipMedida, cQuantCar}})	
	EndIf			 	

Return(aLoad)

/*/{Protheus.doc} CamposPeri
Criação do array para o objeto Struct dos Dados de Produtos Perigosos
Uso restrito

@sample
CamposPeri()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function CamposPeri()
Local aCampos := {}

	aCampos:= { ;
	{"Número ONU/UN"				,"N_ONU"					 ,"C",4	 	 ,0,"@!"							,"","" 		 , .T. ,"peri",	"nONU"			,"G", "01" ,{|| VldCpoGrid("PERI")}			,{}		},;
	{"Nome para Embarque"		,"NOME_AE"					 ,"C",150 	 ,0,"@!"							,"","" 		 , .T. ,"peri",	"xNomeAE"		,"G", "02" ,{|| VldCpoGrid("PERI")}			,{}		},;
	{"Classe de Risco"			,"CLA_RISCO"				 ,"C",40 	 ,0,"@!"							,"","" 		 , .T. ,"peri",	"xClaRisco"	,"G", "03" ,{|| VldCpoGrid("PERI")}			,{}		},;
	{"Grupo de Embalagem"		,"GR_EMB"					 ,"C",6	 	 ,0,"@!"							,"","" 		 , .T. ,"peri",	"grEmb"		,"G", "04" ,{|| VldCpoGrid("PERI")}			,{}		},;
	{"Qtd. Total por Produto"	,"TOT_PROD"				 ,"N",20 	 ,4,"@E 999,999,9999.9999"		,"","" 		 , .T. ,"peri",	"qTotProd"		,"G", "05" ,{|| VldCpoGrid("PERI")}			,{}		}}

Return (aCampos)							

/*/{Protheus.doc} StrModPeri
Criação do objeto Struct dos Dados das informações de Produtos Perigosos
Uso restrito

@sample
StrModPeri()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function StrModPeri(nOp)

Local aCampos := CamposPeri()
Local nCont := 1 
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(				;
	"ZYYZ"							,;      // [01] Alias da tabela
	{ "N_ONU"}					,;      // [02] Array com os campos que correspondem a primary key
	"TAG Peri"					)       	// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;				// [01] Ordem do indice
	"N_ONU"		, ;				// [02] ID
	"N_ONU"		, ;				// [03] Chave do indice
	"TAG Peri"		, ;				// [04] Descrição do indice //"Calculo01"
	''				, ;				// [05] Expressão de lookUp dos campos de indice
	''              , ;				// [06] Nickname do indice
	.T.              )				// [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][1]			, ;              // [01] Titulo do campo
		aCampos[nCont][1]			, ;              // [02] ToolTip do campo
		aCampos[nCont][2]			, ;              // [03] Id do Field
		aCampos[nCont][3]			, ;              // [04] Tipo do campo
		aCampos[nCont][4]			, ;              // [05] Tamanho do campo
		aCampos[nCont][5]			, ;              // [06] Decimal do campo
									, ;			     // [07] Code-block de validação do campo
		aCampos[nCont][14]		, ;              // [08] Code-block de validação When do campo
		aCampos[nCont][15]		, ;              // [09] Lista de valores permitido do campo
		.F.							, ;              // [10] Indica se o campo tem preenchimento obrigatório
									, ;              // [11] Code-block de inicializacao do campo
		.F.							, ;              // [12] Indica se trata-se de um campo chave 
		.F.							, ;              // [13] Indica se o campo pode receber valor em uma operação de update. 
		.F.							, ;              // [14] Indica se o campo é virtual
		, )

		nCont++
	End

ElseIf nOp == 2
          
	oStruct := FWFormViewStruct():New()                                      

	While nCont < (len(aCampos) + 1)

		oStruct:AddField(			;
		aCampos[nCont][2]			, ;                // [01] Campo
		aCampos[nCont][13]		, ;                // [02] Ordem
		aCampos[nCont][1]			, ;                // [03] Titulo
		aCampos[nCont][1]			, ;                // [04] Descricao
		NIL							, ;                // [05] Help
		aCampos[nCont][11]		, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]			, ;                // [07] Picture
		NIL							, ;                // [08] PictVar
		NIL							, ;                // [09] F3
		aCampos[nCont][9]			, ;                // [10] Editavel
   		aCampos[nCont][7]			, ;                // [11] Folder
		aCampos[nCont][8]			, ;                // [12] Group
		aCampos[nCont][15]		, ;                // [13] Lista Combo
		NIL							, ;                // [14] Tam Max Combo
		"" 							, ;                // [15] Inic. Browse
		NIL							)				   // [16] Virtual

		nCont++
	End

EndIf

Return oStruct

/*/{Protheus.doc} loadGridPeri
Retorna o conteudo do grid para os valores de Produtos Perigosos
Uso restrito

@sample
loadGridPeri()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridPeri(oGridModel, lCopy)

Local aLoad 			:= {}
Local nCont			:= 1

Local cNumOnu	:= ""
Local cNomeAE	:= ""
Local cClaRisco := ""
Local cGrEmb	:= ""
Local cTotProd  := ""

	If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI") <> "U")
		If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI") == "A"
           For nCont := 1 to len(oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI)
				// Carrega Variaveis

                //TAG PERI
				cNumOnu		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI["+CVALTOCHAR(nCont)+"]:_NONU")
				cNomeAE		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI["+CVALTOCHAR(nCont)+"]:_XNOMEAE")
				cClaRisco 	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI["+CVALTOCHAR(nCont)+"]:_XCLARISCO")
				cGrEmb		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI["+CVALTOCHAR(nCont)+"]:_GREMB")
				cTotProd  	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI["+CVALTOCHAR(nCont)+"]:_QTOTPROD")
				
				aAdd(aLoad,{0,{cNumOnu, cNomeAE, cClaRisco, cGrEmb, val(cTotProd)  }})		
			
			Next nCont
		Else
             //TAG PERI
			cNumOnu		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI:_NONU")
			cNomeAE		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI:_XNOMEAE")
			cClaRisco 	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI:_XCLARISCO")
			cGrEmb		:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI:_GREMB")
			cTotProd  	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_PERI:_QTOTPROD")
			
			aAdd(aLoad,{0,{cNumOnu, cNomeAE, cClaRisco, cGrEmb, val(cTotProd)  }})		

		
		EndIf
	Else
		aAdd(aLoad,{0,{cNumOnu, cNomeAE, cClaRisco, cGrEmb, cTotProd  }})		
	EndIf			 	

Return(aLoad)


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CampOutros
Criação do array para o objeto Struct dos CTEs de Complemento
Uso restrito

@sample
CampOutros()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CampOutros()
Local aCampos := {}

	// As Funções CampCompl, CamposNFe, CamposNF e CampOutros devem sempre conter os mesmos tamanhos de array, e as mesmas posições.
	aCampos:= { ;
	{"Tipo Doc. Originário"			, "TIP_ORIG"				, 	  "C", 02   ,0,"@!"				,"","",.T.,"infOutros","tpDoc"  	,,"01", "C",	{"00=Declaração","10=Dutoviário", "99=Outros"}		},;	
	{"Número"						, "NUMNFC_DTC"				, 	  "C", 20   ,0,"@!"				,"","",.T.,"infOutros","nDoc"  		,,"02", "G",	{}		},;	
	{"Data Emissão"					, "COMPL_DTC"				, 	  "D", 08   ,0,"@!"				,"","",.T.,"infOutros","dEmi"  		,,"03", "G",	{}		}}	

Return (aCampos)					
								
///---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CampLacre
Criação do array para o objeto Struct do campo Lacre
Uso restrito

@sample
CampLacre()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CampLacre()
Local aCampos := {}

	aCampos:= { ;
	{"Número Lacre"		, "LACRE"		, 	  "C", 20   ,0,"@!"		,""	,"",	.T.,	"lacRodo","nLacre"  		,,"01" ,{|| VldCpoGrid("LACR")}		}}	

Return (aCampos)												
													
/*/{Protheus.doc} loadGridLacre
Retorna o conteudo do grid para os valores dos Lacres
Uso restrito

@sample
loadGridLacre()

@author Fabio Marchiori Sampaio.
@since 13/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
         
Static Function loadGridLacre(oGridModel, lCopy)

Local aLoad 	:= {}
Local nCont	:= 1
Local cLacre	:= ""


	If  (Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") <> "U")
		If TYPE("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") == "A"
           For nCont := 1 to len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO)
				// Carrega Variaveis

                //TAG MOTORISTA
				cLacre	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+CVALTOCHAR(nCont)+"]:_NLACRE")  
			
				aAdd(aLoad,{0,{padr(cLacre,20)}})		
			
			Next nCont
		Else
            //TAG MOTORISTA
			cLacre	:= retContTag("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE")  
	
			aAdd(aLoad,{0,{padr(cLacre, 20)}})		
		
		EndIf
	Else
		aAdd(aLoad,{0,{cLacre}})	
	EndIf			 	

Return(aLoad)													

/*/{Protheus.doc} StrModlacre
Criação do objeto Struct dos com os dos lacres
Uso restrito

@sample
StrModlacre()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function StrModlacre(nOp)
Local aCampos := CampLacre()
Local nCont := 1
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(			;
	"MLAC"						, ;		// [01] Alias da tabela
	{ "LACRE" }				, ;		// [02] Array com os campos que correspondem a primary key
	"Lacre"				)			// [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;			// [01] Ordem do indice
	"LACRE"		, ;			// [02] ID
	"LACRE"		, ;			// [03] Chave do indice
	"LACRE"		, ;			// [04] Descrição do indice //"Calculo01"
	''				, ;			// [05] Expressão de lookUp dos campos de indice
	''				, ;			// [06] Nickname do indice
	.T.              )			// [07] Indica se o indice pode ser utilizado pela interface

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------

	While nCont < (len(aCampos) + 1)

   		oStruct:AddField( ;
		aCampos[nCont][1]			, ;			// [01] Titulo do campo
		aCampos[nCont][1]			, ;			// [02] ToolTip do campo
		aCampos[nCont][2]			, ;			// [03] Id do Field
		aCampos[nCont][3]			, ;			// [04] Tipo do campo
		aCampos[nCont][4]			, ;			// [05] Tamanho do campo
		aCampos[nCont][5]			, ;			// [06] Decimal do campo
									, ;		    // [07] Code-block de validação do campo
		aCampos[nCont][14]		, ;         // [08] Code-block de validação When do campo
		{}							, ;         // [09] Lista de valores permitido do campo
		.F.							, ;         // [10] Indica se o campo tem preenchimento obrigatório
									, ;         // [11] Code-block de inicializacao do campo
		.F.							, ;         // [12] Indica se trata-se de um campo chave 
		.F.							, ;         // [13] Indica se o campo pode receber valor em uma operação de update. 
		.F.							, ;         // [14] Indica se o campo é virtual
		, )
		nCont++
	End

ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()

	While nCont < (len(aCampos) + 1)

		oStruct:AddField( 			   ;
		aCampos[nCont][2]				, ;                // [01] Campo
		aCampos[nCont][13]			, ;                // [02] Ordem
		aCampos[nCont][1]				, ;                // [03] Titulo
		aCampos[nCont][1]				, ;                // [04] Descricao
		NIL								, ;                // [05] Help
		'G'								, ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		aCampos[nCont][6]				, ;                // [07] Picture
		NIL								, ;                // [08] PictVar
		NIL								, ;                // [09] F3
		aCampos[nCont][9]				, ;                // [10] Editavel
		NIL								, ;                // [11] Folder
		NIL								, ;                // [12] Group
		NIL								, ;                // [13] Lista Combo
		0								, ;                // [14] Tam Max Combo
		""								, ;                // [15] Inic. Browse
		NIL								)			    	// [16] Virtual

		nCont++
	End

EndIf

Return oStruct


/*/{Protheus.doc} retMunCCe
Função criada para ser executada apartir da consulta padrão CC2CCE
Uso restrito

@sample
retMunCCe()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function retMunCCe()
Local cCadastro 	:= "Municipios"
Local lCancel 	  	:= .F.
Local aTitulo 	  	:= {}
Local aItens 	  	:= {}
Local lRet		  	:= .F.
Local nRet 	  	:= 0
Local cCampo  	  	:= ReadVar()
Local cCampoMun	:= ""

	Do Case
		Case cCampo == "M->EMIT_CMUN"   
		  	cUF := FWFldGet("EMIT_UF")
		  	cCampoMun := "EMIT_XMUN"
	    Case cCampo == "M->REM_CMUN" 
		  	cUF := FWFldGet("REM_UF")
		  	cCampoMun := "REM_XMUN"
	    Case cCampo == "M->DEST_CMUN" 
		  	cUF := FWFldGet("DEST_UF")
		  	cCampoMun := "DEST_XMUN"
	    Case cCampo == "M->CON_CMUN" 
		  	cUF := FWFldGet("CON_UF")
		  	cCampoMun := "CON_XMUN"
	    Case cCampo == "M->EXPED_CMUN" 
		  	cUF := FWFldGet("EXPED_UF")
		  	cCampoMun := "EXPED_XMUN"
	    Case cCampo == "M->LOCCOLETA_CMUN" 
		  	cUF := FWFldGet("LOCCOLETA_UF")
		  	cCampoMun := "LOCCOLETA_XMUN"
	    Case cCampo == "M->RECEB_CMUN" 
		  	cUF := FWFldGet("RECEB_UF")
		  	cCampoMun := "RECEB_XMUN"
	    Case cCampo == "M->LOCENT_CMUN" 
		  	cUF := FWFldGet("LOCENT_UF")
		  	cCampoMun := "LOCENT_XMUN"
		Case cCampo == "M->MUNINI_DT6" 
		  	cUF := FWFldGet("UFINI_DT6")
		  	cCampoMun := "XMUNINI_DT6"
		Case cCampo == "M->MUNFIM_DT6" 
		  	cUF := FWFldGet("UFFIM_DT6")
		  	cCampoMun := "XMUNFIM_DT6"
	EndCase  

	dbSelectArea("CC2")		
	CC2->(DbSetOrder(1)) 
	If CC2->(MsSeek( cSeekDVU := xFilial("CC2")+cUF))
		While CC2->(!Eof() .And. CC2->CC2_EST==cUF ) 
			Aadd(aItens,{ CC2->CC2_MUN, CC2->CC2_CODMUN, CC2->CC2_EST, CC2->(RecNo()) })
			CC2->(DbSkip())
		EndDo
	EndIf
 
	Aadd( aTitulo, RetTitle('CC2_MUN') )
	Aadd( aTitulo, RetTitle('CC2_CODMUN') )
	Aadd( aTitulo, RetTitle('CC2_EST') )
	
	aCabec := aClone(aTitulo)
	nRet := TmsF3Array( aTitulo, aItens, cCadastro, lCancel, /*aNewButton*/ , aCabec )
	
	If !Empty(nRet)
		CC2->(dbGoTo(aItens[nRet,Len(aTitulo)+1]))
		VAR_IXB := UFCODIBGE(CC2->CC2_EST)+CC2->CC2_CODMUN				
		lRet := .T.  
	Else
		VAR_IXB := Space(7)
		lRet := .F. 
	EndIf
	&(cCampo) := VAR_IXB

Return(lRet)

Static Function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)

/*/{Protheus.doc} TMSAE90Whe
Função para habilitar/desabilitar edição do campo
Uso restrito

@sample
TMSAE90Whe()

@author Fabio Marchiori Sampaio.
@since 10/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function TMSAE90Whe(cTag,cCampo)

Local lRet       := .T.
Local lRetPE     := .T.

//-- Executa ponto de entrada
If	ExistBlock('TME90WHE')
	lRetPE := ExecBlock('TME90WHE',.F.,.F.,{cTag,cCampo})
	If Valtype(lRetPE) == 'L'
		lRet := lRetPE
	EndIf
EndIf

Return( lRet )

Return .T.

/*/{Protheus.doc} TMAE90Trig
Gatilhar descrição dos municipios
Uso restrito

@sample
TMAE90Trig()

@author Felipe Barbieri
@since 15/04/2019
@version 1.0
/*///------------------------------------------------------------------------------------------------

static Function TMAE90Trig(cCampo)
Default cCampo := ""

If cCampo == "MUNINI_DT6"
	FwFldPut("XMUNINI_DT6", Posicione("CC2",1,xFilial("CC2")+FwFldGet("UFINI_DT6")+SubStr(&(readvar()),3,5),"CC2->CC2_MUN"))
ElseIf cCampo == "MUNFIM_DT6"
	FwFldPut("XMUNFIM_DT6", Posicione("CC2",1,xFilial("CC2")+FwFldGet("UFFIM_DT6")+SubStr(&(readvar()),3,5),"CC2->CC2_MUN"))
EndIf

Return .T.


/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pos Valid do Modelo

Uso: TMSAE90

@sample
//PosVldMdl(oModel)

@author Felipe Marques Barbiere
@since 20/04/2022
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet 		 := .T.						// Recebe o Retorno

If Len(oModel:GetValue('TMSAE90_01',"COMPL_CTE_OBS")) > 500 
	lRet := .F.
	oModel:SetErrorMessage (,,,,,"Campo Observação (Aba: Dados Compl. CTe) possui mais de 500 caracteres.")		
EndIf

Return lRet

#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "ATFR075.CH"

#DEFINE PFILIAL		1    
#DEFINE PCBASE		2     
#DEFINE PITEM		3     
#DEFINE PTIPO		4
#DEFINE PHISTOR		5
#DEFINE PSEQREAV	6
#DEFINE PSEQ       7
#DEFINE PDESCRIC	8   
#DEFINE PAQUISIC	9   
#DEFINE PLOCALIZA	10       
#DEFINE PGRUPO		11 
#DEFINE PCUSTBEM	12   
#DEFINE PPERDEPR	13   
#DEFINE PTPDEPR		14   
#DEFINE PMOEDA		15       
#DEFINE PTAXADEP	16     
#DEFINE PVORIG		17
#DEFINE PCOTADEP	18 
#DEFINE PDEPRACM	19   
#DEFINE PVLIVROS	20

Static cTpFis 	:= "01|02|03|04|05|06|07|11|13"
Static cTpGer 	:= "10|12|14|15"
Static nCampos	:= 20 	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFR075  ³ Autor ³ Jair Ribeiro           ³ Data ³ 11/13/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Livro de ativos depreciaveis                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAATF                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ACTUALIZACIONES SUFRIDAS DESDE EL DESARROLLO.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ FECHA  ³ BOPS     ³  MOTIVO DE LA ALTERACION            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano  ³09/12/16³SERINN001-142³creación de tablas temporales se  ³±±
±±³              ³        ³          ³asigna FWTemporaryTable en funciones ³±±
±±³              ³        ³          ³AFR075ARQT,AFR075Prc y AFR075TOT     ³±±
±±³Alf. Medrano  ³21/12/16³SERINN001-142³Merge 12.1.15 vs Main             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR075()
Local oReport	:= Nil
Local cPerg		:= "AFR075"

Local aFiliais	:= {}	//Array de filiais selecionadas
Local aMoedas	:= {}	//Array de moedas selecionadas

Local lAllFil	:= .F.
Local lContinua	:= .T.
Local lTReport	:= TRepInUse()
Local lTopConn 	:= IfDefTopCTB()

If !lTReport
	Help("  ",1,"AFR075TR4",,OEMTOANSI(STR0001),1,0)							//"Função disponível apenas em TReport"
	lContinua := .F.
EndIf
If !lTopConn
	Help("  ",1,"AFR075TOP",,OEMTOANSI(STR0002),1,0) 							//"Rotina disponível apenas para ambientes TopConnect"
	lContinua := .F.
EndIf

If Pergunte(cPerg,.T.) .and. lContinua	
	If MV_PAR11 == 1					 
 		aMoedas	:= AdmGetMoed()
 		lContinua	:= Len(aMoedas)>0
 		If lContinua
 			If Len(aMoedas) > 5
 				Help(" ",1,"ATR075MOE",,OEMTOANSI(STR0003),1,0) 				//"Deve ser selecionado no máximo 5 moedas "
    			lContinua	:= .F.
			EndIf
 		EndIf
 	Else
		aMoedas := {"01"}
	EndIf
	    
    If MV_PAR15 == 1 .and. lContinua
		aFiliais	:= AdmGetFil(@lAllFil) 
   		lContinua	:= Len(aFiliais)>0
	ElseIf lContinua
		aFiliais	:= {cFilAnt}
	EndIf
		
	If lContinua
		oReport:= AFR075RDef(cPerg,lAllFil,aFiliais,aMoedas)
		oReport:PrintDialog()
	EndIf
EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075RDefºAutor  ³Jair Ribeiro        º Data ³  11/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estrutura do relatorio                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cPerg: Grupo de perguntas 			                      º±±
±±º			 |lAllFil: Indica se todas filiais foram selecionadas      	  º±±
±±º			 ³aFiliais: Array com filiais selecionadas                    º±±
±±º			 ³aMoedas: Array com moedas selecionadas                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Livro de Ativos depreciaveis                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075RDef(cPerg,lAllFil,aFiliais,aMoedas)
Local oReport 	:= Nil
Local oSecDesc	:= Nil 
Local oSecTotal	:= Nil
Local cDesc		:= OEMTOANSI(STR0004)+" - Data Ref.: "+DTOC(Iif(Empty(MV_PAR01),dDataBase,MV_PAR01))				   		//"Livro de Ativos Depreciáveis"

oReport:= TReport():New(cPerg,cDesc,cPerg,{|oReport| AFR075Prc(oReport,lAllFil,aFiliais,aMoedas)},cDesc)
oReport:SetLandScape()
oReport:ParamReadOnly()
oReport:DisableOrientation()

oSecAtivo := TRSection():New(oReport,cDesc,{"SN1","SN3","NAOUSADO"})
TRCell():New(oSecAtivo	,"NUMINVENT"	,""	,OEMTOANSI(STR0005)		,									,(TamSx3("N1_CBASE")[1]+TamSx3("N1_ITEM")[1])	,,,,.T.,,,,.T.)
TRCell():New(oSecAtivo	,"N1_DESCRIC"	,	,		  				,									,20										   		,,,,.T.,,,,.T.)    		//DESCRICAO SINTETICA
TRCell():New(oSecAtivo	,"N1_LOCAL"		,	,		  				,									,TamSx3("N1_LOCAL")[1]		   					,,,,.T.,,,,.T.)    		//LOCALIZACAO
TRCell():New(oSecAtivo	,"N3_DINDEPR"	,	,		  				,									,TamSx3("N3_DINDEPR")[1]						,,,,.T.,,,,.T.)    		//DATA AQUISICAO
TRCell():New(oSecAtivo	,"N3_PERDEPR"	,	,		  				,									,TamSx3("N3_PERDEPR")[1]						,,,,.T.,,,,.T.)    		//VIDA UTIL
TRCell():New(oSecAtivo	,"N3_TIPO"		,""	,OEMTOANSI(STR0020)		,									,TamSx3("N3_TIPO")[1]		   					,,,,.T.,,,,.T.)    		//TIPO
TRCell():New(oSecAtivo	,"N3_HISTOR"	,	,		  				,									,20							   					,,,,.T.,,,,.T.)    		//HISTOR
TRCell():New(oSecAtivo	,"METODODEP"	,""	,OEMTOANSI(STR0008)		,									,20							   					,,,,.T.,,,,.T.)    		//METODO DEPRECIACAO
TRCell():New(oSecAtivo	,"SIMBMOEDA"	,""	,OEMTOANSI(STR0006)		,									,08												,,,,.T.,,,,.T.) 			//MOEDA
TRCell():New(oSecAtivo	,"TAXADEP"		,""	,OEMTOANSI(STR0009)		,PesqPict("SN3","N3_TXDEPR1",19,1)	,TamSx3("N3_TXDEPR1")[1]	   					,,,,.T.,,,,.T.)    		//TAXA DE DEPRECIACAO
TRCell():New(oSecAtivo	,"VLRORIG"		,""	,OEMTOANSI(STR0007)		,PesqPict("SN3","N3_VORIG1"	,19,1)	,TamSx3("N3_VORIG1")[1]					   		,,,,.T.,,,,.T.)	   		//VALOR ORIGINAL
TRCell():New(oSecAtivo	,"COTADEPR"		,""	,OEMTOANSI(STR0010)		,PesqPict("SN3","N3_VRDACM1",19,1)	,TamSx3("N3_VRDACM1")[1]   	 					,,,,.T.,,,,.T.)    		//COTA DE DEPRECIACAO
TRCell():New(oSecAtivo	,"VLRDPRAC"		,""	,OEMTOANSI(STR0011)		,PesqPict("SN3","N3_VRDACM1",19,1)	,TamSx3("N3_VRDACM1")[1]						,,,,.T.,,,,.T.)	   		//DEPRECIACAO ACUMULADA
TRCell():New(oSecAtivo	,"VLLIBROS"		,""	,OEMTOANSI(STR0012)		,PesqPict("SN3","N3_VORIG1"	,19,1)	,TamSx3("N3_VORIG1")[1]	 	  					,,,,.T.,,,,.T.)    		//VALOR EM LIBROS

oSecAtivo:Cell("TAXADEP"):SetHeaderAlign("RIGHT")
oSecAtivo:Cell("COTADEPR"):SetHeaderAlign("RIGHT")
oSecAtivo:Cell("VLRORIG"):SetHeaderAlign("RIGHT")
oSecAtivo:Cell("VLRDPRAC"):SetHeaderAlign("RIGHT")
oSecAtivo:Cell("VLLIBROS"):SetHeaderAlign("RIGHT")
oSecAtivo:SetHeaderPage(.T.)

oSecDesc := TRSection():New(oReport,"DESCRIC")
TRCell():New(oSecDesc,"DESCTOT"	,,,,,,,	,.T.,,,	,.T.,,,.T.)
oSecDesc:Cell("DESCTOT"):SetHeaderAlign("CENTER") 
oSecDesc:Cell("DESCTOT"):SetAlign("CENTER")
oSecDesc:SetHeaderSection(.F.)


Return oReport 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075Prc	ºAutor  ³Jair Ribeiro        º Data ³  11/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao dos dados                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oReport: Objeto TReport	 			                      º±±
±±º			 ³lAllFil: Indica se todas filiais foram selecionadas	      º±±
±±º			 ³aFiliais: Array com filiais selecionadas      	          º±±
±±º			 ³aMoedas: Array com moedas selecionadas    	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Livro de Ativos depreciaveis                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075Prc(oReport,lAllFil,aFiliais,aMoedas)
Local oSecAtivo	:= oReport:Section(1)
Local cAliasQry	:= GetNextAlias()
Local dData		:= IiF(Empty(MV_PAR01),dDataBase,MV_PAR01)
Local cCustoI   := MV_PAR02 
Local cCustoF	:= MV_PAR03	
Local cGrupoI	:= MV_PAR04
Local cGrupoF	:= MV_PAR05
Local cBaseI	:= MV_PAR06
Local cItemI	:= MV_PAR07 
Local cBaseF	:= MV_PAR08
Local cItemF	:= MV_PAR09 
Local lBaixados	:= (MV_PAR10 == 1) 
Local lTipoFis	:= (MV_PAR12 == 1)
Local lTipoGer	:= (MV_PAR12 == 2)
Local lFolha	:= (MV_PAR14 == 1)
Local dDataCota	:= AFR075DCOT(dData,"01/01")

//Variaveis para os totalizadores
Local cTotalBem	:= ""
Local cWhereBem	:= ""

Local lTotalGrp	:= .F.
Local cTotalGrp	:= ""
Local cWhereGrp	:= ""

Local lTotalCc	:= .F.
Local cTotalCc	:= ""
Local cWhereCc	:= ""

Local cTotalFil	:= ""
Local cWhereFil	:= ""

Local lLine		:= .T.
Local lNewPg	:= .F.
Local cMoedaRef	:= ""

Local oMeter	:= Nil
Local oText		:= Nil
Local oDlg		:= Nil
Local lEnd		
Local aChave := {}	
private 	oTmpTable

If MV_PAR13 == 1
	aChave 		:= {"FILIAL","GRUPO","CBASE","ITEM","TIPO","SEQREAV","SEQ","MOEDA"}
	cIndice		:= "FILIAL+GRUPO+CBASE+ITEM"
	cCampo		:= "GRUPO"            
	lTotalGrp	:= .T.
ElseIf MV_PAR13 == 2
 	aChave 		:= {"FILIAL","CUSTBEM","CBASE","ITEM","TIPO","SEQREAV","SEQ","MOEDA"} 
	cIndice		:= "FILIAL+CUSTBEM+CBASE+ITEM"
	cCampo		:= "CUSTBEM"
	lTotalCc	:= .T.
Else
	aChave 	:= {"FILIAL","CBASE","ITEM","TIPO","SEQREAV","SEQ","MOEDA"}
	cIndice	:= "FILIAL+CBASE+ITEM"          
EndIf 

MsgMeter({|oMeter,oText,oDlg,lEnd| ;
AFR075ARQT(cAliasQry,dData,cCustoI,cCustoF,cGrupoI,cGrupoF,cBaseI,cItemI,cBaseF,cItemF,;
			lBaixados,lTipoFis,lTipoGer,aMoedas,aFiliais,lAllFil,aChave,dDataCota)},STR0013,STR0014)//"Criando Arquivo Temporário..."#"Demonstrativo de Ativos Reavaliados"

(cAliasQry)->(DbGoTop())
While (cAliasQry)->(!EOF()) .and. !oReport:Cancel()	
	cMoedaRef := IiF(Empty(cMoedaRef),(cAliasQry)->(MOEDA),cMoedaRef)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TOTAL POR BEM                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    If !Empty(cTotalBem) .and. (cAliasQry)->(FILIAL+CBASE+ITEM) != cTotalBem
		AFR075TOT(oReport,cAliasQry,cWhereBem,cTextoBem,lLine)
		lLine		:= .F.
		cTotalBem	:= ""
		If !lTotalGrp .and. !lTotalCc .and. lFolha
			oReport:EndPage()
			lNewPg 	:= .T.	
		Else
			lNewPg 	:= .F.
		EndIf  
	EndIf
	If Empty(cTotalBem)
		cTextoBem	:= STR0015 + (cAliasQry)->(CBASE+ITEM)							//"Sub Total do Bem: "
		cTotalBem	:=(cAliasQry)->(FILIAL+CBASE+ITEM)
		cWhereBem	:= "FILIAL = '"+(cAliasQry)->(FILIAL)+"' AND CBASE = '"+(cAliasQry)->(CBASE)+"' AND ITEM = '"+(cAliasQry)->(ITEM)+"' "
		cWhereBem	+= IiF(lTotalGrp," AND GRUPO = '"+(cAliasQry)->(GRUPO)+"' ","")
		cWhereBem	+= IiF(lTotalCc," AND CUSTBEM = '"+(cAliasQry)->(CUSTBEM)+"' ","" )
	EndIf	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TOTAL POR GRUPO DE BENS		                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTotalGrp
		If !Empty(cTotalGrp) .and. (cAliasQry)->(FILIAL+GRUPO) != cTotalGrp
			AFR075TOT(oReport,cAliasQry,cWhereGrp,cTextoGrp,lLine)
			lLine		:= .F.
			cTotalGrp	:= ""
			If lFolha
				oReport:EndPage()
				lNewPg 	:= .T.	
			EndIf  
		EndIf
		If Empty(cTotalGrp)
			cTotalGrp	:=(cAliasQry)->(FILIAL+GRUPO)
			cTextoGrp	:= STR0016 + (cAliasQry)->(GRUPO) 								//"Sub Total do Grupo: "
			cWhereGrp	:= "FILIAL = '"+(cAliasQry)->(FILIAL)+"' AND GRUPO = '"+(cAliasQry)->(CUSTBEM)+"' "
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TOTAL POR CENTRO DE CUSTO	                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTotalCc
		If !Empty(cTotalCc) .and. (cAliasQry)->(FILIAL+CUSTBEM) != cTotalCc
			AFR075TOT(oReport,cAliasQry,cWhereCc,cTextoCc,lLine)
			lLine		:= .F.
			cTotalCc	:= ""
			If lFolha
				oReport:EndPage()
				lNewPg 	:= .T.	
			EndIf 
		EndIf
		If Empty(cTotalCc)
			cTotalCc	:=(cAliasQry)->(FILIAL+CUSTBEM)
			cTextoCc	:= STR0017 + (cAliasQry)->(CUSTBEM) 							// "Sub Total do Centro de Custo: "
			cWhereCc	:= "FILIAL = '"+(cAliasQry)->(FILIAL)+"' AND CUSTBEM = '"+(cAliasQry)->(CUSTBEM)+"' "
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TOTAL POR FILIAL                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cTotalFil) .and. (cAliasQry)->(FILIAL) != cTotalFil
		AFR075TOT(oReport,cAliasQry,cWhereFil,cTextoFil,lLine)
		lLine		:= .F.
		cTotalFil	:= ""
	EndIf
	If Empty(cTotalFil)
		cTotalFil	:=(cAliasQry)->(FILIAL)
		cTextoFil	:= STR0018 + (cAliasQry)->(FILIAL) 								//"Sub Total da Filial: "
		cWhereFil	:= " FILIAL = '"+(cAliasQry)->(FILIAL)+"' "
		cWhereFil	+= IiF(lTotalGrp," AND GRUPO = '"+(cAliasQry)->(GRUPO)+"' ","" )
		cWhereFil	+= IiF(lTotalCc," AND CUSTBEM = '"+(cAliasQry)->(CUSTBEM)+"' ","" )
	EndIf	     
	If !lLine
		If (!lFolha .or. !lNewPg) 
			oReport:ThinLine()
		EndIf
		lLine:=.T.
	EndIf
	
	cSeek	:=(cAliasQry)->&(cIndice)	
	TRPosition():New(oSecAtivo,"SN1",1,{|| xFilial("SN1",(cAliasQry)->(FILIAL))+(cAliasQry)->CBASE +(cAliasQry)->ITEM})
	oSecAtivo:Init()
	oSecAtivo:Cell("NUMINVENT"):SetValue((cAliasQry)->(CBASE)+"-"+(cAliasQry)->(ITEM))
	oSecAtivo:Cell("N1_DESCRIC"):SetValue((cAliasQry)->DESCRIC) 
	oSecAtivo:Cell("N1_LOCAL"):SetValue((cAliasQry)->LOCALIZA)	
	oSecAtivo:Cell("N3_DINDEPR"):SetValue((cAliasQry)->AQUISIC)	
	oSecAtivo:Cell("N3_PERDEPR"):SetValue((cAliasQry)->PERDEPR )
	oSecAtivo:Cell("N3_TIPO"):SetValue( (cAliasQry)->TIPO)
	oSecAtivo:Cell("N3_HISTOR"):SetValue( (cAliasQry)->HISTOR)      
	oSecAtivo:Cell("METODODEP"):SetValue( GetAdvFVal("SN0","N0_DESC01",xFilial("SN0")+"04"+(cAliasQry)->TPDEPR))	
	oSecAtivo:Cell("SIMBMOEDA"):SetValue(SuperGetMV("MV_SIMB"+CValtoChar(Val((cAliasQry)->MOEDA))))	
	oSecAtivo:Cell("TAXADEP"):SetValue((cAliasQry)->TAXADEP)		
	oSecAtivo:Cell("VLRORIG"):SetValue(	(cAliasQry)->VORIG)
	oSecAtivo:Cell("COTADEPR"):SetValue((cAliasQry)->COTADEP)	
	oSecAtivo:Cell("VLRDPRAC"):SetValue((cAliasQry)->DEPRACM)		
	oSecAtivo:Cell("VLLIBROS"):SetValue((cAliasQry)->VLIVROS)
	oSecAtivo:PrintLine()		
	(cAliasQry)->(DbSkip())
	
	While cSeek ==(cAliasQry)->&(cIndice)
		cMoeda	:= SuperGetMV("MV_SIMB"+CValtoChar(Val((cAliasQry)->MOEDA)))		
		oSecAtivo:Cell("NUMINVENT"):SetValue("")
		oSecAtivo:Cell("N1_DESCRIC"):SetValue("") 
		oSecAtivo:Cell("N1_LOCAL"):SetValue("")	
		oSecAtivo:Cell("N3_DINDEPR"):SetValue(IiF(cMoedaRef == (cAliasQry)->MOEDA, (cAliasQry)->AQUISIC,""))
		oSecAtivo:Cell("N3_PERDEPR"):SetValue(IiF(cMoedaRef == (cAliasQry)->MOEDA, (cAliasQry)->PERDEPR,""))
		oSecAtivo:Cell("N3_TIPO"):SetValue(IiF(cMoedaRef == (cAliasQry)->MOEDA, (cAliasQry)->TIPO,""))
		oSecAtivo:Cell("N3_HISTOR"):SetValue(IiF(cMoedaRef == (cAliasQry)->MOEDA,(cAliasQry)->HISTOR,""))     
		oSecAtivo:Cell("METODODEP"):SetValue(IiF(cMoedaRef == (cAliasQry)->MOEDA, GetAdvFVal("SN0","N0_DESC01",xFilial("SN0")+"04"+(cAliasQry)->TPDEPR),""))	
		oSecAtivo:Cell("SIMBMOEDA"):SetValue(cMoeda)	
		oSecAtivo:Cell("TAXADEP"):SetValue((cAliasQry)->TAXADEP)		
		oSecAtivo:Cell("VLRORIG"):SetValue((cAliasQry)->VORIG)
		oSecAtivo:Cell("COTADEPR"):SetValue((cAliasQry)->COTADEP)
		oSecAtivo:Cell("VLRDPRAC"):SetValue((cAliasQry)->DEPRACM)		
		oSecAtivo:Cell("VLLIBROS"):SetValue((cAliasQry)->VLIVROS)
		oSecAtivo:PrintLine()
		(cAliasQry)->(DbSkip())
	EndDo
	oSecAtivo:Finish()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAL POR BEM                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If !Empty(cTotalBem) .and. (cAliasQry)->(FILIAL+CBASE+ITEM) != cTotalBem
	AFR075TOT(oReport,cAliasQry,cWhereBem,cTextoBem,lLine)
	lLine		:= .F.
	cTotalBem	:= ""
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAL POR GRUPO DE BENS		                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTotalGrp
	If !Empty(cTotalGrp) .and. (cAliasQry)->(FILIAL+GRUPO) != cTotalGrp
		AFR075TOT(oReport,cAliasQry,cWhereGrp,cTextoGrp,lLine)
		lLine		:= .F.
		cTotalGrp	:= ""
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAL POR CENTRO DE CUSTO	                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTotalCc
	If !Empty(cTotalCc) .and. (cAliasQry)->(FILIAL+CUSTBEM) != cTotalCc
		AFR075TOT(oReport,cAliasQry,cWhereCc,cTextoCc,lLine)
		lLine		:= .F.
		cTotalCc	:= ""
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAL POR FILIAL                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cTotalFil) .and. (cAliasQry)->(FILIAL) != cTotalFil
	AFR075TOT(oReport,cAliasQry,cWhereFil,cTextoFil,lLine)
	lLine		:= .F.
	cTotalFil	:= ""
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TOTAL GERAL			                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AFR075TOT(oReport,cAliasQry,"",STR0019,.F.) //"Total Geral "

(cAliasQry)->(dbCloseArea())

If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075DCotºAutor  ³Microsiga           º Data ³  11/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna data para cota de depreciacao                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075DCot(dData,dDataCota)
Local dDataRet
Default dData 		:= dDataBase
Default dDataCota	:= "01/01"

If MONTH(CTOD(dDataCota)) > MONTH(dData)
	dDataRet := CTOD(dDataCota+"/"+ALLTRIM(STR(Year(dData)-1)))
Else
	dDataRet := CTOD(dDataCota+"/"+ALLTRIM(STR(Year(dData))))
EndIf
Return DTOS(dDataRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075TOT ºAutor  ³Jair Ribeiro        º Data ³  11/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Totalizador                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075TOT(oReport,cAliasQry,cCondicao,cTexto,lLine)
Local cQuery	:= ""
Local cAliasTot	:= GetNextAlias()
Local oSecAtivo := oReport:Section(1)
Local oSecDesc	:= oReport:Section(2)

Default cTexto	:= "TESTE"

cQuery+= "SELECT "
cQuery+= " MOEDA "
cQuery+= " ,SUM(VORIG) VORIG"
cQuery+= " ,SUM(COTADEP) COTADEP"
cQuery+= " ,SUM(DEPRACM) DEPRACM" 
cQuery+= " ,SUM(VLIVROS) VLIVROS"
cQuery+= " FROM "+ oTmpTable:GetRealName()
If !Empty(cCondicao)
	cQuery+= " WHERE "
	cQuery+= cCondicao
EndIf
cQuery+= " GROUP BY MOEDA"
cQuery := ChangeQuery(cQuery )
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.F.)

If (cAliasTot)->(!EOF())
	//If lLine
	//	oReport:ThinLine()
	//EndIf
	oSecDesc:Init()
	oSecDesc:Cell("DESCTOT"):SetValue(cTexto)              
	oSecDesc:PrintLine()
	oSecAtivo:Init()
	While (cAliasTot)->(!EOF())
		cMoeda	:= SuperGetMV("MV_SIMB"+CValtoChar(Val((cAliasTot)->MOEDA)))		
		oSecAtivo:Cell("NUMINVENT"):SetValue("")
		oSecAtivo:Cell("N1_DESCRIC"):SetValue("") 
		oSecAtivo:Cell("N1_LOCAL"):SetValue("")	
		oSecAtivo:Cell("N3_DINDEPR"):SetValue("")
		oSecAtivo:Cell("N3_PERDEPR"):SetValue("")
		oSecAtivo:Cell("N3_TIPO"):SetValue("")
		oSecAtivo:Cell("N3_HISTOR"):SetValue("")     
		oSecAtivo:Cell("METODODEP"):SetValue("")	
		oSecAtivo:Cell("SIMBMOEDA"):SetValue(cMoeda)	
		oSecAtivo:Cell("TAXADEP"):Hide()	
		oSecAtivo:Cell("VLRORIG"):SetValue((cAliasTot)->VORIG)
		oSecAtivo:Cell("COTADEPR"):SetValue((cAliasTot)->COTADEP)
		oSecAtivo:Cell("VLRDPRAC"):SetValue((cAliasTot)->DEPRACM)		
		oSecAtivo:Cell("VLLIBROS"):SetValue((cAliasTot)->VLIVROS)
		oSecAtivo:PrintLine()
		(cAliasTot)->(DbSkip())
	EndDo
	oSecAtivo:Cell("TAXADEP"):Show()
	oSecAtivo:Finish()
	oSecDesc:Finish()
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075ARQTºAutor  ³Jair Ribeiro        º Data ³  11/17/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria arquivo temporario com os dados para impressao        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075ARQT(cAliasQry,dData,cCustoI,cCustoF,cGrupoI,cGrupoF,cBaseI,cItemI,cBaseF,cItemF,lBaixados,lTipoFis,lTipoGer,aMoedas,aFiliais,lAllFil,aChave,dDataCota)
Local aTmpFil	:= {}
Local aCampos	:= {}
Local nI		:= 0
Local cArqTmp	:= ""

cArqTmp := cAliasQry 
aAdd(aCampos,	{"FILIAL"		,"C"	,TamSX3("N1_FILIAL")[1]		,00	})
aAdd(aCampos,	{"CBASE" 		,"C"	,TamSX3("N1_CBASE")[1]		,00	})
aAdd(aCampos,	{"ITEM"  		,"C"	,TamSX3("N1_ITEM")[1]		,00	})
aAdd(aCampos,	{"TIPO"	 		,"C"	,TamSX3("N3_TIPO")[1]		,00	})
aAdd(aCampos,	{"HISTOR" 		,"C"	,TamSX3("N3_HISTOR")[1]		,00	})
aAdd(aCampos,	{"SEQREAV" 		,"C"	,TamSX3("N4_SEQREAV")[1]	,00	})
aAdd(aCampos,	{"SEQ" 			,"C"	,TamSX3("N4_SEQ")[1]		,00	})
aAdd(aCampos,	{"DESCRIC"		,"C"	,TamSX3("N1_DESCRIC")[1]	,00	})
aAdd(aCampos,	{"LOCALIZA"		,"C"	,TamSX3("N1_LOCAL")[1]		,00	})
aAdd(aCampos,	{"AQUISIC" 		,"D"	,TamSX3("N3_DINDEPR")[1]	,00	}) 
aAdd(aCampos,	{"GRUPO"		,"C"	,TamSX3("N1_GRUPO")[1]		,00	})
aAdd(aCampos,	{"CUSTBEM"	 	,"C"	,TamSX3("N3_CUSTBEM")[1]	,00	})
aAdd(aCampos,	{"PERDEPR" 		,"N"	,TamSX3("N3_PERDEPR")[1]	,00	})
aAdd(aCampos,	{"TPDEPR"	 	,"C"	,TamSX3("N3_TPDEPR")[1]		,00	})
aAdd(aCampos,	{"MOEDA" 		,"C"	,02					  		,00	})
aAdd(aCampos,	{"TAXADEP"		,"N"	,TamSX3("N3_TXDEPR1")[1]	,TamSX3("N3_TXDEPR1")[2]	})
aAdd(aCampos,	{"VORIG"		,"N"	,TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]		})
aAdd(aCampos,	{"COTADEP"		,"N"	,TamSX3("N3_VRDACM1")[1]	,TamSX3("N3_VRDACM1")[2]	})
aAdd(aCampos,	{"DEPRACM"		,"N"	,TamSX3("N3_VRDACM1")[1]	,TamSX3("N3_VRDACM1")[2]	})
aAdd(aCampos,	{"VLIVROS"		,"N"	,TamSX3("N3_VORIG1")[1]		,TamSX3("N3_VORIG1")[2]		})

If Select(cArqTmp)>0
	(cArqTmp)->(DbCloseArea())
EndIf

oTmpTable := FWTemporaryTable():New(cArqTmp)
oTmpTable:SetFields( aCampos ) 
//crea indice
oTmpTable:AddIndex('T1ORD', aChave)
//Creacion de la tabla
oTmpTable:Create()

aValor := AFR075QRY(dData,cCustoI,cCustoF,cGrupoI,cGrupoF,cBaseI,cItemI,cBaseF,cItemF,lBaixados,lTipoFis,lTipoGer,aMoedas,aFiliais,lAllFil,dDataCota,aTmpFil)

For nI := 1 To Len(aValor)
	RecLock(cArqTmp,.T.)
	(cArqTmp)->FILIAL     	:= aValor[nI,PFILIAL]
	(cArqTmp)->CBASE      	:= aValor[nI,PCBASE]
	(cArqTmp)->ITEM       	:= aValor[nI,PITEM]
	(cArqTmp)->TIPO	      	:= aValor[nI,PTIPO]
	(cArqTmp)->HISTOR      	:= aValor[nI,PHISTOR]
	(cArqTmp)->SEQREAV    	:= aValor[nI,PSEQREAV]
	(cArqTmp)->SEQ 	     	:= aValor[nI,PSEQ]	
	(cArqTmp)->DESCRIC    	:= aValor[nI,PDESCRIC]
	(cArqTmp)->AQUISIC    	:= STOD(aValor[nI,PAQUISIC])
	(cArqTmp)->LOCALIZA   	:= aValor[nI,PLOCALIZA]
	(cArqTmp)->GRUPO	   	:= aValor[nI,PGRUPO]
	(cArqTmp)->CUSTBEM		:= aValor[nI,PCUSTBEM]
	(cArqTmp)->PERDEPR    	:= aValor[nI,PPERDEPR]
	(cArqTmp)->TPDEPR     	:= aValor[nI,PTPDEPR]
	(cArqTmp)->MOEDA      	:= aValor[nI,PMOEDA]
	(cArqTmp)->TAXADEP    	:= aValor[nI,PTAXADEP]
	(cArqTmp)->VORIG	  	:= aValor[nI,PVORIG]
	(cArqTmp)->COTADEP    	:= aValor[nI,PCOTADEP]
	(cArqTmp)->DEPRACM    	:= aValor[nI,PDEPRACM]
	(cArqTmp)->VLIVROS		:= aValor[nI,PVLIVROS]
	MsUnLock()
Next nI

For nI := 1 To Len(aTmpFil)
	CtbTmpErase(aTmpFil[nI])
Next
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075QRY ºAutor  ³Microsiga           º Data ³  11/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa query de acordo com parametros e retorna array     º±±
±±º          ³ com os valores correspondentes                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075QRY(dData,cCustoI,cCustoF,cGrupoI,cGrupoF,cBaseI,cItemI,cBaseF,cItemF,lBaixados,lTipoFis,lTipoGer,aMoedas,aFiliais,lAllFil,dDataCota,aTmpFil)
Local cQuery	:= "" 
Local cTmpFil	:= ""           
Local cChaveAx 	:= ""
Local nI		:= 0
Local aCpoVlN4	:= {}
Local aCpoVlN3	:= {}
Local aAux		:= {}
Local aAux2		:= {}
Local aRet		:= {}
Local aDados	:= {}
Local nPosAx	:= 0
Local nVal		:= 0
Local lInsert	:= .T.
Local aArea		:= GetArea()
Local cAliasRet	:= GetNextAlias()

For nI:= 1 to Len(aMoedas)
	aAdd(aCpoVlN3,IiF(nI > 9,"N3_TXDEP","N3_TXDEPR")+cValToChar(Val(aMoedas[nI])))
	aAdd(aCpoVlN4,"N4_VLROC"+cValToChar(Val(aMoedas[nI])))
Next nI

cQuery += "SELECT N4_FILIAL"+CRLF
cQuery += " ,N4_CBASE"+CRLF
cQuery += " ,N4_ITEM"+CRLF
cQuery += " ,N4_TIPO"+CRLF
cQuery += " ,N4_SEQREAV"+CRLF
cQuery += " ,N4_SEQ"+CRLF
cQuery += " ,N4_OCORR"+CRLF
cQuery += "	,N4_TIPOCNT"+CRLF
cQuery += " ,N4_MOTIVO"+CRLF 
cQuery += " ,N4_DATA"+CRLF 
For nI := 1 To Len(aCpoVlN4)
	cQuery += " ,SUM("+aCpoVlN4[nI]+")"+aCpoVlN4[nI]+CRLF
Next nI

cQuery += " ,N1_DESCRIC"+CRLF
cQuery += " ,N1_LOCAL"+CRLF
cQuery += " ,N1_GRUPO"+CRLF

cQuery += " ,N3_DINDEPR"+CRLF
cQuery += " ,N3_PERDEPR"+CRLF
cQuery += " ,N3_TPDEPR"+CRLF
cQuery += " ,N3_CUSTBEM"+CRLF
cQuery += " ,N3_HISTOR"+CRLF
For nI := 1 To Len(aCpoVlN3)
	cQuery += " ,"+aCpoVlN3[nI]+CRLF
Next nI

cQuery += " FROM "+RetSqlName("SN4")+" SN4"+CRLF 
cQuery += " INNER JOIN "+RetSqlName("SN1")+" SN1"+CRLF
cQuery += " ON( "+CRLF
cQuery += " N4_FILIAL = N1_FILIAL"+CRLF
cQuery += " AND N4_CBASE = N1_CBASE"+CRLF
cQuery += " AND N4_ITEM = N1_ITEM"+CRLF 
cQuery += ")"+CRLF

cQuery += " INNER JOIN "+RetSqlName("SN3")+" SN3"+CRLF
cQuery += " ON( "+CRLF
cQuery += " N4_FILIAL = N4_FILIAL"+CRLF
cQuery += " AND N4_CBASE = N3_CBASE"+CRLF
cQuery += " AND N4_ITEM = N3_ITEM"+CRLF
cQuery += " AND N4_SEQREAV = N3_SEQREAV"+CRLF 
cQuery += " AND N4_TIPO = N3_TIPO"+CRLF
cQuery += ")"+CRLF

cQuery += " WHERE "+CRLF
cQuery += " N4_CBASE BETWEEN '"+cBaseI+ "' AND '"+cBaseF+ "'"+CRLF
cQuery += " AND N4_ITEM BETWEEN '"+cItemI+ "' AND '"+cItemF+ "'"+CRLF
cQuery += " AND N4_DATA	<= '"+DTOS(dData)+"'"+ CRLF
cQuery += " AND N4_TIPOCNT IN ('1','4')"+CRLF 

If lTipoFis
	cQuery += " AND N4_TIPO IN "+FormatIn(cTpFis,"|")+CRLF
ElseIf lTipoGer
	cQuery += " AND N4_TIPO IN "+FormatIn(cTpGer,"|")+CRLF
EndIf


cQuery += " AND N1_GRUPO BETWEEN '"+cGrupoI+ "' AND '"+cGrupoF+ "'"+CRLF
cQuery += " AND N3_CUSTBEM BETWEEN '"+cCustoI+"' AND '"+cCustoF+"'"+CRLF

If !lBaixados  // Apenas Ativos
	cQuery += " AND (N3_DTBAIXA > '"+DTOS(dData)+ "' OR N3_DTBAIXA = '')"+ CRLF
	cQuery += " AND (N1_BAIXA   > '"+DTOS(dData)+ "' OR N1_BAIXA = '')"+ CRLF
EndIf

cQuery += " AND SN1.D_E_L_E_T_ = '' "+ CRLF
cQuery += " AND SN3.D_E_L_E_T_ = '' "+ CRLF
cQuery += " AND SN4.D_E_L_E_T_ = '' "+ CRLF

If !lAllFil
	cQuery += " AND N4_FILIAL "+ GetRngFil(aFiliais,"SN4",.T.,@cTmpFil)+CRLF
	aAdd(aTmpFil,cTmpFil)
EndIf

cQuery += " GROUP BY N4_FILIAL,N4_CBASE,N4_ITEM,N4_TIPO,N4_SEQREAV,N4_SEQ,N4_OCORR,N4_TIPOCNT,N4_MOTIVO,N4_DATA,N1_DESCRIC,N1_LOCAL,N1_GRUPO,N3_DINDEPR,N3_CUSTBEM,N3_PERDEPR,N3_TPDEPR,N3_HISTOR"
For nI := 1 To Len(aCpoVlN3)
	cQuery += ","+aCpoVlN3[nI]
Next nI
cQuery += CRLF
cQuery += " ORDER BY N4_FILIAL,N4_CBASE,N4_ITEM,N4_TIPO,N4_SEQREAV,N4_SEQ,N4_OCORR,N4_TIPOCNT,N4_MOTIVO"+ CRLF 

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRet,.T.,.F.)

While (cAliasRet)->(!EOF())		
	If cChaveAx != (cAliasRet)->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ)  
		cChaveAx :=(cAliasRet)->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ) 
		If lInsert
			AFR075aDad(aDados,cAliasRet,@lInsert)
		EndIf		
		For nI	:= 1 To Len(aAux)
			AFR075aRet(aAux[nI],aDados,aRet)
			lInsert:=.T.
		Next nI
		If lInsert
			AFR075aDad(aDados,cAliasRet,@lInsert)
		EndIf
		aAux 	:= {}		
	EndIf
	
	For nI := 1 To Len(aCpoVlN4)
		If (nPosAx	:= aSCan(aAux,{|aX| AllTrim(aX[1]) == AllTrim(aMoedas[nI])})) > 0
			aAux2 := aClone(aAux[nPosAx][2])
		Else
			aAdd(aAux,{aMoedas[nI],{}})
			aAux2 := {0,0,0,0}
			nPosAx:=Len(aAux)
		EndIf
		
		nValor 	:= (cAliasRet)->&(aCpoVlN4[nI])
		aAux2[1]:=(cAliasRet)->&(aCpoVlN3[nI])
		
		Do Case			
			Case (cAliasRet)->N4_OCORR == "01"
				If (cAliasRet)->N4_MOTIVO $ '13' .and. (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]	-= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	-= nValor
					aAux2[4]	-= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
				
			Case (cAliasRet)->N4_OCORR == "02"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]  	-= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	-= nValor
					aAux2[4]	-= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf

			Case (cAliasRet)->N4_OCORR == "03"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2] 	-= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	-= nValor
					aAux2[4]	-= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
				
			Case (cAliasRet)->N4_OCORR == "04"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]  	+= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
				
			Case (cAliasRet)->N4_OCORR == "05"
				If (cAliasRet)->N4_TIPOCNT == '1' 
					aAux2[2]  	+= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
				
			Case (cAliasRet)->N4_OCORR == "06"
				If (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
				
			Case (cAliasRet)->N4_OCORR == "10"
				If (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
			
			Case (cAliasRet)->N4_OCORR == "13"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]  	+= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
			
			Case (cAliasRet)->N4_OCORR == "15"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]  	-= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	-= nValor
					aAux2[4]	-= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
			
			Case (cAliasRet)->N4_OCORR == "16"
				If (cAliasRet)->N4_TIPOCNT == '1'
					aAux2[2]  	+= nValor
				ElseIf (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
			
			Case (cAliasRet)->N4_OCORR == "20"
				If (cAliasRet)->N4_TIPOCNT == '4'
					aAux2[3]	+= nValor
					aAux2[4]	+= IiF((cAliasRet)->N4_DATA >= dDataCota,nValor,0)
				EndIf
		EndCase
		aAux[nPosAx][2] := aClone(aAux2)		
	Next nI	
	(cAliasRet)->(DbSkip())
EndDo
For nI	:= 1 To Len(aAux)
	AFR075aRet(aAux[nI],aDados,aRet)
Next nI
RestArea(aArea)
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075aDadºAutor  ³Jair Ribeiro        º Data ³  11/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche array auxiliar                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075aDad(aDados,cAliasRet,lInsert)
aDados := Array(nCampos-6)
aDados[PFILIAL]    	:= (cAliasRet)->N4_FILIAL
aDados[PCBASE]     	:= (cAliasRet)->N4_CBASE
aDados[PITEM]      	:= (cAliasRet)->N4_ITEM
aDados[PTIPO]      	:= (cAliasRet)->N4_TIPO
aDados[PHISTOR]    	:= (cAliasRet)->N3_HISTOR
aDados[PSEQREAV]   	:= (cAliasRet)->N4_SEQREAV
aDados[PSEQ]       	:= (cAliasRet)->N4_SEQ
aDados[PDESCRIC]   	:= (cAliasRet)->N1_DESCRIC
aDados[PAQUISIC]   	:= (cAliasRet)->N3_DINDEPR
aDados[PLOCALIZA]	:= (cAliasRet)->N1_LOCAL   
aDados[PGRUPO]		:= (cAliasRet)->N1_GRUPO  
aDados[PCUSTBEM]	:= (cAliasRet)->N3_CUSTBEM
aDados[PPERDEPR]	:= (cAliasRet)->N3_PERDEPR
aDados[PTPDEPR]		:= (cAliasRet)->N3_TPDEPR
lInsert := .F.
Return                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFR075aRetºAutor  ³Jair Ribeiro        º Data ³  11/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche array de retorno                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFR075aRet(aAux,aDados,aRet)
Local aArea		:= GetArea()
If Len(aDados)> 0
	aAdd(aRet,Array(nCampos))
	aRet[Len(aRet),PFILIAL]   	:=  aDados[PFILIAL]
	aRet[Len(aRet),PCBASE]    	:=  aDados[PCBASE]
	aRet[Len(aRet),PITEM]     	:=  aDados[PITEM]
	aRet[Len(aRet),PTIPO]     	:=  aDados[PTIPO]
	aRet[Len(aRet),PHISTOR]    	:=  aDados[PHISTOR]
	aRet[Len(aRet),PSEQREAV]	:=  aDados[PSEQREAV]
	aRet[Len(aRet),PSEQ]     	:=  aDados[PSEQ]
	aRet[Len(aRet),PDESCRIC]  	:=  aDados[PDESCRIC]
	aRet[Len(aRet),PAQUISIC]  	:=  aDados[PAQUISIC]
	aRet[Len(aRet),PLOCALIZA] 	:=  aDados[PLOCALIZA]
	aRet[Len(aRet),PGRUPO] 		:=  aDados[PGRUPO]
	aRet[Len(aRet),PCUSTBEM] 	:=  aDados[PCUSTBEM]	
	aRet[Len(aRet),PPERDEPR]  	:=  aDados[PPERDEPR]
	aRet[Len(aRet),PTPDEPR]   	:=  aDados[PTPDEPR]	
	aRet[Len(aRet),PMOEDA]    	:= aAux[1]		
	aRet[Len(aRet),PTAXADEP]  	:= aAux[2,1]
	aRet[Len(aRet),PVORIG]    	:= aAux[2,2]
	aRet[Len(aRet),PCOTADEP]  	:= aAux[2,4]
	aRet[Len(aRet),PDEPRACM]  	:= aAux[2,3]
	aRet[Len(aRet),PVLIVROS]	:= aAux[2,2]-aAux[2,3]	
EndIf
RestArea(aArea)
Return 

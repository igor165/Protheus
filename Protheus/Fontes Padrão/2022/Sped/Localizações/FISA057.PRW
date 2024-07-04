#INCLUDE "FISA057.CH" 
#INCLUDE "PROTHEUS.CH"                                                                   
#INCLUDE "APWIZARD.CH"                                                                                                                 
#INCLUDE "FILEIO.CH"                                                                                                 

#DEFINE NBYTES_READ 40960                                                                 

#DEFINE TRANSMITIDO 			'S'
#DEFINE AUTORIZADO 			'P'
#DEFINE REJEITADO_RONDANET 	'E'
#DEFINE REJEITADO_DGI 			'M'

#DEFINE TYPE_CFE 	1
#DEFINE TYPE_RESG 	2

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ³Fisa057
Programa de transmissao da Nota Fiscal Eletronica do Uruguai

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fisa057()                         

	Local aArea     := GetArea()
	Local lRetorno  := .T.
	Local nVezes    := 0
	
	PRIVATE lBtnFiltro:= .F.
	PRIVATE cAliasMnt := ""
	PRIVATE cCondic   := ""
	PRIVATE aIndArqE  := {}	
	PRIVATE aRotina   := MenuDef()
	PRIVATE cCadastro := "Nota Fiscal Eletronica"
	Private cSerieFil := ""
	Private dDtInFil  := ""
	Private dDtEndFil := ""
	Private cTipoFil  := ""
	Private cMenTran  :=""
	Private lTransOk  := .f.
	Private cNCae   := "" 
	Private cSCae := ""
	While lRetorno
		lBtnFiltro:= .F.
	    lRetorno := Fis57Brow(nVezes==0)
	    nVezes++
	    If !lBtnFiltro
	    	Exit
	    EndIf
	
	EndDo
	RestArea(aArea)
	
	//Alivia memoria
	DelClassIntF()

Return Nil 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Brow
Cria o browse da rotina de transmissao da fatura eletronica 

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function Fis57Brow(lInit,cAlias)
	Local aPerg       := {}
	Local aCores      := {}
	Local lRetorno    := .T.
	Local lEntAtiva   := .T.
	Local lPerg 	  := .F.

	aadd(aPerg,{2,STR0002,PadR("",Len(STR0003)),{STR0004,STR0003},120,".T.",.T.,".T."})  //"Tipo de NFe"###"2-Entrada"###"1-Saída"###"2-Entrada"
	aadd(aPerg,{2,STR0005,PadR("",Len(STR0006)),{STR0007,STR0008,STR0009,STR0011},120,".T.",.T.,".T."}) //"Filtra"###"1-Autorizadas"###"2-Sem filtro"###"3-Não Autorizadas"###"4-Transmitidas"###"5-Não Transmitidas" //"Filtra"###"5-Não Transmitidas"###"1-Nao Trasmitida"###"2-Autorizada"###"3-Rejeitada"###"4-Sem Filtro"
	aadd(aPerg,{1,STR0012,PadR("",Len(SF2->F2_SERIE))	,"",".T.","01",".T.",30,.F.})	//"Serie da Nota Fiscal" //"Serie da NFE"
	aadd(aPerg,{1,STR0145,dDataBase						,""				,".T.",""	,".T."	,80	,.F.})	//"Data Emissao Inicial
	aadd(aPerg,{1,STR0146,dDataBase						,""				,".T.",""	,".T."	,80	,.F.})	//"Data Emissao Inicial
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o serviço foi configurado - Somente o Adm pode configurar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPerg := ParamBox(aPerg,"Uru-NFe",,,,,,,,"FISA057",.T.,.T.)
	
	
	cAliasMnt := IIF(SubStr(MV_PAR01,1,1)=="1","SF2","SF1")
	cTipoFil  := MV_PAR01
	cSerieFil := MV_PAR03
	dDtInFil  := MV_PAR04
	dDtEndFil := MV_PAR05
	
	If lEntAtiva 
		If lPerg 
			If SubStr(MV_PAR01,1,1) == "1"
				aCores    :={{"F2_FLFTEX==' '",'BR_VERMELHO' },;			//NF não transmitida
							 {"F2_FLFTEX=='S'",'BR_AMARELO'},;				//NF Transmitida
							 {"F2_FLFTEX=='P'",'BR_VERDE'},;				//NF Autorizada
							 {"F2_FLFTEX=='E'",'BR_AZUL'},;					//NF Rejeitado RondaNet
							 {"F2_FLFTEX=='M'",'BR_PRETO'}}					//NF Rejeitado DGI
								  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a Filtragem                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				cCondic := "F2_FILIAL =='"+xFilial("SF2")+"' "
				cCondic += ".AND. F2_SERIE =='"+MV_PAR03+"'
				cCondic += ".AND. F2_ESPECIE <> 'NCP' "
	
			
				If !Empty(MV_PAR03)
					cCondic += ".AND.F2_SERIE=='"+MV_PAR03+"'"
				EndIf
				If SubStr(MV_PAR02,1,1) == "1" 			//"1-n Transmitida"
	    				cCondic += ".AND. F2_FLFTEX$' ' "
				ElseIf SubStr(MV_PAR02,1,1) == "2" 		//"2-Transmitida"  
					cCondic += ".AND. F2_FLFTEX$'STP' "
				ElseIf SubStr(MV_PAR02,1,1) == "3" 		//"Rejeitada"
					cCondic += ".AND. F2_FLFTEX$'E' "                                              	
				EndIf			
				
				//Filtra por data de emissao
				If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
					cCondic += ".AND. F2_EMISSAO >= dDtInFil "
					cCondic += ".AND. F2_EMISSAO <= dDtEndFil "
				EndIf 
				If ExistBlock("FIS57FILT")
					cCondic := ExecBlock("FIS57FILT",.F.,.F.)
				EndIf					
				FilBrowse("SF2",@aIndArqE,@cCondic)

				mBrowse( 6, 1,22,75,"SF2",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Restaura a integridade da rotina                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF2")
				RetIndex("SF2")
				dbClearFilter()
				aEval(aIndArqE,{|x| Ferase(x[1]+OrdBagExt())})			
			Else
				aCores    :={{"F1_FLFTEX==' '",'BR_VERMELHO' },;			//NF não transmitida
							 {"F1_FLFTEX=='S'",'BR_AMARELO'},;				//NF Transmitida
							 {"F1_FLFTEX=='P'",'BR_VERDE'},;				//NF Autorizada
							 {"F1_FLFTEX=='E'",'BR_AZUL'},;					//NF Rejeitado RondaNet
							 {"F1_FLFTEX=='M'",'BR_PRETO'}}					//NF Rejeitado DGI
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a Filtragem                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCondic := "F1_FILIAL=='"+xFilial("SF1")+"' .AND. "
				cCondic += "F1_SERIE =='"+MV_PAR03+"' .AND. " 
				cCondic += "F1_FORMUL =='S'"
				
				If !Empty(MV_PAR03)
					cCondic += ".AND.F1_SERIE=='"+MV_PAR03+"'"
				EndIf
				If SubStr(MV_PAR02,1,1) == "1" 			//"1-n Transmitida"
					cCondic += ".AND. F1_FLFTEX$' ' "
				ElseIf SubStr(MV_PAR02,1,1) == "2" 		//"2-Transmitida"   
					cCondic += ".AND. F1_FLFTEX$'STP' "
				ElseIf SubStr(MV_PAR02,1,1) == "3" 		//"3-Rejeitada"
					cCondic += ".AND. F1_FLFTEX$'E' "              			
				EndIf			
				//Filtra por data de emissao
				If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
					cCondic += ".AND. F1_EMISSAO >= dDtInFil "
					cCondic += ".AND. F1_EMISSAO <= dDtEndFil "
				EndIf



				If ExistBlock("FIS57FILT")
					cCondic := ExecBlock("FIS57FILT",.F.,.F.)
				EndIf
				FilBrowse("SF1",@aIndArqE,@cCondic)
				mBrowse( 6, 1,22,75,"SF1",,,,,,aCores,/*cTopFun*/,/*cBotFun*/,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,.F.,)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Restaura a integridade da rotina                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF1")
				RetIndex("SF1")
				dbClearFilter()
				aEval(aIndArqE,{|x| Ferase(x[1]+OrdBagExt())})			
			EndIf			
		Else
			lRetorno := .F.
		EndIf
	Else
		HelProg(,"FISTRFNFe")
		lRetorno := .F.
	EndIf
Return(lRetorno)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Leg
Demonstra a legenda das cores da mbrowse

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57Leg()
Local aLegenda := {}  
	aCores    :={{"F1_FLFTEX==' '",'BR_VERMELHO' },;			//NF não transmitida
				 {"F1_FLFTEX=='S'",'BR_AMARELO'},;				//NF Transmitida
				 {"F1_FLFTEX=='P'",'BR_VERDE'},;				//NF Autorizada
				 {"F1_FLFTEX=='E'",'BR_AZUL'},;					//NF Rejeitado RondaNet
				 {"F1_FLFTEX=='M'",'BR_PRETO'}}					//NF Rejeitado DGI

	Aadd(aLegenda, {"BR_VERMELHO"  	,STR0014})  //"NF Nao transmitida"
	Aadd(aLegenda, {"BR_AMARELO"   	,STR0013})  //"NF Transmitida"
	Aadd(aLegenda, {"BR_VERDE"    	,"Nota Autorizada"})  //"NF Transmitida"
	Aadd(aLegenda, {"BR_AZUL"   	,"Rejeitado RondaNet"})
	Aadd(aLegenda, {"BR_PRETO"  	,"Rejeitado DGI"})
	BrwLegenda(cCadastro,STR0016,aLegenda)  //"Legenda"

Return(.T.)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional 

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRot := {}
	
	aRot := {{STR0017 ,"PesqBrw"		    ,0,1},;  //"Pesquisa"
			{STR0019  ,"Fis57Rem"	        ,0,2},;  //"Transmissão"
			{STR0020  ,"Fis57Mon(cAliasMnt)",0,3},;  //"Monitor"
			{STR0127  ,"Fis57Sin"			,0,6},;  //"Sincronizar"
			{STR0021  ,"Fis57doc"       	,0,2},;  //"Visualiza Doc."
            {STR0138  ,"Fis57imp"       	,0,2},;  //"Visualizar PDF"
			{STR0016  ,"Fis57Leg"       	,0,3}}   //"Legenda"
					
	If ExistBlock("FIS57MENU")
		aRot := ExecBlock("FIS57MENU",.F.,.F.,{aRot})
	EndIf
	
Return(aRot)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Rem
Faz a remessa das notas fiscais eletronicas 

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57Rem(cSerie,cNotaIni,cNotaFim,lCTe,lRetorno)

	Local aArea       := GetArea()
	Local aPerg       := {}
	Local aParam      := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
	Local aTexto      := {}
	Local cRetorno    := ""
	Local cIdEnt      := ""
	Local cModalidade := ""
	Local cAmbiente   := ""
	Local cVersao     := ""
	Local cVersaoCTe  := ""
	Local cVersaoDpec := ""
	Local cMonitorSEF := ""
	Local cSugestao   := ""
	Local nX          := 0
	Local lOk         := .T.
	Local oWs
	Local oWizard
	Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"NFE"
	Default lCTe      := .F.
	Default lRetorno  := .F.

	MV_PAR01 := aParam[01] := PadR(ParamLoad(cParNfeRem,aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cParNfeRem,aPerg,2,aParam[02]),Len(SF2->F2_DOC))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cParNfeRem,aPerg,3,aParam[03]),Len(SF2->F2_DOC))

	aadd(aPerg,{1,STR0078,aParam[01],"",".T.","",".T.",30,.F.})
	aadd(aPerg,{1,STR0079,aParam[02],"",".T.","",".T.",50,.T.})
	aadd(aPerg,{1,STR0080,aParam[03],"",".T.","",".T.",50,.T.}) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Default cAmbiente :=""
	If (lOk == .T. .or. lOk == Nil) //.And. (!lCTe))
		aadd(aTexto,{})
		aTexto[1] := "Esta rutina tem cómo objetivo generar el xml de envio a transmisión de la Factura Eletronica Uruguay"	
		If !Empty(cSugestao)
			aTexto[1] += CRLF
			aTexto[1] += cSugestao
			aTexto[1] += CRLF
		EndIf			
		aTexto[1] += cMonitorSEF
		
		aadd(aTexto,{})
	
		DEFINE WIZARD oWizard ;
			TITLE STR0085;
			HEADER STR0086;
			MESSAGE STR0087;
			TEXT aTexto[1] ;
			NEXT {|| .T.} ;
			FINISH {||.T.}
	
		CREATE PANEL oWizard  ;
			HEADER STR0088 ;
			MESSAGE ""	;
			BACK {|| .T.} ;
			NEXT {|| ParamSave(cParNfeRem,aPerg,"1"),Processa({|lEnd| cRetorno := Fis57Gera(aArea[1],aParam[1],aParam[2],aParam[3],.F.)}),aTexto[02]:= cRetorno,.T.} ;
			PANEL
	    ParamBox(aPerg,"NFEe - NFe",@aParam,,,,,,oWizard:oMPanel[2],cParNfeRem,.T.,.T.)
	
		CREATE PANEL oWizard  ;
			HEADER STR0088;
			MESSAGE "";
			BACK {|| .T.} ;
			FINISH {|| .T.} ;
			PANEL
		@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
		ACTIVATE WIZARD oWizard CENTERED
	EndIf
	lRetorno := lOk	

RestArea(aArea)
Return
            	
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Gera
Rotina de remessa da Nota fiscal eletronica

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57Gera(cAlias, cSerie, cNotaIni, cNotaFim, lAuto)

Local aArea     := GetArea()
Local aNotas    := {}
Local aRetNotas := {}
Local cRetorno  := ""
Local cAliasSF2 := "SF2"
Local cAliasSF1 := "SF1"
Local cWhere    := ""
Local lQuery    := .F.
Local lRetorno  := .T.
Local nX        := 0
Local nY        := 0
Local nI        := 0
Local nNFes     := 0
Local nXmlSize  := 0
Local dDataIni  := Date()
Local cHoraIni  := Time()
Local cNfCup	:= "CF/SERIE:"									// Identifica que eh Nf sobre Cup
Local aNfCup	:= {{"",CTOD("  /  /  "),"","","","","",""}}	// Array com as Notas sobre cupom
Local aXML      := {}
Local nPosAux 	:= 0											// Posicao auxiliar
Local ctipo		:=""
Local nObj		:=0
Local cIdNF		:=	""
Local lPrim		:= .T.
Local cAliasMnt2	:= ""         
Local cWsVersao		:= GetNewPar("MV_URUVWS","3.1")	//Versao 2.0 (antiga) ou Versao 3.1 (nova)

Default lAuto	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais do dia                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipo:=IIf(cAlias=="SF2","1","2")
If cTipo=="2"
    If !lAuto
		ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€
	//³Tratamento para transmissao de notas de entrada sem SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€
	dbSelectArea("SF1")
	dbSetOrder(1)
	#IFDEF TOP
		cWhere := "%( (SF1.F1_FORMUL='S' ) Or (SF1.F1_FORMUL='N' ) )%"
		cAliasSF1 := GetNextAlias()
		lQuery    := .T.
		BeginSql Alias cAliasSF1
			
		COLUMN F1_EMISSAO AS DATE
					
		SELECT	F1_FILIAL,F1_EMISSAO,F1_FORMUL,
				F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,
				F1_ESPECIE,F1_CAEE,F1_FLFTEX,F1_ESPECIE,
				F1_TIPO	FROM %Table:SF1% SF1
				WHERE SF1.F1_FILIAL = %xFilial:SF2% AND
				SF1.F1_SERIE = %Exp:cSerie% AND 
				SF1.F1_DOC >= %Exp:cNotaIni% AND 
				SF1.F1_DOC <= %Exp:cNotaFim% AND 
				%Exp:cWhere% AND SF1.%notdel%   
		EndSql
		cWhere := ".T."	
	#ELSE
		MsSeek(xFilial("SF1")+cNotaIni+cSerie,.T.)
	#ENDIF
   	cWhere := "!(F1_FLFTEX$'S|P')"

	While !Eof() .And. xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And.;
		(cAliasSF1)->F1_SERIE == cSerie .And.;
		(cAliasSF1)->F1_DOC >= cNotaIni .And.;
		(cAliasSF1)->F1_DOC <= cNotaFim
	
		dbSelectArea(cAliasSF1)

		If aScan(aNotas,{|x| x[3]+x[4]+x[7]==(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_ESPECIE})==0 //.And. (cAliasSF1)->F1_STATUS='C'
						
			If !lAuto
				IncProc("(1/2) "+STR0024+(cAliasSF1)->F1_DOC)  //"Preparando nota: "
			EndIf
			If  &cWhere
				aadd(aNotas,{})	
				nX := Len(aNotas)
				aadd(aNotas[nX],"0")
				aadd(aNotas[nX],(cAliasSF1)->F1_EMISSAO)
				aadd(aNotas[nX],(cAliasSF1)->F1_SERIE)
				aadd(aNotas[nX],(cAliasSF1)->F1_DOC)
				aadd(aNotas[nX],(cAliasSF1)->F1_FORNECE)
				aadd(aNotas[nX],(cAliasSF1)->F1_LOJA)
				aadd(aNotas[nX],(cAliasSF1)->F1_ESPECIE)
				aadd(aNotas[nX],(cAliasSF1)->F1_TIPO)
			EndIf
		EndIf		
		dbSelectArea(cAliasSF1)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF1)
		dbCloseArea()
	EndIf
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€
	//³Tratamento para transmissao de notas de entrada sem SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€	
	dbSelectArea("SF2")
	dbSetOrder(1)
	#IFDEF TOP
		cWhere := "%((SF2.F2_FORMUL='S') OR (SF2.F2_FORMUL='N' ))%"		
		cAliasSF2 := GetNextAlias()
		lQuery    := .T.
		BeginSql Alias cAliasSF2
			
		COLUMN F2_EMISSAO AS DATE
					
		SELECT	F2_FILIAL,F2_EMISSAO,F2_FORMUL,
				F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,
				F2_ESPECIE	,F2_CAEE,F2_FLFTEX,F2_ESPECIE, 
				F2_TIPO	FROM %Table:SF2% SF2
				WHERE SF2.F2_FILIAL = %xFilial:SF1% AND
				SF2.F2_SERIE = %Exp:cSerie% AND 
				SF2.F2_DOC >= %Exp:cNotaIni% AND 
				SF2.F2_DOC <= %Exp:cNotaFim% AND 
				%Exp:cWhere% AND SF2.%notdel%
		EndSql
		cWhere := ".T."	
	#ELSE
		MsSeek(xFilial("SF2")+cNotaIni+cSerie,.T.)
	#ENDIF
	cWhere := "!(F2_FLFTEX$'S|P')"
	
	While !Eof() .And. xFilial("SF2") == (cAliasSF2)->F2_FILIAL .And.;
		Alltrim( (cAliasSF2)->F2_SERIE ) == Alltrim(cSerie) .And.;
		Alltrim( (cAliasSF2)->F2_DOC   ) >= Alltrim(cNotaIni) .And.;
		Alltrim( (cAliasSF2)->F2_DOC   ) <= Alltrim(cNotaFim)
	
		dbSelectArea(cAliasSF2)
		If aScan(aNotas,{|x| x[3]+x[4]+x[7]==(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_ESPECIE})==0 	
			
			If !lAuto
				IncProc("(1/2) "+STR0024+(cAliasSF2)->F2_DOC)  //"Preparando nota: "
			EndIf
			If  &cWhere
				aadd(aNotas,{})	
				nX := Len(aNotas)
	   			aadd(aNotas[nX],"0")
				aadd(aNotas[nX],(cAliasSF2)->F2_EMISSAO)
				aadd(aNotas[nX],(cAliasSF2)->F2_SERIE)
				aadd(aNotas[nX],(cAliasSF2)->F2_DOC)
				aadd(aNotas[nX],(cAliasSF2)->F2_CLIENTE)
				aadd(aNotas[nX],(cAliasSF2)->F2_LOJA)    
				aadd(aNotas[nX],(cAliasSF2)->F2_ESPECIE)
				aadd(aNotas[nX],(cAliasSF2)->F2_TIPO)
			EndIf
  		EndIf		
		dbSelectArea(cAliasSF2)
		dbSkip()	
	EndDo
	If lQuery
		dbSelectArea(cAliasSF2)
		dbCloseArea()
	EndIf
EndIf	
	
For nX := 1 To Len(aNotas)
	If Substr(Alltrim(aNotas[nX,3]),1,1) == 'A'
		cIdNF	:=	'1'
	ElseIf	Substr(Alltrim(aNotas[nX,3]),1,1) == 'B'
		cIdNF	:=	'2'
	ElseIf	Substr(Alltrim(aNotas[nX,3]),1,1) == 'C'
		cIdNF	:=	'3'
	ElseIf	Substr(Alltrim(aNotas[nX,3]),1,1) == 'E'
		cIdNF	:=	'4'
	ElseIf	Substr(Alltrim(aNotas[nX,3]),1,1) == 'M'
		cIdNF	:=	'5'
	Else
		cIdNF	:=	'9'
	Endif
	If aNotas[nX,8] == 'D'
		cIdNF	+=	'21'
	ElseIf aNotas[nX,8] == 'C'
		cIdNF	+=	'20'
	Else			
		cIdNF	+=	'19'
	Endif              
	cIdNF	+= aNotas[nX,4]
    
   //------------------------------------------------------------------------------------
   // Atribui o valor na variavel cAliasMnt2 devido que a variavel cAliasMnt eh Private
   // e como nao realizarei a chamada da funcao pai Fisa057(), por isso declarei esta 
   	// variavel e passando na funcao Clean057Fil e Set057Fil
	//------------------------------------------------------------------------------------
	If !lAuto
		If cAlias == "SF2"
			cAliasMnt2	:= "SF2"
		Else
			cAliasMnt2	:= "SF1"
		EndIf
		
		//Restaura a integridade da tabela SF1/SF2 para executar a funcao de montagem do XML
		Clean057Fil(cAliasMnt2)
    EndIf
    //Monta o XML da Nota a ser transmitida	
	aXML := ExecBlock("FISA057XML",.F.,.F.,{cTipo,aNotas[nX][3],aNotas[nX][4],aNotas[nX][5],aNotas[nX][6]})
	
	If !lAuto
		Set057Fil(cAliasMnt2)
	EndIf
			
	//Gera o arquivo no diretorio de transmissão
	lTransOk:=.F.
	cMenTran :=""
	lRetorno := F057Trans(aXML,TYPE_CFE,lAuto)
	
	 If cWsVersao $ "3.1"
		If !Empty(cNCae) 
			If ExistBlock("FIS57NCA")
				cNCae:=ExecBlock("FIS57NCA",.F.,.F.,{cNCae})
			Else								
				cNCae:=PADL(cNCae,TamSX3("F2_CAEE")[1],"0")
			EndIf
		EndIf  		
	  		//Atualiza a nota como Transmitida
		If cTipo=="1"
			dbSelectArea('SF2')
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial('SF2')+aNotas[nX][4]+aNotas[nX][3]+aNotas[nX][5]+aNotas[nX][6]))
				RecLock('SF2',.F.)
				If lTransOk
					SF2->F2_FLFTEX := TRANSMITIDO //AUTORIZADO
				Else				
					SF2->F2_FLFTEX := REJEITADO_RONDANET //REJEITADO_DGI
				EndIf
				If SF2->(FieldPos("F2_SITNOTA"))>0
					SF2->F2_SITNOTA:= cMenTran
				EndIf					
		
				SF2->F2_SERCAE := cSCae
				SF2->F2_CAEE 	:= cNCae				
	
	
				SF2->(msUnlock())
			EndIf
		Else
			dbSelectArea('SF1')
			SF1->(dbSetOrder(1))
			If SF1->(dbSeek(xFilial('SF1')+aNotas[nX][4]+aNotas[nX][3]+aNotas[nX][5]+aNotas[nX][6]))
				RecLock('SF1',.F.)
				If lTransOk
					SF1->F1_FLFTEX := TRANSMITIDO //AUTORIZADO
				Else				
					SF1->F1_FLFTEX := REJEITADO_RONDANET //REJEITADO_DGI
				EndIf
				If SF1->(FieldPos("F1_SITNOTA"))>0
					SF1->F1_SITNOTA:= cMenTran					
				EndIf	
				SF1->F1_SERCAE := cSCae
				SF1->F1_CAEE 	:= cNCae				
				SF1->(msUnlock())
			EndIf
		EndIf		
		nPosAux := Ascan( aNfCup,{|x| x[7] == aNotas[nX][3] .AND. x[8] == aNotas[nX][4]})  
		nNFes++	  
	  	If !lTransOk
	  		//Se deu erro em uma transmissão, aborta o restante
	  		exit
	  	EndIf  
    EndIf
Next nX                 

If lRetorno
	cRetorno := STR0034+AllTrim(Str(nNFes,18))+STR0035+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "		
Else
	cRetorno := "Error en transmisión" 
EndIf

RestArea(aArea)

Return(cRetorno) 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F57Trans()
Realiza a transmissão do documento para o RondaNet
O mesmo pode ser feito por meio de WS ou via integração por arquivos, dependendo
do parametro MV_RONDATP

@author  Microsiga Protheus
@version P10
@since 	 16/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F057Trans(aXML, nTypeDoc, lAuto)
	Local lIntByFile 	:= GetNewPar("MV_RONDATP",.T.)	// .T. = gera arquivo txt / .F. = webservice
	Local cWsCustId		:= GetNewPar("MV_URUSUCU","1")
	Local cWsUser			:= GetNewPar("MV_URUUSER","")
	Local cWsPass			:= GetNewPar("MV_URUPASW","")
	Local cWsVersao		:= GetNewPar("MV_URUVWS","3.1")	//Versao 2.0 (antiga) ou Versao 3.1 (nova)
	Local oWsRonda 		:= Nil
	Local lRet			:= .T.
	Local lErro			:= .F.
	Local oRet 			:= Nil
	Local cAviso        := ''
	Local cWarning		:= ''
	
	Local cSvcError := ""
	Local cSoapFCode := ""
	Local cSoapFDescr := ""
	Local cMensagem := ""

	
	Default aXML := {}
	Default nTypeDoc := 0
	Default lAuto	:= .F.
	cNCae   := "" 
	cSCae := ""
				              
	If (cWsVersao $ "2.0" .And. Len(aXML) >= 0  )       .OR. ( cWsVersao $ "3.1" .and.len(aXML)>=6    )
		If lIntByFile
			If nTypeDoc == TYPE_CFE
				//Gera arquivo de NFe
				lRet := F57GerArq(aXML)
			Else
			    //Gera arquivo de resguardo
			    lRet := F85GerArq(aXML)
			EndIF
			//Conout("[LOGNFE]Transmissao por arquivo"+CRLF)
		Else
		    //Conout("[LOGNFE]Transmissao por webService"+CRLF)		    
		    //Conout("[LOGNFE]XML Gerado - " + CRLF + aXML[1])
		    //Instancia o WS RondaNet
		    If !Empty(cWsCustId) .and. !Empty(cWsUser) .and. !Empty(cWsPass)
			   
			   //----------------------------------------------------------------
			   // Verifica qual versao se trata e chama o metodo correto
			   //----------------------------------------------------------------
			   If cWsVersao $ "2.0"
			   		MsgInfo(STR0148)
			   		lRet := .F.
			   ElseIf cWsVersao $ "3.1"
			   		oWsRonda := WSRondanetService():New()
			   		oWsRonda:_URL 			:= GetNewPar("MV_IPWSRON","")
					oWsRonda:crutEmisor 		:= Alltrim(SM0->M0_CGC)
					oWsRonda:calias			:= aXML[6]
					oWsRonda:cusuario 		:= cWsUser
					oWsRonda:cpassword 		:= cWsPass
					oWsRonda:ccomprobante	:= aXML[1]
			   	EndIf
				
				//----------------------------------------------------------------
				// Versao 3.0 layout Rondanet - chamada metodo enviarComprobante
				//----------------------------------------------------------------	
				If cWsVersao $ "3.1"
				
					If oWsRonda:enviarComprobante()
						//Conout("[LOGNFE]Return da requisição - " + oWsRonda:cReturn +CRLF)
						If ValType(oWsRonda:cReturn) == "C" .and. !Empty(oWsRonda:cReturn)
							oRet := XMLParser(oWsRonda:cReturn,'_',@cAviso,@cWarning)
							If oRet ==Nil
								oRet:= XMLParser(EncodeUtf8(oWsRonda:cReturn),'_',@cAviso,@cWarning)
							EndIf
							If Empty(cAviso) .and. Empty(cWarning)
								If oRet:_RESPUESTA_WS:_CODIGO:TEXT == '0'
									lRet := .T.
									lTransOk:=.T.   
									cMenTran:= oRet:_RESPUESTA_WS:_DESCRIPCION:TEXT
									cNCae    :=  oRet:_RESPUESTA_WS:_NUMERO:TEXT 
									cSCae := oRet:_RESPUESTA_WS:_SERIE:TEXT 
								Else 
									lRet := .F.
									If lAuto
										Conout(oRet:_RESPUESTA_WS:_DESCRIPCION:TEXT)
									Else
										MsgInfo(oRet:_RESPUESTA_WS:_DESCRIPCION:TEXT)
									EndIf
									cNCae    := " "  
									cSCae := " "
								EndIf
							EndIf
						Else
							If lAuto
								Conout('Retorno não esperado pelo WS Rondanet')
							Else
								MsgStop('Retorno não esperado pelo WS Rondanet')
							EndIf
						EndIf
					Else
						lErro := .T.
					EndIf
				EndIf
				
				//--------------------------------------------------------------------------------
				// Se houver erro na chamada dos metodos tanto na versao 2.0 ou 3.0 entrara aqui
				//--------------------------------------------------------------------------------
				If lErro
					lRet	:= .F.
			  		cSvcError 	:= GetWSCError()
				  	If Left(cSvcError, 9) == "WSCERR048"
				   		cSoapFCode 	:= AllTrim(SubStr(GetWSCError(3), 1, At(":", GetWSCError(3)) - 1))
			   			cSoapFDescr := AllTrim(SubStr(GetWSCError(3), At(":", GetWSCError(3)) + 1, Len(GetWSCError(3))))
				   		cMensagem 	:= Time() + " - Erro na consulta (WS3 - Método PostComprobante: " + cSoapFDescr + " -> " + cSoapFCode
				  	Else
				   		cMensagem := Time() + " - " + "Sem comunicação com o webservice : " + If(oWsRonda:_URL <> Nil, oWsRonda:_URL, "URL Não declarada em MV_IPWSRON")
			  		EndIf
			  		If lAuto
			  			Conout("TOTVS", cMensagem + " " + cSvcError, {"OK"}, 3)
			  		Else	
			  			Aviso("TOTVS", cMensagem + " " + cSvcError, {"OK"}, 3)
			  		EndIf
				EndIf
			Else
			    lRet := .F.
			    If lAuto
			    	MsgInfo('Usuario/Senha de serviço Web não configurados - MV_URUUSER/MV_URUPASW')
			    Else
			    	MsgInfo('Usuario/Senha de serviço Web não configurados - MV_URUUSER/MV_URUPASW')
			    EndIf
			EndIf
		EndIf
	Else
		If ( cWsVersao $ "3.1" .and.len(aXML)<6    )        
	 		MsgInfo('Verifique el Rdmake de generacion do archivo XML.')
	 	End
	EndIf
Return lRet
                                                                        
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F57GerArq
Gera o arquivo xml 

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function F57GerArq(aDadosXML) 
	Local cDirArq  := IIF(aDadosXML[2],GetNewPar("MV_AENVTKM"),GetNewPar("MV_AENVIAR"))
	Local cXML     := aDadosXML[1]
	Local cArqDest := ""
	Local nHandle  := 0
	Local lGerou   := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aDados[1] = String do xml (caracter)            ³
	//³aDados[2] = Tk menores (lógico)                 ³
	//³aDados[3] = Codigo da DGI (caracter)            ³
	//³aDados[4] = Serie (caracter)                    ³
	//³aDados[5] = Numero do Comprovante CFE (caracter)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do nome do arquivo conforme a DGI                  ³
	//³                                                           ³
	//³Si numera el el cliente: nnnAAmmmmmmmGGG.xxx               ³
	//³nnn = Cod DGI de Tipo de CFE                               ³
	//³AA = Nro de Serie                                          ³
	//³mmmmmmm = Nro de CFE                                       ³
	//³xxx = xml para formato DGI o txt para formatos Rondanet    ³
	//³GGG = identificador del generador de comprobantes,         ³
	//³para cuando hay mas de un ERP/sistema generando            ³
	//³comprobantes (puede ser de 1 a 3 caracteres alfanuméricos).³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	cArqDest := cDirArq+aDadosXML[3]+lower(Alltrim(aDadosXML[4]))+aDadosXML[5]+".xml" 
	nHandle := FCreate(cArqDest,,,.F.,3) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se é possível criar o arquivo, ³
	//³caso contrário apresenta os erros       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If nHandle <> -1   
		FWrite(nHandle,cXml)
		FClose(nHandle) 
		lGerou := .T.
	Else 	                                                                 
		Alert('Error al crear archivo:' + Alltrim(Str(Ferror())))        
		lGerou := .F.
	EndIf    

Return lGerou

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57doc
Botao para visualizar documentos de saida

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57doc(cAlias)
Local cperg1:= MV_PAR01
Local cperg2:= MV_PAR02
Local cperg3:= MV_PAR03		
Local cperg4:= MV_PAR04
Local cperg5:= MV_PAR05
Local ntpdoc:=51	
//Destroi o filtro da SF2
Clean057Fil(cAlias)
	
//Abre o doc
If cAlias == "SF2"
 	If AllTrim(SF2->F2_ESPECIE)=="RFN"
 		LocxNf(50,,,2,"ARGNFE",,2)
 	Else
 		LocxNf(Iif(SF2->F2_TIPO=="N",1,2),,,2,"ARGNFE",,2)
 	EndIf
ElseIf cAlias == "SF1"                
 	If AllTrim(SF1->F1_ESPECIE)=="RFD"
 		LocxNf(ntpdoc,,,2,"ARGNFE",,2)
 	Else
 		LocxNf(4,,,2,"ARGNFE",,2)	        
 	EndIf
EndIf 
	
//Reconstroi o filtro
MV_PAR01 := cperg1 
MV_PAR02 := cperg2
MV_PAR03 := cperg3
MV_PAR04 := cperg4
MV_PAR05 := cperg5
Set057Fil(cAlias)
	
Return
        
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Sin
Sincroniza dados com o aplicativo RondaNet de acordo com o modelo de integracao utilizado

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57Sin( lAuto, cSerie, cTipoFil )

Local lIntByFile 	:= GetNewPar("MV_RONDATP",.T.)
Local cSincro := "sincf057.lck"
Local nHandle := 0
Local cAlias := Alias()
Local aArea := (cAlias)->(GetArea())
	
Default lAuto	:= .F.
Default cSerie	:= ""
Default cTipoFil	:= ""   
If valType(cserie)<>"C"
	cSerie	:=  Iif(cAliasMnt=="SF2",F2_SERIE,F1_SERIE)
EndIf
	
If valType(lAuto)<>"L"
	lAuto	:= .F.
EndIf
	
If valType(ctipofil)<>"C"   .Or. !(ctipofil$"12")
	ctipofil	:= Iif(cAliasMnt=="SF2","1","2")
EndIf
	
	
cSincro := "autonfesinc" + cEmpAnt + cFilAnt + cSerie + ".lck"
	//Cria lock no semaforo para evitar mais de uma sincronizacao simultanea
nHandle := F057Lock(cSincro,.F.)	
If nHandle <> -1
	If lIntByFile		
		//Modelo de integracao baseado na troca de arquivos
		MsgRun( STR0139 ,, {||	SincByFile() } )
	Else
		//Modelo de integracao baseado em arquitetura WebServices		
		If lAuto
			SincByWs( lAuto, cSerie, cTipoFil )
		
			autoNfeMsg( "Finalizando o processo principal de Sincronismo" + IIf(cTipoFil == "1", " - Nota de Saida"," - Nota de Entrada"), .T., cEmpAnt, cFilAnt, cSerie , "4")
		Else
			MsgRun( STR0139 ,, {||	SincByWs(.F. ,cSerie,ctipofil) } )
		EndIf
	EndIf
Else 
	MsgAlert(STR0144)
Endif
	
	//Libera o lock no semaforo	
F057Lock(cSincro,.T.)	
    
   	//Alivia memoria
DelClassIntF()
      
RestArea(aArea)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SincByWs
Realiza a sincronizacao de documentos por meio do WebServices RondaNet

@author  Cesar Bianchi
@version P10
@since 	 17/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SincByWs( lAuto, cSerieFil, cTipoFil )
Local aArea			:= (Alias())->(GetArea())
Local cQuery 		:= ""
Local cDescRej		:= ""
Local oWsRonda		:= Nil
Local cSerCae		:= ""
Local cNroCae		:= ""	
Local cArq64		:= ""
Local cFailMsg		:= ""
Local cPulaLin		:= chr(13) + chr(10)
Local cWsUser			:= GetNewPar("MV_URUUSER","")
Local cWsPass			:= GetNewPar("MV_URUPASW","")
Local cWsVersao		:= GetNewPar("MV_URUVWS","3.1")		//Versao 2.0 (antiga) ou Versao 3.1 (nova)
Local cProcName		:= "Sincronismo"
Local cProcesso		:= "4"
Local nDias 			:= 60 // Tratamento para performance da query, monitorar apenas 60 dias antes da data-base
Local dDatabase		:= Date()
Local dDatafil		:= SToD ("  /  /  ")
Local lAutoriz	:=.F.
Local cTipoCFE:=""
Local cSCae	:= ""
Local cNCae	:= ""	

Default lAuto		:= .F.
Default cSerieFil	:= ""
	
If lAuto	
		//----------------------------------------------
		// Calcula a data inicio e final
		//----------------------------------------------
	dDatafil := (dDataBase-nDias) 	//Data atual - 60 dias
	dDtInFil := dDatafil				//Data inicio
	dDtEndFil := dDatabase			//Data fim		
	autoNfeMsg( "Iniciando o processo principal de " + cProcName, .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso) 
EndIf

dbSelectArea('SF1')
dbSelectArea('SF2')
If FindFunction('U_RFatC01')			
                          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os documentos pendentes de processamento de acordo com tipo escolhido (entrada ou saida) e as datas de emissao preenchidas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cTipoFil,1,1) == "1"
		If lAuto
			autoNfeMsg( "ETAPA 1 - Consulta nota de Saida " + cProcName, .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso)
		EndIf 
		cQuery += "SELECT SF2.F2_SERIE SERIE, SF2.F2_DOC DOC, SF2.F2_SERCAE SERCAE, SF2.F2_CAEE NROCAE, SF2.F2_CODDOC CODDOC, "
		cQuery += " SF2.F2_ARQPDF NF_PDF, SF2.F2_FLFTEX STAT, SF2.R_E_C_N_O_ RECN, 'SAIDA' AS TYPE_NF "
		cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "'"
		cQuery += "		AND SF2.F2_SERIE = '" + cSerieFil + "'"
		cQuery += "		AND SF2.F2_CODDOC <> ' ' "

		If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
			cQuery += "		AND SF2.F2_EMISSAO BETWEEN '" + DTOS(dDtInFil) + "' AND '" + DTOS(dDtEndFil) + "'"
		EndIf
		cQuery += " 	AND (SF2.F2_FLFTEX = '" + TRANSMITIDO + "' OR SF2.F2_FLFTEX = '" + AUTORIZADO + "')"
		cQuery += " 	AND SF2.D_E_L_E_T_ = ' ' "
		If lAuto
			autoNfeMsg( "Query do processo de " + cProcName + ": " + allTrim( cQuery ) )
		EndIf
	Else
		If lAuto
			autoNfeMsg( "ETAPA 2 - Consulta nota de Entrada " + cProcName, .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso)
		EndIf
		cQuery := "SELECT SF1.F1_SERIE SERIE, SF1.F1_DOC DOC, SF1.F1_SERCAE SERCAE, SF1.F1_CAEE NROCAE, SF1.F1_CODDOC CODDOC, "
		cQuery += " SF1.F1_ARQPDF NF_PDF, SF1.F1_FLFTEX STAT, SF1.R_E_C_N_O_ RECN, 'ENTRADA' AS TYPE_NF " 
		cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
		cQuery += " WHERE SF1.F1_FILIAL = '" + xFilial('SF1') + "'"
		cQuery += "		AND SF1.F1_SERIE = '" + cSerieFil + "'"
		cQuery += "		AND SF1.F1_CODDOC <> ' ' "
	
		If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
			cQuery += "		AND SF1.F1_EMISSAO BETWEEN '" + DTOS(dDtInFil) + "' AND '" + DTOS(dDtEndFil) + "'"			
		EndIf	
		cQuery += " 	AND (SF1.F1_FLFTEX = '" + TRANSMITIDO + "' OR SF1.F1_FLFTEX = '" + AUTORIZADO  + "')"
		cQuery += " 	AND SF1.D_E_L_E_T_ = ' ' "
		If lAuto
			autoNfeMsg( "Query do processo de " + cProcName  + ": " + allTrim( cQuery ) )
		EndIf
	EndIf
	iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRY", .F., .T.)
	While QRY->(!Eof())
         lAutoriz:=.F.   	  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³1* - Verifica se possui CAE. Se nao tiver, Coloca o numero e a serie do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	 lAtualiza:=.t.    
		    If Empty(QRY->SERCAE) .or. Empty(QRY->NROCAE)
			    			 		
				cSerCae := Alltrim(QRY->SERIE)
	    		cNroCae := QRY->DOC
		       			    		
				If QRY->TYPE_NF == 'ENTRADA'
				 	SF1->(dbGoTo(QRY->RECN))
				 	RecLock('SF1',.F.)
					SF1->F1_SERCAE := cSerCae
					SF1->F1_CAEE := cNroCae
					SF1->(msUnlock())     
					If !Empty(SF1->F1_ARQPDF )
				 	 	lAtualiza:=.F.
				 	 EndIf
				Else
				 	SF2->(dbGoTo(QRY->RECN))
				 	RecLock('SF2',.F.)
					SF2->F2_SERCAE :=  cSerCae
					SF2->F2_CAEE := cNroCae  
					SF2->(msUnlock())       
					If !Empty(SF2->F2_ARQPDF )
				 	 	lAtualiza:=.F.
				 	 EndIf
				EndIf				        	    
			Else
				cSerCae := Alltrim(QRY->SERCAE)
				cNroCae := QRY->NROCAE
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³2* Atualiza o status do documento de acordo com os dados recebidos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtualiza  .And.  !Empty(cSerCae) .and. !Empty(cNroCae)
	 			cDescRej := alltrim(U_RFatC01(SM0->M0_CGC,val(QRY->CODDOC),cSerCae,val(cNroCae), ,lAuto))
				If !Empty(cDescRej)			 	
				 	If QRY->TYPE_NF == 'ENTRADA'
					 	SF1->(dbGoTo(QRY->RECN))
					 	RecLock('SF1',.F.)
					 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
						 	SF1->F1_FLFTEX := REJEITADO_DGI
						ElseIf upper(substr(cDescRej,1,2)) == "AE" //.or. upper(substr(cDescRej,1,2)) == "AS"
							SF1->F1_FLFTEX := AUTORIZADO        
							 lAutoriz:=.T.
						ElseIf upper(substr(cDescRej,1,2)) == "AS"	 
							SF1->F1_FLFTEX  := TRANSMITIDO
						EndIf
					 	SF1->F1_SITNOTA := cDescRej
					 	SF1->(msUnlock())
					Else
					 	SF2->(dbGoTo(QRY->RECN))
					 	RecLock('SF2',.F.)
					 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
						 	SF2->F2_FLFTEX := REJEITADO_DGI
						ElseIf upper(substr(cDescRej,1,2)) == "AE" //.or. upper(substr(cDescRej,1,2)) == "AS"
							SF2->F2_FLFTEX := AUTORIZADO  
							 lAutoriz:=.T.
						ElseIf upper(substr(cDescRej,1,2)) == "AS"	 
							SF2->F2_FLFTEX := TRANSMITIDO
						EndIf
					 	SF2->F2_SITNOTA := cDescRej
					 	SF2->(msUnlock())
					EndIf
				EndIf
			EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³3* Atualiza o documento (PDF) na base do Protheus a partir do Base64 enviado pelo WS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			 If lAutoriz
			 	If QRY->TYPE_NF == 'ENTRADA'
				 	SF1->(dbGoTo(QRY->RECN))
				 	If !Empty(SF1->F1_ARQPDF )
				 	 	lAtualiza:=.F.
				 	 EndIf
				Else
				 	SF2->(dbGoTo(QRY->RECN))    
				 	If !Empty(SF2->F2_ARQPDF )
				 	 	lAtualiza:=.F.
				 	 EndIf
				EndIf 
			EndIf	
			
			If  lAtualiza   

				If cWsVersao == "3.1"
					oWsRonda := WSRondanetService():New()
				EndIf
				oWsRonda:_URL := GetNewPar("MV_IPWSRON","")

				 If cWsVersao == "3.1"
					oWsRonda := WSRondanetService():New()
					oWsRonda:_URL 							:= GetNewPar("MV_IPWSRON","")
					oWsRonda:crutEmisor 					:= Alltrim(SM0->M0_CGC)
					oWsRonda:cusuario 	   					:= cWsUser
					oWsRonda:cpassword 					:= cWsPass
					oWsRonda:ntipoComprobante			:= val(QRY->CODDOC)					
					oWsRonda:cserie							:= Alltrim(QRY->SERCAE)//Alltrim(QRY->SERIE)  //QRY->SERCAE //cSerCae
					oWsRonda:nnumeroComprobante	:= val(QRY->NROCAE)     
							
					If oWsRonda:obtenerRepresentacionImpresa()
		
						If ValType(oWsRonda:cReturn) == "C" .and. !Empty(oWsRonda:cReturn)
							CAVISO := ''
							CWARNING:=''
							oPDFt := XMLParser(oWsRonda:cReturn,'_',@cAviso,@cWarning)
							cArq64 := OPDFT:_RESPUESTA_WS:_DESCRIPCION:TEXT                                                                    			  		
							cNCae    	:= OPDFT:_RESPUESTA_WS:_NUMERO:TEXT 
							cSCae 		:= OPDFT:_RESPUESTA_WS:_SERIE:TEXT    
							If !Empty(cNCae) 
								If ExistBlock("FIS57NCA")
									cNCae:=ExecBlock("FIS57NCA",.F.,.F.,{cNCae})
								Else								
									cNCae:=PADL(cNCae,TamSX3("F2_CAEE")[1],"0")
								EndIf
							EndIf
						  	If QRY->TYPE_NF == 'ENTRADA'
							 	SF1->(dbGoTo(QRY->RECN))
							 	RecLock('SF1',.F.)  
							 	If !Empty(cNCae)
									SF1->F1_SERCAE := cSCae
									SF1->F1_CAEE 	:= cNCae 	
							 	EndIf
							 	SF1->F1_ARQPDF := cArq64
							 	SF1->(msUnlock())
							Else
							 	SF2->(dbGoTo(QRY->RECN))
							 	RecLock('SF2',.F.)
							 	If !Empty(cNCae)
							 		SF2->F2_SERCAE := cSCae
									SF2->F2_CAEE 	:= cNCae	
							 	EndIf
							 	SF2->F2_ARQPDF := cArq64
							 	SF2->(msUnlock())
							EndIf
							If lAuto
								autoNfeMsg( "Actualizando retorno " + cProcName, .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso)
							EndIf	
							
						EndIf
					EndIf
			   EndIf		
			EndIf
									    // Ponto de entrada para gravação dos campos de usuario apos a atualizacao dos dados!
			If  lAutoriz .And. ExistBlock("FIS57NOT")
				If QRY->TYPE_NF == 'ENTRADA'
					SF1->(dbGoTo(QRY->RECN))
					cTipoCFE:=SF1->F1_ESPECIE
				Else
					SF2->(dbGoTo(QRY->RECN))
					cTipoCFE:=SF2->F2_ESPECIE
				EndIf

				cSerCae := Alltrim(QRY->SERIE)
	    		cNroCae := QRY->DOC

				 ExecBlock("FIS57NOT",.F.,.F.,{1,cNroCae,cSerCae,cTipoCFE,cNCae,cSCae,QRY->TYPE_NF})
			EndIf

			//Zera variaveis e vai para o proximo registro    
		lAutoriz:=.F.
		cSerCae := ""
		cNroCae := ""
		cTipoCFE:= ""
		cSCae	:= ""
		cNCae	:= ""	
		cArq64 	:= ""			
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea()) 
 EndIf   
	//Exibe dialog ao usuario com o resultado da sincronização
If Empty(alltrim(cFailMsg))
	If lAuto
		autoNfeMsg( "Sincronizacion Concluida " + IIf(cTipoFil == "1", " - Factura de Salida"," - Factura de Entrada"), .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso)
	Else      
		MsgInfo('Sincronizacion Concluida')
	EndIf
Else
	If lAuto
		autoNfeMsg( "Falla na inicializacion do proceso de " + cProcName, .T., cEmpAnt, cFilAnt, cSerieFil , cProcesso)
	Else      
		Aviso('Atencion','Los documentos abajo relacionados no puderiam ser sincronizados com exito. ' + cPulaLin + cFailMsg,{'Ok'})
	EndIf
EndIf
RestArea(aArea)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SincByFile
Sincroniza com as pastas do RondaNet

@author  Microsiga Protheus
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SincByFile()
Local cError    	:= ""
Local cWarning  	:= ""                                                                      
Local cPathRej 		:= GetNewPar("MV_NOENVIA","")
Local cPathCon 		:= GetNewPar("MV_CONTROL","")
Local cPathImp		:= GetNewPar("MV_URUIMP","") 
Local cPathOriXml	:= ""
Local cPathDestXml	:= ""
Local cNomImp       := ""
Local cNomImpPDF	:= ""
Local cArqTxt		:= ""
Local cNunNota		:= ""
Local cSerNota      := ""
Local cNunNotaRej	:= ""
Local cSerNotaRej   := ""                            		
Local cNunDGI		:= ""
Local cSerDGI		:= ""
Local cTipoCFE		:= "" 
Local cArq 			:= "" 
Local cArqCom		:= ""
Local cTipoNota		:= ""
Local cExiNota		:= ""
Local cNfFail		:= ""
Local nTypeDoc		:= 0
Local aXmlRej 		:={}
Local aXmlRejTxt	:={}
Local aXmlCon		:={}
Local aPdfImp		:={}

Local lCopied		:=.T.

Local nY			:= 0
Local nJ			:= 0
Local nJX			:= 0
Local nI			:= 0  
Local nPos			:= 0                  
Local nQuaXml		:= 0
Local nHandle		:= 0
Local nTam			:= 0
Local nHanimp    	:= 0

Private oXmlRec
Private oXmlRej
Private oXmlCon

If !Empty(cPathRej) .and. !Empty(cPathCon) .and. !Empty(cPathImp)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³      OBTEM OS ARQUIVOS A SEREM PROCESSADOS      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aXmlRej  	:= directory(cPathRej+"*.xml",,,.F.)				// ----- Pega o XML da pasta NoEnviados
	aXmlRejTxt  := directory(cPathRej+"*.txt",,,.F.)				// ----- Pega o TXT da pasta NoEnviados
	aXmlCon		:= directory(cPathCon+"*.xml",,,.F.)				// ----- Pega o XML da pasta Control
	aPdfImp		:= directory(cPathImp+"*.*",,,.F.)					// ----- Pega todos arquivos da pasta Impresion

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³        PROCESSA O DIRETORIO DE AUTORIZADOS        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nJ :=1 To len (aXmlCon)   		
		
		//Parseia o XML 
		oXmlCon := MyParserFile( cPathCon + aXmlCon[nJ,1], "_", @cError, @cWarning,,.F.)
		
		If (Empty(cError) .and. empty(cWarning))
		    If Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE")<>"U" .OR. Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE") == "A"
				
				If Type("oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE")=="A" 
			   		oXmlCon := oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE 
				Else 
			   		oXmlCon := {oXmlCon:_CORRESPONDENCIASNROSCOMP:_CFE} 
				EndIf
				 
				//Processa as notas que estao dentro do XML
			   	For nJX := 1 To Len(oXmlCon)
			   	
			   		//Obtem Serie, Numero, Serie CAE e Numero CAE
					If ( Type("oXmlCon[nJX]:_NROEMPRESA:TEXT") <> "A" )					
						cNunNota := oXmlCon[nJX]:_NROEMPRESA:TEXT
					EndIf 			 
					If ( Type("oXmlCon[nJX]:_SERIEEMPRESA:TEXT") <> "A" )
						cSerNota := oXmlCon[nJX]:_SERIEEMPRESA:TEXT 
	     			EndIf
	     			If ( Type("oXmlCon[nJX]:_TIPOCFE:TEXT") <> "A" )                      
						cTipoCFE := oXmlCon[nJX]:_TIPOCFE:TEXT
	     			EndIf                   
					If ( Type("oXmlCon[nJX]:_NRODGI:TEXT") <> "A" )
	                   	cNunDGI	:= oXmlCon[nJX]:_NRODGI:TEXT 
	       			EndIf
	       			If ( Type("oXmlCon[nJX]:_SERIEDGI:TEXT") <> "A" )
						cSerDGI := oXmlCon[nJX]:_SERIEDGI:TEXT 
	      			EndIf
	      			
					If !Empty(cNunNota) .And. !Empty(cSerNota) .And. !Empty(cTipoCFE) .And. !Empty(cNunDGI) .And. !Empty(cSerDGI)														
						dbSelectArea("SF3")
						SF3->(dbSetOrder(6))
						If SF3->(dbSeek(xFilial("SF3")+STRZERO(val(cNunNota),len(SF3->F3_NFISCAL))+PADR(cSerNota,len(SF3->F3_SERIE))))
							cExiNota := SF3->F3_CAE
							cTipoNota := SF3->F3_TES
						Endif

						//Se for uma nota que ja possui CAE, despreza, pois ja foi atualizada anteriormente
						If IsProcess(cNunNota,cSerNota,cTipoNota,cExiNota)
							   
							//Pesquisa se a nota ja possui PDF Disponivel
							//Se possuir, le seu conteudo BINARIO para gravar na SF1 ou SF2
							If Len(aPdfImp) > 0
								cNomImp := cTipoCFE+Alltrim(cSerDGI)+cNunDGI
								nPos := aScan(aPdfImp,{|x| cNomImp $ x[1]})
								If nPos > 0
									cNomImpPDF := aPdfImp[nPos,1]															
									nHanimp := FOpen(cPathImp+aPdfImp[nPos,1],,0,.F.)
								   	If nHanimp > -1
									   	nTam 	:= Fseek(nHanimp,0,FS_END)
									   	If nTam <= 950000 
									 		FSeek(nHanimp,0,FS_SET)
									 		nI := 1 
											cArqCom := ""
									 		While nI <= nTam
												FRead(nHanimp,@cArq,NBYTES_READ) 
												cArqCom += cArq
												cArq := ""			
												nI := nI + NBYTES_READ
											EndDo
											FClose(nHanimp)
										Else			
											MsgAlert(STR0143)
										EndIf
									Endif
								Else
									cNfFail += "Tipo: " + cTipoCFE + " Serie: " + cSerNota + " Número: " + cNunNota + chr(13) + chr(10)
								EndIf
							Endif	                        
							
							//Posiciona na SF3 do documento e atualiza o CAE
							dbSelectArea("SF3")
							SF3->(dbSetOrder(6))
							If SF3->(dbSeek(xFilial("SF3")+STRZERO(val(cNunNota),len(SF3->F3_NFISCAL))+PADR(cSerNota,len(SF3->F3_SERIE))))
								RecLock("SF3",.F.)
								SF3->F3_SERCAE := cSerDGI  
								SF3->F3_CAE := cNunDGI
								SF3->(MsUnLock())
							Endif														
										           
							//Atualiza os dados nas tabelas do Protheus
							If Val(cTipoNota) < 500								    
								dbSelectArea("SF1")
								SF1->(dbSetOrder(1))
								If SF1->(dbSeek((xFilial("SF1"))+STRZERO(val(cNunNota),len(SF1->F1_DOC))+PADR(cSerNota,len(SF1->F1_SERIE))))
									RecLock("SF1",.F.)								
									//SF1->F1_FLFTEX := AUTORIZADO
									SF1->F1_SITNOTA:= STR0136
									SF1->F1_CAEE   := cNunDGI
									SF1->F1_SERCAE := cSerDGI 
									SF1->F1_ARQPDF := Encode64(cArqcom) 
									SF1->(MsUnLock())
								EndIf													
							Else
								dbSelectArea("SF2")
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek((xFilial("SF2"))+STRZERO(val(cNunNota),len(SF2->F2_DOC))+PADR(cSerNota,len(SF2->F2_SERIE))))
									RecLock("SF2",.F.) 
									//SF2->F2_FLFTEX := AUTORIZADO
									SF2->F2_SITNOTA:= STR0136
									SF2->F2_CAEE   := cNunDGI
									SF2->F2_SERCAE := cSerDGI 
									SF2->F2_ARQPDF := Encode64(cArqcom) 
									SF2->(MsUnLock())
								Endif
							Endif
						    // Ponto de entrada para gravação dos campos de usuario apos a atualizacao dos dados!
							If ExistBlock("FIS57NOT")
								 ExecBlock("FIS57NOT",.F.,.F.,{1,cNunNota,cSerNota,cTipoCFE,cNunDGI,cSerDGI,Iif(Val(cTipoNota) < 500,'ENTRADA','SAIDA')})
							EndIf
							
							cNunNota   := ""
							cSerNota   := ""
							cTipoCFE   := ""
							cNunDGI    := ""
							cSerDGI	   := ""
							cNomImp    := ""
							cNomImpPDF := ""
							cArqCom	   := ""
						Endif
						cExiNota := ""
					EndIf
				Next nJX 					                               		
			EndIf
		Endif
		oXmlCon := Nil													
    Next nJ 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³         PROCESSA O DIRETORIO DE REJEICOES         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 To len(aXmlRej)			

		//Parseia o XML para obter informacoes
		oXmlRej := MyParserFile(cPathRej + aXmlRej[nY,1], "_", @cError, @cWarning,,.F.)	
		
		//Coleta o Numero e a Serie do documento dentro do XML parseado					
		If Empty(cError) .and. empty(cWarning) 						
			//Tipo fatura
			If Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT") <> "U"
				cNunNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT
			EndIf							
			If Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT") <> "U"
				cSerNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT
			Endif
							
			//Tipo e-Ticket	
			If ( Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ETCK:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT") <> "U" )
				cNunNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ETCK:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT
			EndIf														
			If Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ETCK:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT") <> "U"
				cSerNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_ETCK:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT
			Endif
			
			//Tipo e-Fact - Exportacion	
			If ( Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT_EXP:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT") <> "U" )
				cNunNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT_EXP:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_NRO:TEXT
			EndIf														
			If Type("oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT_EXP:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT") <> "U"
				cSerNotaRej := oXmlRej:_NS0_CFE_ADENDA:_NS0_CFE:_NS0_EFACT_EXP:_NS0_ENCABEZADO:_NS0_IDDOC:_NS0_SERIE:TEXT
			Endif
		EndIf

		//Verirfica se possui o arquivo TXT desta nota no diretorio de TXTs			
		If Len(aXmlRejTxt) > 0  				
			nPos := aScan(aXmlRejTxt,{|X| substr(aXmlRej[nY,1],1,len(aXmlRej[nY,1])-4) $ x[1] })
			If nPos > 1											
				lNotTxt := .F.
				nHandle := FOpen(cPathRej+aXmlRejTxt[nPos,1],,0,.F.)
				FRead(nHandle,@cArqTxt,512000)
				Fclose(nHandle)					
			EndIf				
		EndIf

		//Atualiza os dados no protheus
		If !Empty(cNunNotaRej) .And. !Empty(cSerNotaRej)																						
			DbSelectArea("SF3")
			SF3->(DbSetOrder(6))
		  	If SF3->(dbSeek(xFilial("SF3")+STRZERO(val(cNunNotaRej),len(SF3->F3_NFISCAL))+PADR(cSerNotaRej,len(SF3->F3_SERIE))))
				cTipoNota := (SF3->F3_TES)
			Else
			    dbSelectArea("SD2")
				SD2->(dbSetOrder(3))
			    If SD2->(dbSeek(xFilial("SD2")+STRZERO(val(cNunNotaRej),len(SF2->F2_DOC))+PADR(cSerNotaRej,len(SF2->F2_SERIE))))
                   	cTipoNota := (SD2->D2_TES)
       			Else 
                    dbSelectArea("SD1")
					SD1->(dbSetOrder(3))
				    If SD1->(dbSeek(xFilial("SD1")+STRZERO(val(cNunNotaRej),len(SF1->F1_DOC))+PADR(cSerNotaRej,len(SF1->F1_SERIE))))
                      	cTipoNota := (SD1->D1_TES)
                    Else 
						cTipoNota :="" 
					Endif                     
				Endif
			Endif	

			IF !Empty(cTipoNota)				
				If val(cTipoNota) < 500
					dbSelectArea("SF1")
					SF1->(DbSetOrder(1))
      				If dbSeek((xFilial("SF1"))+STRZERO(val(cNunNotaRej),len(SF1->F1_DOC))+PADR(cSerNotaRej,len(SF1->F1_SERIE)))
						RecLock("SF1",.F.)
						SF1->F1_FLFTEX := iif(Empty(SF1->F1_CAEE),REJEITADO_RONDANET,SF1->F1_FLFTEX)
						SF1->F1_SITNOTA:= cArqTxt
						SF1->(MsUnLock())
					Endif
				Else
					dbSelectArea("SF2")
					SF2->(DbSetOrder(1))
      				If SF2->(dbSeek((xFilial("SF2"))+STRZERO(val(cNunNotaRej),len(SF2->F2_DOC))+PADR(cSerNotaRej,len(SF2->F2_SERIE))))
						RecLock("SF2",.F.)
						SF2->F2_FLFTEX := iif(Empty(SF2->F2_CAEE),REJEITADO_RONDANET,SF2->F2_FLFTEX)
						SF2->F2_SITNOTA:= cArqTxt
						SF2->(MsUnLock())
					Endif
				Endif
		  	Endif
		EndIf
		
		//Reseta Variaveis e processa proximo arquivo				
		cSerNotaRej	:= "" 
		cNunNotaRej	:= ""				 		
		lNotTxt	   	:= .F.
		oXmlRej		:= Nil
		cArqTxt		:= ""
	Next nY
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³    Chama o WS para as notas da SF1 e SF2 que tem CAE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetDescFromWS()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     Exibe alerta ao usuario caso nao encontre algum PDF     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cNfFail)
		Aviso("Atencion","No fue possible encuntrar el archivo PDF para estas facturas: " + chr(13) + chr(10) + cNfFail,{"OK"})
	EndIf

Else
	Aviso("Atencion","Un ou mas parametros de los directorios de lectura da integración RondaNet no estan cadastrados. Por favor, verifique os parametros MV_NOENVIA, MV_CONTROL e MV_URUIMP",{"Ok"})
EndIf  
                                                                                                   
Return .T.                                                                                    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57Mon
Monitor de Notas da NFe Uruguai

@author  Fernando Bastos
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Function Fis57Mon(cAlias) 

	Local cIdEnt   := ""
	Local aPerg    := {}
	Local aParam   := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),"",""}
	Local aSize    := {}
	Local aObjects := {}
	Local aListBox := {}
	Local aInfo    := {}
	Local aPosObj  := {}
	Local oWS
	Local oDlg
	Local oListBox
	Local oBtn1
	Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
	Local lOK        := .F.
	
	Default cAlias := 'SF2'
	
	aadd(aPerg,{1,STR0078,aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0079,aParam[02],"",".T.","",".T.",60,.T.}) //"Nota fiscal inicial"
	aadd(aPerg,{1,STR0080,aParam[03],"",".T.","",".T.",60,.T.}) //"Nota fiscal final"
	aadd(aPerg,{1,STR0145,dDataBase,"",".T.","",".T.",80,.F.})	//"Data Emissao Inicial
	aadd(aPerg,{1,STR0146,dDataBase,"",".T.","",".T.",80,.F.})	//"Data Emissao Inicial
	
	
	aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
	aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
	aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])
	aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
	aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])
	
	lOK      := ParamBox(aPerg,"Uru - NFe",@aParam,,,,,,,cParNfeRem,.T.,.T.)
	cSerie   := aParam[01] 
	cNotaIni := aParam[02] 
	cNotaFim :=	aParam[03]
	cDataIni := aParam[04] 
	cDataFim :=	aParam[05]
	
	If (lOK)
		aListBox := NFeMonitor(cAlias,cSerie,cNotaIni,cNotaFim,cDataIni,cDataFim)
		If !Empty(aListBox)
			aSize := MsAdvSize()
			aObjects := {}
			AAdd( aObjects, { 100, 100, .t., .t. } )
			AAdd( aObjects, { 100, 015, .t., .f. } )
		
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )
									
			DEFINE MSDIALOG oDlg TITLE "Uru - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
			
			@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER STR0132,STR0128,STR0133,STR0137,STR0147,STR0134; //"NF"###"Serie"###"Data"###CAE###Serie CAE###"Recomendação"
				SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
			oListBox:SetArray( aListBox )
			oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4],aListBox[ oListBox:nAT,5],aListBox[ oListBox:nAT,6]} }
			
			@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT STR0131   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
			ACTIVATE MSDIALOG oDlg
		EndIf
	EndIf
Return
       
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NFeMonitor 
Separa todos os itens que serao apresentados no monitor

@author  Fernando Bastos
@version P10
@since 	 21/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function NFeMonitor(cAlias,cSerie,cNotaIni,cNotaFim,cDataIni,cDataFim)

Local cAliasSF   := "cAliasSF"  
Local aNotas	 := {}

Default cAlias 	 := 'SF2'
Default cSerie 	 := ""
Default cNotaIni := ""
Default cNotaFim := ""
Default cDataIni := ""
Default cDataFim := ""

If cAlias =="SF1"
	dbSelectArea("SF1")
	dbSetOrder(1)                    	
	#IFDEF TOP
		BeginSql Alias cAliasSF
		COLUMN F1_EMISSAO AS DATE
		SELECT	F1_FILIAL,F1_EMISSAO,F1_FORMUL,F1_DOC,F1_SERIE,F1_LOJA,F1_ESPECIE,F1_CAEE,F1_SERCAE,F1_ESPECIE,F1_EMCAEE,F1_TIPO FROM %Table:SF1% SF1
			WHERE
   			SF1.F1_FILIAL = %xFilial:SF1% AND
			SF1.F1_SERIE = %Exp:cSerie% AND 
			SF1.F1_DOC >= %Exp:cNotaIni% AND 
			SF1.F1_DOC <= %Exp:cNotaFim% AND
			SF1.F1_EMISSAO >= %Exp:cDataIni% AND 
			SF1.F1_EMISSAO <= %Exp:cDataFim% AND  
			SF1.%notdel%
		EndSql
		
	#ELSE
		MsSeek(xFilial("SF1")+cNotaIni+cSerie,.T.)
	#ENDIF
			
	While !Eof() .And. xFilial("SF1") == (cAliasSF)->F1_FILIAL .And.;
		(cAliasSF)->F1_SERIE == cSerie .And.;
		(cAliasSF)->F1_DOC >= cNotaIni .And.;
		(cAliasSF)->F1_DOC <= cNotaFim
	
		dbSelectArea(cAliasSF)
		If ((cAliasSF)->F1_FORMUL=="S" .OR. (cAliasSF)->F1_FORMUL=="N" )
			aadd(aNotas,{})	
			nX := Len(aNotas)
			aadd(aNotas[nX],(cAliasSF)->F1_DOC)
			aadd(aNotas[nX],(cAliasSF)->F1_SERIE)
			aadd(aNotas[nX],(cAliasSF)->F1_EMISSAO)
			aadd(aNotas[nX],(cAliasSF)->F1_CAEE)
			aadd(aNotas[nX],(cAliasSF)->F1_SERCAE)
			If SF1->(FieldPos("F1_SITNOTA"))>0
				DbSelectArea("SF1")
				DbSetOrder(1)
				If (dbSeek((cAliasSF)->F1_FILIAL+(cAliasSF)->F1_DOC+(cAliasSF)->F1_SERIE))
					RecLock("SF1",.F.)
					aadd(aNotas[nX],SF1->F1_SITNOTA)					
					MsUnLock()
				Else
					aadd(aNotas[nX],"")
				Endif									
			Else	
				aadd(aNotas[nX],"")	
			Endif
		EndIf		
		dbSelectArea(cAliasSF)
		dbSkip()	
	EndDo		
	dbCloseArea()		
Else
	dbSelectArea("SF2")
	dbSetOrder(1)                    	
	#IFDEF TOP
		BeginSql Alias cAliasSF
		COLUMN F2_EMISSAO AS DATE
		SELECT	F2_FILIAL,F2_EMISSAO,F2_FORMUL,F2_DOC,F2_SERIE,F2_CLIENT,F2_LOJA,F2_ESPECIE,F2_CAEE,F2_SERCAE,F2_ESPECIE,F2_EMCAEE,F2_TIPO FROM %Table:SF2% SF2
			WHERE
   			SF2.F2_FILIAL = %xFilial:SF2% AND
			SF2.F2_SERIE = %Exp:cSerie% AND 
			SF2.F2_DOC >= %Exp:cNotaIni% AND 
			SF2.F2_DOC <= %Exp:cNotaFim% AND 
			SF2.F2_EMISSAO >= %Exp:cDataIni% AND 
			SF2.F2_EMISSAO <= %Exp:cDataFim% AND  
			SF2.%notdel%
		EndSql
		
	#ELSE
		MsSeek(xFilial("SF2")+cNotaIni+cSerie,.T.)
	#ENDIF
			
	While !Eof() .And. xFilial("SF2") == (cAliasSF)->F2_FILIAL .And.;
		(cAliasSF)->F2_SERIE == cSerie .And.;
		(cAliasSF)->F2_DOC >= cNotaIni .And.;
		(cAliasSF)->F2_DOC <= cNotaFim
	
		dbSelectArea(cAliasSF)
		If ((cAliasSF)->F2_FORMUL=="S" .OR. (cAliasSF)->F2_FORMUL=="S" )
			aadd(aNotas,{})	
			nX := Len(aNotas)
			aadd(aNotas[nX],(cAliasSF)->F2_DOC)
			aadd(aNotas[nX],(cAliasSF)->F2_SERIE)
			aadd(aNotas[nX],(cAliasSF)->F2_EMISSAO)
			aadd(aNotas[nX],(cAliasSF)->F2_CAEE)
			aadd(aNotas[nX],(cAliasSF)->F2_SERCAE)
			If SF2->(FieldPos("F2_SITNOTA"))>0
				DbSelectArea("SF2")
				DbSetOrder(1)
				If (dbSeek((cAliasSF)->F2_FILIAL+(cAliasSF)->F2_DOC+(cAliasSF)->F2_SERIE))
					RecLock("SF2",.F.)
					aadd(aNotas[nX],SF2->F2_SITNOTA)					
					MsUnLock()
				Else			
					aadd(aNotas[nX],"")								   
				Endif
			Else	
				aadd(aNotas[nX],"")	
			Endif
		EndIf		
	   	dbSelectArea(cAliasSF)
		dbSkip()	
	EndDo
    dbCloseArea()
Endif
Return(aNotas)    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Fis57imp
Obtem um conteudo em formato binario base64 gravado na SF1/SF2 referente a nota eletronica do
uruguai e transforma em arquivo PDF

@param cAlias	- Tabela utilizada para extração do arquivo
@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------          
Function Fis57imp(cAlias)
Local cArqCom	:= ""
Local cNunNota	:= IIf(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
Local cSerNota 	:= IIf(cAlias=="SF1",SF1->F1_SERIE,SF2->F2_SERIE) 
Local cPathImp  := GetTempPath()
Local nHandle   := 0  

	IF cAlias == "SF1"
		DbSelectArea("SF1")
		DbSetOrder(1)
		If dbSeek((xFilial("SF1"))+PADR(cNunNota,len(SF1->F1_DOC))+PADR(cSerNota,len(SF1->F1_SERIE))) 		
			cArqCom := Decode64(SF1->F1_ARQPDF)   
		Endif                                                                                                                                  
	Else 
		DbSelectArea("SF2")
		DbSetOrder(1)
		If dbSeek((xFilial("SF2"))+PADR(cNunNota,len(SF2->F2_DOC))+PADR(cSerNota,len(SF2->F2_SERIE))) 		
			cArqCom := Decode64(SF2->F2_ARQPDF)
		Endif	
	Endif

	If !Empty (cArqCom)	
		nHandle := FCreate(cPathImp+LOWER(Alltrim(cSerNota))+Alltrim(cNunNota)+".pdf",,,.F.,3)
		FWrite(nHandle,cArqCom)	
		Sleep(1000)
		FClose(nHandle)
		ShellExecute("Open",cPathImp+LOWER(Alltrim(cSerNota))+Alltrim(cNunNota)+".pdf","",cPathImp, 1 )
	Else
		MsgAlert(STR0140)   //Arquivo PDF não encontrado
	Endif
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyParserFile
Funcao alternativa para copia de arquivo para uso exclusivo em contornos paliativos

@param cOrigem	- Path de Origem
	   cDestino	- Path Destino

@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MyParserFile(cPath,cReplace,cError,cWarning,nCompat,lCase)
	Local lTemp 	:= .F.
	Local lAbsolut	:= .F.
	Local cFileName := ""
	Local cDestino	:= "\"
	Local aAux 		:= {} 
	Local oXML		:= Nil
	
	If IsSrvUnix()
		//S.O Linux
	    //Falta Implementar!!!
	    cPath := alltrim(cPath)
	    oXML := XmlParserFile(substr(cPath,2,len(cPath)-1),cReplace,@cError,@cWarning,,lCase)
	Else
		//S.O Windows
		//Verifica se o path eh absoluto ou relativo (a partir do rootPath.)
		//Se for absoluto, faz uma copia temporaria para o RootPath
		//Funcao XMLParserFile tem limitação para trabalhar apenas sobre o RootPath
		lAbsolut := ":" $ cPath
		If lAbsolut
			lTemp := .T.
			aAux := StrTokArr(cPath,"\")
			cFileName := aAux[len(aAux)]
			cDestino := "\" + cFileName
			
			//Cria copia temporaria
			MyCopyFile(cPath,cDestino)
			
			//Faz o Parser sobre a copia temporaria
			oXML := XmlParserFile(cDestino,cReplace,@cError,@cWarning,,lCase)
	
			//Elimina a copia temporaria
			FErase(cDestino)
		Else
		    //Se path ja eh relativo, apenas faz o parser!
		    oXML := XmlParserFile(cPath,cReplace,@cError,@cWarning,,lCase)
		EndIf
	EndIf

Return oXML

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MyCopyFile
Funcao alternativa para copia de arquivo para uso exclusivo em contornos paliativos

@param cOrigem	- Path de Origem
	   cDestino	- Path Destino

@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function MyCopyFile(cOrigem,cDestino)

	Default cOrigem  := ""
	Default cDestino := ""

	If !Empty(cOrigem) .and. !Empty(cDestino)
		__CopyFile(cOrigem,cDestino)
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} F057Lock
Cria/Exclui um lock em disco, para controle de processamento  

@param cLock	Nome do Arquivo de Lock a ser criado
	   lClose	Operacao: Abertura ou Fechamento de lock

@author  Microsiga Protheus
@version P10
@since 	 09/05/2014
@return nHandleLock
/*/
//-------------------------------------------------------------------------------------
Function F057Lock(cLock,lClose)
Local cDir 	:= getPathSemaforo()
Local nHandle := 0                          
Default lClose	:= .T. 
	
makeDir( getPathSemaforo() )
	      
If file(cDir+cLock) 
   	nHandle := FOpen(cDir+cLock,,0,.F.)
Else     
	nHandle := FCreate((cDir+cLock),,,.T.,3)
	fClose(nHandle)
Endif                           
	
If lClose
	fClose(nHandle)
	FERASE(cDir+cLock)	
Endif

return nHandle


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetDescFromWS
Varre a SF1/SF2 em busca de itens transmitidos e sem retorno, para consulta na RondaNet via WS

@author  Microsiga Protheus
@version P10
@since 	 23/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function SetDescFromWS()
Local cQuery := ""
Local cDescRej := ""
Local aArea := (Alias())->(GetArea())
	
If FindFunction('U_RFatC01')	
		
	If SubStr(cTipoFil,1,1) == "1"
		cQuery += "SELECT SF2.F2_SERIE SERIE, SF2.F2_DOC DOC, SF2.F2_SERCAE SERCAE, SF2.F2_CAEE NROCAE, SF2.F2_CODDOC CODDOC, "
		cQuery += " SF2.F2_ARQPDF NF_PDF, SF2.F2_FLFTEX STAT, SF2.R_E_C_N_O_ RECN, 'SAIDA' AS TYPE_NF "
		cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "'"
		cQuery += "		AND SF2.F2_SERIE = '" + cSerieFil + "'"
		If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
			cQuery += "		AND SF2.F2_EMISSAO BETWEEN '" + DTOS(dDtInFil) + "' AND '" + DTOS(dDtEndFil) + "'"
		EndIf
		cQuery += " 	AND SF2.F2_SERCAE <> ' ' "
		cQuery += " 	AND SF2.F2_CAEE <> ' ' "
		cQuery += " 	AND (SF2.F2_FLFTEX = 'S' OR SF2.F2_FLFTEX = 'P')"
		cQuery += " 	AND SF2.D_E_L_E_T_ = ' ' "
	Else
			//Seleciona os itens
			cQuery := "SELECT SF1.F1_SERIE SERIE, SF1.F1_DOC DOC, SF1.F1_SERCAE SERCAE, SF1.F1_CAEE NROCAE, SF1.F1_CODDOC CODDOC, "
			cQuery += " SF1.F1_ARQPDF NF_PDF, SF1.F1_FLFTEX STAT, SF1.R_E_C_N_O_ RECN, 'ENTRADA' AS TYPE_NF " 
			cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
			cQuery += " WHERE SF1.F1_FILIAL = '" + xFilial('SF1') + "'"
			cQuery += "		AND SF1.F1_SERIE = '" + cSerieFil + "'"
			If !Empty(dDtInFil) .and. !Empty(dDtEndFil)
				cQuery += "		AND SF1.F1_EMISSAO BETWEEN '" + DTOS(dDtInFil) + "' AND '" + DTOS(dDtEndFil) + "'"			
			EndIf	
			cQuery += " 	AND SF1.F1_SERCAE <> ' ' "
			cQuery += " 	AND SF1.F1_CAEE <> ' ' "
			cQuery += " 	AND (SF1.F1_FLFTEX = 'S' OR SF1.F1_FLFTEX = 'P')"
			cQuery += " 	AND SF1.D_E_L_E_T_ = ' ' "
		EndIf
		iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRY", .F., .T.)	
		While QRY->(!Eof())
            	  
			//Faz a busca no WS da RondaNet
 			cDescRej := alltrim(U_RFatC01(SM0->M0_CGC,val(QRY->CODDOC),QRY->SERCAE,val(QRY->NROCAE)))

			//Atualiza a descricao com a string recebida
			If !Empty(cDescRej)			 	
			 	If QRY->TYPE_NF == 'ENTRADA'			 	
				 	SF1->(dbGoTo(QRY->RECN))
				 	RecLock('SF1',.F.)
				 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
					 	SF1->F1_FLFTEX := REJEITADO_DGI
					ElseIf upper(substr(cDescRej,1,2)) == "AE" //.or. upper(substr(cDescRej,1,2)) == "AS" 
						SF1->F1_FLFTEX := AUTORIZADO
					EndIf
				 	SF1->F1_SITNOTA := cDescRej
				 	SF1->(msUnlock())
				Else
				 	SF2->(dbGoTo(QRY->RECN))
				 	RecLock('SF2',.F.)
				 	If upper(substr(cDescRej,1,2)) == "BE" .or. upper(substr(cDescRej,1,2)) == "BS" 
					 	SF2->F2_FLFTEX := REJEITADO_DGI
					ElseIf upper(substr(cDescRej,1,2)) == "AE" //.or. upper(substr(cDescRej,1,2)) == "AS" 
						SF2->F2_FLFTEX := AUTORIZADO
					EndIf
				 	SF2->F2_SITNOTA := cDescRej
				 	SF2->(msUnlock())
				EndIf
			EndIf
			QRY->(dbSkip())
		EndDo
		QRY->(dbCloseArea()) 
	EndIf

	RestArea(aArea)	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsProcess
Verifica se vai processar o documento. Se nao tem CAE, processa. Se tem, processa apenas se nota é vazio

@author  Microsiga Protheus
@version P10
@since 	 23/05/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function IsProcess(cNro,cSer,cTes,cCAE)
Local lRet := .F.
	
If Val(cTes) < 500								    
	//Documento de entrada emitido com formulario proprio
	If Empty(cCAE)
		lRet := .T.
	Else
		dbSelectArea("SF1") 
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek((xFilial("SF1"))+STRZERO(val(cNro),len(SF1->F1_DOC))+PADR(cSer,len(SF1->F1_SERIE))))
			If Empty(SF1->F1_ARQPDF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	//Documento de Saida
	If Empty(cCAE)
		lRet := .T.
	Else
		dbSelectArea("SF2") 
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek((xFilial("SF2"))+STRZERO(val(cNro),len(SF2->F2_DOC))+PADR(cSer,len(SF2->F2_SERIE))))
			If Empty(SF2->F2_ARQPDF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
      
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Set057Fil
Seta o filtro de utilização da SF1/SF2

@author  Microsiga Protheus
@version P10
@since 	 29/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function Set057Fil(cAliasMnt)
If cAliasMnt == "SF2"
	dbSelectArea('SF2')
	FilBrowse("SF2",@aIndArqE,@cCondic)
Else
	dbSelectArea('SF1')
	FilBrowse("SF1",@aIndArqE,@cCondic)
EndIf	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Clean057Fil
Destroi o filtro da SF2/SF1

@author  Microsiga Protheus
@version P10
@since 	 29/07/2014
@return Nil
/*/
//-------------------------------------------------------------------------------------
Static Function Clean057Fil(cAliasMnt)

If cAliasMnt == "SF2"
	dbSelectArea("SF2")
	RetIndex("SF2")
	dbClearFilter()
	aEval(aIndArqE,{|x| Ferase(x[1]+OrdBagExt())})			    
Else
	dbSelectArea("SF1")
	RetIndex("SF1")
	dbClearFilter()
	aEval(aIndArqE,{|x| Ferase(x[1]+OrdBagExt())})	    
EndIf

Return

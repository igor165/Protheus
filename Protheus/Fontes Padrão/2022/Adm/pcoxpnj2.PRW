#include "protheus.ch"
#include "pcoxpnj.ch"
#include "msmgadd.ch"

#define RATEIO_ALX "011"
#define SALARIOPLJ "009"
#define OUTRASVPLJ "010"

Static cSeqALY
Static cSrvType
Static cTipoDB
Static lOracle
Static lDB2
Static lInformix
Static lPostgres

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGerMovsบAutor  ณ Acacio Egas        บ Data ณ  08/25/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de chamada dos movimentos gerados no planejamento   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cId: Id da Estrtura relacionada ao movimento               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoGerMovs(cId,cTipoVar,cVarPnj,nOpc,lQuant,bVlrUnit,cSeek,aAuto,aOutros)

Local lContinua := .T.

Default nOpc := 3

Do Case
	
	Case nOpc == 5
		
		If !Empty(cSeek) .and.  !Empty(cId)
			
			nRet := Aviso( STR0001 , STR0002 ,{ STR0003 , STR0004 , STR0005 }) //"Aten็ใo!"###"Deseja deletar ?"###"Principal"###"Todos"###"Cancelar"
			
			If nRet == 1
				
				cSeek 	:= nil
				
			ElseIf nRet == 2
				
				cId 	:= nil
				
			Else
				
				lContinua := .F.
				
			EndIf
			
		EndIf
		
		If lContinua
			
			PcoDelMovs(cId,cVarPnj,nil,/*cSeq*/,cSeek)
			
		EndIf
			
	Case cTipoVar == '1' // Movimento normal
		
		PcoMovimen(cId,nOpc,cVarPnj,lQuant,bVlrUnit,cSeek,aAuto)
		
	Case cTipoVar == '2' // Movimento relacionado a outros movimentos (1 Movimentos Normal x N Movimentos relacionados)
		
		PcoMovRela(cId,nOpc,lQuant,bVlrUnit,cSeek,aAuto)
		
	Case cTipoVar == '3' // Movimento Imposto (Movimentos que sao impostos de acordo com outros movimentos)
		
		PcoMovImpo(cId,nOpc,cSeek,aAuto)
		
	Case cTipoVar == '4' // Movimento de Contra Partida (1 Movimento Normal x 1 Movimento de Contra partida)
		
		PcoContraP(cId,nOpc,lQuant,bVlrUnit,cSeek,aAuto)
		
	Case cTipoVar == '5' // Roteiro de Movimentos (Grupo de movimentos gerados em cascata)
		
		//PcoDspDire(cId,nOpc,oGtDados,cSeek,aAuto)
		PcoRotMov(cId,nOpc,cVarPnj,cSeek,aAuto)
		
	Case cTipoVar == '6' // Inicial (Inicia um movimento de acordo com o Saldo Anterior de suas contas or็amentarias)
		
		PcoMovIni(cId,nOpc,cVarPnj,lQuant,bVlrUnit,cSeek,aAuto)
		
	Case cTipoVar == '7' // Projetado (Projeto um movimento de acordo com uma variacao prevista)
		
	  //PcoSldInic(cId,nOpc,oGtDados,cSeek,aAuto)
		
	//Case cTipoVar == '008'
		
		//PcoVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)
		
	//Case cTipoVar == '501'
		
		//PcoContPar(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoVar == 'Z' // Importa็ใo ( Configurador - AMK )
	
		PcoEngine(cId,AM2->AM2_PLANEJ,cVarPnj,aOutros[1],aOutros[2])
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovimenบAutor ณAcacio Egas         บ Data ณ 12/03/08  ณ          บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออฯออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de movimento no planejamentos.                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovimen(cId,nOpc,cVarPnj,lQuant,bVlrUnit,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local aBakVal,aValores
Local cRegrDist
Local cTipoPrec
Local cTabePrec,cTipoValo
Local nPrecAgre
Local cTmpArq

Default lQuant:= .F.
Default cSeek := ''

aAdd(aParam,{ 1, STR0006 , SPACE(6)	,"@S6","ExistCpo('ALS')"	, "ALS", ".T."	,6	,.F.}) //"Regra Rec. Diretas"

If aAuto == NIL

	lContinua := ParamBox(aParam,cParamTxt,@aConfig)
	
	If lContinua	
		If lQuant
			
			//***********************************
			//      Busca pre็o Unitario        *
			//***********************************
		    
			nPrecAgre := eVal(bVlrUnit,AM2->AM2_AGREG,AM1->AM1_CODIGO,_cVarPnj)
			If nPrecAgre<>nil
				if nPrecAgre == 0
					Aviso( STR0001 , "Item: " + ALLTRIM(AM2->AM2_AGREG) + STR0013 ,{ STR0014 }) //"Aten็ใo"###"Item: "###" sem valor m้dio/pre็o cadastrado."###"OK"
					lContinua := .F.
				EndIf
			Else
				lContinua := .F.					
			EndIf
		EndIf
	EndIf
	
ElseIf Len(aAuto) == 3
	
	aConfig := aclone(aAuto[1])
	lContinua := .T.

	If lQuant	
		nPrecAgre 	:= aAuto[2]
	EndIf	
EndIf

If lContinua
	
	cRegrDist 	:= aConfig[1]
	
	//******************************************************
	//      Valida็ใo da rotina de Receita Direta          *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX") + cId + AM1->AM1_CODIGO + _cVarPnj + cRegrDist ))
		
		Aviso( STR0001 , STR0015 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	If aAuto = NIL
		
		lContinua := PCOPnjRat(@aValores,"001",AM2->AM2_AGREG,.T.,cRegrDist)
		
	Else
		
		aValores := aClone(aAuto[3])
		
	EndIf
	
EndIf

If lContinua
	
	//******************************************
	//* Ajusta aValores com Data de e Data ate *
	//******************************************
	
	aBakVal 	:= aValores
	aValores 	:= {}
	aEval(aBakVal,{|x,y| aAdd(aValores,{x , aDataPlnj[y,1] , aDataPlnj[y,2]	}) })
	
	//*****************************************************************
	//    Rotina para defini็ใo do tipo de valor e tabela de pre็o    *
	//*****************************************************************
	cTipoValo := '1'
	
	//*********************************************************************
	//    Gera combina็ใo das entidades conforme regra de distribui็ใo    *
	//*********************************************************************
	PcoGerComb(cRegrDist,aValores,nPrecAgre,lQuant/*lQtd*/,/*cCodigo*/,"1"/*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)
	
	//****************************
	//   Rotina para Salvar ALX  *
	//****************************
	DbSelectArea("AMD")
	DbSetOrder(1)
	If DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO+cVarPnj) .and. !Empty(AMD->AMD_CODIGO)
		PcoGrvPLan(cId,"TMPDIS",AM1->AM1_CODIGO	,lQuant,,,,, {|| ALX->ALX_CODIGO := AMD->AMD_CODIGO } )
	Else
		PcoGrvPLan(cId,"TMPDIS",AM1->AM1_CODIGO	,lQuant)
	EndIf


	If cTmpArq != NIL
		MsErase(cTmpArq)
	EndIf

	//***********************************
	// Salva historico de planejamento  *
	//***********************************	
	PcoSavHist(AM1->AM1_CODIGO, _cVarPnj ,cRegrDist , {aConfig,nPrecAgre} )
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovRela บAutor  ณAcacio Egas         บ Data ณ 12/03/08 ณ         บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออฯอออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de movimentos relacionados a outros movimento.    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovRela(cId,nOpc,lQuant,bVlrUnit,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua	:= .F.
Local cParamTxt	:= STR0011 //"Distribui็ใo do Planejamento"
Local cRegrRela
Local cTipoPrec
Local cTabePrec
Local aPrecAgre	:= {}
Local nX		:= 1
Local aEntid,aPrdRelac
Local cIdRelac
Local cFiltroALX := ''
Local aMovVar	:= {}
Local aMovVar2

Default cSeek := ''

aAdd(aParam,{ 1, STR0016 ,SPACE(6),"@S6","ExistCpo('ALR')"	, "ALR", ".T."	,6	,.F.}) //"Regra Rec. Relacionadas"

DbSelectarea("AMD")
DbSetOrder(1)
DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	If AMD->AMD_TPVAR$"1"
		aAdd(aParam,{ 5, Capital(AMD->AMD_DESVAR) ,.F.,130,,.F.}) //
		aAdd(aMovVar,AMD->AMD_VARCOD)
	EndIf
	AMD->(DbSkip())
EndDo
DbSelectarea("ALX")
aAdd(aParam,{ 7, STR0017 ,"ALX",""}) //"Filtra Distribui็ใo"


If aAuto == NIL
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_002",,.T.)
	
ElseIf Len(aAuto)==2 .and. Len(aAuto[1])==Len(aParam)
	
	aConfig 	:= aclone(aAuto[1])
	aPrecAgre   := aclone(aAuto[2])
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrRela 	:= aConfig[1]
	If ! Empty(aConfig[Len(aConfig)])
		cFiltroALX 	:= PcoParseFil(aConfig[2],"ALX")
	EndIf
	cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
	
	//******************************************************
	//      Valida็ใo da rotina de Receita Relacionada     *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(4)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + AM1->AM1_CODIGO + _cVarPnj +cRegrRela ))
		
		Aviso( STR0001 , STR0018 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua

	aMovVar2 := {}
	aEval(aMovVar,{|x,y| if(aConfig[y+1],aAdd(aMovVar2,aMovVar[y]),.F.)})
	aMovVar	:= aClone(aMovVar2)
	lContinua	:= Len(aMovVar)>0
	
EndIf

If lContinua

	DbSelectArea("ALN")
	DbSetOrder(1)
	DbSeek(xfilial("ALN") + cRegrRela )
	While ! ALN->(Eof()) .and. ALN->ALN_FILIAL=xFilial("ALN") .and. ALN->ALN_CODIGO == cRegrRela
		

		If lQuant
			
			If Len(aPrecAgre)<nX
				//***********************************
				//      Busca pre็o Unitario        *
				//***********************************    
				aAdd(aPrecAgre,eVal(bVlrUnit,ALN->ALN_PROIND,AM1->AM1_CODIGO,_cVarPnj))
				lPcoAuto	:= .T.  
			EndIf

			If aPrecAgre[nX]<>nil
				if aPrecAgre[nX] == 0
					Aviso( STR0001 ,"Item relacionado: " + ALLTRIM(ALN->ALN_PROIND) + STR0020 ,{ STR0014 }) //"Aten็ใo"###"Item relacionado: "###"OK"
					lContinua	:= .F.
					Exit
				EndIf
			Else
				lContinua := .F.
				Exit
			EndIf
	    EndIf

		

		If lContinua
					
			cIdRelac := AM2->AM2_ID

			aEntid := { ALN->ALN_CO , ALN->ALN_CLASSE , ALN->ALN_OPER , ALN->ALN_CC , ALN->ALN_ITCTB , ALN->ALN_CLVLR }
			aPrdRelac :={ ALN->ALN_PROIND , aPrecAgre[nX] , cIdRelac}
			
			lContinua := PCOGerRelac( cId , aEntid , aPrdRelac , ALN->ALN_RELAC ,, cRegrRela , ALN->ALN_PERIOD , ALN->ALN_NRPERI , cFiltroALX,aMovVar)
			
			If lContinua
				//****************************
				//   Rotina para Salvar ALX  *
				//****************************				
				PcoGrvPLan(nil,"TMPRGR",AM1->AM1_CODIGO,.T.,cFiltroALX)
				
			EndIf
			
		EndIf
		nX++	
		ALN->(DbSkip())
	End

	//***********************************
	// Salva historico de planejamento  *
	//***********************************	
	PcoSavHist(AM1->AM1_CODIGO, _cVarPnj ,cRegrRela , {aConfig,aPrecAgre} )
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออัอออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovImpo บAutor  ณAcacio Egas         บ Data ณ 12/03/08 ณ         บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออฯอออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de movimentos impostos.                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovImpo(cId,nOpc,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local cRegrMovi
Local aEntid,aMov

Default cSeek 	:= ''

aAdd(aParam,{ 1, STR0021 , SPACE(6)	,"@S6","ExistCpo('AM5')"	, "AM5", ".T."	,40	,.F.}) //"Regra Mov. Relacionados"

DbSelectarea("AMD")
DbSetOrder(1)
DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
aMovVar	:= {}
Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	If AMD->AMD_TPVAR$"1,2"
		aAdd(aParam,{ 5, Capital(AMD->AMD_DESVAR) ,.F.,130,,.F.}) //
		aAdd(aMovVar,AMD->AMD_VARCOD)
	EndIf
	AMD->(DbSkip())
EndDo
aAdd(aParam,{ 7, STR0017 ,"ALX",""}) //"Filtra Distribui็ใo"


If aAuto == NIL .and. Len(aParam)>2
	//*******************
	// Nao e ExecAuto	*
	//*******************
	lContinua := ParamBox(aParam,cParamTxt,@aConfig)//,,,,,,,"PCOA490_003",,.T.)
	
ElseIf Len(aAuto)==Len(aParam)
	//*******************************************
	// ExecAuto tem que ter os mesmos parametro *	
	//*******************************************
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrMovi 	:= aConfig[1]
	aMovVar2 := {}
	aEval(aMovVar,{|x,y| if(aConfig[y+1],aAdd(aMovVar2,aMovVar[y]),.F.)})
	aMovVar	:= aClone(aMovVar2)
	cFiltroALX 	:= PcoParseFil(aConfig[Len(aConfig)],"ALX")
	
	cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	dbSelectArea("AM2")
	dbSetOrder(3)
	dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+AM1->AM1_CODIGO+cId)
	
	//******************************************************
	//      Valida็ใo da rotina de Movimento Relacionado   *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX") + cId + AM1->AM1_CODIGO + _cVarPnj + cRegrMovi ))
		
		Aviso( STR0001 , STR0018 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua

	DbSelectArea("ALP")
	DbSetOrder(1)
	DbSeek(xfilial("ALP") + cRegrMovi )
	While  !ALP->(Eof()) .and. ALP->ALP_FILIAL=xFilial("ALP") .and. ALP->ALP_CODIGO == cRegrMovi
		
		aEntid 		:= { ALP->ALP_CO , ALP->ALP_CLASSE , ALP->ALP_OPER , ALP->ALP_CC , ALP->ALP_ITCTB , ALP->ALP_CLVLR }
		aMov		:= { ALP->ALP_TIPO , ALP->ALP_VALUN, cId }
		lContinua 	:= PCOGerRelac( cId , aEntid , aMov ,, ALP->ALP_PERC , cRegrMovi , ALP->ALP_NRPERI ,, cFiltroALX, aMovVar)
		
		If lContinua
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			
			PcoGrvPLan(cId,"TMPRGR",AM1->AM1_CODIGO, (ALP->ALP_PERC==0),cFiltroALX )
			
		EndIf
		
		ALP->(DbSkip())
	End

	//***********************************
	// Salva historico de planejamento  *
	//***********************************	
	PcoSavHist(AM1->AM1_CODIGO, _cVarPnj ,cRegrMovi , aConfig )
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPcoContraP บAutor  ณAcacio Egas         บ Data ณ 12/03/08 ณ          บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออฯออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de Contra-partida de movimentos.                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoContraP(cId,nOpc,lQuant,bVlrUnit,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local nX
Local lGeraCust
Local aPrecAgre	:= {}
Local aCustRela
Local cQuery
Local cTipoDe,cTipoAte,cFiltroALX,cTipoValo

Default cSeek := ''

DbSelectarea("AMD")
DbSetOrder(1)
DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
aMovVar	:= {}
Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	//****************************************
	// Contra partida de quantidade so deve  *
	// ser gerado sobre movimentos de        *
	// quantidade.                           *
	//****************************************
	If _cVarPnj<>AMD->AMD_VARCOD
		If lQuant .and. AMD->AMD_TIPO=="1"
			aAdd(aMovVar,AMD->AMD_VARCOD)
			aAdd(aParam,{ 5, Capital(AMD->AMD_DESVAR) ,.F.,130,,.F.})
		ElseIf !lQuant
			aAdd(aMovVar,AMD->AMD_VARCOD)
			aAdd(aParam,{ 5, Capital(AMD->AMD_DESVAR) ,.F.,130,,.F.})
		EndIf
	EndIf
	AMD->(DbSkip())
EndDo
dbSelectArea("ALX")
aAdd(aParam,{ 7, STR0028 ,"ALX",""}) //"Filtro de Movimentos"

If aAuto == NIL
	//*******************
	// Nao e ExecAuto	*
	//*******************	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig)
	
ElseIf Len(aAuto)==2 .and. Len(aAuto[1])==Len(aParam)
	//*******************************************
	// ExecAuto tem que ter os mesmos parametro *	
	//*******************************************	
	aConfig 	:= aclone(aAuto[1])
	aPrecAgre	:= aclone(aAuto[2])
	lContinua := .T.
	
EndIf

If lContinua

	cFiltroALX	:= PcoParseFil(aConfig[Len(aConfig)],"ALX")

	cTpVar	:= ''
	aEval(aMovVar,{|x,y| if(aConfig[y],cTpVar	+= "'" + aMovVar[y] + "',",.F.)})
	    
	If Empty(cTpVar)
		lContinua	:= .F.
	Else
		cTpVar := SubStr(cTpVar,1,Len(cTpVar)-1) // Tira a ultima virgula
		If !Empty(cFiltroALX)
			cFiltroALX	+= " AND " 
		EndIf
		
		cFiltroALX	+= "ALX_VARPNJ IN (" + cTpVar + ")"
	
			
		cQuery	:= 	"SELECT ALX_AGREG,ALX_CODIGO FROM " + RetSqlName("ALX") + " WHERE ALX_FILIAL='" + xFilial("ALX") + "' AND D_E_L_E_T_ = ' '  AND ALX_AM2ID='" + cId + "'"
		If !Empty(cFiltroALX)
			cQuery	+= " AND " + cFiltroALX
		EndIf
		cQuery	+= 	" GROUP BY ALX_AGREG,ALX_CODIGO"
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPIT", .T., .T. )
		aItens	:= {}
		Do While !TMPIT->(Eof()) 
			If EMPTY(TMPIT->ALX_CODIGO)
				aAdd(aItens,{TMPIT->ALX_AGREG, "ALX_CODIGO =''" })
			Else
				aAdd(aItens,{TMPIT->ALX_CODIGO, "ALX_CODIGO ='" + TMPIT->ALX_CODIGO + "'" })
			EndIf
			TMPIT->(DbSkip())	
		EndDo
		TMPIT->(DbCloseArea())
	EndIf
EndIf

If lContinua

	For nX := 1 to Len(aItens)
		
		If lQuant .and. Len(aPrecAgre)<nX
			aAdd(aPrecAgre, eVal(bVlrUnit,aItens[nX,1],AM1->AM1_CODIGO,_cVarPnj))
			If aPrecAgre[nX]<>nil
				if aPrecAgre[nX] == 0
					Aviso( STR0001 , "Item: " + ALLTRIM(AM2->AM2_AGREG) + " sem custo cadastrado." ,{ STR0014 }) //"Aten็ใo"###"Item: "###" sem custo cadastrado."###"OK"
					lContinua := .F.                
				EndIf
			Else
				lContinua := .F.                
			EndIf
		EndIf

		cFiltroALX += If(Empty(cFiltroALX),""," AND ") + aItens[nX,2]

		lContinua := PcoGerContr(cId,lQuant,aPrecAgre[nX],cTpVar,cFiltroALX)

		If lContinua

			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			PcoGrvPLan(cId,"TMPRGR",AM1->AM1_CODIGO, .T. , cFiltroALX )

		EndIf
	Next
		
	//***********************************
	// Salva historico de planejamento  *
	//***********************************	
	PcoSavHist(AM1->AM1_CODIGO, _cVarPnj ,nil , {aConfig,aPrecAgre} )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovIni บAutor ณAcacio Egas         บ Data ณ 12/03/08  ณ          บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออฯออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de movimento por fun็ใo especifica.               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovIni(cId,nOpc,cVarPnj,lQuant,bVlrUnit,cSeek,aAuto)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoRotMov    บAutor ณAcacio Egas        บ Data ณ  02/03/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera novimento baseados nas tabelas de Roteiro de          บฑฑ
ฑฑบ          ณ movimentos e Movimentos Compostos.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoRotMov(cId,nOpc,cVarPnj,cSeek,aAuto)

Local nX
Local aArea 		:= GetArea()
Local aConfig		:= Array(1)
Local aParam		:= {}
Local aMovVar		:= {}
Local lContinua		:= .T.
Local cRoteiro 		:= ""
Local cMovsBase 	:= "" 
Local CTMPARQ 

dbSelectArea("AM3")
dbSetOrder(1)
dbSelectArea("AM6")
dbSetOrder(1)
dbSelectArea("AM7")
dbSetOrder(1)

DbSelectarea("AMD")
DbSetOrder(1)
DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	aAdd(aMovVar,AMD->AMD_VARCOD)
	AMD->(DbSkip())
EndDo

aAdd(aParam, { 1 , STR0149 , SPACE(Len(AM7->AM7_IDGRUP)), "@!", "ExistCpo('AM7')", "AM7", ".T.", 60, .F.} ) //"Regra Rec. Diretas"

If aAuto == NIL

	lContinua := ParamBox(aParam,STR0151,@aConfig)//"Selecionar Roteiro de Movimentos"
	cRoteiro := aConfig[1]
Else
	
	cRoteiro := aAuto[1]
	
EndIf

If lContinua

	If Empty(cRoteiro)
		
		lContinua	:= .F.
		
	EndIf

EndIf

If lContinua
	
	dbSelectArea("AM7")
	dbSetOrder(1)
	
	If dbSeek(xFilial("AM7")+cRoteiro) // Roteiro de Movimentos
		
		While AM7->(! Eof() .And. AM7_FILIAL + AM7_IDGRUP = xFilial("AM7") + cRoteiro )
			
			dbSelectArea("AM3") // Movimento Composto
			dbSetOrder(1)
			If dbSeek(xFilial("AM3")+AM7->AM7_GRUPO) .And. !Empty(AM3->AM3_REGPAD) .and. AM3->AM3_PERC>0

				dbSelectArea("AM6") // Base de Calculo do Movimento Composto
				dbSetOrder(1)
				lContinua	:= .F.
				If dbSeek(xFilial("AM6")+AM3->AM3_GRUPO)
					
					cMovsBase := ""
					
					While AM6->( ! Eof() .And. AM6_GRPPAI == AM3->AM3_GRUPO )
						//************************************
						// Concatena todas a Base de calculo *
						//************************************
						cMovsBase += "'" + Alltrim(PadR( AM6->AM6_GRCOMP, Len(ALX->ALX_CODIGO)) ) + "' ,"
						AM6->( dbSkip() )
					End				
					cMovsBase := "ALX_CODIGO IN (" + Subs(cMovsBase, 1, Len(cMovsBase)-1) + ") "
				    
					//***************************************************
					// Forca todas as Entidades com X para Agrupar tudo *
					//***************************************************
					aEntid 	:= { 'X' , 'X' , 'X' , 'X' , 'X' , 'X' }
					aMov	:= { AM3->AM3_GRUPO , AM3->AM3_VALOR, cId }
					PCOGerRelac( cId , aEntid , aMov ,, AM3->AM3_PERC , "" ,,,, aMovVar)
			
					If Select("TMPRGR")>0
						dbSelectArea("TMPRGR")
						dbGoTop()
						
						If ! Eof()
				
							aValor := {}	
				
							While ! Eof()
								
								aAdd(aValor, { TMPRGR->ALY_QUANT, TMPRGR->DATAPLNJ, TMPRGR->DATAFINA, TMPRGR->ALY_VALOR } )
											
								dbSelectArea("TMPRGR")
								dbSkip()
								lContinua	:= .T.
							End
						EndIf
				
						dbSelectArea("TMPRGR")
						dbCloseArea()
					EndIf
			
				ElseIf !Empty(AM3->AM3_FORMUL)
			
					// Monta aValores com Zero
					aValor := {}
					For nX := 1 To Len(_aListData)
				
						aAdd(aValor, { 0, DTOS(CTOD(Substr(_aListData[nX],1,8))) , DTOS(CTOD(Substr(_aListData[nX],14,8))) } )
						lContinua	:= .T.
					Next
			
				EndIf
				
				If lContinua
					//*********************************************
					// Gera combina็ใo na regra padrใo informada  *
					//*********************************************
					PcoGerComb(AM3->AM3_REGPAD,aValor, AM3->AM3_VALOR/*nPrecAgre*/, (AM3->AM3_TPVLR=='1') /*lQtd*/, AM3->AM3_GRUPO/*cCodigo*/,"1"/*cTipo*/,/*cRegrFilt*/,@cTmpArq)
					
					dbSelectArea("TMPDIS")
					dbGoTop()
					
					If ! Eof()
						
						PcoGrvPLan(cId,"TMPDIS",AM1->AM1_CODIGO,(AM3->AM3_TPVLR=='1'))
						
					Else
						
						dbSelectArea("TMPDIS")
						dbCloseArea()
						
					EndIf
					
					If cTmpArq != NIL
						MsErase(cTmpArq)
					EndIf
                Endif
			EndIf
			dbSelectArea("AM7")
			AM7->( dbSkip() )
			
		End

		//***********************************
		// Salva historico de planejamento  *
		//***********************************	
		PcoSavHist(AM1->AM1_CODIGO, cVarPnj ,nil , aConfig )

	EndIf	
	
EndIf

RestArea(aArea)

Return

//********************************
// FIM DOS TIPOS DE PLANEJAMENTO *
//********************************


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGerComb       บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica para gera็ใo das combina็๕es das entidades          บฑฑ
ฑฑบ          ณ cadastradas na regra de distribui็ใo                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoGerComb(ExpC1,ExpC2,ExpN1,ExpO1,ExpC3,ExpA1)                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Regra de Distribui็ใo (ALU)                                 บฑฑ
ฑฑบ          ณ Expc2 - Entidades nใo utlizadas.                                    บฑฑ
ฑฑบ          ณ Expa1 - Vetor com valores para distribui็ใo.                        บฑฑ
ฑฑบ          ณ Expn1 - Pre็o unitario do item do planejamento.                     บฑฑ
ฑฑบ          ณ Expl1 - Logico para controle por quantidade.                        บฑฑ
ฑฑบ          ณ Expc4 - Codigo a ser gravado.                                       บฑฑ
ฑฑบ          ณ Expc5 - Tipo de movimento.(1=Debito, 2=Credito)                     บฑฑ
ฑฑบ          ณ Expc6 - Entidade utilizada quando de distribui็ใo por filtro        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoGerComb(cRegrDist,aValor,nPrecAgre,lQtd,cCodigo,cTipo,cRegrFilt,cTmpArq)

Local cQryCpos
Local cQryPerc
Local cQryJoin
Local cQryValor
Local _nX
Local lVlr2			:= .F.
Local aCpos
Local cGrade		:= ""
Local cCampFilt

Default nPrecAgre	:= 0
Default lQtd		:= .T.
Default cCodigo		:= ' '
Default cTipo		:= ' '

PcoIni_VarStatic()

dbSelectARea("ALS")
dbSetOrder(1)

If ALS->(dbSeek(xfilial("ALS") + cRegrDist))

	cGrade := ALS->ALS_TPREGR

	If cGrade == "3"
		Do Case

			Case ALS->ALS_TPENTI == "AK5"
				cCampFilt := "ALO_CO"

			Case ALS->ALS_TPENTI == "AK6"
				cCampFilt := "ALO_CLASSE"

			Case ALS->ALS_TPENTI == "AKF"
				cCampFilt := "ALO_OPER"

			Case ALS->ALS_TPENTI == "CTT"
				cCampFilt := "ALO_CC"

			Case ALS->ALS_TPENTI == "CTD"
				cCampFilt := "ALO_ITCTB"

			Case ALS->ALS_TPENTI == "CTH"
				cCampFilt := "ALO_CLVLR"

		EndCase
	EndIf
EndIf

cQryCpos := "SELECT "
cQryCpos += "'" 		+ cRegrDist 		+ "' ALX_REGRA "
cQryCpos += ", '"	+ AM2->AM2_AGREG 	+ "' ALX_AGREG "
cQryCpos += ", '"	+ AM2->AM2_ID 		+ "' ALX_AM2ID "
cQryCpos += ", '"	+ cCodigo 			+ "' ALX_CODIGO "
cQryCpos += ", '"	+ cTipo 			+ "' ALX_TIPO "
cQryCpos += ", DATAPLNJ "
cQryCpos += ", DATAFINA "

cQryPerc := ""
cQryJoin := ""
aCpos := {	{"AK5","ALX_CO"}, ;
{"AK6","ALX_CLASSE"},;
{"AKF","ALX_OPER"},;
{"CTT","ALX_CC"},;
{"CTD","ALX_ITCTB"},;
{"CTH","ALX_CLVLR"}}

For _nX := 1 To Len(aCpos)

	If aScan( aEntNot , {|x| x[3]==aCpos[_nX,1] })==0
		If lInformix
			If cGrade$"23"
				cQryCpos += ", NVL(" + StrTran(aCpos[_nX,2], "ALX_", "ALO_") + ",' ') " + aCpos[_nX,2]
			Else
				cQryCpos += ", NVL(ALU"+StrZero(_nX,1)+".ALU_ENTIDA"+ ",' ') " + aCpos[_nX,2]
			EndIf
		ElseIf lOracle
			cQryCpos += ", NVL(" + aCpos[_nX,1] + ",' ') " + aCpos[_nX,2]
		ElseIf  lDB2 .Or. lPostgres
			cQryCpos += ", COALESCE(" + aCpos[_nX,1] + ",' ') " + aCpos[_nX,2]
		Else
			cQryCpos += ", ISNULL(" + aCpos[_nX,1] + ",' ') " + aCpos[_nX,2]
		EndIf

		// Monta Campo Valor
		If lInformix
			If ! (cGrade$"23")
				cQryPerc += " * (NVL(ALU"+StrZero(_nX,1)+".ALU_PERC,100) /100) "
			EndIf
		ElseIf lOracle
			cQryPerc += " * (NVL(" + aCpos[_nX,1] + "_PERC,100) /100) "
		ElseIf  lDB2 .Or. lPostgres
			cQryPerc += " * (COALESCE(" + aCpos[_nX,1] + "_PERC,100) /100) "
		Else
			cQryPerc += " * (ISNULL(" + aCpos[_nX,1] + "_PERC,100) /100) "
		EndIf
		
		If ! ( cGrade$"23" )
				
			If lInformix

				If _nX > 1
					// Monta From
					cQryJoin += " LEFT JOIN " +RetSqlName("ALU") + " ALU"+StrZero(_nX,1) 
					cQryJoin += " ON ALU"+StrZero(_nX,1) +".ALU_TPENTI = '"+aCpos[_nX,1]+"' "
				EndIf

			Else

				// Monta From
				cQryJoin += " LEFT JOIN "

				cQryJoin += " ( SELECT ALU_ENTIDA " + aCpos[_nX,1]
				cQryJoin += " ,ALU_PERC " + aCpos[_nX,1] + "_PERC"
				cQryJoin += " ,ALU_TPENTI " + aCpos[_nX,1]+ "TPENTID "
				cQryJoin += " FROM " + RetSqlName("ALU") + " ALU_" + StrZero(_nX,1) + " "
				cQryJoin += " WHERE "
				cQryJoin += " ALU_" + StrZero(_Nx,1) + ".ALU_TPENTI = '" + aCpos[_nX,1] + "' "
				cQryJoin += " AND ALU_CODIGO = '" + cRegrDist + "' "
				cQryJoin += " AND D_E_L_E_T_ = ' ' ) ALU_" + StrZero(_nX,1)

				cQryJoin += " ON " + aCpos[_nX,1] + "TPENTID='" + aCpos[_nX,1] +"' "

			EndIf

		EndIf
	Else
		cQryCpos += ", '" + &("M->"+aCpos[_nX,2]) + "'" + aCpos[_nX,2]
	EndIf

Next

If lInformix
	If cGrade$"23"
		cQryJoin += " WHERE ALO.ALO_CODIGO = '"+ cRegrDist +"'  AND ALO.D_E_L_E_T_ = ' ' "
	Else
		cQryJoin += " WHERE ALU1.ALU_TPENTI = '" + aCpos[1,1] +"'  AND ALU1.D_E_L_E_T_ = ' ' "
	EndIf	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for grade multiplica pelo percentual da tabela ALO ณ
//ณ(Hist๓rico de Distribui็ใo) e busca as entidades que  ณ
//ณestiverem nesta tabela                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cGrade$"23"

	If lInformix
		cQryPerc := "* (ALO.ALO_PERC /100) "
	Else
		cQryPerc := "* (PERC /100) "

		cQryJoin += " LEFT JOIN ( "
		cQryJoin += " SELECT "
		cQryJoin += " ALO_CODIGO "
		cQryJoin += ", ALO_CO AK5 "
		cQryJoin += ", ALO_CLASSE AK6 "
		cQryJoin += ", ALO_OPER AKF "
		cQryJoin += ", ALO_CC CTT "
		cQryJoin += ", ALO_ITCTB CTD "
		cQryJoin += ", ALO_CLVLR CTH "
		cQryJoin += ", ALO_PERC PERC "
		cQryJoin += " FROM " + RetSqlName("ALO") + " ALO "
		cQryJoin += " WHERE "
		cQryJoin += " ALO.ALO_CODIGO = '" + cRegrDist + "' "
		cQryJoin += " AND ALO.D_E_L_E_T_ = ' '"
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExecuta filtro caso seja regra de distribui็ใo por filtro (tipo 3)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cGrade == "3" .And. cRegrFilt <> NIL

		cQryJoin += "AND " + cCampFilt + " = '" + cRegrFilt + "' "

	EndIf

	If ! lInformix
		cQryJoin += " ) "
		cQryJoin += " ALO ON ALO_CODIGO = '" + cRegrDist + "' "
	EndIf

EndIf

//inicializa a quarta query
If lInformix
	cQryValor := " "
Else
	cQryValor := "("
EndIf

For _nX := 1 To Len(aValor)

	If _nX > 1

		cQryValor += " UNION "

	EndIf

	cQryValor += "SELECT "
	cQryValor += 		AllTrim(Str(	aValor[_Nx,1])) 	+ " VALOR "
	cQryValor += ", '" + 				aValor[_Nx,2] 		+ "' DATAPLNJ "
	cQryValor += ", '" + 				aValor[_Nx,3] 		+ "' DATAFINA "
	If Len(aValor[_Nx])>3

		cQryValor 	+= ", '" + AllTrim(Str(	aValor[_Nx,4])) 	+ "' VALOR2 "

		lVlr2 		:= .T.

	EndIf
	If lInformix
		cQryValor += "  FROM "+RetSqlName("AL2")+" AL2  "
		cQryValor += "  WHERE R_E_C_N_O_ IN "
		cQryValor += "  (SELECT MAX(R_E_C_N_O_) FROM "+RetSqlName("AL2")+" )  "
	Else
		If lOracle .OR. lDB2
			cQryValor += "  FROM (SELECT MAX(R_E_C_N_O_) FROM "+RetSqlName("AL2")+" ) AUXVLR "
		EndIf
	EndIf
Next

	If lInformix
		cQryValor += " "
	Else
		cQryValor += ") VL "
	EndIf

//monta query final
If lQtd
	// Controla Quantidade
	cQuery := cQryCpos
	// FORMULACAO PARA CALCULO DA DISTRIBUICAO (QUANTIDADE)
	cQuery += ", VALOR "
	cQuery += cQryPerc
	cQuery += " ALY_QUANT"

	If cGrade == '3'
		// FORMULACAO PARA CALCULO DA DISTRIBUICAO (VALOR)
		If lVlr2

			cQuery += ", VALOR2 "
			cQuery += cQryPerc
			cQuery += " ALY_VALOR"

		Else

			cQuery += "," + AllTrim(Str(nPrecAgre)) + " ALY_VALOR "

		EndIf

	Else

		// QUANDO RECEBE O VALOR UNITARIO
		cQuery += "," + AllTrim(Str(nPrecAgre)) + " ALY_VALOR "

	EndIf
	cQuery += " FROM "

	If lInformix
		cTmpArq := TmpQryValor(cQryValor)
		cQuery += cTmpArq+ Space(1)
		If cGrade$"23"
			cQuery += " , "+RetSqlName("ALO") + " ALO "
		Else
			cQuery += " , "+RetSqlName("ALU")+" ALU1 "
		EndIf
	Else
		cQuery += cQryValor
	EndIf

	cQuery += cQryJoin

Else
	// Controla valor
	cQuery := cQryCpos
	cQuery += ",0 ALY_QUANT"
	If cGrade == '3'
		// FORMULACAO PARA CALCULO DA DISTRIBUICAO (VALOR)
		If lVlr2

			cQuery += ", VALOR2 "
			cQuery += cQryPerc
			cQuery += " ALY_VALOR "

		Else

			cQuery += ", VALOR " + cQryPerc + " ALY_VALOR "

		EndIf
	Else

		// FORMULACAO PARA CALCULO DA DISTRIBUICAO (VALOR)
		If lVlr2

			cQuery += ", VALOR2 "
			cQuery += cQryPerc
			cQuery += " ALY_VALOR "

		Else

			cQuery += ", VALOR " + cQryPerc + " ALY_VALOR "

		EndIf

	EndIf
	cQuery += " FROM "

	If lInformix
		cTmpArq := TmpQryValor(cQryValor)
		cQuery += cTmpArq + Space(1)
		If cGrade$"23"
			cQuery += " , "+RetSqlName("ALO") + " ALO "
		Else
			cQuery += " , "+RetSqlName("ALU")+" ALU1 "
		EndIf
	Else
		cQuery += cQryValor
	EndIf

	cQuery += cQryJoin

EndIf

//cQuery += " ORDER BY AK5, AK6, AKF, CTT, CTD,  CTH, DATAPLNJ, DATAFINA "
cQuery += " ORDER BY ALX_CO, ALX_CLASSE, ALX_OPER, ALX_CC, ALX_ITCTB,  ALX_CLVLR, DATAPLNJ, DATAFINA "

//cQuery := ChangeQuery(cQuery) +  cQryValor // Se Jogar a cQryValor o ChangeQuery retorna com erro na query
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPDIS", .T., .T. )

Return

Static Function TmpQryValor(cQryValor)
Local cArqTmp
Local aStruct := {}
//define estrutura da tabela temporaria
aAdd(aStruct,{"VALOR","N", 18, 02})
aAdd(aStruct,{"DATAPLNJ","C", 8, 00})
aAdd(aStruct,{"DATAFINA","C",8, 00})

// Cria a tabela temporia direto no banco de dados	                					
cArqTmp := CriaTrab( , .F.)
MsErase(cArqTmp)

MsCreate(cArqTmp,aStruct, "TOPCONN")
Sleep(1000)

dbUseArea(.T., "TOPCONN",cArqTmp,cArqTmp/*cAlias*/,.F.,.F.)

//executa a query cQryValor
cQryValor := ChangeQuery(cQryValor)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQryValor), "TMPVLR", .T., .T. )
dbSelectArea("TMPVLR")
//grava resultado da query na tabela temporaria
While ! Eof()
		
		dbSelectArea(cArqTmp)
		RecLock(cArqTmp, .T.) 
		(cArqTmp)->VALOR := TMPVLR->VALOR
		(cArqTmp)->DATAPLNJ := TMPVLR->DATAPLNJ
		(cArqTmp)->DATAFINA := TMPVLR->DATAFINA
		MsUnLock()

		dbSelectArea("TMPVLR")
		dbSkip()
		
EndDo

dbSelectArea("TMPVLR")
dbCloseArea()

dbSelectArea(cArqTmp)
dbCloseArea()

Return(cArqTmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGerRelac      บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica para gerar Relacionamentos entre Planejamentos.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoGerRelac(ExpC1,ExpC2,ExpN1,ExpO1,ExpC3,ExpA1)                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - cId do item do planejamento.                                บฑฑ
ฑฑบ          ณ Expa1 - Vetor com Entidades a serem substituidas.                   บฑฑ
ฑฑบ          ณ Expa2 - Vetor com Produto, Preco E cId.                             บฑฑ
ฑฑบ          ณ Expn1 - Relacao entre quantidades.                                  บฑฑ
ฑฑบ          ณ Expn2 - Percentual de rela็ใo.                                      บฑฑ
ฑฑบ          ณ Expc2 - Regra Utilizada.                                            บฑฑ
ฑฑบ          ณ Expn3 - Periodo inicial a aplicar.                                  บฑฑ
ฑฑบ          ณ Expn4 - Numero de periodos de repeti็ใo.                            บฑฑ
ฑฑบ          ณ Expc3 - Condi็ใo SQL a aplicar.                                     บฑฑ
ฑฑบ          ณ Expc4 - Condi็ใo de Filtro ALX.                                     บฑฑ
ฑฑบ          ณ Expa3 - Vetor com tipos de planejamento.                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCOGerRelac(cId,aEntid,aItemRelac,nRelac,nPerc,cRegra,nPerIni,nPeriods,cFiltroALX,aTipoPl)

Local cQuery
Local cTipoPl		:= ''
Local lRet			:= .T.
Local _nX

Default nRelac		:= 0
Default nPerc		:= 0
Default nPerIni		:= 0
Default nPeriods	:= 0
Default cFiltroALX	:= ''
Default aTipoPl		:= {}

// Monta Transforma aTipoPl em cTipoPl para ser usado na query
For _nX := 1 To Len(aTipoPl)
	
	cTipoPl += "'" + aTipoPl[_nX] + "'" + If(_nX+1 <= Len(aTipoPl) , "," , "" )
	
Next

If aItemRelac[3] == NIL
	
	aItemRelac[3] := 'ALX_AM2ID'
	
Else
	
	aItemRelac[3] := "'"+aItemRelac[3]+"'"
	
EndIf

cQuery := "SELECT ALX_AGREG," + aItemRelac[3] + " ALX_AM2ID, '" + aItemRelac[1] + "' ALX_CODIGO,'" + "1" /*cTipoCtbl*/ + "' ALX_TIPO,"
cQuery += "'" + cRegra + "' ALX_REGRA, " + Str(nPerIni) + " PERIINI, " + Str(nPeriods) + "  NUMPERI, "

cQuery += IIf(Empty(aEntid[1])	,"ALX_CO "		,"'" + aEntid[1] + "'") + " ALX_CO, "
cQuery += IIf(Empty(aEntid[2])	,"ALX_CLASSE " 	,"'" + aEntid[2] + "'") + " ALX_CLASSE, "
cQuery += IIf(Empty(aEntid[3]) 	,"ALX_OPER "  	,"'" + aEntid[3] + "'") + " ALX_OPER, "
cQuery += IIf(Empty(aEntid[4])	,"ALX_CC "    	,"'" + aEntid[4] + "'") + " ALX_CC, "
cQuery += IIf(Empty(aEntid[5]) 	,"ALX_ITCTB " 	,"'" + aEntid[5] + "'") + " ALX_ITCTB, "
cQuery += IIf(Empty(aEntid[6]) 	,"ALX_CLVLR " 	,"'" + aEntid[6] + "'") + " ALX_CLVLR, "

If nRelac > 0 // Controla por rela็ใo entre um item principal e um relacionamento
	
	cQuery += "SUM(ALY_QUANT * " + Str(nRelac) + ") ALY_QUANT, " + Str(aItemRelac[2]) + " ALY_VALOR, "
	
ElseIf nPerc <> 0 // Controla por Percentual entre um Item principal e um relacionamento
	
	cQuery += "0 ALY_QUANT, SUM(ALY_VALOR * " + Str(nPerc / 100) + ") ALY_VALOR, "
	
ElseIf aItemRelac[2] > 0 // gera relacionado pelo valor unitario do mesmo, sobre a quantidade do item principal
	
	cQuery += " SUM(ALY_QUANT) ALY_QUANT, " + Str(aItemRelac[2]) + " ALY_VALOR, "
	
EndIf

cQuery += "ALY_DTINI DATAPLNJ,ALY_DTFIM DATAFINA "

cQuery += "FROM " + RetSqlName("ALX") + " ALX, " + RetSqlName("ALY") + " ALY "

cQuery += "WHERE "

cQuery += "( ALX.D_E_L_E_T_  = ' '  AND ALY.D_E_L_E_T_  = ' '  "
cQuery += "AND ALX.ALX_FILIAL = '" + xfilial("ALX")  + "' AND ALY_FILIAL = ALX_FILIAL "
cQuery += "AND ALX.ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ = ALX_PLANEJ "
cQuery += "AND ALX.ALX_VERSAO = '" + _cVerPlan + "' AND ALY_VERSAO = ALX_VERSAO "

If cId<>nil
	
	cQuery += "AND ALX.ALX_AM2ID = '" + cId + "' "
	
Else
	
	cQuery += "AND ALX.ALX_AGREG = '" + AM2->AM2_AGREG + "' "
	
EndIf

cQuery += "AND ALX_SEQ = ALY_SEQ "
cQuery += "AND ALX.ALX_TIPOPL = '" + AM1->AM1_CODIGO + "' "
cQuery += "AND ALX_VARPNJ IN (" + cTipoPl + ")  )"

If ! Empty(cFiltroALX)
	
	cQuery += "AND (" + cFiltroALX + ") "
	
EndIf

cQuery += "GROUP BY ALX_AGREG,ALX_AM2ID,ALX_TIPO,ALX_REGRA,ALX_CO,ALX_CLASSE,ALX_OPER,ALX_CC,ALX_ITCTB,ALX_CLVLR,ALY_DTINI,ALY_DTFIM "
cQuery += "ORDER BY 2, 8, 9, 10, 11, 12, 13, 16, 17"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPRGR", .T., .T. )

If TMPRGR->(Eof())
	lRet := .F.
	DbCloseArea()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGerContr      บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica para gerar Relacionamentos entre Planejamentos.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PCOGerContr(ExpC1,ExpC2,ExpN1,ExpO1,ExpC3,ExpA1)                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Id do Item do planejamento.                                 บฑฑ
ฑฑบ          ณ Expa1 - Vetor dos produtos,relacใo e pre็o.                         บฑฑ
ฑฑบ          ณ Expc2 - Tipo de Contra-partida.(1=Receita/Custo,2=Partida/Contra)   บฑฑ
ฑฑบ          ณ Expc3 - Tipo de planejamento a serem comtemplados.                  บฑฑ
ฑฑบ          ณ Expc4 - Condicao SQL a ser executada.                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOGerContr(cId,lQuant,nVlrUnit,TpVar,cSeek)

Local cQuery
Local lRet 	:= .T.

PcoIni_VarStatic()

//****************************************
//   Monta Query para Contra partida     *
//****************************************
If lInformix
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + cId + "' ALX_CODIGO,NVL(AM8.AM8_ID,' ') ALX_REGRA, "
ElseIf  lOracle
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + cId + "' ALX_CODIGO,NVL(AM9.AM8_ID,' ') ALX_REGRA, "
ElseIf lDB2 .Or. lPostgres
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + cId + "' ALX_CODIGO,COALESCE(AM9.AM8_ID,' ') ALX_REGRA, "
Else
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + cId + "' ALX_CODIGO,ISNULL(AM9.AM8_ID,' ') ALX_REGRA, "
EndIf

cQuery += "CASE WHEN (ALX.ALX_TIPO='1') THEN '2' ELSE '1' END ALX_TIPO,"

//CO
cQuery += "CASE WHEN (AM9.AM9_CO='') THEN ALX.ALX_CO ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
Else
	cQuery += "ISNULL(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
EndIf
//CLASSE
cQuery += "CASE WHEN (AM9.AM9_CLASSE='') THEN ALX.ALX_CLASSE ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
Else
	cQuery += "ISNULL(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
EndIf
//OPERACAO
cQuery += "CASE WHEN (AM9.AM9_OPER='') THEN ALX.ALX_OPER ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
Else
	cQuery += "ISNULL(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
EndIf
//CENTRO DE CUSTO
cQuery += "CASE WHEN (AM9.AM9_CC='') THEN ALX.ALX_CC ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
Else
	cQuery += "ISNULL(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
EndIf
//ITEM CONTABIL
cQuery += "CASE WHEN (AM9.AM9_ITCTB='') THEN ALX.ALX_ITCTB ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
Else
	cQuery += "ISNULL(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
EndIf
//CLASSE DE VALOR
cQuery += "CASE WHEN (AM9.AM9_CLVLR='') THEN ALX.ALX_CLVLR ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
Else
	cQuery += "ISNULL(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
EndIf

//SOMA DA QUANTIDADE
If lQuant
	cQuery += "SUM(ALY.ALY_QUANT) * "
Else
	cQuery += "SUM(ALY.ALY_VALOR) * "
EndIf
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_PERC/100,1) ALY_QUANT,"
ElseIf  lDB2 .Or. lPostgres 
	cQuery += "COALESCE(AM9.AM9_PERC/100,1) ALY_QUANT,"
Else
	cQuery += "ISNULL(AM9.AM9_PERC/100,1) ALY_QUANT,"
EndIf

If lQuant

	cQuery += Str(nVlrUnit) + " ALY_VALOR, "
	
EndIf
cQuery += "ALY.ALY_DTINI DATAPLNJ, ALY.ALY_DTFIM DATAFINA "
cQuery += "FROM " + RetSqlName("ALY") + " ALY, " + RetSqlName("ALX") + " ALX "

If lInformix
	cQuery += ",  " + RetSqlName("AM8") + " AM8, " + RetSqlName("AM9") + " AM9 "   //faz join na condicao (where)
Else
	//****************************************
	//     Join com da ALX e AM9             *
	//****************************************
	cQuery += "  LEFT JOIN "
	cQuery += "      (SELECT AM8_ID, AM8_CO , AM8_CLASSE, AM8_OPER, AM8_CC, AM8_ITCTB, AM8_CLVLR, AM9_CO , AM9_CLASSE, AM9_OPER, AM9_CC, AM9_ITCTB, AM9_CLVLR, AM9_PERC FROM " + RetSqlName("AM8") + " AM8, " + RetSqlName("AM9") + " AM9 WHERE AM8.D_E_L_E_T_=' ' AND AM9.D_E_L_E_T_=' ' AND AM8_FILIAL='01' AND AM9_FILIAL=AM8_FILIAL AND AM9_ID=AM8_ID) AM9
	cQuery += "      ON (AM8_CO=ALX_CO OR AM8_CO='') AND "
	cQuery += "         (AM8_CLASSE=ALX_CLASSE OR AM8_CLASSE='') AND "
	cQuery += "         (AM8_OPER=ALX_OPER OR AM8_OPER='') AND "
	cQuery += "         (AM8_CC=ALX_CC OR AM8_CC='') AND "
	cQuery += "         (AM8_ITCTB=ALX_ITCTB OR AM8_ITCTB='') AND "
	cQuery += "         (AM8_CLVLR=ALX_CLVLR OR AM8_CLVLR='') "
EndIf

cQuery += "WHERE "

If lInformix //passado o left join para condicao 
	cQuery += " AM8.D_E_L_E_T_=' '  "
	cQuery += " AND AM9.D_E_L_E_T_=' '  "
	cQuery += " AND AM8.AM8_FILIAL='01' "
	cQuery += " AND AM9.AM9_FILIAL=AM8.AM8_FILIAL "
	cQuery += " AND AM9.AM9_ID=AM8_ID "
	cQuery += " AND AM8.AM8_TIPO='1' "
	cQuery += " AND (AM8.AM8_CO=ALX.ALX_CO OR AM8.AM8_CO=' ') "
	cQuery += " AND (AM8.AM8_CLASSE=ALX.ALX_CLASSE OR AM8.AM8_CLASSE=' ') "
	cQuery += " AND (AM8.AM8_OPER=ALX.ALX_OPER OR AM8.AM8_OPER=' ')  "
	cQuery += " AND (AM8.AM8_CC=ALX.ALX_CC OR AM8.AM8_CC=' ') "
	cQuery += " AND (AM8.AM8_ITCTB=ALX.ALX_ITCTB OR AM8.AM8_ITCTB=' ') "
	cQuery += " AND (AM8.AM8_CLVLR=ALX.ALX_CLVLR OR AM8.AM8_CLVLR=' ') "
	cQuery += " AND "
EndIf
//condicao comum do where
cQuery += "ALX.ALX_FILIAL = '" + xfilial("ALX") + "' AND ALX.ALX_FILIAL = ALY.ALY_FILIAL AND "
cQuery += "ALX.D_E_L_E_T_ = ' ' AND ALY.D_E_L_E_T_ = ' ' AND "
cQuery += "ALX.ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND ALX.ALX_PLANEJ = ALY.ALY_PLANEJ AND "
cQuery += "ALX.ALX_VERSAO = '" + _cVerPlan + "' AND ALX.ALX_VERSAO = ALY.ALY_VERSAO AND "
cQuery += "ALX.ALX_TIPOPL = '" + AM1->AM1_CODIGO + "' AND "

//cQuery += " '" + TpVar + "' LIKE '%'+ALX_TIPOPL+'%' AND "
cQuery +=  " ALX.ALX_VARPNJ IN ( " + TpVar + ") AND "
If !Empty(cId)
	
	cQuery += "ALX.ALX_AM2ID = '" + cId + "' AND "
	
EndIf

If !Empty(cSeek)
	
	cQuery += cSeek + " AND "
	
EndIf

cQuery += "ALX.ALX_SEQ = ALY.ALY_SEQ "

cQuery += "GROUP BY ALX_AGREG,ALX_AM2ID, AM8_ID, ALX_TIPO,  ALX_CO, AM9_CO, ALX_CLASSE, AM9_CLASSE, ALX_OPER, AM9_OPER, ALX_CC, AM9_CC, ALX_ITCTB, AM9_ITCTB, ALX_CLVLR, AM9_CLVLR, AM9_PERC, ALY_DTINI, ALY_DTFIM "
cQuery += "ORDER BY 6, 7, 8, 9, 10, 11, 14, 15"
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPRGR", .T., .T. )

If TMPRGR->(Eof())
	lRet := .F.
	DbCloseArea()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGrvPlan       บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica para grava็ใo das tabelas ALX e ALY.                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoGrvPlan(Expc1,Expo2,Expc3,Expc4)                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Id do Item do Planejamento.                                 บฑฑ
ฑฑบ          ณ Expo2 - Objeto GetDados a ser atualizado.                           บฑฑ
ฑฑบ          ณ Expc2 - Alias utilizada para grava็ใo.                              บฑฑ
ฑฑบ          ณ Expc3 - Tipo de Planejamento a ser gravado.                         บฑฑ
ฑฑบ          ณ Expl1 - Logico para controle de quantidade.                         บฑฑ
ฑฑบ          ณ ExpC4 - Tipo de cแlculo da f๓rmula                                  บฑฑ
ฑฑบ          ณ ExpC5 - F๓rmula para cแlculo valores                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoGrvPlan(cId,cAliasTMP,cTipoVar,lQtd,cFiltroALX,cTipoForm,cFormRegr,cVlrCheio,bSave)

Local cEntiOrca := ""
Local nPosiInic := 0
Local aDataGrav := {}
Local nContItem
Local lAm2Id 	:= TYPE(cAliasTMP + '->ALX_AM2ID')=='C'
Local lTipoPl   := TYPE(cAliasTMP + '->ALX_TIPOPL')=='C'
Local lCodigo	:= TYPE(cAliasTMP + '->ALX_CODIGO')=='C'
Local lInc		:= .F.
Local nContPosi
Local cTipoMvto := ""
Local aBakVal	:= {}
Local lALXInc	:= ExistBlock("PCOALXINC")
Local lALYInc	:= ExistBlock("PCOALYINC")

Default cId  		:= "###"
Default lQtd 		:= .T.
Default cFiltroALX	:= ''
Default cVlrCheio 	:= "0"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a gravacao dos lancamentos do SIGAPCO              ณ
//ณ   Retirar comentario, caso sejแ necessario lan็amento On-Line ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PcoIniLan("000358")

aDataGrav 	:= {}
aBakVal 	:= {}
aEval(aBakVal,{|x,y| aAdd(aValores,{x , aDataPlnj[y,1] , aDataPlnj[y,2]	}) })
//aEval(_aListData,{|x|    ( aAdd( aDataGrav , DTOS(CTOD(Substr(x,1,8))) ) , aAdd(aBakVal,{x,0}) )  })
aEval(_aListData,{|x,y| ( aAdd( aDataGrav , aDataPlnj[y,1] ) , aAdd(aBakVal,{x,0}) )  })

dbSelectARea(cAliasTMP)

While ! (cAliasTMP)->(Eof())	
	
	If Type(cAliasTMP+'->'+'PERIINI')='N'
		nPeriInic := (cAliasTMP)->PERIINI
	Else
		nPeriInic := 0
	EndIf
	
	If Type(cAliasTMP+'->'+'NUMPERI')='N'
		nNumePeri := (cAliasTMP)->NUMPERI
	Else
		nNumePeri := 1
	EndIf
	
	If !(cAliasTMP)->( ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_CLVLR + ALX_ITCTB + If(lAm2Id,ALX_AM2ID,'') + If(lCodigo,ALX_CODIGO,'') ) == cEntiOrca
		
		//************************************************
		//ณ    Localiza ALX com a Chave a ser incluida.  *
		//************************************************
		
		If  ( lInc := !PcoChavALX( cAliasTMP , If( lTipoPl , (cAliasTMP)->ALX_TIPOPL , cTipoVar ) )   )
			cSequAtua := PcoALXSeq()
			
			// Grava dados de distribui็ใo
			Reclock("ALX",.T.)
			ALX_FILIAL 	:= xfilial("ALX")
			ALX_PLANEJ 	:= ALV->ALV_CODIGO
			ALX_VERSAO 	:= _cVerPlan
			ALX_AGREG	:= (cAliasTMP)->ALX_AGREG
			ALX_TIPOPL 	:= If( lTipoPl , (cAliasTMP)->ALX_TIPOPL , cTipoVar )
			ALX_TIPO 	:= (cAliasTMP)->ALX_TIPO
			
			// Grava Filtro para Reprocessamento
			If !Empty(cFiltroALX)
				ALX_FILTRO	:= cFiltroALX
			EndIf
			
			ALX_CODIGO 	:= (cAliasTMP)->ALX_CODIGO
			ALX_CO     	:= (cAliasTMP)->ALX_CO
			ALX_CLASSE 	:= (cAliasTMP)->ALX_CLASSE
			ALX_OPER   	:= (cAliasTMP)->ALX_OPER
			ALX_CC     	:= (cAliasTMP)->ALX_CC
			ALX_ITCTB  	:= (cAliasTMP)->ALX_ITCTB
			ALX_CLVLR  	:= (cAliasTMP)->ALX_CLVLR
			ALX_REGRA   := (cAliasTMP)->ALX_REGRA
			ALX_SEQ 	:= cSequAtua
			
			If lAM2Id
				
				ALX_AM2ID	:= (cAliasTMP)->ALX_AM2ID
				
			Else
				
				ALX_AM2ID	:= cId
				
			EndIf
			If ALX->(FieldPos("ALX_VARPNJ"))>0
				ALX_VARPNJ	:= _cVarPnj
			EndIf
			If ValType(bSave)=="B"
				Eval(bSave)
			EndIf
			MsUnlock()
			
			//**************************************
			// Ponto de entrada o fim da grava็ใo  *
			// da tabela ALX.                      *
			//**************************************		
			If lALXInc
				
				ExecBlock("PCOALXINC", .F., .F.)
				
			EndIf
			
		Else
			
			cSequAtua 	:= ALX->ALX_SEQ
			
		EndIf
		
		//**************************************
		// Tratamento de formula por Vigencia  *
		//**************************************
		
		If cTipoForm == "1" .And. ! Empty(cFormRegr)

			cVar := "M->FORMULA"
			&cVar := "FORMULA('" + cFormRegr + "')"
			__Readvar := "M->FORMULA"
			If Ctb080Form()
	
				nValoForm := Formula(cFormRegr)
				nValoForm := nValoForm / Len(_aListData)
	
			EndIf
	
		EndIf
	
	EndIf
	
	nContPeri := 1
	
	//****************************
	// Localiza Periodo Inicial  *
	//****************************
	nPosiInic := aScan(aDataGrav,Alltrim((cAliasTMP)->DATAPLNJ))
	nPosiInic += nPeriInic
	
	//***********************************************************
	//ณVarre lista de datas e atualiza dados dos planejamentos  *
	//ณrelacionados para o n๚mero de perํodos definido na regra *
	//***********************************************************
	nContPeri := 0
	For nContPosi := nPosiInic to Len(_aListData)
		
		If ALY->(!dbSeek(xfilial("ALY") + ALV->ALV_CODIGO + _cVerPlan + cSequAtua + aDataGrav[nContPosi]))
		
			Reclock("ALY",.T.)
			ALY_FILIAL := xfilial("ALY")
			ALY_PLANEJ := ALV->ALV_CODIGO
			ALY_VERSAO := _cVerPlan
			ALY_SEQ    := cSequAtua
			ALY_DTINI  := STOD(aDataPlnj[nContPosi,1])
			ALY_DTFIM  := STOD(aDataPlnj[nContPosi,2])
			MsUnlock()
			
		
		EndIf
	
		If cVlrCheio == "1"

			//***********************************************
			// Tratamento o valor da query como valor lotal *
			//*****************************
			
			RecLock("ALY",.F.)
			If lQtd
				ALY_QUANT := (cAliasTMP)->ALY_QUANT
				ALY_VALOR := (cAliasTMP)->ALY_VALOR
			Else
				ALY_VALOR := (cAliasTMP)->ALY_VALOR
			EndIf
			MsUnlock()			
		ElseIf !Empty(cFormRegr)
		
			//*****************************
			// Tratamento de formula      *
			//*****************************
		
			//************************
			// Formula por Periodo   *
			//************************
			
			If cTipoForm == "2" .And. ! Empty(cFormRegr)
				
				cVar := "M->FORMULA"
				&cVar := "FORMULA('" + cFormRegr + "')"
				__Readvar := "M->FORMULA"
				If Ctb080Form()
					nValoForm := Formula(cFormRegr)
				EndIf
			EndIf
			
			If !Empty(cFormRegr) .and. cTipoForm<>nil			
				RecLock("ALY",.F.)
					If lQtd // Controla Quantidade	
						ALY_QUANT  	+= nValoForm
						ALY_VALOR 	+= (nValoForm * (cAliasTMP)->ALY_VALOR)
					Else
						ALY_VALOR += nValoForm
					EndIf
				MsUnlock()
			EndIf
		
		Else
		
			//*********************************
			// Tratamento normal dos valores  *
			//*********************************

			RecLock("ALY",.F.)						
			If lQtd // Controla Quantidade
                
				If Alltrim(SuperGetMV('MV_PCOPNJ1',.T.,'2'))=='2'
					
					//******************************
					// Controla Resto dos Valores  *
					//******************************
					aBakVal[nContPosi,2] += (cAliasTMP)->ALY_QUANT - Int((cAliasTMP)->ALY_QUANT)
					// Soma oInteiro
					ALY_QUANT  += Int((cAliasTMP)->ALY_QUANT)
					ALY_VALOR 	+= ( Int((cAliasTMP)->ALY_QUANT) * (cAliasTMP)->ALY_VALOR )
					// Verifica Dizimas
					If aBakVal[nContPosi,2]>=1
						
						ALY_QUANT 	+= Int(aBakVal[nContPosi,2]) // Controla valores lan็ados
						ALY_VALOR 	+= ( Int(aBakVal[nContPosi,2]) * (cAliasTMP)->ALY_VALOR )
						aBakVal[nContPosi,2] := aBakVal[nContPosi,2] - Int(aBakVal[nContPosi,2])
						
					EndIf										
				Else
					
					ALY_QUANT  := Round((cAliasTMP)->ALY_QUANT,0)			
					ALY_VALOR := (ALY_QUANT*(cAliasTMP)->ALY_VALOR)
						
				EndIf
			Else // Controla Valor
			
				ALY_VALOR += (cAliasTMP)->ALY_VALOR

			EndIf
			MsUnlock()
			
		EndIf
				
		//**************************************
		// Ponto de entrada o fim da grava็ใo  *
		// da tabela ALY.                      *
		//**************************************		
		If lALYInc
			
			ExecBlock("PCOALYINC", .F., .F.)
			
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO         ณ
		//ณ   Retirar comentario, caso sejแ necessario lan็amento On-Line ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoDetLan("000358","01","PCOXPNJ")
		
		nContPeri ++
		If nContPeri >= nNumePeri
			
			Exit
			
		EndIf
	Next
	
	cEntiOrca := (cAliasTMP)->( ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_CLVLR + ALX_ITCTB + If(lAm2Id,ALX_AM2ID,'') + If(lCodigo,ALX_CODIGO,'') )
	
	(cAliasTMP)->(dbSkip())
	
End

// Inclui Sobras no Ultimo Periodo

If Alltrim(SuperGetMV('MV_PCOPNJ1',.T.,'2'))=='2'
	nTot := 0
	aEval(aBakVal,{|x| nTot+= x[2] })
	If nTot > 1
		
		RecLock("ALY",.F.)
		nPreco  	:= (ALY->ALY_VALOR / ALY->ALY_QUANT)
		ALY_QUANT 	:= (ALY->ALY_QUANT + Int(nTot))
		ALY_VALOR 	:= (ALY->ALY_QUANT) * nPreco
		MsUnLock()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO         ณ
		//ณ   Retirar comentario, caso sejแ necessario lan็amento On-Line ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//PcoDetLan("000358","01","PCOXPNJ")
		
	EndIf
	aEval(aBakVal,{|x,y| aBakVal[y,2] := 0 }) // Zera Totais
EndIf

(cAliasTMP)->(DbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a gravacao dos lancamentos do SIGAPCO                 ณ
//ณ   Retirar comentario, caso sejแ necessario lan็amento On-Line  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PcoFinLan("000358")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoLoadValบAutor  ณAcacio Egas         บ Data ณ  03/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Carregar ALY e atualizar varriaves da MSMGet   บฑฑ
ฑฑบ          ณ  auto-contida.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoLoadVal(aListDt,lQuant,lGrava,nVlUnit)

Local cSequencia
Local aListVeri	:= {}
Local Nx

Default lGrava	:= .F.
Default nVlUnit	:= 0

If ALX->(!Eof())
	cSequencia	:=  ALX->ALX_SEQ
EndIf

If ! lGrava .and. ! Empty(cSequencia)
	
	// Consulta valores na tabela ALY - Valores do Planejamento
	cQuery := "SELECT ALY_DTINI, ALY_QUANT,ALY_VALOR FROM " + RetSqlName("ALY") + " ALY" + " "
	cQuery += "WHERE ALY_DTINI >= '" + aListDt[1,1] + "' AND ALY_DTFIM <= '"
	cQuery += aListDt[Len(aListDt),2] + " ' "
	cQuery += "AND ALY_FILIAL='"+ xFilial("ALY") + "' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO = '" +_cVerPlan + "' "
	cQuery += "AND ALY_SEQ = '" + cSequencia + "' AND D_E_L_E_T_  = ' '  "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPVAL", .T., .T. )
	
	For Nx := 1 to Len(aListDt)
		
		aAdd(aListVeri,aListDt[Nx,1] )		
		If lQuant
			&('M->QTD' + StrZero(Nx,3)) := 0
		EndIf
		&('M->VLR' + StrZero(Nx,3)) := 0 // Alterar
		
	Next
	
	dbSelectARea("TMPVAL")
	dbGoTop()
	While ! TMPVAL->(Eof())
		
		nPosiValo := aScan(aListVeri,TMPVAL->ALY_DTINI)
		If lQuant
			&('M->QTD' + StrZero(nPosiValo,3)) := TMPVAL->ALY_QUANT
		EndIf
		&('M->VLR' + StrZero(nPosiValo,3)) := TMPVAL->ALY_VALOR
		
		TMPVAL->(dbSkip())
		
	End
	
	TMPVAL->(dbCloseArea())
	
ElseIf lGrava .and. !Empty(cSequencia) // Grava valores na Tabela de Planejamento
	
	PcoIniLan("000358")
	DbSelectArea("ALY")
	DbSetOrder(1)
	For Nx :=1 To Len(aListDt)
		
		If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cSequencia + aListDt[Nx,1] )

			RecLock("ALY",.F.)
			If lQuant
				ALY_QUANT 	:= &('M->QTD' + StrZero(Nx,3))
				ALY_VALOR 	:= (&('M->QTD' + StrZero(Nx,3))*nVlUnit)
			Else
				ALY_VALOR 	:= &('M->VLR' + StrZero(Nx,3))
			EndIf
			MsUnlock()
			
		Else
			
			RecLock("ALY",.T.)
			ALY_FILIAL 	:= xfilial("ALY")
			ALY_PLANEJ 	:= ALV->ALV_CODIGO
			ALY_VERSAO 	:= _cVerPlan
			ALY_SEQ 	:= cSequencia
			ALY_DTINI 	:= STOD(aListDt[Nx,1])
			ALY_DTFIM 	:= STOD(aListDt[Nx,2])
			If lQuant
				ALY_QUANT 	:= &('M->QTD' + StrZero(Nx,3))
				ALY_VALOR := &('M->QTD' + StrZero(Nx,3)) * nVlUnit
			Else
				ALY_VALOR 	:= &('M->VLR' + StrZero(Nx,3))
			EndIf
			MsUnlock()
			
		EndIf
		PcoDetLan("000358","01","PCOXPNJ")
	Next
	PcoFinLan("000358")
Else
	
	For Nx := 1 to Len(aListDt)
		
		If lQuant
			&('M->VLR' + StrZero(Nx,3)) := 0 // Alterar
		EndIf
		&('M->QTD' + StrZero(Nx,3)) := 0 // Alterar
	Next
	If lGrava
		
		Aviso("Aten็ใo","Nใo hแ uma distribui็ใo selecionada",{"Ok"})
		
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoALXSeq บAutor  ณMicrosiga           บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza o proximo numero sequancial no campo ALX_SEQ.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoALXSeq()

PcoIni_VarStatic()

//inicia o semaforo
While !LockByName(xFilial("ALX")+"PROXSEQ_ALX",.T.,.T.,.T.)
	Sleep(1)
EndDo

If lOracle .Or. lInformix
	cQuery0 := "SELECT NVL(MAX(ALX_SEQ) ,'0') MAX FROM " + RetSqlName("ALX") + " "
ElseIf  lDB2 .Or. lPostgres 
	cQuery0 := "SELECT COALESCE(MAX(ALX_SEQ),'0') MAX FROM " + RetSqlName("ALX") + " "
Else
	cQuery0 := "SELECT ISNULL(MAX(ALX_SEQ) ,'0') MAX FROM " + RetSqlName("ALX") + " "
EndIf
cQuery0 += "WHERE ALX_FILIAL = '"+ xFilial("ALX") +"' AND ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' "
cQuery0 += "AND ALX_VERSAO = '" + _cVerPlan + "' AND D_E_L_E_T_  = ' ' "
cQuery0 := ChangeQuery(cQuery0)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery0), "TMPALX", .T., .T. )
nProxSequ := VAL(TMPALX->MAX)+1
TMPALX->(DbCloseArea())

//termina o semaforo 
UnLockByName(xFilial("ALX")+"PROXSEQ_ALX",.T.,.T.,.T.)

Return( StrZero(nProxSequ,9) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoDelMovs บAutor  ณJoใo Gon็alves de Oliveira บ Data ณ 08/02/08        บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออฯออออออฯอออออออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Excluir valores de planejamento                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoDelMovs(ExpC1,ExpC2)                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ ExpC1 - Agregador da distribui็ใo                                       บฑฑ
ฑฑบ          ณ ExpC2 - C๓digo do Tipo de Planejamento (Tabela AM1)                     บฑฑ
ฑฑบ          ณ ExpC3 - Objeto GetDados a ser atualizado.                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoDelMovs(cId,VarPnj,oGetDados,cSeq,cSeek)

Local cUpdate := ""
Local cVarPnj := If( VALTYPE(VarPnj)=="C" , VarPnj , "" )

PcoIni_VarStatic()

cUpdate := "SELECT ALY.R_E_C_N_O_ RECNO "
cUpdate += "FROM " + RetSqlName("ALY") + " ALY," + RetSqlName("ALX") + " ALX "
cUpdate += "WHERE ALX.D_E_L_E_T_=' ' AND ALY.D_E_L_E_T_=' ' AND "
cUpdate += "ALX_FILIAL = '" + xfilial("ALX") + "' AND ALY_FILIAL=ALX_FILIAL AND "
cUpdate += "ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND "
cUpdate += "ALX_VERSAO = '" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "

If cId<>nil
	
	cUpdate += "ALX_AM2ID = '" + cId + "' AND "
	
ElseIf cSeq <> nil
	
	cUpdate += "ALX_SEQ = '" + cSeq + "' AND "
	
EndIf

If cSeek<>nil
	
	cUpdate +=  cSeek + " AND "
	
EndIf

If VALTYPE(VarPnj)=="C"
	
	cUpdate += "ALX_VARPNJ = '" + cVarPnj + "' "
	
ElseIf VALTYPE(VarPnj)=="A"
	
	cVarPl := ''
	aEval( VarPnj , {|x,y| cVarPl += "'" + x + "'" + If( Len(VarPnj)==y , ") " , "," ) } )
	cUpdate += " AND ALX_VARPNJ IN (" + cVarPl
	
EndIf

cUpdate += " AND ALY_SEQ=ALX_SEQ "
cUpdate += " GROUP BY ALY.R_E_C_N_O_

dbUseArea( .T., "TOPCONN", TcGenQry(,,cUpdate), "TMPALY", .T., .T. )

PcoIniLan("000358")

While TMPALY->(!Eof())

	DbSelectArea("ALY")
	DbGoTo( TMPALY->RECNO )

	PcoDetLan("000358","01","PCOXPNJ",.T.)

	RecLock("ALY",.F.,.T.)
		DbDelete()
	MsUnlock()

	TMPALY->(DbSkip())

EndDo

PcoFinLan("000358")

TMPALY->(DbCloseArea())


cUpdate := "UPDATE " + RetSqlName("ALX") + " SET D_E_L_E_T_ = '*' "
cUpdate += " WHERE ALX_FILIAL = '" + xfilial("ALX") + "' AND "
cUpdate += " ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND "
cUpdate += " ALX_VERSAO = '" + _cVerPlan + "' AND "

If cId <> NIL
	cUpdate += " ALX_AM2ID = '" + cId + "' AND "
ElseIf cSeq<>nil
	cUpdate += " ALX_SEQ = '" + cSeq + "' AND "
EndIf
If cSeek<>Nil
	cUpdate +=  cSeek + " AND "
EndIf

If VALTYPE(VarPnj)=="C"
	
	cUpdate += "ALX_VARPNJ = '" + VarPnj + "' AND "
	
ElseIf VALTYPE(VarPnj)=="A"
	
	cVarPl := ''
	aEval( TipoPlan , {|x,y| cVarPl += "'" + x + "'" + If( Len(VarPnj)==y , ") " , "," ) } )
	cUpdate += "ALX_VARPNJ IN (" + cVarPl + " AND "
	
EndIf

cUpdate += " D_E_L_E_T_ = ' ' "
TcSqlExec( cUpdate )
TcRefresh(RetSqlName("ALX"))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoPrcPlan บAutor  ณAcacio Egas        บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza Pre็o para planejamento.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Function PcoPrcPlan(cAgregador,cTipoVar,cTipoValo,cTabePrec)
Local nPrecAgre := 0

If cTipoVar == "005"
	dbSelectArea("ALT")
	If ALT->(dbSeek(xfilial("ALT") + cAgregador))
		nPrecAgre := ALT->ALT_VALOR
	EndIf
ElseIf cTipoVar == "006"
	dbSelectArea("AM4")
	If AM4->(dbSeek(xfilial("AM4") + cAgregador))
		nPrecAgre := AM4->AM4_VALOR
	EndIf
Elseif cTipoVar == "004"

Else

EndIf

If ExistBlock("PNJXPREC")
	
	nPrecAgre := ExecBlock("PNJXPREC", .F., .F., cAgregador,cTipoVar)
	
EndIf

Return(nPrecAgre)
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoAltPnj   ณ Autor ณJoใo Gon็alves de Oliveira ณ Data ณ 06/01/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que altera os valores de planejamento                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAPCO                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoAltPnj(cId,cSeek,aAuto,cTipoPl)

Local lContinua		:= .F.
Local aConfig		:= {}
Local aTipos		:= { STR0045 , STR0046 } //"Por Percentual Normal"###"Por Percentual Embutido"
Local aCalculo		:= { STR0047 , STR0048 , STR0049 } //"Somar"###"Diminuir"###"Substituir Valor"
Local cFiltroALX
Local cStrTpPl
Local aMovVar		:= {}
//Local lReceita
Local lRelac		:= Empty(cSeek) //.or. Empty(cId)
Local aParam		:= {}
Local cUpdate
Local cCodigo		:= ''

Default cSeek		:= ""

//Validacao se a ACAO pode ser Executado em Relacao a Fase Atual.
If !PCOvldFase("AMH",ALV->ALV_FASE,"0007",.t.)	// 0007 -> Ver Cadastro de ACAO (AMI)
	Return
Endif
DbSelectArea("ALX")

DbSelectarea("AMD")
DbSetOrder(1)
DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	aAdd(aParam,{ 5, Capital(AMD->AMD_DESVAR) ,.F.,130,,.F.}) //
	aAdd(aMovVar,AMD->AMD_VARCOD)
	AMD->(DbSkip())
EndDo

aAdd(aParam , {3, STR0050 ,1,aTipos,130,"",.F.} 	) //"Tipo de Reajuste"
aAdd(aParam , {3, STR0051 ,1,aCalculo,130,"",.F.} 			) //"Operacao"
aAdd(aParam , {1, STR0052 ,0		 ,"@E 9,999,999,999.99","","","",100,.T.} 	) //"Valor ou Percentual"
aAdd(aParam , {1, STR0053 ,CtoD(Space(8)),"@D"                 ,"","","",100,.T.}	) //"Data Inicial Periodo"
aAdd(aParam , {1, STR0054 ,CtoD(Space(8)),"@D"                 ,"","","",100,.T.}	) //"Data Final do Periodo"
aAdd(aParam , {7, STR0017 ,"ALX",""}			) //"Filtra Distribui็ใo"


If aAuto==nil
	
	If ParamBox( aParam , STR0055 , @aConfig ) //"Parametros"

		cFiltroALX 	:= PcoParseFil(aConfig[Len(aConfig)],"ALX")
		If !Empty(cSeek)
			
			cFiltroALX 	:= cSeek + If( !Empty(cFiltroALX) , " AND " + cFiltroALX , "" )
			
		EndIf
		aConfig[Len(aConfig)] := cFiltroALX
		lContinua := .T.
	EndIf
	
ElseIf Len(aAuto)==Len(aParam)
	
	aConfig 	:= aAuto
	cFiltroALX	:= aConfig[Len(aConfig)]
	lContinua	:= .T.
	
EndIf

If lContinua .And. (Empty(aConfig[Len(aMovVar)+4]) .Or. Empty(aConfig[Len(aMovVar)+5]))
	
	Aviso( STR0001 , STR0056 ,{ STR0057 },2) //"Atencao"###"Nao informado o periodo a ser reajustado!"###"Fechar"
	lContinua := .F.
	
EndIf

If lContinua

	cTpVar	:= ''
	aEval(aMovVar,{|x,y| if(aConfig[y],cTpVar	+= "'" + aMovVar[y] + "',",.F.)})
	    
	If Empty(cTpVar)
		lContinua	:= .F.
	Else
		cTpVar := SubStr(cTpVar,1,Len(cTpVar)-1) // Tira a ultima virgula
	EndIf

EndIf

If lContinua

	cUpdate 	:= "SELECT ALX.*,ALY_DTINI AS DATAPLNJ, ALY_DTFIM AS DATAFINA,0 AS ALY_QUANT ,"
	nNumeAdic 	:= IIf(aConfig[Len(aMovVar)+1] == 1,aConfig[Len(aMovVar)+3] / 100,aConfig[Len(aMovVar)+3])
	
	// Somente Valor
	If aConfig[Len(aMovVar)+2] < 3
		
		cUpdate += "(ALY_VALOR * " +  AllTrim(Str(IIf(aConfig[Len(aMovVar)+2] == 1,1 + nNumeAdic,1 - nNumeAdic))) + ") AS ALY_VALOR "
		
	Else
		
		cUpdate += Str(aConfig[Len(aMovVar)+3]) + " AS ALY_VALOR" "
		
	EndIf
	cUpdate += "FROM " + RetSqlName("ALX") + " ALX, " + RetSqlName("ALY") + " ALY "
	cUpdate += "WHERE ALX_FILIAL='"+ xFilial("ALX") +"' AND ALY_FILIAL=ALX_FILIAL AND "
	cUpdate += "ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND "
	cUpdate += "ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "
	cUpdate += "ALX.D_E_L_E_T_=' ' AND ALY.D_E_L_E_T_=' ' AND "
	cUpdate += "ALY_SEQ=ALX_SEQ AND "
	cUpdate += "ALY_DTINI >= '" + DTOS(aConfig[Len(aMovVar)+4]) + "' AND ALY_DTFIM <= '" + DTOS(aConfig[Len(aMovVar)+5]) + "' AND "
	
	cUpdate += "ALX_TIPOPL ='" + cTipoPl + "' AND "
	cUpdate += "ALX_VARPNJ IN (" + cTpVar + ") AND "	
	cUpdate += "ALX_AM2ID = '" + cId + "'"
	
	cUpdate	:= ChangeQuery( cUpdate )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cUpdate), "TMPREA", .T., .T. )
	
	If TMPREA->(!Eof())
		
		PcoGrvPlan(cId/*cId*/,"TMPREA",/*cTipoVar*/,.F./*lQtd*/,/*cFiltroALX*/,/*cTipoForm*/,/*cFormRegr*/,"1")

		//***********************************
		// Salva historico de planejamento  *
		//***********************************	
		PcoSavHist(AM1->AM1_CODIGO, "XX" ,nil , aConfig )
			
	Else
		
		TMPREA->(DbCloseArea())
		
	EndIf

EndIf

Return(lContinua)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoPnjRat        บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Chama wizard para atualiza็ใo de valores de planejamento            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoPnjRat(ExpA1,ExpC1,ExpC2,ExpL1)                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ ExpA1 - Vetor com informa็๕es dos valores                           บฑฑ
ฑฑบ          ณ ExpC1 - C๓digo do tipo de planejamento                              บฑฑ
ฑฑบ          ณ ExpC2 - C๓digo do agregador (Produto, Tipo Despesa, etc).           บฑฑ
ฑฑบ          ณ ExpL1 - Determina se serแ informado quantidade ou valor             บฑฑ
ฑฑบ          ณ ExpC3 - Regra de Distribui็ใo Utilizada                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoPnjRat(aValores,cTipoVar,cAgregador,lInfoQtde,cRegrDist,lFormula)
Local oWizard
Local cArquivo
Local lRet 		:= .F.
Local nX
Local lFormValo := .F.

//					  	 Wizard 01					Wizard 02					 Wizard 03	 Wizard 04
Private aConfigs := {{ 1, 1, .T., .F.}	,{ALV->ALV_INIPER, ALV->ALV_FIMPER, 0}	,{}			,{}			}
Private aPeriodo
Private lAllPeriod := .F.

Do Case
	Case cTipoVar == "005"
		dbSelectArea("ALT")
		dbSetOrder(1)
		If ALT->(dbSeek(xfilial("ALT") + cAgregador))
			lFormValo := ! Empty(ALT->ALT_FORMUL)
		EndIf
	Case cTipoVar == "006"
		dbSelectArea("AM4")
		dbSetOrder(1)
		If AM4->(dbSeek(xfilial("AM4") + cAgregador))
			lFormValo := ! Empty(AM4->AM4_FORMUL)
		EndIf
EndCase

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNใo executa tela de distribui็ใo dos valores por perํodo, casoณ
//ณa distribui็ใo nใo utilize percentual ou seja distribui็ใo porณ
//ณfiltro.                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ENDDOC*/
dbSelectARea("ALS")
dbSetOrder(1)
If ALS->(dbSeek(xfilial("ALS") + cRegrDist)) .And. (ALS->ALS_TPPERC == "2" .Or. lFormValo)
	
	aValores := Array(Len(_aListData))
	aFill(aValores,0)
	Return(.T.)
	
EndIf                                                                                                                                 ,

mv_par01 := 1
mv_par02 := 1
mv_par03 := .T.
mv_par04 := .F.
cTextValo := IIf(lInfoQtde,'1','2')

oWizard := APWizard():New( STR0001 ,IIf(lInfoQtde, STR0058 , STR0059 ) + STR0060 ,;
IIf(lInfoQtde, STR0061 , STR0062 )/*<cTitle>*/,;
IIf(lInfoQtde, STR0063 , STR0064 ) + CRLF + CRLF + STR0065 + Alltrim(ALV->ALV_CODIGO) + " - " +;
PadR(ALV->ALV_DESCRI,50) + CRLF + CRLF + STR0012 + cAgregador + CRLF + CRLF + STR0066 + cTipoVar /*<cText>*/,;
{||.T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/,/*<.lPanel.>*/, , , /*<.lNoFirst.>*/) 

//"Atencao"###"Este assistente lhe ajudara a ratear uma determinada quantidade"###"Este assistente lhe ajudara a ratear um determinado valor"###" para os periodos do Planejamento atual"
//"Rateio de quantidades para o Planejamento"###"Rateio de valores para o Planejamento"
//"Voce devera escolher a forma do rateio e ao finalizar o assistente, esta quantidade serแ rateada conforme os parametros solicitados."###"Voce devera escolher a forma do rateio e ao finalizar o assistente, este valor serแ rateado conforme os parametros solicitados."###"Planejamento : "
//"Agregador : "###"Tp. Planejamento.: "
oWizard:NewPanel(IIf(lInfoQtde, STR0067 , STR0068 ), STR0069 ,{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/,;
{|| PnjWizard(@oWizard,1)}/*<bExecute>*/ )
//"Rateio de quantidades"###"Rateio de valores"###"Neste passo voce deverแ informar a forma do rateio para o planejamento orcamentaria."

oWizard:NewPanel( STR0070 , IIf(lInfoQtde, STR0071 , STR0072 ),;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel .>*/, ;
{||PnjWizard(@oWizard,2)}/*<bExecute>*/ )
//"Periodo para o rateio"###"Neste momento deverแ ser informado o periodo a ser considerado a quantidade a ser rateado."###"Neste momento deverแ ser informado o periodo a ser considerado o valor a ser rateado."

oWizard:NewPanel( STR0073 , STR0074 , ;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/, ;
{||PnjWizard(@oWizard,3)}/*<bExecute>*/ )
//"Percentuais para os periodos "###"Neste passo voce deverแ informar os percentuais a serem considerados para o rateio."

oWizard:NewPanel( IIf(lInfoQtde, STR0075 , STR0076), IIf(lInfoQtde, STR0077 , STR0078 ),;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||aValores := aClone(aConfigs[4]),lRet := .T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/,;
{||PnjWizard(@oWizard,4)}/*<bExecute>*/ )
//"Distribui็ใo das quantidades."###"Distribui็ใo dos valores."###"Confirme as quantidades que serao rateados(as) para os periodos. "###"Confirme os valores que serao rateados(as) para os periodos. "

oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/, ;
{||.T.}/*<bInit>*/, ;
{||.T.}/*<bWhen>*/ )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PnjWizardบAutor  ณAcacio Egas                  บ Data ณ 12/03/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Chama wizard para atualiza็ใo de valores de planejamento            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expo1 - Objeto Wizard.                                              บฑฑ
ฑฑบ          ณ Expn1 - Numero da janela do Wizard.                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PnjWizard(oWizard,nNivel)
Local nX
Local nRest

Do Case
	
	Case nNivel==1
		
		aParametros := {{3, STR0079 , 1,{ STR0080 , STR0081 }	,160,,.F.}, ;
		{3, STR0082 , 1,{ STR0083 , STR0084 },160,,.F.}, ;
		{4,"",.T., STR0085 ,165,.F.,.F.}, ;
		{4,"",.F., STR0086 ,165,.F.,.F.} }
		//"Parametros para o Rateio"###"Todos os Periodos "###"Informar o Periodo"
		//"Ratear percentuais diferenciados"###"Sim"###"Nao"
		//"Sugerir percentuais para os periodos"
		//"Sugerir quantidade informada para os periodos"
		
	Case nNivel==2
		
		aParametros := {{ 1 , STR0087 , ALV->ALV_INIPER ,"@D" 	 ,""  ,"" ,"lAllPeriod" ,65 ,.T. }, ;
		{ 1 , STR0088 , ALV->ALV_FIMPER ,"@D" 	 ,""  ,"" ,"lAllPeriod" ,65 ,.T. }, ;
		{ 1 , STR0089 , 0 ,"@E 999,999,999.99" 	 ,""  ,"" ,"" 	,65 ,.T. } }
		//"Data inicial"
		//"Data final"
		//"Valor a ser rateado"
		
		
	Case nNivel==3
		
		aPeriodo := PcoRetPer(aConfigs[2][1],aConfigs[2][2],ALV->ALV_TPPERI,.F.)
		aParametros := {}
		aConfigs[3] := {}
		If aConfigs[1][3] .OR. aConfigs[1][4]
			
			If aConfigs[1][4]
				
				nPercDef := 100
				
			Else
				
				nPercDef := 100/Len(aPeriodo)
				
			EndIf
			
		Else
			
			nPercDef := 0
			
		EndIf
		aAdd(aParametros, {4, STR0090 ,aConfigs[1][3],"  ",165,.F.,.F.}) //"Informar Percentuais"
		aAdd(aConfigs[3], aConfigs[1][3])
		For nX := 1 TO Len(aPeriodo)
			
			aAdd(aParametros,{ 1 ,aPeriodo[nX], nPercDef ,"@E 999.9999 %" 	 ,""  ,"" ,If(aConfigs[1][2]==1,".T.",".F."),65 ,.T. })
			aAdd(aConfigs[3], nPercDef)
			
		Next
		
	Case nNivel==4
		
		aParametros := {}
		aConfigs[4] := {}
		nRest := 0
		For nX := 2 TO Len(aPeriodo)+1
			
			If aConfigs[3][nX] > 0
				
				// Controle de Resto
				nValorRat := Round(aConfigs[2][3]*(aConfigs[3][nX]/100),4)
				nRest += (nValorRat-Int(nValorRat))
				nValorRat := Int(nValorRat)
				// Verifica se Sobras >= 1
				If nRest>=1
					
					nValorRat := Int(nRest) + nValorRat // Controla valores lan็ados
					nRest := nRest - Int(nRest)
					
				EndIf
				
				aAdd(aParametros,{ 1 ,aPeriodo[nX-1], nValorRat ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. })
				aAdd(aConfigs[4], nValorRat)
				
			Else
				
				aAdd(aParametros,{ 1 ,aPeriodo[nX-1], 0 ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. })
				aAdd(aConfigs[4], 0)
				
			EndIf
			
		Next
		// Fim do Resto
		aConfigs[4][Len(aConfigs[4])] := Round(aConfigs[4][Len(aConfigs[4])] + nRest,0)
		
EndCase

ParamBox(aParametros 	, STR0055 , @aConfigs[nNivel],,,.F.	,120,3	, oWizard:oMPanel[oWizard:nPanel],/*"PCOA490_"+ALLTRIM(STR(nNivel))*/,.F. ) //"Parametros"

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o   ณ PcoDelePnjณ Autor ณAcacio Egas            ณ Data     ณ 10/04/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…oณ Exclui todos os dados quando da exclusใo da planilha de        ณฑฑ
ฑฑณ          ณ planejamento                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ PcoDelePnj()        		      				      		      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Planejamento e Controle Or็amentแrio                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Function PcoDelePnj(cAlias,nRecno,nOpcx,aCpos,cSeekALX,lDelALV,lDelAME,lAuto)

Local nOpc := 1
Local cUpdate
Local cQuery

Local _cVerPlan := ALV->ALV_VERSAO // Criado para Ferramenta de Revis๕a

Local lRet := .F.

Default cSeekALX:= ''
Default lDelALV := .T.
Default lDelAME	:= .T.
Default lAuto	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Verifica se usuario tem acesso a planilha  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lRet := PCO490VAP()

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Verifica amarracao com o Projeto do Planejamento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AMM->(DbSetOrder(2))
	lRet := AMM->(!DbSeek(xFilial("AMM")+ALV->ALV_CODIGO)) 

	If !lRet
		Help("   ",1,"NOEXCLPCOA490",,STR0163+CRLF+STR0164,1,0) // "Existem amarra็ใo entre a Planilha de Planejamento e o Projeto de Planejamento." ## "Cancele a amarra็ใo para excluir a Planilha."
	EndIf

EndIf

If lRet

	If !lAuto
		
		nOpc := Aviso( STR0001 , STR0091 + Alltrim(ALV->ALV_CODIGO) + " - "  + Alltrim(_cVerPlan) +  " " + STR0092 ,{ STR0083 , STR0084 }) //"Aten็ใo"###"Todos os dados da planilha "###"serใo excluํdos, continua a exclusใo ?"###"Sim"###"Nใo"
		
	Else
		
		nOpc:= 1
		
	EndIf
	
	If nOpc == 1
		
		// Excluir ALY
		cQuery := "SELECT ALY.R_E_C_N_O_ AS REC  FROM " + RetSqlName("ALY") + " ALY, " + RetSqlName("ALX") + " ALX "
		cQuery += "WHERE ALX_FILIAL = '" + xfilial("ALX") + "' AND ALY_FILIAL=ALX_FILIAL "
		cQuery += "AND ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ "
		cQuery += "AND ALX_VERSAO = '" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO "
		cQuery += "AND ALY_SEQ=ALX_SEQ "
		If !Empty(cSeekALX)
			cQuery += "AND " + cSeekALX
		EndIf
		cQuery += "AND ALY.D_E_L_E_T_  = ' '  AND ALX.D_E_L_E_T_ = ' '  "
		
		//TcSqlExec( cUpdate)
		//TcRefresh(RetSqlName("ALY"))
		
		//*************************************
		// Atulizacao dos lan็amentos do PCO  *    
		//*************************************
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALY", .T., .T. )
	
		PcoIniLan("000358")
		
		While TMPALY->(!Eof())
		
			DbSelectArea("ALY")
			DbGoTo( TMPALY->REC )
		
			PcoDetLan("000358","01","PCOXPNJ",.T.)
		
			RecLock("ALY",.F.,.T.)
			ALY->(DbDelete())
			ALY->(MsUnlock())
		
			TMPALY->(DbSkip())
		
		EndDo
		
		PcoFinLan("000358")
		
		TMPALY->(DbCloseArea())
		//********************************************
		// Fim da Atulizacao dos lan็amentos do PCO  *    
		//********************************************
		
		// Excluir ALX
		cUpdate := "UPDATE " + RetSqlName("ALX") + " SET D_E_L_E_T_ = '*' "
		cUpdate += " WHERE R_E_C_N_O_  IN "
		cUpdate += " ( SELECT ALX.R_E_C_N_O_  FROM " + RetSqlName("ALX") + " ALX "
		cUpdate += "WHERE ALX_FILIAL = '" + xfilial("ALX") + "' "
		cUpdate += "AND ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' "
		cUpdate += "AND ALX_VERSAO = '" + _cVerPlan + "' "
		If !Empty(cSeekALX)
			
			cUpdate += "AND " + cSeekALX
			
		EndIf
		cUpdate += "AND ALX.D_E_L_E_T_  = ' '   ) "
	
		TcSqlExec( cUpdate)
		TcRefresh(RetSqlName("ALX"))
			
		DbSelectArea("AMT")
		AMT->(DbGoTop())
		While AMT->(!EOF())
			If AMT_PLANEJ == ALV_CODIGO
				RecLock("AMT",.F.,.T.)
				AMT->(DbDelete())
				AMT->(MsUnlock())
			EndIf		   
			AMT->(DbSkip())
		EndDo
	
		If lDelAME
			// Excluir AME
			cUpdate := "UPDATE " + RetSqlName("AME") + " SET D_E_L_E_T_ = '*' "
			cUpdate += " WHERE R_E_C_N_O_  IN "
			cUpdate += " ( SELECT AME.R_E_C_N_O_  FROM " + RetSqlName("AME") + " AME "
			cUpdate += "WHERE AME_FILIAL = '" + xfilial("AME") + "' "
			cUpdate += "AND AME_PLANEJ = '" + ALV->ALV_CODIGO + "' "
			cUpdate += "AND AME.D_E_L_E_T_  = ' '   ) "
		
			TcSqlExec( cUpdate)
			TcRefresh(RetSqlName("AME"))
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Exclui a amarracao da planilha com os usuarios  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AMU->(DbSetOrder(1))
		AMU->(DbSeek(xFilial("AMU")+ALV->ALV_CODIGO))
		While AMU->( !Eof() .And. AMU_FILIAL+AMU_CODPLN == ALV->ALV_FILIAL+ALV->ALV_CODIGO )
			RecLock("AMU",.F.)		
			AMU->(DbDelete())
			AMU->(MsUnLock())
			AMU->(DbSkip())
		End
		
		// Excluir ALV
		If lDelALV
			RecLock("ALV",.F.,.T.)
			ALV->(DbDelete())
			ALV->(MsUnlock())
		EndIf
		
	EndIf
	
EndIf
	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoShowDisบAutor  ณAcacio Egas       บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibi distribui็ใo de valores para um item do Planejamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoShowDis(cId,lQtd,cTpVar,cSeek)

Local aCoord	:= { 000, 000, 350, 575 }
Local oDlg
Local oHPanel,oBmp,oCancel
Local cTitle	:= STR0011 //"Distribui็ใo Efetuada"
Local nTop,nLeft,nI
Local oCHFont,oCMFont,oMsmGet
Local _aGetQuants
Local oMPanel := Array(1)
Local cQuery
Local _nContItem

Default lQtd := .T.
Default cSeek:= ''

DEFINE FONT oCHFont	NAME 'FW Microsiga' SIZE 0, -8 BOLD
DEFINE FONT oCMFont	NAME 'FW Microsiga' SIZE 0, -8

_aGetQuants := {}
For _nContItem := 1 to Len(_aListData)
	_SetOwnerPrvt("DIS" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))
	// Criando campos para a MsmGet
	SX3->(DbSetOrder(2))
	SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
	ADD FIELD _aGetQuants TITULO _aListData[_nContItem] CAMPO "DIS" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
Next

cQuery := "SELECT ALY_DTINI,"
If lQtd
	cQuery += "SUM(ALY_QUANT) TOTAL "
Else
	cQuery += "SUM(ALY_VALOR) TOTAL "
EndIf
cQuery += "FROM "+ RetSqlName("ALY") +" ALY,"+ RetSqlName("ALX") +" ALX "
cQuery += "WHERE ALY.D_E_L_E_T_=' ' AND ALX.D_E_L_E_T_=' ' AND "
cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "
If Empty(cSeek)
	cQuery += " ALX_AM2ID = '" + cId + "' "
	cQuery += " AND ALX_TIPOPL='" + AM1->AM1_CODIGO + "' "
	cQuery += " AND ALX_VARPNJ='" + cTpVar + "' "
Else
	cQuery += " AND " + cSeek
Endif
cQuery += " AND ALY_SEQ=ALX_SEQ GROUP BY ALY_DTINI"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPDIS", .T., .T. )
While !Eof()
	If (nI := aScan(_aListData,dToc(sTod(ALY_DTINI)))) >0
		&("M->"+"DIS" + StrZero(nI,3)) := TMPDIS->TOTAL
	EndIf
	DbSkip()
End
DbCloseArea()

DEFINE MSDIALOG oDlg FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] TITLE cTitle PIXEL

@ 000, 000 MSPANEL oHPanel	OF oDlg SIZE 301,030 RAISED

oHPanel:nWidth := oDlg:nWidth

@ 002, 260 BITMAP oBmp RESNAME 'WIZARD' OF oHPanel SIZE 040,025 NOBORDER WHEN .F. PIXEL ADJUST
oBmp:nLeft := oHPanel:nWidth - oBmp:nWidth - 20

@ 005,010 SAY STR0093 OF oHPanel PIXEL FONT oCHFont SIZE 225,017 //"Distribui็ใo"
//chTitle:nWidth := ::oHPanel:nWidth - 130

@ 012,015 SAY STR0094 OF oHPanel PIXEL FONT oCMFont SIZE 225,017 //"Estแ ้ a Distribui็ใo realizada"
//chMsg:nWidth := ::oHPanel:nWidth - 130

@ 035, 006 MSPANEL oMPanel[1]	OF oDlg SIZE 277, 120 RAISED

nTop  := (oMPanel[1]:nTop + oMPanel[1]:nHeight + 12)/2
nLeft := (oDlg:nWidth/2) - 180

@ nTop, nLeft + 130 BUTTON oCancel PROMPT STR0095 SIZE 040, 013 OF oDlg PIXEL ACTION oDlg:End() //"Sair"

oMPanel[1]:Show()

//Cria MsmGet
oMsmGet := MsMGet():New("ALY",ALY->(Recno()),4,,,,,{0, 0, 640, 480},,4,,,,oMPanel[1],,,,,,.T.,_aGetQuants)


oDlg:Activate( ,,,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoTotPnj บAutor  ณMicrosiga           บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca Total da Distribui็ใo                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Ja existe da PCOXPNJ.PRW                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Function PcoTotPnj(nTp,cSeq,dDataIni,dDataFim)

Local cQuery
Local nTot := 0
Local aArea := GetArea()

PcoIni_VarStatic()

If cSeq<>nil
	
	If nTp==1 // Quantidade

		If lOracle .Or. lInformix
			cQuery := "SELECT NVL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		ElseIf  lDB2 
			cQuery := "SELECT COALESCE(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		Else
			cQuery := "SELECT ISNULL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		EndIf
	
	Else // Valor

		If lOracle .Or. lInformix
			cQuery := "SELECT NVL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		ElseIf  lDB2 
			cQuery := "SELECT COALESCE(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		Else
			cQuery := "SELECT ISNULL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		EndIf

	EndIf

	If VALTYPE(dDataIni)=='D' .and. VALTYPE(dDataFim)=='D'

		cQuery += "AND ALY_DTINI>='" + dTos(dDataIni) + "' AND ALY_DTFIM<='"  + dTos(dDataFim) + "' "
			
	EndIf
	
	cQuery += " GROUP BY ALY_FILIAL"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPTOT", .T., .T. )
	nTot := TMPTOT->TOTAL
	DbCloseArea()

ElseIf TYPE('ALX_SEQ')=='C'
	
	If !Empty(ALX_SEQ)
		
		If nTp==1 // Quantidade
			
			If lOracle .Or. lInformix
				cQuery := "SELECT NVL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			ElseIf  lDB2 
				cQuery := "SELECT COALESCE(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			Else
				cQuery := "SELECT ISNULL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			EndIf
		
		Else // Valor

			If lOracle .Or. lInformix
				cQuery := "SELECT NVL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "				
			ElseIf  lDB2 
				cQuery := "SELECT COALESCE(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			Else
				cQuery := "SELECT ISNULL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			EndIf

		EndIf

		cQuery += " GROUP BY ALY_FILIAL"
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPTOT", .T., .T. )
		nTot := TMPTOT->TOTAL
		DbCloseArea()
		
	EndIf
	
EndIf
RestArea(aArea)

Return nTot
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoChavALXบAutor  ณAcacio Egas         บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca chave do ALX.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SOGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoChavALX(cAlias , cTipoVar)

Local cQuery
Local nRec
Local lRet := .F.

//************************************************
//ณ    Localiza ALX com a Chave a ser incluida.  *
//************************************************

cQuery := "SELECT R_E_C_N_O_ RECNO  FROM " + RetSqlName("ALX") + " WHERE D_E_L_E_T_=' ' AND "
cQuery += "ALX_PLANEJ='" 	+ ALV->ALV_CODIGO		+ "' AND "
cQuery += "ALX_VERSAO='" 	+ _cVerPlan				+ "' AND "
cQuery += "ALX_CO='" 		+ (cAlias)->ALX_CO 		+ "' AND "
cQuery += "ALX_CLASSE='" 	+ (cAlias)->ALX_CLASSE 	+ "' AND "
cQuery += "ALX_OPER='" 		+ (cAlias)->ALX_OPER 	+ "' AND "
cQuery += "ALX_CC='" 		+ (cAlias)->ALX_CC 		+ "' AND "
cQuery += "ALX_ITCTB='" 	+ (cAlias)->ALX_ITCTB 	+ "' AND "
cQuery += "ALX_CLVLR='" 	+ (cAlias)->ALX_CLVLR 	+ "' AND "
cQuery += "ALX_AM2ID='" 	+ (cAlias)->ALX_AM2ID 	+ "' AND "
cQuery += "ALX_CODIGO='" 	+ (cAlias)->ALX_CODIGO	+ "' AND "
cQuery += "ALX_TIPO='" 		+ (cAlias)->ALX_TIPO	+ "' AND "
cQuery += "ALX_TIPOPL='" 	+ cTipoVar				+ "' AND "
cQuery += "ALX_REGRA='" 	+ (cAlias)->ALX_REGRA 	+ "' "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALX", .T., .T. )

If !TMPALX->(Eof())
	
	nRec := TMPALX->RECNO
	lRet := .T.
	DbCloseArea()
	DbSelectArea("ALX")
	DbGoTo(nRec)
	
Else
	
	TMPALX->(DbCloseArea())
	
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoReprPnjบAutor  ณAcacio Egas         บ Data ณ  05/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de recalculo de um item do planejamento.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoReprPnj(cId,cTipoPlan,cVarIni,lQuant)

Local oWizard

Private oMsmDist,oGtdRegra,oGtdMan,oMsmMan,oMeter
Private aColsReg,aAMEParam,aHeaderReg,aColsMan,aHeaderMan,aSeqVal,aConfigs[4]
Private lManual := .F.
Private _cFilALX,_cRegra,cReprocSeq := ''

//Validacao se a ACAO pode ser Executado em Relacao a Fase Atual.
If !PCOvldFase("AMH",ALV->ALV_FASE,"0004",.t.)	// 0004 -> Ver Cadastro de ACAO (AMI) 
   Return
Endif
oWizard := APWizard():New( STR0001 , STR0097 + CRLF +;
STR0098 , STR0099 , STR0065 + Alltrim(ALV->ALV_CODIGO) + " - " +;
PadR(ALV->ALV_DESCRI,50) + CRLF + CRLF + STR0012 + AM2->AM2_AGREG + CRLF + CRLF + STR0066 + cTipoPlan ,;
{||.T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/,/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
//"Atencao"###"Este assistente lhe ajudara no Reprocessamento de um determinado item do planejamento."
//"Siga os possos informados no Wizard para realizar o reprocessamento."###"Alterar Distribui็ใo"###"Planejamento : "
//"Agregador : "###"Tp. Planejamento.: "

// janela 01
oWizard:NewPanel( STR0100 , STR0101 ,;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/, ;
{||PcoReproc(@oWizard,1,{AM2->AM2_ID,cVarIni,lQuant}) }/*<bExecute>*/ )
//"Distribui็ใo dos Valores"###"Neste passo voce deverแ informar os valores para cada periodo do planejamento."

// janela 02
oWizard:NewPanel( STR0102 , STR0103 ,;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/,;
{|| PcoReproc(@oWizard,2,{ AM2->AM2_ID }) }/*<bExecute>*/ )
//"Regras aplicadas!"###"Neste passo voce deverแ informar quais as Regra que voc๊ deseja aplicar no reprocessamento."

// janela 03
oWizard:NewPanel( STR0104 , STR0105 ,;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel .>*/, ;
{||PcoReproc(@oWizard,3,{ AM2->AM2_ID }) }/*<bExecute>*/ )
//"Movimentos manuais!"###"Neste momento seram informados os movimentos digitados de forma manual no planejamento."

// janela 04
oWizard:NewPanel( "Reprocessamento","Aten็ใo todos os dados do planejamento serใo reprocessados. Click em finalizar para iniciar o reprocessamento.",;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||PcoRepMet(cId , { cTipoPlan,cVarIni } ) }/*<bFinish>*/,;
.T./*<.lPanel .>*/, ;
{||PcoReproc(@oWizard,4,) }/*<bExecute>*/ )


oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/, ;
{||.T.}/*<bInit>*/, ;
{||.T.}/*<bWhen>*/ )


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoReproc บAutor  ณ Acacio Egas        บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de contrucao do wizard.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoReproc(oWizard,nWin,aParam)
Local _nContItem
Local cQuery
Local aCpos
Local cCombo	:= ''

Do Case
	
	Case nWin==1
		
		//***********************************//
		// Tela de quantidades distribuidas  //
		// Vetor aParam                      //
		//    [1] = cId		                 //
		//    [2] = cTipo de Planejamento    //
		//    [3] = lQuant tipo de movimento //
		//***********************************//
		
		_aGetQuants := {}
		For _nContItem := 1 to Len(_aListData)
			_SetOwnerPrvt("DIS" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))
			// Criando campos para a MsmGet
			SX3->(DbSetOrder(2))
			SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
			ADD FIELD _aGetQuants TITULO _aListData[_nContItem] CAMPO "DIS" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
		Next
		
		cQuery := "SELECT ALY_DTINI,"
		If aParam[3]
			cQuery += "SUM(ALY_QUANT) TOTAL "
		Else
			cQuery += "SUM(ALY_VALOR) TOTAL "
		EndIf
		cQuery += "FROM "+ RetSqlName("ALY") +" ALY,"+ RetSqlName("ALX") +" ALX "
		cQuery += "WHERE ALY.D_E_L_E_T_=' ' AND ALX.D_E_L_E_T_=' ' AND "
		cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND "
		cQuery += " ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "
		cQuery += "ALX_AM2ID='"  + aParam[1] + "' AND "
		cQuery += "ALX_TIPOPL='" + AM1->AM1_CODIGO + "' AND "
		cQuery += "ALX_VARPNJ='" + aParam[2] + "' AND "		
		cQuery += "ALX_FILTRO<>'#' "
		cQuery += " AND ALY_SEQ=ALX_SEQ GROUP BY ALY_DTINI"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPDIS", .T., .T. )
		While !Eof()
			If (nI := aScan(_aListData,dToc(sTod(ALY_DTINI)))) >0
				&("M->"+"DIS" + StrZero(nI,3)) := TMPDIS->TOTAL
			EndIf
			DbSkip()
		End
		DbCloseArea()
		If oMsmDist==nil
			oMsmDist := MsMGet():New("ALY",ALY->(Recno()),4,,,,,{5, 5, 135, 285},,4,,,,oWizard:oMPanel[oWizard:nPanel],,,,,,.T.,_aGetQuants)
		EndIf
		
	Case nWin==2
		
		//***********************************//
		// Tela de movimentos manuais        //
		// Vetor aParam                      //
		//    [1] = cId		                 //
		//***********************************//
		
		If oGtdMan==nil
			
			cQuery := "SELECT * FROM " + RetSqlName("ALX")
			cQuery += " WHERE ALX_FILTRO='#' AND D_E_L_E_T_=' ' AND "
			cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' AND "
			cQuery += "ALX_AM2ID='"  + aParam[1] + "' AND "
			cQuery += "ALX_TIPOPL='" +AM1->AM1_CODIGO + "' "
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPREG", .T., .T. )
			
			// Inclui campos no GetDados de Receitas relacionadas
			aCpos := {"ALX_CODIGO","ALX_TIPOPL","ALX_CO","ALX_CLASSE","ALX_OPER","ALX_CC","ALX_ITCTB","ALX_CLVLR","ALX_SEQ"}
			If ExistBlock("PCOXPNJ2")
				If VALTYPE(aCposUsr := ExecBlock("PCOXPNJ2"))="A"
					aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
				EndIf
			EndIf
			
			aHeaderMan 	:= GetAHeader( "ALX" , aCpos , , , {"ALX_TIPOPL"} )
			aHeaderMan[aScan(aHeaderMan,{|x|ALLTRIM(x[2])=='ALX_CODIGO'	}),01] := "Prod. Relac."
			aHeaderMan[aScan(aHeaderMan,{|x|ALLTRIM(x[2])=='ALX_CODIGO'	}),09] := "SB1"
			aHeaderMan[aScan(aHeaderMan,{|x|ALLTRIM(x[2])=='ALX_TIPOPL'	}),11] := "001=Receita Direta;002=Receita Relac.;003=Mov. Relac.;004=Custo Direto;901=Reajuste"
			
			aColsMan 	:= {}
			aSeqVal		:= {}
			If TMPREG->(Eof())
				
				aAdd(aColsMan,Array(Len(aHeaderMan) + 1))
				AEval(aHeaderMan, {|x,y| aColsMan[Len(aColsMan)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL, CriaVar(AllTrim(x[2])) ) })
				aColsMan[Len(aColsMan),Len(aHeaderMan)+1] := .F.
				lManual	:= .F.
				
			Else
				
				lManual	:= .T.
				
			EndIf
			
			aGetVal := {}
			For _nContItem := 1 to Len(_aListData)
				_SetOwnerPrvt("MAN" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))
				// Criando campos para a MsmGet
				SX3->(DbSetOrder(2))
				SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
				ADD FIELD aGetVal TITULO _aListData[_nContItem] CAMPO "MAN" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
			Next
			
			oGtdMan := MsNewGetDados():New(3,3,65,287,GD_UPDATE+GD_DELETE,,,,,,,,,,oWizard:oMPanel[oWizard:nPanel],aHeaderMan,aColsMan)
			
			While !TMPREG->(Eof())
				
				aAdd(aColsMan,Array(Len(aHeaderMan) + 1))
				aAdd( aSeqVal , { TMPREG->ALX_SEQ , Array(Len(_aListData)) } )
				AEval(aHeaderMan, {|x,y| aColsMan[Len(aColsMan)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,If( x[10]="V" , CriaVar(AllTrim(x[2])) , &('TMPREG->'+x[2]) ) ) })
				aColsMan[Len(aColsMan),Len(aHeaderMan)+1] := .F.
				
				oGtdMan:aCols 	:= aColsMan
				oGtdMan:aHeader := aHeaderMan
				oGtdMan:nAt	:= Len(aColsMan)
				PcoReprcALY( oGtdMan , .T. , .F. )
				
				DbSkip()
				
			End
			TMPREG->(DbCloseArea())
			
			oGtdMan:nAt					:= 1
			oGtdMan:bChange 			:= {|| PcoReprcALY(oGtdMan,.T.) }
			oGtdMan:oBrowse:bGotFocus 	:= {|| PcoReprcALY(oGtdMan,.T.) }
			
			oMsmMan := MsMGet():New("ALY",ALY->(Recno()),4,,,,,{67, 3, 137, 287},,4,,,,oWizard:oMPanel[oWizard:nPanel],,,,,,.T.,aGetVal)
			
		EndIf
		
		// Grava aCols do GetDados de Regras Aplicadas
		If oGtdRegra<>nil
			
			aColsReg	:= oGtdRegra:aCols
			aHeaderReg	:= oGtdRegra:aHeader
			
		EndIf
		
	Case nWin==3
		
		//***********************************//
		// Tela de quantidades distribuidas  //
		// Vetor aParam                      //
		//    [1] = cId		                 //
		//***********************************//
		
		// Grava aCols do GetDados de ALX manual
		If oGtdMan<>nil
			
			aColsMan	:= oGtdMan:aCols
			aHeaderMan	:= oGtdMan:aHeader
			
			PcoReprcALY(oGtdMan,.T.)
			
		EndIf
		
		If oGtdRegra == nil
				
			cQuery := "SELECT * FROM " + RetSqlName("AME") 
			cQuery += " WHERE AME_FILIAL='" + xFilial("AME") + "' AND AME_PLANEJ='" + ALV->ALV_CODIGO 
			cQuery += "' AND AME_VERSAO='" + _cVerPlan + "' AND AME_TPCOD='" + AM1->AM1_CODIGO + "' AND D_E_L_E_T_ = ' '   ORDER BY AME_SEQ"
			
			aHeaderReg := GetaHeader("AME")
			DbSelectarea("AMD")
			DbSetOrder(1)
			DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
			Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO==AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
				cCombo	+= ALLTRIM(AMD->AMD_VARCOD) + "=" + Capital(ALLTRIM(AMD->AMD_DESVAR)) + ";"
				AMD->(DbSkip())
			EndDo

			aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='AME_VARPNJ'	}),11] := cCombo + "XX=Reajuste"
		
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPREG", .T., .T. )
			aColsReg 	:= {}
			aAMEParam	:= {}
			
			If TMPREG->(Eof())
				
				aAdd(aColsReg,Array(Len(aHeaderReg) + 1))
				AEval(aHeaderReg, {|x,y| aColsReg[Len(aColsReg)][y] := If(Alltrim(x[2])$"AME_ALI_WT|AME_REC_WT",NIL, CriaVar(AllTrim(x[2])) ) })
				aAdd(aAMEParam,"")
				aColsReg[Len(aColsReg),Len(aHeaderReg)+1] := .F.
				
			EndIf
			
			While !TMPREG->(Eof())
				
				aAdd(aColsReg,Array(Len(aHeaderReg) + 1))
				AEval(aHeaderReg, {|x,y| aColsReg[Len(aColsReg)][y] := If(Alltrim(x[2])$"AME_ALI_WT|AME_REC_WT",NIL, TMPREG->(FieldGet(TMPREG->(FieldPos(AllTrim(x[2]))))) ) })
				aAdd(aAMEParam,TMPREG->AME_PARAM)
				aColsReg[Len(aColsReg),Len(aHeaderReg)+1] := .F.
				
				TMPREG->(DbSkip())	
			End
			TMPREG->(DbCloseArea())
			
			oGtdRegra := MsNewGetDados():New(40,5,135,285,7,,,,,,,,,,oWizard:oMPanel[oWizard:nPanel],aHeaderReg,aColsReg)
			
		EndIf
				
	Case nWin==4
		
		If oMeter=nil

			//		oSayMet :=
			oMeter 	:= TMeter():New( 3, 3,{|| 0 },/*nTot*/ Len(aColsReg) + Len(aColsMan)  ,oWizard:oMPanel[oWizard:nPanel], 240, 20,,,,"Prompty",,,,,,)
			
		Else
			
			oMeter:SetTotal( Len(aColsReg) + 1 + Len(aColsMan) )
			
		EndIf

		If oGtdRegra <> nil
			aColsReg := oGtdRegra:aCols
		EndIf
		
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoRepMet บAutor  ณ Acacio Egas        บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de reprocessamento de movimentos do planejamento.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoRepMet(cId,aParam)
Local nX,nI,nY
Local cSeq
Local cAgreg
Local nCpSeq
Local nCpCod
Local nCpAgre
Local nCpVerba
Local nCpTipoPl,nCpVarPnj,nCpRegra,nCpSeqPnj
Local cParam
Local aValores

Private _cVarPnj

PcoDelePnj(,,,," ALX_FILTRO<>'#' AND ALX_AM2ID='" + cId + "' ",.F.,.T.,.T.)

oMeter:Set( 1 )
oMeter:Refresh()
nCpSeq 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_SEQ'})
nCpCod 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_CODIGO'	})
nCpAgre 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_AGREG'	})
nCpTipoPl 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_TIPOPL'})

For nX := 1 To Len(aColsMan)
	
	cSeq := aColsMan[nX,nCpSeq]

		nPrecAgre := 0//
		lQtd := .T.
		
	If !Empty(cSeq)
	
		DbSelectArea("ALX")
		DbSetOrder(2)
		If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cSeq)
			
			RecLock("ALX",.F.)
			
			aEval( aHeaderMan , {|x,y| &(AllTrim(aHeaderMan[y,2])) := aColsMan[nX,y] } )
			
			MsUnLock()
			
		EndIf
		
		If (nI := aScan( aSeqVal , {|x|x[1]==cSeq} )) > 0
			
			For nY := 1 To Len(_aListData)
				
				If aSeqVal[nI,2,nY]<>nil
					
					DbSelectArea("ALY")
					DbSetOrder(1)
					If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cSeq+dTos(cTod(SubStr(_aListData[nY],1,8))))
						
						RecLock("ALY",.F.)
						If lQtd
							
							ALY->ALY_QUANT 	:= aSeqVal[nI,2,nY]
							ALY->ALY_VALOR	:= ALY->ALY_QUANT * nPrecAgre
							
						Else
							
							ALY->ALY_VALOR	:= aSeqVal[nI,2,nY]
							
						EndIf
						MsUnlock()
						
					Else
						
						RecLock("ALY",.T.)
						ALY_FILIAL 		:= xfilial("ALY")
						ALY_PLANEJ 		:= ALV->ALV_CODIGO
						ALY_VERSAO 		:= _cVerPlan
						ALY_SEQ 		:= cSeq
						ALY_DTINI 		:= CTOD(Substr(_aListData[nY],1,8))
						ALY_DTFIM 		:= CTOD(Substr(_aListData[nY],14,8))
						If lQtd
							
							ALY->ALY_QUANT 	:= aSeqVal[nI,2,nY]
							ALY->ALY_VALOR	:= ALY->ALY_QUANT * nPrecAgre
							
						Else
							
							ALY->ALY_VALOR	:= aSeqVal[nI,2,nY]
							
						EndIf
						MsUnlock()
						
					EndIf
					
				EndIf
				
			Next
			oMeter:Refresh()
			
		EndIf
		
	EndIf
	
	oMeter:Set( nX  + 1 )
	oMeter:Refresh()
	
Next

nCpSeqPnj 	:= aScan( aHeaderReg , {|x|Alltrim(x[2])="AME_SEQ"		} )
nCpVarPnj 	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='AME_VARPNJ'	} )
nCpRegra	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='AME_REGRA'	} )

aEval(aColsReg, {|x,y| If(Len(aAMEParam)>=y,aAdd(aColsReg[y],aAMEParam[y]),aAdd(aColsReg[y],''))})
aSort(aColsReg,,, {|x,y| y[nCpSeqPnj] > x[nCpSeqPnj]})

For nI := 1 To Len(aColsReg)
	
	If !aColsReg[ nI , Len(aHeaderReg) + 1 ]
		
		// ExecAuto de rotinas do planejamento
		DbSelectArea("AMD")
		DbSetOrder(1)
		DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO+aColsReg[ nI , nCpVarPnj ])
		_cVarPnj	:= AMD->AMD_VARCOD	
		
		bVlrUnit	:= MontaBlock("{|cItem,cTpPlan,cVar| Paramixb := {cItem,cTpPlan,cVar}," + AMD->AMD_VRUNIT + "}")
		Ret	:= Eval(MontaBlock("{|| " + StrToPar(aColsReg[nI,Len(aHeaderReg) + 2]) + " }"))
		
		If Ret == NIL //Tratamento de error.log quando variแvel retorna NIL
			Ret := {0, 0}
		EndIf
		
		If aParam[2]==aColsReg[ nI , nCpVarPnj ]
			aValores := {}
			For nX := 1 To Len(_aListData)	
				aAdd(aValores, &("M->DIS" + StrZero(nX,3) ) )
			Next
			PcoGerMovs(cId,AMD->AMD_TPVAR,aColsReg[ nI , nCpVarPnj],,AMD->AMD_TIPO=="1",bVlrUnit,,{{aColsReg[ nI , nCpRegra ]} , Ret[2] ,aValores})
		
		ElseIf aColsReg[ nI , nCpVarPnj ]<>"XX"

			PcoGerMovs(cId,AMD->AMD_TPVAR,aColsReg[ nI , nCpVarPnj ],,AMD->AMD_TIPO=="1",bVlrUnit,,Ret)
			
		Else

			PcoAltPnj(cId,,Ret,AM1->AM1_CODIGO)
		
		EndIf	
	EndIf
	oMeter:Set( nX + 1 + nI )
	oMeter:Refresh()
	
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoReprcALY บAutor ณ Acacio Egas       บ Data ณ  05/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Consulta da ALY manual no reprocessamento.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoReprcALY(oGdDados,lQtd,lRefresh)

Local aListVeri := {}
Local aCols 	:= oGdDados:aCols
Local aHeader 	:= oGdDados:aHeader
Local n			:= oGdDados:nAt
Local cSeq 		:= aCols[n,aScan(aHeader,{|x|ALLTRIM(x[2])='ALX_SEQ'})]
Local aArea 	:= GetArea()
Local nX

Default lQtd 		:= .T.
Default lRefresh    := .T.

If lRefresh
	
	For Nx := 1 to Len(_aListData)
		
		If !Empty(cReprocSeq)
			
			aSeqVal[aScan( aSeqVal , {|x|x[1]==cReprocSeq} ),2,Nx] := &('M->MAN' + StrZero(Nx,3))
			
		EndIf
		aAdd(aListVeri,Substr(_aListData[Nx],1,8))
		
	Next
	
Else
	
	For Nx := 1 to Len(_aListData)
		
		aAdd(aListVeri,Substr(_aListData[Nx],1,8))
		
	Next
	
EndIf

If Len(aSeqVal)>0 .and. !Empty(cSeq)
	If aSeqVal[aScan( aSeqVal , {|x|x[1]==cSeq} ),2,1] <>nil
		
		For Nx := 1 to Len(_aListData)
			
			If !Empty(cSeq)
				&('M->MAN' + StrZero(Nx,3))	:= aSeqVal[aScan( aSeqVal , {|x|x[1]==cSeq} ),2,Nx]
			EndIf
			
		Next
		
	Else
		
		// Consulta valores na tabela ALY - Valores do Planejamento
		cQuery := "SELECT ALY_DTINI, ALY_QUANT,ALY_VALOR FROM " + RetSqlName("ALY") + " ALY" + " "
		cQuery += "WHERE ALY_DTINI >= '" + DTOS(CTOD(Substr(_aListData[1],1,8))) + "' AND ALY_DTFIM <= '"
		cQuery += DTOS(CTOD(Substr(_aListData[Len(_aListData)],14,8))) + " ' "
		cQuery += "AND ALY_FILIAL='"+ xFilial("ALY") + "' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO = '" +_cVerPlan + "' "
		cQuery += "AND ALY_SEQ = '" + cSeq + "' AND D_E_L_E_T_  = ' '  "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPVAL2", .T., .T. )
		
		dbSelectARea("TMPVAL2")
		If TMPVAL2->(Eof())
			
			For Nx := 1 to Len(_aListData)
				
				&('M->MAN' + StrZero(Nx,3))	:= 0
				
			Next
			
		EndIf
		
		While ! TMPVAL2->(Eof())
			
			nPosiValo := aScan(aListVeri,DTOC(STOD(TMPVAL2->ALY_DTINI)))
			
			If lQtd
				
				&('M->MAN' + StrZero(nPosiValo,3)) := TMPVAL2->ALY_QUANT
				
			Else
				
				&('M->MAN' + StrZero(nPosiValo,3)) := TMPVAL2->ALY_VALOR
				
			EndIf
			
			TMPVAL2->(dbSkip())
			
		End
		
		TMPVAL2->(dbCloseArea())
	EndIf
	
	cReprocSeq := cSeq
EndIf

If lRefresh
	
	oMsmMan:EnchRefreshAll()
	
Else
	
	For Nx := 1 to Len(_aListData)
		
		If !Empty(cReprocSeq)
			
			aSeqVal[aScan( aSeqVal , {|x|x[1]==cReprocSeq} ),2,Nx] := &('M->MAN' + StrZero(Nx,3))
			
		EndIf
		
	Next
	
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrayStr  บAutor  ณAcacio Egas         บ Data ณ  08/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de conversใo de vetor em String.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ArrayStr( aConfig )

Local cStr := ""

aEval( aConfig , {|x,y| cStr += If(VALTYPE(x)=='C' , Alltrim(x) , If(VALTYPE(x)=='D' , Alltrim(dTos(x)) , Alltrim(Str(x)) ))  + ";" } )

Return cStr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrayStr  บAutor  ณAcacio Egas         บ Data ณ  08/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de conversใo de String em Vetor.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function StrArray( cStr )

Local aConfig := {}
Local _nI

While Len(cStr) > 0
	
	_nI := AT(";",cStr)
	aAdd( aConfig , SubStr( cStr , 1 , _nI-1 ) )
	cStr := ALLTRIM(SubStr( cStr , _nI+1 , Len( cStr ) - (_nI) ))
	
End

Return aConfig

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGerOrc บAutor  ณ Acacio Egas        บ Data ณ  06/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Gera็ใo da planilha or็amentแria.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoGerOrc(cAlias,nRecno,nOpcx,aCpos)

Local cQuery
Local cPlanej
Local cFase
Local aParam	:= {}
Local aTpPlan 	:= {}
Local cPlntps 	:= ''
//Local aTpVar	:= {}
//Local cPlnVars 	:= ''
Local aConfig 	:= Array(5)
Local nX
Local lContinua := .F.
Local nNiveEstr := 1

Private _cVerPlan

//Validacao se a ACAO pode ser Executado em Relacao a Fase Atual.
If !PCOvldFase("AMH",ALV->ALV_FASE,"0016",.t.) // 0016 -> Ver Cadastro de ACAO (AMI)
   Return
Endif

// validacao do controle do planejamento, usuario(AMU) x planilha(ALV)
If !PCO490VAP()
	Return
EndIf

PcoIni_VarStatic()

DbSelectArea("ALV")
DbGoTo(nRecno)

cPlanej		:= ALV->ALV_CODIGO
_cVerPlan 	:= ALV->ALV_VERSAO
cFase		:= ALV->ALV_FASE
//************************
// Planejamento P10 R1.3 *
//************************
If Empty(ALV->ALV_CFGPLN)

	PcoGerPnj(cAlias,nRecno,nOpcx,aCpos)

//**********************
// Planejamento P10 R2 *
//**********************
Else
	//*********************************
	// Localiza tipos de planejamento *
	//*********************************
	DbSelectArea("AM1")
	DbSetOrder(2)
	DbSeek(xFilial("AM1")+ALV->ALV_CFGPLN)
	Do While AM1->(!Eof()) .and. xFilial("AM1")+ALV->ALV_CFGPLN == AM1->(AM1_FILIAL+AM1_CFGPLN)
		aAdd( aParam , { 5 , AM1->AM1_DESCR ,.F.,90,,.F.} )
		aAdd( aTpPlan, AM1->AM1_CODIGO )
	
		//*********************************************
		// Localiza variacoes do tipo de planejamento *
		//*********************************************
		/*DbSelectArea("AMD")
		DbSetOrder(1)
		DbSeek(xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO)
		Do While AMD->(!Eof()) .and. xFilial("AMD")+ALV->ALV_CFGPLN+AM1->AM1_CODIGO == AMD->(AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD)
	
			aAdd( aTpVar , {AM1->AM1_CODIGO , AMD->AMD_VARCOD , AMD->AMD_NATVAR } )
			AMD->(DbSkip())
	
		EndDo*/
	
		AM1->(DbSkip())
	EndDo
	
	aAdd( aParam , { 2 , "Gera natureza" , 1 ,{"1=Orcamentaria","2=Contabil","3=Todos"} ,90,,.T.} ) //"Gera natureza"##"1=Orcamentaria"##"2=Contabil"##"3=Todos"
	
	If ParamBox(aParam,	STR0157 ,aConfig)//"Gera็ใo da Planilha Or็amentaria"
		
		For nX := 1 To Len(aConfig)-1
			
			If aConfig[nX]
				
				cPlntps += "'" + aTpPlan[Nx] + "',"
				lContinua := .T.
			
			EndIf
			
		Next
		
		If lContinua
		
			PcoIniLan("000252")
			Processa( {|| lContinua := PCOExclOrca(ALV->ALV_CODIGO)	}, STR0158 ) //"Apagando Planilha or็amentแria"
			PcoFinLan("000252")
	
		EndIf
	
	EndIf
	
	If lContinua	
		
		For nX := 1 To 2
	
			If nX==1
			
				cQuery := "SELECT COUNT( * ) TOT"
				cQuery += " FROM  " + RetSqlName("ALX") + " ALX "
				cQuery += " WHERE ALX_FILIAL='" + xFilial("ALX") + "' AND ALX.D_E_L_E_T_=' ' AND "
				cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND "
				cQuery += " ALX_VERSAO='" + _cVerPlan + "' AND "
				cQuery += " ALX_TIPOPL IN (" + SubStr( cPlntps , 1 , Len(cPlntps) -1 ) + ") "
			
			Else
			
				cQuery := "SELECT ALX_CO,ALX_CLASSE,ALX_CC,ALX_OPER,ALX_ITCTB,ALX_CLVLR,"
	
				If lOracle .Or. lInformix
					cQuery += "((SELECT NVL(SUM(ALY_VALOR ),0)"
				ElseIf  lDB2 .Or. lPostgres 
					cQuery += "((SELECT COALESCE(SUM(ALY_VALOR ),0)"
				Else
					cQuery += "((SELECT ISNULL(SUM(ALY_VALOR ),0)"
				EndIf
	
				cQuery += "  FROM " + RetSqlName("ALX") + " ALXDEB," + RetSqlName("ALY") + " ALYDEB"
				cQuery += "  WHERE ALX_CO=ALX.ALX_CO AND ALX_CLASSE=ALX.ALX_CLASSE AND ALX_OPER=ALX.ALX_OPER AND "
				cQuery += "  ALX_CC = ALX.ALX_CC AND "
				cQuery += "  ALX_ITCTB=ALX.ALX_ITCTB AND ALX_CLVLR=ALX.ALX_CLVLR AND ALX_TIPO='2'AND "
				cQuery += "  ALXDEB.D_E_L_E_T_=' ' AND ALYDEB.D_E_L_E_T_=' ' AND ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND "
				cQuery += "  ALY_PLANEJ=ALX_PLANEJ AND ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND"
				cQuery += "  ALY_SEQ=ALX_SEQ AND ALY_DTINI=ALY.ALY_DTINI AND "
				cQuery += "  ALX_TIPOPL IN (" + SubStr( cPlntps , 1 , Len(cPlntps) -1 ) + ") "
				cQuery += " )"
				
				cQuery += " - "
	
				If lOracle .Or. lInformix
					cQuery += " (SELECT NVL(SUM(ALY_VALOR ),0)"				
				ElseIf  lDB2 .Or. lPostgres 
					cQuery += " (SELECT COALESCE(SUM(ALY_VALOR ),0)"				
				Else
					cQuery += " (SELECT ISNULL(SUM(ALY_VALOR ),0)"
				EndIf
	
				cQuery += "  FROM " + RetSqlName("ALX") + " ALXCRD, " + RetSqlName("ALY") + " ALYCRD"
				cQuery += "  WHERE ALX.ALX_CO=ALX_CO AND ALX_CLASSE=ALX.ALX_CLASSE AND ALX_OPER=ALX.ALX_OPER AND "
				cQuery += "  ALX_CC = ALX.ALX_CC AND "
				cQuery += "  ALX_ITCTB = ALX.ALX_ITCTB AND ALX_CLVLR = ALX.ALX_CLVLR AND ALX_TIPO = '1' AND "
				cQuery += "  ALXCRD.D_E_L_E_T_=' ' AND ALYCRD.D_E_L_E_T_=' ' AND ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND "
				cQuery += "  ALY_PLANEJ=ALX_PLANEJ AND ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND"
				cQuery += "  ALY_SEQ=ALX_SEQ AND ALY_DTINI=ALY.ALY_DTINI AND "
				cQuery += "  ALX_TIPOPL IN (" + SubStr( cPlntps , 1 , Len(cPlntps) -1 ) + ") "
				cQuery += " )"
			
				cQuery += ") ALY_VALOR"
			
				cQuery += ",ALY_DTINI, ALY_DTFIM "
			
				cQuery += " FROM  " + RetSqlName("ALX") + " ALX, " + RetSqlName("ALY") + " ALY"
				cQuery += " WHERE ALX_FILIAL='" + xFilial("ALX") + "' AND ALY_FILIAL='" + xFilial("ALY") + "' AND "
				cQuery += " ALX.D_E_L_E_T_=' ' AND ALY.D_E_L_E_T_=' ' AND"
				cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND"
				cQuery += " ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND"
				cQuery += " ALY_SEQ = ALX_SEQ AND "
				cQuery += " ALX_TIPOPL IN (" + SubStr( cPlntps , 1 , Len(cPlntps) -1 ) + ") "
					
				cQuery += "GROUP BY ALX_CO,ALX_CLASSE,ALX_CC,ALX_OPER,ALX_ITCTB,ALX_CLVLR,ALY_DTINI,ALY_DTFIM "
				cQuery += "ORDER BY ALX_CO,ALX_CLASSE,ALX_CC,ALX_OPER,ALX_ITCTB,ALX_CLVLR,ALY_DTINI, ALY_DTFIM "
			
			EndIf
			
			cQuery := ChangeQuery(cQuery)
	
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPORC", .T., .T. )
			
			If nX==1
			
				nTot	:= TMPORC->TOT
				DbCloseArea()
			
			EndIf
	
		Next
		
		dbSelectArea("TMPORC")
		dbGoTop()
		If !TMPORC->(Eof())
		
			Reclock("AK1",.T.)
			AK1_FILIAL := ALV->ALV_FILIAL
			AK1_CODIGO := ALV->ALV_CODIGO
			AK1_VERSAO := _cVerPlan
			AK1_DESCRI := ALV->ALV_DESCRI
			AK1_NMAX   := 99
			AK1_TPPERI := ALV->ALV_TPPERI
			AK1_INIPER := ALV->ALV_INIPER
			AK1_FIMPER := ALV->ALV_FIMPER
			AK1_TPREV  := '1'
			AK1_CTRUSR := If( Empty(ALV->ALV_CTRUSR) , "2" , ALV->ALV_CTRUSR )
			AK1_FASE   := ALV->ALV_FASE
			MsUnlock()
			
			RecLock("AKE",.T.)
			AKE->AKE_FILIAL := xFilial("AKE")
			AKE->AKE_ORCAME := ALV->ALV_CODIGO
			AKE->AKE_REVISA := _cVerPlan
			AKE->AKE_DATAI	:= MsDate()
			AKE->AKE_HORAI  := Time()
			AKE->AKE_DATAF  := MsDate()
			AKE->AKE_HORAF	:= Time()
			AKE->AKE_USERI  := RetCodUsr()
			AKE->AKE_USERF  := RetCodUsr()
			AKE->AKE_TIPO	:= "1"	    
			MsUnlock()
			
			If ! AK3->(dbSeek(xfilial("AK3") + ALV->ALV_CODIGO + _cVerPlan + ALV->ALV_CODIGO))
		
				Reclock("AK3",.T.)
				AK3_FILIAL := xfilial("AK3")
				AK3_ORCAME := ALV->ALV_CODIGO
				AK3_VERSAO := _cVerPlan
				AK3_CO     := ALV->ALV_CODIGO
				AK3_DESCRI := ALV->ALV_DESCRI
				AK3_NIVEL  := StrZero(nNiveEstr,3)
				MsUnlock()
		
			EndIf
		
		EndIf
		
		PcoIniLan("000252")
	
		Processa( {|| PcoGerPlan( nTot ) } , STR0159 ) //"Gerando Planilha Or็amentแria"
		
		PcoFinLan("000252" , , .T. )
	
		TMPORC->(dbCloseArea())
		
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoExclOrca      บAutorณJoใo Gon็alves de Oliveira บ Data ณ 27/06/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina para exclusใo de planilha or็amentแria                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoExclOrca(ExpC1,ExpC2)                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - C๓digo da Planilha Or็amentแria                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PCOExclOrca(cPlanOrca)

Local lContinua := .T.

dbSelectArea("AK1")
dbSetOrder(1)

If AK1->(dbSeek(xfilial("AK1") + cPlanOrca ))


	If AK1->AK1_STATUS<>"2"
	
		Help("  ",1,"PCOA1202")
		lContinua := .F.
	EndIf	
	
	If lContinua
		lContinua := (Aviso( STR0001 , STR0160 + cPlanOrca + STR0161 ,{ STR0083 , STR0084 })==1) //"Aten็ใo"###"Todos os dados da planilha "###" serใo excluํdos !, Confirma a exclusใo ?"###"Sim"###"Nใo"
		
		Begin Transaction
		
		//exclui as vers๕es simuladas
		dbSelectArea("AKR")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AKR")+cPlanOrca)
			RecLock("AKR",.F.,.T.)
			dbDelete()
			MsUnlock()
		End
		
		//exclui a amarracao usuario x conta orcamentaria
		dbSelectArea("AKG")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AKG")+cPlanOrca)
			RecLock("AKG",.F.,.T.)
			dbDelete()
			MsUnlock()
		End
		
		//exclui a ITENS da conta orcamentaria
		dbSelectArea("AK2")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AK2")+cPlanOrca)
			
			If AK2->AK2_VERSAO == AK1->AK1_VERSAO
				PcoDetLan("000252","01","PCOA100",.T.)
			Else
//				PcoDetLan("000252","02","PCOA100",.T.)
			EndIf
			RecLock("AK2",.F.,.T.)
			dbDelete()
			MsUnlock()
			
		End
		
		//exclui contas orcamentaria da planilha
		dbSelectArea("AK3")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AK3")+cPlanOrca)
			RecLock("AK3",.F.,.T.)
			dbDelete()
			MsUnlock()
		End
		
		//exclui o registro de revisoes
		dbSelectArea("AKE")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AKE")+cPlanOrca)
			RecLock("AKE",.F.,.T.)
			dbDelete()
			MsUnlock()
		End
		
		//exclui contas orcamentaria da planilha
		dbSelectArea("AK1")
		dbSetOrder(1)
		
		While dbSeek(xFilial("AK1")+cPlanOrca)
			RecLock("AK1",.F.,.T.)
			dbDelete()
			MsUnlock()
		End
		
		End Transaction
	
	EndIf
	
EndIf

Return(lContinua)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGerPlanบAutor  ณ Acacio Egas        บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de gera็ใo das tabelas da Planilha Or็amentario     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoGerPlan( nTot )

Local nContItem
Local nIdtfPlan := 1
Local cCtaOrca := TMPORC->ALX_CO
Local cEntiPlan := TMPORC->(ALX_CO+ALX_CLASSE+ALX_CC+ALX_OPER+ALX_ITCTB+ALX_CLVLR)
	
	ProcRegua( nTot )
	
	While ! TMPORC->(Eof())
	
		IncProc()
		
		If TMPORC->ALY_VALOR<>0
			
			aEstrPlan := {}
			nNiveEstr := 2
			
			If AK5->(dbSeek(xfilial("AK5") + TMPORC->ALX_CO))
				
				PCOBuscCtaSupe(TMPORC->ALX_CO,aEstrPlan)
				
			EndIf
			
			If Len(aEstrPlan) > 0
				
				aEstrPlan := aSort(aEstrPlan,,,{|x,y| Val(x[1]) < Val(y[1])})
				
				For nContItem := 1 to Len(aEstrPlan)
					
					AK3->(DbSetOrder(1))
					If AK3->(dbSeek(xfilial("AK3") + ALV->ALV_CODIGO + _cVerPlan  + PadR( aEstrPlan[nContItem,2], Len(AK3->AK3_PAI)) ))
				
						nNiveEstr := Val(AK3->AK3_NIVEL)
						nNiveEstr ++
						
					EndIf
					
					Reclock("AK3",.T.)
					AK3_FILIAL := xfilial("AK3")
					AK3_ORCAME := ALV->ALV_CODIGO
					AK3_VERSAO := _cVerPlan
					AK3_CO     := aEstrPlan[nContItem,1]
					AK3_PAI    := aEstrPlan[nContItem,2]
					AK3_TIPO   := aEstrPlan[nContItem,3]
					AK3_NIVEL  := StrZero(nNiveEstr,3)
					AK3_DESCRI := aEstrPlan[nContItem,4]
					MsUnlock()
					nNiveEstr ++
					
				Next
				
			EndIf
			
			Reclock("AK2",.T.)
			AK2_FILIAL := xfilial("AK2")
			AK2_ID     := StrZero(nIdtfPlan,4)
			AK2_ORCAME := ALV->ALV_CODIGO
			AK2_VERSAO := _cVerPlan
			AK2_PERIOD := STOD(TMPORC->ALY_DTINI)
			AK2_CO     := TMPORC->ALX_CO
			AK2_CC     := TMPORC->ALX_CC
			AK2_ITCTB  := TMPORC->ALX_ITCTB
			AK2_CLVLR  := TMPORC->ALX_CLVLR
			AK2_CLASSE := TMPORC->ALX_CLASSE
			AK2_OPER   := TMPORC->ALX_OPER
			AK2_VALOR  := ABS(TMPORC->ALY_VALOR)
			AK2_MOEDA  := 1
			AK2_DATAF  := STOD(TMPORC->ALY_DTINI)
			AK2_DATAI  := STOD(TMPORC->ALY_DTFIM)
			MsUnlock()
			
			If AK2->AK2_VERSAO == AK1->AK1_VERSAO
				
				PcoDetLan("000252","01","PCOA100")
				
			Else
			
//				PcoDetLan("000252","02","PCOA100")
				
			EndIf
			
		EndIf

		TMPORC->(dbSkip())
		
		If ! TMPORC->(ALX_CO+ALX_CLASSE+ALX_CC+ALX_OPER+ALX_ITCTB+ALX_CLVLR) == cEntiPlan
		
			nIdtfPlan ++
			cEntiPlan := TMPORC->(ALX_CO+ALX_CLASSE+ALX_CC+ALX_OPER+ALX_ITCTB+ALX_CLVLR)
			
		EndIf
		
	End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXPNJ   บAutor  ณMicrosiga           บ Data ณ  07/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoIni_VarStatic()

//carrega as variaveis static
If cTipoDB == NIL .And. ;
	cSrvType == NIL .And. ;
	lOracle == NIL .And. ;
	lDB2 == NIL .And. ;
	lInformix == NIL .And.;
	lPostgres == NIL
	cTipoDB	:= Alltrim(Upper(TCGetDB()))
	cSrvType := Alltrim(Upper(TCSrvType()))	
	lOracle		:= "ORACLE"   $ cTipoDB
	lDB2			:= "DB2"      $ cTipoDB
	lInformix 	:= "INFORMIX"   $ cTipoDB
	lPostgres	:= 'POSTGRES' $ cTipoDB
EndIf

Return

//********************************************************
// Funcoes disponiveis para configuracao de planejamento *
//********************************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoPrdCompบAutor  ณ Acacio Egas         Data ณ  08/27/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao disponivel para buscar custo do produto.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao disponivel para Configuracao de planejamento        บฑฑ
ฑฑฬออออออออออุอออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cChave  บ Codigo do Produto                                บฑฑ
ฑฑบ          ณ cTipoCusบ Tipo do Custo a ser utilizado                    บฑฑ
ฑฑศออออออออออฯอออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PcoPrdComp(cChave)

Local nPrecAgre := nil
Local aParam	:= {}
Local aConfig	:= {}
LOcal cBakcad	:= cCadastro

aAdd(aParam,{ 3, STR0029 ,1,{ STR0008 , STR0030 , STR0031 },50,"",.F.}) //"Tipo de Valor (Custo)"###"Custo Standard"###"U.Pr.Compra"###"Custo M้dio"###"Custo M้dio"

cCadastro	:= ''
If ParamBox(aParam,"Pre็o de custo do Produto:" + cChave,@aConfig)
	
	If aConfig[1]== 1 // Busca Custo Standard
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cChave))
			nPrecAgre := SB1->b1_custd
		EndIf
	ElseIf aConfig[1]== 2
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cChave))
			nPrecAgre := SB1->B1_UPRC
		EndIf
	Else // cTipoCus == "4" - Custo M้dio
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cChave))
			dbSelectARea("SB2")
			dbSetOrder(1)
			If SB2->(dbSeek(xfilial("SB2") + cChave + SB1->B1_LOCPAD))
				nPrecAgre := SB2->b2_cm1
			EndIf
		EndIf
		
	EndIf
EndIf
cCadastro	:= cBakcad

Return nPrecAgre

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoPrdVendบAutor  ณ Acacio Egas         Data ณ  08/27/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao disponivel para buscar custo do produto.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao disponivel para Configuracao de planejamento        บฑฑ
ฑฑฬออออออออออุอออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cChave  บ Codigo do Produto                                บฑฑ
ฑฑบ          ณ cTipoCusบ Tipo do Custo a ser utilizado                    บฑฑ
ฑฑศออออออออออฯอออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PcoPrdVend(cChave)

Local nPrecAgre := nil
Local aParam	:= {}
Local aConfig	:= {}
LOcal cBakcad	:= cCadastro

aAdd(aParam,{ 3, STR0007 , 1		,{ STR0008 , STR0009 }	,50		,""	,.F.}) //"Tipo de Valor (Receita)"###"Custo Standard"###"Pre็o Venda"
aAdd(aParam,{ 1, STR0010 , SPACE(3)	,"@S3","Vazio() .or. ExistCpo('DA0')"	, "DA0", ".T."	,6	,.F.}) //"Tabela de Pre็o"

cCadastro	:= ''
If ParamBox(aParam,"Pre็o de Venda do Produto:" + cChave,@aConfig)

	If aConfig[1]== 1 // Busca Custo Standard
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cChave))
			nPrecAgre := SB1->b1_custd
		EndIf
	ElseIf aConfig[1]== 2
		dbSelectArea("DA1")
		dbSetOrder(1)
		If DA1->(dbSeek(xfilial("DA1") + aConfig[2] + cChave))
			nPrecAgre := DA1->DA1_PRCVEN
		EndIf
	EndIf

EndIf
cCadastro	:= cBakcad

Return nPrecAgre

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoSavHistบAutor  ณAcacio Egas         บ Data ณ  08/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใoo do historico do planejamento.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoSavHist(cTpCod,cVarPnj,cRegra,_Param)

Local cSeq	:= "01"

Default cRegra	:= ''
Default _Param	:= ''
If Type("_cSeqTpPnj")=="C"

Else
	
	cQuery := "SELECT MAX(AME_SEQ) AME_SEQ FROM " + RetSqlName("AME") + " AME WHERE D_E_L_E_T_ = ' '  AND AME_PLANEJ='" + ALV->ALV_CODIGO + "' AND AME_VERSAO='" + ALV->ALV_VERSAO + "' AND AME_TPCOD='" + cTpCod  + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALX", .T., .T. )	
	
	If TMPALX->(!Eof())
		cSeq	:= Soma1(TMPALX->AME_SEQ)
	EndIf
	TMPALX->(DbCloseArea())	
	
	RecLock("AME",.T.)
		AME_FILIAL	:= xFilial("AME")
		AME_PLANEJ	:= ALV->ALV_CODIGO
		AME_VERSAO	:= ALV->ALV_VERSAO
		AME_TPCOD	:= cTpCod
		AME_VARPNJ	:= cVarPnj
		AME_SEQ		:= cSeq
		AME_REGRA	:= cRegra
		AME_PARAM	:= ParToStr(_Param)
	MsUnlock()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณParToStr  บAutor  ณAcacio Egas         บ Data ณ  08/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de transformacao de variavel em String.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ParToStr(_Param)

Local nX
Local cRet	:= ""

If VALTYPE(_Param)=="A"   

	cRet	+=  "{"

	For nX	:= 1 To Len(_Param)

		cRet	+= ParToStr(_Param[nX]) + If(nX==Len(_Param),"}",",")
	
	Next

ElseIf VALTYPE(_Param)=="N"

	cRet	:=  "#N" + Alltrim(Str(_Param))

ElseIf VALTYPE(_Param)=="C"

	cRet	:=  "#C" + Alltrim(_Param)

ElseIf VALTYPE(_Param)=="D"

	cRet	:=  "#D" + Dtos(_Param)

ElseIf VALTYPE(_Param)=="L"

	cRet	:=  "#L" + If(_Param,"T","F")

ElseIf VALTYPE(_Param)=="B"

	cRet	:=  "#B" + Alltrim(Str(_Param))

EndIf


Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณStrToPar  บAutor  ณAcacio Egas         บ Data ณ  08/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de transformacao de String em variavel.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StrToPar(_Param)

Local nArray :=0
Local cIt
Local cType
Local nX	:= 1
Local cFim,cRet	:= ""
_Param	:= ALLTRIM(_Param)
Do While Len(_Param)>=nX
	
	cIt	:= SubStr(_Param,nX,1)
	
	If cIt==","
		If cType=="C"
			cRet	+= "'"
		ElseIf cType=="D"
			cRet	+= "')"
		ElseIf cType=="L"
			cRet	+= "."
		EndIf
		cType := ''
		cRet	+= ","
		nX ++
	ElseIf cIt=="{"
		cRet	+= "{"
		cFim := SubStr(_Param,nX+1)
		nArray := nX+1
		While (nFim := AT("}",cFim))>0
			If AT("{",cFim)==0 .or. AT("{",cFim)>nFim
				nArray 	+= nFim
				Exit
			EndIf
			cFim 	:= SubStr(cFim,nFim+1)
			nArray 	+= nFim
		EndDo
		cRet += StrToPar(SubStr(_Param,(nX + 1),nArray-(nX + 2))) + "}"
		nX	:= nArray
		cType := ''
	ElseIf cIt=="#"
		nX ++
		cType	:= SubStr(_Param,nX,1)
		If cType=="N"
			cRet	+= ""
		ElseIf cType=="C"
			cRet	+= "'"
		ElseIf cType=="D"
			cRet	+= "StoD('"
		ElseIf cType=="L"
			cRet	+= "."
		ElseIf cType=="B"

		EndIf
		nX ++
	Else
		cRet += SubStr(_Param,nX,1)
		nX ++
	EndIf
	
EndDo

If cType=="C"
	cRet	+= "'"
ElseIf cType=="D"
	cRet	+= "')"
ElseIf cType=="L"
	cRet	+= "."
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoALXIni บAutor  ณAcacio Egas         บ Data ณ  08/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de inicializacao de campos da tabela ALX.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoALXIni(cVar,aRecnos)

Local nX

PcoIniLan("000358")
For	nX := 1 To Len(aRecnos)

	DbSelectArea("ALX")
	DbGoTo(aRecnos[nX])

	RecLock("ALX",.F.)
	ALX_FILIAL 	:= xfilial("ALX")
	ALX_PLANEJ 	:= ALV->ALV_CODIGO
	ALX_VERSAO 	:= ALV->ALV_VERSAO
	ALX_AGREG	:= AM2->AM2_AGREG
	ALX_AM2ID	:= AM2->AM2_ID
	ALX_FILTRO	:= '#'
	ALX_TIPOPL 	:= AM1->AM1_CODIGO
	ALX_VARPNJ	:= cVar
	MsUnlock()
	If Empty(ALX->ALX_SEQ)
		cSeq	:=	PcoALXSeq()
		RecLock("ALX",.F.)
		ALX_SEQ 	:= cSeq
		MsUnlock()
	EndIf
    
	DbSelectArea("ALY")
	dbSetOrder(1)
	If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+ALX->ALX_SEQ)

		Do While ALY->(!Eof()) .and. ALY->(ALY_FILIAL+ALY_PLANEJ+ALY_VERSAO+ALY->ALY_SEQ)==ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+ALX->ALX_SEQ
			PcoDetLan("000358","01","PCOXPNJ")
			ALY->(DbSKip())
		
		EndDo
	
	EndIf

Next
PcoFinLan("000358")

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoResPlanบAutor  ณAdam Diniz Lima     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida restricoes									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*///(Codigo.Planejamento , Id de Restri็ใo , Valor)
Function PcoResPlan (clPlan, clIdRes, nlValor )

	Local llOk := .T.  
	
	If Select("AMT") > 0
		AMT->(DbCloseArea())   
		DbSelectArea("AMT")
		If DbSeek(xFilial("AMT")+clPlan+clIdRes)
			If nlValor > AMT->AMT_MAXIMO
				llOk := .F.
				Aviso("Aten็ใo!","O valor de Restri็ใo foi excedido.",{"Ok"})	     
			Endif
		EndIf 
	EndIf
           
Return llOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoEngine บAutor  ณ Daniel Leme        บ Data ณ  08/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza Valida็๕es chamada ao processo de Integra็ใo do    บฑฑ
ฑฑบ          ณ ERP com a Planilha de Planejamento                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoEngine(cId,cPlanej,cVarPnj,nRecAMC,lBuildAM2)
Local aAreas 	:= {	AM1->(GetArea()),;
							AM2->(GetArea()),;
							AMC->(GetArea()),;
							AMD->(GetArea()),;
							AKB->(GetArea()),;
							AKC->(GetArea()),;
							AMJ->(GetArea()),;
							ALX->(GetArea()),;
							ALY->(GetArea()),;
							ALV->(GetArea()),;
							GetArea()}
Local cChvAMC		:= ""
Local aCampos		:= {}
Local aParametros	:= {}
Local aRet			:= {}
Local lContinua	:= .T.
Local cQuery 		:= ""
Local cAliasQry	:= ""
Local lJoin 		:= .F.

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se foi indicado Processo de Origem e a Importa็ใo da Origem foi agrupada, impossibilitando o relacionamento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/

//-- Posicionar AMC no ๚ltimo Nivel da Estrutura para a leitura descendente
AMC->(DbSetOrder(1)) //-- AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD+AMC_NIVEL
If !(lContinua := AMC->(DbSeek(xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO)))
	Alert("Problemas na Configura็ใo da Estrutura da Planilha de Planejamento! Verifique a Configura็ใo!")
EndIf

cChvAMC := AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD) 
If !AMC->(DbSeek( cChvAMC + Replicate( 'z', Len(AMC_NIVEL)), .T. ))
	AMC->(DbSkip(-1))
EndIf
If lContinua .And. !(lContinua := cChvAMC == AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD))
	Alert("Problemas na Configura็ใo da Estrutura da Planilha de Planejamento! Verifique a Configura็ใo!")
EndIf

//-- Verifica se foi informado Processo+Item para realizar JOIN entre a แrea de Integra็ใo e a Tabela de Origem.
//-- Importante: Quando preenchido, Processo+Item ้ o mesmo para todos os nํveis da estrutura
If lContinua .And. !Empty(AM1->AM1_PROINT) .And. !Empty(AM1->AM1_ITEINT)
	        
	//-- Posicionar AKB
	AKB->(DbSetOrder(1)) //-- AKB_FILIAL+AKB_PROCES+AKB_ITEM
	If !(lContinua := AKB->(MsSeek(xFilial("AKB") + AM1->(AM1_PROINT+AM1_ITEINT) )))
		Alert("Problemas na Configura็ใo do Processo de Integra็ใo indicado! Verifique a Configura็ใo da Integra็ใo!")
	EndIf

	//-- Somente serแ possํvel ligar a Integra็ใo เ Origem (JOIN) se todos os registros da Integra็ใo possuirem Chave (Integra็ใo sem Acumular)
	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) NRECS"
	cQuery += " FROM " + RetSqlName("AMJ") + " AMJ "
	cQuery += " WHERE "
	cQuery += "    AMJ_FILIAL				= '"+xFilial("AMJ")+"' "
	cQuery += "    AND AMJ_PROCES 		= '"+AM1->AM1_PROINT+"' "	
	cQuery += "    AND AMJ_ITEM   		= '"+AM1->AM1_ITEINT+"' "	
	cQuery += "    AND AMJ_CHAVE  		= ' ' "	
	cQuery += "    AND AMJ.D_E_L_E_T_ 	= ' ' "
	If Type("aDataPlnj") == "A" .And. !Empty(aDataPlnj)
		//-- Data maior ou igual เ menor data do primeiro perํodo
		cQuery += " AND AMJ_DATPLA >= '" + aDataPlnj[1][1] + "' "
		//-- Data menor ou igual เ maior data do ๚ltimo perํodo
		cQuery += " AND AMJ_DATPLA <= '" + aDataPlnj[Len(aDataPlnj)][2] + "' "
	EndIf
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	lJoin := (cAliasQry)->(Eof()) .Or. (cAliasQry)->NRECS == 0
	(cAliasQry)->(DbCloseArea())

EndIf

//-- Abre Parambox para sele็ใo de entidades que devem acumular.
aAdd(aCampos,{"AMJ_CO"		,.T.})
aAdd(aCampos,{"AMJ_CLASSE"	,.T.})
aAdd(aCampos,{"AMJ_OPER"	,.T.})
aAdd(aCampos,{"AMJ_CC"		,.T.})
aAdd(aCampos,{"AMJ_ITCTB"	,.T.})
aAdd(aCampos,{"AMJ_CLVLR"	,.T.})

aParametros := { 	{ 5, Posicione("SX3",2,aCampos[1][1],"X3Titulo()"),.T.,120,,.F.},;
						{ 5, Posicione("SX3",2,aCampos[2][1],"X3Titulo()"),.T.,120,,.F.},;
						{ 5, Posicione("SX3",2,aCampos[3][1],"X3Titulo()"),.T.,120,,.F.},;
						{ 5, Posicione("SX3",2,aCampos[4][1],"X3Titulo()"),.T.,120,,.F.},;
						{ 5, Posicione("SX3",2,aCampos[5][1],"X3Titulo()"),.T.,120,,.F.},;
						{ 5, Posicione("SX3",2,aCampos[6][1],"X3Titulo()"),.T.,120,,.F.} }


If lContinua .And. ParamBox(aParametros,"Agrupamento",aRet) //"Parametros"
	If aScan(aRet,{|x| x == .T. }) == 0
		Alert("Ao menos uma Entidade Or็amentแria deverแ ser selecionada para Agrupamento na Integra็ใo!")
		lContinua := .F.
	EndIf
   aEval(aRet,{ |x,nI| aCampos[nI][2] := x })
   
   If lContinua
		//-- Busca dados da Area de Integracao - Tabela 
		Processa({|| PcoGerEng(cId,cPlanej,cVarPnj,nRecAMC,lBuildAM2,aCampos,lJoin) },"Aguarde","Buscando Informa็๕es Integradas...")
	EndIf
EndIf

aEval(aAreas,{|x| RestArea(x) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGerEng บAutor  ณ Daniel Leme        บ Data ณ  08/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da Area de Integra็ใo para preenchimento     บฑฑ
ฑฑบ          ณ da Planilha de Planejamento                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoGerEng(cId,cPlanej,cVarPnj,nRecAMC,lBuildAM2,aCampos,lJoin)
Local aAreas 	:= {	AM1->(GetArea()),;
							AM2->(GetArea()),;
							AMC->(GetArea()),;
							AMD->(GetArea()),;
							AKB->(GetArea()),;
							AKC->(GetArea()),;
							AMJ->(GetArea()),;
							ALX->(GetArea()),;
							ALY->(GetArea()),;
							SX3->(GetArea()),;
							ALV->(GetArea()),;
							GetArea()}

Local aAreaAM2 	:= AM2->(GetArea()) 
Local aAreaAMC 	:= AMC->(GetArea()) 
Local cNivelAMC 	:= ""
Local aNiveis 		:= {}

Local cQuery 		:= ""
Local cSelect		:= ""
Local cFrom  		:= ""
Local cJoin  		:= ""
Local cWhere 		:= ""
Local cGrpBy 		:= ""
Local cOrdBy 		:= ""
Local cWhereAux 	:= ""
Local cWhereAMD 	:= ""
Local cAliasQry 	:= ""

Local cFiltAux 	:= ""
Local cFiltOri 	:= ""
Local cFiltAMD 	:= ""

Local cTrab 		:= ""
Local cInd01 		:= ""
Local aStruct 		:= {}

Local lContinua 	:= .T.
Local lResolvQry 	:= .T.
Local lGrava 		:= .T.
Local lValidSQL	:= .F.
Local bError

Local cChvAMC,cChvTrb,cIdPai,cBloco
Local nI, nJ, nTo
                      
If Type("aDataPlnj") == "U"
	Private aDataPlnj := {}
EndIf

IncProc("Criando mecanismo de Pesquisa...")

//-- Montagem da Clausula "SELECT"
cSelect := " SELECT "

//-- Somente Campos Selecionados para agrupamento serใo preenchidos
aEval(aCampos,{ |x| cSelect += Iif(x[2], x[1]+ ", ", "") })

//-- Soma os campos de Valor de 1 a 5
nTo := 5
For nI := 1 To nTo
	cSelect += "    SUM(CASE "
	cSelect += "             WHEN AMJ_TIPO = '1' THEN" //-- Credito - Soma
	cSelect += "                  AMJ_VALOR"+AllTrim(Str(nI))
	cSelect += "             WHEN AMJ_TIPO = '2' THEN" //-- Debito - Subtrai
	cSelect += "                  AMJ_VALOR"+AllTrim(Str(nI))+" * (-1) "
	cSelect += "             ELSE 0 "
	cSelect += "        END) AMJ_VALOR" + AllTrim(Str(nI)) + ", "

Next nI
cSelect := Left(cSelect,Len(cSelect)-2) + " "

//-- Montagem da clausula "FROM"
cFrom := " FROM " + RetSqlName("AMJ") + " AMJ "

//-- Guarda o nํvel em que estแ posicionado na estrutura 
If !Empty(nRecAMC)
	AMC->(DbGoto(nRecAMC))
	cNivelAMC := AMC->AMC_NIVEL
EndIf

//-- Posicionar AMC no ๚ltimo Nivel da Estrutura para a leitura descendente
AMC->(DbSetOrder(1)) //-- AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD+AMC_NIVEL
lContinua := AMC->(DbSeek(xFilial("AMC")+AM1->AM1_CFGPLN+AM1->AM1_CODIGO))

cChvAMC := AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD) 
If !AMC->(DbSeek( cChvAMC + Replicate( 'z', Len(AMC_NIVEL)), .T. ))
	AMC->(DbSkip(-1))
EndIf
If (lContinua := cChvAMC == AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD))
	aAreaAMC := AMC->(GetArea()) 
EndIf

//-- Verifica se possui Integra็ใo configurada
lContinua := !Empty(AMC->AMC_CHVINT)

//-- Verifica se foi informado Processo+Item para realizar JOIN entre a แrea de Integra็ใo e a Tabela de Origem.
//-- Importante: Quando preenchido, Processo+Item ้ o mesmo para todos os nํveis da estrutura
If lContinua .And. lJoin .And. !Empty(AM1->AM1_PROINT) .And. !Empty(AM1->AM1_ITEINT)
	        
	//-- Posicionar AKB
	AKB->(DbSetOrder(1)) //-- AKB_FILIAL+AKB_PROCES+AKB_ITEM
	lContinua := AKB->(MsSeek(xFilial("AKB") + AM1->(AM1_PROINT+AM1_ITEINT) ))
	
	If lContinua

		//-- Verifica se ้ possํvel resolver expressใo SQL para ligar a มrea de Integra็ใo เ tabela de Origem
		cJoin := PCOSQLJoin( AKB->AKB_ENTIDA /*cAlias*/, AKB->AKB_INDICE /*nIndice*/, "AMJ_CHAVE"/*cCpoChave*/)
	
		//-- Se houver como resolver expressใo de igualdade para o JOIN, liga-o เ query
		If !Empty( cJoin ) 

			cJoin := " JOIN " + RetSqlName(AKB->AKB_ENTIDA) + " " + AKB->AKB_ENTIDA + " ON " + cJoin
			
		Else
			
			lJoin := .F.
	
		EndIf

	EndIf

EndIf

//-- Montagem da Clausula "WHERE"
cWhere := " WHERE "
cWhere += "    AMJ_FILIAL = '"+xFilial("AMJ")+"' "
cWhere += "    AND AMJ.D_E_L_E_T_ = ' ' "
If lContinua .And. !Empty(AM1->AM1_PROINT) .And. !Empty(AM1->AM1_ITEINT)
	cWhere += "    AND AMJ_PROCES = '"+AM1->AM1_PROINT+"' "	
	cWhere += "    AND AMJ_ITEM   = '"+AM1->AM1_ITEINT+"' "	
EndIf


//-- Realiza Leitura descendente dos Niveis da Estrutura para constru็ใo da query
AM2->(DbSetOrder(3)) //-- AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_ID+AM2_IDPAI
Do While lContinua .And. AMC->(!Bof()) .And. AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD) == cChvAMC

	//-- Realiza Filtragem do mesmo nivel e dos Niveis inferiores ao selecionado com a AM2
	If !lBuildAM2 .Or. AMC->AMC_NIVEL <= cNivelAMC
		cWhereAux := PCOSQLSvK(AllTrim(AMC->AMC_CHVINT),, AM2->AM2_AGREG)
		If !Empty(cWhereAux)
			cWhere += " AND " + cWhereAux
		Else 
			Alert("Nใo foi possํvel a liga็ใo com a Entidade identificada pelo C๓digo: " + AllTrim(AMC->AMC_CHVINT) + ". Verifique a configura็ใo da Planilha de Planejamento e os parโmetros de Importa็ใo!")
			lContinua := .F.
		EndIf
	EndIf
	//-- Caso seja selecionada a op็ใo de Constru็ใo da Tabela AM2, Cria as Colunas para todos nํves
	If lBuildAM2
	
		cSelect += ", " + AllTrim(AMC->AMC_CHVINT) + " NIVEL" + AMC->AMC_NIVEL
		aAdd(aNiveis,{AMC->AMC_NIVEL,AMC->AMC_TABELA,""})
		
	EndIf
	   
   //-- Verifica se possui filtro na tabela de integra็ใo e se ้ possํvel resolv๊-lo na Query
   If !Empty(AMC->AMC_FILINT)
	  	cWhereAux := PcoParseFil(AMC->AMC_FILINT, "AMJ")
		If Empty(cWhereAux)
			lResolvQry 	:= .F.
	   	cFiltAux += If( !Empty(cFiltAux), " .And. ", "") + "( " + AMC->AMC_FILINT + ")"
		Else
			cWhere += " AND (" + cWhereAux + ") "
		EndIf
	EndIf
	
   //-- Verifica se possui filtro na tabela de Origem e se ้ possํvel resolv๊-lo na Query
	If lContinua .And. !Empty(AMC->AMC_FILPRI) 
		If !Empty( cJoin ) 
		  	cWhereAux := PcoParseFil(AMC->AMC_FILPRI, AKB->AKB_ENTIDA)
			If Empty(cWhereAux)
				lResolvQry 	:= .F.
		   	cFiltOri += If( !Empty(cFiltOri), " .And. ", "") + "( " + AMC->AMC_FILPRI + ")"
			Else
				cWhere += " AND (" + cWhereAux + ") "
			EndIf
		Else
			Alert("Nใo foi possํvel a liga็ใo com a tabela de Origem. Verifique a configura็ใo de Integra็ใo e os parโmetros de Importa็ใo!")
			lContinua := .F.
		EndIf
	EndIf
	
	//-- Valida็๕es caso seja indicado processo 
	If lContinua .And. !Empty(AM1->AM1_PROINT) .And. !Empty(AM1->AM1_ITEINT)

		//-- Se a Chave de Integra็ใo depender do Join e este nใo for possํvel, serแ abortado o processo.	
		If Empty(cJoin) .And. (Substr(AKB->AKB_ENTIDA,If(Left(AKB->AKB_ENTIDA,1)=="S",2,1))+"_") $ AMC->AMC_CHVINT
			Alert("Nใo foi possํvel a liga็ใo com a tabela de Origem. Verifique a configura็ใo de Integra็ใo e os parโmetros de Importa็ใo!")
			lContinua := .F.
	   EndIf

   EndIf

	//-- Sobe um nivel na Estrutura da configura็ใo e, caso necessแrio, na Planilha.
	If lContinua .And. AMC->AMC_NIVEL <= cNivelAMC
		If !Empty(AM2->AM2_IDPAI) .And. AM2->(!DbSeek(AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_IDPAI))
			Alert("Nใo foi possํvel Percorrer a estrutura da Planilha. Erro na tabela AM2!")
			lContinua := .F.
		EndIf
	EndIf
	
	AMC->(DbSkip(-1))

EndDo

//-- Reposiciona as tabelas ap๓s percorrer estrutura
RestArea(aAreaAM2)
RestArea(aAreaAMC)


//-- Montagem da Clausula "GROUP BY", condicional, pois se houver JOIN com a origem, nใo agruparแ
cGrpBy := " GROUP BY "
aEval(aCampos,{ |x| cGrpBy += Iif(x[2], x[1]+", ", "")  })
cGrpBy := Left(cGrpBy, Len(cGrpBy)-2)

//-- Montagem da Clausula "ORDER BY" 
cOrdBy := " "
If lBuildAM2
	cOrdBy := " ORDER BY "
	For nI := Len(aNiveis) To 1 Step -1
		cOrdBy += aNiveis[nI][1] + ", "
	Next nI
	cOrdBy := Left(cOrdBy,Len(cOrdBy)-2)
EndIf

//-- Define Arquivo de Trabalho
If lContinua
	Aadd(aStruct,{"ALX_AGREG"	,ValType(ALX->ALX_AGREG)	,TamSX3("ALX_AGREG")[1]		,TamSX3("ALX_AGREG")[2]	})
	Aadd(aStruct,{"ALX_AM2ID"	,ValType(ALX->ALX_AM2ID)	,TamSX3("ALX_AM2ID")[1]		,TamSX3("ALX_AM2ID")[2]	})
	Aadd(aStruct,{"ALX_CO"		,ValType(ALX->ALX_CO)		,TamSX3("ALX_CO")[1]	  		,TamSX3("ALX_CO")[2]		})
	Aadd(aStruct,{"ALX_CLASSE"	,ValType(ALX->ALX_CLASSE)	,TamSX3("ALX_CLASSE")[1]	,TamSX3("ALX_CLASSE")[2]})
	Aadd(aStruct,{"ALX_OPER"	,ValType(ALX->ALX_OPER)		,TamSX3("ALX_OPER")[1]		,TamSX3("ALX_OPER")[2]	})
	Aadd(aStruct,{"ALX_CC"		,ValType(ALX->ALX_CC)		,TamSX3("ALX_CC")[1]	  		,TamSX3("ALX_CC")[2]		})
	Aadd(aStruct,{"ALX_ITCTB"	,ValType(ALX->ALX_ITCTB)	,TamSX3("ALX_ITCTB")[1]		,TamSX3("ALX_ITCTB")[2]	})
	Aadd(aStruct,{"ALX_CLVLR"	,ValType(ALX->ALX_CLVLR)	,TamSX3("ALX_CLVLR")[1]		,TamSX3("ALX_CLVLR")[2]	})
	Aadd(aStruct,{"ALX_CODIGO"	,ValType(ALX->ALX_CODIGO)	,TamSX3("ALX_CODIGO")[1]	,TamSX3("ALX_CODIGO")[2]})
	Aadd(aStruct,{"ALX_REGRA"	,ValType(ALX->ALX_REGRA)	,TamSX3("ALX_REGRA")[1]		,TamSX3("ALX_REGRA")[2]	})
	Aadd(aStruct,{"ALX_TIPO"	,ValType(ALX->ALX_TIPO)		,TamSX3("ALX_TIPO")[1]		,TamSX3("ALX_TIPO")[2]	})
	Aadd(aStruct,{"ALY_QUANT"	,ValType(ALY->ALY_QUANT)	,TamSX3("ALY_QUANT")[1]		,TamSX3("ALY_QUANT")[2]	})
	Aadd(aStruct,{"ALY_VALOR"	,ValType(ALY->ALY_VALOR)	,TamSX3("ALY_VALOR")[1]		,TamSX3("ALY_VALOR")[2]	})
	Aadd(aStruct,{"DATAPLNJ"	,"C"								,8									,0								})
	Aadd(aStruct,{"DATAFINA"	,"C"								,8									,0								})
	
	cTrab := GetNextAlias()
	TCDelFile(cTrab)
	dbCreate(cTrab,aStruct,"TOPCONN")
	DbUseArea(.T.,"TOPCONN",cTrab,"TR1",.T.,.F.)
	DbSelectArea("TR1")
	
	//-- Cria Indice no Arquivo de Trabalho, para poder acumular
	cInd01 := GetNextAlias()
	DbCreateIndex(cInd01,"ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR + DATAPLNJ + DATAFINA",;
							{|| ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR + DATAPLNJ + DATAFINA },.F.)
	
	Set Index To (cInd01)
	
EndIf

//-- Percorre a Tabela AMD para os lancamentos do tipo "Movimento", para complementar a query com o filtro.
AMD->(DbSetOrder(1)) //-- AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD+AMD_VARCOD
AMD->(DbSeek(xFilial("AMD")+AMC->(AMC_CFGPLN+AMC_TPCOD)))
Do While lContinua .And. AMD->(!Eof()) .And. AMD->( AMD_FILIAL+AMD_CFGPLN+AMD_TPCOD ) == xFilial("AMD")+AMC->(AMC_CFGPLN+AMC_TPCOD)


	//-- Inicializa Private para grava็ใo da ALX
	_cVarPnj := AMD->AMD_VARCOD
	//-- Somente Lancamentos do tipo 1-Movimento serใo preenchidos por esta rotina
	If AMD->AMD_TPVAR == "1"

		cWhereAMD := ""
		
	   //-- Verifica se possui filtro na para a Varia็ใo e se ้ possํvel resolv๊-lo na Query
		If !Empty(AMD->AMD_FILINT)
	
		  	cWhereAMD := PcoParseFil(AMD->AMD_FILINT, "AMJ")
		  	
			If Empty(cWhereAMD)
				lResolvQry	:= .F. //-- DANIEL: ESTAH ERRADO, POIS, NESTE REGISTRO DA AMD NAO CONSEGUIU, NO PROXIMO, PODERA FUNCIONAR.
		   	cFiltAMD 	:= AMD->AMD_FILINT
			Else
				cWhere += " AND (" + cWhereAMD + ") " //-- DANIEL: AQUI ESTA ERRADO, POIS ACUMULA FILTRO DE REGISTROS DISTINTOS
			EndIf
	
		EndIf

		//-- Montagem da(s) query(ies) para cada perํodo do planejamento
		nTo := Len(aDataPlnj)
		ProcRegua(nTo)

		For nI := 1  To nTo

			IncProc("Processando Informa็๕es...")
			cAliasQry := GetNextAlias()
			cWhereAux := " AND AMJ_DATPLA >= '" + aDataPlnj[nI][1] + "' "
			cWhereAux += " AND AMJ_DATPLA <= '" + aDataPlnj[nI][2] + "' "
			
		   //-- Se for necessแrio aplica็ใo de Filtro ou Constru็ใo da มrvore, nใo agrupa as informa็๕es.                                                             
		   //-- DANIEL: AQUI ESTAH ERRADO, POIS, DENTRO DO LOOP, DARA AMBIGUOUS COLUMN... 
		   //-- (CONT): DEVERA SER TRATADO  O CSELECT PARA CADA REGISTRO AMD, SENAO  
			If !lResolvQry .Or. lBuildAM2      
			
				//-- Limpa a Clแsula "GROUP BY" da query
				cGrpBy := ""
			
				//-- Adiciona o Recno da tabela de Integra็ใo - AMJ - aos campos do Select
				cSelect += ", AMJ.R_E_C_N_O_ REC_AMJ "

				//-- Adiciona o Recno da tabela de origem aos campos do Select, se houver Join
				If !Empty(cJoin)
					cSelect += ", " + AKB->AKB_ENTIDA +".R_E_C_N_O_ REC_ORIG "
			   EndIf

				//-- Retira a Sumariza็ใo do select, pois nใo haverแ "GROUP BY"
				cSelect := StrTran(cSelect, "SUM", "")

			EndIf          
			
			cQuery := cSelect + cFrom + cJoin + cWhere + cWhereAux + cGrpBy + cOrdBy
			cQuery := ChangeQuery(cQuery)
         
			If lContinua .And. !lValidSQL
				lValidSQL := .T.
				If !(lContinua := TcSQLExec( cQuery ) == 0)
					Alert("Problemas encontrados na Constru็ใo da Consulta aos Dados de Integra็ใo! Verifique a configura็ใo de Integra็ใo!")
				EndIf			
			EndIf			
			If lContinua
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				aEval(AMJ->(DbStruct()), {|x| Iif(x[2] <> 'C' .And. FieldPos(x[1]) > 0, TcSetField(cAliasQry,x[1],x[2],x[3],x[4]),Nil)})
			EndIf	
			aEval(aNiveis,{|x| x[3] := ""})
			
			Do While lContinua .And. (cAliasQry)->(!Eof())
			                        
				lGrava := .T.
				//-- Se existir filtro ADVPL deverแ posicionar registros da AMJ / Join
				//-- para o correto funcionamento do Filtro
				If lContinua .And. (!Empty(cFiltAMD) .Or. !Empty(cFiltAux) .Or. !Empty(cFiltOri))
					AMJ->(DbGoto((cAliasQry)->REC_AMJ))
					If !Empty(cJoin)
						(AKB->AKB_ENTIDA)->(DbGoto((cAliasQry)->REC_ORIG))
					EndIf

					//-- Se houver necessidade de execu็ใo de filtro definido pelo usuแrio, deverแ ser executado em bloco de execu็ใo para que nใo
					//--    provoque ERROR.LOG
					bError := ErrorBlock({|| lContinua := .F.})
					Begin Sequence
						lGrava := lGrava .And. (Empty(cFiltAMD) .Or. AMJ->(&(cFiltAMD)))
						lGrava := lGrava .And. (Empty(cFiltAux) .Or. AMJ->(&(cFiltAux)))
						lGrava := lGrava .And. (Empty(cFiltOri) .Or. (AKB->AKB_ENTIDA)->(&(cFiltOri)))
					End Sequence
					ErrorBlock(bError)

               If !lContinua
						Alert("Problemas encontrados na Aplica็ใo do Filtro! Verifique a configura็ใo de Integra็ใo!")
               EndIf
				EndIf
				
				//-- Se for utilizada a op็ใo para cria็ใo da estrutura, posiciona AM2, criando, se necessแrio
				If lGrava .And. lBuildAM2

					For nJ := Len(aNiveis) To 1 Step -1

						If nJ== Len(aNiveis)
							cIdPai := Space( Len(AM2->AM2_ID))
						Else
							cIdPai := aNiveis[nJ+1][3]
						EndIf
						
						If aNiveis[nJ][3] != (cAliasQry)->&("NIVEL"+aNiveis[nJ][1])

							AM2->(DbSetOrder(5)) //-- AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_IDPAI+AM2_AGREG+AM2_ID
							If AM2->(!DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+AM1->AM1_CODIGO+cIdPai+(cAliasQry)->&("NIVEL"+aNiveis[nJ][1])))

							   //-- Posiciona no Pai para a cria็ใo como Filho
								If !Empty(cIdPai)
									AM2->(DbSetOrder(3)) //-- AM2_FILIAL+AM2_PLANEJ+AM2_VERSAO+AM2_TIPOPL+AM2_ID+AM2_IDPAI
									lContinua := AM2->(DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+AM1->AM1_CODIGO+cIdPai ))
								EndIf
								
								//-- Inclui AM2 no nํvel, deixando posicionado
								If lContinua
									Pco490Ent(aNiveis[nJ][2],,,,Empty(cIdPai),{(cAliasQry)->&("NIVEL"+aNiveis[nJ][1]),(cAliasQry)->&("NIVEL"+aNiveis[nJ][1])}/*aAuto*/)
								Else
									Alert("Problemas encontrados na Constru็ใo da Estrutura do Planejamento! Verifique a configura็ใo de Integra็ใo e os parโmetros de Importa็ใo.")
									Exit
								EndIf
								
							EndIf
							
							aNiveis[nJ][3] := AM2->AM2_ID
							
						EndIf
						
					Next nJ
					
				EndIf
				
				If lContinua .And. lGrava
					//-- ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR + DATAPLNJ + DATAFINA
					cChvTrb := AM2->(AM2_AGREG+AM2_ID)
					//-- CO
					If "AMJ_CO" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_CO
					Else
						cChvTrb += Space(Len(AMJ->AMJ_CO))
					EndIf
					//-- CLASSE
					If "AMJ_CLASSE" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_CLASSE
					Else
						cChvTrb += Space(Len(AMJ->AMJ_CLASSE))
					EndIf
					//-- OPER
					If "AMJ_OPER" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_OPER
					Else
						cChvTrb += Space(Len(AMJ->AMJ_OPER))
					EndIf
					//-- CC
					If "AMJ_CC" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_CC
					Else
						cChvTrb += Space(Len(AMJ->AMJ_CC))
					EndIf
					//-- ITCTB
					If "AMJ_ITCTB" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_ITCTB
					Else
						cChvTrb += Space(Len(AMJ->AMJ_ITCTB))
					EndIf
					//-- CLVLR
					If "AMJ_CLVLR" $ cSelect
						cChvTrb += (cAliasQry)->AMJ_CLVLR
					Else
						cChvTrb += Space(Len(AMJ->AMJ_CLVLR))
					EndIf
					cChvTrb += aDataPlnj[nI][1]
					cChvTrb += aDataPlnj[nI][2]

					If TR1->(DbSeek(cChvTrb))
						RecLock("TR1",.F.)
					Else
						RecLock("TR1",.T.)
						TR1->ALX_AGREG		:= AM2->AM2_AGREG
						TR1->ALX_AM2ID		:= AM2->AM2_ID
						If "AMJ_CO" $ cSelect
							TR1->ALX_CO			:= (cAliasQry)->AMJ_CO
						EndIf
						If "AMJ_CLASSE" $ cSelect
							TR1->ALX_CLASSE	:= (cAliasQry)->AMJ_CLASSE
						EndIf
						If "AMJ_OPER" $ cSelect
							TR1->ALX_OPER		:= (cAliasQry)->AMJ_OPER
						EndIf
						If "AMJ_CC" $ cSelect
							TR1->ALX_CC			:= (cAliasQry)->AMJ_CC
						EndIf
						If "AMJ_ITCTB" $ cSelect
							TR1->ALX_ITCTB		:= (cAliasQry)->AMJ_ITCTB
						EndIf
						If "AMJ_CLVLR" $ cSelect
							TR1->ALX_CLVLR		:= (cAliasQry)->AMJ_CLVLR
						EndIf

	               TR1->DATAPLNJ := aDataPlnj[nI][1]
	               TR1->DATAFINA := aDataPlnj[nI][2]
					EndIf
               TR1->ALY_VALOR += (cAliasQry)->AMJ_VALOR1
               MsUnLock()
               
               If TR1->ALY_VALOR  < 0
						Alert("Nใo ้ permitido valores negativos no Planejamento! Verifique a configura็ใo de Integra็ใo e os parโmetros de Importa็ใo.")
               	lContinua := .F.
               EndIf

				EndIf  
				(cAliasQry)->(DbSkip())
			EndDo

			//-- A constru็ใo da query ้ condicional, portanto eh necessario testar se ela foi construida
			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf
			//-- Caso tenha encontrado algum problema, sai do laco 
			If !lContinua
				Exit
			EndIf
		Next nI

	EndIf		
	AMD->(DbSkip())
EndDo	

//-- Restaura areas para grava็ใo
aEval(aAreas,{|x| RestArea(x) })

//-- Preenche os dados de chave com valor Zero nas Datas sem movimenta็ใo
If lContinua
	ProcRegua(TR1->(RecCount()))
	//-- Ordem do TR1: ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR + DATAPLNJ + DATAFINA
	TR1->(DbGoTop())
	nTo := Len(aDataPlnj)
	cChvTrb := ""
	Do While lContinua .And. TR1->(!Eof())
		IncProc("Formatando Informa็๕es...")
		If cChvTrb != TR1->(ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR)
			cChvTrb := TR1->(ALX_AGREG + ALX_AM2ID + ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_ITCTB + ALX_CLVLR)
			nJ := TR1->(Recno())
			For nI := 1 To nTo
				If TR1->(!DbSeek(cChvTrb+aDataPlnj[nI][1]+aDataPlnj[nI][2]))
					cBloco := TR1->(PCOSQLSvK(AllTrim( TR1->(IndexKey()) ),, cChvTrb+aDataPlnj[nI][1]+aDataPlnj[nI][2]))
					cBloco := StrTran(cBloco,"AND",",")
					cBloco := StrTran(cBloco,"=",":=")
					cBloco := &("{ || " + cBloco+ ",.T.}")
					RecLock("TR1",.T.)
					lContinua := Eval(cBloco)
					TR1->(MsUnLock())
				EndIf
			Next nI
			TR1->(DbGoto(nJ))
		EndIf
		TR1->(DbSkip())
	EndDo
EndIf
	
//-- Se processo foi OK, grava dados no planejamento
If lContinua
	ProcRegua(2)
	IncProc("Gravando Informa็๕es...")
	Begin Transaction
		TR1->(DbGoTop())
		PcoGrvPlan(cId/*cId*/,"TR1",AM1->AM1_CODIGO/*cTipoVar*/,.F./*lQtd*/,"#"/*cFiltroALX*/,/*cTipoForm*/,/*cFormRegr*/,)
	End Transaction
	IncProc("Gravando Informa็๕es...")
EndIf


If !Empty(cTrab)
	TR1->(DbCloseArea())
	TCDelFile(cTrab)
EndIf		

_cVarPnj := cVarPnj


aEval(aAreas,{|x| RestArea(x) })

oPlanej:RefreshTre("001") //Atualiza o Tree

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSQLJoinบAutor  ณ Daniel Leme        บ Data ณ  08/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna uma sequencia de igualdade para relacionamento     บฑฑ
ฑฑบ          ณ (join) numa query entre um campo chave e o alias e indice  บฑฑ
ฑฑบ          ณ que compoe este campo chave (ex: AKD_CHAVE, AMJ_CHAVE      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSQLJoin( cAlias, nIndice, cCpoChave)
Local aArea 	:= GetArea()
Local aAreaAux	:= (cAlias)->(GetArea())
Local cRet 		:= ""
Local cChv		:= ""


//-- Monta a expressใo de campos que comp๕e o อndice
(cAlias)->(DbSetOrder(nIndice))
cChv := AllTrim(Upper( (cAlias)->(IndexKey()) ))

cRet := (cAlias)->(PCOSQLSvK(cChv,cCpoChave))

//-- Complementa com o "D_E_L_E_T_ = ' '"
If !Empty(cRet)

	cRet += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "
	
EndIf

RestArea(aAreaAux)
RestArea(aArea)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOSQLSvK บAutor  ณ Daniel Leme        บ Data ณ  08/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna uma sequencia de igualdade para relacionamento     บฑฑ
ฑฑบ          ณ (join) numa query entre uma combina็ใo de campos e um      บฑฑ
ฑฑบ          ณ campo ou string contendo uma chave concatenada.            บฑฑ
ฑฑบ          ณ Ex:PCOSQLSvK("A2_COD+A2_LOJA",,"00000101")                 บฑฑ
ฑฑบ          ณ    Retorno: A2_COD = '000001' AND A2_LOJA = '01'           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOSQLSvK(cChv,cCpoChave,cStrChave)
Local cRet 		:= ""
Local cStr, nPosRet, cCpo, aSizeCpo, cTipoCpo, nSizeCpo, nI, nPos

Default cStrChave := ""

//-- Extrai Espacos em Branco
While (nPos := AT(" ",cChv) ) > 0   
	cChv := Subs(cChv,1,nPos-1)+Subs(cChv,nPos+1)
End

//-- Retira expressใo "DTOS"
While (nPos := AT("DTOS(",cChv) ) > 0  
	cChv := Subs(cChv,1,nPos-1)+Subs(cChv,nPos+5)
	cStr := ""
	For ni:= nPos to Len(cChv)
		If Subs(cChv,ni,1) == ")"
			Exit
		Else
			cStr += Subs(cChv,ni,1)
		EndIf
	Next
	cChv := Subs(cChv,1,nPos-1)+cStr+Subs(cChv,ni+1)
End

//-- Retira expressใo "STR"
While (nPos := AT("STR(",cChv) )  > 0 
	cChv := Subs(cChv,1,nPos-1)+Subs(cChv,nPos+4)
	cStr := ""
	For ni := nPos to Len(cChv)
		If Subs(cChv,ni,1)$"),"
			Exit
		EndIf
		cStr+= Subs(cChv,ni,1)
	Next
	ni := AT(")",cChv )
	If ni == 0
		Alert("PCOSQLJoin: Error Token")
		cChv := ""
	EndIf
	cChv := Subs(cChv,1,nPos-1)+cStr+Subs(cChv,ni+1)
End

//-- Monta expressใo SQL para igualdade เ Chave
If Empty(cStrChave )
	nPosRet := 4 //-- As Tres primeiras posi็๕es da chave ้ o Alias da Tabela
Else
	nPosRet := 1
EndIf

While !Empty(cChv)

	nPos := AT("+",cChv)
	If nPos ==0
		nPos := Len(AllTrim(cChv)) + 1
	EndIf

	//-- Verifica o tamanho do Campo a ser tratado
	cCpo := Subs(cChv,1,nPos-1)
	
	aSizeCpo := TamSx3(cCpo) // [1] nTamanho [2] nDec [3] cTipo
	cTipoCpo := "U"
	If ValType(aSizeCpo) == "A" .And. Len(aSizeCpo) >= 3

		If aSizeCpo[3] == "D" //-- Data
			nSizeCpo := 8
		ElseIf aSizeCpo[3] == "C" //-- Caracter
			nSizeCpo := aSizeCpo[1]
		Else
			Alert("PCOSQLJoin: Error Type")
			cRet := ""
			Exit
		EndIf

	ElseIf Type(cCpo) != "U"

		cTipoCpo := ValType(&(cCpo))
		If cTipoCpo == "D" //-- Data
			nSizeCpo := 8
		ElseIf cTipoCpo == "C" //-- Caracter
			nSizeCpo := Len( &(cCpo)) 
		Else
			Alert("PCOSQLJoin: Error Type")
			cRet := ""
			Exit
		EndIf
	Else
		Alert("PCOSQLJoin: Error Type")
		cRet := ""
		Exit
	EndIf
	//-- Monta a expressใo SQL igualando a substring ao campo	
	cRet += cCpo + " = "
	If Empty(cStrChave )
		cRet += "SUBSTRING( " + cCpoChave +", "+AllTrim(Str(nPosRet))+", "+AllTrim(Str(nSizeCpo))+") AND "
	Else
		cRet += "'"+ Substr( cStrChave, nPosRet, nSizeCpo) + "' AND "
	EndIf

	//-- Atualiza Variแveis de apoio
	cChv := Subs(cChv,nPos+1)
	nPosRet += nSizeCpo
End

If !Empty(cRet)
	cRet := Left(cRet,Len(cRet)-4) //-- Retira o ๚ltimo "AND"
EndIf

Return cRet

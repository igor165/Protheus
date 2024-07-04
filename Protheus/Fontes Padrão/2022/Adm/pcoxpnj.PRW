#include "protheus.ch"
#include "pcoxpnj.ch"
#include "msmgadd.ch"

#define RATEIO_ALX "011"
#define SALARIOPLJ "009"
#define OUTRASVPLJ "010"
#define PCO_REGBLOQ 3
#define PCO_REGLANC 4
#define PCO_SAVESX8 6

STATIC aRecBlq	:= {}
STATIC aRecLanc	:= {}
STATIC nSaveSX8	:= 0
STATIC aPcoProc	:= {}

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoRunPlan บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08      บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica de funcionalidades do planejamento.                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoRunPlan(ExpC1,ExpC2,ExpN1,ExpO1,ExpC3,ExpA1)                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Id do Item do Planejamento(Tabela AM2).                     บฑฑ
ฑฑบ          ณ Expc2 - Tipo do Planejamento.                                       บฑฑ
ฑฑบ          ณ Expn1 - nOpc para Incluir = 3, Alterar = 4, Deletar = 5             บฑฑ
ฑฑบ          ณ Expo1 - Objeto GetDados a ser Manipulado.                           บฑฑ
ฑฑบ          ณ Expc3 - Condicao SQL a ser executada.                               บฑฑ
ฑฑบ          ณ Expa1 - Vetor para Exec Auto de Parambox.                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static cSeqALY
Static cSrvType
Static cTipoDB
Static lOracle
Static lDB2
Static lInformix
Static lPostgre

Function PcoRunPlan(cId,cTipoPlan,nOpc,oGtDados,cSeek,aAuto,aOutros)

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
			
			PcoDelPnj(cId,cTipoPlan,oGtDados,/*cSeq*/,cSeek)
			
		EndIf
		
	Case nOpc == 4
		
		PcoPnjAtu(cId,nOpc,cTipoPlan,oGtDados) // chamado direto nos fontes de planejamento
		
	Case cTipoPlan == '001'
		
		PcoRecDire(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '002'
		
		PcoRecRela(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '003'
		
		PcoMovRela(cId,nOpc,oGtDados,cSeek,aAuto,aOutros)
		
	Case cTipoPlan == '004'
		
		PcoCusDire(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '005'
		
		PcoDspDire(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '006'
		
		PcoMovNOpe(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '007'
		
		PcoSldInic(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '008'
		
		PcoVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)
		
	Case cTipoPlan == '501'
		
		PcoContPar(cId,nOpc,oGtDados,cSeek,aAuto)
		
EndCase

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoRecDire       บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de receitas diretas do planejamento.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoRecDire(cId,nOpc,oGtDados,cSeek,aAuto)

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

Default cSeek := ''

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0006 , SPACE(6)	,"@S6","ExistCpo('ALS')"	, "ALS", ".T."	,6	,.F.}) //"Regra Rec. Diretas"
	aAdd(aParam,{ 3, STR0007 , 1		,{ STR0008 , STR0009 }	,50		,""	,.F.}) //"Tipo de Valor (Receita)"###"Custo Standard"###"Pre็o Venda"
	aAdd(aParam,{ 1, STR0010 , SPACE(3)	,"@S3","Vazio() .or. ExistCpo('DA0')"	, "DA0", ".T."	,6	,.F.}) //"Tabela de Pre็o"
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_001",,.T.)
	
ElseIf Len(aAuto) == 4 // 3 da parambox + vetor com valores
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrDist 	:= aConfig[1]
	cTipoPrec 	:= ALLTRIM(Str(aConfig[2]))
	cTabePrec 	:= aConfig[3]
	
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	dbSelectArea("AM2")
	dbSetOrder(3)
	dbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan+"001" + cId)
	
	//***************************************
	//      Busca pre็o do produto          *
	//***************************************
	nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"001",cTipoPrec,cTabePrec)
	
	If nPrecAgre == 0
		
		Aviso( STR0001 , STR0012 + ALLTRIM(AM2->AM2_AGREG) + STR0013 ,{ STR0014 }) //"Aten็ใo"###"Agregador: "###" sem valor m้dio/pre็o cadastrado."###"OK"
		lContinua := .F.
		
	EndIf
	
EndIf

If lContinua
	
	//******************************************************
	//      Valida็ใo da rotina de Receita Direta          *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX")  + ALV->ALV_CODIGO + _cVerPlan + cId + "001" + cRegrDist ))
		
		Aviso( STR0001 , STR0015 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	If aAuto = NIL
		
		lContinua := PCOPnjRat(@aValores,"001",AM2->AM2_AGREG,.T.,cRegrDist)
		
	Else
		
		aValores := aAuto[4]
		
	EndIf
	
EndIf

/*
If lContinua
	
	lContinua := !Empty(cTipoCtbl := PCOBuscTp("001"))
	
Endif
*/

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
	PcoGerComb(cRegrDist,/*cEntiExcl*/,aValores,nPrecAgre,.T./*lQtd*/,/*cCodigo*/,"1"/*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)
	
	//****************************
	//   Rotina para Salvar ALX  *
	//****************************
	PcoGrvPLan(cId,oGtDados,"TMPDIS","001",.T.)

	If cTmpArq != NIL
		MsErase(cTmpArq)
	EndIf
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoRecRela       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de receitas relacionadas do planejamento.         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoRecRela(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local cRegrRela
Local cTipoPrec
Local cTabePrec
Local nPrecAgre
Local aEntid,aPrdRelac
Local cIdRelac
Local cFiltroALX := ''

Default cSeek := ''

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0016 ,SPACE(6),"@S6","ExistCpo('ALR')"	, "ALR", ".T."	,6	,.F.}) //"Regra Rec. Relacionadas"
	aAdd(aParam,{ 3, STR0007 ,1,{ STR0008 , STR0009 },50,"",.F.}) //"Tipo de Valor (Receita)"###"Custo Standard"###"Pre็o Venda"
	aAdd(aParam,{ 1, STR0010 ,SPACE(3),"@S3","Vazio() .or. ExistCpo('DA0')","DA0",".T.",6,.F.}) //"Tabela de Pre็o"
	aAdd(aParam,{ 7, STR0017 ,"ALX",""}) //"Filtra Distribui็ใo"
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_002",,.T.)
	
ElseIf Len(aAuto)==4
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrRela 	:= aConfig[1]
	cTipoPrec 	:= ALLTRIM(Str(aConfig[2]))
	cTabePrec 	:= aConfig[3]
	If ! Empty(aConfig[4])
		cFiltroALX 	:= PcoParseFil(aConfig[4],"ALX")
	EndIf
	cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
	
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	dbSelectArea("AM2")
	dbSetOrder(3)
	dbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "001" + cId)
	
	//******************************************************
	//      Valida็ใo da rotina de Receita Relacionada     *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(1)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + "002" + AM2->AM2_AGREG +cRegrRela ))
		
		Aviso( STR0001 , STR0018 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	DbSelectArea("ALN")
	DbSetOrder(1)
	DbSeek(xfilial("ALN") + cRegrRela )
	While ! ALN->(Eof()) .and. ALN->ALN_FILIAL=xFilial("ALN") .and. ALN->ALN_CODIGO == cRegrRela
		
		//***************************************
		//      Busca pre็o do produto          *
		//***************************************
		nPrecAgre := PcoPrcPlan(ALN->ALN_PROIND,"001",cTipoPrec,cTabePrec)
		
		
		If nPrecAgre == 0
			
			Aviso( STR0001 ,STR0019 + ALLTRIM(ALN->ALN_PROIND) + STR0020 ,{ STR0014 }) //"Aten็ใo"###"Produto relacionado: "###"OK"
			
		Else
			
			// Inseri o No para depois gravar AM2_ID
			PcoIncAM2("SB1"+xFilial("SB1")+ALN->ALN_PROIND,"001",.F.,"SB101"+PcoGetAm2(SubStr(oPlanej:GetTre("001"):GetCargo(),4)),.F.)
			
			cIdRelac := AM2->AM2_ID
			
			DbSelectArea("AM2")
			DbSetOrder(3)
			DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + "001" + ALLTRIM(AM2->AM2_IDPAI))
			
			aEntid := { ALN->ALN_CO , ALN->ALN_CLASSE , ALN->ALN_OPER , ALN->ALN_CC , ALN->ALN_ITCTB , ALN->ALN_CLVLR }
			aPrdRelac :={ ALN->ALN_PROIND , nPrecAgre , cIdRelac}
			
			lContinua := PCOGerRelac( cId , aEntid , aPrdRelac , ALN->ALN_RELAC ,, cRegrRela , ALN->ALN_PERIOD , ALN->ALN_NRPERI , cFiltroALX,{'001'})
			
			If lContinua
				//****************************
				//   Rotina para Salvar ALX  *
				//****************************
				
				PcoGrvPLan(nil,oGtDados,"TMPRGR","002",.T.,cFiltroALX)
				
				// Grava e Inclui o No
				DbSelectArea("AM2")
				DbSetOrder(3)
				DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cIdRelac)
				oPlanej:LoadTree(@oPlanej:GetTre("001"),"SB1X",ALN->ALN_PROIND,,2,.F.,,,"'"+AM2->AM2_ID+"'")
			Else
				
				// Deleta o Item da Estrutura pois nใo gerou movimentos
				DbSelectArea("AM2")
				DbSetOrder(3)
				DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cIdRelac)
				RecLock("AM2",.F.)
				DbDelete()
				MsUnlock()
				
			EndIf
			
		EndIf
		
		ALN->(DbSkip())
	End
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovRela       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de movimentos relacionados do planejamento.       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovRela(cId,nOpc,oGtDados,cSeek,aAuto,aOutros)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local cRegrMovi
Local lAplicAll
Local aEntid,aMov

Default cSeek 	:= ''
Default aOutros := {.T.} // Controla se ้ produto principal (.T.) ou relacionado (.F.)

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0021 , SPACE(6)	,"@S6","ExistCpo('AM5')"	, "AM5", ".T."	,40	,.F.}) //"Regra Mov. Relacionados"
	aAdd(aParam,{ 3, STR0022 ,1,{ STR0003 , STR0004 },130,,.F.,(aOutros[1])}) //"Aplicar:"###"Principal"###"Todos"
	aAdd(aParam,{ 7, STR0017 ,"ALX",""}) //"Filtra Distribui็ใo"
	
	If aOutros[1]
		
		lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_003a",,.T.)
		
	Else
		
		lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_003b",,.T.)
		
	EndIf
	
ElseIf Len(aAuto)==3
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrMovi 	:= aConfig[1]
	//	If aOutros[1]
	lAplicAll 	:= (aConfig[2]==2)
	cFiltroALX 	:= PcoParseFil(aConfig[3],"ALX")
	//	Else
	//	    lAplicAll 	:= .F.
	//		cFiltroALX 	:= PcoParseFil(aConfig[2],"ALX")
	//	EndIf
	
	cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	dbSelectArea("AM2")
	dbSetOrder(3)
	dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
	
	//******************************************************
	//      Valida็ใo da rotina de Movimento Relacionado   *
	//******************************************************
	If aAuto==nil // Nใo valida se for Rotina Automatica.
		dbSelectArea("ALX")
		dbSetOrder(3)
		If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + cId + "003" + cRegrMovi ))
			
			Aviso( STR0001 , STR0018 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
			lContinua := .F.
			
		EndIf
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	DbSelectArea("ALP")
	DbSetOrder(1)
	DbSeek(xfilial("ALP") + cRegrMovi )
	While  !ALP->(Eof()) .and. ALP->ALP_FILIAL=xFilial("ALP") .and. ALP->ALP_CODIGO == cRegrMovi
		
		aEntid 		:= { ALP->ALP_CO , ALP->ALP_CLASSE , ALP->ALP_OPER , ALP->ALP_CC , ALP->ALP_ITCTB , ALP->ALP_CLVLR }
		aMov		:= { ALP->ALP_TIPO , ALP->ALP_VALUN, If(lAplicAll,nil,cId) }
		lContinua 	:= PCOGerRelac( If(lAplicAll,nil,cId) , aEntid , aMov ,, ALP->ALP_PERC , cRegrMovi , ALP->ALP_NRPERI ,, cFiltroALX, { '001' , '002' })
		
		If lContinua
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			
			PcoGrvPLan(cId,oGtDados,"TMPRGR","003", (ALP->ALP_PERC==0),If(aOutros[1] .and. !lAplicAll,cFiltroALX + " AND ALX_TIPOPL='001'",cFiltroALX) )
			
		EndIf
		
		ALP->(DbSkip())
	End
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoCusDire       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de Custo direto do planejamento.                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoCusDire(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local _nX
Local lGeraCust
Local nPrecAgre
Local aCustRela
Local cTipoDe,cTipoAte,cFiltroALX,cTipoValo

Default cSeek := ''

If aAuto == NIL
	
	aAdd(aParam,{ 3, STR0023 ,1,{ STR0024 , STR0025 },50,"",.F.}) //"Gera custo da"###"Estrutura"###"Produto"
	aAdd(aParam,{ 1, STR0026 ,SPACE(2),"@S2","","02 ",".T.",6,.F.}) //"De Tipo "
	aAdd(aParam,{ 1, STR0027 ,SPACE(2),"@S2","","02 ",".T.",6,.F.})//"At้ Tipo "
	
	dbSelectArea("ALX")
	aAdd(aParam,{ 7, STR0028 ,"ALX",""}) //"Filtro de Movimentos"
	aAdd(aParam,{ 3, STR0029 ,1,{ STR0008 , STR0030 , STR0031 },50,"",.F.}) //"Tipo de Valor (Custo)"###"Custo Standard"###"U.Pr.Compra"###"Custo M้dio"###"Custo M้dio"
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_004",,.T.)
	
ElseIf Len(aAuto)==5
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	lEstrutur 	:= aConfig[1]==1
	cTipoDe 	:= aConfig[2]
	cTipoAte 	:= aConfig[3]
	If aAuto==nil
		
		cFiltroALX 	:= PcoParseFil(aConfig[4],"ALX")
		cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
		
	Else
		
		cFiltroALX 	:= aConfig[4]
		cFiltroALX 	+= If(!Empty(cSeek) .and. !Empty(cFiltroALX)," AND ", '' ) + cSeek
		
	EndIf
	cTipoValo	:= ALLTRIM(Str(aConfig[5]))
	
	//************************************************************
	//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
	//*  para grava็ใo nใo atualiza os dados.                    *
	//************************************************************
	If cId<>nil .and. Empty(cSeek)
		
		dbSelectArea("AM2")
		dbSetOrder(3)
		dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		
		//******************************************************
		//   Valida็ใo da rotina de custo relacionado pelo ID  *
		//******************************************************
		dbSelectArea("ALX")
		dbSetOrder(3)
		If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + cId + "004"))
			
			Aviso( STR0001 , STR0032 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada para Este produto"###"Ok"
			lContinua := .F.
			
		EndIf
		
	ElseIf cId<>nil
		
		//*****************************************************************
		//  Valida็ใo da rotina de Receita Direta pelo Produto Agregador  *
		//*****************************************************************
		
		dbSelectArea("AM2")
		dbSetOrder(3)
		dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		
		dbSelectArea("ALX")
		dbSetOrder(1)
		If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + "004" + AM2->AM2_AGREG))
			
			Aviso( STR0001 , STR0033 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada para este agregador."###"Ok"
			lContinua := .F.
			
		EndIf
		
	Else
		
		//******************************************************
		//  Valida็ใo da rotina de Receita Direta pelo TipoPl  *
		//******************************************************
		
		dbSelectArea("ALX")
		dbSetOrder(1)
		If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + "004" ))
			
			Aviso( STR0001 , STR0034 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada para este planejamento"###"Ok"
			lContinua := .F.
			
		EndIf
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	If cId <> NIL .and. Empty(cSeek)
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"004", cTipoValo )
		If lEstrutur
			PcoExpPro(LEFT(AM2->AM2_AGREG,30),aConfig,aCustRela,AM2->AM2_ID)// Revisar
		Else
			aCustRela := {{AM2->AM2_AGREG,1,nPrecAgre,cId}}
		EndIf
		
	ElseIf cId <> NIL .and. ! Empty(cSeek) // Gera Todos os Custos para o item principal ponterado
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"+cId)
		aCustRela := {}
		While !AM2->(Eof()) .and. AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL=xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"
			
			If ALLTRIM(AM2->AM2_IDPAI) == cId .or. ALLTRIM(AM2->AM2_ID) == cId
				
				DbSelectArea("AM2")
				nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"004", cTipoValo )
				If lEstrutur
					PcoExpPro(LEFT(AM2->AM2_AGREG,30),aConfig,aCustRela,AM2->AM2_ID)// Revisar
				Else
					aAdd( aCustRela , {AM2->AM2_AGREG,1,nPrecAgre,AM2->AM2_ID} )
				EndIf
				
			EndIf
			AM2->(DbSkip())
			
		End
		
	Else // Gera Todos os Custos do Planejamento
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001")
		aCustRela := {}
		While !AM2->(Eof()) .and. AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL+AM2->AM2_AGREG=xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"
			
			DbSelectArea("AM2")
			nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"004", cTipoValo )
			aAdd( aCustRela , {AM2->AM2_AGREG,1,nPrecAgre,AM2->AM2_ID} )
			
			AM2->(DbSkip())
			
		End
		
	EndIf
	
	
	lGeraCust := .T.
	For _nX := 1 to Len(aCustRela)
		
		If aCustRela[_nX,3] == 0
			
			//			If Empty(cFiltroALX)
			
			lContinua	:= (Aviso( STR0001 , STR0035 + AllTrim(aCustRela[_nX,1]) + STR0036 ,{ STR0014 , STR0005 })==1) //"Aten็ao"###"Produto "###" sem valor de custo! Nใo serแ gerado custo para este produto."###"Ok"###"Cancelar"
			
			//				If !lContinua
			
			//					Exit
			
			//				EndIf
			
			//			EndIf
			
		EndIf
		
	Next
	
EndIf

If lContinua
	
	For _nX := 1 to Len(aCustRela)
		
		If aCustRela[_nX,3] > 0
			
			lContinua := PcoGerContr(aCustRela[_nX,4],aCustRela[_nX],"1","001#002",cFiltroALX, "1" )
			If lContinua
				
				//****************************
				//   Rotina para Salvar ALX  *
				//****************************
				PcoGrvPLan(cId,oGtDados,"TMPRGR","004", .T. , cFiltroALX )
				
			EndIf
			
		EndIf
		
	Next
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoDspDire       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de despesas diretas do planejamento.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoDspDire(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local aBakVal,aValores
Local cRegrDist
Local cTabePrec,cTipoValo
Local nPrecAgre
Local cFormRegr := ""
Local cTipoForm := ""
Local cTmpArq

Default cSeek := ''

//************************************************************
//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
//*  para grava็ใo nใo atualiza os dados.                    *
//************************************************************
dbSelectArea("AM2")
dbSetOrder(3)
dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"005"+cId)

//***********************************************************************
//    Rotina para defini็ใo do tipo de valor, tabela de pre็o e f๓rmula *
//***********************************************************************
dbSelectARea("ALT")
dbSetOrder(1)
If ALT->(dbSeek(xfilial("ALT") + AM2->AM2_AGREG))
	cTipoValo := ALT->ALT_TPVLR
	cFormRegr := ALT->ALT_FORMUL
	cTipoForm := ALT->ALT_TPFORM
	
	// Verrifica se ja tem regra padrao
	If !Empty(ALT->ALT_REGPAD)

		aAuto := {ALT->ALT_REGPAD}

	EndIf

EndIf

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0037 , SPACE(6)	,"@S6","ExistCpo('ALS')"	, "ALS", ".T."	,6	,.F.}) //"Regra Desp. Indiretas"
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_005",,.T.)
	
ElseIf Len(aAuto)==1
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrDist 	:= aConfig[1]
	
	//***************************************
	//      Busca pre็o do produto          *
	//***************************************
	nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"005",,cTabePrec)
	
	If nPrecAgre == 0 .AND. cTipoValo='1' // Somente se for controle por quantidade
		
		Aviso( STR0001 , STR0012 + ALLTRIM(AM2->AM2_AGREG) + STR0038 ,{ STR0014 }) //"Aten็ใo"###"Agregador: "###" sem valor cadastrado."###"OK"
		lContinua := .F.
		
	EndIf
	
EndIf

If lContinua
	
	//******************************************************
	//      Valida็ใo da rotina de despesa indireta        *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + cId + "005" + cRegrDist ))
		
		Aviso( STR0001 , STR0039 ,{ STR0014 }) //"Aten็ใo!"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	lContinua := PCOPnjRat(@aValores,"005",AM2->AM2_AGREG,.T.,cRegrDist)
	
EndIf

/*
If lContinua
	
	lContinua := !Empty(cTipoCtbl := PCOBuscTp("005"))
	
Endif
*/

If lContinua
	
	//******************************************
	//* Ajusta aValores com Data de e Data ate *
	//******************************************
	aBakVal 	:= aValores
	aValores 	:= {}
	aEval(aBakVal,{|x,y| aAdd(aValores,{x , aDataPlnj[y,1] , aDataPlnj[y,2] }) })
	
	//*********************************************************************
	//    Gera combina็ใo das entidades conforme regra de distribui็ใo    *
	//*********************************************************************
	PcoGerComb(cRegrDist,/*cEntiExcl*/,aValores	,nPrecAgre,cTipoValo=='1'/*lQtd*/,/*cCodigo*/,"1" /*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)
			
	//****************************
	//   Rotina para Salvar ALX  *
	//****************************
	
	PcoGrvPLan(cId,oGtDados,"TMPDIS","005",cTipoValo=='1',,,cTipoForm,cFormRegr)
	
	If cTmpArq != NIL
		MsErase(cTmpArq)
	EndIf
	
EndIf

return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoMovNOpe       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de Movimentos nใo operacionais do planejamento.   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoMovNOpe(cId,nOpc,oGtDados,cSeek,aAuto)

Local aParam 	:= {}
Local aConfig	:= {}

Local lContinua := .F.
Local cParamTxt := STR0011 //"Distribui็ใo do Planejamento"
Local aBakVal,aValores
Local cRegrDist
Local cTabePrec,cTipoValo
Local nPrecAgre
Local cTmpArq
Local cTipoForm := ""
Local cFormRegr	:= ""

Default cSeek := ''

//************************************************************
//*  Se o agregador nใo possui pre็o m้dio ou valor unitแrio *
//*  para grava็ใo nใo atualiza os dados.                    *
//************************************************************

dbSelectArea("AM2")
dbSetOrder(3)
dbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"006"+cId)

//***********************************************************************
//    Rotina para defini็ใo do tipo de valor, tabela de pre็o e f๓rmula *
//***********************************************************************
dbSelectARea("AM4")
dbSetOrder(1)
If AM4->(dbSeek(xfilial("AM4") + AM2->AM2_AGREG))
	cTipoValo := AM4->AM4_TPVLR
	cTipoForm := AM4->AM4_TPFORM
	cFormRegr := AM4->AM4_FORMUL

	// Verrifica se ja tem regra padrao
	If !Empty(AM4->AM4_REGPAD)

		aAuto := {AM4->AM4_REGPAD}

	EndIf

EndIf

If aAuto == NIL
	
	aAdd(aParam,{ 1, STR0040 , SPACE(6)	,"@S6","ExistCpo('ALS')"	, "ALS", ".T."	,6	,.F.}) //"Regra Mov. Nใo Operac."
	
	lContinua := ParamBox(aParam,cParamTxt,@aConfig,,,,,,,"PCOA490_006",,.T.)
	
ElseIf Len(aAuto)==1
	
	aConfig := aclone(aAuto)
	lContinua := .T.
	
EndIf

If lContinua
	
	cRegrDist 	:= aConfig[1]
	
	//***************************************
	//      Busca pre็o do produto          *
	//***************************************
	nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"006",,cTabePrec)
	
	If nPrecAgre == 0 .AND. cTipoValo=='1' // Somente se for controle por quantidade
		
		Aviso( STR0001 , STR0012 + ALLTRIM(AM2->AM2_AGREG) + STR0038 ,{ STR0014 }) //"Aten็ใo"###"Agregador: "###" sem valor cadastrado."###"OK"
		lContinua := .F.
		
	EndIf
	
EndIf

If lContinua
	
	//******************************************************
	//      Valida็ใo da rotina de movimento nใo operacional *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(3)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + cId + Space(3) + "006" + cRegrDist ))
		
		Aviso( STR0001 , STR0018 ,{ STR0014 }) //"Aten็ใo"###"Distribui็ใo de dados jแ efetuada"###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

If lContinua
	
	lContinua := PCOPnjRat(@aValores,"006",AM2->AM2_AGREG,.T.,cRegrDist)
	
EndIf
/*
If lContinua
	
	lContinua := !Empty(cTipoCtbl := PCOBuscTp("006",AM2->AM2_AGREG))
	
Endif
*/

If lContinua
	//******************************************
	//* Ajusta aValores com Data de e Data ate *
	//******************************************
	aBakVal 	:= aValores
	aValores 	:= {}
	aEval(aBakVal,{|x,y| aAdd(aValores,{x , aDataPlnj[y,1] , aDataPlnj[y,2] }) })
	
	//*********************************************************************
	//    Gera combina็ใo das entidades conforme regra de distribui็ใo    *
	//*********************************************************************
	PcoGerComb(cRegrDist,/*cEntiExcl*/,aValores,nPrecAgre,cTipoValo=='1'/*lQtd*/,/*cCodigo*/,"1" /*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)
	
	//****************************
	//   Rotina para Salvar ALX  *
	//****************************
	PcoGrvPLan(cId,oGtDados,"TMPDIS","006",cTipoValo=='1',,,cTipoForm,cFormRegr)

	If cTmpArq != NIL
		MsErase(cTmpArq)
	EndIf
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoSldInic       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de Saldos Iniciais de C.O. do Planejamento.       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoSldInic(cId,nOpc,oGtDados,cSeek,aAuto)

PnjSldInic(cId,nOpc,oGtDados,cSeek,aAuto) // Fun็ใo movida para PCOA495

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoVarPatr       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de varia็ใo patrimonial do planejamento.          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)

PnjVarPatr(cId,nOpc,oGtDados,cSeek,aAuto)

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoContPar       บAutorณJoใo Gon็alves             บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina de geracao de contra partida do planejamento.                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoContPar(cId,nOpc,oGtDados,cSeek,aAuto)

Local lContinua := .T.
Local aId
Local cFiltroALX
Local nX

Default cSeek := ''

If lContinua
	
	
	cFiltroALX 	:= cSeek
	
	//******************************************************
	//   Valida็ใo da rotina de Receita Direta pelo cId    *
	//******************************************************
	dbSelectArea("ALX")
	dbSetOrder(1)
	If ALX->(dbSeek(xfilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + "501" ))
		
		Aviso( STR0001 , STR0043 ,{ STR0014 }) //"Aten็ใo"###"Jแ existem lan็amentos de Contra partida para este planejamento."###"Ok"
		lContinua := .F.
		
	EndIf
	
	// Criar Ponto de Entrada para validar ACACIO
	
EndIf

aId := {}

If lContinua
	
	DbSelectArea("AM2")
	DbSetOrder(3)
	DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001")
	
	While !AM2->(Eof()) .and. AM2->AM2_FILIAL+AM2->AM2_PLANEJ+AM2->AM2_VERSAO+AM2->AM2_TIPOPL=xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+"001"
		
		If ALLTRIM(AM2->AM2_IDPAI)<>''
			
			aAdd(aId,{AM2->AM2_ID , AM2->AM2_AGREG })
			
		Else
			
			aAdd(aId,{AM2->AM2_ID , '' })
			
		EndIf
		AM2->(DbSkip())
		
	End
	
EndIf


If lContinua
	
	For nX := 1 To Len(aId)
		
		//*************************************
		//  Contra Partida de Receita direta  *
		//*************************************
		lContinua := PcoGerContr(aId[nX,1],{aId[nX,2],1,'SUM(ALY_VALOR) '},"2","001",cFiltroALX)
		
		If lContinua
			
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			PcoGrvPLan(aId[nX,1],oGtDados,"TMPRGR","501", .T. , cFiltroALX )
			
		EndIf
		
		//******************************************
		//  Contra Partida de Receita relacionada  *
		//******************************************
		lContinua := PcoGerContr(aId[nX,1],{aId[nX,2],1,'SUM(ALY_VALOR) '},"2","002",cFiltroALX)
		
		If lContinua
			
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			PcoGrvPLan(aId[nX,1],oGtDados,"TMPRGR","502", .T. , cFiltroALX ,.F.)
			
		EndIf
		
		//*******************************************
		//  Contra Partida de Movimento Relacionado *
		//*******************************************
		lContinua := PcoGerContr(aId[nX,1],{aId[nX,2],1,'SUM(ALY_VALOR) '},"2","003",cFiltroALX)
		
		If lContinua
			
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			PcoGrvPLan(aId[nX,1],oGtDados,"TMPRGR","503", .T. , cFiltroALX ,.F.)
			
		EndIf
		
		//*************************************
		//  Contra Partida de Custo Direto    *
		//*************************************
		lContinua := PcoGerContr(aId[nX,1],{aId[nX,2],1,'SUM(ALY_VALOR) '},"2","004",cFiltroALX)
		
		If lContinua
			
			//****************************
			//   Rotina para Salvar ALX  *
			//****************************
			PcoGrvPLan(aId[nX,1],oGtDados,"TMPRGR","504", .T. , cFiltroALX ,.F.)
			
		EndIf
		
	Next
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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

Static Function PcoGerComb(cRegrDist,cEntiExcl,aValor,nPrecAgre,lQtd,cCodigo,cTipo,cRegrFilt,cTmpArq)
Local cQryCpos
Local cQryPerc
Local cQryJoin
Local cQryValor
Local _nX
Local lVlr2			:= .F.
Local aCpos
Local cGrade		:= ""
Local cCampFilt

Default cEntiExcl	:= '#'
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
cQryCpos += "'"		+ cRegrDist			+ "' ALX_REGRA "
cQryCpos += ", '"	+ AM2->AM2_AGREG 	+ "' ALX_AGREG "
cQryCpos += ", '"	+ AM2->AM2_ID		+ "' ALX_AM2ID "
cQryCpos += ", '"	+ cCodigo 			+ "' ALX_CODIGO "
cQryCpos += ", '"	+ cTipo 			+ "' ALX_TIPO "
cQryCpos += ", DATAPLNJ "
cQryCpos += ", DATAFINA "

cQryPerc := ""
cQryJoin := ""
aCpos := {	{"AK5","ALX_CO"		},;
			{"AK6","ALX_CLASSE"	},;
			{"AKF","ALX_OPER"	},;
			{"CTT","ALX_CC"		},;
			{"CTD","ALX_ITCTB"	},;
			{"CTH","ALX_CLVLR"	}}

For _nX := 1 To Len(aCpos)

	// Adiciona campos a Select
	If aCpos[_nX,1] $ cEntiExcl

		cQryCpos += ", '' " + aCpos[_nX,2]

	Else

		If lInformix
			If cGrade$"23"
				cQryCpos += ", NVL(" + StrTran(aCpos[_nX,2], "ALX_", "ALO_") + ",' ') " + aCpos[_nX,2]
			Else
				cQryCpos += ", NVL(ALU"+StrZero(_nX,1)+".ALU_ENTIDA"+ ",' ') " + aCpos[_nX,2]
			EndIf
		ElseIf lOracle
			cQryCpos += ", NVL(" + aCpos[_nX,1] + ",' ') " + aCpos[_nX,2]
		ElseIf  lDB2 .Or. lPostgre 
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
		ElseIf  lDB2 .Or. lPostgre 
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

		cQryValor 	+= ", " + AllTrim(Str(	aValor[_Nx,4])) 	+ " VALOR2 "

		lVlr2 		:= .T.

	EndIf
	If lInformix
		cQryValor += "  FROM "+RetSqlName("AL2")+" AL2  "
		cQryValor += "  WHERE R_E_C_N_O_ IN "
		cQryValor += "  (SELECT MAX(R_E_C_N_O_) FROM "+RetSqlName("AL2")+" )  "
	Else	
        If lOracle .Or. lDB2 .Or. lPostgre	
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

		cQuery += ", VALOR " + cQryPerc + " ALY_VALOR "

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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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
/*
cTipoCtbl := PCOBuscTp(aTipoPl[1],IIf(aTipoPl[1]$"003,008",aItemRelac[1],""))
*/
// Monta Transforma aTipoPl em cTipoPl para ser usado na query
For _nX := 1 To Len(aTipoPl)
	
	cTipoPl += "'" + aTipoPl[_nX] + "'" + If(_nX+1 <= Len(aTipoPl) , "," , "" )
	
Next
/*
cTipoCtbl := PCOBuscTp(aTipoPl[1],IIf(cTipoPl$"003,008",aItemRelac[1],""))
*/
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
cQuery += "AND ALX_TIPOPL IN (" + cTipoPl + ")  )"

If ! Empty(cFiltroALX)
	
	cQuery += "AND (" + cFiltroALX + ") "
	
EndIf

cQuery += "GROUP BY ALX_AGREG,ALX_AM2ID,ALX_CODIGO,ALX_TIPO,ALX_REGRA,ALX_CO,ALX_CLASSE,ALX_OPER,ALX_CC,ALX_ITCTB,ALX_CLVLR,ALY_DTINI,ALY_DTFIM "
cQuery += "ORDER BY 2, 8, 9, 10, 11, 12, 13, 16, 17"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPRGR", .T., .T. )

If TMPRGR->(Eof())
	lRet := .F.
	DbCloseArea()
EndIf

Return lRet

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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
Static Function PCOGerContr(cId,aPrd,cTipoAM8,cTpPlans,cSeek,cTipo)

Local cQuery
Local lRet			:= .T.

Default cTipoAM8	:= "1"

PcoIni_VarStatic()

//****************************************
//   Monta Query para Contra partida     *
//****************************************
If lInformix
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + aPrd[1] + "' ALX_CODIGO,NVL(AM8.AM8_ID,' ') ALX_REGRA, "
ElseIf  lOracle
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + aPrd[1] + "' ALX_CODIGO,NVL(AM9.AM8_ID,' ') ALX_REGRA, "
ElseIf lDB2 .Or. lPostgre  
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + aPrd[1] + "' ALX_CODIGO,COALESCE(AM9.AM8_ID,' ') ALX_REGRA, "
Else
	cQuery := "SELECT ALX.ALX_AGREG,ALX_AM2ID,'" + aPrd[1] + "' ALX_CODIGO,ISNULL(AM9.AM8_ID,' ') ALX_REGRA, "
EndIf

If cTipo<>nil

	cQuery += "'" + cTipo + "' ALX_TIPO,"

Else

	cQuery += "CASE WHEN (ALX.ALX_TIPO='1') THEN '2' ELSE '1' END ALX_TIPO,"

EndIf
//CO
cQuery += "CASE WHEN (AM9.AM9_CO='') THEN ALX.ALX_CO ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
ElseIf  lDB2 .Or. lPostgre 
	cQuery += "COALESCE(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
Else
	cQuery += "ISNULL(AM9.AM9_CO,ALX.ALX_CO) END ALX_CO,"
EndIf
//CLASSE
cQuery += "CASE WHEN (AM9.AM9_CLASSE='') THEN ALX.ALX_CLASSE ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
ElseIf  lDB2 .Or. lPostgre 
	cQuery += "COALESCE(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
Else
	cQuery += "ISNULL(AM9.AM9_CLASSE,ALX.ALX_CLASSE) END ALX_CLASSE,"
EndIf
//OPERACAO
cQuery += "CASE WHEN (AM9.AM9_OPER='') THEN ALX.ALX_OPER ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += "COALESCE(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
Else
	cQuery += "ISNULL(AM9.AM9_OPER,ALX.ALX_OPER) END ALX_OPER,"
EndIf
//CENTRO DE CUSTO
cQuery += "CASE WHEN (AM9.AM9_CC='') THEN ALX.ALX_CC ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += "COALESCE(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
Else
	cQuery += "ISNULL(AM9.AM9_CC,ALX.ALX_CC) END ALX_CC,"
EndIf
//ITEM CONTABIL
cQuery += "CASE WHEN (AM9.AM9_ITCTB='') THEN ALX.ALX_ITCTB ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += "COALESCE(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
Else
	cQuery += "ISNULL(AM9.AM9_ITCTB,ALX.ALX_ITCTB) END ALX_ITCTB,"
EndIf
//CLASSE DE VALOR
cQuery += "CASE WHEN (AM9.AM9_CLVLR='') THEN ALX.ALX_CLVLR ELSE "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += "COALESCE(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
Else
	cQuery += "ISNULL(AM9.AM9_CLVLR,ALX.ALX_CLVLR) END ALX_CLVLR,"
EndIf
//SOMA DA QUANTIDADE
cQuery += "SUM(ALY.ALY_QUANT * " + Str(aPrd[2]) + ") * "
If lOracle .Or. lInformix
	cQuery += " NVL(AM9.AM9_PERC/100,1) ALY_QUANT,"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += "COALESCE(AM9.AM9_PERC/100,1) ALY_QUANT,"
Else
	cQuery += "ISNULL(AM9.AM9_PERC/100,1) ALY_QUANT,"
EndIf

If VALTYPE(aPrd[3])="N"
	
	cQuery += Str(aPrd[3]) + " ALY_VALOR, "
	
ElseIf VALTYPE(aPrd[3])="C"
	
	cQuery += aPrd[3] + " ALY_VALOR, "
	
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
	cQuery += "      (SELECT AM8_ID, AM8_CO , AM8_CLASSE, AM8_OPER, AM8_CC, AM8_ITCTB, AM8_CLVLR, AM9_CO , AM9_CLASSE, AM9_OPER, AM9_CC, AM9_ITCTB, AM9_CLVLR, AM9_PERC FROM " + RetSqlName("AM8") + " AM8, " + RetSqlName("AM9") + " AM9 WHERE AM8.D_E_L_E_T_=' ' AND AM9.D_E_L_E_T_=' ' AND AM8_FILIAL='01' AND AM9_FILIAL=AM8_FILIAL AND AM9_ID=AM8_ID AND AM8_TIPO='" + cTipoAM8 + "') AM9
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

//cQuery += " '" + cTpPlans + "' LIKE '%'+ALX_TIPOPL+'%' AND "
cQuery +=  " ALX.ALX_TIPOPL IN ( '"+ StrTran(cTpPlans, "#", "' , '") +"') AND "
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoGrvPlan       บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina generica para grava็ใo das tabelas ALX e ALY.                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoGrvPlan(Expc1,Expo2,Expc3,Expc4)                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Id do Item do Planejamento.                                  บฑฑ
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
Function PcoGrvPlan(cId,oGetDados,cAliasTMP,cTipoPlan,lQtd,cFiltroALX,lDelaCols,cTipoForm,cFormRegr,cVlrCheio)

Local cEntiOrca := ""
Local nPosiInic := 0
Local aDataGrav := {}
Local nContItem
Local lAm2Id 	:= TYPE(cAliasTMP + '->ALX_AM2ID')=='C'
Local lTipoPl   := TYPE(cAliasTMP + '->ALX_TIPOPL')=='C'
Local lInc		:= .F.
Local nContPosi
Local cTipoMvto := ""
Local aBakVal	:= {}
Local lALXInc	:= ExistBlock("PCOALXINC")
Local lALYInc	:= ExistBlock("PCOALYINC")

Default cId  		:= "###"
Default lQtd 		:= .T.
Default cFiltroALX	:= ''
Default lDelaCols   := .T.
Default cVlrCheio 	:= "0"

//******************************
// Rotina para Atualizar aCols *
//         Acacio Egas         *
//******************************
If oGetDados<>nil .and. lDelaCols
	If Empty(oGetDados:aCols[1,aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "ALX_SEQ"})])
		oGetDados:aCols := {} // Limpa aCols da GetDados
		aRecno := {}
	EndIf
EndIf

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
	
	If !(cAliasTMP)->(ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_CLVLR + ALX_ITCTB + If(lAm2Id,ALX_AM2ID,'')) == cEntiOrca
		
		If !Empty(cEntiOrca) .and. (cId == ALLTRIM(ALX->ALX_AM2ID) .or. cId == "###") .and. lInc
			DbSelectArea("ALX")
			If oGetDados<>nil
				PcoAtuGtd(@oGetDados)
			EndIf
			lInc := .F.
		EndIf
		
		
		//************************************************
		//ณ    Localiza ALX com a Chave a ser incluida.  *
		//************************************************
		
		If  ( lInc := !PcoChavALX( cAliasTMP , If( lTipoPl , (cAliasTMP)->ALX_TIPOPL , cTipoPlan ) )   )
			cSequAtua := PcoALXSeq()
			
			// Grava dados de distribui็ใo
			ALX->( Reclock("ALX",.T.) )
			ALX->ALX_FILIAL 	:= xfilial("ALX")
			ALX->ALX_PLANEJ 	:= ALV->ALV_CODIGO
			ALX->ALX_VERSAO 	:= _cVerPlan
			ALX->ALX_AGREG	:= (cAliasTMP)->ALX_AGREG
			ALX->ALX_TIPOPL 	:= If( lTipoPl , (cAliasTMP)->ALX_TIPOPL , cTipoPlan )
			ALX->ALX_TIPO 	:= (cAliasTMP)->ALX_TIPO
			
			// Grava Filtro para Reprocessamento
			If !Empty(cFiltroALX)
				ALX->ALX_FILTRO	:= cFiltroALX
			EndIf
			
			ALX->ALX_CODIGO 	:= (cAliasTMP)->ALX_CODIGO
			ALX->ALX_CO     	:= (cAliasTMP)->ALX_CO
			ALX->ALX_CLASSE 	:= (cAliasTMP)->ALX_CLASSE
			ALX->ALX_OPER   	:= (cAliasTMP)->ALX_OPER
			ALX->ALX_CC     	:= (cAliasTMP)->ALX_CC
			ALX->ALX_ITCTB  	:= (cAliasTMP)->ALX_ITCTB
			ALX->ALX_CLVLR  	:= (cAliasTMP)->ALX_CLVLR
			ALX->ALX_REGRA   := (cAliasTMP)->ALX_REGRA
			ALX->ALX_SEQ 	:= cSequAtua
			
			If lAM2Id
				
				ALX->ALX_AM2ID	:= (cAliasTMP)->ALX_AM2ID
				
			Else
				
				ALX->ALX_AM2ID	:= cId
				
			EndIf
			ALX->( MsUnlock() )
			
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
		If ALY->(dbSeek(xfilial("ALY") + ALV->ALV_CODIGO + _cVerPlan + cSequAtua + aDataGrav[nContPosi]))
			
			Reclock("ALY",.F.)
			
			If cVlrCheio == "1"
				
				ALY_QUANT := (cAliasTMP)->ALY_QUANT
				ALY_VALOR := (cAliasTMP)->ALY_VALOR
				
			Else
				If Alltrim(SuperGetMV('MV_PCOPNJ1',.T.,'2'))=='2'
					
					//******************************
					// Controla Resto dos Valores  *
					//******************************
					aBakVal[nContPosi,2] += (cAliasTMP)->ALY_QUANT - Int((cAliasTMP)->ALY_QUANT)
					// Soma oInteiro
					ALY_QUANT  := Int((cAliasTMP)->ALY_QUANT) + ALY->ALY_QUANT
					
					// Verifica Dizimas
					If aBakVal[nContPosi,2] >= 1
						
						ALY_QUANT := Int(aBakVal[nContPosi,2]) + ALY_QUANT // Controla valores lan็ados
						aBakVal[nContPosi,2] := aBakVal[nContPosi,2] - Int(aBakVal[nContPosi,2])
						
					EndIf
					
					If lQtd // Controla Quantidade
						
						ALY_VALOR := (ALY_QUANT*(cAliasTMP)->ALY_VALOR)
						
					Else // Controla Valor
						
						ALY_VALOR := (cAliasTMP)->ALY_VALOR
						
					EndIf
				Else
					
					ALY_QUANT  := Round((cAliasTMP)->ALY_QUANT,0) + ALY->ALY_QUANT
					
					If lQtd // Controla Quantidade
						
						ALY_VALOR := (ALY_QUANT*(cAliasTMP)->ALY_VALOR)
						
					Else // Controla Valor
						
						ALY_VALOR := (cAliasTMP)->ALY_VALOR
						
					EndIf
					
				EndIf
				
			EndIf

			MsUnlock()
			
		//**************************************
		// Tratamento de formula por Periodo   *
		//**************************************

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
	
						ALY_QUANT  	:= nValoForm
						ALY_VALOR 	:= (nValoForm * (cAliasTMP)->ALY_VALOR)
	
					Else
					
						ALY_VALOR := nValoForm
					
					EndIf
	
				MsUnlock()
			
			EndIf
			
		Else
			
			Reclock("ALY",.T.)
			ALY_FILIAL := xfilial("ALY")
			ALY_PLANEJ := ALV->ALV_CODIGO
			ALY_VERSAO := _cVerPlan
			ALY_SEQ    := cSequAtua
			If cVlrCheio == "1"
				
				ALY_QUANT := (cAliasTMP)->ALY_QUANT
				ALY_VALOR := (cAliasTMP)->ALY_VALOR
				
			Else
				
				If Alltrim(SuperGetMV('MV_PCOPNJ1',.T.,'2'))=='2'
					
					//******************************
					// Controla Resto dos Valores  *
					//******************************
					aBakVal[nContPosi,2] += (cAliasTMP)->ALY_QUANT - Int((cAliasTMP)->ALY_QUANT)
					// Soma oInteiro
					ALY_QUANT  := Int((cAliasTMP)->ALY_QUANT)
					// Verifica Dizimas
					If aBakVal[nContPosi,2]>=1
						
						ALY_QUANT := Int(aBakVal[nContPosi,2]) + ALY_QUANT // Controla valores lan็ados
						aBakVal[nContPosi,2] := aBakVal[nContPosi,2] - Int(aBakVal[nContPosi,2])
						
					EndIf
					
					If lQtd // Controla Quantidade
						
						ALY_VALOR := (ALY_QUANT*(cAliasTMP)->ALY_VALOR)
						
					Else // Controla Valor
						
						ALY_VALOR := (cAliasTMP)->ALY_VALOR
						
					EndIf
					
				Else
					
					ALY_QUANT  := Round((cAliasTMP)->ALY_QUANT,0)
					If lQtd // Controla Quantidade
						
						ALY_VALOR := (ALY_QUANT*(cAliasTMP)->ALY_VALOR)
						
					Else // Controla Valor
						
						ALY_VALOR := (cAliasTMP)->ALY_VALOR
						
					EndIf
					
				EndIf
				
			EndIf

			ALY_DTINI  := STOD(aDataPlnj[nContPosi,1])
			ALY_DTFIM  := STOD(aDataPlnj[nContPosi,2])

			MsUnlock()
				
			//**************************************
			// Tratamento de formula por Periodo   *
			//**************************************

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
	
						ALY_QUANT  	:= nValoForm
						ALY_VALOR 	:= (nValoForm * (cAliasTMP)->ALY_VALOR)
	
					Else
					
						ALY_VALOR := nValoForm
					
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
	
	cEntiOrca := (cAliasTMP)->(ALX_CO + ALX_CLASSE + ALX_OPER + ALX_CC + ALX_CLVLR + ALX_ITCTB + If(lAm2Id,ALX_AM2ID,''))
	
	(cAliasTMP)->(dbSkip())
	
End

If (cId == ALLTRIM(ALX->ALX_AM2ID) .or. cId == "###") .and. lInc // Inclui o aCols cas๓ nใo tenha todos todos os Periodos
	
	DbSelectArea("ALX")
	If oGetDados<>nil
		PcoAtuGtd(@oGetDados)
	EndIf
	lInc := .F.
	
EndIf

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

//******************************
// Rotina para Atualizar aCols *
//         Acacio Egas         *
//******************************
If oGetDados<>nil
	If Len(oGetDados:aCols) == 0 // Acacio Egas
		PcoAtuGtd(@oGetDados,.T.)
	EndIf
	oGetDados:Refresh() // Atualiza GetDados
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a gravacao dos lancamentos do SIGAPCO                 ณ
//ณ   Retirar comentario, caso sejแ necessario lan็amento On-Line  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PcoFinLan("000358")

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoFindALX บAutor  ณAcacio Egas        บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza lan็amento no ALX e Preenche GetDados.            บฑฑ
ฑฑบ          ณ Utilizada em todas as rotinas de planejamento.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoFindALX(cId,TipoPlan,oGetDados,cSeek)

cQuery := "SELECT ALX_TIPO, ALX_CODIGO, ALX_CO, ALX_CLASSE, ALX_OPER, ALX_CC, ALX_CLVLR, ALX_ITCTB,ALX_SEQ, ALX_REGRA FROM "
cQuery += RetSqlName("ALX") + " WHERE D_E_L_E_T_  = ' '  AND ALX_FILIAL = '" + xFilial("ALX") + "' AND ALX_PLANEJ = '"
cQuery += ALV->ALV_CODIGO + "' AND ALX_VERSAO = '" + _cVerPlan + "' "

If !Empty(cId)
	
	cQuery += "AND ALX_AM2ID = '" + cId + "' "
	
EndIf

If VALTYPE(TipoPlan)=="C"
	
	cQuery += "AND ALX_TIPOPL = '" + TipoPlan + "' "
	
ElseIf VALTYPE(TipoPlan)=="A"
	
	cTipoPl := ''
	aEval( TipoPlan , {|x,y| cTipoPl += "'" + x + "'" + If( Len(TipoPlan)==y , ") " , "," ) } )
	
	cQuery += "AND ALX_TIPOPL IN ("+cTipoPl
	
	
EndIf


If cSeek <> NIL // Filtro para Nos de entidades no Tree
	
	cQuery += cSeek
	
EndIf

cQuery += "ORDER BY ALX_SEQ"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALX", .T., .T. )
DbSelectArea("TMPALX")
DbGoTop()
If ! Eof()
	
	oGetDados:aCols := {}
	oGetDados:nAt 	:= 1
	
Else
	
	oGetDados:aCols := {}
	PcoAtuGtd(oGetDados)
	
EndIf

While !Eof()
	
	PcoAtuGtd(oGetDados)
	DbSkip()
	
End

oGetDados:Refresh()
TMPALX->(DbCloseArea())

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoLoadALY  บAutor  ณAcacio Egas       บ Data ณ  03/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Carregar ALY e atualizar varriaves da MSMGet   บฑฑ
ฑฑบ          ณ  auto-contida.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoLoadALY(aListDt,oGetDados,oMsmALY,lGrava,nVlUnit)

Local aTituTela 	:= {}
Local aListVeri 	:= {}
Local Nx
Local nPosiValo 	:= 0
Local cSequencia 	:= If(cSeqALY==nil,'',cSeqALY)

Default lGrava		:= .F.
Default nVlUnit		:= 0

If oGetDados<>nil
	
	cSeqALY 	:= oGetDados:aCols[oGetDados:nat,aScan(oGetDados:aHeader,{|x|ALLTRIM(x[2])=="ALX_SEQ"})]
	cSequencia 	:= cSeqALY
	
EndIf

If ! lGrava .and. ! Empty(cSequencia)
	
	If oGetDados<>nil
		
		cSeqALY := oGetDados:aCols[oGetDados:nat,aScan(oGetDados:aHeader,{|x|ALLTRIM(x[2])=="ALX_SEQ"})]
		
	EndIf
	
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
		&('M->VLR' + StrZero(Nx,3)) := 0 // Alterar
		&('M->QTD' + StrZero(Nx,3)) := 0
		
	Next
	
	dbSelectARea("TMPVAL")
	dbGoTop()
	While ! TMPVAL->(Eof())
		
		nPosiValo := aScan(aListVeri,TMPVAL->ALY_DTINI)
		&('M->QTD' + StrZero(nPosiValo,3)) := TMPVAL->ALY_QUANT
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
			ALY_QUANT 	:= &('M->QTD' + StrZero(Nx,3))
			
			If &('M->QTD' + StrZero(Nx,3))>0 .and. nVlUnit>0
				
				ALY_VALOR 	:= (&('M->QTD' + StrZero(Nx,3))*nVlUnit)
				
			Else
				
				ALY_VALOR 	:= &('M->VLR' + StrZero(Nx,3))
				
			EndIf
			
			&('M->VLR' + StrZero(Nx,3)) := ALY_VALOR
			MsUnlock()
			
		Else
			
			RecLock("ALY",.T.)
			ALY_FILIAL 	:= xfilial("ALY")
			ALY_PLANEJ 	:= ALV->ALV_CODIGO
			ALY_VERSAO 	:= _cVerPlan
			ALY_SEQ 	:= cSequencia
			ALY_DTINI 	:= STOD(aListDt[Nx,1])
			ALY_DTFIM 	:= STOD(aListDt[Nx,2])
			ALY_QUANT 	:= &('M->QTD' + StrZero(Nx,3))
			If &('M->QTD' + StrZero(Nx,3))>0 .and. nVlUnit>0
				
				ALY_VALOR := &('M->QTD' + StrZero(Nx,3)) * nVlUnit
				
			Else
				
				ALY_VALOR 	:= &('M->VLR' + StrZero(Nx,3))
				
			EndIf
			&('M->VLR' + StrZero(Nx,3)) := ALY_VALOR
			MsUnlock()
			
		EndIf
		PcoDetLan("000358","01","PCOXPNJ")
	Next
	PcoFinLan("000358")
Else
	
	For Nx := 1 to Len(aListDt)
		
		aAdd(aListVeri,aListDt[Nx,1])
		&('M->VLR' + StrZero(Nx,3)) := 0 // Alterar
		&('M->QTD' + StrZero(Nx,3)) := 0 // Alterar
		
	Next
	If lGrava
		
		Aviso("Aten็ใo","Nใo hแ uma distribui็ใo selecionada",{"Ok"})
		
	EndIf
	
EndIf

oPlanej:GetMsm("002"):EnchRefreshAll()
oPlanej:GetMsm("003"):EnchRefreshAll()

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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
Function PcoALXSeq()

PcoIni_VarStatic()

//inicia o semaforo
While !LockByName(xFilial("ALX")+"PROXSEQ_ALX",.T.,.T.,.T.)
	Sleep(1)
EndDo

If lOracle .Or. lInformix
	cQuery0 := "SELECT NVL(MAX(ALX_SEQ) ,'0') MAX FROM " + RetSqlName("ALX") + " "
ElseIf  lDB2 .Or. lPostgre  
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoDelPnj  บAutor   ณJoใo Gon็alves de Oliveira บ Data ณ 08/02/08       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออฯออออออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Excluir valores de planejamento                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoDelPnj(ExpC1,ExpC2)                                                บฑฑ
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

Function PcoDelPnj(cId,TipoPlan,oGetDados,cSeq,cSeek)

Local cUpdate := ""
Local cTipoPlan := If( VALTYPE(TipoPlan)=="C" , TipoPlan , "" )

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

If VALTYPE(TipoPlan)=="C"
	
	cUpdate += "ALX_TIPOPL = '" + TipoPlan + "' "
	
ElseIf VALTYPE(TipoPlan)=="A"
	
	cTipoPl := ''
	aEval( TipoPlan , {|x,y| cTipoPl += "'" + x + "'" + If( Len(TipoPlan)==y , ") " , "," ) } )
	cUpdate += " AND ALX_TIPOPL IN (" + cTipoPl
	
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

If VALTYPE(TipoPlan)=="C"
	
	cUpdate += "ALX_TIPOPL = '" + TipoPlan + "' AND "
	
ElseIf VALTYPE(TipoPlan)=="A"
	
	cTipoPl := ''
	aEval( TipoPlan , {|x,y| cTipoPl += "'" + x + "'" + If( Len(TipoPlan)==y , ") " , "," ) } )
	cUpdate += "ALX_TIPOPL IN (" + cTipoPl + " AND "
	
EndIf

cUpdate += " D_E_L_E_T_ = ' ' "
TcSqlExec( cUpdate )
TcRefresh(RetSqlName("ALX"))

If (cId == nil .and. cTipoPlan$'002') .Or. (cId <> nil .and. cTipoPlan == '009')
	
	cPlanExcl := IIf(cTipoPlan == "002","001","009")
			
	cUpdate := "SELECT AM2_ID FROM " + RetSqlName("AM2") + " AM2 WHERE AM2_TIPOPL='" 
	cUpdate += cPlanExcl + "' AND AM2.D_E_L_E_T_=' ' AND "

	If cTipoPlan == "002"
		cUpdate += " AM2_IDPAI<>'   ' AND "
	Else
		If cId <> NIL
			cUpdate += " AM2_ID = '" + cId + "' AND "	
		EndIf	
	EndIf	

	If lOracle .Or. lInformix
		cUpdate += " NVL((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID=AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
	ElseIf  lDB2 .Or. lPostgre  
		cUpdate += " COALESCE((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID=AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
	Else
		cUpdate += " ISNULL((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID=AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cUpdate), "TMPAM2", .T., .T. )
	While TMPAM2->(!Eof())
		
		oPlanej:GetTre("001"):TreeSeek("SB1X"+TMPAM2->AM2_ID)
		oPlanej:GetTre("001"):DelItem()
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		If AM2->(DbSeek(xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + cPlanExcl + Alltrim(TMPAM2->AM2_ID)))
			RecLock("AM2",.F.)
			DbDelete()
			MsUnlock()
		EndIf	
		
		TMPAM2->(DbSkip())
		
	End
	TMPAM2->(DbCloseArea())
	TcRefresh(RetSqlName("AM2"))
	
EndIf

//******************************
// Rotina para Atualizar aCols *
//         Acacio Egas         *
//******************************
If oGetDados<>nil
	
	oGetDados:aCols := {} // Acacio Egas
	PcoAtuGtd(@oGetDados,.T.)
	oGetDados:Refresh() // Atualiza GetDados
	cSeqALY := nil
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAtuGtd บAutor  ณAcacio Egas         บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina Generica para atualizar as GetDados do planejamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoAtuGtd(oGetDados,lIniLin)
Local lNewLine  := .T.
Local nX		:= 0

Default lIniLin := .F.

//******************************
// Rotina para Atualizar aCols *
//         Acacio Egas         *
//******************************

aHeader := aClone(oGetDados:aHeader)

If oGetDados<>nil
	
	If !lIniLin
		If Type("aCols") == "U"
			aCols 	:= aClone(oGetDados:aCols)
			aAdd(aCols,Array(Len(aHeader) + 1))
			lNewLine := .F.
		EndIf
		n		:= Len(aCols)

		For nX := 1 to Len(aHeader)
			If Alltrim(aHeader[nX,2]) $ "ALX_ALI_WT|ALX_REC_WT"
				aCols[Len(aCols)][nX] :=	NIL
			Else
				If (aHeader[nX,10] == "V" .OR. lNewLine )  .And. ( Empty(aCols[Len(aCols)][nX]) )
					If lNewLine .And. Alltrim(aHeader[nX,2]) $ "ALX_QTDTOT|ALX_VLTOT" // Linha nova nใo carrega valores (PCOTOTPNJ(2))
						aCols[Len(aCols)][nX] := CriaVar(AllTrim(aHeader[nX,2]),.F.)
					Else 
						aCols[Len(aCols)][nX] := CriaVar(AllTrim(aHeader[nX,2]))
					EndIf 	
				Elseif !lNewLine 
					aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX,2]))
				EndIf 
			EndIf 
		Next
		
	Else
		
		aCols 	:= {}
		n		:= 1
		aAdd(aCols,Array(Len(aHeader) + 1))
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,CriaVar(AllTrim(x[2]))) })
		// Deleted
		aCols[Len(aCols)][Len(aHeader) + 1] := .F.
		
	EndIf
	
EndIf

oGetDados:aCols 	:= aCols
oGetDados:aHeader	:= aHeader

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoPrcPlan บAutor  ณAcacio Egas        บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza Pre็o para planejamento.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoPrcPlan(cAgregador,cTipoPlan,cTipoValo,cTabePrec)
Local nPrecAgre := 0

If cTipoPlan == "005"
	dbSelectArea("ALT")
	If ALT->(dbSeek(xfilial("ALT") + cAgregador))
		nPrecAgre := ALT->ALT_VALOR
	EndIf
ElseIf cTipoPlan == "006"
	dbSelectArea("AM4")
	If AM4->(dbSeek(xfilial("AM4") + cAgregador))
		nPrecAgre := AM4->AM4_VALOR
	EndIf
Elseif cTipoPlan == "004"
	If cTipoValo == "1" // Busca Custo Standard
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cAgregador))
			nPrecAgre := SB1->b1_custd
		EndIf
	ElseIf cTipoValo == "2"
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cAgregador))
			nPrecAgre := SB1->B1_UPRC
		EndIf
	Else // cTipoValo == "4" - Custo M้dio
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cAgregador))
			dbSelectARea("SB2")
			dbSetOrder(1)
			If SB2->(dbSeek(xfilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD))
				nPrecAgre := SB2->b2_cm1
			EndIf
		EndIf
		
	EndIf
Else
	If cTipoValo == "1" // Busca Custo Standard
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + cAgregador))
			nPrecAgre := SB1->b1_custd
		EndIf
	ElseIf cTipoValo == "2"
		dbSelectArea("DA1")
		dbSetOrder(1)
		If DA1->(dbSeek(xfilial("DA1") + cTabePrec + cAgregador))
			nPrecAgre := DA1->DA1_PRCVEN
		EndIf
	EndIf
EndIf

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para tratamento do valor unitแrio do ณ
//ณplanejamento.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ENDDOC*/
If ExistBlock("PNJXPREC")
	
	nPrecAgre := ExecBlock("PNJXPREC", .F., .F., cAgregador,cTipoPlan)
	
EndIf

Return(nPrecAgre)

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoIncAM2 บAutor  ณAcacio Egas         บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para incluir Item do Planejamento.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoIncAM2(cCargo,cTipoPl,lMsg,cCargoPai,lRestArea)

Local lRet			:= .T.
Local aArea			:= GetArea()
Local aAreaAM2		:= AM2->(GetArea())
Local cIdPai		:= ""
Local cAliasPai
Local cAgreg		:=SubStr(cCargo,4+Len(xFilial()),Len(cCargo)-3+Len(xFilial()))

Default lMsg		:= .T.
Default cCargoPai	:= ""
Default lRestArea	:= .T.

cAliasPai := SubStr(cCargoPai,1,3)

DbSelectArea("AM2")
DbSetorder(2)

If ! Empty(cCargoPai)
	If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cTipoPl+SubStr(cCargoPai,6,Len(cCargoPai)-5)) ;
		.And. Empty(AM2->AM2_IDPAI)  //Qdo eh o PAI esse campo esta em branco
		cIdPai := AM2->AM2_ID
	EndIf
EndIf

If ! DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cTipoPl+SubStr(cCargo,6,Len(cCargo)-5)) .or. ALLTRIM(cIdPai)<>ALLTRIM(AM2->AM2_IDPAI)
	
	PcoInsertAM2(cAgreg, cTipoPl, cIdPai)
	
Else
	
	If lMsg
		Aviso( STR0001 , STR0044 ,{ STR0014 }) //"Aten็ใo"###"Item jแ cadastrado."###"OK"
	EndIf
	lRet := .F.
	
EndIf

If lRestArea
	
	RestArea(aAreaAM2)
	RestArea(aArea)
	
EndIf

Return (lRet)

Function PcoInsertAM2(cAgreg, cTipoPl, cIdPai)

RecLock("AM2",.T.)
AM2->AM2_FILIAL := xFilial("AM2")
AM2->AM2_PLANEJ := ALV->ALV_CODIGO
AM2->AM2_VERSAO := _cVerPlan
AM2->AM2_AGREG  := cAgreg
AM2->AM2_TIPOPL := cTipoPl
AM2->AM2_ID		:= StrZero(AM2->(Recno()), Len(AM2->AM2_ID) )
AM2->AM2_IDPAI	:= cIdPai  //so eh preenchido quando eh filho
MsUnlock()

Return

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunÿÿo    ณPcoPnjAlt   ณ Autor ณJoใo Gon็alves de Oliveira ณ Data ณ 06/01/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriÿÿo ณFuncao que altera os valores de planejamento                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAPMS                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoPnjAlt(cId,cSeek,aAuto,aTipoPl)

Local lContinua	:= .T.
Local aConfig   := {}
Local aTipos    := { STR0045 , STR0046 } //"Por Percentual Normal"###"Por Percentual Embutido"
Local aCalculo  := { STR0047 , STR0048 , STR0049 } //"Somar"###"Diminuir"###"Substituir Valor"
Local cFiltroALX
Local cStrTpPl
//Local lReceita
Local lRelac	:= Empty(cSeek) //.or. Empty(cId)
Local aParam 	:= {}
Local cQuery,cUpdate,cIds
Local cCodigo	:= ''

Default cSeek	:= ""

If aAuto==nil
	
	DbSelectArea("ALX")
	
	aAdd(aParam , {3, STR0050 ,1,aTipos,130,"",.F.} 	) //"Tipo de Reajuste"
	aAdd(aParam , {3, STR0051 ,1,aCalculo,130,"",.F.} 			) //"Operacao"
	aAdd(aParam , {1, STR0052 ,0		 ,"@E 9,999,999,999.99","","","",100,.T.} 	) //"Valor ou Percentual"
	aAdd(aParam , {1, STR0053 ,CtoD(Space(8)),"@D"                 ,"","","",100,.T.}	) //"Data Inicial Periodo"
	aAdd(aParam , {1, STR0054 ,CtoD(Space(8)),"@D"                 ,"","","",100,.T.}	) //"Data Final do Periodo"
	aAdd(aParam , {7, STR0017 ,"ALX",""}			) //"Filtra Distribui็ใo"
	/*aAdd(aParam , {3,"Aterar"	,1,{"Receita","Custo"},130,"",.F.} ) */
	aAdd(aParam , {3, STR0022 ,1,{ STR0003 , STR0004 },130,"",.F.,!lRelac } ) //"Aplicar"###"Principal"###"Todos"
	
	If ! ParamBox( aParam , STR0055 , @aConfig ) //"Parametros"
		
		lContinua := .F.
		
	Else

		DbSelectArea("ALX")

		// Limpa a cSeek caso sejแ somente para gerar para o princicpal
		If aConfig[7]==1
			
			cSeek	:= '' 
			
		Else
		
			cId		:= ''
			
		EndIf

		cFiltroALX 	:= PcoParseFil(aConfig[6],"ALX")
		If !Empty(cSeek)
			
			cFiltroALX 	:= cSeek + If( !Empty(cFiltroALX) , " AND " + cFiltroALX , "" )
			
		EndIf
		aConfig[6] := cFiltroALX

	EndIf
	
Else
	
	aConfig 	:= aAuto
	aConfig[1] 	:= Val(aConfig[1])
	aConfig[2] 	:= Val(aConfig[2])
	aConfig[3] 	:= Val(aConfig[3])
	aConfig[4] 	:= stod(aConfig[4])
	aConfig[5] 	:= stod(aConfig[5])
	cFiltroALX	:= aConfig[6]
	aConfig[7]  := Val( aConfig[7] )
	
EndIf

If lContinua .And. (Empty(aConfig[4]) .Or. Empty(aConfig[5]))
	
	Aviso( STR0001 , STR0056 ,{ STR0057 },2) //"Atencao"###"Nao informado o periodo a ser reajustado!"###"Fechar"
	lContinua := .F.
	
EndIf


If lContinua
	
	cIds	:= "('"
	cQuery 	:= "SELECT ALX_AM2ID,ALX_AGREG,ALX_CODIGO FROM " + RetSqlName("ALX") + " ALX WHERE "
	cQuery 	+= "ALX_FILIAL='" + xFilial("ALX") + "' AND ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' "
	
	If !Empty(cId)
		
		cQuery 		+= " AND ALX_AM2ID='" + cId + "' "
		cFiltroALX 	:= " ALX_AM2ID='" + cId + "' "
		
	Else
		
		cQuery 		+= If( Empty(cFiltroALX) , "" , " AND (" + cFiltroALX + ") " )
		
	EndIf
	cQuery 	+= " AND ALX_AM2ID<>'' AND "
	
	
	
	cStrTpPl := ''
	
	aEval( aTipoPl , {|z| cStrTpPl += "'" + z + "'," } )
	
	cStrTpPl := SubStr(cStrTpPl , 1 , Len(cStrTpPl) -1 )
	
	cQuery 	+= " ALX_TIPOPL IN (" + cStrTpPl + ") AND "
	
	cQuery 	+= " ALX.D_E_L_E_T_ = ' '  GROUP BY ALX_AM2ID,ALX_AGREG,ALX_CODIGO "
	
	cQuery 	:= ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPID", .T., .T. )
	
	If TMPID->(Eof())
		
		lContinua := .F.
		TMPID->(DbCloseArea())
		
	EndIf
	
EndIf

If lContinua
	
	While TMPID->(!Eof())
		
		cIds += TMPID->ALX_AM2ID + "','"
		TMPID->(DbSkip())
		
	End
	
	cIds := SubStr( cIds , 1 , Len(cIds)-2 ) + ")"
	
	cUpdate 	:= "SELECT ALX.*,ALY_DTINI AS DATAPLNJ, ALY_DTFIM AS DATAFINA,0 AS ALY_QUANT ,"
	nNumeAdic 	:= IIf(aConfig[1] == 1,aConfig[3] / 100,aConfig[3])
	
	// Somente Valor
	If aConfig[2] < 3
		
		cUpdate += "(ALY_VALOR * " +  AllTrim(Str(IIf(aConfig[2] == 1,1 + nNumeAdic,1 - nNumeAdic))) + ") AS ALY_VALOR "
		
	Else
		
		cUpdate += Str(aConfig[3]) + " AS ALY_VALOR "
		
	EndIf
	cUpdate += " FROM " + RetSqlName("ALX") + " ALX, " + RetSqlName("ALY") + " ALY "
	cUpdate += " WHERE ALX_FILIAL='"+ xFilial("ALX") +"' AND ALY_FILIAL=ALX_FILIAL AND "
	cUpdate += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND "
	cUpdate += " ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "
	cUpdate += " ALX.D_E_L_E_T_=' ' AND ALY.D_E_L_E_T_=' ' AND "
	cUpdate += " ALY_SEQ=ALX_SEQ AND "
	cUpdate += " ALY_DTINI >= '" + DTOS(aConfig[4]) + "' AND ALY_DTFIM <= '" + DTOS(aConfig[5]) + "' AND "
	
	cUpdate += " ALX_TIPOPL IN (" + cStrTpPl + ") AND "
	
	cUpdate += " ALX_AM2ID IN " + cIds
	
	cUpdate	:= ChangeQuery( cUpdate )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cUpdate), "TMPREA", .T., .T. )
	
	If TMPREA->(!Eof())
		
		PcoGrvPlan(/*cId*/,/*oGetDados*/,"TMPREA",/*cTipoPlan*/,.F./*lQtd*/,/*cFiltroALX*/,.T.,/*cTipoForm*/,/*cFormRegr*/)
		
		// Refaz Movimentos Relacionados
		TMPID->(DbGoTop())
		While TMPID->(!Eof())
			
			
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPontera tabela AM2ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//ENDDOC*/
			DbSelectArea("AM2")
			DbSetOrder(3)
			DbSeek( xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + aTipoPl[1] + TMPID->ALX_AM2ID)
			
			If !Empty(AM2->AM2_IDPAI)
				
				cCodigo := AM2->AM2_AGREG
				cId 	:= AM2->AM2_ID
				// No momento da Gera็ใo o Pai tem q estar ponterado
				DbSeek( xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + aTipoPl[1] + AM2->AM2_IDPAI)
				
			Else
				
				cCodigo := ''
				cId 	:= AM2->AM2_ID
				
			EndIf
			
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ฟ
			//ณGrava Historico do reajuste afetuadoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ0ู
			//ENDDOC*/
			If aConfig[7]==1 .and. aTipoPl[1]='004'
				
				If Empty(cCodigo)
				
					cCodigo	:= AM2->AM2_AGREG

				EndIf
				
				aConfig[6] 	:= " ALX_AGREG='" + AM2->AM2_AGREG + "' AND ALX_CODIGO='" + cCodigo + "' "

			ElseIf aConfig[7]==1 .and. aTipoPl[1]=='001'
			
				If lRelac
				
					aConfig[6] 	:= " ALX_AGREG='" + AM2->AM2_AGREG + "' AND ALX_CODIGO='" +cCodigo + "' "
				
				Else
				
					aConfig[6] 	:= " ALX_AGREG='" + AM2->AM2_AGREG + "' AND ALX_CODIGO='' "
			
				EndIf
			
			ElseIf aTipoPl[1]=='009'
			
				aConfig[6] 	:= " ALX_AGREG='" + cCodigo + "' AND ALX_CC='" +AM2->AM2_AGREG + "' "

			EndIf
			RecLock("ALX",.T.)
			ALX_FILIAL 	:= xfilial("ALX")
			ALX_PLANEJ 	:= ALV->ALV_CODIGO
			ALX_VERSAO 	:= _cVerPlan
			ALX_REGRA	:= ''
			
			If aTipoPl[1]<>"009"
			
				ALX_AGREG	:= AM2->AM2_AGREG
				ALX_CODIGO	:= cCodigo
		    
		    Else

				ALX_AGREG	:= cCodigo
				ALX_CODIGO	:= AM2->AM2_AGREG
			
			EndIf		    
		    
			ALX_AM2ID	:= ''
			ALX_TIPOPL 	:= "9" + SubStr( aTipoPl[1] , 2 )
			ALX_TIPO	:= ""
			ALX_SEQ 	:= ""
			ALX_FILTRO	:= ArrayStr(aConfig)
			MsUnlock()
			
			If "001" $ cStrTpPl
				
				cQuery 	:= "SELECT ALX_REGRA,ALX_FILTRO FROM " + RetSqlName("ALX") + " ALX WHERE "
				cQuery 	+= " ALX_AM2ID= '" + TMPID->ALX_AM2ID + "' AND ALX_TIPOPL='003' AND ALX.D_E_L_E_T_ = ' '  GROUP BY ALX_REGRA,ALX_FILTRO"
				
				cQuery 	:= ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPID2", .T., .T. )
				
				While TMPID2->(!Eof())
					
					aAuto := { TMPID2->ALX_REGRA , 1	, '' }
					PcoRunPlan( nil , "003" , 5 , nil , "ALX_AM2ID='" + cId + "' AND ALX_REGRA='" + TMPID2->ALX_REGRA + "' ")
					
					PcoRunPlan( cId , '003' , 3 , nil , TMPID2->ALX_FILTRO + " AND ALX_AGREG='" + TMPID->ALX_AGREG + "' AND ALX_CODIGO='" + TMPID->ALX_CODIGO + "' ", aAuto )
					TMPID2->(DbSkip())
					
				End
				
				TMPID2->(DbCloseArea())
			
			ElseIf "009" $ cStrTpPl

				cQuery 	:= "SELECT ALX_CODIGO,ALX_REGRA,ALX_CC,ALX_AGREG,ALX_FILTRO FROM " + RetSqlName("ALX") + " ALX WHERE "
				cQuery 	+= " ALX_AM2ID= '" + TMPID->ALX_AM2ID + "' AND ALX_TIPOPL='010' AND ALX.D_E_L_E_T_ = ' '  GROUP BY ALX_CODIGO,ALX_REGRA,ALX_CC,ALX_AGREG,ALX_FILTRO"
				
				cQuery 	:= ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPID2", .T., .T. )
				
				While TMPID2->(!Eof())
							
					PcoRunPlan( nil , "010" , 5 , nil , " ALX_CC='"+ AM2->AM2_AGREG +"' AND ALX_AGREG='" + cCodigo + "' " )
					
					cCargo 			:= oPlanej:GetTre("001"):GetCargo()			

					dbSelectArea("AM2")
					dbSetorder(3)
					dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"009"+SubStr(cCargo,4,Len(AM2->AM2_ID)) )
					
					PcoGerVerba( TMPID2->ALX_CODIGO , TMPID2->ALX_CC , cCodigo , nil , nil , nil )
									
					TMPID2->(DbSkip())
					
				End
				
				TMPID2->(DbCloseArea())
				
			EndIf
			
			TMPID->(DbSkip())
			
		End
		
		TMPID->(DbCloseArea())
		
	Else
		
		TMPREA->(DbCloseArea())
		TMPID->(DbCloseArea())
		
	EndIf
	
EndIf

Return(lContinua)

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunÿÿo    ณPcoPnjAtu   ณ Autor ณAcacio Egas           ณ Data ณ 13/03/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriÿÿo ณFuncao que altera os valores de planejamento                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAPCO                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoPnjAtu(oGetDados,cTipoPlan,lid)

Local aCols 	:= oGetDados:aCols
Local aHeader 	:= oGetDados:aHeader
Local nA		:= oGetDados:nat
Local Nx,Ni
Local nCpoSeq 	:= aScan(oGetDados:aHeader,{|x|ALLTRIM(x[2])=="ALX_SEQ"})
Local nPosConta	:= aScan(oGetDados:aHeader,{|x|ALLTRIM(x[2])=="ALX_CO"})
Local lInclui
Local cCargo 	:= oPlanej:GetTre("001"):GetCargo()
Local cAgreg,cCodigo := ''
Local cSeq 		:= PcoALXSeq()
Local aDels		:= {}
Local cIdAtu, nId, cCargoPai
Local lFirst	:= .T.

Default lId := .F.

If lId
	
	If SubStr(cCargo,4,1)=='X'
		
		cId := SubStr(cCargo,5,Len(cCargo)-4)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+cId )
		cCodigo := AM2->AM2_AGREG
		DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+AM2->AM2_IDPAI )
		cAgreg 	:= AM2->AM2_AGREG
		cTipoPlan := '002'
	Else
		
		cId 	:= SubStr(cCargo,4,Len(cCargo)-3)
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+cId )
		cAgreg 	:= AM2->AM2_AGREG
		
	EndIf
	
Else
	
	cAgreg 	:= SubStr(cCargo,6,Len(cCargo)-5)
	DbSelectArea("AM2")
	DbSetOrder(2)
	DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+cAgreg)
	cId 	:= AM2->AM2_ID
	
EndIf
DbSelectare("ALX")
DbSetorder(2)
PcoIniLan("000358")
For Nx:=1 To Len(aCols)
	
	If !Empty(aCols[Nx,nCpoSeq])		//
		
		If !aCols[Nx][Len(aCols[Nx])]
			
			If 	MaCheckCols(aHeader,aCols,Nx)

				DbSelectare("ALX")
				DbSetorder(2)				
				lInclui := !DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+aCols[Nx,nCpoSeq])
				RecLock("ALX",lInclui)
				For Ni:=1 To Len(aHeader)
					
					&(AllTrim(aHeader[Ni,2])) := aCols[Nx,Ni]
					
				Next
				MsUnlock()
			
			   //******************************
			   // Atualizado de Saldo do PCO  *
			   //******************************
				DbSelectArea("ALY")
				DbSetOrder(1)
				If DbSeek(xFilial("ALY")+ALX->ALX_PLANEJ+_cVerPlan+ALX->ALX_SEQ)
					Do While ALY->(!Eof()) .and. ;
					xFilial("ALY")+ALX->ALX_PLANEJ+_cVerPlan+ALX->ALX_SEQ==ALY->ALY_FILIAL+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ
						PcoDetLan("000358","01","PCOXPNJ")
						ALY->(DbSkip())
					EndDo
				EndIf					
			
			EndIf
			
		Else // Deleta linha do Acols
			
			PcoDelPnj(nil,cTipoPlan,,aCols[nx,nCpoSeq])
			aAdd(aDels,Nx)
			
		Endif
		
	ElseIf !aCols[Nx][Len(aCols[Nx])] // Inclui distribui็ใo
		
		If 	MaCheckCols(aHeader,aCols,Nx)
			
			/*
			If cTipoPlan == '009'  //folha de pagamento
				If nPosConta > 0
					cTipoCtbl := PCOBuscTp(cTipoPlan, aCols[Nx, nPosConta])
				EndIf
			Else
				cTipoCtbl := PCOBuscTp(cTipoPlan, cAgreg )
			EndIf
			*/
			cSeq:= Iif(lFirst, cSeq, Soma1(cSeq))
			RecLock("ALX",.T.)
			
			ALX_FILIAL 	:= xfilial("ALX")
			ALX_PLANEJ 	:= ALV->ALV_CODIGO
			ALX_VERSAO 	:= _cVerPlan
			ALX_AGREG	:= cAgreg
			If cTipoPlan == '009'  //folha de pagamento
				If aScan(oGetDados:aHeader,{|x|ALLTRIM(x[2])=="ALX_CODIGO"}) == 0
					ALX_CODIGO	:= PcoRetVerb()
				EndIf
				cIdAtu 	:= oPlanej:GetTre("001"):aNodes[ aScan( oPlanej:GetTre("001"):aCargo, {|X| X[1] = cCargo } ), 1 ]
				nId  	:= aScan( oPlanej:GetTre("001"):aNodes, {|X| X[2] = cIdAtu } )
				cCargoPai := oPlanej:GetTre("001"):aCargo[ nId, 1]
				ALX_CC := Subs(cCargoPai, 6)
			Else
				ALX_CODIGO	:= cCodigo
			EndIf
			ALX_AM2ID	:= cId
			ALX_FILTRO	:= '#'
			ALX_TIPOPL 	:= cTipoPlan
			ALX_TIPO	:= "1"/*cTipoCtbl*/
			ALX_SEQ 	:= cSeq
			cSeqALY		:= ALX_SEQ // Guarda a Sequencia atual
			// Preenche sequancia no acols
			oGetDados:aCols[Nx,nCpoSeq] := ALX_SEQ
			For Ni:=1 To Len(aHeader)
				
				&(AllTrim(aHeader[Ni,2])) := aCols[Nx,Ni]
				
			Next
			MsUnlock()
			lFirst := .F.
		EndIf
		
	EndIf
	
Next
PcoFinLan("000358")
If Len(aDels)>0
	
	aEval(aDels,{|x| aDel(oGetDados:aCols,x)})
	aSize(oGetDados:aCols,Len(oGetDados:aCols)-Len(aDels))
	If Len(oGetDados:aCols)=0
		
		PcoAtuGtd(oGetDados,.T.)
		
	EndIf
	
EndIf

// Ajusta a GetDados
If Len(oGetDados:aCols)==0 // Cria linha
	
	aAdd(oGetDados:aCols,Array(Len(oGetDados:aHeader) + 1))
	AEval(oGetDados:aHeader, {|x,y| oGetDados:aCols[Len(oGetDados:aCols)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	oGetDados:aCols[1,Len(oGetDados:aHeader) + 1] := .F.
	oGetDados:Refresh()
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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

Function PcoPnjRat(aValores,cTipoPlan,cAgregador,lInfoQtde,cRegrDist,lFormula)
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
	Case cTipoPlan == "005"
		dbSelectArea("ALT")
		dbSetOrder(1)
		If ALT->(dbSeek(xfilial("ALT") + cAgregador))
			lFormValo := ! Empty(ALT->ALT_FORMUL)
		EndIf
	Case cTipoPlan == "006"
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
PadR(ALV->ALV_DESCRI,50) + CRLF + CRLF + STR0012 + cAgregador + CRLF + CRLF + STR0066 + cTipoPlan /*<cText>*/,;
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PnjWizard       บAutorณJoใo Gon็alves de Oliveira บ Data ณ 12/03/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
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
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funÿÿo   ณ PcoExpPro   ณ Autor ณJoใo Gon็alves Oliveiraณ Data ณ 18/03/08  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriÿÿoณ Faz a explosao da estrutura para o produto do planejamento     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ PcoExpPro(ExpC1,ExpA1)		      				      		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo do produto a ser explodido                      ณฑฑ
ฑฑณParametrosณ ExpA1 = Array com os parametros                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Planejamento e Controle Or็amentแrio                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Static Function PcoExpPro(cProduto,aConfig,aCustRela,cId) // Revisar

Local nRegiAtua
Local nRegiSub
Local nQtdeBase := 0

dbSelectArea("SG1")
dbSetOrder(1)
If SG1->(dbSeek(xFilial("SG1") + cProduto))
	
	nQtdeBase := SG1->G1_QUANT
	While ! SG1->(Eof()) .And. SG1->(G1_FILIAL + G1_COD) == xFilial("SG1") + cProduto
		
		nRegiAtua := SG1->(Recno())
		nBuscComp := aScan(aCustRela,{|x| x[1] == SG1->G1_COMP})
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->(dbSeek(xfilial("SB1") + SG1->G1_COMP))
			
			lGravEstr := IIf(! Empty(aConfig[4]),aConfig[4],.T.)
			lGravEstr := IIf(SB1->b1_tipo >= aConfig[2] .And. SB1->b1_tipo <= aConfig[3],.T.,lGravEstr)
			
			If nBuscComp == 0 .And. lGravEstr
				/*BEGINDOC
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤํteHฟ
				//ณPonto de Entrada para buscar o custo unitแrio para o ํtemณ
				//ณda estrutura                                             ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤํteHู
				//ENDDOC*/
				If ExistBlock("PCOX001A")
					
					nPrecAgre := ExecBlock("PCOX001A", .F., .F., SG1->G1_COMP)
					
				Else
					
					nPrecAgre := PcoPrcPlan(SG1->G1_COMP,"001","1")
					
				EndIf
				
				aAdd(aCustRela,{SG1->G1_COMP,SG1->G1_QUANT / nQtdeBase,nPrecAgre,cId})
				
			EndIf
			
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se existe sub-estrutura                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nRegiSub := SG1->(Recno())
		If SG1->(dbSeek(xFilial("SG1") + SG1->G1_COMP,.F.))
			
			PcoExpPro(SG1->G1_COD,aConfig,aCustRela,cId)
			
		Else
			
			SG1->(dbGoto(nRegiSub))
			nBuscComp := aScan(aCustRela,{|x| x[1] == SG1->G1_COMP})
			dbSelectArea("SB1")
			dbSetOrder(1)
			If SB1->(dbSeek(xfilial("SB1") + SG1->G1_COMP)) .And. nBuscComp == 0
				
				lGravEstr := IIf(! Empty(aConfig[4]),aConfig[4],.T.)
				lGravEstr := IIf(SB1->b1_tipo >= aConfig[2] .And. SB1->b1_tipo <= aConfig[3],.T.,lGravEstr)
				If lGravEstr
					
					/*BEGINDOC
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤํteHฟ
					//ณPonto de Entrada para buscar o custo unitแrio para o ํtemณ
					//ณda estrutura                                             ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤํteHู
					//ENDDOC*/
					If ExistBlock("PCOX001A")
						nPrecAgre := ExecBlock("PCOX001A", .F., .F., SG1->G1_COMP)
					Else
						nPrecAgre := PcoPrcPlan(SG1->G1_COMP,"001",aConfig[5])
					EndIf
					aAdd(aCustRela,{SG1->G1_COMP,SG1->G1_QUANT / nQtdeBase,nPrecAgre,cId})
					
				EndIf
				
			EndIf
			
		Endif
		SG1->(dbGoto(nRegiAtua))
		SG1->(dbSkip())
		
	End
	
EndIf

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funÿÿo   ณ PCOSldPNJ  ณ Autor ณJoใo Gon็alves Oliveiraณ Data ณ 05/04/08   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriÿÿoณ Atualiza saldos das contas or็amentแrias de evolu็ใo           ณฑฑ
ฑฑณ          ณ patrimonial                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ PCOSldPNJ(ExpA1,ExpA2)		      				      		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Vetor com perํodos de planejamento                     ณฑฑ
ฑฑณParametrosณ ExpA1 = Vetor com entidades da distribui็ใo                    ณฑฑ
ฑฑณParametrosณ ExpN1 = Valor a ser somado ou subtraํdo do saldo               ณฑฑ
ฑฑณParametrosณ ExpC1 = Data inicial para atualiza็ใo dos saldos               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Planejamento e Controle Or็amentแrio                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Function PcoSldPNJ(aDataPlnj,_aDistrib,nValoMvto,cDataSald)

cUpdate := "UPDATE " + RetSqlName("ALY") + " SET ALY_VALOR = ALY_VALOR + '" + Str(nValoMvto) + "' "
cUpdate += "FROM " + RetSqlName("ALY") + " ALY," + RetSqlName("ALX") + " ALX "
cUpdate += "WHERE ALY_FILIAL = '" + xfilial("ALY") + "' "
cUpdate += "AND ALX_FILIAL = '" + xfilial("ALX") + "' "
cUpdate += "AND ALY_PLANEJ = '" + ALV->ALV_CODIGO + "' "
cUpdate += "AND ALY_VERSAO = '" + _cVerPlan + "' "
cUpdate += "AND ALY_SEQ = '" + _aDistrib[7] + "' "
cUpdate += "AND ALY_FILIAL = ALX_FILIAL AND ALY_PLANEJ = ALX_PLANEJ "
cUpdate += "AND ALX_TIPOPL = '007' "
cUpdate += "AND ALY_VERSAO = ALX_VERSAO AND ALY_SEQ = ALX_SEQ "
cUpdate += "AND ALX.D_E_L_E_T_  = ' '  AND ALY.D_E_L_E_T_  = ' '  "
cUpdate += "AND ALY_DTINI >= '" + cDataSald + "' "
TcSqlExec( cUpdate)
TcRefresh(RetSqlName("ALY"))

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funÿÿo   ณ PcoPnjDel  ณ Autor ณJoใo Gon็alves Oliveiraณ Data ณ 10/04/08   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriÿÿoณ Exclui todos os dados quando da exclusใo da planilha de        ณฑฑ
ฑฑณ          ณ planejamento                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ PcoPnjDel()         		      				      		      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Planejamento e Controle Or็amentแrio                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Function PcoPnjDel(cAlias,nRecno,nOpcx,aCpos,cSeekALX,cSeekAM2,lDelALV,lAuto)

Local nOpc := 1
Local cUpdate
Local cQuery

Local _cVerPlan 	:= ALV->ALV_VERSAO // Criado para Ferramenta de Revis๕a

Default cSeekALX	:= ''
Default cSeekAM2:= ''
Default lDelALV := .T.
Default lAuto	:= .F.

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
			DbDelete()
		MsUnlock()
	
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
	
	// Excluir AM2
	cUpdate := "UPDATE " + RetSqlName("AM2") + " SET D_E_L_E_T_ = '*' "
	cUpdate += " WHERE R_E_C_N_O_  IN "
	cUpdate += " ( SELECT AM2.R_E_C_N_O_  FROM " + RetSqlName("AM2") + " AM2 "
	cUpdate += "WHERE AM2_FILIAL = '" + xfilial("AM2") + "' "
	cUpdate += "AND AM2_PLANEJ = '" + ALV->ALV_CODIGO + "' "
	cUpdate += "AND AM2_VERSAO = '" + _cVerPlan + "' "
	If !Empty(cSeekAM2)
		
		cUpdate += "AND " + cSeekAM2
		
	EndIf
	cUpdate += "AND AM2.D_E_L_E_T_  = ' '   ) "

	TcSqlExec( cUpdate)
	TcRefresh(RetSqlName("AM2"))
	
	// Excluir ALV
	If lDelALV
		
		cUpdate := "UPDATE " + RetSqlName("ALV") + " SET D_E_L_E_T_ = '*' "
		cUpdate += " WHERE R_E_C_N_O_  IN "
		cUpdate += " ( SELECT ALV.R_E_C_N_O_  FROM " + RetSqlName("ALV") + " ALV "
		cUpdate += "WHERE ALV_FILIAL = '" + xfilial("ALV") + "' "
		cUpdate += "AND ALV_CODIGO = '" + ALV->ALV_CODIGO + "' "
		cUpdate += "AND ALV_VERSAO = '" + _cVerPlan + "' "
		cUpdate += "AND ALV.D_E_L_E_T_  = ' '  )  "
		TcSqlExec( cUpdate)
		TcRefresh(RetSqlName("ALV"))
		
	EndIf
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoDistShow บAutor  ณAcacio Egas       บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibi distribui็ใo de valores para um item do Planejamento บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoDistShow(cSeek,lQtd,cTipoPl)

Local aCoord	:= { 000, 000, 425, 575}	
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
cQuery += cSeek
cQuery += " AND ALX_TIPOPL='" + cTipoPl + "' "
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

@ 035, 006 MSPANEL oMPanel[1]	OF oDlg SIZE 277, 155 RAISED

nTop  := (oMPanel[1]:nTop + oMPanel[1]:nHeight + 12)/2
nLeft := (oDlg:nWidth/2) - 180

@ nTop, nLeft + 130 BUTTON oCancel PROMPT STR0095 SIZE 040, 013 OF oDlg PIXEL ACTION oDlg:End() //"Sair"

oMPanel[1]:Show()

//Cria MsmGet
oMsmGet := MsMGet():New("ALY",ALY->(Recno()),4,,,,,{0, 0, 640, 480},,4,,,,oMPanel[1],,,,,,.T.,_aGetQuants)
oMsmGet:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

oDlg:Activate( ,,,.T.)

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoTotPnj บAutor  ณMicrosiga           บ Data ณ  05/15/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca Total da Distribui็ใo                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoTotPnj(nTp,cSeq,dDataIni,dDataFim)

Local cQuery
Local nTot := 0
Local aArea := GetArea()

PcoIni_VarStatic()

If cSeq<>nil
	
	If nTp==1 // Quantidade

		If lOracle .Or. lInformix
			cQuery := "SELECT NVL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		ElseIf  lDB2 .Or. lPostgre  
			cQuery := "SELECT COALESCE(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		Else
			cQuery := "SELECT ISNULL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		EndIf
	
	Else // Valor

		If lOracle .Or. lInformix
			cQuery := "SELECT NVL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ cSeq + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
		ElseIf  lDB2 .Or. lPostgre  
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

ElseIf Select("TMPALX") > 0 //Alterado pois no Oracle nใo estava trazendo o TYPE do campo
	
	If !Empty(ALX_SEQ)
		
		If nTp==1 // Quantidade
			
			If lOracle .Or. lInformix
				cQuery := "SELECT NVL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			ElseIf  lDB2 .Or. lPostgre  
				cQuery := "SELECT COALESCE(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			Else
				cQuery := "SELECT ISNULL(SUM(ALY_QUANT),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "
			EndIf
		
		Else // Valor

			If lOracle .Or. lInformix
				cQuery := "SELECT NVL(SUM(ALY_VALOR),0) TOTAL FROM "+ RetSqlName("ALY") +" WHERE D_E_L_E_T_=' ' AND ALY_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_VERSAO='" + _cVerPlan + "' AND ALY_SEQ='"+ ALX_SEQ + "' AND ALY_FILIAL='"+ xFilial("ALY") +"' "				
			ElseIf  lDB2 .Or. lPostgre  
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


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funÿÿo   ณ PCOBuscTp  ณ Autor ณJoใo Gon็alves Oliveiraณ Data ณ 15/04/08   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descriÿÿoณ Busca tipo de contabiliza็ใo para o tipo de planejamento e/ou  ณฑฑ
ฑฑณ          ณ tipo de movimento indicado                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ PCOBuscTp(ExpC1,ExpC2)       	  				      		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Tipo de Planejamento                                   ณฑฑ
ฑฑณParametrosณ ExpC2 = Tipo de Movimento                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Planejamento e Controle Or็amentแrio                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/

Function PCOBuscTp(cTipoPlan,cTipoMvto)
Local cTipoCtbl := ""
Local aArea 	:= getArea()

dbSelectARea("AM1")
dbSetOrder(1)

If AM1->(dbSeek(xfilial("AM1") + cTipoPlan))
	
	cTipoCtbl := AM1->AM1_TIPO
	
EndIf

If AllTrim(cTipoCtbl) == ""
	
	If cTipoPlan$"007,008,009"
		
		dbSelectARea("AK5")
		dbSetOrder(1)
		If AK5->(dbSeek(xfilial("AK5") + cTipoMvto))
			cTipoCtbl := AK5->AK5_DEBCRE
		EndIf
		
	ElseIf cTipoPlan=="006
		
		dbSelectARea("AM4")
		dbSetOrder(1)
		
		If AM4->(dbSeek(xfilial("AM4") + cTipoMvto))
			cTipoCtbl := AM4->AM4_TIPO
		EndIf
		
	Else
		
		dbSelectARea("ALQ")
		dbSetOrder(1)
		
		If ALQ->(dbSeek(xfilial("ALQ") + cTipoMvto))
			cTipoCtbl := ALQ->ALQ_TIPO
		EndIf
		
	EndIf
	
EndIf

If AllTrim(cTipoCtbl) == ""
	Aviso( STR0001 , STR0096 ,{ STR0014 }) //"Aten็ใo"###"Tipo de contabiliza็ใo nใo identificado, impossํvel prosseguir"###"Ok"
EndIf

RestArea(aArea)

Return(cTipoCtbl)

Static Function PcoChavALX(cAlias , cTipoPlan)

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
cQuery += "ALX_TIPOPL='" 	+ cTipoPlan				+ "' AND "
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoPnjReProc บAutor  ณAcacio Egas      บ Data ณ  05/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de recalculo de um item do planejamento.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoPnjReProc(cId,cTipoPlan)

Local oWizard

Private oMsmDist,oGtdRegra,oGtdMan,oMsmMan,oMeter
Private aColsReg,aHeaderReg,aColsMan,aHeaderMan,aSeqVal,aConfigs[4]
Private lManual := .F.
Private _cFilALX,_cRegra,cReprocSeq := ''

DbSelectArea("AM2")
DbSetOrder(3)
DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+cTipoPlan+cId )

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
{||PcoReproc(@oWizard,1,{AM2->AM2_AGREG,cTipoPlan}) }/*<bExecute>*/ )
//"Distribui็ใo dos Valores"###"Neste passo voce deverแ informar os valores para cada periodo do planejamento."

// janela 02
oWizard:NewPanel( STR0102 , STR0103 ,;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel.>*/,;
{|| PcoReproc(@oWizard,2,{ AM2->AM2_AGREG ,cTipoPlan }) }/*<bExecute>*/ )
//"Regras aplicadas!"###"Neste passo voce deverแ informar quais as Regra que voc๊ deseja aplicar no reprocessamento."

// janela 03
oWizard:NewPanel( STR0104 , STR0105 ,;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
.T./*<.lPanel .>*/, ;
{||PcoReproc(@oWizard,3,{ AM2->AM2_AGREG , cTipoPlan }) }/*<bExecute>*/ )
//"Movimentos manuais!"###"Neste momento seram informados os movimentos digitados de forma manual no planejamento."

If cTipoPlan<>"009"

	// janela 04
	oWizard:NewPanel( STR0106 , STR0107 ,;
	{||.T.}/*<bBack>*/, ;
	{||.T.}/*<bNext>*/, ;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel .>*/, ;
	{||PcoReproc(@oWizard,4,) }/*<bExecute>*/ )
    //"Parametros de Reprocessamento"###"Neste momento seram informados referente ao reprocessamento do Planejamento"
	
EndIf

// janela 05
oWizard:NewPanel( "Reprocessamento","Aten็ใo todos os dados do planejamento serใo reprocessados. Click em finalizar para iniciar o reprocessamento.",;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{||PcoRepMet(cId , { cTipoPlan } ) }/*<bFinish>*/,;
.T./*<.lPanel .>*/, ;
{||PcoReproc(@oWizard,5,) }/*<bExecute>*/ )


oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/, ;
{||.T.}/*<bInit>*/, ;
{||.T.}/*<bWhen>*/ )


Return

Static Function PcoReproc(oWizard,nWin,aParam)
Local _nContItem
Local cQuery
Local aCpos
Local cTpPLans
Local aTpPlans := { {'001',{'001','002','003','004','901','904'}} , {'009',{'009','010','909','910'} } }

Do Case
	
	Case nWin==1
		
		//***********************************//
		// Vetor aParam                      //
		//    [1] = cAgregador               //
		//    [2] = cTipo de Planejamento    //
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
		If .T.
			cQuery += "SUM(ALY_QUANT) TOTAL "
		Else
			cQuery += "SUM(ALY_VALOR) TOTAL "
		EndIf
		cQuery += "FROM "+ RetSqlName("ALY") +" ALY,"+ RetSqlName("ALX") +" ALX "
		cQuery += "WHERE ALY.D_E_L_E_T_=' ' AND ALX.D_E_L_E_T_=' ' AND "
		cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ AND "
		cQuery += " ALX_VERSAO='" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO AND "
		cQuery += "ALX_AGREG='"  + aParam[1] + "' AND "
		cQuery += "ALX_TIPOPL='" + aParam[2] + "' AND "
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
		// Vetor aParam                      //
		//    [1] = cAgregador               //
		//    [2] = cTipo de Planejamento    //
		//***********************************//
		
		If oGtdMan==nil
			
			cQuery := "SELECT * FROM " + RetSqlName("ALX")
			cQuery += " WHERE ALX_FILTRO='#' AND D_E_L_E_T_=' ' AND "
			cQuery += " ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' AND "
			cQuery += "ALX_AGREG='" + aParam[1] + "' AND "
			cQuery += "ALX_TIPOPL='" + aParam[2] + "' "
			
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
		// Vetor aParam                      //
		//    [1] = cAgregador               //
		//    [2] = cTipo de Planejamento    //
		//***********************************//
		
		// Grava aCols do GetDados de ALX manual
		If oGtdMan<>nil
			
			aColsMan	:= oGtdMan:aCols
			aHeaderMan	:= oGtdMan:aHeader
			
			PcoReprcALY(oGtdMan,.T.)
			
		EndIf
		
		cTpPLans := ''
		
		aEval(aTpPLans[ aScan( aTpPLans , { |x| x[1]== aParam[2] } ) , 2 ],{|z| cTpPLans += "'" + z + "'," } )
		
		cTpPLans := SubStr(cTpPLans , 1 , Len(cTpPLans) -1 )
		
		If oGtdRegra == nil
			
			//**************************************//
			//    Reprocessamento de Receita        //
			//**************************************//
			If aParam[2]='001'
				
				cQuery := "SELECT ALX_REGRA,ALX_TIPOPL,ALX_FILTRO,MAX(R_E_C_N_O_) R_E_C_N_O_ "
				cQuery += "FROM " + RetSqlName("ALX") + " "
				cQuery += "WHERE ALX_FILIAL='" + xFilial("ALX") + "' AND ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' AND ALX_FILTRO<>'#' AND "
				cQuery += "ALX_AGREG='" + aParam[1] + "' AND "
				cQuery += "D_E_L_E_T_=' ' AND "
				cQuery += "ALX_TIPOPL IN (" + cTpPLans + ") "
				cQuery += "GROUP BY ALX_TIPOPL,ALX_REGRA,ALX_FILTRO ORDER BY R_E_C_N_O_"
				
				aCpos := {"ALX_REGRA","ALX_TIPOPL","ALX_FILTRO"}
				If ExistBlock("PCOXPNJ1")
					If VALTYPE(aCposUsr := ExecBlock("PCOXPNJ1"))="A"
						aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
					EndIf
				EndIf
				aHeaderReg := GetaHeader("ALX",aCpos)
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_TIPOPL'	}),11] := STR0108 //"001=Receita Direta;002=Receita Relac.;003=Mov. Relac.;004=Custo Direto;501=Contra-Partida;501=Contra-Partida;901=Reajuste de Receita;904=Reajuste de Custo"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_REGRA'	}),14] := "A"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_FILTRO'	}),14] := "A"
				
			ElseIf aParam[2]='009'
				
				cQuery := "SELECT ALX_CODIGO,ALX_REGRA,ALX_TIPOPL,ALX_FILTRO,MAX(R_E_C_N_O_) R_E_C_N_O_ "
				cQuery += "FROM " + RetSqlName("ALX") + " "
				cQuery += "WHERE ALX_FILIAL='" + xFilial("ALX") + "' AND ALX_PLANEJ='" + ALV->ALV_CODIGO + "' AND ALX_VERSAO='" + _cVerPlan + "' AND ALX_FILTRO<>'#' AND "
				cQuery += "ALX_AGREG='" + aParam[1] + "' AND "
				cQuery += "D_E_L_E_T_=' ' AND "
				cQuery += "ALX_TIPOPL IN (" + cTpPLans + ") "
				cQuery += "GROUP BY ALX_CODIGO,ALX_TIPOPL,ALX_REGRA,ALX_FILTRO ORDER BY R_E_C_N_O_"
				
				aCpos := {"ALX_REGRA","ALX_TIPOPL","ALX_CODIGO","ALX_FILTRO"}
				If ExistBlock("PCOXPNJ1")
					If VALTYPE(aCposUsr := ExecBlock("PCOXPNJ1"))="A"
						aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
					EndIf
				EndIf
				aHeaderReg := GetaHeader("ALX",aCpos)
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_TIPOPL'	}),11] := STR0109 //"009=Salario;010=Outras;909=Reajuste"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_REGRA'	}),14] := "A"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_CODIGO'	}),14] := "V"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_CODIGO'	}),01] := STR0110 //"Verba"
				aHeaderReg[aScan(aHeaderReg,{|x|ALLTRIM(x[2])=='ALX_FILTRO'	}),14] := "A"
				
			EndIf
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPREG", .T., .T. )
			aColsReg 	:= {}
			
			If TMPREG->(Eof())
				
				aAdd(aColsReg,Array(Len(aHeaderReg) + 1))
				AEval(aHeaderReg, {|x,y| aColsReg[Len(aColsReg)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL, CriaVar(AllTrim(x[2])) ) })
				aColsReg[Len(aColsReg),Len(aHeaderReg)+1] := .F.
				
			EndIf
			
			While !TMPREG->(Eof())
				
				// Retira os reajustes que nใo tem mais utilidade
				If SubStr(TMPREG->ALX_TIPOPL,1,1)=="9" .and. Len(aColsReg)=0 .and. !lManual
					
					// Deleta historico de reajustes anteriores.
					DbSelectArea("ALX")
					DbGoTo(TMPREG->R_E_C_N_O_)
					If TMPREG->R_E_C_N_O_==RECNO()
						
						RecLock("ALX",.F.)
						DbDelete()
						MsUnlock()
						
					EndIf
					
				Else
					
					aAdd(aColsReg,Array(Len(aHeaderReg) + 1))
					AEval(aHeaderReg, {|x,y| aColsReg[Len(aColsReg)][y] := If(Alltrim(x[2])$"ALX_ALI_WT|ALX_REC_WT",NIL, &('TMPREG->'+x[2]) ) })
					aColsReg[Len(aColsReg),Len(aHeaderReg)+1] := .F.
					
				EndIf
				TMPREG->(DbSkip())
				
			End
			TMPREG->(DbCloseArea())
			
			oGtdRegra := MsNewGetDados():New(40,5,135,285,7,,,,,,,,,,oWizard:oMPanel[oWizard:nPanel],aHeaderReg,aColsReg)
			
		Else
			
			oGtdRegra:aCols 	:= aColsReg
			oGtdRegra:aHeader   := aHeaderReg
			oGtdRegra:Refresh()
			
		EndIf
		
	Case nWin==4
		
		// Grava aCols do GetDados de Regras Aplicadas
		If oGtdRegra<>nil
			
			aColsReg	:= oGtdRegra:aCols
			aHeaderReg	:= oGtdRegra:aHeader
			
		EndIf
		
		aParam := {}
		aConfigs := {1,"   ",2,2}
		aAdd(aParam,{ 3, STR0007 , 1 		,{ STR0008 ,STR0009 }	,50		,""	,.F.}) //"Tipo de Valor (Receita)"###"Custo Standard"###"Pre็o Venda"
		aAdd(aParam,{ 1, STR0010 , SPACE(3)	,"@S3","Vazio() .or. ExistCpo('DA0')"	, "DA0", ".T."	,6	,.F.}) //"Tabela de Pre็o"
		aAdd(aParam,{ 3, STR0023 ,1,{ STR0024 , STR0025 },50,"",.F.}) //"Gera Custo da"###"Estrutura"###"Produto"
		aAdd(aParam,{ 3, STR0029 ,1,{ STR0008 , STR0030 , STR0031 },50,"",.F.}) //"Tipo de Valor (Custo)"###"Custo Standard"###"U.Pr.Compra"###"Custo M้dio"
		
		ParamBox(aParam 	, STR0055 , @aConfigs,,,.F.	,120,3	, oWizard:oMPanel[oWizard:nPanel],"PCOXPNJ_01",.F. ) //"Parametros"
		
	Case nWin==5
		
		If oMeter=nil
			
			//		oSayMet :=
			oMeter 	:= TMeter():New( 3, 3,{|| 0 },/*nTot*/ Len(aColsReg) + Len(aColsMan)  ,oWizard:oMPanel[oWizard:nPanel], 240, 20,,,,"Prompty",,,,,,)
			
		Else
			
			oMeter:SetTotal( Len(aColsReg) + 1 + Len(aColsMan) )
			
		EndIf
		
		
EndCase

Return

Static Function PcoRepMet(cId,aParam)

Local nX,nI,nY
Local cSeq
Local cAgreg
Local nCpSeq
Local nCpCod
Local nCpAgre
Local nCpVerba
Local nCpTipoPl



DbSelectArea("AM2")
DbSetOrder(3)
DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+aParam[1]+cId )
cAgreg := AM2->AM2_AGREG

PcoPnjDel("ALV",ALV->(Recno()),5,nil," ALX_FILTRO<>'#' AND ALX_AGREG='" + cAgreg + "' "," AM2_IDPAI='" + cId + "' ",.F.,.T.)
oMeter:Set( 1 )
oMeter:Refresh()
nCpSeq 		:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_SEQ'})
nCpCod 		:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_CODIGO'	})
nCpAgre 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_AGREG'	})
nCpTipoPl 	:= aScan(aHeaderMan,{|x|ALLTRIM(x[2])='ALX_TIPOPL'})

For nX := 1 To Len(aColsMan)
	
	cSeq := aColsMan[nX,nCpSeq]
	If aColsMan[nX,nCpTipoPl] == '001'
		
		DbSelectArea("AM2")
		DbSetOrder(3)
		DbSeek( xFilial("AM2")+ALV->ALV_CODIGO+_cVerPlan+'001'+cId )
		nPrecAgre := PcoPrcPlan(AM2->AM2_AGREG,"001", Alltrim(Str(aConfigs[1]))	, aConfigs[2] )
		lQtd := .T.
		
	ElseIf aColsMan[nX,nCpTipoPl] == '002'
		
		nPrecAgre := PcoPrcPlan(aColsMan[nX,nCpCod],"001", Alltrim(Str(aConfigs[1]))	, aConfigs[2] )
		lQtd := .T.
		
	ElseIf aColsMan[nX,nCpTipoPl] == '004'
		
		nPrecAgre := PcoPrcPlan(aColsMan[nX,nCpCod],"004", Alltrim(Str(aConfigs[4])) )
		lQtd := .T.
		
	ElseIf aColsMan[nX,nCpTipoPl] == '009'
	
		nPrecAgre := 0
		lQtd := .T.	

	Else
		
		nPrecAgre := 0
		lQtd := .F.
		
	EndIf
	
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
					If DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+cSeq+dTos(cTod(SubStr(_aListData[nY],1,10))))
						
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
						ALY_DTINI 		:= CTOD(Substr(_aListData[nY],1,10))
						ALY_DTFIM 		:= CTOD(Substr(_aListData[nY],14,10))
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

nCpTipoPl 	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='ALX_TIPOPL'	} )
nCpRegra	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='ALX_REGRA'	} )
nCpFiltro	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='ALX_FILTRO'	} )

If aParam[1]='009'
	
	nCpVerba	:= aScan( aHeaderReg , {|x|Alltrim(x[2])='ALX_CODIGO'	} )
	
EndIf

For nI := 1 To Len(aColsReg)
	
	If !aColsReg[ nI , Len(aHeaderReg) + 1 ]
		
		// ExecAuto de rotinas do planejamento
		
		If aColsReg[ nI , nCpTipoPl ]=='001'
			aValores := {}
			For nX := 1 To Len(_aListData)
				
				aAdd(aValores, &("M->DIS" + StrZero(nX,3) ) )
				
			Next
			aAuto := { aColsReg[ nI , nCpRegra ] , aConfigs[1]	, aConfigs[2] , aValores }
			PcoRunPlan(cId,'001',3,nil,nil,aAuto)
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='002'
			
			aAuto := { aColsReg[ nI , nCpRegra ] , aConfigs[1]	, aConfigs[2]	, '' }
			PcoRunPlan( cId , '002' , 3 , nil , aColsReg[ nI , nCpFiltro ] , aAuto)
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='003'
			
			aAuto := { aColsReg[ nI , nCpRegra ] , 2	, '' }
			PcoRunPlan( cId , '003' , 3 , nil , aColsReg[ nI , nCpFiltro ] , aAuto )
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='004'
			
			aAuto := { aConfigs[3]	, '' , '' , '' , aConfigs[4] }
			PcoRunPlan( cId , '004' , 3 , nil , aColsReg[ nI , nCpFiltro ] , aAuto )
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='501'
			
			PcoRunPlan( cId , {'501','502','503','504'} , 3 , nil , nil , NIL)
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='009'
			
			cFuncao := ''
			cCentroCusto := ''
			PcoCarCCFunc(oPlanej:GetTre("001"):GetCargo() , @cCentroCusto, @cFuncao)
			
			aValores := {}
			For nX := 1 To Len(_aListData)
				
				DbSelectArea("SRJ")
				DbSetOrder(1)
				DbSeek(xFilial("SRJ") + cFuncao )
				aAdd(aValores, {&("M->DIS" + StrZero(nX,3) ), DTOS(CTOD( Substr(_aListData[Nx],1,10) ) ) , DtoS(CtoD( Substr(_aListData[Nx],14,10)) ), SRJ->RJ_SALARIO * &("M->DIS" + StrZero(nX,3) ) } )
				
			Next
			
			Gera_Salario(cCentroCusto, cFuncao,,,,aValores, .T. )
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='010'
			
			cFuncao 		:= ''
			cCentroCusto 	:= ''
			cCargo 			:= oPlanej:GetTre("001"):GetCargo()
			
			PcoCarCCFunc(oPlanej:GetTre("001"):GetCargo() , @cCentroCusto, @cFuncao )

			dbSelectArea("AM2")
			dbSetorder(3)
			dbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"009"+SubStr(cCargo,4,Len(AM2->AM2_ID)) )

			PcoGerVerba( aColsReg[ nI , nCpVerba ] , cCentroCusto, cFuncao, )
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='901'
			
			
			PcoPnjAlt(nil , nil , StrArray( aColsReg[ nI , nCpFiltro ] ) , {'001','002'} )
			
		ElseIf aColsReg[ nI , nCpTipoPl ]=='904'
			
			
			PcoPnjAlt(nil , nil , StrArray( aColsReg[ nI , nCpFiltro ] ) , {'004'} )

		ElseIf aColsReg[ nI , nCpTipoPl ]=='909'
			
			
			PcoPnjAlt(nil , nil , StrArray( aColsReg[ nI , nCpFiltro ] ) , {'009'} )
			
		EndIf
		
	EndIf
	oMeter:Set( nX + 1 + nI )
	oMeter:Refresh()
	
Next

Return .T.

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoReprcALY บAutor ณ Acacio Egas       บ Data ณ  05/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Consulta da ALY no reprocessamento.              บฑฑ
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
		aAdd(aListVeri,Alltrim(Substr(_aListData[Nx],1,10)))
		
	Next
	
Else
	
	For Nx := 1 to Len(_aListData)
		
		aAdd(aListVeri,Alltrim(Substr(_aListData[Nx],1,10)))
		
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
		cQuery += "WHERE ALY_DTINI >= '" + DTOS(CTOD(Substr(_aListData[1],1,10))) + "' AND ALY_DTFIM <= '"
		cQuery += DTOS(CTOD(Substr(_aListData[Len(_aListData)],14,10))) + " ' "
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoSxbRegr บAutor ณ Acacio Egas        บ Data ณ  05/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Colsuta padrใo dos filtros do planejamento.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoFilALX()

Local cRet
Local _cFilALX := ''
Local cTipoPl := aCols[n,1]

If SubStr(cTipoPl,1,1) <> "9"
	
	cRet := BuildExpr("ALX", , aCols[n,3], /*lTopFilter*/, /*bOk*/, /*oDlg*/, /*aUsado*/, /*cDesc*/, /*nRow*/, /*nCol*/, /*aCampo*/, /*lVisibleTopFilter*/, /*lExpBtn*/, /*cTopFilter*/ )
	
	_cFilALX := PcoParseFil( cRet , "ALX" )
	
EndIf

Return .T.

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoSxbRegr บAutor ณ Acacio Egas        บ Data ณ  05/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Colsuta padrใo de todas as Regras do           บฑฑ
ฑฑบ          ณ  planejamento.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoSxbRegr()

Local cAliasReg := ''
Local cTipoPl := aCols[n,1]

Do Case
	
	Case cTipoPl=='001'
		
		cAliasReg := 'ALS'
		
	Case cTipoPl=='002'
		
		cAliasReg := 'ALR'
		
	Case cTipoPl=='003'
		
		cAliasReg := 'AM5'
		
	Case cTipoPl=='004'
		
		cAliasReg := ''
		
EndCase

If !Empty(cAliasReg)
	
	lRet := ConPad1( , , ,cAliasReg,/*cCampoRet*/,/*lGet*/,/*lOnlyView*/,/*cVar*/,/*oGet*/, /*uContent*/)
	
Else
	
	Aviso( STR0001 , STR0111 ,{ STR0014 }) //"Aten็ใo!"###"Este Tipo de planejamento nใo utiliza regra!"###"OK"
	lRet := .T.
	
EndIf

Return lRet
/*
ROTINA QUE DEVERAO SER PASSADAS PARA PCOXPNJ
*/

Function PcoRatALX(oGtdALX)
Local lContinua := .F.
Local cCodRateio := ""
Local aRecCTQ := {}
Local aDadosALX := {}
Local lAllLinhas := .F.
Local nX

lContinua := PcoParRateio( @cCodRateio, @aRecCTQ, @lAllLinhas )

If lContinua
	
	If ! lAllLinhas
		
		PcoCarDadALX( aDadosALX, oGtdALX )
		
		PcoProcRat( cCodRateio, aRecCTQ, aDadosALX )
		
	Else
		
		For nX := 1 TO Len(oGtdALX:aCols)
			
			aDadosALX := {}
			
			PcoCarDadALX( aDadosALX, oGtdALX, nX )
			
			PcoProcRat( cCodRateio, aRecCTQ, aDadosALX )
			
		Next
		
	EndIf
	
EndIf

Return


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoParRateioบAutor  ณPaulo Carnelossi  บ Data ณ  08/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de rateio do planejamento.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoParRateio( cCodRateio, aRecCTQ, lAllLinhas )
Local lContinua := .F.
Local cQuery
Local aConfig := {}

If ParamBox({ 	{ 1, STR0112 , SPACE(Len(CTQ->CTQ_RATEIO)), "@!", "ExistCpo('CTQ')", "CTQ", ".T.", 60, .F.	}, ;
	{ 3, STR0113 ,2,{ STR0083 , STR0084 },40,,.F.} },;
	STR0114 ,aConfig,,,,,,,"PCOARATALX",,.T.)
	//"Codigo Rateio"
	//"Ratear Todas as Linhas"###"Sim"###"Nao"
	//"Rateio do Movimento de Planejamento"
	
		
	cQuery := " SELECT * FROM  " + RetSqlName("CTQ")
	cQuery += " WHERE "
	cQuery += " CTQ_FILIAL = '"+xFilial("CTQ")+"' "
	cQuery += " AND CTQ_RATEIO = '"+ aConfig[1] +"' "
	cQuery += " AND D_E_L_E_T_ =  ' '"
	cQuery += " ORDER BY CTQ_SEQUEN"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )
	
	dbSelectArea("TMPAUX")
	dbGoTop()
	
	If ! Eof()
		cCodRateio := TMPAUX->CTQ_RATEIO
		While ! Eof()
			aAdd(aRecCTQ, TMPAUX->R_E_C_N_O_ )
			dbSkip()
		End
		lContinua := .T.
		lAllLinhas := ( aConfig[2] == 1 )
	EndIf
	
	dbSelectArea("TMPAUX")
	dbCloseArea()
	
EndIf

Return lContinua

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoCarDadALXบAutor  ณPaulo Carnelossi  บ Data ณ  08/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de rateio do planejamento.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoCarDadALX( aDadosALX, oGtdALX, nLin )
Local nX
Local aCols  := {}
Default nLin := 0

If Valtype(oGtdALX) == "O"
	If "MSNEWGETDADOS" $ UPPER(oGtdALX:cClassName)	
   		aCols := aClone(oGtdALX:aCols)
	 	nLin := IiF(nLin == 0, oGtdALX:oBrowse:nAt, nLin)
	
		For nX := 1 TO Len(oGtdALX:aHeader)
			aAdd(aDadosALX, { oGtdALX:aHeader[nX,2], aCols[nLin, nX] } )
		Next
	EndIf
EndIf
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoProcRat  บAutor  ณPaulo Carnelossi  บ Data ณ  08/14/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de processamento do rateio de planejamento.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoProcRat( cCodRateio, aRecCTQ, aDadosALX )
Local cSequencia
Local nPosSequen
Local nRecALX := 0
Local aRecALY := {}
Local lContinua := .F.

nPosSequen := aScan(aDadosALX, {|x| Alltrim(x[1]) == "ALX_SEQ"} )

If nPosSequen > 0 .And. ! Empty( aDadosALX[ nPosSequen, 2 ] )
	
	cSequencia := aDadosALX[ nPosSequen, 2 ]
	
	PcoBuscaALX(cSequencia, @nRecALX, aRecALY)
	
	If nRecALX > 0
		dbSelectArea("ALX")
		dbGoto(nRecALX)
		
		lContinua := Empty(ALX->ALX_SEQRAT)
		
		If ! lContinua .And. ;
			Aviso( STR0001 , STR0115 , { STR0083 , STR0084 }) == 1 //"Atencao"###"Rateio existente para este movimento. Ratear Novamente ? "###"Sim"###"Nao"
			//exclui o rateio
			PcoDelRateio(nRecALX)
			dbSelectArea("ALX")
			dbGoto(nRecALX)
			RecLock("ALX",.F.)
			ALX_CODRAT := ""
			ALX_SEQRAT := ""
			MsUnlock()
			lContinua := .T.
		EndIf
		
		If lContinua
			PcoPnjRateio( cCodRateio, aRecCTQ, nRecALX, aRecALY )
		EndIf
		
	Else
		
		Alert( STR0116 ) //"Erro - Verifique a base de dados. [ Tabela ALX ]"
		
	EndIf
	
Else
	
	Alert( STR0117 ) //"O campo sequencia nใo foi encontrado!"
	
EndIf

Return


Function PcoPnjRateio( cCodRateio, aRecCTQ, nRecALX, aRecALY )
Local nBase, cConta, cCenCusto, cItCtb, cClasseVlr
Local cConta_Partida, cCCust_Partida, cItCtb_Partida, cClVlr_Partida
Local cConta_CtPart, cCCust_CtPart, cItCtb_CtPart, cClVlr_CtPart, nBaseCtPart, cUM_CtPart, nValorCtPart
Local aLog, cAlertDiverg
Local lContinua := .T.
Local cSeqPartida, aALXOrigem, aALXPartida
Local cSeqCtPartida
Local cSeqOri
Local nX
Local aALX_CtPart


//rateio baseado no array de recnos do CTQ
If Len(aRecCTQ) > 0
	dbSelectArea("CTQ")
	dbGoto( aRecCTQ[1] ) //pegar sempre o primeiro para cabecalho do rateio
	
	nBase 		:= CTQ->CTQ_PERBAS / 100
	cConta 		:= CTQ->CTQ_CTORI
	cCenCusto 	:= CTQ->CTQ_CCORI
	cItCtb 		:= CTQ->CTQ_ITORI
	cClasseVlr 	:= CTQ->CTQ_CLORI
	
	//verifica se ALX posicionado combina com dados do rateio - cConta, cCenCusto, cItCtb, cClasseVlr
	dbSelectArea("ALX")
	dbGoto( nRecALX )
	aLog := {}
	If Alltrim(ALX->ALX_CO) != Alltrim(cConta)
		aAdd(aLog, STR0118 + ALX->ALX_CO + STR0119 + cConta + " ") //"Conta Orcamentaria : "###"  Rateio - Conta : "
	EndIf
	If Alltrim(ALX->ALX_CC) != Alltrim(cCenCusto)
		aAdd(aLog, STR0120 + ALX->ALX_CC + STR0121 + cCenCusto + " ") //"Centro de Custo  : "###"  Rateio - Centro Custo : "
	EndIf
	If Alltrim(ALX->ALX_ITCTB) != Alltrim(cItCtb)
		aAdd(aLog, STR0122 + ALX->ALX_ITCTB + STR0123 + cItCtb + " ") //"Item Contabil : "###"  Rateio - Item Contabil : "
	EndIf
	If Alltrim(ALX->ALX_CLVLR) != Alltrim(cClasseVlr)
		aAdd(aLog, STR0124 + ALX->ALX_CLVLR + STR0125 + cClasseVlr + " ") //"Classe de Valor : "###"  Rateio - Classe de Valor : "
	EndIf
	
	If ! Empty(aLog)
		
		cAlertDiverg := STR0126 +CHR(13)+CHR(10) //"Encontradas as seguintes ocorrencias no movimento (ALX) com relacao ao rateio: "
		For nX := 1 TO Len(aLog)
			cAlertDiverg += Str(nX, 1)+") "+aLog[nX]+CHR(13)+CHR(10)
		Next  //nx
		cAlertDiverg += STR0127 //"Prossegue o Rateio ou Cancela ? "
		
		If Aviso( STR0128 , cAlertDiverg,{ STR0129 , STR0005 },3, STR0130 ) == 2 //"Atencao"###"Ratear"###"Cancelar"###"Divergencias"
			lContinua := .F.
		EndIf
		
	EndIf
	
	If lContinua
		//se nao ocorrer divergencias procede o rateio
		cConta_Partida	:= CTQ->CTQ_CTPAR
		cCCust_Partida 	:= CTQ->CTQ_CCPAR
		cItCtb_Partida 	:= CTQ->CTQ_ITPAR
		cClVlr_Partida 	:= CTQ->CTQ_CLPAR
		
		aALXPartida 	:= {}
		
		If ! Empty(cConta_Partida)
			aAdd(aALXPartida, {"ALX_CO", cConta_Partida } )
		EndIf
		
		If ! Empty(cCCust_Partida)
			aAdd(aALXPartida, {"ALX_CC", cCCust_Partida } )
		EndIf
		
		If ! Empty(cItCtb_Partida)
			aAdd(aALXPartida, {"ALX_ITCTB", cItCtb_Partida } )
		EndIf
		
		If ! Empty(cClVlr_Partida)
			aAdd(aALXPartida, {"ALX_CLVLR", cClVlr_Partida } )
		EndIf
		
		dbSelectArea("ALX")
		dbGoto( nRecALX )
		cSeqOri := ALX->ALX_SEQ
		
		aALXOrigem 		:= {}
		For nX := 1 TO ALX->(FCOUNT())
			aAdd(aALXOrigem, { Alltrim(FieldName(nX)), FieldGet(nX) } )
		Next //nX
		
		//adiciona ALX referente a partida do rateio
		//alem dos campos acima pegar o restante do lancamento original
		cSeqPartida := PcoAddALX(aALXOrigem, aALXPartida, cCodRateio, cSeqOri , .T.)
		
		//adiciona ALY referente a partida do rateio
		//para tanto utilizara a variavel nbase com relacao ao ALY Original
		PcoAddALY(cSeqPartida, aRecALY, nBase)
		
		//atualiza o recno do alx original
		dbSelectArea("ALX")
		dbGoto( nRecALX )
		RecLock("ALX",.F.)
		ALX_CODRAT := cCodRateio
		ALX_SEQRAT := cSeqPartida   //Grava neste campo a Sequencia da Partida
		MsUnlock()
		
		//adiciona a contra - partida do rateio
		For nX := 1 TO Len(aRecCTQ)
			
			dbSelectArea("CTQ")
			dbGoto( aRecCTQ[nX] )
			
			cConta_CtPart	:= CTQ->CTQ_CTCPAR
			cCCust_CtPart 	:= CTQ->CTQ_CCCPAR
			cItCtb_CtPart 	:= CTQ->CTQ_ITCPAR
			cClVlr_CtPart 	:= CTQ->CTQ_CLCPAR
			nBaseCtPart 	:= CTQ->CTQ_PERCEN / 100
			cUM_CtPart      := CTQ->CTQ_UM
			nValorCtPart 	:= CTQ->CTQ_VALOR
			
			aALX_CtPart 	:= {}
			
			If ! Empty(cConta_CtPart)
				aAdd(aALX_CtPart, {"ALX_CO", cConta_CtPart } )
			EndIf
			
			If ! Empty(cCCust_CtPart)
				aAdd(aALX_CtPart, {"ALX_CC", cCCust_CtPart } )
			EndIf
			
			If ! Empty(cItCtb_CtPart)
				aAdd(aALX_CtPart, {"ALX_ITCTB", cItCtb_CtPart } )
			EndIf
			
			If ! Empty(cClVlr_CtPart)
				aAdd(aALX_CtPart, {"ALX_CLVLR", cClVlr_CtPart } )
			EndIf
			
			//adiciona ALX Referente a contra-partida do rateio
			cSeqCtPartida := PcoAddALX(aALXOrigem, aALX_CtPart, cCodRateio, cSeqOri, .F. )
			
			//adiciona ALY referente a contra-partida do rateio
			PcoAddALY( cSeqCtPartida, aRecALY, nBase*nBaseCtPart )
			
		Next // nX
		
	EndIf
	
EndIf

Return

Function PcoAddALX(aOrigem, aSubsOrig, cCodRateio, cSeqOrigem , lContraPat )
Local cSequencia
Local nX
Local nPosCpo

//gera ALX
cSequencia := PcoALXSeq()

aAdd(aSubsOrig,  { "ALX_SEQ", cSequencia } )
aAdd(aSubsOrig,  { "ALX_CODRAT", cCodRateio } )
aAdd(aSubsOrig,  { "ALX_SEQRAT", cSeqOrigem } )
aAdd(aSubsOrig,  { "ALX_TIPOPL", RATEIO_ALX } )

dbSelectArea("ALX")

Reclock("ALX",.T.)
For nX := 1 TO Len(aOrigem)
	
	If ( nPosCpo := FieldPos( aOrigem[nX, 1] ) ) > 0
		FieldPut(nPosCpo, aOrigem[nX, 2] )
	EndIf
	
Next

For nX := 1 TO Len(aSubsOrig)
	If ( nPosCpo := FieldPos( aSubsOrig[nX, 1] ) ) > 0
		FieldPut(nPosCpo, aSubsOrig[nX, 2] )
	EndIf
Next

If lContraPat
	
	ALX->ALX_TIPO := If( ALX->ALX_TIPO=='1' , '2' , '1' ) // Contra partida com Tipo invertido
	
EndIf
MsUnlock()

Return(cSequencia)


Function PcoAddALY(cSequencia, aRecALY, nBase)
Local nX, nY
Local aDataALY

For nX := 1 TO Len(aRecALY)
	dbSelectArea("ALY")
	dbGoto( aRecALY[nX] )
	
	aDataALY := {}
	For nY := 1 TO FCOUNT()
		
		//substitui a sequencia / quantidade / valor
		If Alltrim(FieldName(nY)) == "ALY_SEQ"
			aAdd(aDataALY, { Alltrim(FieldName(nY)), cSequencia } )
			
		ElseIf Alltrim(FieldName(nY)) == "ALY_QUANT"
			aAdd(aDataALY, { Alltrim(FieldName(nY)), FieldGet(nY)*nBase } )
			
		ElseIf Alltrim(FieldName(nY)) == "ALY_VALOR"
			aAdd(aDataALY, { Alltrim(FieldName(nY)), FieldGet(nY)*nBase } )
			
		Else
			
			aAdd(aDataALY, { Alltrim(FieldName(nY)), FieldGet(nY) } )
			
		EndIf
		
	Next  //nY
	
	dbSelectArea("ALY")
	Reclock("ALY",.T.)
	For nY := 1 TO FCOUNT()
		
		If ( nPosCpo := FieldPos( aDataALY[nY, 1] ) ) > 0
			FieldPut(nPosCpo, aDataALY[nY, 2] )
		EndIf
		
	Next //nY
	
	MsUnlock()
	
Next  //nX

Return

Function PcoBuscaALX(cSequencia, nRecALX, aRecALY, cCodPlan)
Local cQuery

Default cCodPlan := ALV->ALV_CODIGO
cQuery := " SELECT * FROM  " + RetSqlName("ALX")
cQuery += " WHERE "
cQuery += " ALX_FILIAL = '" + xFilial("ALX") + "' "
cQuery += " AND ALX_SEQ = '"+ cSequencia +"' " 
cQuery += " AND ALX_PLANEJ = '" + cCodPlan +"'"
cQuery += " AND D_E_L_E_T_ =  ' '"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALX", .T., .T. )

dbSelectArea("TMPALX")
dbGoTop()

If ! Eof()
	nRecALX := TMPALX->R_E_C_N_O_
	
	aRecALY := {}
	
	cQuery := " SELECT * FROM  " + RetSqlName("ALY")
	cQuery += " WHERE "
	cQuery += " ALY_FILIAL = '" + xFilial("ALY") + "' "
	cQuery += " AND ALY_PLANEJ = '"+ ALV->ALV_CODIGO +"' "
	cQuery += " AND ALY_VERSAO = '"+ _cVerPlan +"' "
	cQuery += " AND ALY_SEQ = '"+ cSequencia +"' "
	cQuery += " AND D_E_L_E_T_ =  ' '"
	cQuery += " ORDER BY ALY_DTINI "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALY", .T., .T. )
	
	dbSelectArea("TMPALY")
	dbGoTop()
	
	If ! Eof()
		While ! Eof()
			aAdd(aRecALY, TMPALY->R_E_C_N_O_ )
			dbSelectArea("TMPALY")
			dbSkip()
		End
	EndIf
	
	dbSelectArea("TMPALY")
	dbCloseArea()
	
EndIf

dbSelectArea("TMPALX")
dbCloseArea()

Return

Function PcoDelRateio(nRecALX)
Local cSeqOri
Local cQuery

dbSelectArea("ALX")
dbGoto(nRecALX)
cSeqOri := ALX->ALX_SEQ

cQuery := " SELECT * FROM  " + RetSqlName("ALX")
cQuery += " WHERE "
cQuery += " ALX_FILIAL = '" + xFilial("ALX") + "' "
cQuery += " AND ALX_PLANEJ = '" + ALV->ALV_CODIGO + "'"
cQuery += " AND ALX_SEQRAT = '"+ cSeqOri +"' "
cQuery += " AND ALX_TIPOPL = '"+ RATEIO_ALX +"' "
cQuery += " AND D_E_L_E_T_ =  ' '"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALX", .T., .T. )

dbSelectArea("TMPALX")
dbGoTop()

While ! Eof()
	
	cQuery := " SELECT * FROM  " + RetSqlName("ALY")
	cQuery += " WHERE "
	cQuery += " ALY_FILIAL = '" + xFilial("ALY") + "' "
	cQuery += " AND ALY_PLANEJ = '"+ ALV->ALV_CODIGO +"' "
	cQuery += " AND ALY_VERSAO = '"+ _cVerPlan +"' "
	cQuery += " AND ALY_SEQ = '"+ TMPALX->ALX_SEQ +"' "
	cQuery += " AND D_E_L_E_T_ =  ' '"
	cQuery += " ORDER BY ALY_DTINI "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPALY", .T., .T. )
	
	dbSelectArea("TMPALY")
	dbGoTop()
	
	While ! Eof()
		
		dbSelectArea("ALY")
		dbGoto(TMPALY->R_E_C_N_O_)
		
		PcoDetLan("000358","01","PCOXPNJ",.T.)

		RecLock("ALY",.F.)
		dbDelete()
		MsUnlock()
		
		dbSelectArea("TMPALY")
		dbSkip()
		
	End
	
	dbSelectArea("TMPALY")
	dbCloseArea()
	
	dbSelectArea("ALX")
	dbGoto(TMPALX->R_E_C_N_O_)
	
	RecLock("ALX",.F.)
	dbDelete()
	MsUnlock()
	
	
	dbSelectArea("TMPALX")
	dbSkip()
	
End

dbSelectArea("TMPALX")
dbCloseArea()

dbSelectArea("ALX")

Return


Function PcoTemRatALX(oGtdALX)
Local cSequencia
Local nPosSequen
Local nRecALX := 0
Local aRecALY := {}
Local lContinua := .F.
Local aDadosALX := {}
Local lRet := .F.

PcoCarDadALX( aDadosALX, oGtdALX )

nPosSequen := aScan(aDadosALX, {|x| Alltrim(x[1]) == "ALX_SEQ"} )

If nPosSequen > 0 .And. ! Empty( aDadosALX[ nPosSequen, 2 ] )
	
	cSequencia := aDadosALX[ nPosSequen, 2 ]
	// localiza na base de dados
	PcoBuscaALX(cSequencia, @nRecALX, aRecALY)
	
	If nRecALX > 0
		
		dbSelectArea("ALX")
		dbGoto(nRecALX)
		
		If ! Empty(ALX->ALX_SEQRAT) // se nao esta vazio o campo com a sequencia do rateio
			Aviso( STR0001 , STR0131 , { STR0014 }) //"Atencao"###"Rateio existente para este movimento. Nao e permitido a exclusao."###"OK"
			lRet := .T.
		EndIf
		
	EndIf
	
EndIf

Return(lRet)


Function PcoExclRatALX(oGtdALX)
Local cSequencia
Local nPosSequen
Local nRecALX := 0
Local aRecALY := {}
Local lContinua := .F.
Local aDadosALX := {}
Local lRet := .F.

If oGtdALX:cClassName == "MSNEWGETDADOS"
	PcoCarDadALX( aDadosALX, oGtdALX )
EndIf

nPosSequen := aScan(aDadosALX, {|x| Alltrim(x[1]) == "ALX_SEQ"} )

If nPosSequen > 0 .And. ! Empty( aDadosALX[ nPosSequen, 2 ] )
	
	cSequencia := aDadosALX[ nPosSequen, 2 ]
	// localiza na base de dados
	PcoBuscaALX(cSequencia, @nRecALX, aRecALY)
	
	If nRecALX > 0
		
		dbSelectArea("ALX")
		dbGoto(nRecALX)
		
		If Empty(ALX->ALX_SEQRAT)
			
			Aviso( STR0001 , STR0132 , { STR0014 }) //"Atencao"###"Rateio inexistente para este movimento. "###
			
		ElseIf ! Empty(ALX->ALX_SEQRAT) // se nao esta vazio o campo com a sequencia do rateio
			
			If Aviso( STR0001 , STR0133 , { STR0083 , STR0084 }) == 1 //"Atencao"###"Rateio existente para este movimento. Confirma a exclusao."#"Sim"###"Nao"
				PcoDelRateio(nRecALX)
				dbSelectArea("ALX")
				dbGoto(nRecALX)
				RecLock("ALX",.F.)
				ALX_CODRAT := ""
				ALX_SEQRAT := ""
				MsUnlock()
				lRet := .T.
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

Return(lRet)


Function PcoVisuRateioALX(oGtdALX)
Local cSequencia
Local nPosSequen
Local nRecALX := 0
Local aRecALY := {}
Local aDadosALX := {}
Local lContinua := .F.
Local nWidth  		:= GetScreenRes()[1] - 40
Local nHeight 		:= GetScreenRes()[2] - 200
Local _nContItem

Local cAgregador
Local cTipoPlan     := RATEIO_ALX
Local cSeekPartida
Local cSeekCtPartida

Local bEnchQtd 		:= {|| oRateio:GetMsm("003"):EnchRefreshAll(), oRateio:GetMsm("004"):EnchRefreshAll() }

Private oRateio

PcoCarDadALX( aDadosALX, oGtdALX )

nPosSequen := aScan(aDadosALX, {|x| Alltrim(x[1]) == "ALX_SEQ"} )

If nPosSequen > 0 .And. ! Empty( aDadosALX[ nPosSequen, 2 ] )
	
	cSequencia := aDadosALX[ nPosSequen, 2 ]
	
	PcoBuscaALX(cSequencia, @nRecALX, aRecALY)   //ALX posicionado na grade
	
	If nRecALX > 0
		dbSelectArea("ALX")
		dbGoto(nRecALX)
		
		lContinua := ! Empty(ALX->ALX_SEQRAT)
		cAgregador := ALX->ALX_AGREG
		cSeekPartida := " AND ALX_SEQ = '" + ALX->ALX_SEQRAT + "' "
		cSeekCtPartida := " AND ALX_SEQRAT = '" + ALX->ALX_SEQ + "' "
		cSeekCtPartida += " AND ALX_SEQ != '" + ALX->ALX_SEQRAT + "' "
		
	EndIf
	
EndIf

If ! lContinua
	Aviso( STR0001 , STR0134 , { STR0014 }) //"Atencao"###"Rateio nao existente. Verifique !"###"Rateio nao existente. Verifique !"###"OK"
	Return
EndIf

oRateio := PCOArea():New(0,0, nWidth, nHeight,"Rateio")

//Cria  Layouts para a Tela
oRateio:AddLayout( "Rateio" )

oRateio:AddWindow( 48, "WINRAT2", STR0136 , 2, .F., "Rateio" ) //"Rateio - Partida / Contra-Partida"

oRateio:AddWindow( 48, "WINRAT3", STR0137 , 1, .F., "Rateio" ) //"Valores do Rateio"

//-----------------------------------------------------------------------------------------------
// TELAS
//-----------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------
// Monta aHeader e aCols a ser utilizado na GetDados referente a Grupo de Verbas Saldarios
aCpos := {"ALX_CO","ALX_CC","ALX_CLASSE","ALX_OPER","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_TIPO","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOXPNJ3")
	If VALTYPE(aCposUsr := ExecBlock("PCOXPNJ3"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeader := GetAHeader("ALX",aCpos,)
aCols 	:= nil
// Cria GetDados da Tela
oRateio:AddGtD("001", STR0138 , "WINRAT2", "Rateio", aHeader, aCols, {|| PcoLoadALY(aDataPlnj, oRateio:GetGtd("001")), Eval(bEnchQtd)}, {|x|  }, {|x| } ) //"Partida"

//-------------------------------------------------------------------------------------------------
aCpos := {"ALX_CO","ALX_CC","ALX_CLASSE","ALX_OPER","ALX_ITCTB","ALX_CLVLR","ALX_SEQ","ALX_TIPO","ALX_REGRA","ALX_QTDTOT","ALX_VLTOT"}
If ExistBlock("PCOXPNJ4")
	If VALTYPE(aCposUsr := ExecBlock("PCOXPNJ4"))="A"
		aEval(aCposUsr , {|x| aAdd(aCpos , x ) } )
	EndIf
EndIf
aHeader := GetAHeader("ALX",aCpos,)
oRateio:AddGtD("002", STR0139 , "WINRAT2", "Rateio", aHeader, aCols, {|| PcoLoadALY(aDataPlnj, oRateio:GetGtd("002")), Eval(bEnchQtd)}, {|x|  }, {|x| } ) //"Contra-Partida"

//********************************************************
//  Gera Variaveis de Memoria para a MsmGetAutoContida   *
//********************************************************
// Gera variแveis para utiliza็ใo na MsMGet
_aGetValues := {}
_aGetQuants := {}
For _nContItem := 1 to Len(_aListData)
	_SetOwnerPrvt("VLR" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))
	_SetOwnerPrvt("QTD" + StrZero(_nContItem,3),CriaVar(Trim("ALY_VALOR"),.F.))
	// Criando campos para a MsmGet
	SX3->(DbSetOrder(2))
	SX3->( MsSeek( PadR("ALY_VALOR", 10 ) ) )
	ADD FIELD _aGetValues TITULO _aListData[_nContItem] CAMPO "VLR" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
	ADD FIELD _aGetQuants TITULO _aListData[_nContItem] CAMPO "QTD" + StrZero(_nContItem,3) TIPO SX3->X3_TIPO 	TAMANHO SX3->X3_TAMANHO DECIMAL SX3->X3_DECIMAL PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) VALID (SX3->X3_VALID) OBRIGAT NIVEL SX3->X3_NIVEL F3 SX3->X3_F3 BOX SX3->X3_CBOX FOLDER 1
Next
// Fim

//Cria MsmGet
oRateio:AddMsm("003", STR0140 ,"ALY",ALY->(Recno()),"WINRAT3", "Rateio", {|| PcoLoadALY(aDataPlnj,,)}, {|x| PcoLoadALY(aDataPlnj,,,.T.)}, _aGetQuants) //"Quantidades"
oRateio:AddMsm("004", STR0141 ,"ALY",ALY->(Recno()),"WINRAT3", "Rateio", {|| PcoLoadALY(aDataPlnj,,)}, {|x| PcoLoadALY(aDataPlnj,,,.T.)}, _aGetValues) //"Valores"

PcoFindALX(AM2->AM2_ID,cTipoPlan,oRateio:GetGtd("001"),cSeekPartida)

PcoFindALX(AM2->AM2_ID,cTipoPlan,oRateio:GetGtd("002"),cSeekCtPartida)

oRateio:Activate()

Return


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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

//-----------------------------------------------------------------------------------------------------------//

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณGera_Salario บAutor ณPaulo Carnelossi   บ Data ณ  08/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa que gera os movimentos na tabela ALX referente a  บฑฑ
ฑฑบ          ณ Grupo de Verbas SALARIOS que eh planejado no modulo SIGACSAบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gera_Salario(cCentroCusto, cFuncao, cPerIni, cPerFim, oGetDados, aValor , lAuto )

Local aArea 		:= GetArea()
Local cCodVerba 	:= ""
Local cQuery 		:= ""
Local lContinua		:= .T.
Local aConfig		:= Array(1)
Local cTipoForm, cFormRegr,cRegDist
Local cTmpArq

DEFAULT cCentroCusto 	:= ""
DEFAULT cPerIni 			:= DTOS(ALV->ALV_INIPER)
DEFAULT cPerFim 			:= DTOS(ALV->ALV_FIMPER)
DEFAULT oGetDados			:= oPlanej:GetGtd("001")
DEFAULT aValor				:= nil
Default lAuto				:= .F.

cCodVerba := PcoRetVerb()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
//ณValida็ใo de Parametros obrigatoriosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด

If Empty(cCodVerba) .or. Empty(cCentroCusto) .or. Empty(cPerIni) .or. Empty(cPerFim)
	
	lCOntinua	:= .F.
	
EndIf


If lContinua
	
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona tabela de Grupos de Verbaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ENDDOC*/
	
	dbSelectArea("AM3")
	dbSetOrder(1)
	
	If dbSeek(xFilial("AM3")+cCodVerba)
		
		cTipoForm := AM3->AM3_TPFORM
		cFormRegr := AM3->AM3_FORMUL
		
		If !lAuto
			
			If !ParamBox({ 	{ 1, STR0142 , AM3->AM3_REGPAD , "@!", "ExistCpo('ALS')", "ALS", ".T.", 60, .F.	}},	STR0143,aConfig) //"Regra de Distribui็ใo"###"Selecionar Regra de Disitrui็ใo"
				
				lContinua	:= .F.
				
			Else
				
				cRegDist := aConfig[1]
				
			EndIf
			
		Else
					
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida็ใo da Regra de Distribui็ใo ณ
			//ณpara rotina automatica             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			ENDDOC*/
			If !Empty(AM3->AM3_REGPAD)

				cRegDist := AM3->AM3_REGPAD

			Else

				Aviso( STR0001 , STR0144 ,{ STR0014 }) //"Aten็ใo"###"Nใo existe regra de distribui็ใo para a Verba Salario."###"OK"
				lContinua:= .F.

			EndIf
			
		EndIf
		
	Else
		
		Aviso( STR0001 , STR0145 ,{ STR0014 }) //"Aten็ใo"###"Favor preencher o parametro MV_PCOVSAL com a verba Salแrio."###"OK"
		lContinua := .F.
		
	EndIf
	
EndIf

If lContinua
	
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤศ็x่`r่`r(ฟ
	//ณMonta Parametro aValor caso o mesmo nใo tenha sido informadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤศ็x่`r่`r(ู
	//ENDDOC*/
	
	If aValor==nil
		
		DbSelectArea("AM2")
		DbSetOrder(2)
		DbSeek(ALV->ALV_FILIAL+ALV->ALV_CODIGO+_cVerPlan+"009"+cCentroCusto)
		
		cQuery += " SELECT RBD_CC, RBD_FUNCAO, RBD_ANOMES "	
		cQuery += " ,(SELECT MAX(AM2_ID) FROM " + RetSqlName("AM2") + " AM2 WHERE AM2_FILIAL='" + xFilial("AM2") + "' AND D_E_L_E_T_=' ' AND AM2_PLANEJ='" + ALV->ALV_CODIGO + "' AND AM2_VERSAO='" + _cVerPlan + "' AND AM2_IDPAI='" + AM2->AM2_ID + "' AND AM2_AGREG=RBD.RBD_FUNCAO) AM2_ID "
		
		If cParAprvAtu=="1"
			
			cQuery += ", SUM(RBD_QTATUA) ALY_QUANT"
			cQuery += ", SUM(RBD_VLATUA) ALY_VALOR"
			
		ElseIf cParAprvAtu=="2"
			
			cQuery += ", SUM(RBD_QTATUA + RBD_QTAPRO) ALY_QUANT" // Valor atual mais aprovado
			cQuery += ", SUM(RBD_VLATUA + RBD_VLAPRO) ALY_VALOR"
			
		ElseIf cParAprvAtu=="3"
			
			cQuery += ", SUM(RBD_QTPREV) ALY_QUANT"
			cQuery += ", SUM(RBD_VLPREV) ALY_VALOR"
			
		EndIf
		
		cQuery += " FROM  " + RetSqlName("RBD") + " RBD "
		cQuery += " WHERE "
		cQuery += " RBD_FILIAL = '"+xFilial("RBD")+"' "
		cQuery += " AND RBD_CC = '"+cCentroCusto+"' "
	
		If cFuncao <> nil
	
			cQuery += " AND RBD_FUNCAO = '"+cFuncao+"' "
	
		EndIf
	
		cQuery += " AND RBD_ANOMES BETWEEN '"+cPerIni+"' AND '"+cPerFim+"'"
		cQuery += " AND D_E_L_E_T_ =  ' '"
		
		cQuery += " GROUP BY RBD_CC,RBD_FUNCAO,RBD_ANOMES"
		cQuery += " ORDER BY RBD_CC,RBD_FUNCAO,RBD_ANOMES"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )
		
		dbSelectArea("TMPAUX")
		dbGoTop()
		
		If ! Eof()
			
			While !Eof()

				aValor := {}
				
				cFunc 	:= TMPAUX->RBD_FUNCAO
				DbSelectArea("AM2")
				DbSetOrder(3)
				DbSeek( xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan + '009' + TMPAUX->AM2_ID )

				While cFunc == TMPAUX->RBD_FUNCAO
			
					aAdd(aValor, { TMPAUX->ALY_QUANT, TMPAUX->RBD_ANOMES+"01", DTOS(LastDay(STOD(TMPAUX->RBD_ANOMES+"01"))), TMPAUX->ALY_VALOR } )
					
					dbSelectArea("TMPAUX")
					dbSkip()
					
				End
				
				If Len(aValor) > 0
			
			
					/*BEGINDOC
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGera combina็ใo de entidades de acordo ณ
					//ณcom a Regra de distribui็ใo            ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//ENDDOC*/
					
					// PROCESSA
					PcoGerComb(cRegDist,/*cEntiExcl*/,aValor,0/*nPrecAgre*/, /*lQtd*/,cCodVerba/*cCodigo*/,"1"/*cTipo*/,cCentroCusto/*cRegrFilt*/,@cTmpArq)
										
					dbSelectArea("TMPDIS")
					dbGoTop()
					
					If ! Eof()
										
						// PROCESSA
						PcoGrvPlan(AM2->AM2_ID, oGetDados, "TMPDIS", SALARIOPLJ, /*lQtd*/, ""/*cFiltroALX*/, .T./*lDelaCols*/, cTipoForm, cFormRegr, "1"/*cVlrCheio=="1"*/)
					
					Else
						
						Aviso( STR0001 , STR0146 + cCentroCusto + ".", { STR0014 }) //"Atencao"###"Nใo foi possํvel gerar conbina็ใo para o Centro de Custo:"###"Ok"
						dbCloseArea()
						
					EndIf
					
				EndIf	
				
				dbSelectArea("TMPAUX")
			
			End
			
			dbSelectArea("TMPAUX")
			dbCloseArea()

			If cTmpArq != NIL
				MsErase(cTmpArq)
			EndIf
			
		Else
			
			If !lAuto

				Aviso( STR0001 , STR0147 , { STR0014 }) //"Atencao"###"Nใo foram encontradas informa็๕es para este Centro de Custo e Fun็ใo no Modulo de CSA."###"Ok"

			EndIf
			dbSelectArea("TMPAUX")
			dbCloseArea()
			lContinua	:= .F.
			
		EndIf
		
	Else

		If Len(aValor) > 0
	
	
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGera combina็ใo de entidades de acordo ณ
			//ณcom a Regra de distribui็ใo            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//ENDDOC*/
			
			// PROCESSA
			PcoGerComb(cRegDist,/*cEntiExcl*/,aValor,0/*nPrecAgre*/, /*lQtd*/,cCodVerba/*cCodigo*/,"1"/*cTipo*/,cCentroCusto/*cRegrFilt*/,@cTmpArq)
						
			dbSelectArea("TMPDIS")
			dbGoTop()
			
			If ! Eof()
								
				// PROCESSA
				PcoGrvPlan(AM2->AM2_ID, oGetDados, "TMPDIS", SALARIOPLJ, /*lQtd*/, ""/*cFiltroALX*/, .T./*lDelaCols*/, cTipoForm, cFormRegr, "1"/*cVlrCheio=="1"*/)
			
			Else
				
				Aviso( STR0001 , STR0146 + cCentroCusto + ".", { STR0014 }) //"Atencao"###"Nใo foi possํvel gerar conbina็ใo para o Centro de Custo:"###"Ok"
				dbCloseArea()
				
			EndIf
			
			If cTmpArq != NIL
				MsErase(cTmpArq)
			EndIf

		EndIf	
			
	EndIf
	
EndIf

RestArea(aArea)

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoRetVerb   บAutor ณPaulo Carnelossi   บ Data ณ  08/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Grupo de verba correspondente a SALARIO registrado บฑฑ
ฑฑบ          ณ no Parametro MV_PCOVSAL                                    บฑฑ
ฑฑบ          ณ (se nao encontrar parametro avisa para incluir via         บฑฑ
ฑฑบ          ณ configurador)                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoRetVerb()

Local cCodGrVerba := ""

cCodGrVerba := GetMv("MV_PCOVSAL")

If Empty(cCodGrVerba)
	Aviso( STR0001 , STR0148 , { STR0014 }) //"Atencao"###"Cadastro de Grupo de Verbas referente a Salarios nใo encotrado! Utilize o Configurador para criar parametro tipo caracter contendo o Grupo de Verba."###"Ok"
EndIf

Return(cCodGrVerba)

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณGera_Outras  บAutor ณPaulo Carnelossi   บ Data ณ  08/04/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que gera Outras Verbas Salariais de acordo com o    บฑฑ
ฑฑบ          ณ identificador de grupo de verbas informado, conforme regra บฑฑ
ฑฑบ          ณ do relacionamento entre grupo de verbas                    บฑฑ
ฑฑบ          ณ Gera ALX e ALY para campo Valor                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Gera_Outras( cCentroCusto, cFuncao, cPerIni, cPerFim, oGetDados)

Local aArea 		:= GetArea()
Local aConfig		:= Array(1)
Local cQuery 		:= ""
Local lContinua		:= .T.
Local nPerc			:= 0
Local cGrpPai := ""
Local cCjt_Gr_Verba := ""
Local cFiltroSRJ := ''

DEFAULT cCentroCusto 	:= ""
DEFAULT cPerIni 			:= DTOS(ALV->ALV_INIPER)
DEFAULT cPerFim 			:= DTOS(ALV->ALV_FIMPER)

dbSelectArea("AM3")
dbSetOrder(1)
dbSelectArea("AM6")
dbSetOrder(1)
dbSelectArea("AM7")
dbSetOrder(1)

dbSelectArea("SRJ")

If !ParamBox({ 	{ 1 , STR0149 , SPACE(Len(AM7->AM7_IDGRUP)), "@!", "ExistCpo('AM7')", "AM7", ".T.", 60, .F.	}, ;
				{ 7 , STR0150 , "SRJ" , "" , If(cFuncao<>nil,".F.",".T.") } },;
	STR0151 ,aConfig,,,,,,,"PCOA496_03",,.T.)
	//"Roteiro Grupo Verba"###"Filtra Distribui็ใo"###"Selecionar Roteiro do Grupo de Verbas"
	
	lContinua := .F.
	
Else
	
	cIdGrVerba := aConfig[1]
	If cFuncao==nil
	
	cFiltroSRJ := aConfig[2]
	
	EndIf
	
EndIf

If lContinua

	If Empty(cIdGrVerba) .or. Empty(cCentroCusto) .or. Empty(cPerIni) .or. Empty(cPerFim)
		
		lContinua	:= .F.
		
	EndIf

EndIf

If lContinua
	
	If Empty(cFiltroSRJ)
	
		dbSelectArea("AM7")
		dbSetOrder(1)
		
		If dbSeek(xFilial("AM7")+cIdGrVerba)
			
			While AM7->(! Eof() .And. AM7_FILIAL + AM7_IDGRUP = xFilial("AM7") + cIdGrVerba )
				
				PcoGerVerba(AM7->AM7_GRUPO, cCentroCusto, cFuncao, cPerIni, cPerFim, oGetDados)
				
				dbSelectArea("AM7")
				AM7->( dbSkip() )
				
			End
			
		EndIf
	
	Else
	
		cIdPai := AM2->AM2_ID
		
		cQuery	:= "SELECT * "
		cQuery	+= "FROM " + RetSqlName("SRJ") + " SRJ  "
		cQuery	+= "RIGHT JOIN "
		cQuery	+= "(SELECT AM2_AGREG FROM " + RetSqlName("AM2") + " WHERE D_E_L_E_T_=' ' AND AM2_IDPAI='" + cIdPai + "' AND AM2_TIPOPL='009') AM2 "
		cQuery	+= "ON RJ_FUNCAO=AM2_AGREG AND SRJ.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSRJ", .T., .T. )
		
		DbSelectArea("TMPSRJ")
		DbGoTop()
		
		While !TMPSRJ->(Eof())
	
			DbSelectArea("TMPSRJ")
			If &(cFiltroSRJ)
				
				cQuery := "SELECT AM2_ID FROM " + RetSqlName("AM2") + " WHERE D_E_L_E_T_=' ' AND "
				cQuery += "AM2_FILIAL='" + xFilial("AM2") + "' AND AM2_IDPAI='" + cIdPai + "' AND "
				cQuery += "AM2_AGREG='" + TMPSRJ->RJ_FUNCAO + "' "
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPID", .T., .T. )
				DbGoTop()
				If !TMPID->(Eof())
				
					dbSelectArea("AM7")
					dbSetOrder(1)
					
					If dbSeek(xFilial("AM7")+cIdGrVerba)
						
						While AM7->(! Eof() .And. AM7_FILIAL + AM7_IDGRUP = xFilial("AM7") + cIdGrVerba )
												
							DbSelectArea("AM2")
							DbSetOrder(3)
							dbSeek( ALV->ALV_FILIAL + ALV->ALV_CODIGO + _cVerPlan + "009" + TMPID->AM2_ID )
								
							PcoGerVerba(AM7->AM7_GRUPO, cCentroCusto, TMPSRJ->RJ_FUNCAO, cPerIni, cPerFim, oGetDados)
												
							dbSelectArea("AM7")
							AM7->( dbSkip() )
							
						End
						
					EndIf
			
				EndIf
				
				TMPID->(DbCloseArea())
				
			EndIf
          
			TMPSRJ->(DbSkip())	

		End
	
		TMPSRJ->(DbCloseArea())    
	
	EndIf
	
EndIf

RestArea(aArea)

Return

Static Function PcoGerVerba(cGrpVerba, cCentroCusto, cFuncao, cPerIni, cPerFim, oGetDados)

Local nPerc,nX
Local lQuant,nPrcUnit
Local lContinua := .T.
Local cTmpArq
Local aValor := {}
DEFAULT cPerIni 			:= SubStr(DTOS(ALV->ALV_INIPER),1,6)
DEFAULT cPerFim 			:= DTOS(ALV->ALV_FIMPER)

dbSelectArea("AM3")
dbSetOrder(1)
If dbSeek(xFilial("AM3")+cGrpVerba) .And. !Empty(AM3->AM3_REGPAD) .and. AM3->AM3_PERC>0

	lQuant 		:= (AM3->AM3_TPVLR=='1')
	nPrcUnit    := AM3->AM3_VALOR
	nPerc 		:= AM3->AM3_PERC

Else

	lContinua	:= .F.

EndIf

If lContinua
	
	dbSelectArea("AM6")
	dbSetOrder(1)
	If dbSeek(xFilial("AM6")+cGrpVerba) //a funcao ParamIdGrupo ja posiciona na tabela AM7
		
		cGrpPai := AM6->AM6_GRPPAI
		
		cCjt_Gr_Verba := ""
		
		While AM6->( ! Eof() .And. AM6_GRPPAI == cGrpPai )
			cCjt_Gr_Verba += "'" + Alltrim(PadR( AM6->AM6_GRCOMP, Len(ALX->ALX_CODIGO)) ) + "' ,"
			AM6->( dbSkip() )
		End
		
		cCjt_Gr_Verba := "(" + Subs(cCjt_Gr_Verba, 1, Len(cCjt_Gr_Verba)-1) + ") "
		
		cQuery := " SELECT ALY_DTINI, ALY_DTFIM "
		If lQuant
			cQuery += ", SUM(ALY_QUANT)*"+Str(nPerc/100, 5, 2)+" ALY_QUANT "
			cQuery += ", ((SUM(ALY_QUANT)*"+Str(nPerc/100, 5, 2)+ ")*" + Str(nPrcUnit)  + ") ALY_VALOR "
		Else
			cQuery += ", 0 ALY_QUANT "
			cQuery += ", (SUM(ALY_VALOR)*"+Str(nPerc/100, 6, 4)+ ") ALY_VALOR "
		EndIf
		cQuery += " FROM  "
		cQuery += RetSqlName("ALX") + " ALX "
		cQuery += ", " + RetSqlName("ALY") + " ALY "
		cQuery += " WHERE "
		cQuery += " ALX.D_E_L_E_T_ =  ' ' AND "
		cQuery += " ALY.D_E_L_E_T_ =  ' ' AND "
		cQuery += " ALX_FILIAL = '" + xFilial("ALX") + "' AND ALY_FILIAL=ALX_FILIAL "
		cQuery += " AND ALX_PLANEJ = '" + ALV->ALV_CODIGO + "' AND ALY_PLANEJ=ALX_PLANEJ "
		cQuery += " AND ALX_VERSAO = '" + _cVerPlan + "' AND ALY_VERSAO=ALX_VERSAO "
		cQuery += " AND ALY_SEQ = ALX_SEQ "
		cQuery += " AND ALX_CC = '" + Alltrim(cCentroCusto) + "' "
		cQuery += " AND ALX_AGREG = '" + Alltrim(cFuncao) + "' "
		cQuery += " AND ALX_TIPOPL IN ('" + SALARIOPLJ + "', '" + OUTRASVPLJ + "') "
		cQuery += " AND ALX_CODIGO IN " + cCjt_Gr_Verba
		cQuery += " AND ALY_DTINI BETWEEN '" + cPerIni + "01" + "' AND '" + DTOS(LastDay(STOD(cPerFim+"01"))) + "' "
		cQuery += " GROUP BY ALY_DTINI, ALY_DTFIM "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )
		
		dbSelectArea("TMPAUX")
		dbGoTop()
		
		If ! Eof()

			aValor := {}	

			While ! Eof()
				
				aAdd(aValor, { TMPAUX->ALY_QUANT, TMPAUX->ALY_DTINI, TMPAUX->ALY_DTFIM, TMPAUX->ALY_VALOR } )
				
				dbSelectArea("TMPAUX")
				dbSkip()
				
			End
			
		Else
		
			lContinua	:= .F.
		
		EndIf

		dbSelectArea("TMPAUX")
		dbCloseArea()

	ElseIf !Empty(AM3->AM3_FORMUL)

		// Monta aValores com Zero
		aValor := {}
		For nX := 1 To Len(_aListData)
	
			aAdd(aValor, { 0, DTOS(CTOD(Substr(_aListData[nX],1,10))) , DTOS(CTOD(Substr(_aListData[nX],14,10))) } )
		
		Next

	EndIf			
	
	If lContinua
	
		PcoGerComb(AM3->AM3_REGPAD,/*cEntiExcl*/, aValor, AM3->AM3_VALOR/*nPrecAgre*/, (AM3->AM3_TPVLR=='1') /*lQtd*/, AM3->AM3_GRUPO/*cCodigo*/,"1"/*cTipo*/,cCentroCusto/*cRegrFilt*/,@cTmpArq)
		
		dbSelectArea("TMPDIS")
		dbGoTop()
		
		If ! Eof()
			
			PcoGrvPlan(AM2->AM2_ID, oGetDados, "TMPDIS", OUTRASVPLJ, (AM3->AM3_TPVLR=='1')/*lQtd*/, ""/*cFiltroALX*/, .T./*lDelaCols*/, AM3->AM3_TPFORM/*cTipoForm*/, AM3->AM3_FORMUL/*cFormRegr*/, "1"/*cVlrCheio=="1"*/)
			
		Else
			
			dbSelectArea("TMPDIS")
			dbCloseArea()
			
		EndIf
		
		If cTmpArq != NIL
			MsErase(cTmpArq)
		EndIf
		
	EndIf
	
EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoGerPnj บAutor  ณ Acacio Egas        บ Data ณ  06/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Gera็ใo da planilha or็amentแria.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoGerPnj(cAlias,nRecno,nOpcx,aCpos)

Local cQuery
Local cPlanej
Local aConfig := Array(5)
Local lRunRat
Local _nX
Local cPlntps := ''
Local aTpPlan := { {'001','002','003','004'} , {'005'} , {'006'} , {'009','010'} }
Local lContinua := .F.
Local nNiveEstr := 1
Local aEstrPlan := {}
Local nId,nX
Local nOpcExcl := 1

Private _cVerPlan
Private aCtaPlan

PcoIni_VarStatic()

DbSelectArea("ALV")
DbGoTo(nRecno)

cPlanej		:= ALV->ALV_CODIGO
_cVerPlan 	:= ALV->ALV_VERSAO

If ParamBox({ 	{ 5 , STR0152 ,.F.,90,,.F.},;
	{ 5 , STR0153 ,.F.,90,,.F.},;
	{ 5 , STR0154 ,.F.,90,,.F.},;
	{ 5 , STR0155 ,.F.,90,,.F.},;
	{ 3 , STR0156 ,2,{ STR0083 , STR0084 },40,,.F.} },;
	STR0157 ,aConfig,,,,,,,"PcoGerPnj",,.T.)	
    //"Gerar Receita"
    //"Gerar Despesa"
    //"Gerar Mov.nใo Oper."
    //"Gerar Folha de Pag."
    //"Controla Rateio"###"Sim"###"Nao"
    //"Gera็ใo da Planilha Or็amentaria"
    

	lRunRat	:= (aConfig[5]==1)
	
	For _nX := 1 To Len(aConfig)-1
		
		If aConfig[_nX]
			
			aEval( aTpPlan[_nX] , {|x| cPlntps += "'" + x + "'," } )
			lContinua := .T.
		
		EndIf
		
	Next

	If lRunRat
		
		cPlntps += "'011',"
		
	EndIf
	
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
			ElseIf  lDB2 .Or. lPostgre  
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
			ElseIf  lDB2 .Or. lPostgre  
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

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoBuscCtaSupe   บAutorณJoใo Gon็alves de Oliveira บ Data ณ 27/06/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina para busca da conta superior                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoBuscCtaSupe(ExpC1,ExpA1)                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Conta Or็amentแria a ser avaliada                           บฑฑ
ฑฑบ          ณ Expa1 - Vetor para grava็ใo da estrutura encontrada                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOBuscCtaSupe(cCtaOrca,aEstrPlan)

If AK5->(dbSeek(xfilial("AK5") + cCtaOrca))
	
	cCtaSupe := AK5->AK5_COSUP
	
	If ! Empty(cCtaSupe)
		
		dbSelectARea("AK3")
		dbSetOrder(2)
		
		If ! AK3->(dbSeek(xfilial("AK3") + ALV->ALV_CODIGO + _cVerPlan + cCtaSupe + cCtaOrca))
			
			aAdd(aEstrPlan,{cCtaOrca,cCtaSupe,AK5->AK5_TIPO,AK5->AK5_DESCRI})
			cCtaOrca := AK5->AK5_COSUP
			PcoBuscCtaSupe(cCtaOrca,aEstrPlan)
			
		EndIf
		
	Else
		
		dbSelectARea("AK3")
		dbSetOrder(2)
		If ! AK3->(dbSeek(xfilial("AK3") + ALV->ALV_CODIGO + _cVerPlan + PadR( ALV->ALV_CODIGO, Len(AK3->AK3_PAI)) + cCtaOrca	))
			
			aAdd(aEstrPlan,{cCtaOrca,ALV->ALV_CODIGO,AK5->AK5_TIPO,AK5->AK5_DESCRI})
			
		EndIf
		
	EndIf
	
EndIf
Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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

Function PCOExclOrca(cPlanOrca)

Local lContinua := .T.

dbSelectArea("AK1")
dbSetOrder(1)

If AK1->(dbSeek(xfilial("AK1") + cPlanOrca ))


	If AK1->AK1_STATUS=="2"
	
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
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PcoExclFunc      บAutorณJoใo Gon็alves de Oliveira บ Data ณ 04/07/08บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออฯอออออฯอออออฯอออนฑฑ
ฑฑบDescri็ใo ณ Rotina para exclusใo de dados de planejamento do centro de custo    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ PcoExclCust(ExpC1,ExpC2)                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetrosณ Expc1 - Identificador do n๓ onde estแ posicionado                   บฑฑ 
ฑฑบParโmetrosณ Expc2 - Tipo de Planejamento                                        บฑฑ
ฑฑบParโmetrosณ Expc3 - Objeto Getdados                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Planejamento e Controle Or็amentแrio                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoExclFunc(cId,cTipoPlan,oGetDados)

PcoIni_VarStatic()

cId := Substr(cId,4,Len(cId) - 3)

cQuery := "SELECT AM2_ID FROM " + RetSqlName("AM2") + " AM2 "
cQuery += " WHERE AM2_TIPOPL='"+cTipoPlan +"' " 
cQuery += " AND AM2.D_E_L_E_T_=' ' "
cQuery += "  AND AM2_IDPAI = '" + cId + "' "

If lOracle .Or. lInformix
	cQuery += " AND  NVL((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID = AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
ElseIf  lDB2 .Or. lPostgre  
	cQuery += " AND COALESCE((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID = AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
Else
	cQuery += " AND ISNULL((SELECT COUNT(*) FROM "+ RetSqlName("ALX") +" WHERE ALX_AM2ID = AM2.AM2_ID AND D_E_L_E_T_=' '),0)=0"
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPFIL", .T., .T. )

dbSelectARea("TMPFIL")
dbGoTop()
While ! TMPFIL->(Eof())
	PCODelPNJ(TMPFIL->AM2_ID,cTipoPlan,oGetDados)	
	TMPFIL->(dbSkip())		
End
TMPFIL->(dbCloseARea())

Return

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


/* Function PcoPnjIRev( cPlanilha , _cVerPlan , CRevisao )

Local lContinua := .T.
Local nY,nM,nX,nE
Local nRecAM2,nRecALX,nRecALY
Local bCampo 	:= {|n| FieldName(n) }
Local aAKE		:= {}
Local aALY		:= {}
Local aALX		:= {}
Local aAM2		:= {}

DbSelectArea("ALV")
DbSetOrder(1)
DbSeek( xFilial("ALV") + cPlanilha + _cVerPlan )

If !Empty(ALV->ALV_VERREV)

	Help("  ",1,"PCOA1201")
	lContinua := .F.

EndIf

If lContinua

	DbSelectArea("AM2")
	DbSetOrder(1)
	DbSeek( xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan)
	
	Do While !Eof() .and. xFilial("AM2") + ALV->ALV_CODIGO + _cVerPlan == AM2->AM2_FILIAL + AM2->AM2_PLANEJ + AM2->AM2_VERSAO
	    
		aAM2 := {}
		For nM := 1 To AM2->(Fcount())
			aAdd( aAM2 , FieldGet(nM) )
		Next
		nRecAM2 := Recno()
		RecLock( "AM2" , .T. )
		aEval( aAM2 , {|x,y| FieldPut( y , x ) } )
		AM2->AM2_VERSAO := CRevisao
		MsUnlock()

		DbSelectArea("ALX")
		DbSetOrder(3)
		DbSeek( xFilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + AM2->AM2_ID )
		Do While !Eof() .and. xFilial("ALX") + ALV->ALV_CODIGO + _cVerPlan + AM2->AM2_ID == ALX->ALX_FILIAL + ALX->ALX_PLANEJ + ALX->ALX_VERSAO + ALX->ALX_AM2ID

			aALX := {}
			For nX := 1 To ALX->(Fcount())
				aAdd( aALX , FieldGet( nX ) )
			Next
			nRecALX := Recno()
			RecLock( "ALX" , .T. )
			aEval( aALX , {|x,y| FieldPut( y , x ) } )
			ALX->ALX_VERSAO := CRevisao
			MsUnlock()
	
			DbSelectArea("ALY")
			DbSetOrder(1)
			DbSeek( xFilial("ALY") + ALV->ALV_CODIGO + _cVerPlan + ALX->ALX_SEQ )
			Do While !Eof() .and. xFilial("ALY") + ALV->ALV_CODIGO + _cVerPlan + ALX->ALX_SEQ == ALY->ALY_FILIAL + ALY->ALY_PLANEJ + ALY->ALY_VERSAO + ALY->ALY_SEQ
				aALY := {}
				For nY := 1 To ALY->(Fcount())
					aAdd( aALY , FieldGet(nY) )
				Next
				nRecALY := Recno()
				RecLock( "ALY" , .T. )
				aEval( aALY , {|x,y| FieldPut( y , x ) } )
				ALY->ALY_VERSAO := CRevisao
				MsUnlock()
				PcoDetLan("000358","02","PCOA100")
				DbSelectArea("ALY")
				DbGoTo(nRecALY)
				ALY->(DbSKip())		
			EndDo
			DbSelectArea("ALX")
			DbGoTo(nRecALX)
			ALX->(DbSKip())
		EndDo	

		DbSelectArea("AM2")
		DbGoTo(nRecAM2)
		AM2->(DbSkip())

	EndDo

	RecLock("AK1",.F.)
	AK1->AK1_VERREV	:= CRevisao
	AK1->AK1_STATUS := "2"
	MsUnlock()

	RecLock("AKE",.T.)
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AKE->AKE_FILIAL := xFilial("AKE")
	AKE->AKE_REVISA := AK1->AK1_VERREV
	MsUnlock()

	RecLock( "ALV" , .F. )
	ALV->ALV_VERREV := AK1->AK1_VERREV
	ALV->ALV_STATUS := "2"
	MsUnlock()
	
EndIf

Return */


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
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
	lInformix == NIL
	cTipoDB		:= Alltrim(Upper(TCGetDB()))
	cSrvType 	:= Alltrim(Upper(TCSrvType()))
	lOracle		:= "ORACLE"   $ cTipoDB
	lDB2		:= "DB2"      $ cTipoDB
	lInformix 	:= "INFORMIX" $ cTipoDB
    lPostgre  	:= "POSTGRES" $ cTipoDB
EndIf

Return


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXPNJ   บAutor  ณClovis Magenta		  บ Data ณ  29/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada pelo method Bt e Class PCOArea do fonte     บฑฑ
ฑฑบ          ณ PCOA491,onde terao as a็๕es de gravar e buscar dados da ALVบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA492                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoGetALV(cMethod)
Local bCampo 	:= {|n| FieldName(n) }
Local nx			:= 0
Local cCampo	:= ""

Default cMethod := "1"

Do Case
	Case cMethod == "1"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Efetua a copia do registro                                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("ALV",.F.)
		For nx := 1 TO FCount()
			cCampo := Upper(AllTrim(FieldName(nx)))
			If ALV->(FieldPos(cCampo))>0
				If cCampo == "ALV_FILIAL"
					FieldPut(nx,xFilial("ALV"))
				Else
					FieldPut(nx,M->&(EVAL(bCampo,nx)))
				Endif
			Endif
		Next nx
		
		MsUnlock()

	Case cMethod == "2"

		FOR nx := 1 TO FCount()
			M->&(EVAL(bCampo,nx)) := FieldGet(nx)
		Next nx

EndCase

Return .T.

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoIniProcบAutor  ณ Acacio Egas        บ Data ณ  07/24/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de inicializacao da gravacao de lancamentos por     บฑฑ
ฑฑบ          ณ processo. O Processo deve ter um Tipo de Saldo Especifico. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoIniProc( cProcesso )

Local cSldProc		:= ALLTRIM(SuperGetMV("MV_PCO" + SubStr( cProcesso , 4 , 3 ) ,.F.,""))

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If !Empty(cSldProc)

		cUpd := "UPDATE " + RetSqlName("AKD") + " SET AKD_STATUS='3' WHERE AKD_PROCES='" + cProcesso + "' AND D_E_L_E_T_=' ' "
		TcSqlExec( cUpd )
		TcRefresh(RetSqlName("AKD"))

	EndIf
	PcoIniLan(cProcesso)

EndIf

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoDetProcบAutor  ณ Acacio Egas        บ Data ณ  07/24/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de geracao dos lancamentos por processo.            บฑฑ
ฑฑบ          ณ O Processo deve ter um Tipo de Saldo Especifico.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoDetProc( cProcesso , cItem , cPrograma , lDeleta , cProcDel )

	PcoDetLan(cProcesso,cItem,cPrograma,lDeleta, cProcDel)

Return

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoDetProcบAutor  ณ Acacio Egas        บ Data ณ  07/24/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de Finaliza็ใo dos lancamentos por processo.        บฑฑ
ฑฑบ          ณ O Processo deve ter um Tipo de Saldo Especifico.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PNJGerRelac(cId,aEntid,aItemRelac,nRelac,nPerc,cRegra,nPerIni,nPeriods,cFiltroALX,aTipoPl)

	Local lRet

	lRet := PCOGerRelac(cId,aEntid,aItemRelac,nRelac,nPerc,cRegra,nPerIni,nPeriods,cFiltroALX,aTipoPl)

Return lRet

/*
Funcao para direcionamento do PCOA495 para PCOXPNJ.
*/
Function PNJGerComb(cRegrDist,cEntiExcl,aValor,nPrecAgre,lQtd,cCodigo,cTipo,cRegrFilt,cTmpArq)

	PcoGerComb(cRegrDist,/*cEntiExcl*/,aValores,nPrecAgre,.F./*lQtd*/,/*cCodigo*/,"1"/*cTipoCtbl*/,/*cRegrFilt*/,@cTmpArq)

Return 
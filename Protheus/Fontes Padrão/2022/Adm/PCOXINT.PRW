
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOXINT.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "AP5MAIL.CH"      

#Define BMP_ON     "LBOK"
#Define PCO_PROC    1
#Define PCO_LDETLAN 2
#Define PCO_REGBLOQ 3
#Define PCO_REGLANC 4
#Define PCO_LOTE    5
#Define PCO_SAVESX8 6
#Define PCO_IDLAN   7

STATIC lDetLanc		:= .F.
STATIC aRecBlq		:= {}
STATIC aRecLanc		:= {}
STATIC cPcoLote		:= ''
STATIC nSaveSX8		:= 0
STATIC cIDLAn	  	:= ''
Static aCposUsr
Static aCpoUsrAMJ
Static aCpoUsrAKC
Static aCpoUsrAKI
Static aPcoProc 	:= {}
Static nUltVldLan 	:= 0
Static aQueryCache 	:= {}
Static aMudouAcols 	:= {}
Static lCtgOk		:= .F.
Static lDetTransa	:= .F. // Utilizada para verrificar se a PcoDetLan esta em transacao
Static nQtdEntid
Static __nCtdSleep  := 0
Static __oQuAkd	    := NIL
Static __oAkdRecno  := NIL
Static _cQryPCOArq  := NIL
Static _oJsonPCOArq := NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetaHeaderบAutor  ณGuilherme C. Leal   บ Data ณ  01/28/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna o aHeader de um arquivo especificado    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GetaHeader(cAlias,aCpos,aCposNo,aEnchAuto,aCposVisual,lWalk_Thru)
Local	aCampo	 := {}
Local	aHeader	 := {}
Local	aAreaSX3 := SX3->(GetArea())
Local	lObrigat
// Local	cCampoBloq	:= "AKM_INICPO|AKM_DIGCPO|AKM_CODTAB|AKM_RADCHV" //apos descida do projeto MCASP, remover protecao
// Local	lPco160		:= IsInCallStack("PCOA160")						//apos descida do projeto MCASP, remover protecao

/*  Variavel lVersaoM verifica se o release ้ o anterior as descidas
 de MCASP do fonte PCOA160 e PCOA161, ao descer esses fontes retirar a trava */
// Local	lVersaoM	:= GetRPORelease() < "12.1.035"					//apos descida do projeto MCASP, remover protecao

Default aCpos     := {}
Default aCposVisual:= {}
Default aCposNo   := {}
Default aEnchAuto := {}
Default lWalk_Thru := .F.

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))

Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !x3uso(SX3->X3_USADO) 
		SX3->(DbSkip())
		Loop
	EndIf

	lObrigat := Iif(VerByte(SX3->X3_RESERV,7) .or. X3Obrigat(SX3->X3_CAMPO),.T.,.F.)
	lVisual := If(aScan(aCposVisual,Alltrim(SX3->X3_CAMPO))>0,.T.,.F.) 
	
	aCampo := {Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,			;
		SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,	;
		SX3->X3_F3,SX3->X3_CONTEXT,X3Cbox(),SX3->X3_RELACAO,SX3->X3_WHEN,		;
		If(lVisual,"V",SX3->X3_VISUAL),	SX3->X3_VLDUSER, SX3->X3_PICTVAR,lObrigat}
	
	// If lPco160  .And. lVersaoM .And. SX3->X3_CAMPO $ 'AKM_CPOREF' //apos descida do projeto MCASP, remover protecao
	// 	aCampo[9] := ""
	// Endif 

	If Len(aCposNo) > 0 .And. ( AScan(aCposNo,{|x| Upper(AllTrim(SX3->X3_CAMPO)) == Upper(AllTrim(x)) }) > 0	)
		Aadd(aEnchAuto,aClone(aCampo))
		SX3->(DbSkip())
		Loop
	EndIf
	
	If Len(aCpos) = 0 .Or. ( Len(aCpos) > 0 .And. AScan(aCpos,{|x| Upper(AllTrim(SX3->X3_CAMPO)) == Upper(AllTrim(x)) }) > 0 )
		// If (!SX3->X3_CAMPO $ cCampoBloq  .And. lPco160 .And. lVersaoM ) .Or. !lPco160 //apos descida do projeto MCASP, remover protecao
		Aadd(aHeader,aClone(aCampo))
		// Endif
	EndIf

	SX3->(DbSkip())
	
EndDo

If lWalk_Thru
	PcoHeaderWT(cAlias, aHeader)
EndIf

SX3->(RestArea(aAreaSX3))
Return aHeader

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoIniLanณ Autor ณ Edson Maricate         ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao inicializacao da gravacao dos lancamentos do SIGAPCO   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoIniLan(cProcesso,lDelBlq)
Local nUltProc
Local nX, aProcDep
Local lSolicCT  := (SuperGetMV("MV_PCOSDCT",.F.,.F.)) //Verifica se Ativa solicita็ใo de saldo de contingencia

Default lDelBlq := .T.

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	//*********************************************************
	// Prepara variavel de controle do estorno da contigencia *
	//*********************************************************
	If  lSolicCT .and. cProcesso<>"000356"
		lCtgOk	:= .F. // retorna o valor padrใo 
		PcoCtngRes(.t.) // Zera o vetor com o Backup dos dados da Contigencia
	EndIf

	If lDelBlq
		PcoChkBlq()
	EndIf

	cIDLan		:= StrZero(1,Len(AKD->AKD_ID))
	lDetLanc		:= .F.
	aRecBlq		:= {}
	aRecLanc	:= {}

	If aScan( aMudouAcols , {|x| x[1]==cProcesso})==0
		aAdd( aMudouAcols , {cProcesso,.F.} )
	EndIf

	If Empty(cPcoLote)
		nSaveSX8	:= GetSX8Len()
	EndIf
    
    //adiciona no array aPcoProc (Static )e insere um array com 
    // 1 - Codigo do Processo
    // 2 - Logico .F.  (lDetLan - qdo grava um lcto em pcodetlan muda para .T.)
    // 3 - array contendo os recnos AKD referente ao bloqueio
    // 4 - array contendo os recnos dos lancamentos (AKD)
    // 5 - NUMERO DO LOTE (VERIFICAR O Q COLOCA)
    // 6 - NUMERO SX8 (OS Q JA ESTAO RESERVADOS)
    // 7 - ID DO LANCAMENTO
    
	aAdd(aPcoProc, aClone(Array(7)) )
	nUltProc := Len(aPcoProc)
	aPcoProc[nUltProc, PCO_PROC 	] 	:= cProcesso
	aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .F.
	aPcoProc[nUltProc, PCO_REGBLOQ 	] 	:= aClone({})
	aPcoProc[nUltProc, PCO_REGLANC 	] 	:= aClone({})
	aPcoProc[nUltProc, PCO_LOTE 	] 	:= ""
	aPcoProc[nUltProc, PCO_SAVESX8 	] 	:= GetSX8Len()
	aPcoProc[nUltProc, PCO_IDLAN 	] 	:= StrZero(1,Len(AKD->AKD_ID))

	//abre arquivos 
	If nUltProc == 1

		PcoAbreArq(cProcesso)

		aProcDep := PcoProcRelac(cProcesso)
		For nX := 1 TO Len(aProcDep)
			PcoAbreArq(aProcDep[nX])			
		Next // nX

	EndIf	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoDetLanณ Autor ณ Edson Maricate         ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de geracao dos lancamentos nas contas orcamentarias    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoDetLan( cProcesso, cItem, cPrograma, lDeleta, cProcDel, cAKDStatus, lAtuSld )
Local aArea			:= GetArea()
Local aAreaAKC		
Local aAreaAKB		
Local aAreaAKD		
Local aAreaSX3      := SX3->(GetArea())
Local aRecAKD		:= {}
Local cChave		:= ""
Local lAtivo		:= .F.
Local nx
Local nZ, cNomCpo := "", aCposNew := {}
Local lFoundAKC
Local nLinhas := 1, aCposForm := {}, aCpos_Form := {}
Local nY, nTam, nElemChk, nPosCpo, cContCpo, aCposArray := {}
Local nRec_AKD := 0
Local lNotBlind		:= !IsBlind()
Local nUltProc      := Len(aPcoProc)
Local lGrvComp	 := ExistBlock("PCOGRVCOM")

Local cQryAKD	:= ""
Local cAliasAKD	:= ""
Local lSolicCT	:= (SuperGetMV("MV_PCOSDCT",.F.,.F.)) //Verifica se Ativa solicita็ใo de saldo de contingencia
Local lSeek 	:= .T.
Local lAKDChv	:= ExistBlock("PCOAKDCHV")
Local cQuery := "" 
Local cAliasQry := GetNextAlias() 
Local cUltLote
Local aArea_AKD := {}
     
DEFAULT lDeleta 	:= .F.
DEFAULT cProcDel 	:= ""
DEFAULT cAKDStatus 	:= "2"
DEFAULT lAtuSld 	:= ( cPrograma <> "PCOA310" )

//--------------------------------------------------
//Corre็ใo da atualiza็ใo de saldos para criar as 
// tabelas AKS e AKT em ambientes em que estas 
// tabelas ainda nใo existem. A nใo exist๊ncia 
// da tabela impacta no bloqueio dos lan็amentos 
// de integra็ใo
//--------------------------------------------------
dbSelectArea("AKT")
dbSelectArea("AKS")

If SuperGetMV("MV_PCOINTE",.T.,"2")=="1"
	//***************************************************************
	//      Data: 12/08/09 - Acacio Egas                            *
	// Verrifica se a PcoDetLan foi chamada dentro de uma Transacao.*
	// Neste caso nao se pode manipular as Tabelas AKS e AKT dentro *
	// da transacao. A atualiza็ใo sera feita na PcoFinLan.         *
	//***************************************************************
	If Intransact()
		lDetTransa := .T.
	EndIf
	
	//*************************************************
	// Utilizada para controlar se gerou DetLan,      *
	//  se nao passar executa RollBack da Contigencia *
	//*************************************************
	If  lSolicCT .and. cProcesso<>"000356"
		lCtgOk := .T.
	EndIf


	//colocado este retorno para quando as rotinas que chamar pcodetlan()
	//nao for chamado entre as funcoes PcoIniLan() e PcoFinLan()
	If Empty(aPcoProc)
		RestArea( aArea )
		Return
	EndIf	

	aAreaAKC := AKC->(GetArea())
	aAreaAKB := AKB->(GetArea())
	aAreaAKD := AKD->(GetArea())

	lFoundAKC := PcoExistLc(cProcesso,cItem,"1")

	dbSelectArea("AKB")
	dbSetOrder(1)
	If MsSeek(xFilial()+cProcesso+cItem) .And. (lFoundAKC .OR. AKB->AKB_CFGON == "1")

		aCposForm := PcoCposForm(3)
		/*
		Descricao do vetor aCposForm:
		
		aCposForm[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
		aCposForm[2] : Nome do campo na tabela de lancamentos (AKD)
		aCposForm[3] : .T. - Utiliza funcao PcoPlancel()
				   .F. - Formula em expressao ADVPL        
		aCposForm[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
		aCposForm[5] : Resultado apos macro execucao
		*/
	
		aCposNew := PcoCposNew(3)
	
		/*
		Descricao do vetor aCpos_Form:    - sera utilizado para gravar resultado 
	                                      - aCposNew  - identico ao array aCposForm
		aCpos_Form[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
		aCpos_Form[2] : Nome do campo na tabela de lancamentos (AKD)
		aCpos_Form[3] : .T. - Utiliza funcao PcoPlancel()
					   .F. - Formula em expressao ADVPL        
		aCpos_Form[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
		aCpos_Form[5] : Resultado apos macro execucao
		*/
		For nZ := 1 TO Len(aCposNew)  
				
			cNomCpo := aCposNew[nZ]
				
			If AKC->(FieldPos(StrTran(cNomCpo,"AKD_","AKC_"))) > 0
				aAdd(aCpos_Form, { StrTran(cNomCpo,"AKD_","AKC_"), ;
									cNomCpo, ;
									.F., ;
									StrTran(cNomCpo,"AKD_","AKC_"), ;
									NIL })
			EndIf
				
		Next  //nZ
	
		dbSelectArea(AKB->AKB_ENTIDA)
		dbSetOrder(AKB->AKB_INDICE)

		If cProcesso $ "000005" .And. ( cItem $ "04" )
			// Complemento da Chave para item Contabil e Classe de Valor
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AKD->AKD_CHAVE))
		ElseIf cProcesso $ "000002" .And. ( cItem $ "05" )
			// Complemento da Chave para item Contabil e Classe de Valor
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AKD->AKD_CHAVE))	
		ElseIf cProcesso $ "000001" .And. ( cItem $ "05" )
			// Complemento da Chave para item Contabil e Classe de Valor
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AKD->AKD_CHAVE))	
		ElseIf cProcesso $ "000006" .And. ( cItem $ "03" )
			// Complemento da Chave para item Contabil e Classe de Valor
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AKD->AKD_CHAVE))
		ElseIf cProcesso $ "000007"//|000102"
			cChave := ""
		ElseIf cProcesso == "000009" .And. ! ( cItem $ "01|30" )
			cChave := ""
		ElseIf cProcesso == "000010" .And. ! ( cItem $ "01|16" )
			cChave := ""
		ElseIf cProcesso == "000011" .And. ! ( cItem $ "01" )
			cChave := ""
		ElseIf cProcesso == "000016" .And. ! ( cItem $ "01|02" )
			cChave := ""
		ElseIf cProcesso == "000017" .And. ! ( cItem $ "01|02" )
			cChave := ""
		ElseIf cProcesso == "000056"  //Eliminacao de residuo sempre gera lcto
			cChave := ""              //em lote novo e nao fica vinculado pela chave
		ElseIf cProcesso == "000100" .And. cItem $ "02|04"
			cChave := ""		
		ElseIf cProcesso == "000356"  //Solicita็ใo de Contignecia
			cChave := Padr("ALJ"+&(IndexKey())+ cItem,Len(AKD->AKD_CHAVE)) 
		ElseIf cProcesso == "000021"
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey()+"+CV4_ITSEQ"),Len(AKD->AKD_CHAVE))		
		ElseIf cProcesso == "000054"  .and. cItem $ "15|16" // tratamento para baixa parcial do pedido de compras (Documento de entrada)
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+ SD1->D1_DOC,Len(AMJ->AMJ_CHAVE))			 
		Else
			cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey()),Len(AKD->AKD_CHAVE))
		EndIf
	
		//**************************************************
		// Ponto de entrada para alterar o campo AKD_CHAVE *
		//**************************************************
		If lAKDChv
			cChave := ExecBlock("PCOAKDCHV" ,.f.,.f., {cProcesso , cItem , .F. ,cChave} )
		EndIf
	
		If !lDeleta  .And. lNotBlind .And. AKB->AKB_CFGON == "1"
			If !PcoCfgLanc() .And. IsInCallStack("FINA100")
				Return(.F.)
			Endif
		EndIf
					
		If !Empty(cChave) 
		
			cAliasAKD := GetNextAlias() 
			
			cQuery := ""
			If __oAkdRecno == Nil
				cQuery += "SELECT AKD.AKD_LOTE,AKD.R_E_C_N_O_ AKDRECNO FROM " + RetSqlName( "AKD" ) + " AKD " 
				cQuery += "WHERE "
				cQuery += "AKD.AKD_FILIAL = ? AND " 
				cQuery += "AKD.AKD_CHAVE  = ? AND " 
				cQuery += "AKD.AKD_PROCES = ? AND "
				cQuery += "AKD.D_E_L_E_T_ =' '"                        
				
				cQuery := ChangeQuery( cQuery )
				__oAkdRecno := FWPreparedStatement():New(cQuery)	
			EndIf 

			__oAkdRecno:SetString(1,xFilial( 'AKD' ))
			__oAkdRecno:SetString(2,cChave)
			__oAkdRecno:SetString(3,cProcesso)
			
			dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, __oAkdRecno:GetFixQuery() ), cAliasAKD, .f., .t. ) 
			
			TcSetField( cAliasAKD, "AKDRECNO", "N", 12, 0 ) 
			
			While !( cAliasAKD )->( Eof() ) 
			
				aPcoProc[nUltProc, PCO_LOTE] := ( cAliasAKD )->AKD_LOTE
				aAdd(aRecAKD, ( cAliasAKD )->AKDRECNO )

				( cAliasAKD )->( dbSkip() ) 
									
			EndDo 
		    
			( cAliasAKD )->( dbCloseArea()) 
		    
			dbSelectArea( "AKD" ) 
		EndIf
			
		If Empty(aRecAKD).And. Empty(aPcoProc[nUltProc, PCO_LOTE]/*cPcoLote*/)
			
			dbSelectArea("AKD")
			dbSetOrder(1)

			If __oQuAkd == Nil
				cQryAKD := "SELECT MAX(AKD_LOTE) LOTE "
				cQryAKD += "  FROM "+ RetSqlName( 'AKD' )+" AKD "
				cQryAKD += " WHERE AKD.AKD_FILIAL = ? "
				cQryAKD += "   AND D_E_L_E_T_ = ' '"
				cQryAKD := ChangeQuery(cQryAKD)
				__oQuAkd := FWPreparedStatement():New(cQryAKD)			
			EndIf
			
			__oQuAkd:SetString(1,xFilial( 'AKD' ))
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,__oQuAkd:GetFixQuery()),cAliasQry,.T.,.F.)
			
			Iif (!Empty((cAliasQry)->LOTE),cUltLote := Soma1((cAliasQry)->LOTE),cUltLote := '0000000001')

			(cAliasQry)->(dbCloseArea())
			
			aPcoProc[nUltProc, PCO_LOTE] := cUltLote
			
			If AKB->AKB_ENTIDA == "AKD"  //Quando A ORIGEM for o proprio AKD Tem que reposicionar apos pegar o proximo codigo do lote
				aArea_AKD := AKD->(GetArea())
			EndIf
			
			While !Empty(aPcoProc[nUltProc, PCO_LOTE]) .And. ;
						( AKD->(dbSeek(xFilial('AKD')+aPcoProc[nUltProc, PCO_LOTE])) .Or.;
						!MayIUseCode("AKD"+xFilial('AKD')+aPcoProc[nUltProc, PCO_LOTE]) )

				PcoSleep()
				cUltLote := Soma1(cUltLote)
				aPcoProc[nUltProc, PCO_LOTE] := cUltLote   
				      
			EndDo 
			//Quando A ORIGEM for o proprio AKD Tem que reposicionar apos pegar o proximo codigo do lote
			If AKB->AKB_ENTIDA == "AKD"
				RestArea(aArea_AKD)
			EndIf
		EndIf
		
		dbSelectArea("AKC")
		dbSetOrder(1)
		If MsSeek(xFilial("AKC")+cProcesso+cItem)
			While !Eof() .And. xFilial("AKC")+cProcesso+cItem==AKC->AKC_FILIAL+AKC->AKC_PROCES+AKC->AKC_ITEM
				If AKC_ATIVO == BMP_ON 
					lAtivo 	:= .T.
					If !lDeleta
						//Verifica se existe uma funcao de usuario para ser executada antes 
						//de comecar o lancamento 
						If FieldPos('AKC_EXEPRE') > 0 .And. !Empty(AKC_EXEPRE)
							&(Alltrim(AKC_EXEPRE)+IIf("("$Alltrim(AKC_EXEPRE),"","(.F.)"))				      
						Endif
						//faz macro execucao em todas os campos da tabela AKC
						//e armazena na posicao 5 do array aCposForm / aCposNew
				
						nTam := Len(aCposForm)
						aCposArray := {}   
					
						For nZ := 1 to nTam
						
							nPosCpo := AKC->(FieldPos(aCposForm[nZ,1]))
							If nPosCpo > 0
								cContCpo := AKC->(FieldGet(nPosCpo))
								If !Empty(cContCpo)
									uValor := Eval( &( "{|| " + cContCpo+" }")) 
							        aCposForm[nZ, 5] := uValor
							    EndIf    
					        EndIf
					        
						Next //nZ
					
					
						nTam := Len(aCpos_Form)  
					
						For nZ := 1 to nTam
						
							nPosCpo := AKC->(FieldPos(aCpos_Form[nZ,1]))
							If nPosCpo > 0
								cContCpo := AKC->(FieldGet(nPosCpo))
								If !Empty(cContCpo)
									uValor := Eval( &( "{|| " + cContCpo+" }")) 
							        aCpos_Form[nZ, 5] := uValor
							    EndIf    
					        EndIf
					        
						Next // nZ
						
						/*guarda no aCposArray todos os resultados Tipo = Array
						  e para outros tipos valida tipo do campo
						Estrutura do Array aCposArray
							aCposArray[nL,1] : Nome do campo na tabela de lancamentos (AKD)
							aCposArray[nL,2] : Tamanho do Array de resultado da macro execucao
							aCposArray[nL,3] : 1=aCposForm - 2=aCpos_Form (em q array vai buscar resultado)
							aCposArray[nL,4] : Elemento do Array para busca do resultado da macro execucao
						*/
						For nZ := 1 TO Len(aCposForm)
							If ValType(aCposForm[nZ, 5])=="A"  //Array
								aAdd(aCposArray, {aCposForm[nZ, 2], Len(aCposForm[nZ, 5]), 1, nZ } )
							Else
								//para outros ---> valida tipo do campo 
								If lNotBlind .And. aCposForm[nZ, 5] != NIL .And. ValType(aCposForm[nZ, 5]) # TamSX3(aCposForm[nZ,2])[3]
									Alert( STR0043 + AllTrim(aCposForm[nZ,1])) // Tipo de dado invรกlido informado na coluna: 
								EndIf
							EndIf	
						Next //nZ
						
						For nZ := 1 TO Len(aCpos_Form)
							If ValType(aCpos_Form[nZ, 5])=="A"  //Array
								aAdd(aCposArray, {aCpos_Form[nZ, 2], Len(aCpos_Form[nZ, 5]), 2, nZ } )
							Else
								//para outros ---> valida tipo do campo 
								If lNotBlind .And. aCpos_Form[nZ, 5] != NIL .And. ValType(aCpos_Form[nZ, 5]) # TamSX3(aCpos_Form[nZ,2])[3]
									Alert( STR0043 + AllTrim(aCpos_Form[nZ,1])) // Tipo de dado invรกlido informado na coluna: 
								EndIf
							EndIf	
						Next //nZ
						
						//testa se todos estao do mesmo tamanho e do mesmo tipo 
						//for comeca do segundo elemento -- Retornos tipo Array
						For nZ := 2 TO Len(aCposArray)
							//verifica elemento anterior com atual
							If lNotBlind .And. aCposArray[nZ-1, 2] != aCposArray[nZ, 2]
								Alert( STR0045+;//"Os vetores com resultados estao com tamanho diferente."
										STR0046+ aCposArray[nZ-1, 1] + "/" +;//"Verifique a expressao dos campos "
										aCposArray[nZ, 1])
							EndIf
						Next //nZ
						
						//verifica se tipo esta de acordo com dicionario
						//para os campos que retornaram array
						For nZ := 1 TO Len(aCposArray)
							cTypeCpo := TamSX3(aCposArray[nZ,1])[3]
							
							//verifica se tipo esta de acordo com dicionario
							nElemChk := aCposArray[nZ,4]
							If aCposArray[nZ,3] == 1
								For nY := 1 TO Len(aCposForm[nElemChk, 5])
									If lNotBlind .And. ValType(aCposForm[nElemChk, 5, nY]) # cTypeCpo
										Alert( STR0043 + AllTrim(aCposForm[nElemChk,1])) // Tipo de dado invรกlido informado na coluna: 
									EndIf
								Next //nY
							Else
								For nY := 1 TO Len(aCpos_Form[nElemChk, 5])
									If lNotBlind .And. ValType(aCpos_Form[nElemChk, 5, nY]) # cTypeCpo
										Alert( STR0043 + AllTrim(aCpos_Form[nElemChk,1])) // Tipo de dado invรกlido informado na coluna: 
									EndIf
								Next //nY
							EndIf	
							
						Next //nZ
						
						//se nao falhou nenhuma validacao acrescenta registro tabela AKD
						//----> inicia gravacao na tabela AKD
						
						If Len(aCposArray) > 0
							nLinhas := aCposArray[1, 2]
						Else
							nLinhas := 1
						EndIf
						
						If nLinhas == 1  //uma unica linha
							If (			Eval( &( "{|| " + If(!Empty(AKC->AKC_VALOR1), AKC->AKC_VALOR1, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AKC->AKC_VALOR2), AKC->AKC_VALOR2, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AKC->AKC_VALOR3), AKC->AKC_VALOR3, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AKC->AKC_VALOR4), AKC->AKC_VALOR4, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AKC->AKC_VALOR5), AKC->AKC_VALOR5, "0")+" }"))	> 0 )
								
								aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .T. //lDetLanc		:= .T.

								AKD->( dbSetOrder(10))
								lSeek := .T.
								If ! Empty(cChave) .And. Len(aRecAKD)>0
									For nx:= 1 to len(aRecAKD)   
										If aRecAKD[nx] > 0
											AKD->(dbGoto(aRecAKD[nx]))
											If AKC->AKC_SEQ == AKD->AKD_SEQ
												RecLock("AKD",.F.)
												If lAtuSld .And. AKD->AKD_STATUS == "1"
													PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
												EndIf
												lSeek := .F.
												aRecAKD[aScan(aRecAKD,AKD->(RecNo()))] := -1
												EXIT
											Endif
										Endif
									Next nx
								
								Endif
								
								If lSeek

										cAliasAKD := GetNextAlias()

										cQuery := ""

										cQuery += "SELECT MAX( AKD.AKD_ID ) AKDMAXID FROM " + RetSqlName( "AKD" ) + " AKD "
										cQuery += "WHERE "
										cQuery += "AKD.AKD_FILIAL='" + xFilial("AKD")               + "' AND "
										cQuery += "AKD.AKD_LOTE='"   + aPcoProc[nUltProc, PCO_LOTE] + "' AND "
										cQuery += "AKD.AKD_ID>='"    + aPcoProc[nUltProc, PCO_IDLAN] + "' AND "
										cQuery += "AKD.D_E_L_E_T_=' '"

										cQuery := ChangeQuery( cQuery )

										dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, cQuery ), cAliasAKD, .f., .t. )

										If !Empty( ( cAliasAKD )->AKDMAXID )
											aPcoProc[nUltProc, PCO_IDLAN] := SomaIt( ( cAliasAKD )->AKDMAXID)
										EndIf

									    ( cAliasAKD )->( dbCloseArea())

									    dbSelectArea( "AKD" )

									RecLock("AKD",.T.)
									AKD->AKD_FILIAL := 	xFilial("AKD")
									AKD->AKD_LOTE	:=	aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
									AKD->AKD_ID		:= 	aPcoProc[nUltProc, PCO_IDLAN]//cIDLan
									//cIDLan			:= 	SomaIt(cIDLan)
									aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
								EndIf

								//gravacao dos campos armazenados nos arrays
								//aCposForm e aCpos_Form
								nTam := Len(aCposForm)
					
								For nZ := 1 to nTam
						
									nPosCpo := AKD->(FieldPos(aCposForm[nZ,2]))
									If nPosCpo > 0
										uValor := aCposForm[nZ, 5]
										If uValor != NIl .And. !Empty(uValor)
											AKD->(FieldPut(nPosCpo, uValor))
										EndIf
							        EndIf
					        
								Next //nZ

								nTam := Len(aCpos_Form)
					
								For nZ := 1 to nTam
						
									nPosCpo := AKD->(FieldPos(aCpos_Form[nZ,2]))
									If nPosCpo > 0
										uValor := aCpos_Form[nZ, 5]
										If uValor != NIl .And. !Empty(uValor)
											AKD->(FieldPut(nPosCpo, uValor))
										EndIf
							        EndIf
					        
								Next //nZ
								
								AKD->AKD_PROCES	:= AKC->AKC_PROCES
								AKD->AKD_ITEM	:= AKC->AKC_ITEM
								AKD->AKD_SEQ	:= AKC->AKC_SEQ
								AKD->AKD_CHAVE	:= cChave
								AKD->AKD_USER	:= __cUserId
								AKD->AKD_IDREF	:= &(AKC->AKC_KEYREF)
								If AKD->(FieldPos("AKD_LCTBLQ")) > 0								
									AKD->AKD_LCTBLQ	:= " "
								EndIf	
								AKD->AKD_STATUS	:= cAKDStatus // "2"
								If AKD->(FieldPos("AKD_FILORI")) > 0
									AKD->AKD_FILORI	:= xFilial(AKB->AKB_ENTIDA)
								EndIf
								AKD->( MsUnlock() )
														
								dbSelectArea("AK5")
								dbSetOrder(1)
								If !Empty(AKD->AKD_CO) .And. dbSeek(xFilial()+AKD->AKD_CO)
									RecLock("AKD",.F.)
									AKD->AKD_COSUP := AK5->AK5_COSUP
									AKD->( MsUnlock() )
								EndIf
								aAdd(aRecLanc,AKD->(RecNo()))
								aAdd(aPcoProc[nUltProc, PCO_REGLANC],AKD->(RecNo()))
							EndIf
							
						Else
							//gravacao varias linhas quando retorno da macro for array
							For nY := 1 TO nLinhas
								lSeek := .T.
								If PcoAcumValue("AKC", aCposForm, aCpos_Form) > 0
									aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .T. //lDetLanc		:= .T.
									nRec_AKD++
									If nRec_AKD <= Len(aRecAKD) //nY e a linha a ser gravada
										For nx:= 1 to len(aRecAKD)
											If aRecAKD[nx] > 0
												AKD->(dbGoto(aRecAKD[nRec_AKD]))
												If AKC->AKC_SEQ == AKD->AKD_SEQ
													RecLock("AKD",.F.)
													If lAtuSld .And. AKD->AKD_STATUS == "1"
														PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
													EndIf
													lSeek := .F.
													aRecAKD[nRec_AKD/*aScan(aRecAKD,AKD->(RecNo()))*/] := -1
													EXIT
												Endif
											Endif
										Next nx
									Endif
									
									If lSeek
										AKD->( dbSetOrder(1) )
										Do While AKD->( dbSeek( xFilial("AKD")+;
															aPcoProc[nUltProc, PCO_LOTE]+;
															aPcoProc[nUltProc, PCO_IDLAN] ) )
											aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
										EndDo
										RecLock("AKD",.T.)
										AKD->AKD_FILIAL := 	xFilial("AKD")
										AKD->AKD_LOTE	:=	aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
										AKD->AKD_ID		:= 	aPcoProc[nUltProc, PCO_IDLAN]//cIDLan
										aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
									EndIf
									
									//gravacao dos campos armazenados nos arrays
									//aCposForm e aCpos_Form
									nTam := Len(aCposForm)
						
									For nZ := 1 to nTam
							
										nPosCpo := AKD->(FieldPos(aCposForm[nZ,2]))
										If nPosCpo > 0 .And. aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
										    If ValType(aCposForm[nZ,5]) == "A"
												uValor := aCposForm[nZ,5,nY]
										    Else
												uValor := aCposForm[nZ,5]
											EndIf	
											AKD->(FieldPut(nPosCpo, uValor))
								        EndIf
						        
									Next //nZ
	
									nTam := Len(aCpos_Form)
						
									For nZ := 1 to nTam
							
										nPosCpo := AKD->(FieldPos(aCpos_Form[nZ,2]))
										If nPosCpo > 0 .And. aCpos_Form[nZ,5] != NIL .And. !Empty(aCpos_Form[nZ,5])
										    If ValType(aCpos_Form[nZ,5]) == "A"
												uValor := aCpos_Form[nZ,5,nY]
										    Else
												uValor := aCpos_Form[nZ,5]
											EndIf	
											AKD->(FieldPut(nPosCpo, uValor))
								        EndIf
						        
									Next //nZ
	
									AKD->AKD_PROCES	:= AKC->AKC_PROCES
									AKD->AKD_ITEM	:= AKC->AKC_ITEM
									AKD->AKD_SEQ	:= AKC->AKC_SEQ
									AKD->AKD_CHAVE	:= cChave
									AKD->AKD_USER	:= __cUserId
									AKD->AKD_IDREF	:= &(AKC->AKC_KEYREF)
									If AKD->(FieldPos("AKD_LCTBLQ")) > 0								
										AKD->AKD_LCTBLQ	:= " "
									EndIf	
									AKD->AKD_STATUS	:= cAKDStatus // "2"
									If AKD->(FieldPos("AKD_FILORI")) > 0
										AKD->AKD_FILORI	:= xFilial(AKB->AKB_ENTIDA)
									EndIf									
									AKD->( MsUnlock() )
									dbSelectArea("AK5")
									dbSetOrder(1)
									If !Empty(AKD->AKD_CO) .And. dbSeek(xFilial()+AKD->AKD_CO)
										RecLock("AKD",.F.)
										AKD->AKD_COSUP := AK5->AK5_COSUP
										AKD->( MsUnlock() )
									EndIf
									aAdd(aRecLanc,AKD->(RecNo()))
									aAdd(aPcoProc[nUltProc, PCO_REGLANC],AKD->(RecNo()))
								EndIf
							Next //nZ
						EndIf

					Else

						If !Empty(cProcDel)
					
							//quando deve considerar o processo-item para 
							//exclusao do lancamento
							For nx := 1 to Len(aRecAKD)
								dbSelectArea("AKD")
								dbGoto(aRecAKD[nx])
		                        If Alltrim(AKD->AKD_PROCES+AKD->AKD_ITEM)$cProcDel
        		               		aRecAKD[nx] := -1
								EndIf	
							Next
						EndIf
						
						Exit
							
					EndIf
					//limpar resultados da macro execucao posicao 5 dos arrays
					//aCposForm / aCpos_Form
					AEval(aCposForm,{|x| x[5] := NIL })
					AEval(aCpos_Form,{|x| x[5] := NIL })
				EndIf
				dbSelectArea("AKC")
				dbSkip()
			End
		EndIf
		If lAtivo
			For nx := 1 to Len(aRecAKD)
				If aRecAKD[nx] > 0
					dbSelectArea("AKD")
					dbGoto(aRecAKD[nx])
					If lAtuSld .And. AKD->AKD_STATUS == "1"
						PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)	
					EndIf
					RecLock("AKD",.F.,.T.)
					If (AKB->(FieldPos("AKB_ESTORN")) # 0 ) .And. AKB->AKB_ESTORN == "1"  // 1=Sim;2=Nao
						AKD->AKD_STATUS := "3"
					Else
						dbDelete()
					EndIf	
					MsUnlock()                                         
				EndIf
			Next
		EndIf
	EndIf
	RestArea(aAreaAKD)
	RestArea(aAreaAKB)
	RestArea(aAreaAKC)
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

IF lGrvComp
	Execblock ("PCOGRVCOM",.T.,.T.)
EndIF	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAcumValue บAutor  ณPaulo Carnelossi บ Data ณ  01/09/06   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna acumulador dos valores absolutos dos campos configu-บฑฑ
ฑฑบ          ณrados cujo nome do campo == alias "_VALOR1"                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoAcumValue(cAlias ,aCposForm, aCpos_Form)
Local nY, nZ, nI, cCampo,nAcumul := 0

For nY := 1 To 5
	cCampo := cAlias+"_VALOR"+Str(nY,1)
    For nZ := 1 TO Len(aCposForm)
    	If aCposForm[nZ,1] == cCampo
           If ValType(aCposForm[nZ,5]) == "A" //Array
	          For nI := 1 TO Len(aCposForm[nZ,5])
	          	nAcumul += Abs(aCposForm[nZ,5,nI])
	          Next //nI
	       Else
	          If aCposForm[nZ,5] != NIL
		       	  nAcumul += Abs(aCposForm[nZ,5])
		      EndIf 	  
	       EndIf
	    EndIf
	Next //nZ
	
	For nZ := 1 TO Len(aCpos_Form)
    	If aCpos_Form[nZ,1] == cCampo
           If ValType(aCpos_Form[nZ,5]) == "A" //Array
	          For nI := 1 TO Len(aCpos_Form[nZ,5])
	          	nAcumul += Abs(aCpos_Form[nZ,5,nI])
	          Next //nI
	       Else
	          If aCpos_Form[nZ,5] != NIL
		       	  nAcumul += Abs(aCpos_Form[nZ,5])
		      EndIf 	  
	       EndIf   
	    EndIf
	Next //nZ
	
Next //nY

Return(nAcumul)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoFinLanณ Autor ณ Edson Maricate         ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de finalizacao dos lancamentos das contas orcamentariasณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoFinLan(cProcesso,lForceVis,lProc,lDelBlq,lAtuSld)
Local aCposVisual	:= {} 
Local aArea			:= GetArea()
Local nX,  aLoteProc:= {}
Local nY
Local nPosLote             
Local lNotBlind		:= !IsBlind()
Local nUltProc 		:= Len(aPcoProc)
Local nQtReserv
DEFAULT lForceVis	:= .F.                    
DEFAULT lProc       := .F.
Default lDelBlq		:= .T.
Default lAtuSld		:= .T.

If SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
	If Empty( aPcoProc )
		Conout( STR0067 + cProcesso + CRLF + STR0068 + FunName() )
	Else
		//******************************************
		//      Data: 12/08/09 - Acacio Egas       *
		// Atualiza a pilha de saldo criada devido *
		// a transacao aberta durante a PcoDetLan  *
		//******************************************
		lDetTransa := .F.
		PcoFinTran()
		
		AK8->(dbSetOrder(1))
		AK8->(MsSeek(xFilial()+cProcesso))
		FreeUsedCodes(.T.)
		If !Empty(aPcoProc[nUltProc, PCO_REGLANC]) 
			For nX := 1 TO Len(aPcoProc)
				For nY := 1 TO Len(aPcoProc[nX, PCO_REGLANC]) 
					AKD->(dbGoto(aPcoProc[nX, PCO_REGLANC, nY]))
					If AKD->AKD_STATUS != "3"
						If (nPosLote	:=	ASCAN(aLoteProc, {|x| x[1] == AKD->AKD_LOTE}))==0
							aAdd(aLoteProc, {AKD->AKD_LOTE,{aPcoProc[nX, PCO_REGLANC, nY]}})
						Else
							AAdd(aLoteProc[nPosLote][2],aPcoProc[nX, PCO_REGLANC, nY])
						EndIf		
					EndIf
				Next	
			Next
			DbSelectArea('AKD')
			While ( GetSX8Len() > aPcoProc[nUltProc, PCO_SAVESX8] )
				ConFirmSX8()
			EndDo
			
			For nX := 1 To Len(aLoteProc)
				AKD->(dbGoto(aLoteProc[nX][2][1]))
				If !PCOA050(4,.T.,aCposVisual,aLoteProc[nX][2],lProc,,lAtuSld)
					dbSelectArea("SX3")
					dbSetOrder(1)
					dbSeek("AKD")
					While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
						If X3USO(x3_usado) .AND. cNivel >= x3_nivel
							nPos := AT(Alltrim(SX3->X3_CAMPO)+";",AK8->AK8_PROPLC)
							If nPos > 0
								If Substr(AK8->AK8_PROPLC,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
									aAdd(aCposVisual,Alltrim(SX3->X3_CAMPO))
								EndIf
							EndIf
						EndIf
						dbSkip()
					End
					//AKD->(dbGoto(aPcoProc[nUltProc, PCO_REGLANC, nX]))
					If lNotBlind
						PCOA050(4,,aCposVisual,aLoteProc[nX][2],,,lAtuSld)
					EndIf
				Else
					If lNotBlind .And. ( lForceVis .Or. AK8->AK8_VISUAL == "1" )
						dbSelectArea("SX3")
						dbSetOrder(1)
						dbSeek("AKD")
						While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
							If X3USO(x3_usado) .AND. cNivel >= x3_nivel
								nPos := AT(Alltrim(SX3->X3_CAMPO)+";",AK8->AK8_PROPLC)
								If nPos > 0
									If Substr(AK8->AK8_PROPLC,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
										aAdd(aCposVisual,Alltrim(SX3->X3_CAMPO))
									EndIf
								EndIf
							EndIf
							dbSkip()
						End
						PCOA050(4,,aCposVisual,aLoteProc[nX][2],,,lAtuSld)
					EndIf
				EndIf
			Next	
		Else
			DbSelectArea('AKD')
			nQtReserv := GetSX8Len()
			While ( GetSX8Len() > aPcoProc[nUltProc, PCO_SAVESX8] )
				RollBackSX8()
				If nQtReserv == GetSX8Len()  //contingencia para nao entrar em loop infinito
					Exit                     //se depois do RollBackSX8() nao decrementou 
				EndIf
			EndDo
			
		EndIf
	    If nUltProc > 0
	    	aRecLanc := aPcoProc[nUltProc, PCO_REGLANC 	]
	    	aRecBlq  := aPcoProc[nUltProc, PCO_REGBLOQ 	]
	    	nSaveSX8 := aPcoProc[nUltProc, PCO_SAVESX8  ]
	    	If lDelBlq
		    	PcoFreeBlq(cProcesso)
	    	EndIf
	    	aSize(aPcoProc, nUltProc-1)
	    EndIf
	EndIf
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoFreeBlq ณ Autor ณ Edson Maricate       ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de finalizacao dos bloqueios de lancamentos das contas ณฑฑ
ฑฑณ          ณorcamentarias                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณEXPC1 - Numero do processo de lancamento/bloqueio             ณฑฑ
ฑฑณ          ณEXPC2 - Indica se deve inicializar o ID do lancamento para    ณฑฑ
ฑฑณ          ณ        um mesmo lote. Utilizado nos casos de bloqueio de     ณฑฑ
ฑฑณ          ณ        lancamentos que podem reaproveitar o mesmo no. de loteณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoFreeBlq(cProcesso, lUsaLote, nRecAKD, lRestaura, aPcoBkpBlq, lCancela)
Local	aArea     := GetArea()
Local 	nx		  := 0
Local   nUltProc  := Len(aPcoProc)
Local 	lSolicCT  := (SuperGetMV("MV_PCOSDCT",.F.,.F.)) //Verifica se Ativa solicitaรงรฃo de saldo de contingencia
Local   aCntgs
Local   nQtReserv
Local lAtualiza := .F.

Default	lUsaLote  := .F.
Default nRecAKD   := 0
Default lRestaura := .F.
Default aPcoBkpBlq := {}
Default lCancela := .F.

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	If nRecAKD > 0
		PcoDelBlq(nRecAKD)
		If nUltProc > 0
			If (nPosBlq	:=	aScan(aPcoProc[nUltProc, PCO_REGBLOQ],nRecAKD)) > 0
				aDel(aPcoProc[nUltProc, PCO_REGBLOQ],nPosBlq)
				aSize(aPcoProc[nUltProc, PCO_REGBLOQ],Len(aPcoProc[nUltProc, PCO_REGBLOQ])-1)			
	      Endif
		Endif
		If lRestaura
			PcoRestoreAKD(aPcoBkpBlq, nRecAKD)		
		EndIf
	Else
		If nUltProc > 0 
			For nX := 1 to Len(aPcoProc[nUltProc, PCO_REGBLOQ])
				If aScan(aRecLanc,aPcoProc[nUltProc, PCO_REGBLOQ,nX])<=0
					PcoDelBlq(aPcoProc[nUltProc, PCO_REGBLOQ,nX])
					lAtualiza := .T.
				EndIf
			Next
			If lRestaura .And. lAtualiza
				PcoRestoreAKD(aPcoBkpBlq, 0)		
			EndIf
		Endif	
		aRecBlq	  := {}
		aRecLanc  := {}
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se reaproveita o numero de lote, inicializa o ID ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nUltProc > 0 .And. nUltProc == nUltVldLan .And. lUsaLote
			//cIDLan   := StrZero(1,Len(AKD->AKD_ID))
			aPcoProc[nUltVldLan, PCO_IDLAN] := StrZero(1,Len(AKD->AKD_ID))
		Else
			nQtReserv := GetSX8Len()
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
				If nQtReserv == GetSX8Len()  //contingencia para nao entrar em loop infinito
					Exit                     //se depois do RollBackSX8() nao decrementou 
				EndIf
			EndDo
			If nUltProc > 0 // se array aPcoProc estiver vazio eh pq ja fez freeblq
				//nSaveSX8  := 0     //nao precisa inicializar pois sempre qdo pega o lote atualiza a variavel
				//cPcoLote := ""
				aPcoProc[nUltProc, PCO_SAVESX8] := 0
				aPcoProc[nUltProc, PCO_LOTE] := ""
			EndIf	
		EndIf
	EndIf

	If  lSolicCT

		If !lCtgOk  .and. nRecAKD==0

			//PcoReproc(cProcesso)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Restaura lan็amentos de contingencia para estorno         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCntgs := PcoCtngRes()
			PcoRestoreAKD( aCntgs )
			PcoCtngRes(.t.)

		ElseIf lCancela
			PcoCtngRes(.t.)		
		EndIf
		
		If lCancela
		
			PcoReproc(cProcesso)
		
		EndIf
		
    ElseIf lCancela             
		//se tiver bloqueio e foi cancelado em uma alteracao da getdados deve reprocessar para 
		//acertar os lancamentos na tabela AKD (esta chamada sempre sera depois do finlan() normal)
    	PcoReproc(cProcesso)

	EndIf

EndIf
        
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoVldLanณ Autor ณ Edson Maricate         ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao dos pontos de bloqueio do SIGAPCO         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณEXPC1 - Codigo do processo de lancamento do PCO               ณฑฑ
ฑฑณ          ณEXPC2 - Item do processo de lancamento                        ณฑฑ
ฑฑณ          ณEXPC3 - Programa de origem do lancamento                      ณฑฑ
ฑฑณ          ณEXPC4 - Indica se deve inicializar o ID do lancamento para    ณฑฑ
ฑฑณ          ณ        um mesmo lote. Utilizado nos casos de bloqueio de     ณฑฑ
ฑฑณ          ณ        lancamentos que podem reaproveitar o mesmo no. de loteณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoVldLan(cProcesso,cItem,cPrograma,lUsaLote,lDeleta, lVldLinGrade, cMsgBlind)
Local aArea			:= GetArea()
Local aAreaSX3      := SX3->(GetArea())
Local aAreaAKI      := AKI->(GetArea())
Local aAreaAKA		:= AKA->(GetArea())
Local aRecAKD		:= {}
Local cChave		:= ""
Local lRet 			:= .T.
Local lAtivo 		:= .F.
Local nx
//Local cIDLan		
Local aRecLct
Local dDataLanc
Local dDataIni
Local dDataFim
Local cChaveRD
Local nProc
Local aCposVisual	:= {}
Local cCodCuboPrv, cCodCuboReal, aProcPrv, aProcReal
Local nZ, cNomCpo := "", aCposNew := {}
Local aCfgAux := {}
Local aAuxFil := {}
Local lValorAux
Local lFoundAKI
Local cChvAux 
Local aCposForm
Local aCpos_Form := {}
Local nY, nTam, nElemChk, nPosCpo, cContCpo, aCposArray := {}
Local nRec_AKD := 0
Local lFoundAKA := .F.
Local lVldBloq  := .T.
Local nUltProc 	:= Len(aPcoProc)
Local nTimeOut  := SuperGetMV("MV_PCOOUTB",.F.,0) * 1000
Local lSolicCT  := (SuperGetMV("MV_PCOSDCT",.F.,.F.)) //Verifica se Ativa solicita็ใo de saldo de contingencia
Local nOpcTime  := 1
Local aPcoBkpBlq := {}
Local lGravaAKD	:= .F.
Local lVerSald	:= .F. // Variavel utilizada para verrificar bloqueio na AKH caso AKI gere movimento na AKD
Local n_origAcols 
Local lAKDChv	:= ExistBlock("PCOAKDCHV")
Local lPcoFecBl	:= ExistBlock("PCOFECBL")
Local lMrgBloq		:= .F.
Local cFilALC		:= ""
Local cAssunto		:= ""
Local cMsgEmail	:= ""
Local aDestinat	:= {}
Local cQryAKD	:= ""
Local cAliasQry := GetNextAlias()
Local cUltLote  := ""
Local lNotBlind := !IsBlind()

Private nMoedaCfg, cChaveR
Private aDataIniFim := {,}
Private __aDadosBlq	:=	{}
Private lSldAcum  := .T.

Default lUsaLote	:= 	.F.
Default lDeleta		:=	.F.
Default lVldLinGrade:= 	.F.
Default cMsgBlind	:= ""


If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If Type("n")#"U"
	    n_origAcols := n
    EndIf
	SaveInter()
	If Type("n")#"U"
		n := n_origAcols
    EndIf
    
	//verifica se cubo esta sendo utilizado no reprocessamento
	If	Pco_CubeProc(cProcesso)
		RestInter()
		RestArea(aAreaAKA)
		RestArea(aAreaAKI)
		RestArea(aAreaSX3)
		RestArea(aArea)
		Return(.F.)
	EndIf

	/*
	Descricao do vetor aCposForm:
	
	aCposForm[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
	aCposForm[2] : Nome do campo na tabela de lancamentos (AKD)
	aCposForm[3] : .T. - Utiliza funcao PcoPlancel()
				   .F. - Formula em expressao ADVPL        
	aCposForm[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
	aCposForm[5] : Resultado apos macro execucao
	*/
	aCposForm	:= PcoCposForm(4)
	aCposNew	:= PcoCposNew(3)
	
	/*
	Descricao do vetor aCpos_Form:    - sera utilizado para gravar resultado 
	                                      - aCposNew  - identico ao array aCposForm
	aCpos_Form[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
	aCpos_Form[2] : Nome do campo na tabela de lancamentos (AKD)
	aCpos_Form[3] : .T. - Utiliza funcao PcoPlancel()
				   .F. - Formula em expressao ADVPL        
	aCpos_Form[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
	aCpos_Form[5] : Resultado apos macro execucao
	*/
	For nZ := 1 TO Len(aCposNew)  
			
		cNomCpo := StrTran(aCposNew[nZ], "AKD_", "AKI_")
			
		If AKI->(FieldPos(cNomCpo)) > 0
			aAdd(aCpos_Form, { 	cNomCpo, ;
								StrTran(cNomCpo,"AKI_","AKD_"), ;
								.F., ;
								cNomCpo, ;
								NIL })
		EndIf
			
	Next  //nZ

	// Abre arquivos
	PcoAbreArq(cProcesso)
	
	dbSelectArea("AKI")
	dbSetOrder(1)
	lFoundAKI := MsSeek(xFilial()+cProcesso+cItem)

	AK8->(dbSetOrder(1))
	AK8->(MsSeek(xFilial()+cProcesso))

	If cProcesso$"000052|000376"
	    If nUltProc == 0 .OR. aScan( aPcoProc , {|x| x[1]==cProcesso}) == 0
			//cIDLan		:= StrZero(1,Len(AKD->AKD_ID))
			PcoIniLan(cProcesso) // se nao tinha passado por PcoIniLan forca a passagem
			nUltProc 	:= Len(aPcoProc)
		Else
			nUltProc := aScan( aPcoProc , {|x| x[1]==cProcesso})
		Endif
    ElseIf nUltProc == 0 .OR. cProcesso <> aPcoProc[nUltProc, 1]//Empty(cIdLan)
		//cIDLan		:= StrZero(1,Len(AKD->AKD_ID))
		PcoIniLan(cProcesso) // se nao tinha passado por PcoIniLan forca a passagem
		nUltProc 	:= Len(aPcoProc)
	Endif

	aRecLct		:= {}
	
	dbSelectArea("AKA")
	dbSetOrder(1)
	lFoundAKA := MsSeek(xFilial()+cProcesso+cItem)
	If lFoundAKA
	    lVldBloq  := Verif_Bloqueio(lVldLinGrade)
	EndIf    
	If (!lFoundAKA) .OR. (!lFoundAKI .And.AKA->AKA_CFGON <> "1"); //se nao encontrar retorna 
		.OR. (!lVldBloq)
		RestInter()   	
		RestArea(aAreaAKA)
		RestArea(aAreaAKI)
		RestArea(aAreaSX3)
		RestArea(aArea)
		Return(lRet)
	EndIf

	//**************************************************
	// Ponto de entrada para alterar o campo AKD_CHAVE *
	//**************************************************
	If lAKDChv
		cChvAux := ExecBlock("PCOAKDCHV" ,.f.,.f., {cProcesso , cItem , .T. ,cChave} )
		If 	Empty(cChvAux)
			cChvAux := &(AKA->AKA_CHAVE)
		Else	
			cChvAux := &(cChvAux)
		EndIf
	Else	
		cChvAux := &(AKA->AKA_CHAVE)
	EndIf
	cChave := Padr(AKA->AKA_ENTIDA+cChvAux,Len(AKD->AKD_CHAVE))

	If lNotBlind .And. AKA->AKA_CFGON == "1"
		PcoCfgBlq()
	EndIf
	
	If !Empty(cChvAux)
		dbSelectArea("AKD")
		dbSetOrder(10)
		MsSeek(xFilial()+cChave)
		While !Eof() .And. xFilial("AKD")+AllTrim(cChave)==AKD_FILIAL+AllTrim(AKD_CHAVE)
			//cPcoLote:= AKD->AKD_LOTE
			If AKD->AKD_PROCES == cProcesso
				aPcoProc[nUltProc, PCO_LOTE] := AKD->AKD_LOTE
				cChave 	:= AKD_CHAVE
	
				// Utilizado para gravar o valor atual do registo para calculo do empenho
				If lSolicCT
				
					 PcoCtngVld()
	
				EndIf

				aAdd(aRecAKD,AKD->(RecNo()))
			Endif
			dbSkip()
		End
	EndIf
	
	If Empty(aRecAKD) .And. Empty(aPcoProc[nUltProc, PCO_LOTE]) //Empty(cPcoLote)
		dbSelectArea("AKD")
		dbSetOrder(1)
		nSaveSX8	:= GetSX8Len()
		aPcoProc[nUltProc, PCO_SAVESX8] := GetSX8Len()
		//cPcoLote	:= CriaVar("AKD_LOTE",.T.)
		aPcoProc[nUltProc, PCO_LOTE] := CriaVar("AKD_LOTE",.T.)
		/*
		While !Empty(cPcoLote) .And. ( AKD->(dbSeek(xFilial('AKD')+cPcoLote)) .Or. !MayIUseCode("AKD"+xFilial('AKD')+cPcoLote)  ) 
			cPcoLote	:= Soma1(cPcoLote,Len(AKD->AKD_LOTE))
		End
		*/
		
		cQryAKD := "SELECT MAX(AKD_LOTE) LOTE "
		cQryAKD += "  FROM " + RetSqlName( 'AKD' ) + " AKD "
		cQryAKD += " WHERE AKD.AKD_FILIAL = '" + xFilial( 'AKD' ) + "'"
		cQryAKD += "   AND D_E_L_E_T_ = ' '"
			
		cQryAKD := ChangeQuery(cQryAKD)
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAKD),cAliasQry,.T.,.F.)
			
		cUltLote := Soma1((cAliasQry)->LOTE)

		(cAliasQry)->(dbCloseArea())
			
		aPcoProc[nUltProc, PCO_LOTE] := cUltLote
			
		While !Empty(aPcoProc[nUltProc, PCO_LOTE]) .And. ;
				( AKD->(dbSeek(xFilial('AKD')+aPcoProc[nUltProc, PCO_LOTE])) .Or. ;
				!MayIUseCode("AKD"+xFilial('AKD')+aPcoProc[nUltProc, PCO_LOTE])  ) 
				
				PcoSleep()
				cUltLote := Soma1(cUltLote,Len(AKD->AKD_LOTE))
				aPcoProc[nUltProc, PCO_LOTE] := cUltLote				
		End
	EndIf

	dbSelectArea("AKI")
	dbSetOrder(1)
	MsSeek(xFilial()+cProcesso+cItem)
	While !Eof() .And. xFilial()+cProcesso+cItem==AKI_FILIAL+AKI_PROCES+AKI_ITEM
		//verifica se valor nao esta zerado
		If AKI_ATIVO == BMP_ON
			
			If !lDeleta
				//Verifica se existe uma funcao de usuario para ser executada antes
				//de comecar o lancamento
				If FieldPos('AKI_EXEPRE') > 0 .And. !Empty(AKI_EXEPRE)
					&(Alltrim(AKI_EXEPRE)+IIf("("$Alltrim(AKI_EXEPRE),"","(.T.)"))
				Endif
				
				//faz macro execucao em todas os campos da tabela AKI
				//e armazena na posicao 5 do array aCposForm / aCposNew
				nTam := Len(aCposForm)
				aCposArray := {}
				For nZ := 1 to nTam
					
					nPosCpo := AKI->(FieldPos(aCposForm[nZ,1]))
					If nPosCpo > 0
						cContCpo := AKI->(FieldGet(nPosCpo))
						If !Empty(cContCpo)
							uValor := Eval( &( "{|| " + cContCpo+" }"))
							aCposForm[nZ, 5] := uValor
						EndIf
					EndIf
					
				Next //nZ
				
				
				nTam := Len(aCpos_Form)
				
				For nZ := 1 to nTam
					
					nPosCpo := AKI->(FieldPos(aCpos_Form[nZ,1]))
					If nPosCpo > 0
						cContCpo := AKI->(FieldGet(nPosCpo))
						If !Empty(cContCpo)
							uValor := Eval( &( "{|| " + cContCpo+" }"))
							aCpos_Form[nZ, 5] := uValor
						EndIf
					EndIf
					
				Next // nZ
				
				/*guarda no aCposArray todos os resultados Tipo = Array
				e para outros tipos valida tipo do campo
				Estrutura do Array aCposArray
				aCposArray[nL,1] : Nome do campo na tabela de lancamentos (AKD)
				aCposArray[nL,2] : Tamanho do Array de resultado da macro execucao
				aCposArray[nL,3] : 1=aCposForm - 2=aCpos_Form (em q array vai buscar resultado)
				aCposArray[nL,4] : Elemento do Array para busca do resultado da macro execucao
				*/
				For nZ := 1 TO Len(aCposForm)
					If ValType(aCposForm[nZ, 5])=="A"  //Array
						aAdd(aCposArray, {aCposForm[nZ, 2], Len(aCposForm[nZ, 5]), 1, nZ } )
					Else
						//para outros ---> valida tipo do campo
						If aCposForm[nZ, 5] != NIL .And. ValType(aCposForm[nZ, 5]) # TamSX3(aCposForm[nZ,2])[3]
							Alert( STR0043 + AllTrim(aCposForm[nZ,1])) // Tipo de dado invรกlido informado na coluna:
							//Break
						EndIf
					EndIf
				Next //nZ
				
				For nZ := 1 TO Len(aCpos_Form)
					If ValType(aCpos_Form[nZ, 5])=="A"  //Array
						aAdd(aCposArray, {aCpos_Form[nZ, 2], Len(aCpos_Form[nZ, 5]), 2, nZ } )
					Else
						//para outros ---> valida tipo do campo
						If aCpos_Form[nZ, 5] != NIL .And. ValType(aCpos_Form[nZ, 5]) # TamSX3(aCpos_Form[nZ,2])[3]
							Alert( STR0043 + AllTrim(aCpos_Form[nZ,1])) // Tipo de dado invรกlido informado na coluna:
							//Break
						EndIf
					EndIf
				Next //nZ
				
				//testa se todos estao do mesmo tamanho e do mesmo tipo
				//for comeca do segundo elemento -- Retornos tipo Array
				For nZ := 2 TO Len(aCposArray)
					//verifica elemento anterior com atual
					If aCposArray[nZ-1, 2] != aCposArray[nZ, 2]
						Alert( STR0045+;  //"Os vetores com resultados estao com tamanho diferente."
						STR0046 + aCposArray[nZ-1, 1] + "/" +; //"Verifique a expressao dos campos "
						aCposArray[nZ, 1])
						//Break
					EndIf
				Next //nZ
				
				//verifica se tipo esta de acordo com dicionario
				//para os campos que retornaram array
				For nZ := 1 TO Len(aCposArray)
					cTypeCpo := TamSX3(aCposArray[nZ,1])[3]
					
					//verifica se tipo esta de acordo com dicionario
					nElemChk := aCposArray[nZ,4]
					If aCposArray[nZ,3] == 1
						For nY := 1 TO Len(aCposForm[nElemChk, 5])
							If ValType(aCposForm[nElemChk, 5, nY]) # cTypeCpo
								Alert( STR0043 + AllTrim(aCposForm[nElemChk,1])) // Tipo de dado invรกlido informado na coluna:
								//Break
							EndIf
						Next //nY
					Else
						For nY := 1 TO Len(aCpos_Form[nElemChk, 5])
							If ValType(aCpos_Form[nElemChk, 5, nY]) # cTypeCpo
								Alert( STR0043 + AllTrim(aCpos_Form[nElemChk,1])) // Tipo de dado invรกlido informado na coluna:
								//Break
							EndIf
						Next //nY
					EndIf
					
				Next //nZ
				
				//se nao falhou nenhuma validacao acrescenta registro tabela AKD
				//----> inicia gravacao na tabela AKD
				
				If Len(aCposArray) > 0
					nLinhas := aCposArray[1, 2]
				Else
					nLinhas := 1
				EndIf
				
				If nLinhas == 1
					lValorAux :=  Eval( &( "{|| " + If(!Empty(AKI->AKI_VALOR1), AKI->AKI_VALOR1, "0")+" }"))	> 0 .OR. ;
					Eval( &( "{|| " + If(!Empty(AKI->AKI_VALOR2), AKI->AKI_VALOR2, "0")+" }"))> 0 .OR. ;
					Eval( &( "{|| " + If(!Empty(AKI->AKI_VALOR3), AKI->AKI_VALOR3, "0")+" }"))> 0 .OR. ;
					Eval( &( "{|| " + If(!Empty(AKI->AKI_VALOR4), AKI->AKI_VALOR4, "0")+" }"))> 0 .OR. ;
					Eval( &( "{|| " + If(!Empty(AKI->AKI_VALOR5), AKI->AKI_VALOR5, "0")+" }"))> 0
					lGravaAKD	:=	.F.
					If AKD->(MsSeek(xFilial()+cChave+AKI->AKI_SEQ)) .And. lValorAux
						lGravaAKD	:=	.T.
						lAtivo := .T.
						RecLock("AKD",.F.)
                        //faz copia do registro no array aPcoBkpBlq para posterior 
                        //restauracao caso processo seja bloqueado 
						PcoBackupAKD(aPcoBkpBlq)
						If AKD->AKD_STATUS == '1'
							PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
						EndIf
						aRecAKD[aScan(aRecAKD,AKD->(RecNo()))] := -(AKD->(RecNo()))
						
					ElseIf lValorAux  //somente faz lancto se valor for > 0
						lGravaAKD	:=	.T.
						lAtivo := .T.
						AKD->( dbSetOrder(1) )
						/*
						Do While AKD->( dbSeek( xFilial("AKD")+cPcoLote+cIDLan ) )
							cIDLan := SomaIt(cIDLan)
						EndDo
						*/
						Do While AKD->( dbSeek( xFilial("AKD")+;
											aPcoProc[nUltProc, PCO_LOTE]+;
											aPcoProc[nUltProc, PCO_IDLAN] ) )
							aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
						EndDo
						
						RecLock("AKD",.T.)
						AKD->AKD_FILIAL := 	xFilial("AKD")
						AKD->AKD_LOTE	:=	aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
						AKD->AKD_ID		:= aPcoProc[nUltProc, PCO_IDLAN] //cIDLan
						//cIDLan			:= SomaIt(cIDLan)
						aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
					EndIf
					If lGravaAKD
						//gravacao dos campos armazenados nos arrays
						//aCposForm e aCpos_Form
						If aScan( aMudouAcols , {|x| x[1]==cProcesso})>0
							aMudouAcols[aScan( aMudouAcols , {|x| x[1]==cProcesso}),2] := .T.
						EndIf

						nTam := Len(aCposForm)
						
						For nZ := 1 to nTam
							
							nPosCpo := AKD->(FieldPos(aCposForm[nZ,2]))
							If nPosCpo > 0
								uValor := aCposForm[nZ, 5]
								If uValor != NIl .And. !Empty(uValor)
									AKD->(FieldPut(nPosCpo, uValor))
								EndIf
							EndIf
							
						Next //nZ
						
						nTam := Len(aCpos_Form)
						
						For nZ := 1 to nTam
							
							nPosCpo := AKD->(FieldPos(aCpos_Form[nZ,2]))
							If nPosCpo > 0
								uValor := aCpos_Form[nZ, 5]
								If uValor != NIl .And. !Empty(uValor)
									AKD->(FieldPut(nPosCpo, uValor))
								EndIf
							EndIf
							
						Next //nZ
						
						AKD->AKD_PROCES	:= AKI->AKI_PROCES
						AKD->AKD_ITEM	:= AKI->AKI_ITEM
						AKD->AKD_SEQ	:= AKI->AKI_SEQ
						AKD->AKD_CHAVE	:= cChave
						AKD->AKD_USER	:= __cUserId
						AKD->AKD_IDREF	:= &(AKI->AKI_KEYREF)
						If AKD->(FieldPos("AKD_LCTBLQ")) > 0
							AKD->AKD_LCTBLQ	:= "1"
						EndIf	
						AKD->AKD_STATUS	:= "2"
						If AKD->(FieldPos("AKD_FILORI")) > 0
							AKD->AKD_FILORI	:= xFilial(AKA->AKA_ENTIDA)
						EndIf
						AKD->( MsUnlock() )
						aAdd(aRecLct,AKD->(RecNo()))
						/*
						If aScan(aRecBlq,AKD->(RecNo())) <= 0
							aAdd(aRecBlq,AKD->(RecNo()))
						EndIf
						*/
						If aScan(aPcoProc[nUltProc, PCO_REGBLOQ],AKD->(RecNo())) <= 0
							aAdd(aPcoProc[nUltProc, PCO_REGBLOQ],AKD->(RecNo()))
						EndIf
						nUltVldLan 	:= nUltProc
						lVerSald	:= .T. // Atualizou AKD tem que comparar Saldo
					EndIf
					
				Else
					//varias linhas
					For nY := 1 TO nLinhas
						lValorAux :=  (PcoAcumValue("AKI", aCposForm, aCpos_Form) > 0)
						
						lGravaAKD	:=	.F.
						lAtivo := .T.
						nRec_AKD++
						
						If nRec_AKD <= Len(aRecAKD)//AKD->(MsSeek(xFilial()+cChave+AKI->AKI_SEQ))
							lGravaAKD	:=	.T.
							AKD->(dbGoto(aRecAkd[nRec_AKD]))
							RecLock("AKD",.F.)
		                    //faz copia do registro no array aPcoBkpBlq para posterior 
	                        //restauracao caso processo seja bloqueado 
							PcoBackupAKD(aPcoBkpBlq)
							If AKD->AKD_STATUS == '1'
								PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
							EndIf
							aRecAKD[nRec_AKD/*aScan(aRecAKD,AKD->(RecNo()))*/] := -(AKD->(RecNo()))
						ElseIf lValorAux  //somente faz lancto se valor for > 0
							AKD->( dbSetOrder(1) )
							/*
							Do While AKD->( dbSeek( xFilial("AKD")+cPcoLote+cIDLan ) )
								cIDLan := SomaIt(cIDLan)
							EndDo
							*/
							Do While AKD->( dbSeek( xFilial("AKD")+;
											aPcoProc[nUltProc, PCO_LOTE]+;
											aPcoProc[nUltProc, PCO_IDLAN] ) )
								aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
							EndDo
							lGravaAKD	:=	.T.
							RecLock("AKD",.T.)
							AKD->AKD_FILIAL:=	xFilial("AKD")
							AKD->AKD_LOTE	:=	aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
							AKD->AKD_ID		:=  aPcoProc[nUltProc, PCO_IDLAN] //cIDLan
							//cIDLan			:= SomaIt(cIDLan)
							aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
						EndIf
						If lGravaAKD
							//gravacao dos campos armazenados nos arrays
							//aCposForm e aCpos_Form
							If aScan( aMudouAcols , {|x| x[1]==cProcesso})>0
								aMudouAcols[aScan( aMudouAcols , {|x| x[1]==cProcesso}),2] := .T.
							EndIf
						
							nTam := Len(aCposForm)
							
							For nZ := 1 to nTam
								
								nPosCpo := AKD->(FieldPos(aCposForm[nZ,2]))
								If nPosCpo > 0 .And. aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
									If ValType(aCposForm[nZ,5]) == "A"
										uValor := aCposForm[nZ,5,nY]
									Else
										uValor := aCposForm[nZ,5]
									EndIf
									AKD->(FieldPut(nPosCpo, uValor))
								EndIf
								
							Next //nZ
							
							nTam := Len(aCpos_Form)
							
							For nZ := 1 to nTam
								
								nPosCpo := AKD->(FieldPos(aCpos_Form[nZ,2]))
								If nPosCpo > 0 .And. aCpos_Form[nZ,5] != NIL .And. !Empty(aCpos_Form[nZ,5])
									If ValType(aCpos_Form[nZ,5]) == "A"
										uValor := aCpos_Form[nZ,5,nY]
									Else
										uValor := aCpos_Form[nZ,5]
									EndIf
									AKD->(FieldPut(nPosCpo, uValor))
								EndIf
								
							Next //nZ
							
							
							AKD->AKD_PROCES	:= AKI->AKI_PROCES
							AKD->AKD_ITEM	:= AKI->AKI_ITEM
							AKD->AKD_SEQ	:= AKI->AKI_SEQ
							AKD->AKD_CHAVE	:= cChave
							AKD->AKD_USER	:= __cUserId
							AKD->AKD_IDREF	:= &(AKI->AKI_KEYREF)
							If AKD->(FieldPos("AKD_LCTBLQ")) > 0
								AKD->AKD_LCTBLQ	:= "1"
							EndIf	
							AKD->AKD_STATUS	:= "2"
							If AKD->(FieldPos("AKD_FILORI")) > 0
								AKD->AKD_FILORI	:= xFilial(AKA->AKA_ENTIDA)
							EndIf
							AKD->( MsUnlock() )
							aAdd(aRecLct,AKD->(RecNo()))
							/*
							If aScan(aRecBlq,AKD->(RecNo())) <= 0
								aAdd(aRecBlq,AKD->(RecNo()))
							EndIf
							*/
							If aScan(aPcoProc[nUltProc, PCO_REGBLOQ],AKD->(RecNo())) <= 0
								aAdd(aPcoProc[nUltProc, PCO_REGBLOQ],AKD->(RecNo()))
							EndIf
							nUltVldLan 	:= nUltProc
							lVerSald	:= .T. // Atualizou AKD tem que comparar Saldo
						EndIf
					Next //nY == Varias Linhas
				EndIf
			Else
				For nx := 1 to Len(aRecAKD)
					If aRecAKD[nx] > 0
						dbSelectArea("AKD")
						dbGoto(aRecAKD[nx])
                        //faz copia do registro no array aPcoBkpBlq para posterior 
                        //restauracao caso processo seja bloqueado 
						PcoBackupAKD(aPcoBkpBlq)
						If AKD->AKD_STATUS == '1'
							PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
						EndIf
						RecLock("AKD",.F.,.T.)
						dbDelete()
						MsUnlock()
					EndIf
				Next
			Endif
			//limpar resultados da macro execucao posicao 5 dos arrays
			//aCposForm / aCpos_Form
			AEval(aCposForm,{|x| x[5] := NIL })
			AEval(aCpos_Form,{|x| x[5] := NIL })
		EndIf
		dbSelectArea("AKI")
		dbSkip()
	EndDo
	
	If lAtivo
		For nx := 1 to Len(aRecAKD)
			If aRecAKD[nx] > 0
				dbSelectArea("AKD")
				dbGoto(aRecAKD[nx]) 
                //faz copia do registro no array aPcoBkpBlq para posterior 
                //restauracao caso processo seja bloqueado
                PcoBackupAKD(aPcoBkpBlq)
				If AKD->AKD_STATUS == '1'
					PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)						
				EndIf
				RecLock("AKD",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		Next
	EndIf

	If !Empty(aRecLct) .And. !IsBlind()
		AKD->(dbGoto(aRecLct[1]))
		AK8->(dbSetOrder(1))
		AK8->(MsSeek(xFilial()+cProcesso))
		MBRCHGLOOP(.F.)
		If !PCOA050(4,.T.,aCposVisual,,, .T./*lLockBlq*/)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("AKD")
			While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
				If X3USO(x3_usado) .AND. cNivel >= x3_nivel
					nPos := AT(Alltrim(SX3->X3_CAMPO)+";",AK8->AK8_PROPLC)
					If nPos > 0
						If Substr(AK8->AK8_PROPLC,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
							aAdd(aCposVisual,Alltrim(SX3->X3_CAMPO))
						EndIf
					EndIf
				EndIf
				dbSkip()
			End
			AKD->(dbGoto(aRecLct[1]))
			lRet := PCOA050(4,,aCposVisual,,, .T./*lLockBlq*/)
		Else
			If AK8->AK8_VISUAL == "1"
				dbSelectArea("SX3")
				dbSetOrder(1)
				dbSeek("AKD")
				While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
					If X3USO(x3_usado) .AND. cNivel >= x3_nivel
						nPos := AT(Alltrim(SX3->X3_CAMPO)+";",AK8->AK8_PROPLC)
						If nPos > 0
							If Substr(AK8->AK8_PROPLC,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
								aAdd(aCposVisual,Alltrim(SX3->X3_CAMPO))
							EndIf
						EndIf
					EndIf
					dbSkip()
				End
				lRet := PCOA050(4,,aCposVisual,,, .T./*lLockBlq*/)	
			EndIf
		EndIf
		MBRCHGLOOP(.T.)
	EndIf
	If lRet .And. lVerSald
		aRecAKD	:= {}
		dbSelectArea("AKD")
		dbSetOrder(10)
		MsSeek(xFilial()+cChave)
		While !Eof() .And. xFilial()+cChave==AKD_FILIAL+AKD_CHAVE
			aAdd(aRecAKD,AKD->(RecNo()))
			dbSkip()
		End
		If !Empty(aRecAKD)
			AKD->(dbGoto(aRecAKD[1]))
			For nx := 1 to Len(aRecAKD)	
				dbSelectArea("AKD")
				dbGoto(aRecAKD[nx])
				dDataLanc	:= AKD->AKD_DATA
				dbSelectArea("AKH")
				dbSetOrder(1)
				If MsSeek(xFilial()+cProcesso+cItem)
					While !Eof() .And. xFilial("AKH")+cProcesso+cItem==AKH_FILIAL+AKH_PROCES+AKH_ITEM
						If AKH_ATIVO == BMP_ON
							AKJ->(dbSetOrder(1))
							AKJ->(MsSeek(xFilial()+AKH->AKH_CODBLQ))
							If (AKJ->(FieldPos('AKJ_SLDPER'))==0 .Or. AKJ->AKJ_SLDPER <> '1')
								lSldAcum := .T.
							Else
								lSldAcum := .F.
							EndIf
							If (AKJ->(FieldPos('AKJ_CALCVL'))==0 .Or. AKJ->AKJ_CALCVL <> '1') .And. !Empty(AKJ->AKJ_BLOCK)
								If PCOExecForm(AKJ->AKJ_BLOCK)
									lRet := .T.
								Else
									PcoIncr_QtBlq()
									lRet := .F.
									Exit
								EndIf
							Else
								Do Case 
									Case AKJ->AKJ_TPSLD == "1"
										dDataIni := dDataLanc
										If DOW(dDataLanc)<>1
											dDataIni -= DOW(dDataLanc)-1
										EndIf
										dDataFim := dDataIni+6
									Case AKJ->AKJ_TPSLD == "2"
										If DAY(dDataLanc) <= 15
											dDataIni := FirstDay(dDataLanc)
											dDataFim := CTOD("15/"+Str(Month(dDataLanc),2,0)+"/"+Str(Year(dDataLanc),2,0))
										Else
											dDataIni := CTOD("16/"+Str(Month(dDataLanc),2,0)+"/"+Str(Year(dDataLanc),4,0))
											dDataFim :=  LastDay(dDataLanc)
										EndIf
									Case AKJ->AKJ_TPSLD == "3"
										dDataIni := FirstDay(dDataLanc)
										dDataFim :=  LastDay(dDataLanc)
									Case AKJ->AKJ_TPSLD == "4"
										dDataIni := CTOD("01/"+Str((Round(MONTH(dDataLanc)/2,0)*2)-1,2,0)+"/"+Str(Year(dDataLanc),4,0))
										dDataFim := LastDay(CTOD("01/"+Str((Round(MONTH(dDataLanc)/2,0)*2),2,0)+"/"+Str(Year(dDataLanc),4,0)))
									Case AKJ->AKJ_TPSLD == "5"
										If MONTH(dDataLanc)<7  //1o. semestre
											dDataIni := CTOD("01/01/"+Str(Year(dDataLanc),4,0))
											dDataFim := LastDay(CTOD("01/06/"+Str(Year(dDataLanc),4,0)))
									    Else //2o. semestre
											dDataIni := CTOD("01/07/"+Str(Year(dDataLanc),4,0))
											dDataFim := LastDay(CTOD("01/12/"+Str(Year(dDataLanc),4,0)))
										EndIf	
									Case AKJ->AKJ_TPSLD == "6"
										dDataIni := CTOD("01/01/"+Str(Year(dDataLanc),4,0))
										dDataFim := LastDay(CTOD("31/12/"+Str(Year(dDataLanc),4,0)))
									Case AKJ->AKJ_TPSLD == "7"
										dDataIni := CTOD("01/"+Str((Round(((MONTH(dDataLanc)+1)/(12/4)),0))*(12/4)-2,2,0)+"/"+Str(Year(dDataLanc),4,0))
										dDataFim := LastDay(CTOD("01/"+Str((Round(((MONTH(dDataLanc)+1)/(12/4)),0))*(12/4),2,0)+"/"+Str(Year(dDataLanc),4,0)))
								EndCase
								aDataIniFim[1] := dDataIni
								aDataIniFim[2] := dDataFim
								aFiltro		:= {}
								cCodCuboPrv  := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_PRVCFG, "AL4_CONFIG")
								dbSelectArea("AKW")
								dbSetOrder(1)
								MsSeek(xFilial()+cCodCuboPrv)
								cChav	:=	""
								cChavOri	:=	""
								aItCfgBlq	:=	{}
								nTamChav	:=	0
								While !Eof() .And. xFilial()+cCodCuboPrv == AKW->AKW_FILIAL+AKW->AKW_COD .And. AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR
									nTamChav	+=	AKW->AKW_TAMANH
									aAdd(aFiltro,&(AKW->AKW_CHAVER))
									cChaveAtu	:=	&(AKW->AKW_CHAVER)
									cChaveRel  	:= If(!Empty(AKW->AKW_CODREL),&(AKW->AKW_CODREL),cChaveAtu)
									If Empty(cChaveRel)
										cChaveRel := &(AKW->AKW_CHAVER)
									EndIf
									cChav	+=	If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))
									cChavOri := Padr(cChavOri+cChaveAtu,nTamChav)
									If AKJ->AKJ_NIVPR==AKW->AKW_NIVEL
										cChaveR := &(AKW->AKW_CONCCH)
									  	aAdd(aItCfgBlq, {cChav, ;
					  									{Nil}, ;
								  					AKW->AKW_CONCDE, ;
					  								AKW->AKW_ALIAS, ;
								  					AKW->AKW_ALIAS, ;
								  					&(AKW->AKW_DESCRE),;
								  					0,;
								  					Val(AKW->AKW_NIVEL),;
								  					cChavOri,;
								  					.F.,;
								  					0 ,;
								  					.F.,;
								  					"",;
													If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))})

									EndIf
									dbSkip()
								EndDo
								
								nMoedaCfg := AKJ->AKJ_MOEDPR

								aProcPrv  := PcoRunCube(cCodCuboPrv, 1, "PcoVerBloq", AKJ->AKJ_PRVCFG, 0,,.F.,aFiltro,aFiltro,.T.,aCfgAux,/*lProcessa*/,/*lVerAcesso*/,/*lForceNoSint*/,aItCfgBlq,/*aFiltCfg*/,/*cArqAKT*/,/*lLimpArqAKT*/,/*lVisao*/,.T./*lBloqueio*/)
								aAdd(aAuxFil, aClone(aCfgAux))
								nValPrv	:= 0
								nProc := ASCAN(aProcPrv, {|aVal| AllTrim(aVal[9]) == AllTrim(cChaveR).And.aVal[2][1] <> Nil})
								If nProc > 0
									nValPrv := aProcPrv[nProc][2][1]
								EndIf	
		
								aFiltro		:= {}
								aCfgAux     := {}
								cCodCuboReal := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
								dbSelectArea("AKW")
								dbSetOrder(1)
								MsSeek(xFilial()+cCodCuboReal)
								aItCfgBlq	:=	{}
								cChav		:=	""
								cChavOri	:=	"" 
								nTamChav	:=	0
								While !Eof() .And. xFilial()+cCodCuboReal == AKW->AKW_FILIAL+AKW->AKW_COD .And. AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR
									nTamChav	+=	AKW->AKW_TAMANH	
									aAdd(aFiltro,&(AKW->AKW_CHAVER))
									cChaveAtu	:=	&(AKW->AKW_CHAVER)
									cChaveRel  	:= If(!Empty(AKW->AKW_CODREL),&(AKW->AKW_CODREL),cChaveAtu)
									If Empty(cChaveRel)
										cChaveRel := &(AKW->AKW_CHAVER)
									EndIf
									cChav	+=	If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))
									cChavOri := Padr(cChavOri+cChaveAtu,nTamChav)
									If AKJ->AKJ_NIVPR==AKW->AKW_NIVEL
										cChaveR := &(AKW->AKW_CONCCH)                         
										cChaveRD := AKW->AKW_CONCDE

										cChaveR := &(AKW->AKW_CONCCH)
									  	aAdd(aItCfgBlq, {cChav, ;
				  									{Nil}, ;
							  					AKW->AKW_CONCDE, ;
				  								AKW->AKW_ALIAS, ;
							  					AKW->AKW_ALIAS, ;
							  					&(AKW->AKW_DESCRE),;
							  					0,;
							  					Val(AKW->AKW_NIVEL),;
							  					cChavOri,;
							  					.F.,;
							  					0 ,;
							  					.F.,;
							  					"",;
												If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))	 })
							
									EndIf
									dbSkip()
								EndDo
																	
								nMoedaCfg := AKJ->AKJ_MOEDRZ
								aProcReal := PcoRunCube(cCodCuboReal, 1, "PcoVerBloq", AKJ->AKJ_REACFG, 0,,.F.,aFiltro,aFiltro,.T.,aCfgAux,/*lProcessa*/,/*lVerAcesso*/,/*lForceNoSint*/,aItCfgBlq,/*aFiltCfg*/,/*cArqAKT*/,/*lLimpArqAKT*/,/*lVisao*/,.T./*lBloqueio*/)
								aAdd(aAuxFil, aClone(aCfgAux))

								nValReal	:= 0
								nProc := ASCAN(aProcReal, {|aVal| AllTrim(aVal[9]) == AllTrim(cChaveR) .And.aVal[2][1] <> Nil})
								If nProc > 0
									nValReal := aProcReal[nProc][2][1]
									If IsInCallStack("GPM670GRAVA")
										nValReal += M->E2_VALOR
									EndIf
								EndIf	
		                        
								If (AKJ->(FieldPos('AKJ_CALCVL'))> 0 .And. AKJ->AKJ_CALCVL== '1') .And. !Empty(AKJ->AKJ_BLOCK)
									__aDadosBlq	:=	{nMoedaCfg,nValReal,nValPrv,cChaveR,cProcesso,cItem,cPrograma,cChaveRD,aDataIniFim,aAuxFil}
									If PCOExecForm(AKJ->AKJ_BLOCK)
										lRet := .T.
									Else
										PcoIncr_QtBlq()
										lRet := .F.
										PcoFreeBlq(cProcesso,lUsaLote, AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
										Exit
									EndIf
								Else
									//Verifica se Ativa Solicita็ใo de Saldo de Contingencia
									If lSolicCT
										lRet := PCOA530({nMoedaCfg,nValReal,nValPrv,cChaveR,cProcesso,cItem,cPrograma,cChaveRD,aDataIniFim,aAuxFil,AKW->AKW_CONCCH} , @cMsgBlind  )

										If ! lRet
											PcoIncr_QtBlq()
											PcoFreeBlq(cProcesso,lUsaLote,  AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
											Exit
										Else
											// A partir da versใo 12.1.37 retirar o findFunction
											If FindFunction("PCO530CLIB")
												If (nValPrv  <= 0 .Or. Abs(nValReal) > Abs(nValPrv)) .and. Pco530CLib() 
													loop	
												EndIF
											EndIf
										EndIf
																
			                  //Compara os resultados dos 2 cubos
									ElseIf ExistBlock("PCOVLBLQ")
										If !ExecBlock("PCOVLBLQ",.f.,.f.,{nMoedaCfg,nValReal,nValPrv,cChaveR,cProcesso,cItem,cPrograma,cChaveRD,aDataIniFim,aAuxFil,lUsaLote,aPcoBkpBlq})
											PcoIncr_QtBlq()
											lRet := .F.
											PcoFreeBlq(cProcesso,lUsaLote,  AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
											Exit
										Else
											lRet := .T.
										EndIf
									Else
										lMrgBloq := AKJ->(FieldPos("AKJ_TIPMSG")) > 0 .AND. AKJ->(FieldPos("AKJ_PRCMRG")) > 0 .AND. AKJ->(FieldPos("AKJ_GRPUSR")) > 0
										If nValPrv  <= 0 .Or. Abs(nValReal) > Abs(nValPrv)
											cMensagem	:=	STR0003+DTOC(dDataIni)+" - "+DTOC(dDataFim)+"."+CHR(13)+CHR(10)+; //"Planejamento e Controle Orรงamentรกrio"###"Os saldos atuais do Planejamento e Controle Orรงamentรกrio sรฃo insuficientes para completar esta operaรงรฃo no periodo de "
																							STR0004+AllTrim(AKJ->AKJ_DESCRI)+CHR(13)+CHR(10)+; //"Tipo de Bloqueio : "
																							STR0005+AllTrim(cChaveRD)+CHR(13)+CHR(10)+; //"Cubo : "
																							STR0006+AllTrim(cChaveR)+CHR(13)+CHR(10)+; //"Chave  : "
																							STR0007+Str(nValPrv,14,2)+STR0008+Str(nValReal,14,2)+CHR(13)+CHR(10)
											If !isBlind()
												While .T.
													If nTimeOut > 0
														nDet := AvisoTimer(STR0002,cMensagem,{STR0009, STR0010},3,STR0011,,"CADEADO",nTimeOut,nOpcTime) //"Saldo Previsto : "###"  x Saldo Realizado : "###"&Fechar"###"Detalhes"###"Saldo Insuficiente"
													Else
														nDet := Aviso(STR0002,cMensagem,{STR0009, STR0010},3,STR0011,,"CADEADO") //"Saldo Previsto : "###"  x Saldo Realizado : "###"&Fechar"###"Detalhes"###"Saldo Insuficiente"
													EndIf	
													If nDet <= 1
												 		// Ponto de entrada que permite realizar customizacoes na acao do botao fechar
														If lPcoFecBl
													 		ExecBlock( "PCOFECBL", .F., .F. )
													 	EndIf
														Exit
													Else
														PcoDetBlq(cCodCuboPrv, cCodCuboReal, dDataIni, dDataFim, cChaveR, nValPrv, nValReal, aAuxFil)
													EndIf														
												End
											Else
												cMsgBlind := cMensagem
											EndIf
											PcoIncr_QtBlq()
											lRet := .F.
											PcoFreeBlq(cProcesso,lUsaLote,  AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
											Exit
										ElseIf lMrgBloq .AND. AKJ->AKJ_PRCMRG > 0.00 .AND. nValReal >= (nValPrv - (nValPrv * (AKJ->AKJ_PRCMRG/100)))	
											cAssunto	:= STR0047											
											cMsgEmail	:=	STR0048 + "<br><br>" + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
															STR0049 + "<b>" + TRANSFORM((nValReal/nValPrv)*100,"@E 999,999.99") + "%</b> " + STR0050 + " <b>" +;
															DTOC(dDataIni) + "</b> " + STR0051 + " <b>" + DTOC(dDataFim) + "</b>" + STR0052 +;
															STR0053 + "<br><br>" +;
															STR0054 + "<br><br>" + ;
															"<b>" + STR0004 + "</b>" +AllTrim(AKJ->AKJ_DESCRI)+ "<br>" +; //"Tipo de Bloqueio : "
															"<b>" + STR0005 + "</b>" +AllTrim(cChaveRD)+ "<br>" +; //"Cubo : "
															"<b>" + STR0006 + "</b>" +AllTrim(cChaveR)+ "<br> " +; //"Chave  : "
															"<b>" + STR0007 + "</b>" +TRANSFORM(nValPrv,PesqPict("AK2","AK2_VALOR"))+ "<br>" +;
															"<b>" + STR0055 + "</b>"+TRANSFORM(nValReal,PesqPict("AK2","AK2_VALOR"))+ "<br>" +;
															"<b>" + STR0056 + "</b>"+TRANSFORM((nValPrv-nValReal),PesqPict("AK2","AK2_VALOR"))+ "<br><br>" + STR0059
											/*
											 * Busca de destinatแrios do e-mail de aviso pr้-bloqueio or็amentแrio
											 */
											DbSelectArea("ALB") // Cadastro de Grupos de Usuรกrios do PCO
											ALB->(DbSetOrder(1)) // Filial + C๓digo do Grupo de Usuแrios
											If ALB->(DbSeek(XFILIAL("ALB") + AKJ->AKJ_GRPUSR ))
												cFilALC := XFILIAL("ALC")
												DbSelectArea("ALC") // Itens dos usuแrios do grupo de usuแrios do PCO
												ALC->(DbSetOrder(1)) // Filial + C๓digo do Grupo de Usuแrios + C๓digo do Usuแrio
												If ALC->(DbSeek(cFilALC + ALB->ALB_CODIGO ))
													While !ALC->(Eof()) .AND. cFilALC + ALB->ALB_CODIGO == ALC->(ALC_FILIAL + ALC_GRUPO)
														If ALC->ALC_BLKUSR == '2' .AND. ALC->ALC_ALERTA == '1' // Se o usuรกrio nรฃo estiver bloqueado e se recebe e-mail, entra nos destinatรกrios do e-mail de aviso
															aAdd(aDestinat,UsrRetMail(ALC->ALC_USUARI))
														EndIf
														ALC->(DbSkip())														
													EndDo
												EndIf
											EndIf
											
											
											If AKJ->AKJ_TIPMSG == '1' /// Aviso ao operador do sistema e e-mail para os administradores do grupo de usuรกrios do PCO
												cMensagem	:=	STR0057 + STR0002 + ; //"O bloqueio destas operaรงรตes estรก prรณximo, pois os saldos do ambiente "###"Planejamento e Controle Orรงamentรกrio"
															STR0058 + CVALTOCHAR(AKJ->AKJ_PRCMRG) + STR0066 +; //" jรก alcanรงaram "###"% do total no perรญodo de "
															DTOC(dDataIni) + " a " + DTOC(dDataFim) + "." + CHR(13)+CHR(10)+;
															STR0004+AllTrim(AKJ->AKJ_DESCRI)+CHR(13)+CHR(10)+; //"Tipo de Bloqueio : "
															STR0005+AllTrim(cChaveRD)+CHR(13)+CHR(10)+; //"Cubo : "
															STR0006+AllTrim(cChaveR)+CHR(13)+CHR(10)+; //"Chave  : "
															STR0007+TRANSFORM(nValPrv,PesqPict("AK2","AK2_VALOR"))+STR0008+TRANSFORM(nValReal,PesqPict("AK2","AK2_VALOR"))+CHR(13)+CHR(10)
															
												Aviso(STR0002,cMensagem,{STR0009},3,cAssunto,,"PMSINFO")
												PcoMail(aDestinat,cAssunto,cMsgEmail) 
											ElseIf AKJ->AKJ_TIPMSG == '2' // Somente envio de e-mail para os administradores do grupo de usuแrios do PCO
												PcoMail(aDestinat,cAssunto,cMsgEmail) 	
											EndIf
											lRet := .T.
										EndIf
									EndIf
								Endif									
							EndIf
						EndIf
						dbSelectArea("AKH")
						dbSKip()
					End
		   		Else   
			     	//Nao tem bloqueio cadastrado entao sai com TRUE
			     	lRet	:=	.T. 
					Exit
				Endif
		      	//O ultimo bloquieo cadastrado bloqueo o movimento, portanto nao precisa avaliar os proximos
				If !lRet
					Exit
				Endif	
			Next
		Else         
			//Nao gravou nenhum AKD, portanto nao avaliou bloque
			lRet := .T.
		EndIf
	EndIf
	

	RestInter()
	RestArea(aAreaAKA)
	RestArea(aAreaAKI)
	RestArea(aAreaSX3)
	RestArea(aArea)
EndIf

//Msg enviado quando vier de excauto 
If  !lNotBlind .and. !lRet
    Help('',1,"ERROR_PCO",,cMsgBlind,1,0)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOTstForณ Autor ณ Guilherme C. Leal      ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao das formulas de bloqueio do SIGAPCO       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOTstForm(cForm)
Local bRet
Local lRet := .F.
Local bErrBlock := ErrorBlock()

ErrorBlock( {|e| PCOFormErro(e) } )
                                                                   
BEGIN SEQUENCE

bRet := __CompStr(cForm)
If ValType(bRet) != "U"
	lRet := .T.
Else
	PCOFormErro()
	lRet := .F.
EndIf

RECOVER 

lRet := .F.
 
END SEQUENCE

ErrorBlock( bErrBlock )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOExecFoณ Autor ณ Guilherme C. Leal      ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que executa as formulas de bloqueio do SIGAPCO         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOExecForm(cForm)
Local bRet
Local lRet := .F.

Local bErrBlock := ErrorBlock()




ErrorBlock( {|e| PCOFormErro(e) } )
                                                                 
BEGIN SEQUENCE

bRet := __CompStr(cForm)
If ValType(bRet) != "U"
	lRet := __RunCB(bRet)
Else
	PCOFormErro()
	Return NIL
EndIf

RECOVER 

lRet := NIL

END SEQUENCE

ErrorBlock( bErrBlock )


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoVldLanณ Autor ณ Edson Maricate         ณ Data ณ 12-01-2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de validacao dos pontos de bloqueio do SIGAPCO         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOFormErro(oError,lError,cError,cMsg,lExibe)
                                               
Default cMsg 	:= ""
Default lExibe	:= .T.

If Valtype(oError) == "O"
	Alert(iif(Empty(cMsg),STR0062,cMsg)+iif(lExibe,CHR(13)+CHR(10)+AllTrim(oError:Description),"")) //"Existe um erro na fรณrmula digitada"
/*
	lError := .T.
	cError := CHR(13)+CHR(10)+AllTrim(oError:Description)
	//O HELP nao eh chamado dentro do bloco de erro (ERRORBLOCK())
	//Sao setadas as variaveis e chamado manualmente depois da chamada do erroblock
	HELP("  ",1,"PCOERRFORM",,CHR(13)+CHR(10)+AllTrim(oError:Description))
*/	
EndIf

BREAK

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoVerBloqณ Autor ณ Paulo Carnelossi      ณ Data ณ21/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao para retorno do saldo do cubo gerencial (bloqueio)   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPcoVerBloq                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PcoVerBloq(cConfig,cChave)
Local nMoeda := If(nMoedaCfg==1, AKJ->AKJ_MOEDPR, AKJ->AKJ_MOEDRZ)
Local aRetIni,aRetFim
Local nCrdIni := 0
Local nDebIni := 0
Local nCrdFim := 0
Local nDebFim := 0
Local nSldIni := 0
Local nSldFim := 0

If ! lSldAcum  //se nao for acumulado nao precisa calcular saldo inicial
	aRetIni := PcoRetSld(cConfig,cChave,aDataIniFim[1]-1)
	nCrdIni := aRetIni[1, nMoeda]
	nDebIni := aRetIni[2, nMoeda]
	nSldIni := nCrdIni-nDebIni
EndIf	
                                            	
aRetFim := PcoRetSld(cConfig,cChave,aDataIniFim[2])
nCrdFim := aRetFim[1, nMoeda]
nDebFim := aRetFim[2, nMoeda]

nSldFim := nCrdFim-nDebFim

Return {If(lSldAcum, nSldFim, nSldFim-nSldIni)}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoCfgLanc  บAutor  ณEdson Maricate    บ Data ณ  05/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigurador de Lancamento                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoCfgLanc()

Local aArea			:= GetArea()
Local aAreaAKC		:= AKC->(GetArea())
Local aAreaAKB		:= AKB->(GetArea())
Local aAreaAKD		:= AKD->(GetArea())
Local oDlg
Local oTree
Local oTree2
Local aHeadAKC		:= {}
Local aColsAKC		:= {}
Local aRecAKC		:= {}
Local nLenAKC 		:= 0
Local nLinAKC 		:= 0
Local aHeadAKD		:= {}
Local aColsAKD		:= {}
Local aCposEnch	:= {"AKD_LOTE","AKD_STATUS"}
Local nLenAKD 		:= 0
Local nLinAKD		:= 0  
Local nPosAtivo
Local cX			:= "" 
Local cVar		:= SPACE(100)
Local oBold
Local oPanel, oFolder, oPanel3, oPanel4, oPanel5, oPanel6, oPanel21, oPanel22
Local lRet := .T.
		
PRIVATE cTable		:= AKB->AKB_ENTIDA
Private oGdAKD
Private oGdAKC

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do AKC                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadAKC := GetaHeader("AKC")
nLenAKC  := Len(aHeadAKC) + 1
nPosAtivo:= AScan(aHeadAKC,{|x| Upper(AllTrim(x[2])) == "AKC_ATIVO" })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do AKC                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aColsAKC := {}
DbSelectArea("AKC")
DbSetOrder(1)
DbSeek(xFilial()+AKB->AKB_PROCES+AKB->AKB_ITEM)

While  !Eof() .And. AKC->AKC_FILIAL + AKC->AKC_PROCES + AKC->AKC_ITEM == xFilial() + AKB->AKB_PROCES + AKB->AKB_ITEM
	AAdd(aColsAKC,Array( nLenAKC ))
	nLinAKC++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKC, {|x,y| aColsAKC[nLinAKC][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKC[nLinAKC][nLenAKC] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKC, AKC->( Recno() ) )
	
	AKC->(DbSkip())
EndDo

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsAKC) = 0
	AAdd(aColsAKC,Array( nLenAKC ))
	nLinAKC++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKC, {|x,y| aColsAKC[nLinAKC][y] := IIf(Upper(AllTrim(x[2])) == "AKC_SEQ", StrZero(1,Len(AKC->AKC_SEQ)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKC[nLinAKC][nLenAKC] := .F.
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do AKD                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("AKD")

aHeadAKD := GetaHeader("AKD",,aCposEnch,{})
nLenAKD  := Len(aHeadAKD) + 1


nPosVal   := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL1"})
nPosVal2  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL2"})
nPosVal3  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL3"})
nPosVal4  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL4"})
nPosVal5  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL5"})
nPosIDRef := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDREF"})
nPosIdent := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDENT"})
nPosUMed  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_UM"})
If nPosIDRef > 0
//	aHeadAKD[nPosIDRef][1] := ""
	aHeadAKD[nPosIDRef][4] := 0
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do AKD                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aColsAKD := {}
AAdd(aColsAKD,Array( nLenAKD ))
nLinAKD++
// Varre o aHeader para preencher o acols
AEval(aHeadAKD, {|x,y| aColsAKD[nLinAKD][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

If nPosVal > 0
	aColsAKD[nLinAKD][nPosVal] := PCOPlanCel(AKD->AKD_VALOR1,AKD->AKD_CLASSE)
EndIf

If nPosVal2 > 0
	aColsAKD[nLinAKD][nPosVal2] := PCOPlanCel(AKD->AKD_VALOR2,AKD->AKD_CLASSE)
EndIf

If nPosVal3 > 0
	aColsAKD[nLinAKD][nPosVal3] := PCOPlanCel(AKD->AKD_VALOR3,AKD->AKD_CLASSE)
EndIf

If nPosVal4 > 0
	aColsAKD[nLinAKD][nPosVal4] := PCOPlanCel(AKD->AKD_VALOR4,AKD->AKD_CLASSE)
EndIf

If nPosVal5 > 0
	aColsAKD[nLinAKD][nPosVal5] := PCOPlanCel(AKD->AKD_VALOR5,AKD->AKD_CLASSE)
EndIf

If nPosIdent > 0 .And. !Empty(AKD->AKD_IDREF)
	aAuxArea := GetArea()
	AK6->(dbSetOrder(1))
	AK6->(dbSeek(xFilial()+AKD->AKD_CLASSE))
	If !Empty(AK6->AK6_VISUAL)
		dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
		dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
		dbSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
		aColsAKD[nLinAKD][nPosIdent] := &(AK6->AK6_VISUAL)
	EndIf
	If nPosUMed > 0
		AK6->(dbSetOrder(1))
		AK6->(dbSeek(xFilial()+AKD->AKD_CLASSE))
		aAuxArea := GetArea()
		If !Empty(AK6->AK6_UM)
			If !Empty(AKD->AKD_IDREF)
				dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
				dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
				dbSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
			EndIf
			aColsAKD[nLinAKD][nPosUMed] := &(AK6->AK6_UM)
		EndIf
	EndIf
	RestArea(aAuxArea)
EndIf

// Deleted
aColsAKD[nLinAKD][nLenAKD] := .F.

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsAKD) = 0
	AAdd(aColsAKD,Array( nLenAKD ))
	nLinAKD++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKD, {|x,y| aColsAKD[nLinAKD][y] := IIf(Upper(AllTrim(x[2])) == "AKD_ID", StrZero(1,Len(AKD->AKD_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKD[nLinAKD][nLenAKD] := .F.
EndIf

DbSelectArea("AKC")

DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE STR0016+AllTrim(AKB->AKB_DESCRI) FROM 0,0 TO 480,850 PIXEL  //"Configuraรงรฃo On-Line de Lancamentos - "

	oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,110,110,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_LEFT

	oFolder := TFolder():New(121,2,{STR0017,STR0018},{},oPanel,,,, .T., .T.,390,110) //"Campos"###"Variaveis"
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel3 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_TOP

	oPanel4 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel4:Align := CONTROL_ALIGN_ALLCLIENT

	@ 1110,1110 MSGET oX VAR cX SIZE 1,1 


	TSay():New( 3, 3, MontaBlock("{|| '"+STR0063+"' }"), oPanel3 , ,oBold,,,,.T.)//"Tabela"

	@ 10,3 MSGET oTable VAR cTable SIZE 30,10 PIXEL Of oPanel3 F3 "SX21" PICTURE '@!' VALID ExistCpo("SX2") .And. Processa({|| CfgLoadTree(cTable,oTree,.T.)},STR0041,STR0044) HASBUTTON	// Aguarde...  ### Carregando dados.

	@ 10,40 BUTTON oIns Prompt ">>" SIZE 10 ,7  FONT oDlg:oFont ACTION {|| PCOCliqLan(1,oTree,aHeadAKC)} OF oPanel3 PIXEL When Substr(oTree:GetCargo(),1,3)=="FLD"
	TSay():New( 10, 52, MontaBlock("{|| '"+STR0019+"' }"), oPanel3 , ,oBold,,,,.T.,,,50,20) //"Clique aqui para inserir o campo"

	oTree := DbTree():New(1,1,10,10, oPanel4,,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT	
	
	CfgLoadTree(cTable,oTree)
	
	oPanel5 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel5:Align := CONTROL_ALIGN_TOP

	oPanel6 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel6:Align := CONTROL_ALIGN_ALLCLIENT


	TSay():New( 3, 3, MontaBlock("{|| '"+STR0001+"' }"), oPanel5 , ,oBold,,,,.T.) //Variavel
	@ 10,3 MSGET oVar VAR cVar SIZE 60,10 PIXEL Of oPanel5 VALID CfgLoadVar(cVar,oTree2) 

	oTree2 := DbTree():New(1,1,10,10, oPanel6,,,.T.)
	oTree2:Align := CONTROL_ALIGN_ALLCLIENT	

	oTree2:AddItem( Padr(STR0018,100),Padr("0",80),,,,,0)	 //"Variaveis"


	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,90,90,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel21 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
	oPanel21:Align := CONTROL_ALIGN_TOP

	TSay():New( 3, 4, MontaBlock("{|| '"+STR0039+"' }"), oPanel21 , ,oBold,,,,.T.) // "Configuraรงรฃo dos Lancamentos"

	oGdAKC:= MsNewGetDados():New(0,0,70,70,GD_INSERT+GD_UPDATE+GD_DELETE,,,"+AKC_SEQ",,,9999,,,,oPanel2,aHeadAKC,aColsAKC)
	oGdAKC:oBrowse:Align := CONTROL_ALIGN_TOP
	oGdAKC:CARGO := AClone(aRecAKC)
	oGdAKC:oBrowse:blDblClick:={|| If(  oGdAKC:oBrowse:nColPos == nPosAtivo , A040BMP(@oGdAKC,nPosAtivo), oGdAKC:EditCell() ) }

	oPanel22 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
	oPanel22:Align := CONTROL_ALIGN_TOP

	TSay():New( 3, 4, MontaBlock("{|| '"+STR0040+"' }"), oPanel22 , ,oBold,,,,.T.) // "Visualizaรงรฃo dos Lancamentos"
	@1,180 BTNBMP oBmp1 RESOURCE "RELOAD"   SIZE 25,25 ACTION PcoAtuLancto(@oGDAKC,@oGdAKD, 1) Of oPanel22

	oGdAKD:= MsNewGetDados():New(0,0,100,100,0,"AKDLinOK",,"+AKD_ID",,,9999,,,,oPanel2,aHeadAKD,aColsAKD)
	oGdAKD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	PcoAtuLancto(oGDAKC,oGDAKD, 1)

If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(PcoAtuLancto(oGDAKC,oGdAKD, 1).And.Aviso(STR0014,STR0020,{STR0012,STR0013},2)==1.And.PcoLanctoOk(oGdAKC,AKB->AKB_PROCES,AKB->AKB_ITEM),oDlg:End(),Nil) },{|| (lRet := .F., oDlg:End()) }) //"Atenรงรฃo!"###"Confirma gravaรงao da configuraรงรฃo do ponto de lanรงamento de acordo com as modificaรงรตes efetuadas ?"###"Sim"###"Nao"
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(PcoAtuLancto(oGDAKC,oGdAKD, 1).And.Aviso(STR0014,STR0020,{STR0012,STR0013},2)==1.And.PcoLanctoOk(oGdAKC,AKB->AKB_PROCES,AKB->AKB_ITEM),oDlg:End(),Nil) },{|| (lRet := .F., oDlg:End()) }) //"Atenรงรฃo!"###"Confirma gravaรงao da configuraรงรฃo do ponto de lanรงamento de acordo com as modificaรงรตes efetuadas ?"###"Sim"###"Nao"
EndIf

RestArea(aAreaAKC)
RestArea(aAreaAKB)
RestArea(aAreaAKD)
RestArea(aArea)      

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CfgLoadTree(cTable,oTree,lProc)
Local nItens	:= If(!Empty(cTable),(cTable)->(FCount()),0)
Local cCampo    := ""
Local aAreaSX3  := SX3->( GetArea() )

Default lProc	:=	.F.

If !Empty(cTable)
	oTree:Reset()
	oTree:AddItem( Padr(cTable,100),Padr("TAB"+cTable,80),,,,,0)
	oTree:Hide()
	
	If lProc
		Procregua( nItens )
	Endif
	SX3->( dbSetOrder( 1 ) )
	SX3->(	dbSeek((cTable)))
	
	While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cTable 
		If lProc
			IncProc()
		Endif
		cCampo:=SX3->X3_CAMPO 
		IF X3Uso(SX3->X3_USADO)
		  	IF alltrim(SX3->X3_CONTEXT) <>'V'	
				oTree:TreeSeek( Padr("TAB"+cTable,80) )
				oTree:AddItem( Padr(cCampo,100),Padr("FLD"+cCampo,80))
				oTree:TreeSeek( Padr("FLD"+cCampo,80) )
				oTree:AddItem( Padr(STR0021+AllTrim(X3DESCRIC()),100),Padr("DESCR"+cCampo,80),,,,,) //"Descriรงรฃo : "
				oTree:AddItem( Padr(STR0022+AllTrim(SX3->X3_TIPO),100),Padr("TIP"+cCampo,80),,,,,) //"Tipo : "
				oTree:AddItem( Padr(STR0023+AllTrim(Str(SX3->X3_TAMANHO,3)),100),Padr("TAM"+cCampo,80),,,,,) //"Tamanho : "
				oTree:AddItem( Padr(STR0024+AllTrim(Str(SX3->X3_DECIMAL,3)),100),Padr("DECI"+cCampo,80),,,,,) //"Decimal : "	
				If SX3->X3_TIPO == "C"
					oTree:AddItem( Padr(STR0025+AllTrim((cTable)->&(cCampo)),100),Padr("CONT"+cCampo,80),,,,,) //"Conteudo : "
				ElseIf SX3->X3_TIPO == "D"
					oTree:AddItem( Padr(STR0025+AllTrim(DTOC((cTable)->&(cCampo))),100),Padr("CONT"+cCampo,80),,,,,)	 //"Conteudo : "
				ElseIf SX3->X3_TIPO == "N"
					oTree:AddItem( Padr(STR0025+AllTrim(TransForm((cTable)->&(cCampo),SX3->X3_PICTURE)),100),Padr("CONT"+cCampo,80),,,,,)	 //"Conteudo : "
				EndIf
			EndIf	
		EndIF
		SX3->(DbSkip())	
	EndDo
	oTree:Show()
	oTree:Refresh()
Endif
RestArea( aAreaSX3 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CfgLoadVar(cVar,oTree)
Local nx

oTree:TreeSeek( Padr("0",80) )	
If Type(cVar) <> "U"
	If ValType(&cVar)=="C"
		oTree:AddItem( Padr(cVar,100),Padr("VAR"+cVar,80),,,,,0)	
		oTree:TreeSeek( Padr("VAR"+cVar,80) )	
		oTree:AddItem( Padr(STR0026,100),Padr("TIP"+cVar,80),,,,,) //"Tipo : Caracter"
		oTree:AddItem( Padr(STR0025+AllTrim(&cVar),100),Padr("CONT"+cVar,80),,,,,)		 //"Conteudo : "
	ElseIf ValType(&cVar)=="N"
		oTree:AddItem( Padr(cVar,100),Padr("VAR"+cVar,80),,,,,0)	
		oTree:TreeSeek( Padr("VAR"+cVar,80) )	
		oTree:AddItem( Padr(STR0027,100),Padr("TIP"+cVar,80),,,,,) //"Tipo : Numerica"
		oTree:AddItem( Padr(STR0025+AllTrim(Str(&cVar)),100),Padr("CONT"+cVar,80),,,,,)		 //"Conteudo : "
	ElseIf ValType(&cVar)=="L"
		oTree:AddItem( Padr(cVar,100),Padr("VAR"+cVar,80),,,,,0)	
		oTree:TreeSeek( Padr("VAR"+cVar,80) )	
		oTree:AddItem( Padr(STR0028,100),Padr("TIP"+cVar,80),,,,,) //"Tipo : Logica"
		oTree:AddItem( Padr(STR0025+If(&cVar,STR0029,STR0030),100),Padr("CONT"+cVar,80),,,,,)		 //"Conteudo : "###"Verdadeiro"###"Falso"
	ElseIf ValType(&cVar)=="A"
		oTree:AddItem( Padr(cVar,100),Padr("VAR"+cVar,80),,,,,0)	
		oTree:TreeSeek( Padr("VAR"+cVar,80) )	
		oTree:AddItem( Padr(STR0031,100),Padr("TIP"+cVar,80),,,,,) //"Tipo : Array"
		oTree:AddItem( Padr(STR0032,100),Padr("CX"+cVar,80),,,,,) //"Conteudo"
		oTree:TreeSeek( Padr("CX"+cVar,80) )	
		aArray := aClone(&cVar)
		LoadArray(cVar,aArray,oTree,1)
	EndIf
Else
	Aviso(STR0033,STR0034,{STR0061},2) //"Variavel indefinida."###"Variavel indefinida no momento. Verifique a variavel informada."###"Fechar"
EndIf

oTree:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LoadArray(cVar,aArray,oTree,nNivel)
Local nx
Local cSavCargo	:= oTree:GetCargo()

For nx := 1 to Len(aArray)
	oTree:TreeSeek( PadR(cSavCargo,80) )
	If ValType(aArray[nx])=="C"
		oTree:AddItem( Padr("["+AllTrim(Str(nNivel,3,0))+"]["+AllTrim(Str(nx,3,0))+STR0035+aArray[nx],100),Padr("CONT"+cVar+"["+Str(nNivel,3,0)+"]["+Str(nx)+"]",80),,,,,) //"] - Caracter : "
	ElseIf ValType(aArray[nx])=="N"
		oTree:AddItem( Padr("["+AllTrim(Str(nNivel,3,0))+"]["+AllTrim(Str(nx,3,0))+STR0036+Str(aArray[nx]),100),Padr("CONT"+cVar+"["+Str(nNivel,3,0)+"]["+Str(nx)+"]",80),,,,,)	 //"] - Numerico : "
	ElseIf ValType(aArray[nx])=="L"
		oTree:AddItem( Padr("["+AllTrim(Str(nNivel,3,0))+"]["+AllTrim(Str(nx,3,0))+STR0037+If(aArray[nx],STR0029,STR0030),100),Padr("CONT"+cVar+"["+Str(nNivel,3,0)+"]["+Str(nx)+"]",80),,,,,)		 //"] - Logico : "###"Verdadeiro"###"Falso"
	ElseIf ValType(aArray[nx])=="A"
		LoadArray(cVar,aArray[nNivel],oTree,nNivel++)
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoAtuLancto(oGDAKC,oGDAKD, nOpcCfg)
Return(PcoAtuGrid(oGDAKC,oGDAKD, nOpcCfg))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoAtuGrid(oGDCfg,oGDAKD, nOpcCfg)
Local uValor
Local cIDLan		:= StrZero(1,Len(AKD->AKD_ID))
Local nx, nTam		:= 0
Local nLinAKD		:= 0
Local nY, nZ, cNomCpo 	:= "", aCposNew := {}
Local bBlock		:= ErrorBlock()
Local lFormOk		:= .T.
Local aColsOri 		:= aClone(oGDAKD:aCols)
Local aCposErro 	:= {}

/*
Descricao do vetor aCposForm:

aCposForm[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
aCposForm[2] : Nome do campo na tabela de lancamentos (AKD)
aCposForm[3] : .T. - Utiliza funcao PcoPlancel()
			   .F. - Formula em expressao ADVPL        
aCposForm[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
aCposForm[5] : Resultado apos macro execucao
*/
Local aCposForm
Local aCpos_Form := {}
Local aCposArray := {}
Local aCposForm2 := {}
Local aBkpError  := {}
Local cTypeCpo, nLinhas, nElemChk
Local cExePre	:=	''
Local cNomeVal	:= ""
Local uValorLc	:= 0
Local lValorLc	:= .F.

aCposForm := PcoCposForm(nOpcCfg)

//carrega array aCposForm2 para tratamento de erro na digitacao
For nZ := 1 TO Len(aCposForm)
	aAdd(aCposForm2, aCposForm[nZ, 4])
Next	

aCposNew := PcoCposNew(nOpcCfg)

ErrorBlock( {|e| PCOFormErro(e,,,STR0042 + AllTrim(oGDCfg:aHeader[aScan(oGDCfg:aHeader,{|x| AllTrim(x[2])==Alltrim(aCposErro[nZ])}),1]),.F.)})	// Existe um erro na expressao digitada:


Begin Sequence

oGDAKD:aCols := {}

For nx := 1 to Len(oGDCfg:aCols)
	aCposErro 	:= aCposForm2
	aCposArray	:= {}

	If  !oGDCfg:aCols[nx][Len(oGDCfg:aCols[nx])].And.;
		GdFieldGet(If(nOpcCfg==1,"AKC_", "AKI_")+"ATIVO",nx,,oGDCfg:aHeader,oGDCfg:aCols) == BMP_ON

		//Verifica se existe uma funcao de usuario para ser executada antes 
		//de comecar o lancamento                                     
		cExePRE	:=	GdFieldGet(If(nOpcCfg==1,"AKC_", "AKI_")+'EXEPRE'	,nx,,oGDCfg:aHeader,oGDCfg:aCols)
		If GdFieldPos(If(nOpcCfg==1,"AKC_", "AKI_")+'EXEPRE',oGDCfg:aHeader) > 0 .And. !Empty(cEXEPRE)
			AAdd(aCposErro,If(nOpcCfg==1,"AKC_", "AKI_")+'EXEPRE')
			&(Alltrim(cExePRE)+IIf("("$Alltrim(cExePRE),"",IIf(nOpcCfg<>1,"(.F.)","(.T.)")))				      
	    Endif
		nTam := Len(aCposForm)
	
		For nZ := 1 to nTam
		
			If !Empty( GdFieldGet(aCposForm[nZ,1],nx,,oGDCfg:aHeader,oGDCfg:aCols ) )
				uValor := Eval( &( "{|| " + GdFieldGet(aCposForm[nZ,1],nx,,oGDCfg:aHeader,oGDCfg:aCols)+" }"))
		        aCposForm[nZ, 5] := uValor
	        EndIf
	        
		Next nZ
		aBkpError := AClone(aCposErro)
	
		/*
		Descricao do vetor aCpos_Form:    - sera utilizado para gravar resultado 
	                                      - aCposNew  - identico ao array aCposForm
		aCpos_Form[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
		aCpos_Form[2] : Nome do campo na tabela de lancamentos (AKD)
		aCpos_Form[3] : .T. - Utiliza funcao PcoPlancel()
				   .F. - Formula em expressao ADVPL        
		aCpos_Form[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
		aCpos_Form[5] : Resultado apos macro execucao
		*/
	
		nTam := Len(aCposNew)  
		//Para ser utilizado no bloco de erro
		aCposErro 	:= aCposNew
	
		For nZ := 1 TO nTam
				
			cNomCpo := aCposNew[nZ]
				
			If If(nOpcCfg==1, AKC->(FieldPos(cNomCpo)), AKI->(FieldPos(cNomCpo))) > 0 .And. !Empty(GdFieldGet(cNomCpo,nx,,oGDCfg:aHeader,oGDCfg:aCols))
				aAdd(aCpos_Form, { cNomCpo, ;
									StrTran(cNomCpo,If(nOpcCfg==1,"AKC_","AKI_"),"AKD_"), ;
									.F., ;
									cNomCpo, ;
									NIL })
				uValor := Eval( &( "{|| " +GdFieldGet(cNomCpo,nx,,oGDCfg:aHeader,oGDCfg:aCols)+" }"))
		      	aCpos_Form[Len(aCpos_Form), 5] := uValor
			EndIf
				
		Next  //nZ
		
		/*guarda no aCposArray todos os resultados Tipo = Array
		  e para outros tipos valida tipo do campo
		Estrutura do Array aCposArray
			aCposArray[nL,1] : Nome do campo na tabela de lancamentos (AKD)
			aCposArray[nL,2] : Tamanho do Array de resultado da macro execucao
			aCposArray[nL,3] : 1=aCposForm - 2=aCpos_Form (em q array vai buscar resultado)
			aCposArray[nL,4] : Elemento do Array para busca do resultado da macro execucao
		*/
		aCposErro	:=	{}
		AEval(aCposForm,{|x| aAdd(aCposErro, x[1]) })
		For nZ := 1 TO Len(aCposForm)
			If ValType(aCposForm[nZ, 5])=="A"  //Array
				aAdd(aCposArray, {aCposForm[nZ, 2], Len(aCposForm[nZ, 5]), 1, nZ } )
			Else
				//para outros ---> valida tipo do campo 
				If aCposForm[nZ, 5] != NIL .And. ValType(aCposForm[nZ, 5]) # TamSX3(aCposForm[nZ,2])[3]
					Alert( STR0043 + AllTrim(oGDCfg:aHeader[aScan(oGDCfg:aHeader,{|x| AllTrim(x[2])==aCposForm[nZ,1]})][1])) // Tipo de dado invรกlido informado na coluna: 
					Break
				EndIf
			EndIf	
		Next //nZ
		aCposErro	:=	{}		
		AEval(aCpos_Form,{|x| aAdd(aCposErro, x[1]) })
		For nZ := 1 TO Len(aCpos_Form)
			If ValType(aCpos_Form[nZ, 5])=="A"  //Array
				aAdd(aCposArray, {aCpos_Form[nZ, 2], Len(aCpos_Form[nZ, 5]), 2, nZ } )
			Else
				//para outros ---> valida tipo do campo 
				If aCpos_Form[nZ, 5] != NIL .And. ValType(aCpos_Form[nZ, 5]) # TamSX3(aCpos_Form[nZ,2])[3]
					Alert( STR0043 + AllTrim(oGDCfg:aHeader[aScan(oGDCfg:aHeader,{|x| AllTrim(x[2])==aCpos_Form[nZ,1]})][1])) // Tipo de dado invรกlido informado na coluna: 
					Break
				EndIf
			EndIf	
		Next //nZ
		
		//testa se todos estao do mesmo tamanho e do mesmo tipo 
		//for comeca do segundo elemento -- Retornos tipo Array
		For nZ := 2 TO Len(aCposArray)
			//verifica elemento anterior com atual
			If aCposArray[nZ-1, 2] != aCposArray[nZ, 2]
				Alert( STR0045+;  //"Os vetores com resultados estao com tamanho diferente."
						STR0046+ aCposArray[nZ-1, 1] + "/" +;  //"Verifique a expressao dos campos " 
						aCposArray[nZ, 1])
				Break
			EndIf
		Next //nZ
		
		//verifica se tipo esta de acordo com dicionario
		//para os campos que retornaram array
		For nZ := 1 TO Len(aCposArray)
			cTypeCpo := TamSX3(aCposArray[nZ,1])[3]
			
			//verifica se tipo esta de acordo com dicionario
			nElemChk := aCposArray[nZ,4]
			If aCposArray[nZ,3] == 1
				For nY := 1 TO Len(aCposForm[nElemChk, 5])
					If ValType(aCposForm[nElemChk, 5, nY]) # cTypeCpo
						Alert( STR0043 + AllTrim(oGDCfg:aHeader[aScan(oGDCfg:aHeader,{|x| AllTrim(x[2])==aCposForm[nElemChk,1]})][1])) // Tipo de dado invรกlido informado na coluna: 
						Break
					EndIf
				Next //nY
			Else
				For nY := 1 TO Len(aCpos_Form[nElemChk, 5])
					If ValType(aCpos_Form[nElemChk, 5, nY]) # cTypeCpo
						Alert( STR0043 + AllTrim(oGDCfg:aHeader[aScan(oGDCfg:aHeader,{|x| AllTrim(x[2])==aCpos_Form[nElemChk,1]})][1])) // Tipo de dado invรกlido informado na coluna: 
						Break
					EndIf
				Next //nY
			EndIf	
			
		Next //nZ
		
		aCposErro := AClone(aBkpError)
		//se nao falhou nenhuma validacao acrescenta linhas no acols
		If Len(aCposArray) > 0    //varias linhas
		
			nLinhas := aCposArray[1, 2]  // numero de linhas a adicionar no acols
			
			For nY := 1 TO nLinhas
			
				If PcoAcumValue(If(nOpcCfg==1,"AKC", "AKI"), aCposForm, aCpos_Form) > 0
			
					AAdd(oGDAKD:aCols,Array( Len(oGDAKD:aHeader)+1 ))
					nLinAKD++
					// Varre o aHeader para preencher o acols
					AEval(oGDAKD:aHeader, {|x,y| oGDAKD:aCols[nLinAKD][y] := IIf(Upper(AllTrim(x[2])) == "AKD_ID", StrZero(1,Len(AKD->AKD_ID)),CriaVar(AllTrim(x[2])) ) })
		
					// Deleted
					oGDAKD:aCols[nLinAKD][Len(oGDAKD:aHeader)+1 ] := .F.
				
					nTam := Len(aCposForm)

					For nZ := 1 to nTam
				
						If aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
						    If ValType(aCposForm[nZ,5]) == "A"
								uValor := aCposForm[nZ,5,nY]
						    Else
								uValor := aCposForm[nZ,5]
							EndIf	
							If aCposForm[nZ,3]
								oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==aCposForm[nZ,2]}) ] := PCOPlanCel(uValor,oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])=="AKD_CLASSE"})])
							Else
								oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==aCposForm[nZ,2]}) ] := uValor
							EndIf	
						EndIf
			                
					Next nZ
			
					nTam := Len(aCpos_Form)//Len(aCposNew)  
					//Para ser utilizado no bloco de erro
					aCposErro 	:= {}
					AEval(aCpos_Form,{|x| aAdd(aCposErro, x[1]) })
			
					For nZ := 1 TO nTam
						
						cNomCpo := aCpos_Form[nZ,1]//aCposNew[nZ]
						
						If If(nOpcCfg==1, AKC->(FieldPos(cNomCpo)), AKI->(FieldPos(cNomCpo)) ) > 0 .And. ;
							aCpos_Form[nZ,5] != NIL .And. !Empty(aCpos_Form[nZ,5])
							If ValType(aCpos_Form[nZ,5]) == "A"
								uValor := aCpos_Form[nZ,5,nY]
							Else
								uValor := aCpos_Form[nZ,5]
							EndIf	
							oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==StrTran(cNomCpo,If(nOpcCfg==1, "AKC_", "AKI_" ),"AKD_")}) ]	:= uValor
						EndIf
						
					Next  //nZ	
			
					oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])=="AKD_ID"}) ]	:= cIDLan
					cIDLan	:= SomaIt(cIDLan)		
			    EndIf
			    
			Next //nY
		
		Else  //uma unica linha
		            
			// Percorre os cinco campos de valor da configuracao checando se estao preenchidos
			nY		 := 1
			lValorLc := .F.
			cTabCfg	 := If( nOpcCfg==1, "AKC_", "AKI_" )
		         
			Do While !lValorLc .And. nY <= 5
				// Atualiza nZ que eh utilizada para identificar o campo no tratamento de erro (ErrorBlock)
				// Executa expressao do campo e verifica se estah preenchido
				cNomeVal := cTabCfg + "VALOR" + AllTrim( Str(nY) )
				nZ		 := AScan( aCposErro, cNomeVal )
				uValorLc := GdFieldGet( cNomeVal, nX,, oGDCfg:aHeader, oGDCfg:aCols )
				lValorLc := ( Eval( &( "{|| " + IIf( !Empty( uValorLc ), uValorLc, "0") + " }" ) ) > 0 )
				nY ++
			EndDo

			// Soh continua se existir algum campo de valor preenchido
			If	lValorLc
					
				AAdd(oGDAKD:aCols,Array( Len(oGDAKD:aHeader)+1 ))
				nLinAKD++
				// Varre o aHeader para preencher o acols
				AEval(oGDAKD:aHeader, {|x,y| oGDAKD:aCols[nLinAKD][y] := IIf(Upper(AllTrim(x[2])) == "AKD_ID", StrZero(1,Len(AKD->AKD_ID)),CriaVar(AllTrim(x[2])) ) })
		
				// Deleted
				oGDAKD:aCols[nLinAKD][Len(oGDAKD:aHeader)+1 ] := .F.

				nTam := Len(aCposForm)

				For nZ := 1 to nTam
			
					If aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
						uValor := aCposForm[nZ,5]
						If aCposForm[nZ,3]
							oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==aCposForm[nZ,2]}) ] := PCOPlanCel(uValor,oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])=="AKD_CLASSE"})])
						Else
							oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==aCposForm[nZ,2]}) ] := uValor
						EndIf	
					EndIf
		                
				Next nZ
		
				nTam := Len(aCpos_Form)//Len(aCposNew)  
				//Para ser utilizado no bloco de erro
				aCposErro 	:= {}
				AEval(aCpos_Form,{|x| aAdd(aCposErro, x[1]) })
		
				For nZ := 1 TO nTam
					
					cNomCpo := aCpos_Form[nZ, 1]
					
					If If(nOpcCfg==1,AKC->(FieldPos(cNomCpo)), AKI->(FieldPos(cNomCpo))) > 0 .And. ;
						aCpos_Form[nZ,5] != NIL .And. !Empty(aCpos_Form[nZ,5])
						uValor := aCpos_Form[nZ,5]
						oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])==StrTran(cNomCpo,If(nOpcCfg==1,"AKC_", "AKI_"),"AKD_")}) ]	:= uValor
					EndIf
					
				Next	
		
				oGDAKD:aCols[nLinAKD][aScan(oGdAKD:aHeader,{|x| Alltrim(x[2])=="AKD_ID"}) ]	:= cIDLan
				cIDLan	:= SomaIt(cIDLan)		
					
			EndIf		
		EndIf

	    //zerar posicao 5 (conteudo da macro execucacao)dos arrays aCposForm, aCpos_Form
		AEval(aCposForm,{|x| x[5] := NIL })
		AEval(aCpos_Form,{|x| x[5] := NIL })
	    
	EndIf

Next // nX


oGDAKD:oBrowse:Refresh()

ErrorBlock(bBlock)

Recover
                 
lFormOk := .F.                  
oGDAKD:aCols :=	aClone(aColsOri)
oGDAKD:oBrowse:Refresh()

ErrorBlock(bBlock)

End Sequence

Return lFormOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoCposForm(nOpcCfg)
Local aCposForm := {}    

Local nQtd

/*
Descricao do vetor aCposForm:

aCposForm[1] : Nome do campo na tabela de configuracao de lancamentos (AKC)
aCposForm[2] : Nome do campo na tabela de lancamentos (AKD)
aCposForm[3] : .T. - Utiliza funcao PcoPlancel()
			   .F. - Formula em expressao ADVPL        
aCposForm[4] : Nome do campo na grade de configuracao de lancamentos (AKC)p/ tratar erro
aCposForm[5] : Resultado apos macro execucao
*/

If nOpcCfg == 1    //Wizard de Configuracao de lancamento
	aCposForm     := {	{ "AKC_CO"    , "AKD_CO"    , .F., "AKC_CO"		, NIL },;
						 { "AKC_DATA"  , "AKD_DATA"  , .F., "AKC_DATA"		, NIL },;
						 { "AKC_CLASSE", "AKD_CLASSE", .F., "AKC_CLASSE"	, NIL },;
 						 { "AKC_HIST"  , "AKD_HIST"  , .F., "AKC_HIST"		, NIL },;
						 { "AKC_TPSALD", "AKD_TPSALD", .F., "AKC_TPSALD"	, NIL },;
						 { "AKC_TIPO"  , "AKD_TIPO"  , .F., "AKC_TIPO"		, NIL },;
						 { "AKC_UM"    , "AKD_UM"    , .F., "AKC_UM"		, NIL },;
						 { "AKC_VALOR1", "AKD_VAL1"  , .T., "AKC_VALOR1"	, NIL },;
						 { "AKC_VALOR2", "AKD_VAL2"  , .T., "AKC_VALOR2"	, NIL },;
						 { "AKC_VALOR3", "AKD_VAL3"  , .T., "AKC_VALOR3"	, NIL },;
						 { "AKC_VALOR4", "AKD_VAL4"  , .T., "AKC_VALOR4"	, NIL },;
						 { "AKC_VALOR5", "AKD_VAL5"  , .T., "AKC_VALOR5"	, NIL },;
						 { "AKC_OPER"  , "AKD_OPER"  , .F., "AKC_OPER"		, NIL } ;
					   }    
ElseIf nOpcCfg == 2    //Wizard de Configuracao de bloqueio

	aCposForm     := {	{ "AKI_CO"    , "AKD_CO"    , .F., "AKI_CO", NIL  },;
						 { "AKI_DATA"  , "AKD_DATA"  , .F., "AKI_DATA", NIL  },;
						 { "AKI_CLASSE", "AKD_CLASSE", .F., "AKI_CLASSE", NIL  },;
 						 { "AKI_HIST"  , "AKD_HIST"  , .F., "AKI_HIST", NIL  },;
						 { "AKI_TPSALD", "AKD_TPSALD", .F., "AKI_TPSALD", NIL  },;
						 { "AKI_TIPO"  , "AKD_TIPO"  , .F., "AKI_TIPO", NIL  },;
						 { "AKI_UM"    , "AKD_UM"    , .F., "AKI_UM", NIL  },;
						 { "AKI_VALOR1", "AKD_VAL1"  , .T., "AKI_VALOR1"	, NIL  },;
						 { "AKI_VALOR2", "AKD_VAL2"  , .T., "AKI_VALOR2"	, NIL  },;
						 { "AKI_VALOR3", "AKD_VAL3"  , .T., "AKI_VALOR3"	, NIL  },;
						 { "AKI_VALOR4", "AKD_VAL4"  , .T., "AKI_VALOR4"	, NIL  },;
						 { "AKI_VALOR5", "AKD_VAL5"  , .T., "AKI_VALOR5"	, NIL  },;
						 { "AKI_OPER"  , "AKD_OPER"  , .F., "AKI_OPER", NIL  } ;
					   }

ElseIf nOpcCfg == 3    //lancamento - utilizado na pcoDetLan()
	aCposForm     := {	{ "AKC_CO"    , "AKD_CO"    , .F., "AKC_CO"		, NIL },;
						 { "AKC_DATA"  , "AKD_DATA"  , .F., "AKC_DATA"		, NIL },;
						 { "AKC_CLASSE", "AKD_CLASSE", .F., "AKC_CLASSE"	, NIL },;
 						 { "AKC_HIST"  , "AKD_HIST"  , .F., "AKC_HIST"		, NIL },;
						 { "AKC_TPSALD", "AKD_TPSALD", .F., "AKC_TPSALD"	, NIL },;
						 { "AKC_TIPO"  , "AKD_TIPO"  , .F., "AKC_TIPO"		, NIL },;
						 { "AKC_UM"    , "AKD_UM"    , .F., "AKC_UM"		, NIL },;
						 { "AKC_VALOR1", "AKD_VALOR1", .T., "AKC_VALOR1"	, NIL },;
						 { "AKC_VALOR2", "AKD_VALOR2", .T., "AKC_VALOR2"	, NIL },;
						 { "AKC_VALOR3", "AKD_VALOR3", .T., "AKC_VALOR3"	, NIL },;
						 { "AKC_VALOR4", "AKD_VALOR4", .T., "AKC_VALOR4"	, NIL },;
						 { "AKC_VALOR5", "AKD_VALOR5", .T., "AKC_VALOR5"	, NIL },;
						 { "AKC_OPER"  , "AKD_OPER"  , .F., "AKC_OPER"		, NIL } ;
					   }    

ElseIf nOpcCfg == 4    //Configuracao de bloqueio utilizado funcao pcoVldLan()

	aCposForm     := {	{ "AKI_CO"    , "AKD_CO"    , .F., "AKI_CO", NIL  },;
						 { "AKI_DATA"  , "AKD_DATA"  , .F., "AKI_DATA", NIL  },;
						 { "AKI_CLASSE", "AKD_CLASSE", .F., "AKI_CLASSE", NIL  },;
 						 { "AKI_HIST"  , "AKD_HIST"  , .F., "AKI_HIST", NIL  },;
						 { "AKI_TPSALD", "AKD_TPSALD", .F., "AKI_TPSALD", NIL  },;
						 { "AKI_TIPO"  , "AKD_TIPO"  , .F., "AKI_TIPO", NIL  },;
						 { "AKI_UM"    , "AKD_UM"    , .F., "AKI_UM", NIL  },;
						 { "AKI_VALOR1", "AKD_VALOR1", .T., "AKI_VALOR1"	, NIL  },;
						 { "AKI_VALOR2", "AKD_VALOR2", .T., "AKI_VALOR2"	, NIL  },;
						 { "AKI_VALOR3", "AKD_VALOR3", .T., "AKI_VALOR3"	, NIL  },;
						 { "AKI_VALOR4", "AKD_VALOR4", .T., "AKI_VALOR4"	, NIL  },;
						 { "AKI_VALOR5", "AKD_VALOR5", .T., "AKI_VALOR5"	, NIL  },;
						 { "AKI_OPER"  , "AKD_OPER"  , .F., "AKI_OPER", NIL  } ;
					   }

ElseIf nOpcCfg == 5    //lancamento Integra็ใo - utilizado na pcoDetInt()
	aCposForm		:= {{ "AMK_CO"    , "AMJ_CO"    , .F., "AMK_CO"			, NIL },;
							 { "AMK_DATA"  , "AMJ_DATA"  , .F., "AMK_DATA"		, NIL },;
							 { "AMK_DATPLA", "AMJ_DATPLA", .F., "AMK_DATPLA"		, NIL },;
							 { "AMK_CLASSE", "AMJ_CLASSE", .F., "AMK_CLASSE"	, NIL },;
							 { "AMK_OPER"  , "AMJ_OPER"  , .F., "AMK_OPER"		, NIL },;
							 { "AMK_CC"		, "AMJ_CC"    , .F., "AMK_CC"			, NIL },;
							 { "AMK_ITCTB" , "AMJ_ITCTB" , .F., "AMK_ITCTB" 	, NIL },;
							 { "AMK_CLVLR" , "AMJ_CLVLR" , .F., "AMK_CLVLR" 	, NIL },;
							 { "AMK_TIPO"  , "AMJ_TIPO"  , .F., "AMK_TIPO"		, NIL },;
							 { "AMK_VALOR1", "AMJ_VALOR1", .F., "AMK_VALOR1"	, NIL },;
							 { "AMK_VALOR2", "AMJ_VALOR2", .F., "AMK_VALOR2"	, NIL },;
							 { "AMK_VALOR3", "AMJ_VALOR3", .F., "AMK_VALOR3"	, NIL },;
							 { "AMK_VALOR4", "AMJ_VALOR4", .F., "AMK_VALOR4"	, NIL },;
							 { "AMK_VALOR5", "AMJ_VALOR5", .F., "AMK_VALOR5"	, NIL };
					   	}         

	// Incluir a Unidade Orcamentaria e as novas entidades cadastradas
	If AMK->(FieldPos("AMK_UNIORC")) >  0
		aAdd(aCposForm,{ "AMK_UNIORC", "AMJ_UNIORC", .F., "AMK_UNIORC"	, NIL })
	EndIf 

	// Verifica a quantidade de entidades contabeis
	If nQtdEntid == NIL
		If cPaisLoc == "RUS"
			nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
		Else
			nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
		EndIf
	EndIf 

	If nQtdEntid > 4
		For nQtd := 5 To nQtdEntid
	   		aAdd(aCposForm,{ "AMK_ENT"+STRZERO(nQtd,2), "AMJ_ENT"+STRZERO(nQtd,2), .F., "AMK_ENT"+STRZERO(nQtd,2)	, NIL }) 
	 	Next
	EndIf 

EndIf

Return(aCposForm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoCposNew(nOpcCfg)
Local aCposNew := {} 
Local nQtd

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
	EndIf
EndIf 

If nOpcCfg == 1  //lancamento
	aAdd(aCposNew, "AKC_CODPLA")
	aAdd(aCposNew, "AKC_VERSAO")
	aAdd(aCposNew, "AKC_CC")
	aAdd(aCposNew, "AKC_ITCTB")
	aAdd(aCposNew, "AKC_CLVLR")  
	
	// Incluir a Unidade Orcamentaria e as novas entidades cadastradas
	If AKC->(FieldPos("AKC_UNIORC")) >  0
		aAdd(aCposNew, "AKC_UNIORC")
	EndIf 
		
	If nQtdEntid > 4
		For nQtd := 5 To nQtdEntid
	   		aAdd(aCposNew,"AKC_ENT"+STRZERO(nQtd,2)) 
	 	Next
	EndIf     
	
	If aCpoUsrAKC == Nil
		aCpoUsrAKC :=	{}
		DbSelectArea('SX3')
		DbSetOrder(1)
	   	DbSeek('AKC')
	   	While !EOF() .And. X3_ARQUIVO == "AKC"
			If SX3->X3_PROPRI == "U" 
	  		 	AAdd(aCpoUsrAKC,Alltrim(SX3->X3_CAMPO))
	  		Endif	
	  		DbSkip()
	  	Enddo                                    
	Endif                
	AEval(aCpoUsrAKC,{|x| aAdd(aCposNew,x)})

ElseIf nOpcCfg == 2  //bloqueio
	aAdd(aCposNew, "AKI_CODPLA")
	aAdd(aCposNew, "AKI_VERSAO")
	aAdd(aCposNew, "AKI_CC")
	aAdd(aCposNew, "AKI_ITCTB")
	aAdd(aCposNew, "AKI_CLVLR")  
	
	// Incluir a Unidade Orcamentaria e as novas entidades cadastradas
	If AKI->(FieldPos("AKI_UNIORC")) >  0
		aAdd(aCposNew, "AKI_UNIORC")
	EndIf 
		
	If nQtdEntid > 4
		For nQtd := 5 To nQtdEntid
	   		aAdd(aCposNew,"AKI_ENT"+STRZERO(nQtd,2)) 
	 	Next
	EndIf 
	
	If aCpoUsrAKI == Nil
		aCpoUsrAKI :=	{}
		DbSelectArea('SX3')
		DbSetOrder(1)
	   	DbSeek('AKI')
	   	While !EOF() .And. X3_ARQUIVO == "AKI"
		   If SX3->X3_PROPRI == "U" 
	  		 	AAdd(aCpoUsrAKI,Alltrim(SX3->X3_CAMPO))
	  		Endif	
	  		DbSkip()
	  	Enddo                                    
	Endif                
	AEval(aCpoUsrAKI,{|x| aAdd(aCposNew,x)})

ElseIf nOpcCfg == 3  //utilizado na funcao PcoDetLan()/PcoVldLan()
	aAdd(aCposNew, "AKD_CODPLA")
	aAdd(aCposNew, "AKD_VERSAO")
	aAdd(aCposNew, "AKD_CC")
	aAdd(aCposNew, "AKD_ITCTB")
	aAdd(aCposNew, "AKD_CLVLR")

	// Incluir a Unidade Orcamentaria e as novas entidades cadastradas
	If AKD->(FieldPos("AKD_UNIORC")) >  0
		aAdd(aCposNew, "AKD_UNIORC")
	EndIf 

	If nQtdEntid > 4
		For nQtd := 5 To nQtdEntid
	   		aAdd(aCposNew,"AKD_ENT"+STRZERO(nQtd,2)) 
	 	Next
	EndIf 

	If aCposUsr == Nil
		aCposUsr :=	{}
		DbSelectArea('SX3')
		DbSetOrder(1)
	   DbSeek('AKD')
	   While !EOF() .And. X3_ARQUIVO == "AKD"
		   If SX3->X3_PROPRI == "U" 
	  		 	AAdd(aCposUsr,Alltrim(SX3->X3_CAMPO))
	  		Endif	
	  		DbSkip()
	  	Enddo                                    
	Endif                
	AEval(aCposUsr,{|x| aAdd(aCposNew,x)})
ElseIf nOpcCfg == 4  //utilizado na funcao PcoDetInt()  


	// Incluir a Unidade Orcamentaria e as novas entidades cadastradas
	If AMJ->(FieldPos("AMJ_UNIORC")) >  0
		aAdd(aCposNew, "AMJ_UNIORC")
	EndIf 

	If nQtdEntid > 4
		For nQtd := 5 To nQtdEntid
	   		aAdd(aCposNew,"AMJ_ENT"+STRZERO(nQtd,2)) 
	 	Next
	EndIf 

	If aCpoUsrAMJ == Nil
		aCpoUsrAMJ :=	{}
		DbSelectArea('SX3')
		DbSetOrder(1)
	   DbSeek('AMJ')
	   While !EOF() .And. X3_ARQUIVO == "AMJ"
		   If SX3->X3_PROPRI == "U" 
	  		 	AAdd(aCpoUsrAMJ,Alltrim(SX3->X3_CAMPO))
	  		Endif	
	  		DbSkip()
	  	Enddo                                    
	Endif                
	AEval(aCpoUsrAMJ,{|x| aAdd(aCposNew,x)})
EndIf

Return(aCposNew)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoLanctoOk(oGdAKC,cProcess,cItem)

Local nI

If !LanctoVld(oGdAKC)
	Return .F.
EndIf

// Grava as configuracoes dos Lancamento
For nI := 1 To Len(oGdAKC:aCols)
	If nI <= Len(oGdAKC:Cargo) .And. oGdAKC:Cargo[nI] > 0
		AKC->(DbGoto(oGdAKC:Cargo[nI]))
		Reclock("AKC",.F.)
	Else
		If oGdAKC:aCols[nI][Len(oGdAKC:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKC",.T.)
		EndIf
	EndIf

	If oGdAKC:aCols[nI][Len(oGdAKC:aCols[nI])] // Verifica se a linha esta deletada
		AKC->(DbDelete())
	Else
		// Varre o aHeader e grava com base no acols
		AEval(oGdAKC:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKC:aCols[nI][y] ) })
		Replace AKC_FILIAL With xFilial()
		Replace AKC_PROCES With cProcess
		Replace AKC_ITEM   With cItem

	EndIf

	MsUnlock()
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LanctoVld(oGdAKC)
Local nI
Local nPosField

For nI := 1 To Len(oGdAKC:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKC:aHeader,{|x,y| x[17] .And. Empty(oGdAKC:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0038 + AllTrim(oGdAKC:aHeader[nPosField][1]) + STR0060+Str(nI,3,0),3,1)  //"Campo:"###"Linha : "
		Return .F.
	EndIf
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoCfgBlq()

Local aArea			:= GetArea()
Local aAreaAKI		:= AKI->(GetArea())
Local aAreaAKA		:= AKA->(GetArea())
Local aAreaAKD		:= AKD->(GetArea())
Local oDlg
Local oTree
Local oTree2
Local aHeadAKI		:= {}
Local aColsAKI		:= {}
Local aRecAKI		:= {}
Local nLenAKI 		:= 0
Local nLinAKI 		:= 0
Local aHeadAKD		:= {}
Local aColsAKD		:= {}
Local aCposEnch	:= {"AKD_LOTE","AKD_STATUS"}
Local nLenAKD 		:= 0
Local nLinAKD		:= 0  
Local nPosAtivo
Local cX			:= "" 
Local cVar		:= SPACE(100)
Local oBold		
Local oPanel, oFolder, oPanel3, oPanel4, oPanel5, oPanel6, oPanel21, oPanel22

PRIVATE cTable		:= "   "
Private oGdAKD
Private oGdAKI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do AKI                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadAKI := GetaHeader("AKI")
nLenAKI  := Len(aHeadAKI) + 1
nPosAtivo:= AScan(aHeadAKI,{|x| Upper(AllTrim(x[2])) == "AKI_ATIVO" })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do AKI                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aColsAKI := {}
DbSelectArea("AKI")
DbSetOrder(1)
DbSeek(xFilial()+AKA->AKA_PROCES+AKA->AKA_ITEM)

While  !Eof() .And. AKI->AKI_FILIAL + AKI->AKI_PROCES + AKI->AKI_ITEM == xFilial() + AKA->AKA_PROCES + AKA->AKA_ITEM
	AAdd(aColsAKI,Array( nLenAKI ))
	nLinAKI++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKI, {|x,y| aColsAKI[nLinAKI][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKI[nLinAKI][nLenAKI] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKI, AKI->( Recno() ) )
	
	AKI->(DbSkip())
EndDo

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsAKI) = 0
	AAdd(aColsAKI,Array( nLenAKI ))
	nLinAKI++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKI, {|x,y| aColsAKI[nLinAKI][y] := IIf(Upper(AllTrim(x[2])) == "AKI_SEQ", StrZero(1,Len(AKI->AKI_SEQ)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKI[nLinAKI][nLenAKI] := .F.
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do AKD                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("AKD")

aHeadAKD := GetaHeader("AKD",,aCposEnch,{})
nLenAKD  := Len(aHeadAKD) + 1


nPosVal   := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL1"})
nPosVal2  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL2"})
nPosVal3  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL3"})
nPosVal4  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL4"})
nPosVal5  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_VAL5"})
nPosIDRef := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDREF"})
nPosIdent := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_IDENT"})
nPosUMed  := AScan(aHeadAKD,{|x| Upper(AllTrim(x[2])) == "AKD_UM"})
If nPosIDRef > 0
	aHeadAKD[nPosIDRef][1] := ""
	aHeadAKD[nPosIDRef][4] := 0
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do AKD                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aColsAKD := {}
AAdd(aColsAKD,Array( nLenAKD ))
nLinAKD++
// Varre o aHeader para preencher o acols
AEval(aHeadAKD, {|x,y| aColsAKD[nLinAKD][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

If nPosVal > 0
	aColsAKD[nLinAKD][nPosVal] := PCOPlanCel(AKD->AKD_VALOR1,AKD->AKD_CLASSE)
EndIf

If nPosVal2 > 0
	aColsAKD[nLinAKD][nPosVal2] := PCOPlanCel(AKD->AKD_VALOR2,AKD->AKD_CLASSE)
EndIf

If nPosVal3 > 0
	aColsAKD[nLinAKD][nPosVal3] := PCOPlanCel(AKD->AKD_VALOR3,AKD->AKD_CLASSE)
EndIf

If nPosVal4 > 0
	aColsAKD[nLinAKD][nPosVal4] := PCOPlanCel(AKD->AKD_VALOR4,AKD->AKD_CLASSE)
EndIf

If nPosVal5 > 0
	aColsAKD[nLinAKD][nPosVal5] := PCOPlanCel(AKD->AKD_VALOR5,AKD->AKD_CLASSE)
EndIf

If nPosIdent > 0 .And. !Empty(AKD->AKD_IDREF)
	aAuxArea := GetArea()
	AK6->(dbSetOrder(1))
	AK6->(dbSeek(xFilial()+AKD->AKD_CLASSE))
	If !Empty(AK6->AK6_VISUAL)
		dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
		dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
		dbSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
		aColsAKD[nLinAKD][nPosIdent] := &(AK6->AK6_VISUAL)
	EndIf
	
	If nPosUMed > 0
		AK6->(dbSetOrder(1))
		AK6->(dbSeek(xFilial()+AKD->AKD_CLASSE))
		aAuxArea := GetArea()
		If !Empty(AK6->AK6_UM)
			If !Empty(AKD->AKD_IDREF)
				dbSelectArea(Substr(AKD->AKD_IDREF,1,3))
				dbSetOrder(Val(Substr(AKD->AKD_IDREF,4,2)))
				dbSeek(Substr(AKD->AKD_IDREF,6,Len(AKD->AKD_IDREF)))
			EndIf
			aColsAKD[nLinAKD][nPosUMed] := &(AK6->AK6_UM)
		EndIf
	EndIf
	RestArea(aAuxArea)
EndIf

// Deleted
aColsAKD[nLinAKD][nLenAKD] := .F.

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsAKD) = 0
	AAdd(aColsAKD,Array( nLenAKD ))
	nLinAKD++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKD, {|x,y| aColsAKD[nLinAKD][y] := IIf(Upper(AllTrim(x[2])) == "AKD_ID", StrZero(1,Len(AKD->AKD_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAKD[nLinAKD][nLenAKD] := .F.
EndIf

DbSelectArea("AKI")

DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE STR0016+AllTrim(AKA->AKA_DESCRI) FROM 0,0 TO 480,850 PIXEL  //"Configuraรงรฃo On-Line de Lancamentos - "

	oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,110,110,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_LEFT

	oFolder := TFolder():New(121,2,{STR0017,STR0018},{},oPanel,,,, .T., .T.,390,110) //"Campos"###"Variaveis"
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel3 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_TOP

	oPanel4 := TPanel():New(0,0,'',oFolder:aDialogs[1], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel4:Align := CONTROL_ALIGN_ALLCLIENT

	@ 1110,1110 MSGET oX VAR cX SIZE 1,1 


	TSay():New( 3, 3, MontaBlock("{|| '"+STR0015+"' }"), oPanel3 , ,oBold,,,,.T.) // "Tabela"
	@ 10,3 MSGET oTable VAR cTable SIZE 30,10 PIXEL Of oPanel3 F3 "SX21" VALID ExistCpo("SX2") .And. Processa({|| CfgLoadTree(cTable,oTree,.T.)},STR0041,STR0044) HASBUTTON	// Aguarde...  ### Carregando dados.

	@ 10,40 BUTTON oIns Prompt ">>" SIZE 10 ,7  FONT oDlg:oFont ACTION {|| PCOCliqLan(2,oTree,aHeadAKI) } OF oPanel3 PIXEL When Substr(oTree:GetCargo(),1,3)=="FLD"
	TSay():New( 10, 52, MontaBlock("{|| '"+STR0019+"' }"), oPanel3 , ,oBold,,,,.T.,,,50,20) //Clique aqui para inserir o campo

	oTree := DbTree():New(1,1,10,10, oPanel4,,,.T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT	
	
	
	oPanel5 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel5:Align := CONTROL_ALIGN_TOP

	oPanel6 := TPanel():New(0,0,'',oFolder:aDialogs[2], , .T., .T.,, ,30,30,.T.,.T. )
	oPanel6:Align := CONTROL_ALIGN_ALLCLIENT


	TSay():New( 3, 3, MontaBlock("{|| '"+STR0001+"' }"), oPanel5 , ,oBold,,,,.T.) //Variavel
	@ 10,3 MSGET oVar VAR cVar SIZE 60,10 PIXEL Of oPanel5 VALID CfgLoadVar(cVar,oTree2) 

	oTree2 := DbTree():New(1,1,10,10, oPanel6,,,.T.)
	oTree2:Align := CONTROL_ALIGN_ALLCLIENT	

	oTree2:AddItem( Padr(STR0018,100),Padr("0",80),,,,,0)	 //"Variaveis"


	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,90,90,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel21 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
	oPanel21:Align := CONTROL_ALIGN_TOP

	TSay():New( 3, 4, MontaBlock("{|| '"+STR0039+"' }"), oPanel21 , ,oBold,,,,.T.) //"Configuraรงรฃo dos Lancamentos"

	oGdAKI:= MsNewGetDados():New(0,0,70,70,GD_INSERT+GD_UPDATE+GD_DELETE,,,"+AKI_SEQ",,,9999,,,,oPanel2,aHeadAKI,aColsAKI)
	oGdAKI:oBrowse:Align := CONTROL_ALIGN_TOP
	oGdAKI:CARGO := AClone(aRecAKI)
	oGdAKI:oBrowse:blDblClick:={|| If(  oGdAKI:oBrowse:nColPos == nPosAtivo , A040BMP(@oGdAKI,nPosAtivo), oGdAKI:EditCell() ) }

	oPanel22 := TPanel():New(0,0,'',oPanel2, oDlg:oFont, .T., .T.,, ,15,15,.T.,.T. )
	oPanel22:Align := CONTROL_ALIGN_TOP

	TSay():New( 3, 4, MontaBlock("{|| '"+STR0040+"' }"), oPanel22 , ,oBold,,,,.T.) //"Visualizaรงรฃo dos Lancamentos"
	@1,180 BTNBMP oBmp1 RESOURCE "RELOAD"   SIZE 25,25 ACTION  PcoAtuBlq(@oGDAKI,@oGdAKD, 2) Of oPanel22

	oGdAKD:= MsNewGetDados():New(0,0,100,100,0,"AKDLinOK",,"+AKD_ID",,,9999,,,,oPanel2,aHeadAKD,aColsAKD)
	oGdAKD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	PcoAtuBlq(oGDAKI,oGDAKD, 2)

If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(PcoAtuBlq(oGDAKI,oGDAKD, 2).And.Aviso(STR0014,STR0020,{STR0012,STR0013},2)==1.And.BlqOk(oGdAKI,AKA->AKA_PROCES,AKA->AKA_ITEM),oDlg:End(),Nil) },{|| oDlg:End() }) //"Atenรงรฃo!"###"Confirma gravaรงao da configuraรงรฃo do ponto de lanรงamento de acordo com as modificaรงรตes efetuadas ?"###"Sim"###"Nao"
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(PcoAtuBlq(oGDAKI,oGDAKD, 2).And.Aviso(STR0014,STR0020,{STR0012,STR0013},2)==1.And.BlqOk(oGdAKI,AKA->AKA_PROCES,AKA->AKA_ITEM),oDlg:End(),Nil) },{|| oDlg:End() }) //"Atenรงรฃo!"###"Confirma gravaรงao da configuraรงรฃo do ponto de lanรงamento de acordo com as modificaรงรตes efetuadas ?"###"Sim"###"Nao"
EndIf

RestArea(aAreaAKI)
RestArea(aAreaAKA)
RestArea(aAreaAKD)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function BlqOk(oGdAKI,cProcess,cItem)
Local aArea := GetArea()
Local nI

If !BlqVld(oGdAKI)
	RestArea(aArea)
	Return .F.
EndIf

// Grava as configuracoes dos Lancamento
For nI := 1 To Len(oGdAKI:aCols)
	If nI <= Len(oGdAKI:Cargo) .And. oGdAKI:Cargo[nI] > 0
		dbSelectArea("AKI")
		DbGoto(oGdAKI:Cargo[nI])
		Reclock("AKI",.F.)
	Else
		If oGdAKI:aCols[nI][Len(oGdAKI:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			dbSelectArea("AKI")
			Reclock("AKI",.T.)
		EndIf
	EndIf

	If oGdAKI:aCols[nI][Len(oGdAKI:aCols[nI])] // Verifica se a linha esta deletada
		AKI->(DbDelete())
	Else
		// Varre o aHeader e grava com base no acols
		AEval(oGdAKI:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKI:aCols[nI][y] ) })
		Replace AKI_FILIAL With xFilial()
		Replace AKI_PROCES With cProcess
		Replace AKI_ITEM   With cItem

	EndIf

	MsUnlock()
Next nI

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BlqVld(oGdAKI)
Local nI
Local nPosField

For nI := 1 To Len(oGdAKI:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKI:aHeader,{|x,y| x[17] .And. Empty(oGdAKI:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0038 + AllTrim(oGdAKI:aHeader[nPosField][1]) + STR0060+Str(nI,3,0),3,1)  //"Campo:"###"Linha : "
		Return .F.
	EndIf
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoAtuBlq(oGDAKI,oGDAKD, nOpcCfg)
Return(PcoAtuGrid(oGDAKI,oGDAKD, nOpcCfg))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAbreArqบAutor  ณPaulo Carnelossi    บ Data ณ  11/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para abertura dos arquivos ao iniciar o processo de  บฑฑ
ฑฑบ          ณcontabilizacao do modulo SigaPCO                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoAbreArq(cProcesso)
Local aArea  
Local aBind 
Local cKeyJson := FWxFilial("AKB")+cProcesso

//- verifica a Exit๊ncia do objeto Json
If _oJsonPCOArq == nil 
	_oJsonPCOArq := JsonObject():New()
EndIf 
//- Verifica a exist๊ncia da chave, para indica se jแ houve a 
//- abertura dos alias
If _oJsonPCOArq[cKeyJson] == nil 
	_oJsonPCOArq[cKeyJson] := .T.
	aArea := GetArea()
	aBind := {}
	If _cQryPCOArq == nil 
		_cQryPCOArq := "SELECT DISTINCT AKB_ENTIDA FROM "
		_cQryPCOArq += RetSqlName("AKB")
		_cQryPCOArq += " WHERE AKB_FILIAL = ? "
		_cQryPCOArq += " AND AKB_PROCES   = ? "
		_cQryPCOArq += " AND D_E_L_E_T_   = ? "
		_cQryPCOArq := ChangeQuery(_cQryPCOArq)
	EndIf 
	AADD(aBind,FWxFilial("AKB"))
	AADD(aBind,cProcesso)
	AADD(aBind,Space(1))
	dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_cQryPCOArq,aBind),'QPcoAbreArq')


	While QPcoAbreArq->(!Eof())

		dbSelectArea(QPcoAbreArq->AKB_ENTIDA)
		QPcoAbreArq->(dbSkip())

	End
	QPcoAbreArq->(dbCloseArea())

	RestArea(aArea)
	aSize(aArea,0)
	aArea := nil 
EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCODetBlq(cCodCuboPrv, cCodCuboReal, dDataIni, dDataFim, cChaveR, nValPrv, nValReal, aAuxFil)

Local aArea := GetArea()
Local aAreaAKD := AKD->(GetArea())
Local aAreaAL1 := AL1->(GetArea())

Local cFiltroAKD := ""
Local cCadAnt := cCadastro
Local nNivel 
Local lItCfgBlq := ValType(aItCfgBlq) <> Nil

//primeiro o ORCADO
dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial("AL1")+cCodCuboPrv)
cCadastro := STR0064 //"Detalhes do Saldo Orcado"
cFiltroAKD	:= 'AKD->AKD_FILIAL = "'+xFilial("AKD")+'" .And. DTOS(AKD->AKD_DATA) <= "' +DTOS(dDataFim)+'"'
If lItCfgBlq
	nNivel := aItCfgBlq[1][8]
EndIf
C340MontaFiltro(cCodCuboPrv, @cFiltroAKD, aAuxFil, 1/*nSerie*/,nNivel)
DbSelectArea("AL4")
If lItCfgBlq
	AL4->(DbSetOrder(1))
	AL4->(DbSeek(xFilial("AL4")+AKJ->AKJ_PRVCFG+cCodCuboPrv+(STRZERO(nNivel+1,2))    ))
	cFiltroAKD += aItCfgBlq[1][1]+'" .And. AKD->AKD_TPSALD >= "'+Alltrim(AL4->AL4_EXPRIN)+'" .And.  AKD->AKD_TPSALD <= "'+Alltrim(AL4->AL4_EXPRFI)+'" ' 
EndIf
Pcoc330lct(cFiltroAKD)

//segundo o REALIZADO
dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial("AL1")+cCodCuboReal)
cCadastro := STR0065 //"Detalhes do Saldo Realizado"
cFiltroAKD	:= 'AKD->AKD_FILIAL = "'+xFilial("AKD")+'" .And. DTOS(AKD->AKD_DATA) <= "' +DTOS(dDataFim)+'"'
If lItCfgBlq
	nNivel := aItCfgBlq[1][8]
EndIf
C340MontaFiltro(cCodCuboReal, @cFiltroAKD, aAuxFil, 2/*nSerie*/,nNivel)
If lItCfgBlq
	AL4->(DbSetOrder(1))
	AL4->(DbSeek(xFilial("AL4")+AKJ->AKJ_REACFG+cCodCuboReal+(STRZERO(nNivel+1,2))))
	cFiltroAKD += aItCfgBlq[1][1]+'" .And. AKD->AKD_TPSALD >= "'+Alltrim(AL4->AL4_EXPRIN)+'" .And.  AKD->AKD_TPSALD <= "'+Alltrim(AL4->AL4_EXPRFI)+'" ' 
EndIf
Pcoc330lct(cFiltroAKD)

cCadastro := cCadAnt
RestArea(aAreaAL1)
RestArea(aAreaAKD)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ PCOCliqLan บAutor  ณGustavo Henrique    บ Data ณ 10/10/05 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza a coluna da aCols com o campo selecioando no     บฑฑ
ฑฑบ          ณ painel lateral com a estrutura da tabela.                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTipo    : 1 - Configuracao de lancamentos                บฑฑ
ฑฑบ          ณ            2 - Configuracao de bloqueios                  บฑฑ
ฑฑบ          ณ oTree    : Objeto tree com a estrutura da tabela          บฑฑ
ฑฑบ          ณ aHeadTmp : aHeader com o cabecalho do aCols posicionado   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO - Configuracao de lancamento / bloqueio               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOCliqLan(nTipo,oTree,aHeadTmp)
                         
local oGDTmp
local cColuna := ""
local cCampo  := ""
     
// Cria um objeto de GetDados temporario a partir da GetDados de origem: lancamento ou bloqueio
oGDTmp  := Iif( nTipo == 1, oGDAKC, oGDAKI )

// Guarda o conteudo da coluna da aCols e o nome do campo da tabela selecionada no painel lateral
cColuna := Alltrim(oGDTmp:aCols[oGDTmp:nAt][oGdTmp:oBrowse:nColPos])
cCampo  := Alltrim(Substr(oTree:GetCargo(),4,Len(oTree:GetCargo())))

// Soma o campo selecionado no conteudo do campo no aCols posicionado       
oGDTmp:aCols[oGDTmp:nAt][oGdTmp:oBrowse:nColPos] := PadR( cColuna + cTable + "->" + cCampo, TamSX3(aHeadTmp[oGdTmp:oBrowse:nColPos][2])[1] )

// Restaura o objeto da GetDados utilizado a partir das alteracoes realizadas no objeto temporario
if nTipo == 1
	oGDAKC := oGDTmp
else
	oGDAKI := oGDTmp
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOParseFil บAutor ณ Bruno / Gustavo  บ Data ณ  27/10/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Converter uma expressao simples de filtro em Advpl para    บฑฑ
ฑฑบ          ณ formato de Query - SQL                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Filtro de origem em Advpl                          บฑฑ
ฑฑบ          ณ EXPC2 - Nome da tabela para montar e executar uma query    บฑฑ
ฑฑบ          ณ         de teste utilizando a expressao final SQL.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ EXPC1 - Filtro de retorno em SQL (se vazio, indica que     บฑฑ
ฑฑบ          ณ         a expresao nao pode ser convertida)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCORunCube - Consultas e relatorios de cubos gerenciais    บฑฑ
ฑฑบ          ณ Esta rotina deve ser utilizada para tentar interpretar     บฑฑ
ฑฑบ          ณ filtros criados pelo usuario (como os da SetPrint,por      บฑฑ
ฑฑบ          ณ exemplo) e o uso deve ser da seguinte forma:               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ cFiltro := PcoParseFil(cFiltroAdvPl,cAlias)                บฑฑ
ฑฑบ          ณ cQuery  := "SELECT * From "+RetSqlName(cAlias)+ " "+cAlias บฑฑ
ฑฑบ          ณ cQuery  := "where "+Condicao padrao.                       บฑฑ
ฑฑบ          ณ If !Empty(cFiltro)                                         บฑฑ
ฑฑบ          ณ    cQuery  := " AND ("+cFiltro+")"                         บฑฑ
ฑฑบ          ณ Endif                                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Se o cFiltro estiver vazio deve ser interpretado o         บฑฑ
ฑฑบ          ณ cFitlroAdvPl quando lido o retorno da query.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoParseFil( cFiltOri, cTabela )

Local aOpcoes		:= {".OR.",".AND.",".NOT.","+","-","/","*","SUBSTRING","SUBSTR","=","LEFT","RIGHT","$","ALLTRIM","LTRIM","RTRIM","TRIM","DTOS"}
Local cFiltro		:= ""  
Local cTestar		:= ""	// String parcial para testar parenteses
Local cQuery    	:= ""
Local cFltTmp		:= Upper( Alltrim( cFiltOri ) )		
Local nLenFlt		:= 0
Local nX,nY			:= 0	// Contadores genericos
Local nPars			:= 0
Local nLenOpcoes	:= Len( aOpcoes )
Local lFirstChar	:= .F.
Local lFiltroOK		:= .T.
Local lOracle	 	:= "ORACLE"   $ Upper(TCGetDB())
Local lPostgres 	:= "POSTGRES" $ Upper(TCGetDB())
Local lDB2		 	:= "DB2"      $ Upper(TCGetDB())

//cFltTmp	:= StrTran( cFltTmp, "DTOS"	, ""	)
cFltTmp := StrTran( cFltTmp, "!="	, "<>"		)
cFltTmp := StrTran( cFltTmp, "#"	, "<>"		)
cFltTmp	:= StrTran( cFltTmp, "!"	, ".NOT."	)
cFltTmp := StrTran( cFltTmp, "$"	, " $ "		) 

If ExistBlock("PCOFiltOri")
	cFltTmp :=	ExecBlock("PCOFiltOri",.F.,.F.,cFltTmp)
EndIf	
                           
//Verificar se esta expressao ja foi avaliada para esta tabela
If (nPosQry := Ascan(aQueryCache,{ |x| x[1] == cTabela+cFiltOri})) > 0
	//Se foi avaliada 
	If aQueryCache[nPosQry,2]	
		cFiltro  := aQueryCache[nPosQry,3]		
	Else
		cFiltro	:=	""	
	Endif
	Return cFiltro
Endif
nLenFlt := Len( cFltTmp )

For nX := 1 To nLenFlt

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIgnora os primeiros caracteres se sao parentesis.  ณ
	//ณPor exemplo : (((1=2 .....                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lFirstChar
		lFirstChar	:=	SubStr(cFltTmp,nX,1)<> "("
	ElseIf Substr(cFltTmp,nX,1) == "("				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se antes do parentesis achado existe algum operador cosiderado valido (que o bancoณ
		//ณconseguira resolver). Por exemplo ".Or.(" ou ".And.(((" .ou ".NOT.". E todos os definidos  ณ
		//ณem aOpcoes, considerando os parentesis ja lidos. (variavek nPars).                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nY:= 1 To nLenOpcoes
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณO Replicate(nPars,"(") server para adicionar os parentesis ja ณ
			//ณlidos da expressao (".Or." e tao valido quanto ".Or.(((").    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cTestar   := aOpcoes[nY]+Replicate("(",nPars)
			lFiltroOk := (Right(cFiltro,Len(cTestar)) ==  cTestar)
			If lFiltroOk
				Exit
			Endif          			
		Next nY
		If !lFiltroOk
			Exit
		EndIf
	EndIf
	cFiltro	+=	Substr(cFltTmp,nX,1)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAcumula a quantidade de parentesis consecutivos ou zera a con-ณ
	//ณtagem em caso do caratcer lido nao ser um parametro.          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Substr(cFltTmp,nX,1) == "("
		nPars++
	Else
		nPars := 0			
	EndIf	
Next nX

If lFiltroOk 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFaz as conversoes das expresoes conhecidas de AdvPl para SQL. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cFiltro := Upper(cFiltro)
	cFiltro := StrTran(cFiltro,	".OR."	, " OR "	)
	cFiltro := StrTran(cFiltro,	".AND."	, " AND "	)
	cFiltro := StrTran(cFiltro,	".NOT."	, " NOT "	)
	cFiltro := StrTran(cFiltro,	"=="	, "="		)
	cFiltro	:= StrTran(cFiltro,	"->"	, "."		)
	cFiltro	:= StrTran(cFiltro,	"DTOS"	,""			)
	cFiltro	:= StrTran(cFiltro,	'"'		,"'"		)

	If lOracle .Or. lPostgres .Or. lDB2
        cFiltro	:=	StrTran( cFiltro,"SUBSTRING","SUBSTR")
	Else
        cFiltro	:=	StrTran( cFiltro,"SUBSTR","SUBSTRING")
	Endif		       
                                                              
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Testa a expressao apos converter de Advpl para SQL, caso nao esteja ok, retorna a string vazia ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := " SELECT 1 "
	cQuery += " FROM " + RetSQLName(cTabela) + " " + cTabela
	cQuery += "  WHERE "
	cQuery += If( SubStr(cTabela,1,1)=="S", SubStr(cTabela,2,2),cTabela) + "_FILIAL" + "='" + xFilial(cTabela) + "'"
	cQuery += " AND " + cFiltro	// Adiciona expressao de filtro convertida para SQL
	cQuery	:=	ChangeQuery(cQuery)
	If TcSQLExec( cQuery ) == 0
		lFiltroOK := .T.
	Else
		cFiltro   := ""	
	EndIf					    

Else 

	cFiltro := ""	
	
Endif          

AAdd(aQueryCache,{cTabela+cFiltOri,lFiltroOk,cFiltro})
Return( cFiltro )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณVerif_Bloqueio บAutor  ณPaulo Carnelossi บ Data ณ 22/02/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se ira bloquear processo linha a linha quando for  บฑฑ
ฑฑบ          ณuma grade (exemplo pedido de compras ou nota fiscal de      บฑฑ
ฑฑบ          ณentrada                                                     บฑฑ
ฑฑบ          ณO procedimento normal e validar o bloqueio sempre, mas por  บฑฑ
ฑฑบ          ณperformance e para agilizar digitacao nos casos de grade    บฑฑ
ฑฑบ          ณpode ser validado no pressionar do botao OK (TudOK)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Verif_Bloqueio(lVldLinGrade)
Local lVldBloq := .T.
//considerando que a tabela AKA ja esta posicionado no processo / item
If 		lVldLinGrade .And. ; //se esta na validacao linha da Grade (LinOK)
			(AKA->(FieldPos("AKA_GRADE")) > 0 ) .And. ;
			(AKA->(FieldPos("AKA_VLDBLQ")) > 0 ) .And. ;
			AKA->AKA_GRADE == "1" /*1=Sim*/ .And. ;
			AKA->AKA_VLDBLQ <> "1" /*1-Por Linha 2-Por Grade*/ 
			lVldBloq  := .F.
EndIf
Return (lVldBloq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPcoBlqFim      บAutor  ณPaulo Carnelossi บ Data ณ 23/02/06  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se ira bloquear processo no final da digitacao da  บฑฑ
ฑฑบ          ณgrade (exemplo pedido de compras ou nota fiscal de entrada  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณO procedimento normal e validar o bloqueio sempre, mas por  บฑฑ
ฑฑบ          ณperformance e para agilizar digitacao nos casos de grade    บฑฑ
ฑฑบ          ณpode ser validado no pressionar do botao OK (TudOK)         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ//aProcItPco := { {"000054","07"},{"000054","05"},;         บฑฑ
ฑฑบ          ณ{"000054","01"} }                                           บฑฑ
ฑฑบ          ณ//onde o Elem 01 = Codigo do Processo                       บฑฑ
ฑฑบ          ณ//       Elem 02 = Item do Processo                         บฑฑ
ฑฑบ          ณ//que deveriam ser validados na linha OK                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoBlqFim(aProcItPco)
//aProcIt := { {"000054","07"},{"000054","05"},{"000054","01"} }
//onde o Elem 01 = Codigo do Processo
//       Elem 02 = Item do Processo
Local aArea := GetArea()
Local nX
Local aAreaAKA
Local nRet := 0
Local aRet := Array(Len(aProcItPco))

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	aFill(aRet, 0)
	aAreaAKA := AKA->(GetArea())
	dbSelectArea("AKA")
	dbSetOrder(1)
	
	For nX := 1 TO Len(aProcItPco)
		If dbSeek(xFilial("AKA")+aProcItPco[nX, 1]+aProcItPco[nX, 2])
			If 	AKA->(FieldPos("AKA_GRADE")) > 0  .And. ;
				AKA->(FieldPos("AKA_VLDBLQ")) > 0  .And. ;
				AKA->AKA_GRADE == "1" /*1=Sim*/ .And. ;
				AKA->AKA_VLDBLQ == "2" /*1-Por Linha 2-Por Grade*/
				aAdd(aRet, 1)
			Else
	    		aAdd(aRet, 0)
	    	EndIf   		
	    Else
	    	aAdd(aRet, 0)
	   	EndIf   		
	Next
	
	RestArea(aAreaAKA)
	
	For nX := 1 TO Len(aRet)
		nRet += aRet[nX]
	Next

EndIf

RestArea(aArea)

Return (nRet > 0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AcessAK2_CC_CV_IC(lVisualiza)
Local lRet := .T.
Local nPosCta := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CO"})
Local nPosCC := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CC"})
Local nPosIC := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_ITCTB"})
Local nPosCV := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CLVLR"})
Local cCtaOrc := Space(Len(AK2->AK2_CO))
Local cCCusto := Space(Len(AK2->AK2_CC))
Local cItCtb := Space(Len(AK2->AK2_ITCTB))
Local cClVlr := Space(Len(AK2->AK2_CLVLR))
Local lMore  
Local nPosUni, nQtd  
Local cUniOrc, cEnt
Local aNPosEnts := {}, aCEnts := {}      

If(AK2->(FieldPos("AK2_UNIORC")) >  0)
	nPosUni := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_UNIORC"})
	cUniOrc := Space(Len(AK2->AK2_UNIORC))
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
	EndIf
EndIf 

If nQtdEntid > 4
	aNPosEnts := Array(nQtdEntid)
	aCEnts		:= Array(nQtdEntid)

	For nQtd := 5 To nQtdEntid 
		cEnt := "AK2->AK2_ENT"+STRZERO(nQtd,2) 

		aNPosEnts[nQtd] := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])== "XK2_ENT"+STRZERO(nQtd,2)}) 
		aCEnts[nQtd] := Space(Len(&cEnt))

		If (aNPosEnts[nQtd] > 0)
			aCEnts[nQtd] := oGd[2]:aCols[1, aNPosEnts[nQtd]]
		EndIf
	Next
EndIf

If nPosCta > 0 
	cCtaOrc := oGd[2]:aCols[1, nPosCta]
EndIf

If nPosCC > 0 
	cCCusto := oGd[2]:aCols[1, nPosCC]
EndIf

If nPosIC > 0 
	cItCtb := oGd[2]:aCols[1, nPosIC]
EndIf

If nPosCV > 0 
	cClVlr := oGd[2]:aCols[1, nPosCV]
EndIf   

If nPosUni > 0 
	cUniOrc := oGd[2]:aCols[1, nPosUni]
EndIf

If !Empty(cCtaOrc)
	dbSelectArea("AK3")
	dbSetOrder(1)
	If MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCtaOrc)
		lMore := .T.
		While lMore
		    // verifica centro de custo
			lRet := !Empty(cCCusto)
			If lRet
				lRet := PcoCC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",cRevisa,cCCusto,If(lVisualiza, 1, 2) )
				If ! lRet
		    	   Exit
		        EndIf
			EndIf
			//verifica item contabil
			lRet := !Empty(cItCtb)
			If lRet
				lRet := PcoIC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",cRevisa,cItCtb,If(lVisualiza, 1, 2) )
				If ! lRet
		    	   Exit
			    EndIf
			EndIf
		    //verifica classe de valor
		    lRet := !Empty(cClVlr)
			If lRet
				lRet := PcoCV_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",cRevisa,cClVlr,If(lVisualiza, 1, 2) )
				If 	! lRet 
		    	   Exit
			    EndIf
			EndIf   

			//verifica Unidade Orcamentaria
			If !Empty(cUniOrc) .Or. !Empty(aCEnts)
				lRet := PcoUserEtd(cUniOrc,aCEnts)
				If 	! lRet 
		    	   Exit
			    EndIf
			EndIf  

			//Se nao sair em nenhum if encerra o laco e retorna .T.
			lRet  := .T.
			lMore := .F.
		End	
	EndIf
EndIf	    

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoChkBlq บAutor  ณPaulo Carnelossi    บ Data ณ  27/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImplementacao da funcao PcoChkBlq() que  objetiva eliminar  บฑฑ
ฑฑบ          ณos registros referente a lancamentos de bloqueio que por    บฑฑ
ฑฑบ          ณalguma anormalidade nao foram aproveitados pela             บฑฑ
ฑฑบ          ณfuncao pcodetlan() ou por queda do sistema no momento da    บฑฑ
ฑฑบ          ณgravacao dos lancamentos normais.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoChkBlq()
Local	aArea     := GetArea()
Local	aAreaAKD  := AKD->(GetArea())
Local 	cQuery    := ""
Local lQuery := ( TcGetDb() # "AS/400" .and. TCGetDB()!="SYBASE" )             

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If AKD->(FieldPos("AKD_LCTBLQ")) > 0
	
		dbSelectArea("AKD")
		dbSetOrder(11)
		If dbSeek(xFilial("AKD")+"1")  // 1=Lancamento de Bloqueio
		
			If lQuery
				cQuery 	:= "  SELECT R_E_C_N_O_ REG_AUX "
				cQuery 	+= "  FROM " + RetSQLName("AKD") + " " + "AKD"
				cQuery 	+= "  WHERE "
				cQuery 	+= "  AKD_FILIAL = '"+xFilial("AKD")+"' AND "
				cQuery 	+= "  AKD_LCTBLQ = '1' AND "
				cQuery 	+= "  D_E_L_E_T_ <> '*' "
				cQuery 	+= "  ORDER BY  " + SqlOrder(AKD->(IndexKey()))			
				cQuery := ChangeQuery(cQuery)                
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณFecha o alias da query, para executแ-la com o mesmo alias ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "AKD_Qry", .T., .T. )
				AKD_Qry->(dbGoTop())
				
				While AKD_Qry->(!Eof())
				   
					dbSelectArea("AKD")
					dbGoto(AKD_Qry->REG_AUX)
					
					If MsRLock()
						PcoDelBlq(AKD->(Recno()))
					EndIf
					
					dbSelectArea("AKD_Qry")
					AKD_Qry->(dbSkip())
	
				End
				
				//apos processar query fecha o alias correspondente
				dbSelectArea("AKD_Qry")
				DbCloseArea()
				dbSelectArea("AKD")
				
			Else	
						
				While AKD->(!Eof() .And. AKD_FILIAL+AKD_LCTBLQ ==xFilial("AKD")+"1")  // 1=Lancamento de Bloqueio 
					If MsRLock()
						PcoDelBlq(AKD->(Recno()))
					EndIf
					dbSelectArea("AKD")
					AKD->(dbSkip())
				End
				
			EndIf
		
		EndIf
		
	EndIf

EndIf

RestArea(aAreaAKD)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoDelBlq บAutor  ณPaulo Carnelossi    บ Data ณ  28/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao utilizada por PcoFreeBlq() e PcoChkBlq() para apagar บฑฑ
ฑฑบ          ณlancamentos referente a bloqueios                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoDelBlq(nRecAKD)

dbSelectArea("AKD")
dbGoto(nRecAKD)
If AKD->(! Deleted())
	If AKD->AKD_LCTBLQ=='1'

		If AKD->AKD_STATUS == '1'
			PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
		EndIf
		RecLock("AKD",.F.,.T.)
		dbDelete()
		MsUnlock()

	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoProcRelacบAutor ณPaulo Carnelossi   บ Data ณ  23/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna um array contendo os processos filhos que serao     บฑฑ
ฑฑบ          ณchamados nesta rotina para na primeira vez que executar     บฑฑ
ฑฑบ          ณPcoIniLan() abrir todos os arquivos envolvidos na transacao,บฑฑ
ฑฑบ          ณpor isso,  deve ser feito unicamente na primeira PcoIniLan()บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoProcRelac(cProcesso)
Local aProcFilhos := {}

Do Case

	Case cProcesso == "000001"  // ---> "FINA040" - "CONTAS A RECEBER"
	
	Case cProcesso == "000002"  // ---> "FINA050" - "CONTAS A PAGAR"
	
	Case cProcesso == "000003"  // ---> "FINA060" - "TRANSFERENCIAS - FINANCEIRO"
	
	Case cProcesso == "000004"  // ---> "FINA070" - "BAIXAS A RECEBER"
	
	Case cProcesso == "000005"  // ---> "FINA080" - "BAIXAS A PAGAR"
	
	Case cProcesso == "000006"  // ---> "FINA090" - "BAIXAS A PAGAR AUTOMATICA"
	
	Case cProcesso == "000007"  // ---> "FINA100" - "MOVIMENTACAO BANCARIA"
	
	Case cProcesso == "000008"  // ---> "FINA171" - "APLICACOES FINANCEIRAS"
	
	Case cProcesso == "000009"  // ---> "FINA181" - "RESGATE DE APLICACOES"
	
	Case cProcesso == "000010"  // ---> "FINA182" - "APROPRIACAO DE EMPRESTIMO"
	
	Case cProcesso == "000011"  // ---> "FINA183" - "ESTORNO DE APROPRIACAO DE EMPRESTIMO"
	
	Case cProcesso == "000012"  // ---> "FINA110" - "BAIXAS A RECEBER AUTOMATICA"
	
	Case cProcesso == "000014"  // ---> "FINA280" - "FATURAS A RECEBER"
	     aAdd(aProcFilhos, "000001")  // ---> "FINA040" - "CONTAS A RECEBER"
	     aAdd(aProcFilhos, "000004")  // ---> "FINA070" - "BAIXAS A RECEBER"
	     
	Case cProcesso == "000015"  // ---> "FINA290" - "FATURAS A PAGAR"
	
	Case cProcesso == "000016"  // ---> "FINA330" - "COMPENSACAO CR"
	
	Case cProcesso == "000017"  // ---> "FINA340" - "COMPENSACAO CP"
	
	Case cProcesso == "000018"  // ---> "FINA450" - "COMPENSACAO ENTRE CARTEIRAS"
	
	Case cProcesso == "000019"  // ---> "FINA350" - "VARIACAO MONETARIA"
	
	Case cProcesso == "000020"  // ---> "FINA430" - "RETORNO DE COMUNICACAO BANCARIA A PAGAR"
	
	Case cProcesso == "000021"  // ---> "FINA050" - "CONTAS A PAGAR - RATEIO"//"Rateio"
	
	Case cProcesso == "000022"  // ---> "FINA300" - "RETORNO DE COMUNICACAO BANCARIA (SISPAG)"
	
	Case cProcesso == "000050"  // ---> "MATA125" - "CONTRATO DE PARCERIA"
	
	Case cProcesso == "000051"  // ---> "MATA110" - "SOLICITACAO DE COMPRAS"
	
	Case cProcesso == "000052"  // ---> "MATA121" - "PEDIDO DE COMPRAS"
	                                    
	Case cProcesso == "000053"  // ---> "MATA122" - "AUTORIZACAO DE ENTREGA"
	
	Case cProcesso == "000054"  // ---> "MATA103" - "DOCUMENTO DE ENTRADA"
	
	Case cProcesso == "000055"  // ---> "MATA097" - "LIBERACAO DE PEDIDO DE COMPRAS"
	
	Case cProcesso == "000080"  // ---> "RSPA100" - "LIBERACAO DE PEDIDO DE COMPRAS" //"Cadastro de vagas para contratacao"
	
	Case cProcesso == "000082"  // ---> "CTBA105" - "Contabilizacao"
	
	Case cProcesso == "000083"  // ---> "CSAA090" - "Quadro de Funcionarios"
	
	Case cProcesso == "000084"  // ---> "GPEA010" - "Cadastro de Funcionarios"
	
	Case cProcesso == "000085"  // ---> "GPEM120" - "Fechamento mensal da folha"
	
	Case cProcesso == "000100"  // ---> "MATA410" - "PEDIDO DE VENDAS"
	
	Case cProcesso == "000101"  // ---> "MATA461" - "NOTA FISCAL DE SAIDA"
	
//	Case cProcesso == "000102"  // ---> "MATA520" - "EXCLUSAO DE NOTA FISCAL DE SAIDA"
	
	Case cProcesso == "000150"  // ---> "MATA105" - "Solicitacao ao armazem"
	
	Case cProcesso == "000151"  // ---> "MATA240" - "MOVIMENTOS INTERNOS"
	
	Case cProcesso == "000152"  // ---> "MATA250" - "PRODUCAO"
	
	Case cProcesso == "000153"  // ---> "MATA340" - "ACERTO DO INVENTARIO"
	
	Case cProcesso == "000250"  // ---> "MATA953" - "APURACAO DE ICMS"
	
	Case cProcesso == "000251"  // ---> "MATA955" - "APURACAO DE IPI"
	
	Case cProcesso == "000252"  // ---> "PCOA100" - "PLANILHA ORCAMENTARIA"
	
	Case cProcesso == "000255"  // ---> "PCOA330" - "Importacao CTB"
	
	Case cProcesso == "000300"  // ---> "MATA467N" - "NOTA DE SAIDA MANUAL E DE BENDEFICIAMENTO A CLIENTE"
	
	Case cProcesso == "000301"  // ---> "MATA462N" - "REMITO DE SAIDA MANUAL E DE BENDEFICIAMENTO A CLIENTE"
	
	Case cProcesso == "000302"  // ---> "MATA462DN" - "REMITO DE DEVOLUCAO (FATURAMENTO)"
	
	Case cProcesso == "000303"  // ---> "MATA462R" - "REMITO DE RETORNO SIMBOLICO (FATURAMENTO)"
	
	Case cProcesso == "000304"  // ---> "MATA462TN" - "REMITO DE TRANSFERENCIA"
	
	Case cProcesso == "000305"  // ---> "MATA102DN" - "REMITO DE DEVOLUCAO (COMPRAS)"
	
	Case cProcesso == "000306"  // ---> "MATA101N" - "NOTA DE ENTRADA MANUAL"
	
	Case cProcesso == "000307"  // ---> "MATA102N" - "REMITO DE ENTRADA MANUAL E DE BENEFICIAMENTO A CLIENTE"
	
	Case cProcesso == "000308"  // ---> "MATA465N" - "NOTA DE DEBITO A CLIENTE"
	
	Case cProcesso == "000309"  // ---> "MATA465N" - "NOTA DE CREDITO A CLIENTE"
	
	Case cProcesso == "000310"  // ---> "MATA466N" - "NOTA DE DEBITO A FORNECEDOR"
	
	Case cProcesso == "000311"  // ---> "MATA466N" - "NOTA DE CREDITO A FORNECEDOR"
	
	Case cProcesso == "000312"  // ---> "MATA466N" - "RECIBO DE SERVICOS (COMPRAS)"
	
	Case cProcesso == "000350"  // ---> "PMSA110" -  "Geracao de projeto"

EndCase

Return(aProcFilhos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAvisoTimerบAutor  ณPaulo Carnelossi    บ Data ณ  18/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCopia da funcao aviso() (matxfuna.prx) acrescentando timer  บฑฑ
ฑฑบ          ณpara nao ficar parado na tela de bloqueio do PCO            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION AvisoTimer(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,nTime,nOpcTimer)
 
Local ny        := 0
Local nx        := 0
Local aSize  := {  {134,304,35,155,35,113,51},;  // Tamanho 1
 {134,450,35,155,35,185,51},; // Tamanho 2
 {227,450,35,210,65,185,99} } // Tamanho 3
Local nLinha    := 0
Local cMsgButton:= ""
Local oGet
Local oTimer

Private oDlgAviso
Private nOpcAviso := 0

DEFAULT nTime 		:= 0
DEFAULT nOpcTimer 	:= 1
 
cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Quando for rotina automatica, envia o aviso ao Log.          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type('lMsHelpAuto') == 'U'
 lMsHelpAuto := .F.
EndIf
 
If !lMsHelpAuto
 If nSize == Nil
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If  Len(aBotoes) > 3
   If Len(cMensagem) > 286
    nSize := 3
   Else
    nSize := 2
   EndIf
  Else
   Do Case
   Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
    nSize := 2
   Case Len(cMensagem) >= 250
    nSize := 3
   OtherWise
    nSize := 1
   EndCase
  EndIf
 EndIf
 If nSize <= 3
  nLinha := nSize
 Else
  nLinha := 3
 EndIf
 DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption Of oMainWnd PIXEL
 DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
 @ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
 @ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
 If cBitmap <> Nil
  @ 2, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
  @ 3  ,50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold 
 Else
  @ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold 
 EndIf
 If nSize <= 3
  @ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
 Else
  @ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
 EndIf
If Len(aBotoes) > 1
 TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
EndIf
 ny := (aSize[nLinha][2]/2)-36
 For nx:=1 to Len(aBotoes)
  cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
  bAction:=&(cAction)
  cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
  cMsgButton:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )
  TButton():New(aSize[nLinha][7],ny,cMsgButton, oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
  ny -= 35
 Next nx

 //timer para fechar tela aviso na tela de bloqueio do PCO
 If nTime > 0
	oTimer:= TTimer():New(nTime,{|| (nOpcAviso := nOpcTimer, oDlgAviso:End()) },oDlgAviso)
	oTimer:Activate()
 EndIf
 
 ACTIVATE MSDIALOG oDlgAviso CENTERED
 
Else
 If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)
  cMensagem += " " + aBotoes[nRotAutDefault]
  nOpcAviso := nRotAutDefault
 Endif 
 ConOut(Repl("*",40))
 ConOut(cCaption)
 ConOut(cMensagem)
 ConOut(Repl("*",40))
 AutoGrLog(cCaption)
 AutoGrLog(cMensagem)
EndIf
 
Return (nOpcAviso)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoExistLc ณ Autor ณ Bruno Sobieski       ณ Data ณ 09-02-2001 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณVerifica se existe lancamento no PCO                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoExistLc(cProcess,cItem,cTipo)
Local lAchou := .F.
Local aArea	:=	GetArea()
DEFAULT cTipo := "2" //Bloqueio

If cTipo == "1"
	DbSelectArea('AKC')
	DbSetOrder(1)
	DbSeek(xFilial()+cProcess+cItem)
	While !lAchou .And. !Eof() .And. AKC_FILIAL+AKC_PROCES+AKC_ITEM == xFilial()+cProcess+cItem
		lAchou	:=	(Alltrim(AKC_ATIVO) == 'LBOK'	)
		DbSkip()
	Enddo
	If !lAchou
		DbSelectArea('AKB')
		DbSetOrder(1)
		lAchou	:= DbSeek(xFilial('AKB')+cProcess+cItem) .and. AKB->AKB_CFGON=="1"
	EndIf
Else
	DbSelectArea('AKI')
	DbSetOrder(1)
	DbSeek(xFilial()+cProcess+cItem)
	While !lAchou .And. !Eof() .And. AKI_FILIAL+AKI_PROCES+AKI_ITEM == xFilial()+cProcess+cItem
		lAchou	:=	(Alltrim(AKI_ATIVO) == 'LBOK'	)
		DbSkip()
	Enddo
	If !lAchou
		DbSelectArea('AKA')
		DbSetOrder(1)
		lAchou	:= DbSeek(xFilial('AKA')+cProcess+cItem) .and. AKA->AKA_CFGON=="1"
	EndIf
Endif
RestArea(aArea)
Return lAchou

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ PcoHasInt ณ Autor ณ Daniel Leme          ณ Data ณ 30-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณVerifica se existe lancamento de Integra็ใo no PCO            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGenerico                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoHasInt(cProcess,cItem)
Local lAchou := .F.
Local aArea	:=	GetArea()

DbSelectArea('AMK')
DbSetOrder(1)
DbSeek(xFilial()+cProcess+cItem)
While !lAchou .And. !Eof() .And. AMK_FILIAL+AMK_PROCES+AMK_ITEM == xFilial()+cProcess+cItem
	lAchou	:=	(Alltrim(AMK_ATIVO) == 'LBOK'	)
	DbSkip()
Enddo

RestArea(aArea)
Return lAchou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoIncr_QtBlq บAutor ณPaulo Carnelossi บ Data ณ  16/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncrementa quantidade de bloqueio por tipo quando lancamentoบฑฑ
ฑฑบ          ณfor bloqueado para uso no painel de gestao                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoIncr_QtBlq()
Local aAreaAux
Local cAlias := Alias()

If AKJ->(FieldPos("AKJ_QTDBLQ")) > 0

	aAreaAux := GetArea()
	dbSelectArea("AKJ")
	//como ja esta posicionado somente incrementar qtd bloqueio
	Reclock("AKJ",.F.)
	AKJ->AKJ_QTDBLQ := AKJ->AKJ_QTDBLQ+1
	MsUnlock()
	RestArea(aAreaAux)
	
EndIf

dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoHeaderWTบAutor  ณPaulo Carnelossi    บ Data ณ  28/02/07  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณMontar no aheader os campos ALIAS _ALI_WT / _REC_WT para    บฑฑ
ฑฑบ          ณutilizar nas getdados que nao possa utilizar fillgetdados() บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PcoHeaderWT(cAlias, aHeader)
Local aArea := GetARea()
Local aAreaSX3 := SX3->(GetArea())
Local cUsado

dbSelectArea("SX3")
dbSetOrder(2)
cAlias := Alltrim(cAlias)

If SX3->(DbSeek(cAlias+"_FILIAL"))
	cUsado := SX3->X3_USADO

	AADD( aHeader, { "Alias WT", cAlias+"_ALI_WT", "", 09, 0,, cUsado, "C", cAlias, "V"} )
	AADD( aHeader, { "Recno WT", cAlias+"_REC_WT", "", 09, 0,, cUsado, "N", cAlias, "V"} )
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoBackupAKDบAutor  ณPaulo Carnelossi  บ Data ณ  09/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz backup dos dados da tabela AKD ref. ao processo que     บฑฑ
ฑฑบ          ณsendo avaliado pela funcao PcoVldLan()                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoBackupAKD(aRecGrv)

Local nX, nPos 
Local nNumCpos := AKD->(FCount())

//aRecGrv tera 2 elementos
// elem 1 = recno do registro AKD ja posicionado
// elem 2 = array com conteudo do registro AKD { "NOME DO CAMPO", XCONTEUDO }

aAdd(aRecGrv, { AKD->(Recno()), {} } )
nPos := Len(aRecGrv)

For nX := 1 TO nNumCpos
	aAdd(aRecGrv[nPos,2], { AKD->(FieldName(nX)), AKD->(FieldGet(nX)) } )
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPcoRestoreAKDบAutor  ณPaulo Carnelossi  บ Data ณ 09/04/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFaz restore dos dados da tabela AKD ref. ao processo que    บฑฑ
ฑฑบ          ณsendo avaliado pela funcao PcoVldLan() e que foi bloqueado  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoRestoreAKD(aPcoBkpBlq, nRecno)

Local nX, nY, nPos 
Local nNumCpos := AKD->(FCount())

DEFAULT nRecno := 0

If nRecno > 0  //qdo passado o recno do AKD para a funcao

	nPos 	:= Ascan(aPcoBkpBlq, {|aVal| aVal[1] == nRecno})
	nRecAux := nRecno

	If nPos > 0
		dbSelectArea("AKD")
		dbGoto(nRecAux) 
	
		If  AKD->(Deleted())  //se foi deletado recupera
			RecLock("AKD",.F.)
			AKD->(dbRecall())
		Else	
			RecLock("AKD",.F.)
		EndIf
		//volta o conteudo dos campos
		For nX := 1 TO nNumCpos
			AKD->(FieldPut(nX, aPcoBkpBlq[nPos,2,nX,2]))
		Next
		MsUnLock()
		//atualiza o saldo dos cubos, caso anterior ao bloqueio estava com saldo ja grv
		If AKD->AKD_STATUS == '1'
			PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5},AKD->AKD_DATA)
		EndIf	
		
	EndIf
	
Else

	//quando vai restaurar todos os registros armazenados no array de backup
	For nY := 1 TO Len(aPcoBkpBlq)
	
		nPos 	:= nY
		nRecAux := aPcoBkpBlq[nY, 1]
	
		dbSelectArea("AKD")
		dbGoto(nRecAux) 
	
		If  AKD->(Deleted())
			RecLock("AKD",.F.)
			AKD->(dbRecall())
		Else	
			RecLock("AKD",.F.)
		EndIf
		//volta o conteudo dos campos
		
		If Len(aPcoBkpBlq[nY, 2])>0
			For nX := 1 TO nNumCpos
				AKD->(FieldPut(nX, aPcoBkpBlq[nPos,2,nX,2]))
			Next
			MsUnLock()
			//atualiza o saldo dos cubos, caso anterior ao bloqueio estava com saldo ja grv
			If AKD->AKD_STATUS == '1'
				PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5},AKD->AKD_DATA)
			EndIf	

		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Apaga lan็amentos de Contingencia                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			MsUnLock()		
			If AKD->AKD_STATUS == '1'
				PcoAtuSld(If(AKD->AKD_TIPO=="1","D","C"),"AKD",{AKD->AKD_VALOR1,AKD->AKD_VALOR2,AKD->AKD_VALOR3,AKD->AKD_VALOR4,AKD->AKD_VALOR5},AKD->AKD_DATA)
			EndIf	
			RecLock("AKD",.F.)
			DbDelete()
			MsUnLock()	
		EndIf
		
	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoVerifAcolsบAutor ณPaulo Carnelossi  บ Data ณ  09/04/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna conteudo da variavel static utilizada/alimentada    บฑฑ
ฑฑบ          ณnas funcoes PcoIniLan/PcoVldLan quando processo tem grade   บฑฑ
ฑฑบ          ณe bloqueio ativo                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoVerifAcols(cProcesso)
Local lRet := .F.
//Verifica se foi alterado algo na getdados nos processos em que eh chamada a funcao PcoVldLan()
//e se alterou reprocessa a solicitacao de compras com PcoIniLan/PcoDetLan/PcoFinLan
//esta variavel static e alimentada nas funcoes pcoinilan/pcovldlan

If aScan( aMudouAcols , {|x| x[1]==cProcesso})>0
	lRet := aMudouAcols[aScan( aMudouAcols , {|x| x[1]==cProcesso}),2]
EndIf


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoReproc บAutor  ณPaulo Carnelossi    บ Data ณ  09/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReprocessa quando tem grade e bloqueio ativo e quando       บฑฑ
ฑฑบ          ณeh alterado as informacoes da grade                         บฑฑ
ฑฑบ          ณchamado pela funcao pcofreeblq()                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PcoReproc(cProcess)  
Local oModel		:= NIL
Local oModelCNB	:= NIL
Local nFor         := 0
//se alterou alguma informacao na getdados e nao foi confirmado devera 
//reprocessar a solicitacao ou pedido de compra para acertar a tabela AKD
If cProcess == "000051"   //Solicitacao de compras

	dbSelectArea("SC1")
	dbSetOrder(1)
	If PcoExistLc("000051","01","2") .And. ;  //se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("SC1")+cA110Num)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000051")
		While SC1->(! Eof() .And. C1_FILIAL+C1_NUM==xFilial("SC1")+cA110Num)
			PcoDetLan("000051","01","MATA110")
			SC1->(dbSkip())
		EndDo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000051")  
	EndIf		
	
ElseIf cProcess == "000052"

	dbSelectArea("SC7")
	dbSetOrder(1)
	If ( PcoExistLc("000052","01","2") .Or. ;  //se tem bloqueio ativo no processo
			PcoExistLc("000052","02","2") ) .And. ;  //se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("SC7")+cA120Num)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000052")
		While SC7->(! Eof() .And. C7_FILIAL+C7_NUM==xFilial("SC7")+cA120Num)
			If Empty(SC7->C7_NUMCOT)
				PcoDetLan("000052","01","MATA121")
			Else
				PcoDetLan("000052","02","MATA121")
			Endif
			SC7->(dbSkip())
		EndDo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000052")  
	EndIf		

ElseIf cProcess == "000053"

	dbSelectArea("SC7")
	dbSetOrder(1)
	If ( PcoExistLc("000053","01","2") .Or. ;  //se tem bloqueio ativo no processo
			PcoExistLc("000053","02","2") ) .And. ;  //se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("SC7")+cA120Num)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000053")
		While SC7->(! Eof() .And. C7_FILIAL+C7_NUM==xFilial("SC7")+cA120Num)
			If Empty(SC7->C7_NUMCOT)
				PcoDetLan("000053","01","MATA122")
			Else
				PcoDetLan("000053","02","MATA122")
			Endif
			SC7->(dbSkip())
		EndDo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000053")  
	EndIf		

ElseIf cProcess == "000055"

	dbSelectArea("SC7")
	dbSetOrder(1)
	If ( PcoExistLc("000055","01","2") .Or. ;  //se tem bloqueio ativo no processo
			PcoExistLc("000055","02","2") ) .And. ;  //se tem bloqueio ativo no processo
		dbSeek(xFilial("SC7")+cA120Num)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000055")
		lLibera	:= .F.
		While SC7->(! Eof() .And. C7_FILIAL+C7_NUM==xFilial("SC7")+cA120Num)
			If (SC7->C7_CONAPRO == "L")
				PcoDetLan("000055","01",'MATA097')
				lLibera := .T.
			Endif
			SC7->(dbSkip())
		EndDo
		If lLibera
			PcoDetLan("000055","02",'MATA097')
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000055")  
	EndIf		
	
ElseIf cProcess == "000354"//Planilha de Contrato - SIGAGCT

	oModel		:= FWModelActive()
	oModelCNB	:= oModel:GetModel("CNBDETAIL")

	dbSelectArea("CNB")
	dbSetOrder(1)
	If PcoExistLc("000354","02","2") .And. ;//se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("CNB")+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO'))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000354")
		For nFor := 1 To oModelCNb:Length()
			oModelCNB:GoLine(nFor)
			PcoDetLan("000354","02","CNTA200")
		Next nFor
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000354")  
	EndIf		

ElseIf cProcess == "000355"//Medicao de Contrato - SIGAGCT

	dbSelectArea("CNE")
	dbSetOrder(1)
	If PcoExistLc("000355","02","2") .And. ;//se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("CNE")+M->CND_CONTRA+M->CND_REVISA+M->CND_NUMERO+M->CND_NUMMED)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000355")
		While CNE->(! Eof() .And. CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED==xFilial("CNE")+M->CND_CONTRA+M->CND_REVISA+M->CND_NUMERO+M->CND_NUMMED)
			PcoDetLan("000355","02","CNTA120")
			CNE->(dbSkip())
		EndDo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000355")
	EndIf

ElseIf cProcess == "000150"//Solicitacao ao Armazem - SIGAEST

	dbSelectArea("SCP")
	dbSetOrder(1)
	If PcoExistLc("000150","01","2") .And. ;//se tem bloqueio ativo no processo
		PcoVerifAcols(cProcess) .And. ;    //se foi alterado a grade e nao confirmou
		dbSeek(xFilial("SCP")+cA105Num)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoIniLan("000150")
		While SCP->(! Eof() .And. CP_FILIAL+CP_NUM==xFilial("SCP")+cA105Num)
			PcoDetLan("000150","01","MATA105")
			SCP->(dbSkip())
		EndDo
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000150")
	EndIf

EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_CubeProc(cProcesso, lShowMessage)	
Local aArea := GetArea()
Local cQuery
Local cQryAKH
Local lRet := .F.
Local cSrvType := Alltrim(Upper(TCSrvType()))
Local aAreaAKH, aAreaAL3, aAreaAKJ, aTipoBlq := {}, nX

Local lQuery := ( Alltrim(Upper(TCSrvType())) # "AS/400" .and. TCGetDB()!="SYBASE" )

If lQuery
	If cSrvType == "ISERIES"
		lQuery := .F.
	EndIf
	If Alltrim(Upper(TcGetDb())) == "INFORMIX"
		lQuery := .F.
	EndIf
EndIf
			
If lQuery
	cQryAKH := " SELECT DISTINCT AKH_CODBLQ FROM "
	cQryAKH += RetSqlName("AKH")
	cQryAKH += " WHERE "
	cQryAKH += " AKH_FILIAL  = '" + xFilial("AKH")+"' "
	cQryAKH += " AND AKH_PROCES = '" + cProcesso +"' "
	cQryAKH += " AND D_E_L_E_T_ = ' '"
	
	cQuery := " SELECT DISTINCT AL3_CONFIG FROM "
	cQuery += RetSqlName("AL3")+" AL3 "
	cQuery += " WHERE "
	cQuery += " AL3_FILIAL = '" + xFilial("AL3") + "' "
	cQuery += " AND AL3_CODIGO IN ( "
	cQuery += "                     SELECT DISTINCT AKJ_PRVCFG FROM "
	cQuery += 						RetSqlName("AKJ")+ " AKJ "
	cQuery += "                     WHERE AKJ_FILIAL = '" + xFilial("AKJ") +"' "
	cQuery += "                     AND AKJ_COD IN ( " + cQryAKH + " ) "
	cQuery += "                     AND AKJ.D_E_L_E_T_ = ' ' "
	cQuery += " 					UNION
	cQuery += " 					SELECT DISTINCT AKJ_REACFG FROM "
	cQuery += 						RetSqlName("AKJ")+ " AKJ1 "
	cQuery += "                     WHERE AKJ_FILIAL = '" + xFilial("AKJ") +"' "
	cQuery += "                     AND AKJ_COD IN ( " + cQryAKH + " ) "
	cQuery += "                     AND AKJ1.D_E_L_E_T_ = ' ' ) "
	cQuery += " AND AL3.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)                
				
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "AL3_QRY", .T., .T. )
	AL3_QRY->(dbGoTop())
					
	While AL3_QRY->(!Eof())
	
		If Pco_UsedCube(AL3_QRY->AL3_CONFIG)  
			//se o cubo estiver sendo reprocessado retorna .t. para nao permitir continuar a Digitacao
			If lShowMessage
				Aviso("Atencao", "Cubo "+AL3_QRY->AL3_CONFIG+" esta sendo reprocessado. Aguarde! ", {"Ok"})
			EndIf
			lRet := .T.	
			Exit
		EndIf
	
		AL3_QRY->( dbSkip() )	
		
	EndDo
	
	AL3_QRY->(dbCloseArea())

Else

	aAreaAKH := AKH->(GetArea())
	aAreaAL3 := AL3->(GetArea())
	aAreaAKJ := AKJ->(GetArea())
	
	dbSelectArea("AKH")
	dbSetOrder(1)
	dbSeek(xFilial("AKH")+cProcesso)
	
	While AKH->( ! Eof() .And. AKH_FILIAL+AKH_PROCES == xFilial("AKH")+cProcesso )
	
		If Ascan(aTipoBlq, AKH->AKH_CODBLQ) == 0
			aAdd(aTipoBlq, AKH->AKH_CODBLQ)
		EndIf	

		AKH->(dbSkip())	
		
	EndDo
	
	dbSelectArea("AL3")
	dbSetOrder(1)

	dbSelectArea("AKJ")
	dbSetOrder(1)

	For nX := 1 TO Len(aTipoBlq)
	
		dbSelectArea("AKJ")
		If dbSeek(xFilial("AKJ")+aTipoBlq[nX])
		
			dbSelectArea("AL3")
			//procura a configuracao referente ao orcado/previsto
			If dbSeek(xFilial("AL3")+AKJ->AKJ_PRVCFG)	
		
				If Pco_UsedCube(AL3->AL3_CONFIG)  
					//se o cubo estiver sendo reprocessado retorna .t. para nao permitir continuar a Digitacao
					If lShowMessage
						Aviso("Atencao", "Cubo "+AL3_QRY->AL3_CONFIG+" esta sendo reprocessado. Aguarde! ", {"Ok"})
					EndIf
					lRet := .T.	
					Exit
				EndIf
		
			EndIf
			
			//procura a configuracao referente ao realizado
			If dbSeek(xFilial("AL3")+AKJ->AKJ_REACFG)		
		
				If Pco_UsedCube(AL3->AL3_CONFIG)  
					//se o cubo estiver sendo reprocessado retorna .t. para nao permitir continuar a Digitacao
					If lShowMessage
						Aviso("Atencao", "Cubo "+AL3_QRY->AL3_CONFIG+" esta sendo reprocessado. Aguarde! ", {"Ok"})
					EndIf
					lRet := .T.	
					Exit
				EndIf
		
			EndIf

		EndIf

	Next
	
	RestArea(aAreaAKH)
	RestArea(aAreaAL3)
	RestArea(aAreaAKJ)

EndIf
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOXFUN   บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoCubeStatus(cStatus)
Local 	cQuery    := ""
Local lQuery := ( TcGetDb() # "AS/400" .and. TCGetDB()!="SYBASE" )              

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If AL1->(FieldPos("AL1_STATUS")) > 0
	
		dbSelectArea("AL1")
		dbSetOrder(1)
		
		If lQuery
			cQuery 	+= "  UPDATE  "
			cQuery 	+= RetSQLName("AL1") + " "
			cQuery 	+= "  SET "
			cQuery 	+= "  AL1_STATUS = '"+cStatus+"' "
			cQuery 	+= "  WHERE "
			cQuery 	+= "  AL1_FILIAL  = '"+xFilial("AL1")+"' "
			cQuery 	+= "  AND AL1_CONFIG = '"+AL1->AL1_CONFIG+"' "
			cQuery 	+= "  AND D_E_L_E_T_ <> '*' "
			
			TcSqlExec(cQuery)
//			TcSqlExec("COMMIT")
			//apos processar query fecha o alias correspondente
			dbSelectArea("AL1")
				
		Else
		
			If MsRLock()  //se conseguir travar atualiza status, senao eh pq esta reprocessando
				AL1->AL1_STATUS := cStatus
				MsUnLock()
			EndIf
				
		EndIf
		
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPco_UsedCubeบAutor  ณPaulo Carnelossi    บ Data ณ 19/05/08  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que verifica se o cubo informado esta em uso pela    บฑฑ
ฑฑบ          ณrotina de reprocessamento de cubos (pcoa300)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Pco_UsedCube(cCodCube)
Local aArea		:= GetArea()
Local aAreaAL1	:= AL1->(GetArea())
Local lRet 		:= .F.

DEFAULT cCodCube := ""

dbSelectArea("AL1")
dbSetOrder(1)

If cCodCube != AL1->AL1_CONFIG  //se nao estiver posicionado no cubo*/
	If dbSeek(xFilial("AL1")+cCodCube)  //posiciona no cubo
		If AL1->(FieldPos("AL1_STATUS")) > 0
			lRet := ( AL1->AL1_STATUS == "2" )
		Else
			lRet := .F.  //Quando nao existir o campo AL1_STATUS retorna sempre que o cubo nao esta sendo usado			lRet := .F.
		EndIf	
	EndIf

Else
	//se ja esta posicionado somente retorna status do cubo
	If AL1->(FieldPos("AL1_STATUS")) > 0
		lRet := ( AL1->AL1_STATUS == "2" )
	Else
		lRet := .F.  //Quando nao existir o campo AL1_STATUS retorna sempre que o cubo nao esta sendo usado
	EndIf	
EndIf

RestArea(aAreaAL1)
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoIniIntณ Autor ณ Daniel Leme            ณ Data ณ 11-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao inicializacao da gravacao dos lancamentos de Integra็ใoณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoIniInt(cProcesso)
Local nUltProc
Local nX, aProcDep

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	//*********************************************************
	// Prepara variavel de controle do estorno da contigencia *
	//*********************************************************
	cIDLan		:= StrZero(1,Len(AMJ->AMJ_ID))
	lDetLanc		:= .F.
	aRecBlq		:= Nil
	aRecLanc		:= {}

	If aScan( aMudouAcols , {|x| x[1]==cProcesso})==0
		aAdd( aMudouAcols , {cProcesso,.F.} )
	EndIf

	If Empty(cPcoLote)
		nSaveSX8	:= GetSX8Len()
	EndIf
    
    //adiciona no array aPcoProc (Static )e insere um array com 
    // 1 - Codigo do Processo
    // 2 - Logico .F.  (lDetLan - qdo grava um lcto em pcodetlan muda para .T.)
    // 3 - array contendo os recnos AKD referente ao bloqueio
    // 4 - array contendo os recnos dos lancamentos (AKD)
    // 5 - NUMERO DO LOTE (VERIFICAR O Q COLOCA)
    // 6 - NUMERO SX8 (OS Q JA ESTAO RESERVADOS)
    // 7 - ID DO LANCAMENTO
    
	aAdd(aPcoProc, aClone(Array(7)) )
	nUltProc := Len(aPcoProc)
	aPcoProc[nUltProc, PCO_PROC 	] 	:= cProcesso
	aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .F.
	aPcoProc[nUltProc, PCO_REGBLOQ 	] 	:= aClone({})
	aPcoProc[nUltProc, PCO_REGLANC 	] 	:= aClone({})
	aPcoProc[nUltProc, PCO_LOTE 	] 	:= ""
	aPcoProc[nUltProc, PCO_SAVESX8 	] 	:= GetSX8Len()
	aPcoProc[nUltProc, PCO_IDLAN 	] 	:= StrZero(1,Len(AKD->AKD_ID))

	//abre arquivos 
	If nUltProc == 1

		PcoAbreArq(cProcesso)

		aProcDep := PcoProcRelac(cProcesso)
		For nX := 1 To Len(aProcDep)
			PcoAbreArq(aProcDep[nX])			
		Next // nX

	EndIf	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoFinIntณ Autor ณ Daniel Leme            ณ Data ณ 11-08-2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de finalizacao dos lancamentos de Integra็ใo           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoFinInt(cProcesso)
Local aArea			:= GetArea()
Local nUltProc 	:= Len(aPcoProc)
Local nQtReserv

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	
	AK8->(dbSetOrder(1))
	AK8->(MsSeek(xFilial()+cProcesso))
	FreeUsedCodes(.T.)

	DbSelectArea('AMJ')
	nQtReserv := GetSX8Len()
	While ( GetSX8Len() > aPcoProc[nUltProc, PCO_SAVESX8] )
		RollBackSX8()
		If nQtReserv == GetSX8Len()  //contingencia para nao entrar em loop infinito
			Exit                     //se depois do RollBackSX8() nao decrementou 
		EndIf
	EndDo
		
   
   If nUltProc > 0
    	aRecLanc := aPcoProc[nUltProc, PCO_REGLANC 	]
    	aSize(aPcoProc, nUltProc-1)
   EndIf

EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoDetIntณ Autor ณ Daniel Leme            ณ Data ณ 06/08/2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de geracao dos lancamentos na แrea de Integra็ใo       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPCO                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoDetInt(cProcesso,cItem,cPrograma,lDeleta, cProcDel,cAliasLanc)
Local aArea			:= GetArea()
Local aAreaAMK		
Local aAreaAKB		
Local aAreaLanc		
Local aAreaSX3		:= SX3->(GetArea())
Local aRec_Lanc		:= {}
Local cChave		:= ""
Local lAtivo		:= .F.
Local nx
Local nZ, cNomCpo := "", aCposNew := {}
Local lFoundAMK
Local nLinhas := 1, aCposForm := {}, aCpos_Form := {}
Local nY, nTam, nElemChk, nPosCpo, cContCpo, aCposArray := {}
Local nRec_Lanc := 0
Local lNotBlind		:= !IsBlind()
Local nUltProc      := Len(aPcoProc)

Local cAliasQry := ""
Local lSeek 	 := .T.
Local cQuery := "" 

DEFAULT lDeleta 	:= .F.
DEFAULT cProcDel 	:= ""

DEFAULT cAliasLanc := "AMJ"

If SuperGetMV("MV_PCOINTE",.T.,"2")=="1"

	//***************************************************************
	//      Data: 12/08/09 - Acacio Egas                            *
	// Verrifica se a PcoDetLan foi chamada dentro de uma Transacao.*
	// Neste caso nao se pode manipular as Tabelas AKS e AKT dentro *
	// da transacao. A atualiza็ใo sera feita na PcoFinLan.         *
	//***************************************************************
	If Intransact()
		lDetTransa := .T.
	EndIf
	
	//-- Colocado este retorno para quando as rotinas que chamar pcodetint()
	//-- nao for chamado entre as funcoes PcoIniInt() e PcoFinInt()
	If Empty(aPcoProc) .Or. aRecBlq != Nil
		RestArea( aArea )
		Return
	EndIf	

	aAreaAMK := AMK->(GetArea())
	aAreaAKB := AKB->(GetArea())
	aAreaLanc:= AMJ->(GetArea())

	lFoundAMK := PcoHasInt(cProcesso,cItem)

	dbSelectArea("AKB")
	dbSetOrder(1)
	If MsSeek(xFilial("AKB")+cProcesso+cItem) .And. (lFoundAMK .Or. AKB->AKB_CFGON == "1")

		/*/
		Descricao do vetor aCposForm e aCpos_Form:
		
		aCposForm[1] : Nome do campo na tabela de configuracao de lancamentos (AMK)
		aCposForm[2] : Nome do campo na tabela de lancamentos (AMJ)
		aCposForm[3] : .T. - Utiliza funcao PcoPlancel()
				   		.F. - Formula em expressao ADVPL        
		aCposForm[4] : Nome do campo na grade de configuracao de lancamentos (AMK)p/ tratar erro
		aCposForm[5] : Resultado apos macro execucao
		/*/
	
		aCposForm	:= PcoCposForm(5)
		aCposNew		:= PcoCposNew(4)
	
		//-- aCposNew  - Preenche o array aCpos_Form com campos de usuแrio-> estrutura id๊ntica ao array aCposForm
		For nZ := 1 To Len(aCposNew)  
				
			cNomCpo := aCposNew[nZ]
			If AMK->(FieldPos(StrTran(cNomCpo,"AMJ_","AMK_"))) > 0
				aAdd(aCpos_Form, { StrTran(cNomCpo,"AMJ_","AMK_"), ;
									cNomCpo, ;
									.F., ;
									StrTran(cNomCpo,"AMJ_","AMK_"), ;
									NIL })
			EndIf
				
		Next  //-- nZ
	
		dbSelectArea(AKB->AKB_ENTIDA)
		dbSetOrder(AKB->AKB_INDICE)
		//-- Quando o usuแrio seleciona op็ใo de agrupar, limpa chave de origem		
		If Type("lAgrupa") != "U" .And. lAgrupa
			cChave := ""
		Else
			If cProcesso $ "000005" .And. ( cItem $ "04" )
				//-- Complemento da Chave para item Contabil e Classe de Valor
				cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AMJ->AMJ_CHAVE))
			ElseIf cProcesso $ "000006" .And. ( cItem $ "03" )
				//-- Complemento da Chave para item Contabil e Classe de Valor
				cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey())+SEZ->EZ_ITEMCTA+SEZ->EZ_CLVL,Len(AMJ->AMJ_CHAVE))
			ElseIf cProcesso $ "000007"//|000102"
				cChave := ""
			ElseIf cProcesso == "000009" .And. ! ( cItem $ "01|30" )
				cChave := ""
			ElseIf cProcesso == "000010" .And. ! ( cItem $ "01|16" )
				cChave := ""
			ElseIf cProcesso == "000011" .And. ! ( cItem $ "01" )
				cChave := ""
			ElseIf cProcesso == "000016" .And. ! ( cItem $ "01|02" )
				cChave := ""
			ElseIf cProcesso == "000017" .And. ! ( cItem $ "01|02" )
				cChave := ""
			ElseIf cProcesso == "000056"  //Eliminacao de residuo sempre gera lcto
				cChave := ""              //em lote novo e nao fica vinculado pela chave
			ElseIf cProcesso == "000100" .And. cItem $ "02|04"
				cChave := ""		
			ElseIf cProcesso == "000356"  //Solicita็ใo de Contignecia
				cChave := Padr("ALJ"+&(IndexKey())+ cItem,Len(AMJ->AMJ_CHAVE))
			Else
				cChave := Padr(AKB->AKB_ENTIDA+&(IndexKey()),Len(AMJ->AMJ_CHAVE))
			EndIf
	
		EndIf
		
		//-- Caso seja preenchida a chave, serใo buscados os registros para esta chave
		If !Empty(cChave) 
		
				cAliasQry := GetNextAlias() 
				cQuery := " SELECT AMJ_LOTE LOTE,R_E_C_N_O_ RECNO FROM " + RetSqlName( "AMJ" ) 
				cQuery += " WHERE "
				cQuery += " 	AMJ_FILIAL 		= '" + xFilial("AMJ")	+ "'" 
				cQuery += " 	AND AMJ_CHAVE  = '" + cChave				+ "'" 
				cQuery += " 	AND AMJ_PROCES = '" + cProcesso			+ "'"
				cQuery += " 	AND D_E_L_E_T_ = ' '"                        
				
				cQuery := ChangeQuery( cQuery ) 
				
				dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .f., .t. ) 
				TcSetField( cAliasQry, "RECNO", "N", 12, 0 ) 
				
				While !( cAliasQry )->( Eof() ) 
				
					aPcoProc[nUltProc, PCO_LOTE] := ( cAliasQry )->LOTE
					aAdd(aRec_Lanc, ( cAliasQry )->RECNO )

					( cAliasQry )->( dbSkip() ) 
										
				EndDo 
			    
				( cAliasQry )->( dbCloseArea()) 
				dbSelectArea( "AMJ" ) 
			
		EndIf

		//--  Se nใo foi encontrado registro para a chave, cria um novo lote para o(s) lancamentos.			
		If Empty(aRec_Lanc) .And. Empty(aPcoProc[nUltProc, PCO_LOTE])
			
				dbSelectArea("AMJ")
				dbSetOrder(1)
				aPcoProc[nUltProc, PCO_LOTE] := CriaVar("AMJ_LOTE",.T.)
				While !Empty(aPcoProc[nUltProc, PCO_LOTE]) .And. ;
						( AMJ->(dbSeek(xFilial("AMJ")+aPcoProc[nUltProc, PCO_LOTE])) .Or.;
						 !MayIUseCode("AMJ"+xFilial("AMJ")+aPcoProc[nUltProc, PCO_LOTE])  ) 
	
					aPcoProc[nUltProc, PCO_LOTE] := Soma1(aPcoProc[nUltProc, PCO_LOTE],Len(AMJ->AMJ_LOTE))
	
				End
		EndIf

		//-- Processa os lan็amentos do Processo/Item		
		dbSelectArea("AMK")
		dbSetOrder(1)
		If MsSeek(xFilial("AMK")+cProcesso+cItem)
			While !Eof() .And. xFilial("AMK")+cProcesso+cItem==AMK->AMK_FILIAL+AMK->AMK_PROCES+AMK->AMK_ITEM
				If AMK_ATIVO == BMP_ON 
					lAtivo 	:= .T.
					If !lDeleta
					
						//-- Verifica se existe uma funcao de usuario para ser executada antes 
						//-- de comecar o lancamento 
						If FieldPos('AMK_EXEPRE') > 0 .And. !Empty(AMK_EXEPRE)
							&(Alltrim(AMK_EXEPRE)+IIf("("$Alltrim(AMK_EXEPRE),"","(.F.)"))				      
						Endif

						//-- Faz macro execucao em todos os campos da tabela AMK
						//-- e armazena na posicao 5 do array aCposForm
						nTam := Len(aCposForm)
						For nZ := 1 To nTam
						
							nPosCpo := AMK->(FieldPos(aCposForm[nZ,1]))
							If nPosCpo > 0
								cContCpo := AMK->(FieldGet(nPosCpo))
								If !Empty(cContCpo)
									uValor := Eval( &( "{|| " + cContCpo+" }")) 
									aCposForm[nZ, 5] := uValor
								EndIf    
							EndIf
					        
						Next //-- nZ
					
					
						//-- Faz macro execucao em todos os campos da tabela AMK
						//-- e armazena na posicao 5 do array aCpos_Form - Cpos de Usuแrio
						nTam := Len(aCpos_Form)  
						For nZ := 1 To nTam
						
							nPosCpo := AMK->(FieldPos(aCpos_Form[nZ,1]))
							If nPosCpo > 0
								cContCpo := AMK->(FieldGet(nPosCpo))
								If !Empty(cContCpo)
									uValor := Eval( &( "{|| " + cContCpo+" }")) 
									aCpos_Form[nZ, 5] := uValor
								EndIf
							EndIf
					        
						Next //-- nZ
						
						/*/ 
							Guarda no aCposArray todos os resultados Tipo = Array e para outros tipos valida tipo do campo
							Estrutura do Array aCposArray
								aCposArray[nL,1] : Nome do campo na tabela de lancamentos (AKD)
								aCposArray[nL,2] : Tamanho do Array de resultado da macro execucao
								aCposArray[nL,3] : 1=aCposForm - 2=aCpos_Form (em q array vai buscar resultado)
								aCposArray[nL,4] : Elemento do Array para busca do resultado da macro execucao
						/*/

						For nZ := 1 To Len(aCposForm)
							If ValType(aCposForm[nZ, 5])=="A" 
								aAdd(aCposArray, {aCposForm[nZ, 2], Len(aCposForm[nZ, 5]), 1, nZ } )
							Else
								//-- Se nใo ้ array, valida tipo do campo 
								If lNotBlind .And. aCposForm[nZ, 5] != NIL .And. ValType(aCposForm[nZ, 5]) # TamSX3(aCposForm[nZ,2])[3]
									Alert( STR0043 + AllTrim(aCposForm[nZ,1])) //-- Tipo de dado invรกlido informado na coluna: 
								EndIf
							EndIf	
						Next //-- nZ
						
						For nZ := 1 To Len(aCpos_Form)
							If ValType(aCpos_Form[nZ, 5])=="A"
								aAdd(aCposArray, {aCpos_Form[nZ, 2], Len(aCpos_Form[nZ, 5]), 2, nZ } )
							Else
								//-- Se nใo ้ array, valida tipo do campo 
								If lNotBlind .And. aCpos_Form[nZ, 5] != NIL .And. ValType(aCpos_Form[nZ, 5]) # TamSX3(aCpos_Form[nZ,2])[3]
									Alert( STR0043 + AllTrim(aCpos_Form[nZ,1])) //-- Tipo de dado invรกlido informado na coluna: 
								EndIf
							EndIf	
						Next //-- nZ
						

						//-- Testa se todos estao do mesmo tamanho e do mesmo tipo 
						//-- o comando "For" come็a do segundo elemento para Retornos tipo Array
						For nZ := 2 To Len(aCposArray)
							//-- Verifica elemento anterior com atual
							If lNotBlind .And. aCposArray[nZ-1, 2] != aCposArray[nZ, 2]
								Alert( STR0045+;										//-- "Os vetores com resultados estao com tamanho diferente."
										STR0046+ aCposArray[nZ-1, 1] + "/" +;	//-- "Verifique a expressao dos campos "
										aCposArray[nZ, 1])
							EndIf
						Next //-- nZ
						
						//-- Verifica se tipo esta de acordo com dicionario
						//-- para os campos que retornaram array
						For nZ := 1 To Len(aCposArray)
							cTypeCpo := TamSX3(aCposArray[nZ,1])[3]
							
							//-- Verifica se tipo esta de acordo com dicionario
							nElemChk := aCposArray[nZ,4]
							If aCposArray[nZ,3] == 1
								For nY := 1 To Len(aCposForm[nElemChk, 5])
									If lNotBlind .And. ValType(aCposForm[nElemChk, 5, nY]) # cTypeCpo
										Alert( STR0043 + AllTrim(aCposForm[nElemChk,1]))	//-- Tipo de dado invรกlido informado na coluna: 
									EndIf
								Next //-- nY
							Else
								For nY := 1 To Len(aCpos_Form[nElemChk, 5])
									If lNotBlind .And. ValType(aCpos_Form[nElemChk, 5, nY]) # cTypeCpo
										Alert( STR0043 + AllTrim(aCpos_Form[nElemChk,1]))	//-- Tipo de dado invรกlido informado na coluna: 
									EndIf
								Next //-- nY
							EndIf	
							
						Next //-- nZ
						
						//-- Se nใo falhou nenhuma validacao acrescenta registro tabela de Lancamentos - AMJ
						//--    Entใo: Inicia gravacao na tabela de Lan็amentos - AMJ
						If Len(aCposArray) > 0
							nLinhas := aCposArray[1, 2]
						Else
							nLinhas := 1
						EndIf
						
						//-- Se apenas uma ๚nica Linha
						If nLinhas == 1
							If (			Eval( &( "{|| " + If(!Empty(AMK->AMK_VALOR1), AMK->AMK_VALOR1, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AMK->AMK_VALOR2), AMK->AMK_VALOR2, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AMK->AMK_VALOR3), AMK->AMK_VALOR3, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AMK->AMK_VALOR4), AMK->AMK_VALOR4, "0")+" }"))	> 0 .OR. ;
											Eval( &( "{|| " + If(!Empty(AMK->AMK_VALOR5), AMK->AMK_VALOR5, "0")+" }"))	> 0 )
								
								aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .T.

								AMJ->( dBSetOrder(2))
								
								lSeek := .T.
								If !Empty(cChave) .And. Len(aRec_Lanc) > 0

									For nX:= 1 To Len(aRec_Lanc)   
										If aRec_Lanc[nX] > 0
											AMJ->(dbGoto(aRec_Lanc[nX]))
											If AMK->AMK_SEQ == AMJ->AMJ_SEQ

												RecLock("AMJ",.F.)
												lSeek := .F.
												aRec_Lanc[aScan(aRec_Lanc,AMJ->(RecNo()))] := -1
												Exit
											EndIf
										EndIf
									Next nX

								ElseIf Empty(cChave) //-- As integra็๕es que nใo possuem Chave serใo tratadas como se fossem acumulados
                           
									cAliasQry := GetNextAlias()
									cQuery := " SELECT R_E_C_N_O_ RECNO"
									cQuery += " FROM " + RetSqlName( "AMJ" )
									cQuery += " WHERE "
									cQuery += " 	AMJ_FILIAL		= '" + xFilial("AMJ")  + "'"
									cQuery += " 	AND AMJ_PROCES	= '" + AMK->AMK_PROCES + "'"
									cQuery += " 	AND AMJ_ITEM   = '" + AMK->AMK_ITEM   + "'"
									cQuery += " 	AND AMJ_SEQ    = '" + AMK->AMK_SEQ    + "'"

									//-- Realiza busca pela Chave acumuladora                           
									AMJ->(DbSetOrder(4)) //-- AMJ_FILIAL+AMJ_PROCES+AMJ_ITEM+AMJ_SEQ+AMJ_CO+AMJ_CLASSE+AMJ_OPER+AMJ_CC+AMJ_ITCTB+AMJ_CLVLR+DtoS(AMJ_DATA)
									nTam := Len(aCposForm)
									For nZ := 1 To nTam
										
										If aCposForm[nZ,2] $ AMJ->(IndexKey()) // .And. (nPosCpo := AMJ->(FieldPos(aCposForm[nZ,2]))) > 0
											uValor := aCposForm[nZ, 5]
											If uValor != NIl .And. !Empty(uValor)
												If ValType(uValor) == "C"
													cQuery += " AND " + aCposForm[nZ,2] + " = '" + aCposForm[nZ][5] + "'"
												ElseIf ValType(uValor) == "D"
													cQuery += " AND " + aCposForm[nZ,2] + " = '" + DtoS(aCposForm[nZ][5]) + "'"
												ElseIf ValType(uValor) == "N"
													cQuery += " AND " + aCposForm[nZ,2] + " = " + Str( aCposForm[nZ][5] )
												EndIf
											Else
												If ValType(AMJ->&(aCposForm[nZ,2]) ) $ "D/C"
													cQuery += " AND " + aCposForm[nZ,2] + " = ' ' "
												ElseIf ValType(AMJ->&(aCposForm[nZ,2]) ) == "N"												
													cQuery += " AND " + aCposForm[nZ,2] + " = 0 "
												EndIf
											EndIf
										EndIf
						        
									Next //-- nZ
	
									cQuery += " 	AND D_E_L_E_T_ = ' '"

									cQuery := ChangeQuery( cQuery )

									dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .f., .t. )

									//-- Se encontrar registro, soma os valores (1 a 5)
									If (cAliasQry)->(!Eof()) .And. !Empty( (cAliasQry)->RECNO )
									
										AMJ->(DbGoto( (cAliasQry)->RECNO ) )
									
										RecLock("AMJ",.F.)
										aEval(aCposForm,{|x| x[5] := If( x[5] != Nil .And. !Empty(x[5]) .And. "_VALOR" $ x[2] ,;
																					x[5] + AMJ->&(x[2]),;
																					AMJ->&(x[2]) ) })
										lSeek := .F.
								
									EndIf

									(cAliasQry)->( dbCloseArea())

								EndIf
								
								If lSeek
                           
									cAliasQry := GetNextAlias()
									cQuery := " SELECT MAX( AMJ_ID ) MAXID FROM " + RetSqlName( "AMJ" )
									cQuery += " WHERE "
									cQuery += " 	AMJ_FILIAL		= '" + xFilial("AMJ")                + "'"
									cQuery += " 	AND AMJ_LOTE	= '" + aPcoProc[nUltProc, PCO_LOTE]  + "'"
									cQuery += " 	AND AMJ_ID	  >= '" + aPcoProc[nUltProc, PCO_IDLAN] + "'"
									cQuery += " 	AND D_E_L_E_T_ = ' '"

									cQuery := ChangeQuery( cQuery )

									dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .f., .t. )

									If (cAliasQry)->(!Eof()) .And. !Empty( (cAliasQry)->MAXID )
										aPcoProc[nUltProc, PCO_IDLAN] := SomaIt( (cAliasQry)->MAXID )
									EndIf

									(cAliasQry)->( dbCloseArea())

									dbSelectArea( "AMJ" )
								
									RecLock("AMJ",.T.)
									AMJ->AMJ_FILIAL	:= xFilial("AMJ")
									AMJ->AMJ_LOTE		:= aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
									AMJ->AMJ_ID			:= aPcoProc[nUltProc, PCO_IDLAN]//cIDLan
									
									aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
								EndIf

								//-- Gravacao dos campos armazenados no array aCposForm
								nTam := Len(aCposForm)
								For nZ := 1 To nTam
						
									nPosCpo := AMJ->(FieldPos(aCposForm[nZ,2]))
									If nPosCpo > 0
										uValor := aCposForm[nZ, 5]
										If uValor != NIl .And. !Empty(uValor)
											AMJ->(FieldPut(nPosCpo, uValor))
										EndIf
									EndIf
					        
								Next //-- nZ

								//-- Gravacao dos campos armazenados no array aCpos_Form
								nTam := Len(aCpos_Form)
								For nZ := 1 To nTam
						
									nPosCpo := AMJ->(FieldPos(aCpos_Form[nZ,2]))
									If nPosCpo > 0
										uValor := aCpos_Form[nZ, 5]
										If uValor != Nil .And. !Empty(uValor)
											AMJ->(FieldPut(nPosCpo, uValor))
										EndIf
									EndIf
					        
								Next //-- nZ
								
								AMJ->AMJ_PROCES	:= AMK->AMK_PROCES
								AMJ->AMJ_ITEM		:= AMK->AMK_ITEM
								AMJ->AMJ_SEQ		:= AMK->AMK_SEQ
								//-- Estes campos somente sใo preenchidos se nใo houver agrupamento
								If Type("lAgrupa") != "U" .And. !lAgrupa								
									AMJ->AMJ_CHAVE		:= cChave
									AMJ->AMJ_IDREF		:= &(AMK->AMK_KEYREF)
								EndIf
								AMJ->( MsUnlock() )
														
								aAdd(aRecLanc,AMJ->(RecNo()))
								aAdd(aPcoProc[nUltProc, PCO_REGLANC],AMJ->(RecNo()))
							EndIf
							
						Else
							//-- Grava็ใo de vแrias linhas quando retorno da macro for do tipo Array
							For nY := 1 To nLinhas
								lSeek := .T.
								If PcoAcumValue("AMK", aCposForm, aCpos_Form) > 0
									aPcoProc[nUltProc, PCO_LDETLAN 	] 	:= .T.
									nRec_Lanc++

									If !Empty(cChave) .And. nRec_Lanc <= Len(aRec_Lanc) 

										For nX:= 1 To Len(aRec_Lanc)
											If aRec_Lanc[nX] > 0
												AMJ->(dbGoto(aRec_Lanc[nRec_Lanc]))
												If AMK->AMK_SEQ == AMJ->AMJ_SEQ
													RecLock("AMJ",.F.)
													lSeek := .F.
													aRec_Lanc[nRec_Lanc] := -1
													Exit
												EndIf
											EndIf
										Next nX

									ElseIf Empty(cChave) //-- As integra็๕es que nใo possuem Chave serใo tratadas como se fossem acumulados
	                           
										cAliasQry := GetNextAlias()
										cQuery := " SELECT R_E_C_N_O_ RECNO"
										cQuery += " FROM " + RetSqlName( "AMJ" )
										cQuery += " WHERE "
										cQuery += " 	AMJ_FILIAL		= '" + xFilial("AMJ")  + "'"
										cQuery += " 	AND AMJ_PROCES	= '" + AMK->AMK_PROCES + "'"
										cQuery += " 	AND AMJ_ITEM   = '" + AMK->AMK_ITEM   + "'"
										cQuery += " 	AND AMJ_SEQ    = '" + AMK->AMK_SEQ    + "'"
	
										//-- Realiza busca pela Chave acumuladora                           
										AMJ->(DbSetOrder(4)) //-- AMJ_FILIAL+AMJ_PROCES+AMJ_ITEM+AMJ_SEQ+AMJ_CO+AMJ_CLASSE+AMJ_OPER+AMJ_CC+AMJ_ITCTB+AMJ_CLVLR+DtoS(AMJ_DATA)
										nTam := Len(aCposForm)
										For nZ := 1 To nTam
											
											If aCposForm[nZ,2] $ AMJ->(IndexKey()) // .And. (nPosCpo := AMJ->(FieldPos(aCposForm[nZ,2]))) > 0
												If ValType(aCposForm[nZ, 5]) == "A"
													uValor := aCposForm[nZ, 5, nY]
												Else
													uValor := aCposForm[nZ, 5]
												EndIf
												If uValor != Nil .And. !Empty(uValor)
													If ValType(uValor) == "C"
														cQuery += " AND " + aCposForm[nZ,2] + " = '" + uValor + "'"
													ElseIf ValType(uValor) == "D"
														cQuery += " AND " + aCposForm[nZ,2] + " = '" + DtoS(uValor) + "'"
													ElseIf ValType(uValor) == "N"
														cQuery += " AND " + aCposForm[nZ,2] + " = " + Str( uValor )
													EndIf
												Else
													If ValType(AMJ->&(aCposForm[nZ,2]) ) $ "D/C"
														cQuery += " AND " + aCposForm[nZ,2] + " = ' ' "
													ElseIf ValType(AMJ->&(aCposForm[nZ,2]) ) == "N"												
														cQuery += " AND " + aCposForm[nZ,2] + " = 0 "
													EndIf
												EndIf
											EndIf
							        
										Next //-- nZ
		
										cQuery += " 	AND D_E_L_E_T_ = ' '"
	
										cQuery := ChangeQuery( cQuery )
	
										dbUseArea( .T. ,"TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .f., .t. )
	
	
										//-- Se encontrar registro, altera-o, somando os valores (1 a 5)
										If (cAliasQry)->(!Eof()) .And. !Empty( (cAliasQry)->RECNO )
										
											AMJ->(DbGoto( (cAliasQry)->RECNO ) )
										
											RecLock("AMJ",.F.)


											//-- Soma os valores (1 a 5)
											nTam := Len(aCposForm)
											For nZ := 1 To nTam
									
												nPosCpo := AMJ->(FieldPos(aCposForm[nZ,2]))
												If nPosCpo > 0 .And. aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
													If ValType(aCposForm[nZ,5]) == "A"
														aCposForm[nZ,5,nY] += AMJ->&(aCposForm[nZ][2])
													ElseIf ValType(aCposForm[nZ,5]) == "N"
														aCposForm[nZ,5] += AMJ->&(aCposForm[nZ][2])
													Else
														aCposForm[nZ,5] := AMJ->&(aCposForm[nZ][2])
													EndIf	
												EndIf
								        
											Next //-- nZ
											lSeek := .F.
									
										EndIf
	
										(cAliasQry)->( dbCloseArea())
	
									EndIf
									
									If lSeek
										
										AMJ->( dbSetOrder(1) )
										Do While AMJ->( dbSeek( xFilial("AMJ")+;
															aPcoProc[nUltProc, PCO_LOTE]+;
															aPcoProc[nUltProc, PCO_IDLAN] ) )
											aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
										EndDo
										RecLock("AMJ",.T.)
										AMJ->AMJ_FILIAL	:= xFilial("AMJ")
										AMJ->AMJ_LOTE		:= aPcoProc[nUltProc, PCO_LOTE] //cPcoLote
										AMJ->AMJ_ID			:= aPcoProc[nUltProc, PCO_IDLAN]//cIDLan
										aPcoProc[nUltProc, PCO_IDLAN] := SomaIt(aPcoProc[nUltProc, PCO_IDLAN])
									EndIf
									
									//-- Grava็ใo dos campos armazenados no array aCposForm
									nTam := Len(aCposForm)
									For nZ := 1 To nTam
							
										nPosCpo := AMJ->(FieldPos(aCposForm[nZ,2]))
										If nPosCpo > 0 .And. aCposForm[nZ,5] != NIL .And. !Empty(aCposForm[nZ,5])
											If ValType(aCposForm[nZ,5]) == "A"
												uValor := aCposForm[nZ,5,nY]
											Else
												uValor := aCposForm[nZ,5]
											EndIf	
											AMJ->(FieldPut(nPosCpo, uValor))
										EndIf
						        
									Next //-- nZ
	
									//-- Grava็ใo dos campos armazenados no array aCpos_Form
									nTam := Len(aCpos_Form)
									For nZ := 1 To nTam
							
										nPosCpo := AMJ->(FieldPos(aCpos_Form[nZ,2]))
										If nPosCpo > 0 .And. aCpos_Form[nZ,5] != NIL .And. !Empty(aCpos_Form[nZ,5])
											If ValType(aCpos_Form[nZ,5]) == "A"
												uValor := aCpos_Form[nZ,5,nY]
											Else
												uValor := aCpos_Form[nZ,5]
											EndIf	
											AMJ->(FieldPut(nPosCpo, uValor))
										EndIf
						        
									Next //-- nZ
	
									AMJ->AMJ_PROCES	:= AMK->AMK_PROCES
									AMJ->AMJ_ITEM		:= AMK->AMK_ITEM
									AMJ->AMJ_SEQ		:= AMK->AMK_SEQ
									//-- Estes campos somente sใo preenchidos se nใo houver agrupamento
									If Type("lAgrupa") != "U" .And. !lAgrupa								
										AMJ->AMJ_CHAVE		:= cChave
										AMJ->AMJ_IDREF		:= &(AMK->AMK_KEYREF)
									EndIf
									AMJ->( MsUnlock() )
									
									aAdd(aRecLanc,AMJ->(RecNo()))
									aAdd(aPcoProc[nUltProc, PCO_REGLANC],AMJ->(RecNo()))
								EndIf
							Next //-- nZ

						EndIf

					Else

						If !Empty(cProcDel)
					
							//-- Quando deve considerar o processo-item para exclusao do lancamento
							For nx := 1 To Len(aRec_Lanc)
								dbSelectArea("AMJ")
								dbGoto(aRec_Lanc[nx])
								//-- Aqui, Revisar
								If Alltrim(AMJ->(AMJ_PROCES+AMJ_ITEM)) $ cProcDel
									aRec_Lanc[nx] := -1
								EndIf	
							Next
						EndIf
						Exit

					EndIf

					//-- Limpar resultados da macro execucao posicao 5 dos arrays aCposForm e aCpos_Form
					AEval(aCposForm,{|x| x[5] := NIL })
					AEval(aCpos_Form,{|x| x[5] := NIL })

				EndIf
				dbSelectArea("AMK")
				dbSkip()
			End
		EndIf
		If lAtivo
			For nX := 1 To Len(aRec_Lanc)
				If aRec_Lanc[nX] > 0
					dbSelectArea("AMJ")
					dbGoto(aRec_Lanc[nX])
					RecLock("AMJ",.F.,.T.)
					dbDelete()
					MsUnlock()                                         
				EndIf
			Next
		EndIf
	EndIf
	RestArea(aAreaLanc)
	RestArea(aAreaAKB)
	RestArea(aAreaAMK)
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoAvistoTm บAutor  ณMicrosiga         บ Data ณ  24/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada da funcao PcoAvisoTimer() que eh um aviso com      บฑฑ
ฑฑบ          ณ timer()                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoAvisoTm(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,nTime,nOpcTimer)
Return(AvisoTimer(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,nTime,nOpcTimer))

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOMail
Fun็ใo gen้rica para envio de e-mail do ambiente Planejamento e Controle Or็amentแrio.

@param aDestinat Array com os e-mails destinatแrios
@param cAssunto	 Assunto do e-mail (Tํtulo)
@param cMensagem Mensagem do corpo do e-mail
@return lRet Retorno que indica se o e-mail foi enviado ou nใo.
@author marylly.araujo
@since 15/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function PcoMail(aDestinat,cAssunto,cMensagem) 
Local lRet			:= .T.
Local cTO			:= ""
Local cCC			:= ""
Local cFrom		:= SuperGetMV("MV_RELFROM",.F.,"")                                                                                  
Local cSMTPServer	:= SuperGetMV("MV_RELSERV",.F.,"")
Local cSMTPUser 	:= SuperGetMV("MV_RELACNT",.F.,"")
Local cSMTPPass 	:= SuperGetMV("MV_RELPSW",.F.,"")
Local nSMTPPort	:= 25
Local oMail		:= Nil
Local oMessage 	:= Nil
Local nErro		:= 0
Local nEmail		:= 0
Local lRelAuth 	:= SuperGetMV("MV_RELAUTH",.F., .F.)
Local nPortAux 	:= 0

DEFAULT aDestinat	:= {}
DEFAULT cAssunto	:= ""
DEFAULT cMensagem	:= ""

Private cError		:= ""
Private lSendOk	:=	.T.  

//tratamento para quando a porta estiver estipulada no parametro MV_RELSERV com ":" apos server
If ( nPortAux := At(":", cSMTPServer)) > 0
	nSMTPPort := Val(Alltrim(Substr(cSMTPServer, nPortAux+1)))
	cSMTPServer := Substr(cSMTPServer, 1, nPortAux - 1) 
EndIf

/*
 * Envio de e-mail s๓ ocorre se existirem destinatแrios
 */
If Len(aDestinat) > 0
	cTo := aDestinat[1] // Primeiro e-mail de destinatแrios

	/*
	 * Pr๓ximos destinatแrios com c๓pia oculta.
	 */
	For nEmail := 2 To Len(aDestinat)
		If EMPTY(cCC)
			cCC += aDestinat[nEmail]
		Else
			cCC += ", " + aDestinat[nEmail]
		EndIf
	Next nEmail
	
	/*
	 * Iniciando conexใo com o servidor de e-mails
	 */
	oMail := TMailManager():New()
	
	conout('Inicializando SMTP')
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nSMTPPort  )
	
	conout('Setando Time-Out')
	oMail:SetSmtpTimeOut( 500 )
	
	conout('Conectando com servidor...')
	nErro := oMail:SmtpConnect()
	
	conout('Status de Retorno = '+str(nErro,6))
	
	/*
	 * Autenticando o usuแrio no servidor de e-mails
	 */
	If lRelAuth
		Conout("Autenticando Usuario ")
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
		conout('Status de Retorno = '+str(nErro,6))
		If nErro <> 0
	
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')')
			lRet := .F.
		Endif
	EndIf

	If nErro <> 0
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		conout(cMAilError)
		
		Conout("Erro de Conexใo SMTP "+str(nErro,4))

		conout('Desconectando do SMTP')
		oMail:SMTPDisconnect()
		lRet := .F.
	Endif
				
	conout('Compondo mensagem em mem๓ria')
	/*
	 * Criando o objeto da mensagem do e-mail
	 */
	oMessage := TMailMessage():New()
	oMessage:Clear()      
    oMessage:cFrom		:= cFrom
    oMessage:cTo			:= cTo
    oMessage:cBcc			:= cCC
    oMessage:cSubject		:= cAssunto
    oMessage:cBody		:= cMensagem
    oMessage:MsgBodyType( "text/html" )
	
	conout(oMessage:cBody)
	conout('Enviando Mensagem para ['+cTo+'] ')
	nErro := oMessage:Send( oMail )
	
	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		Conout("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
		lRet := .F.
	Endif
	
	conout('Desconectando do SMTP')
	oMail:SMTPDisconnect()
Else
	CONOUT("Sem destinatแrios para envio do e-mail referente ao bloqueio or็amentแrio.")
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoIntransบAutor  ณ Acacio Egas        บ Data ณ  08/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se a Rotina PcoDetLan esta dentro de uma transacao บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOXSLD                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoIntrans()
Return lDetTransa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPcoSleep บAutor  ณ Microsiga           บ Data ณ  11/10/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sleep usado para dar um tempo antes de incrementar o lote  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCODETLAN                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PcoSleep()
If __nCtdSleep == NIL .OR. __nCtdSleep > 10
	__nCtdSleep := 0
EndIf

__nCtdSleep++

Sleep( __nCtdSleep*100 )  //espera ateh no maximo 1000 milisegundos

Return

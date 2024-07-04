
#Include "PROTHEUS.CH"

STATIC aCritRPC 	:= {}
STATIC __lGetPerRPC	:= BGJ->(FIELDPOS("BGJ_PERRPC")) > 0 .Or. BH3->(FIELDPOS("BH3_PERRPC")) > 0 .Or. BYA->(FIELDPOS("BYA_PERRPC")) > 0

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSUARPC  ╨Autor  ЁThiago Machado Correa ╨ Data Ё  13/07/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё RPC - Programa para criacao do txt utilizado no software da  ╨╠╠
╠╠╨          Ё ans para envio do comunicado de reajuste.                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Pls                                                          ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PLSUARPC()

Local nOpca       := 0
Local aSays       := {}
Local aButtons    := {}
Local cCaminhoArq := ""
Private cPerg     := "PLSRPC"
Private cCadastro := FunDesc() //"GeraГЦo RPC"
Private cBA1Name  := RetSQLName("BA1")
Private cBA3Name  := RetSQLName("BA3")  
Private cBI3Name  := RetSQLName("BI3")
Private nTotRC2   := 0
Private nTotRC3   := 0
Private nTotRC4   := 0
Private cNomArq
Private cQuery
Private cCodOpe
Private cEmpIni
Private cEmpFim
Private cConIni
Private cConFim
Private cSubIni
Private cSubFim
Private cPlaIni
Private cPlaFim
Private cMesIni
Private cAnoIni
Private cMesFim
Private cAnoFim
Private cDiretorio
Private cProdNaoUt  
Private cMesAnoIReaj
Private cMesAnoFReaj
Private cMesAnoIAnal
Private cMesAnoFAnal
Private oTempRC3
Private lCopart
Private lPERPC01   := ExistBlock("PLSRPC01")
Private lPERPC02   := ExistBlock("PLSRPC02")
Private lExiCLARPC := BG7->( FieldPos("BG7_CLARPC") ) > 0

If BQC->(FieldPos("BQC_MOTREA")) == 0
   MsgInfo("Para utilizar esta rotina deve-se criar o campo BQC_MOTREA. Por favor entre em contato com o Suporte.")
   Return
Endif

If BQC->(FieldPos("BQC_CARREA")) == 0
   MsgInfo("Para utilizar esta rotina deve-se criar o campo BQC_CARREA. Por favor entre em contato com o Suporte.")
   Return
Endif

If BQC->(FieldPos("BQC_REALIN")) == 0
   MsgInfo("Para utilizar esta rotina deve-se criar o campo BQC_REALIN. Por favor entre em contato com o Suporte.")
   Return
Endif

BA0->(DbSetOrder(1)) // Operadora    
BI3->(DbSetOrder(1)) // Produto
BQC->(DbSetOrder(1)) // Sub-Contrato
BT6->(DbSetOrder(1)) // Sub-Contrato x Produto
BPF->(DbSetOrder(1)) // Reajuste x Sub-Contrato
BG1->(DbSetOrder(1))
BG3->(DbSetOrder(1))
BQU->(DbSetOrder(1))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aSays,"Esta rotina efetua a exportacao dos contratos reajustados para o software RPC da ANS." )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
Aadd(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk() .and. Ver_perg(), FechaBatch(), nOpca:=0 ) }} )
Aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FormBatch(cCadastro,aSays,aButtons)

If  nOpca == 1

	cCodOpe      := mv_par01
	cEmpIni      := mv_par02
	cEmpFim      := mv_par03
	cConIni      := mv_par04
	cConFim      := mv_par05
	cSubIni      := mv_par06
	cSubFim      := mv_par07
	cPlaIni      := mv_par08
	cPlaFim      := mv_par09
	cMesIni      := mv_par10
    cAnoIni      := mv_par11
    cMesFim      := mv_par12
    cAnoFim      := mv_par13
	cDiretorio   := mv_par14
	cProdNaoUt   := mv_par15
	cMesAnoIReaj := mv_par16
	cMesAnoFReaj := mv_par17
	cMesAnoIAnal := mv_par18
	cMesAnoFAnal := mv_par19
	cConsidCancel := mv_par21 //1 - Sim / 2 - NЦo
	cConsidSusp := mv_par22 //1 - Sim / 2 - NЦo
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Valida periodo informado...		                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (cAnoIni+cMesIni) > (cAnoFim+cMesFim)
		MsgStop("Intervalo de datas incorreto!!!")
	Else
		msAguarde( {|| PlsuaRpcPrep() }, "Aguarde...","Preparando ambiente.", .T.)
	
		Tmp->(DbGoTop())
		
		If Tmp->(EOF())
			MsgStop("Nenhum registro encontrado para os parametros informados.")   
		Else	 
		    cNomArq := "RPC" + cCodOpe + substr(dtos(date()),7,2) + substr(dtos(date()),5,2) + substr(dtos(date()),1,4) + substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2) + "." + "txt"
		    PlsPTU("RPC   ",cNomArq,cDiretorio)

		    If Len(aCritRPC) > 0
		       PLSCRIGEN(aCritRPC, {{"Descricao","@!",200},{"Chave","@!",500}}, "Criticas da Geracao RPC ")
		    Endif
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Fecha arquivo temporario...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		TMP->(dbCloseArea())
	Endif    

Endif
                
Return Nil

Static Function Ver_perg()
	Pergunte(cPerg,.F.)
Return .T.

Function PlsuaRpcPrep()
 	//зддддддддддддддддддддддддддддддд©
 	//Ё Cria a Query dos reajustes... Ё
	//юддддддддддддддддддддддддддддддды
	
	aCritRPC := {}

	cQuery := " SELECT BYC_OPEREA BPF_OPEREA,BYC_CODREA BPF_CODREA, BYC_CODEMP BPF_CODEMP, BYC_CONEMP BPF_CONEMP, BYC_VERCON BPF_VERCON, "
	cQuery += " BYC_SUBCON BPF_SUBCON, BYC_VERSUB BPF_VERSUB, BYC_CODPRO BPF_CODPRO, BYC_VERPRO BPF_VERPRO, BI3_SUSEP BI3_SUSEP, SUBSTRING(BHW_ANOMES,1,4) BPF_ANOREA, SUBSTRING(BHW_ANOMES,5,2) BPF_MESREA "
	cQuery += " FROM " + RetSQLName("BYC") + ", " + RetSQLName("BHW") + ", " + RetSQLName("BI3")
	cQuery += " WHERE BYC_FILIAL = '"  + xFilial("BYC") + "'"    
	cQuery += " AND BHW_FILIAL = '"  + xFilial("BHW") + "'" 
	cQuery += " AND BI3_FILIAL = '"  + xFilial("BI3") + "'"
	cQuery += " AND BYC_OPEREA = BHW_CODINT "
	cQuery += " AND BYC_CODREA = BHW_CODREA  "
	cQuery += " AND BYC_OPEREA = BI3_CODINT 
	cQuery += " AND BYC_CODPRO = BI3_CODIGO
	cQuery += " AND BYC_OPEREA = '"  + cCodOpe + "'" 
	cQuery += " AND BYC_CODEMP >= '" + cEmpIni + "'"
	cQuery += " AND BYC_CODEMP <= '" + cEmpFim + "'"
	cQuery += " AND BYC_CONEMP >= '" + cConIni + "'"
	cQuery += " AND BYC_CONEMP <= '" + cConFim + "'"
	cQuery += " AND BYC_SUBCON >= '" + cSubIni + "'"
	cQuery += " AND BYC_SUBCON <= '" + cSubFim + "'"
	cQuery += " AND BYC_CODPRO >= '" + cPlaIni + "'"
	cQuery += " AND BYC_CODPRO <= '" + cPlaFim + "'"
	//Filtro de produto 1=Ativos;2=Ativos com ComercializaГЦo Suspensa;3=Cancelados                                                                     
	IF cConsidCancel == 2
		cQuery += " AND BI3_SITANS != '3'" 
	EndIF
	IF cConsidSusp == 2
		cQuery += " AND BI3_SITANS != '2'" 
	EndIF
	//Filtro de data 
	cQuery += " AND BHW_ANOMES >= '" + cAnoIni + cMesIni + "'" 
	cQuery += " AND BHW_ANOMES <= '" + cAnoFim + cMesFim + "'"
	If !Empty(cMesAnoIReaj) .And. !Empty(cMesAnoFReaj)
		cQuery += " AND BYC_DATREA >= '" + Substr(cMesAnoIReaj,3,4)+Substr(cMesAnoIReaj,1,2) + "01'" // Formato AAAAMM01
		cQuery += " AND BYC_DATREA <= '" + Substr(cMesAnoFReaj,3,4)+Substr(cMesAnoFReaj,1,2) + "31'" // Formato AAAAMM31
	EndIf
	If ! Empty(cProdNaoUt)
		cQuery += " AND BYC_CODPRO NOT IN (" + AllTrim(cProdNaoUt) + ")"
	Endif
	cQuery += " AND "+RetSQLName("BYC")+".D_E_L_E_T_ <> '*' " 
	cQuery += " AND "+RetSQLName("BHW")+".D_E_L_E_T_ <> '*' "
	cQuery += " AND "+RetSQLName("BI3")+".D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY BYC_OPEREA,BYC_CODREA, BYC_CODEMP, BYC_CONEMP, BYC_VERCON, BYC_SUBCON, BYC_VERSUB, BYC_CODPRO, BYC_VERPRO, BI3_SUSEP, "
	cQuery += " SUBSTRING(BHW_ANOMES,1,4), SUBSTRING(BHW_ANOMES,5,2) "
	
	PLSQuery(cQuery,"TMP")
		
Return Nil

Function ValidaRpc()
Local lRet
Local nTotUsu 
Local nRecBPF := 0
Local cKeyBPF := ""

	lRet := .T.  
	nTotUsu := 0
	lCopart := .F.

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Produto...						                         	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! BI3->(DBSeek(xFilial("BI3")+TMP->(BPF_OPEREA+BPF_CODPRO+BPF_VERPRO)))
       aadd(aCritRPC,{"BI3 -> Produto nao encontrado para a chave","["+xFilial("BI3")+TMP->(BPF_OPEREA+BPF_CODPRO+BPF_VERPRO)+"]"})
	   lRet := .F.
	Else
		If MV_PAR20=2 // Considera somente arquivo para o RPC. 
	       IF BI3->(FieldPos("BI3_CONRPC")) > 0
			   If BI3->BI3_CONRPC == "N"
			   	  lRet := .F.
			   Endif
		   Endif
		Endif
	Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Sub-Contrato...					                         	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If ! BQC->(DBSeek(xFilial("BQC")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)))
   	   aadd(aCritRPC,{"BQC -> Subcontrato nao encontrado para a chave","["+xFilial("BQC")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)+"]"})
	   lRet := .F.
	Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Sub-Contrato x Produto...						                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If ! BT6->(DbSeek(xFilial("BT6")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)+BI3->(BI3_CODIGO+BI3_VERSAO)))
	   aadd(aCritRPC,{"BT6 -> Subcontrato x produto nao encontrado para a chave","["+xFilial("BT6")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)+BI3->(BI3_CODIGO+BI3_VERSAO)+"]"})
	   lRet := .F.
    Endif
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Reajuste x Sub-Contrato...					                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If ! BPF->(DbSeek(xFilial("BPF")+TMP->(BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)))
       aadd(aCritRPC,{"BPF -> Subcontrato x Reajuste nao encontrado para a chave","["+xFilial("BPF")+TMP->(BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB) + " Data de Inclusao: " + dtos(BQC->BQC_DATCON) + " Data de Bloqueio: " + dtos(BQC->BQC_DATBLO) +"]"})
	   lRet := .F.
	Else
        nRecBPF := BPF->(Recno()) 
        cKeyBPF := BPF->(BPF_FILIAL+BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)
        While BPF->(BPF_FILIAL+BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB) == cKeyBPF .And. !BPF->(Eof())
            If !Empty(BPF->BPF_CODAJS) 
                nRecBPF := BPF->(Recno())     
            EndIf
            BPF->(DbSkip())    
        EndDo 
        BPF->(DbGoTo(nRecBPF))
    Endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se tem usuario para o produto ...				                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTotUsu := RpcNroUsu()                
	if nTotUsu == 0
		lRet := .F.    
        aadd(aCritRPC,{"BPF -> Nao existem usuarios para o produto","["+TMP->(BPF_OPEREA+BPF_CODREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB)+" - "+TMP->BPF_CODPRO+"]"})		
	Endif

	If lRet
		nTotRC2++

		RPCC3Valida()    
		lRet := RPCC4Valida()
	Endif	
	
Return lRet

Function RpcNroUsu()
Local cQry, nConta

	cQry := " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG,BA1_CODPLA "
	cQry += " FROM " + cBA1name + ", " + cBA3name
	cQry += " WHERE BA1_FILIAL = '" + xFilial("BA1")  + "' AND "
	cQry +=       " BA3_FILIAL = '" + xFilial("BA3")  + "' AND "
	cQry +=       " BA1_CODINT = '" + TMP->BPF_OPEREA + "' AND "
	cQry +=       " BA1_CODEMP = '" + TMP->BPF_CODEMP + "' AND "
	cQry +=       " BA1_CONEMP = '" + TMP->BPF_CONEMP + "' AND "
	cQry +=       " BA1_SUBCON = '" + TMP->BPF_SUBCON + "' AND "
	cQry +=		  " BA1_DATINC <= '" + dtos(LastDate(StoD(AllTrim(TMP->BPF_ANOREA)+AllTrim(TMP->BPF_MESREA)+"01"))) + "' AND " // Menor ou igual ao ultimo dia do mЙs reajustado
	cQry +=       " (BA1_CODPLA = '" + TMP->BPF_CODPRO + "' OR  BA3_CODPLA = '"  + TMP->BPF_CODPRO + "') AND "
	cQry +=       " BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC AND "
	cQry += cBA1name + ".D_E_L_E_T_ <> '*' AND " + cBA3name + ".D_E_L_E_T_ <> '*' "

	PLSQuery(cQry,"QRY")
	
    nConta := 0
       
	QRY->(DbGoTop())
	
	BA3->(DbSetOrder(1))//BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
	BA1->(DbSetOrder(2))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BI3->(DbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
	While ! QRY->(EOF())
		If Empty(QRY->BA1_CODPLA) .OR. QRY->BA1_CODPLA = TMP->BPF_CODPRO   
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica o SUSEP                                                         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Empty(QRY->BA1_CODPLA) 
				BA3->(DbSeek(xFilial("BA3")+TMP->BPF_OPEREA+TMP->BPF_CODEMP+QRY->BA1_MATRIC))
				BI3->(DbSeek(xFilial("BI3")+TMP->BPF_OPEREA+BA3->(BA3_CODPLA+BA3_VERSAO)))
	        Else
    	   	    BA1->(DbSeek(xFilial("BA3")+TMP->BPF_OPEREA+TMP->BPF_CODEMP+QRY->BA1_MATRIC+QRY->BA1_TIPREG))
       		    BI3->(DbSeek(xFilial("BI3")+TMP->BPF_OPEREA+BA1->(BA1_CODPLA+BA1_VERSAO)))
	        EndIf
        
			If BI3->BI3_SUSEP == TMP->BI3_SUSEP  
				If !VeBloqUsu(QRY->BA1_CODINT, QRY->BA1_CODEMP, QRY->BA1_MATRIC, QRY->BA1_TIPREG, StoD(AllTrim(TMP->BPF_ANOREA)+AllTrim(TMP->BPF_MESREA)+"01"))
					nConta++
				Else
			   		aadd(aCritRPC,{"Verificacao de usuario valido -> Chave","["+QRY->BA1_CODINT + QRY->BA1_CODEMP + QRY->BA1_MATRIC + QRY->BA1_TIPREG+"]"})
				EndIf	
			Endif
	    EndIf    
		QRY->(DbSkip())
	Enddo

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha arquivo temporario...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	QRY->(dbCloseArea())
	
Return nConta


Function VeBloqUsu(cCodInt, cCodEmp, cMatric, cCodDep, dDatFim)

Local cDatBlo  := "00000000"
Local cEstIni  := "D" // Sempre inicia como desbloqueado
Local cEstFin  := ""
Local cQryBlq  := ""
Local cRetorno := ""
Local cNameBCA := RetSQLName("BCA")
Local lRet     
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se no fim do periodo o beneficiario estava bloqueado         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQryBlq  := " SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ FROM " + cNameBCA
	cQryBlq  += " WHERE BCA_FILIAL = '" + xFilial("BCA") + "' AND BCA_MATRIC = '" + cCodInt + cCodEmp + cMatric + "' AND"
	cQryBlq  += " BCA_TIPREG = '" + cCodDep + "' AND"
	cQryBlq  += " BCA_DATA < '" + dtos(dDatFim) + "' AND "	  
	cQryBlq  += cNameBCA + ".D_E_L_E_T_ <> '*' "
	cQryBlq  += " ORDER BY BCA_DATA, R_E_C_N_O_"
	PLSQuery(cQryBlq,"BCAQRY")

	While ! BCAQRY->(eof()) 

		cRetorno := ""
		lGrvBlq  := .F.
	 	cRetorno := VerifAns(BCAQRY->BCA_NIVBLQ,BCAQRY->BCA_MOTBLO)
	    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Caso a data do (des)bloqueio seja maior que a data final, ignoro.     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If dtos(BCAQRY->BCA_DATA) >= dtos(dDatFim)
		 	BCAQRY->(dbSkip())
		 	Loop
		Endif

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alimenta controle para tratar bloqueio/desbloqueio no mesmo mes...    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If substr(cRetorno,1,1)=="S"
			If BCAQRY->BCA_TIPO == "0"
				cEstFin := "B" // Bloqueio
				cDatBlo := dtos(BCAQRY->BCA_DATA)
				lGrvBlq := .T.
			Else
				cEstFin := "D" // Desbloqueio	
			Endif
		Endif
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se for Desbloqueio ou Bloqueio nao relacionado a ANS, desconsidera... Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ! lGrvBlq
			cDatBlo := "00000000"
		Endif     
		
	 	BCAQRY->(dbSkip())
	Enddo
      
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trata bloqueio/desbloqueio no mesmo mes								  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cEstIni == cEstFin    
		cDatBlo := "00000000"
	Endif

	BCAQRY->(DbCloseArea())

	If cDatBlo == "00000000"
		lRet := .F.
	Else
		lRet := .T.
	Endif

Return lRet


Function RPCC1Valida()
Local lRet

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona Operadora...							                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ! BA0->(DBSeek(xFilial("BA0")+cCodOpe))	
		lRet := .F.
	Else
		lRet := .T.
	Endif          
	
Return lRet	

Function RPCC3Valida()

Local aStru   := {}
Local cMotRea := ""
Local cNomArq := ""

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo temporario...				                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aStru,{"SEQ" ,"C",003,0})
	aadd(aStru,{"REG" ,"C",100,0})
	
	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempRC3 := FWTemporaryTable():New( "RC3" )
	oTempRC3:SetFields( aStru )
	oTempRC3:AddIndex( "INDRC3",{ "SEQ" } )
	
	if( select( "RC3" ) > 0 )
		RC3->( dbCloseArea() )
	endIf
	
	oTempRC3:Create()
	
	dbSelectArea( "RC3" )
	RC3->( dbSetorder( 1 ) )
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta motivo do reajuste...			                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMotRea := BQC->BQC_MOTREA
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava arquivo temporario...						                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	RC3->(Reclock("RC3",.T.))
	RC3->SEQ := "001"
	RC3->REG := substr(cMotRea,1,100)
	RC3->(MsUnlock())               
	
	nTotRC3++
	
	If alltrim(substr(cMotRea,101,100)) <> ""
		RC3->(Reclock("RC3",.T.))
		RC3->SEQ := "002"
		RC3->REG := substr(cMotRea,101,100)
		RC3->(MsUnlock())               
		nTotRC3++
	Endif
	
	If alltrim(substr(cMotRea,201,55)) <> ""
		RC3->(Reclock("RC3",.T.))
		RC3->SEQ := "003"
		RC3->REG := substr(cMotRea,201,55)
		RC3->(MsUnlock())               
		nTotRC3++
	Endif              
	
	RC3->(DbGoTop())
	
Return

Function RPCC4Valida()

	Local aStru  := {}
	Local nX     := 0
	Local cSql   := ""
	Local cValorAntes  := 0
	Local cPercAntes   := 0
	Local cValorDepois := 0
	Local cPercDepois  := 0
	Local cObs         := Padr(GetNewPar("MV_PLRPCC4",""),150)
	Local lRet         := .T.

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo temporario...				                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aStru,{"ITE_COD","C",003,0})
	aadd(aStru,{"VLR_ANT","C",015,0})
	aadd(aStru,{"VLR_APO","C",015,0})
	aadd(aStru,{"PER_ANT","C",006,0})
	aadd(aStru,{"PER_APO","C",006,0})
	aadd(aStru,{"OBSERV" ,"C",150,0})

	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempRC4 := FWTemporaryTable():New( "RC4" )
	oTempRC4:SetFields( aStru )
	oTempRC4:AddIndex( "INDRC4",{ "ITE_COD" } )
	
	if( select( "RC4" ) > 0 )
		RC4->( dbCloseArea() )
	endIf
	
	oTempRC4:Create()
	
	dbSelectArea( "RC4" )
	RC4->( dbSetorder( 1 ) )
	
	if lExiCLARPC .And. BI3->BI3_CPFM == "1"

		cSql := " SELECT BHF_VALCOP, BHF_PERCOP, BHF_CODGRU, BHF_VIGINI, BG7_CLARPC FROM " + RetSQLName("BHF") + " BHF "
		
		cSql += " INNER JOIN "+RetSQLName("BG7")+" BG7 "
		cSql += "	ON BG7_FILIAL = '"+xFilial("BG7")+"' "
		cSql += "	AND BG7_CODINT = BHF_CODINT "
		cSql += "	AND BG7_CODGRU = BHF_CODGRU "
		cSql += "	AND BG7.D_E_L_E_T_ = ' ' "

		cSql += " WHERE BHF_FILIAL = '"+xFilial("BHF")+"' "
		cSql += "   AND BHF_CODINT = '"+Substr(BQC->BQC_CODIGO,1,4)+"' "
		cSql += "   AND BHF_CODIGO = '"+Substr(BQC->BQC_CODIGO,5,4)+"' "
		cSql += "   AND BHF_NUMCON = '"+BQC->BQC_NUMCON+"' "
		cSql += "   AND BHF_VERCON = '"+BQC->BQC_VERCON+"' "
		cSql += "   AND BHF_SUBCON = '"+BQC->BQC_SUBCON+"' "
		cSql += "   AND BHF_VERSUB = '"+BQC->BQC_VERSUB+"' "
		cSql += "   AND BHF_CODPRO = '"+BI3->BI3_CODIGO+"' "
		cSql += "   AND BHF_VERPRO = '"+BI3->BI3_VERSAO+"' "
		cSql += "   AND BHF_VIGINI BETWEEN '"+Substr(cMesAnoIReaj,3,4)+Substr(cMesAnoIReaj,1,2)+"01"+"' AND '"+Substr(cMesAnoFReaj,3,4)+Substr(cMesAnoFReaj,1,2)+"31"+"' "
		cSql += "   AND BHF.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBBHF",.T.,.F.)

		//Roda todas os grupos que tiveram vigencia inicial no periodo dos parametros
		while !TRBBHF->(eof())
			
			cValorDepois  := TRBBHF->BHF_VALCOP
			cPercDepois   := TRBBHF->BHF_PERCOP
			cValorAntes   := 0
			cPercAntes    := 0

			// Verifica se tem vigencia com data de encerramento anterior a vigencia inicial
			cSql := " SELECT BHF_VALCOP, BHF_PERCOP FROM " + RetSQLName("BHF")
			cSql += " WHERE BHF_FILIAL = '"+xFilial("BHF")+"' "
			cSql += " AND BHF_CODINT = '"+Substr(BQC->BQC_CODIGO,1,4)+"' "
			cSql += " AND BHF_CODIGO = '"+Substr(BQC->BQC_CODIGO,5,4)+"' "
			cSql += " AND BHF_NUMCON = '"+BQC->BQC_NUMCON+"' "
			cSql += " AND BHF_VERCON = '"+BQC->BQC_VERCON+"' "
			cSql += " AND BHF_SUBCON = '"+BQC->BQC_SUBCON+"' "
			cSql += " AND BHF_VERSUB = '"+BQC->BQC_VERSUB+"' "
			cSql += " AND BHF_CODPRO = '"+BI3->BI3_CODIGO+"' "
			cSql += " AND BHF_VERPRO = '"+BI3->BI3_VERSAO+"' "
			cSql += " AND BHF_CODGRU = '"+TRBBHF->BHF_CODGRU+"' "
			cSql += " AND BHF_VIGFIN < '"+TRBBHF->BHF_VIGINI+"' " 
			cSql += " AND D_E_L_E_T_ = ' ' "
			cSQL += " ORDER BY BHF_VIGFIN DESC "
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBBHFAUX",.T.,.F.)

			if !TRBBHFAUX->(eof())
				cValorAntes := TRBBHFAUX->BHF_VALCOP
				cPercAntes  := TRBBHFAUX->BHF_PERCOP
			endIf
			TRBBHFAUX->(DbCloseArea())

			if  (!Empty(cValorAntes) .And. !Empty(cValorDepois)) .Or. ;
				(!Empty(cPercAntes) .And. !Empty(cPercDepois)) .And. !Empty(TRBBHF->BG7_CLARPC)

				if lPERPC01
					GeraRC4(TRBBHF->BG7_CLARPC,cValorAntes,cValorDepois,cPercAntes,cPercDepois,cObs)
					lCopart := .T.
				//Se achou valor de copart, preciso do PE para calcular o valor do campo A2/19
				else
					aadd(aCritRPC,{"Para gerar os registros C2/19 e C4 И necessАrio aplicar o Ponto de PLSRPC01:","["+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) + " " + BI3->(BI3_CODIGO+BI3_VERSAO)+TRBBHF->BHF_CODGRU+ "]"})
					lRet := .F.
				endIf

			endIf
			TRBBHF->(DbSkip())

		endDo
		TRBBHF->(DbCloseArea())
	endIf

	//Se vazio, gero uma linha vazia
	if !lCopart .And. lRet
		GeraRC4()
	endIf

	RC4->(DbGoTop())

Return lRet


Static Function GeraRC4(cCodGru,cValorAntes,cValorDepois,cPercAntes,cPercDepois,cObs)

	Default cCodGru      := '001'
	Default cValorAntes  := 0
	Default cValorDepois := 0
	Default cPercAntes   := 0
	Default cPercDepois  := 0
	Default cObs         := SPACE(150)

	if lPERPC02
		cObs := Padr(ExecBlock("PLSRPC02",.F.,.F.,{ BI3->(Recno()), BQC->(Recno()), BT6->(Recno()), BPF->(Recno())} ), 150)
	endIf

	RC4->(Reclock("RC4",.T.))
	RC4->ITE_COD := Strzero(Val(cCodGru),3)
	RC4->VLR_ANT := STRZERO((cValorAntes*100),15)
	RC4->VLR_APO := STRZERO((cValorDepois*100),15)
	RC4->PER_ANT := STRZERO((cPercAntes*100),6)
	RC4->PER_APO := STRZERO((cPercDepois*100),6)
	RC4->OBSERV  := cObs

	RC4->(MsUnlock())               
	nTotRC4++

Return


Function PLSRPCPLA()
Local cRet := ""

	Do Case
		Case BI3->BI3_APOSRG == "1"
			cRet := REPLICATE("9",9) + SPACE(11)
		Case BT6->(FieldPos("BT6_CODSIM")) > 0 .and. Alltrim(BT6->BT6_CODSIM) <> ""
			cRet := BT6->BT6_CODSIM
		Case Alltrim(BI3->BI3_SUSEP) <> ""
			cRet := BI3->BI3_SUSEP + SPACE(08)
		Otherwise
			cRet := BI3->BI3_CODIGO + SPACE(16)
	EndCase

Return cRet

//-----------------------------------------------------------------------
Static Function VerifAns(cNivel,cMotBlo)
Local cRet

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se um bloqueio em determinado Nivel com certo Motivo       Ё
	//Ё Interessa para a ANS												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	cRet := "N"
	
	// Verifica Nivel do Desbloqueio
	Do case 
		Case cNivel == 'U' // Nivel de Usuario
	    	If BG3->(dbSeek(xFilial("BG3")+cMotBlo))
	    		If ! Empty(BG3->BG3_BLQANS)
					cRet := "S" + BG3->BG3_BLQANS
				Endif	
	    	Endif
		Case cNivel == 'F' // Nivel de Familia
	    	If BG1->(dbSeek(xFilial("BG1")+cMotBlo))
	    		If ! Empty(BG1->BG1_BLQANS)
					cRet := "S" + BG1->BG1_BLQANS
				Endif	
	    	Endif
		case cNivel == 'S' // Nivel de Sub-Contrato
	    	If BQU->(dbSeek(xFilial("BQU")+cMotBlo))
	    		If ! Empty(BQU->BQU_BLQANS)
					cRet := "S" + BQU->BQU_BLQANS
				Endif	
	    	Endif
	EndCase
	
Return(cRet)

/*/{Protheus.doc} BuscaMajorita()
FunГЦo utilizada para preencher o campo de marjoraГЦo.

@author Totver

@type function
@since 2020/04
@version 1.0
/*/

Function BuscaMajorita()

Local cRet 		:= "E"
Local aAreaBA1	:= BA1->(GetArea())
Local aAreaBQC	:= BQC->(GetArea())
Local lEstDif	:= .F.
Local cEstBA1	:= ''

BA1->(DbSetOrder(1))

If(BA1->(DbSeek(xFilial("BA1")+BQC->(BQC_CODINT+BQC_CODEMP))))

	While BA1->(!Eof()) .and. BA1->(BA1_CODINT+BA1_CODEMP) == BQC->(BQC_CODINT+BQC_CODEMP)

		If BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) == BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
			
			cEstBA1 := BA1->BA1_ESTADO

			While BA1->(!Eof()) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) == BQC->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
				If cEstBA1 <> BA1->BA1_ESTADO
					cRet := "M"
					lEstDif:= .T.
					Exit 
				Endif
			
				BA1->(DbSkip())
			EndDo

		Endif
		If lEstDif
			Exit
		Endif
		BA1->(DbSkip())

	EndDo

Endif


RestArea(aAreaBA1)
RestArea(aAreaBQC)

Return cRet


/*/{Protheus.doc} BuscaMajorita()
FunГЦo utilizada para buscar o percentual de reajuste

@author Totver

@type function
@since 2020/04
@version 1.0
/*/

Function BuscaPerRea()

	Local cRet := Replicate("0",6)
	Local aAreaBYC	:= BYC->(GetArea())
	
	dbSelectArea("BGJ")
	dbSelectArea("BH3")
	dbSelectArea("BYA")

	BYC->(DbSetOrder(1))
	BGJ->( DbSetOrder(1)) //BGJ_FILIAL + BGJ_CODINT + BGJ_CODIGO + BGJ_ANO + BGJ_MES
	BH3->( DbSetOrder(1) ) //BH3_FILIAL + BH3_CODINT + BH3_CODIGO + BH3_NUMCON + BH3_VERSAO + BH3_ANO + BH3_MES
	BYA->( DbSetOrder(1)) //BYA_FILIAL + BYA_CODINT + BYA_CODIGO + BYA_NUMCON+ BYA_VERSAO + BYA_SUBCON + BYA_VERSUB + BYA_ANO + BYA_MES
	If __lGetPerRPC
		Do Case
			Case BYA->(DbSeek(xFilial("BYA")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB+BPF_ANOREA+BPF_MESREA))) .And. BYA->BYA_PERRPC > 0
				cRet := STRZERO((BYA->BYA_PERRPC*100),6)
			Case BH3->(DbSeek(xFilial("BH3")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_ANOREA+BPF_MESREA))) .And. BH3->BH3_PERRPC > 0
				cRet := STRZERO((BH3->BH3_PERRPC*100),6)
			Case BGJ->(DbSeek(xFilial("BGJ")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_ANOREA+BPF_MESREA))) .And. BGJ->BGJ_PERRPC > 0
				cRet := STRZERO((BGJ->BGJ_PERRPC*100),6)
		EndCase
	EndIf


	if lCopart .And. lPERPC01
		cRet := ExecBlock("PLSRPC01",.F.,.F.,{ BI3->(Recno()), BQC->(Recno()), BT6->(Recno()), BPF->(Recno()), cRet} )
		if Empty(cRet)
			cRet := Replicate("0",6)
		endIf
	endIf

	// ----- Regra antiga --------
	//(BYC->(DbSeek(xFilial("BYC")+TMP->(BPF_OPEREA+BPF_CODEMP+BPF_CONEMP+BPF_VERCON+BPF_SUBCON+BPF_VERSUB+BPF_CODPRO+BPF_VERPRO+BPF_OPEREA+BPF_CODREA))))
	//cRet := STRZERO((BYC->BYC_PERREA*100),6)		

	RestArea(aAreaBYC)

Return cRet
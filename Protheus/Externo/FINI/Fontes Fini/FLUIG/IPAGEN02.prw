#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN02

Rotina responsável pela apontamento da pré-requisição

@type 	 function
@author  Ectore Cecato - Totvs IP Jundiaí
@since 	 05/10/2018
@version Protheus 12 - Genérico

/*/

User function IPAGEN02(cDoc)
	
	Local lRet 			:= .F.
	Local message 		:= "ok"
	Local cFilterSCP 	:= "CP_NUM = '"+ cDoc +"' "
	
	conout("Numero do documento para gerar a pré requisição:"+cDoc)
	
	
	DbSelectArea("SCP")
	
	SCP->(DbSetOrder(1))
	
	If SCP->(DbSeek(FWxFilial("SCP") + cDoc)) 
		conout("Encontrou  o documento para gerar a pré requisição:"+cDoc)
		//Gera pré-requisição
		Pergunte("MTA106", .F.)
				
		Param01 := .F.  			//Obrigatorio para chamada fora do MATA106/MATA185
		Param02 := MV_PAR01 == 1
		Param03 := If(Empty(cFilterSCP), {|| .T.}, {|| &cFilterSCP})
		Param04 := .F.	 			//Nunca considerar a previsao de entrada pois a separacao do item acontecera imediatamente //MV_PAR02==1
		Param05 := .F.   			//MV_PAR03 == 1
		Param06 := MV_PAR04 == 1
		Param07 := MV_PAR05
		Param08 := MV_PAR06
		Param09 := MV_PAR07 == 1
		Param10 := MV_PAR08 == 1
		Param11 := MV_PAR09
		Param12 := .T.
		
		conout("Iniciando a  pré requisição:"+cDoc)	
		lRet := U_XMaSAPreReq(Param01, Param02, Param03, Param04, Param05, Param06, Param07, Param08, Param09, Param10, Param11, Param12)
		conout("Finalizando  a  pré requisição:"+cDoc)				
		If !lRet
			conout("Não foi possivel gerar a  pré requisição:"+cDoc)
			message := "Não foi possível gerar a pré-requisição, favor gerá-la manualmente"
		else 
			conout("pré requisição:"+cDoc+" gerada com sucesso")
		EndIf
		
	Else
		conout(" requisição:"+cDoc+" não encontrada")
		message := "Requisicao "+ cDoc +" não encontrada"
	EndIf
	
Return message


user Function XMaSAPreReq(lMarkB,lDtNec,BFiltro,lConsSPed,lGeraDoc,lAmzSA,cSldAmzIni,cSldAmzFim,lLtEco,lConsEmp,nAglutDoc,lAuto,lEstSeg,aRecSCP,lRateio)

Local aArea     := GetArea()
Local aLotes    := {}
Local aSCs      := {}
Local aHeadSC1  := {}
Local aColsSC1  := {}
Local aHeadSCX  := {}
Local aColsSCX  := {}
Local aCampos	:= {}
Local aLinha	:= {}
Local aDocs		:= {}
Local aDocsCp	:= {}
Local aRateio	:= {}
Local aCTBEnt   := CTBEntArr()
Local aMT106SCQ := {}
local aCPAgl	:= {}
Local aResultado:= {}
Local aFornecedor:= {}
Local aPosDhn		:= {}

Local cEntidades:= ""
Local cNumSC    := ""
Local cNumSA    := ''
Local cItemSC   := ""
Local cCursor   := "SCP"
Local cQuery    := ""
Local cSeq      := "01"	
Local cMsgSC    := ""
Local cSeekSCP  := ""
Local cSeekSCQ  := ""
Local cMsg		:= ""
Local cChaveRat	:= ""
Local cUndRequi	:= SuperGetMv("MV_CCUNREQ")

Local nPrc		:= 0
Local nX        := 0
Local nQtde     := 0
Local nQtdPre   := 0
Local nEstoque  := 0
Local nLoteSC   := 0
Local nSaveSX8  := GetSX8Len()
Local nEstSeg	:= 0 
Local nRegSemSC := 0
Local nSaldo	:= 0
Local nLoop		:= 0

Local lIncluiReg:= .T.
Local lQuery    := .F.
Local lContinua	:= .T.
Local lVLCP 	:= .T.
Local lPrjCni   := ValidaCNI()
Local lErrAutSC	:= .F.
Local lVldPE	:= .T.
Local lMT106SCA := ExistBlock("MT106SCA")
Local lMASAVLSC := ExistBlock("MASAVLSC")
Local lEstNeg 	:= SuperGetMv("MV_ESTNEG",.F.,"N") == "S"
Local nSumLE    := 0

Local uLoteSC   := Nil

Local lMT106GRV := ExistBlock("MT106GRV")
Local lMT106VGR := ExistBlock("MT106VGR")
Local lMA106SCQ := ExistBlock("MA106SCQ")
Local lMASAVLOP := ExistBlock("MASAVLOP")

Private lxCont  := .F.                 // FSW - Controle de numeracao SC

DEFAULT lMarkb  := .F.
DEFAULT lDtNec  := .F.
DEFAULT bFiltro := {|| .T.}
DEFAULT lLtEco  := .T.
DEFAULT lConsEmp:= .F.
DEFAULT nAglutDoc:=  2      
DEFAULT lAuto	:= .F.
DEFAULT lEstSeg	:= .F.
DEFAULT aRecSCP	:= {}
DEFAULT lRateio	:= .F.
DEFAULT lGeraDoc:= .T.

lConsSPed:=If(Valtype(lConsSPed) # "L",.F.,lConsSPed)

If lGeraDoc
	PcoIniLan("000051")
EndIf

dbSelectArea("SCP")
If lDtNec
	dbSetOrder(3)
Else
	dbSetOrder(4)
EndIf

//preparacaoo para quebra por CP_DESCRI
SCP->(dbCommit())
cCursor := GetNextAlias()
lQuery  := .T.
cQuery  := "SELECT CP_FILIAL,R_E_C_N_O_ SCPRECNO "
cQuery  += "FROM "+RetSqlName("SCP")+" SCP "
cQuery  += "WHERE "
cQuery  += "CP_PREREQU<>'S' AND "
cQuery  += "D_E_L_E_T_=' ' "
If ( lMarkb )
	If ( ThisInv() )
		cQuery += "AND CP_OK<>'"+ThisMark()+"' "
	Else
		cQuery += "AND CP_OK='"+ThisMark()+"' "
	EndIf
EndIf

If ExistBlock("MT106QRY")
   c106Qry := ExecBlock("MT106QRY",.F.,.F.,{lAuto})
   If ValType(c106Qry) == "C"
	   cQuery += c106Qry
   EndIf	   
EndIf

cQuery += "ORDER BY "+SqlOrder(SCP->(IndexKey()))
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cCursor, .F., .T. ) 		
	
While  !Eof() 
	If ( lQuery )
		dbSelectArea(cCursor)
		SCP->(MsGoto((cCursor)->SCPRECNO))
	EndIf
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1",(cCursor)->CP_FILIAL)+SCP->CP_PRODUTO))
	
	dbSelectArea("SCP")
	
	//Calcula a Necessidade de uma Solicitacao de Compra/Autorizacao de Entrega 
	
	If	SCP->CP_PREREQU<>"S"              
		If !lQuery
			If ThisInv()
				If SCP->CP_OK == ThisMark()
					dbSelectArea("SCP")
					dbSkip()
					Loop
				EndIf
			Else
				If AllTrim(SCP->CP_OK) <> ThisMark()
					dbSelectArea("SCP")
					dbSkip()
					Loop
				EndIf
			EndIf		
		EndIf
		If lMarkb
			 IsMark("CP_OK",ThisMark(),ThisInv())
		EndIf
		If SB1->B1_MSBLQL == "1" // Verifica tambem se o produto nao esta bloqueado
			If !lAuto
				//Aviso("B1_MSBLQL",OemtoAnsi(STR0091)+Alltrim(SB1->B1_COD)+OemtoAnsi(STR0092),{STR0118}) // "Ok"
			EndIf
		Else
			If ( Eval(bFiltro) )
				lIncluiReg	:=.T.
				cMsg		:= ""
				Begin Transaction
					dbSelectArea("SB2")
					dbSetOrder(1)
					If lAmzSA
						cSeekSCP := xFilial("SB2")+SCP->CP_PRODUTO+SCP->CP_LOCAL
					Else
						cSeekSCP := xFilial("SB2")+SCP->CP_PRODUTO
					EndIf
					nSaldo := 0
					If MsSeek(cSeekSCP)
						RecLock("SB2")
						If lAmzSA
				   			nSaldo  := SaldoSB2(.F.,lConsEmp)+If(lConsSPed,AvalSalPed(SCP->CP_PRODUTO,SCP->CP_LOCAL),0)
						Else
							While !Eof() .And. cSeekSCP == SB2->B2_FILIAL+SB2->B2_COD
								If SB2->B2_LOCAL < cSldAmzIni .Or. SB2->B2_LOCAL > cSldAmzFim
									SB2->(dbSkip())
									Loop
								EndIf
								nSaldo += SaldoSB2(.F.,lConsEmp)+If(lConsSPed,AvalSalPed(SB2->B2_COD,SB2->B2_LOCAL),0)
								SB2->(dbSkip())
							EndDo
						EndIf
					EndIf
					If lMT106GRV
						ExecBlock("MT106GRV",.F.,.F.)
					EndIf
                   	
					//Calcula se possui estoque de seguranca
					       
					If lEstSeg
				   		nEstSeg   := CalcEstSeg( RetFldProd(SB1->B1_COD,"B1_ESTFOR","SB1") )
	                    If nEstSeg > 0
	                    	nSaldo:= nSaldo - nEstSeg 
	                    EndIf 
					EndIf
					
					//Ponto de entrada que permite validar se deve ou nao ser  
					//gerada a pre-requisicao de solicitacao ao armazem.       				
					
					If lMT106VGR 
						If (Valtype(lContinua := ExecBlock("MT106VGR",.F.,.F.,{lAmzSA,nSaldo,lConsEmp,lConsSPed}))=='L') .And. !lContinua
						    //Quando executado o break o mesmo pulara para o final da funcao
						    //executando la o DbSkip() sem a necessesidade de se colocar um dbSkip loop aqui.
							DisarmTransaction()
						    break
						EndIf				
					EndIf						
					nQtde	:= SCP->CP_QUANT
					nEstoque:= 0
					cSeq    := "01"
					nQtdPre := nQtde
					uLoteSC := Nil
					While nQtde > 0
						nSaldo  := Max(0,nSaldo)
						nEstoque:= Min(nSaldo,nQtde)
						
						//Verifica se pode gerar pre-requisicao com saldo negativo
						
						If lEstNeg .And. !lGeraDoc .And. !(Rastro(SCP->CP_PRODUTO) .Or. Localiza(SCP->CP_PRODUTO))
							nEstoque := nQtde
						EndIf
	
						
						/// Grava Pre-Requisicao         
						
						nRegSemSC:=0
						dbSelectArea("SCQ")
						dbSetOrder(1)
						cSeekSCQ:=xFilial("SCQ",(cCursor)->CP_FILIAL)+SCP->CP_NUM+SCP->CP_ITEM
						dbSeek(cSeekSCQ)
						While !Eof() .And. cSeekSCQ == CQ_FILIAL+CQ_NUM+CQ_ITEM
							aPosDhn := COMPosDHN({2,{SCQ->CQ_FILIAL,SCQ->CQ_NUM,SCQ->CQ_ITEM}})
							If !aPosDhn[1] .Or. !((aPosDhn[2])->DHN_TIPO $ "1|2")
								nRegSemSC := SCQ->(Recno())
								nQtdPre   -= SCQ->CQ_QTDISP
								nQtde     -= SCQ->CQ_QTDISP
								If aPosDhn[1]
									(aPosDhn[2])->(DbCloseArea())
								EndIf
								Exit
							EndIf						
							SCQ->(dbSkip())
						End
				
						If !lGeraDoc .And. nRegSemSC > 0
							msGoto(nRegSemSC)
							RecLock("SCQ",.F.)
							SCQ->CQ_QTDISP := SCQ->CQ_QTDISP+nEstoque
							MsUnlock()
							lIncluiReg:=.F.
							MaAvalRA("SCQ",3,nEstoque)
						Else
							RecLock("SCQ",.T.)					
							SCQ->CQ_FILIAL	:= xFilial("SCQ",(cCursor)->CP_FILIAL)
							SCQ->CQ_NUM		:= SCP->CP_NUM
							SCQ->CQ_ITEM	:= SCP->CP_ITEM
							SCQ->CQ_PRODUTO	:= SCP->CP_PRODUTO
							SCQ->CQ_LOCAL	:= SCP->CP_LOCAL
							SCQ->CQ_UM		:= SCP->CP_UM
							SCQ->CQ_QUANT	:= nQtdPre
							SCQ->CQ_QTSEGUM	:= SCP->CP_QTSEGUM
							SCQ->CQ_SEGUM	:= SCP->CP_SEGUM
							SCQ->CQ_QTDISP	:= nEstoque
							SCQ->CQ_NUMSQ	:= cSeq
							SCQ->CQ_DATPRF	:= SCP->CP_DATPRF
							SCQ->CQ_DESCRI	:= SCP->CP_DESCRI
							SCQ->CQ_CC		:= SCP->CP_CC
							SCQ->CQ_CONTA	:= SCP->CP_CONTA
							SCQ->CQ_ITEMCTA	:= SCP->CP_ITEMCTA
							SCQ->CQ_CLVL	:= SCP->CP_CLVL
							SCQ->CQ_OP		:= SCP->CP_OP
							SCQ->CQ_OBS		:= SCP->CP_OBS	
							
							For nX := 1 To Len(aCTBEnt)
								SCQ->&("CQ_EC"+aCTBEnt[nX]+"CR") := SCP->&("CP_EC"+aCTBEnt[nX]+"CR")
								SCQ->&("CQ_EC"+aCTBEnt[nX]+"DB") := SCP->&("CP_EC"+aCTBEnt[nX]+"DB")
							Next nX
							
							//aMT106SCQ utilizada no P.E. MT106PRE
							aAdd(aMT106SCQ,{SCQ->CQ_FILIAL,SCQ->CQ_NUM,SCQ->CQ_ITEM,SCQ->CQ_NUMSQ,SCQ->CQ_PRODUTO,SCQ->CQ_LOCAL,SCQ->CQ_QUANT})
	
							
							//Ponto de Entrada MA106SCQ     |
							
							If lMA106SCQ
							   uLoteSC := ExecBlock("MA106SCQ",.F.,.F.)
							   If Valtype(uLoteSC) == "N" .And. uLoteSC > 0
							   		nLoteSC := uLoteSC
							   	EndIf	
							Endif
							MaAvalRA("SCQ",1)
						EndIf

						nLoteSC := IIf(uLoteSC <> Nil,nLoteSC,(SCQ->CQ_QUANT-SCQ->CQ_QTDISP))
						nLot2SC := ConvUm(SCP->CP_PRODUTO,nLoteSC,0,2)
						cMsgSC  := OemToAnsi("SC gerada por SA")+IIF(!Empty(SCP->CP_OBS)," - "+Left(SCP->CP_OBS,(Len(SC1->C1_OBS))-(Len("SC gerada por SA")+3)),"") //"SC gerada por SA"
	
						// Avalia empenho ja existente a fim de nao gerar SCS/AES caso ja tenha saldo empenhado
						If lConsEmp .And. AvalEmpSCP(SCP->CP_PRODUTO,SCP->CP_LOCAL,SCP->CP_OP,nQtdPre) 
							Reclock("SCP",.F.)
							SCP->CP_PREREQU := "S"
							MsUnlock()
							Exit
						// Qdo nao gera Documento
						ElseIf !lGeraDoc
							If QtdComp(nLoteSC) > QtdComp(0)
								cMsg := "Qdo nao gera Documento"+" "+SCP->CP_NUM+" / "+SCP->CP_ITEM
							EndIf
							Reclock("SCP",.F.)
							SCP->CP_PREREQU := "S"
							MsUnlock()
							Exit
						EndIf	
	
						
						//Ponto de Entrada - Geracaoo de Solicitacao de Compras					   
						
						If lMASAVLSC
							lVldPE := ExecBlock("MASAVLSC",.F.,.F.,{SB1->B1_COD,SB1->B1_LOCPAD,SB1->B1_CONTRAT}) 
							If Valtype(lVldPE) <> "L"
								lVldPE := .T.
							ElseIf !lVldPE  
								Reclock("SCP",.F.)
								SCP->CP_PREREQU := "S"
								MsUnlock() 
							EndIf
						EndIf

						If lGeraDoc .And. lVldPE
							//-- Calcula a quantidade conforme o Lote Economico, conforme parametro 8
							If lLtEco
								If ( nLoteSC > 0 )
									aLotes := CalcLote(SCQ->CQ_PRODUTO,nLoteSC,"C")
									nLoteSC:= 0
									For nX := 1 To Len(aLotes)
										nLoteSC += aLotes[nX]
									Next nX
								Else
									nLoteSC := 0
								EndIf
								nSumLE += nQtdPre
							EndIf
							
							aFornecedor:= COMPESQFOR(SCQ->CQ_PRODUTO) //-- Retorna codigo e loja do fornecedor
							nPrc:= COMPESQPRECO(SCQ->CQ_PRODUTO,(cCursor)->CP_FILIAL,aFornecedor[1],aFornecedor[2])
							aRateio:={}
							If SGS->(MsSeek(SCP->(CP_FILIAL+CP_NUM+CP_ITEM))) //Existe Rateio
								While !SGS->(EOF()) .AND. SGS->(GS_FILIAL+GS_SOLICIT+GS_ITEMSOL) == SCP->(CP_FILIAL+CP_NUM+CP_ITEM)
									cEntidades:= SGS->GS_CC 		+ "|" 
									cEntidades+= SGS->GS_CONTA		+ "|"
									cEntidades+= SGS->GS_ITEMCTA 	+ "|"
									cEntidades+= SGS->GS_CLVL 		+ "|"
									For nX := 1 To Len(aCTBEnt)
										cEntidades+= SGS->&("GS_EC"+aCTBEnt[nX]+"CR")	+ "|"
										cEntidades+= SGS->&("GS_EC"+aCTBEnt[nX]+"DB")	+ "|"
									Next nX
									aAdd(aRateio,{SGS->GS_PERC, cEntidades})
									
									SGS->(DbSkip())
								EndDo
							Else //-- Caso nao existe rateio assume 100%
								cEntidades:= SCP->CP_CC 		+ "|" 
								cEntidades+= SCP->CP_CONTA		+ "|"
								cEntidades+= SCP->CP_ITEMCTA 	+ "|"
								cEntidades+= SCP->CP_CLVL 		+ "|"
								For nX := 1 To Len(aCTBEnt)
									cEntidades+= SCP->&("CP_EC"+aCTBEnt[nX]+"CR")		+ "|"
									cEntidades+= SCP->&("CP_EC"+aCTBEnt[nX]+"DB")		+ "|"
								Next nX								
							EndIf
							
							If !Empty(SCP->CP_VUNIT)
								nPrc:= SCP->CP_VUNIT
							EndIf
							If !Empty(aRateio)
								aAdd(aCampos,{"RATEIO"		, "1"})
							EndIf
							aAdd(aCampos,{"OBS"		, cMsgSC})	
							aAdd(aCampos,{"DATPRF"	, SCQ->CQ_DATPRF})	
							aAdd(aCampos,{"LOCAL"	, SCQ->CQ_LOCAL})	
							aAdd(aCampos,{"CC"		, SCQ->CQ_CC})	
							aAdd(aCampos,{"CONTA"	, SCQ->CQ_CONTA})	
							aAdd(aCampos,{"ITEMCTA"	, SCQ->CQ_ITEMCTA})	
							aAdd(aCampos,{"CLVL"	, SCQ->CQ_CLVL})	
							aAdd(aCampos,{"DESCRI"	, SCQ->CQ_DESCRI})	
							aAdd(aCampos,{"EMISSAO"	, dDataBase})						
							aAdd(aCampos,{"FILENT"	, xFilEnt((cCursor)->CP_FILIAL,"SC1")})
							aAdd(aCampos,{"COTACAO"	, If(SB1->B1_IMPORT=="S","IMPORT","")})	
							aAdd(aCampos,{"FORNECE"	, SB1->B1_PROC})	
							aAdd(aCampos,{"LOJA"	, SB1->B1_LOJPROC})								
							aAdd(aCampos,{"SOLICIT"	, SCP->CP_SOLICIT})
							aAdd(aCampos,{"VUNIT"	, SCP->CP_VUNIT})
							aAdd(aCampos,{"OS"		, If(empty(SCP->CP_NUMOS),SubStr(SCP->CP_OP,1,At("OS",SCP->CP_OP)-1),SCP->CP_NUMOS)})
							If lMT106SCA
					  			aCPAgl := Execblock("MT106SCA",.f.,.f.)
		                        If Valtype(aCPAgl) == "A"
		                        	aAdd(aCampos,{"MT106SCA",{aCPAgl[1], aCPAgl[2]}})
		                        Else
		                        	aAdd(aCampos,{"MT106SCA",{" ", " "}})
								EndIf
							Else
	                        	aAdd(aCampos,{"MT106SCA",{" ", " "}})
							EndIf
							
							If lLtEco .and. Ascan(aDocs,{|x| x[1] == SCP->CP_PRODUTO .and. iif(x[2] > 0,!(nSumLE > x[2]),.f.)}) <> 0
								nLoteSC := 0
	 						EndIf
							aadd(aDocs,;
									{SCP->CP_PRODUTO,;			//aPequena[x,1] : Produto
									 nLoteSC 		,;			//aPequena[x,2] : Quantidade da necessidade total
									 (cCursor)->CP_FILIAL,;		//aPequena[x,3] : Filial que será gerada o documento 
									 (cCursor)->CP_FILIAL,;		//aPequena[x,4] : Filial que será feita entrega do produto 
									 "1"     		,;			//aPequena[x,5] : Documento que será gerado sendo 1=Solicitação de Compras e 2=Pedido de Compra
									 aFornecedor[1]	,; 			//aPequena[x,6] : Fornecedor do produto
									 aFornecedor[2]	,; 			//aPequena[x,7] : Loja do fornecedor do produto
									 "001" 			,;			//aPequena[x,8] : Condiçãoo de pagamento
									 nPrc			,;		 	//aPequena[x,9] : Preçoo do Produto
									 aClone(aRateio),;		 	//aPequena[x,10] : Array de Rateio
									 SCP->CP_NUM	,;		 	//aPequena[x,11] :código Documento
									 SCP->CP_ITEM	,;			//aPequena[x,12] : Item do Documento 
									 aClone(aCampos)	,;		 	//aPequena[x,13] : Dados de campos adicionais
									 (cCursor)->CP_FILIAL})	 	//aPequena[x,14] : Filial de Origem
							Reclock("SCP",.F.)
							SCP->CP_PREREQU := "S"
							MsUnlock()
							//limpa o array para o Loop
							aCampos	:= {}		
		
						EndIf
						
						nQtde -= nQtdPre
						nSaldo-= nEstoque
						cSeq  := Soma1(cSeq,Len(SCQ->CQ_NUMSQ))
						
						//Ponto de Entrada para permitir a geracaoo de Ordem de Producaoo pela Pre-Requisicao
						
						If lMASAVLOP
							 ExecBlock("MASAVLOP",.F.,.F.)
						EndIf	
						// Se houve erro na geracao da rotina automatica da solicitacao de compra desfaz alteracoes
						If lErrAutSC .And. !IsBlind()
							//AVISO(STR0116,STR0117,{STR0118})
							DisarmTransaction()
							Exit
						EndIf
					EndDo
					
				End Transaction
				If !Empty(cMsg) .And. !lAuto
					//Aviso(STR0014,cMsg,{STR0087},1)			
				EndIf
				If	Empty(cMsg)
					AAdd(aRecSCP,SCP->(Recno()))
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea(cCursor)
	dbSkip()
	lVLCP := .T. // Ativa variavel para validar novo item da Geracao de pre req. ao armazem 
EndDo

If !Empty(aDocs)
	aDocsCp := aClone(aDocs) 
	aResultado:= ComGeraDoc(aDocs,.T.,.F.,.F.,.T.,30,"MATA106",/*lEnviaEmail*/,nAglutDoc  )
	If ExistBlock("MT106SC1")
		For nLoop := 1 To Len( aResultado )
			If Len(aResultado[nLoop]) > 0
				dbSelectArea("SCP")
				dbSetOrder(1)
				dbSeek(aDocsCp[nLoop][14]+aDocsCp[nLoop][11]+aDocsCp[nLoop][12])
				Do Case
					//--Tipo de documento gerado pela biblioteca de compras
					Case aResultado[nLoop,1,3] == "1" //-- Solicitacao de Compras
						SC1->(dbSetOrder(1)) //-- C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
						If SC1->(dbSeek(aResultado[nLoop,1,1]+aResultado[nLoop,1,2]))
							Execblock("MT106SC1",.F.,.F.,{"SC1",SC1->C1_NUM,SC1->C1_ITEM,SC1->(Recno())})
						EndIf
					Case aResultado[nLoop,1,3] == "2" //-- Pedido de Compras
						SC7->(dbSetOrder(1))  //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
						If SC7->(dbSeek(aResultado[nLoop,1,1]+aResultado[nLoop,1,2]))
							Execblock("MT106SC1",.F.,.F.,{"SC7",SC7->C7_NUM,SC7->C7_ITEM,SC7->(Recno())})
						EndIf
					Case aResultado[nLoop,1,3] == "3" //-- Autorizacao de Entrega
						SC7->(dbSetOrder(1))  //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
						If SC7->(dbSeek(aResultado[nLoop,1,1]+aResultado[nLoop,1,2]))
							Execblock("MT106SC1",.F.,.F.,{"SC7",SC7->C7_NUM,SC7->C7_ITEM,SC7->(Recno())})
						EndIf
					Case aResultado[nLoop,1,3] == "5" //-- Medicao de Contrato
						CND->(dbSetOrder(4))  //--CND_FILIAL+CND_NUMMED
						If CND->(dbSeek(aResultado[nLoop,1,1]+aResultado[nLoop,1,2]))
							Execblock("MT106SC1",.F.,.F.,{"CND",CND->CND_NUMMED,,CND->(Recno())})
						EndIf
					Case aResultado[nLoop,1,3] == "6" //-- Solicitacaoo de Importacoo
						SW1->(dbSetOrder(1)) //-- W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I 
						If SW1->(MsSeek(aResultado[nLoop,1,1]+PadR(cUndRequi,Len(SW1->W1_CC))+aResultado[nLoop,1,2]))
							Execblock("MT106SC1",.F.,.F.,{"SW1",SW1->W1_SI_NUM,SW1->W1_COD_I,SW1->(Recno())})
						EndIf
				EndCase
			Endif
		Next nLoop
	EndIf
EndIf


//P.E. Apos a geracao completa da Pre-Requisicao	   
//PARAMIXB[1] := CQ_FILIAL   PARAMIXB[2] := CQ_NUM    
//PARAMIXB[3] := CQ_ITEM     PARAMIXB[4] := CQ_NUMSQ   
//PARAMIXB[5] := CQ_PRODUTO  PARAMIXB[6] := CQ_LOCAL  
//PARAMIXB[7] := CQ_QUANT                             

If ExistBlock("MT106PRE")
	ExecBlock("MT106PRE",.F.,.F.,aMT106SCQ)
EndIf
If ( lQuery )
	dbSelectArea(cCursor)
	dbCloseArea()
	dbSelectArea("SCP")
EndIf
If lGeraDoc
	PcoFinLan("000051")
EndIf
RestArea(aArea)
Return(.T.)

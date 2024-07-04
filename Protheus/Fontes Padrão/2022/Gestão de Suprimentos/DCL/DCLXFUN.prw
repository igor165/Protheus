#INCLUDE 'Protheus.ch'
#DEFINE ENTER chr(13) + chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValEstDcl
Valida se a movimentacao deixara o saldo em estoque
	negativa, e atraves dos parametros MV_DCLEST1/2/3
	permite ou nao prosseguir com a movimentacao.
@author Robson Sales
@param cCod = Codigo do produto
@param cLocal = Armazem
@param nQuant = Quantidade da movimentacao
@param dData = Data de emissao do movimento
@param nOperacao = 1(SD1), 2(SD2) e 3(SD3)
@return lRet
@since 17/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function ValEstDcl(cCod,cLocal,nQuant,dData,nOperacao)

Local nSaldo 	:= 0
Local lRet   	:= .T.
Local cMens  	:= ""
Local cTitle 	:= "DCL-EST: Movimentação deixará Saldo Negativo"
Local lSegue 	:= SuperGetMv("MV_DCLEST"+Alltrim(Str(nOperacao)),.F.,.F.)
Local lEstZero:= Alltrim(cCod) $ SUPERGETMV('MV_ESTZERO',.F.,'  ')
Local aAreaSB2:= SB2->(GetArea())

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	// Para o caso EstZero não valida saldo, por que sempre será Zero.
	If !lEstZero
		
		nSaldo := CalcEst(cCod,cLocal,dData+1)[1]
		
		// Subtrai empenho e reserva do saldo Fisico
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If SB2->(MsSeek(xFilial("SB2")+cCod+cLocal))
			nSaldo -= SB2->B2_RESERVA
			nSaldo -= SB2->B2_QEMP
		EndIf
		
		If (nSaldo - nQuant) < 0 
			cMens := "ATENÇÃO" + ENTER
			cMens += ""+ENTER
			cMens += "A movimentação deixará Saldo Negativo em Estoque." + ENTER
			cMens += ""+ENTER
			cMens += "Produto..........:   " + Alltrim(cCod) + ENTER
			cMens += "Armazém.......:   " + Alltrim(cLocal) + ENTER
			cMens += "Em estoque....:   " + Alltrim(Transform(nSaldo,"@E 99,999,999.99")) + ENTER 
			cMens += "Necessidade..:   "  + Alltrim(Transform(nQuant,"@E 99,999,999.99")) + ENTER
			cMens += "Diferença.......:   " + Alltrim(Transform((nQuant-nSaldo),"@E 99,999,999.99")) + ENTER
			If lSegue
				cMens += ""+ENTER
				cMens += "Prosseguir mesmo assim?"
				If ! MsgYesNo(cMens,cTitle)
					lRet:=.F.
					Help(,,"DCLEST_Help",,"O movimento não foi processado.",1,0) 
				EndIf
			Else
				MsgInfo(cMens,cTitle)
				lRet:=.F.
				Help(,,"DCLEST_Help",,"O movimento não foi processado.",1,0)
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSB2)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVldBloq
Funcao responsavel por validar se um produto esta bloqueado, 
Caso retornar verdadeiro o produto esta bloqueado

@author alexandre.gimenez	

@param cCod,cLocal - Codigo e Armazem do produto
@return lRet
@since 23/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLVldBloq(cCod,cLocal)
Local lRet := .F.
Local aArea := GetArea()

If SuperGetMv("MV_DCLNEW",.F.,.F.)
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cCod+cLocal))
		lRet := SB1->B1_MSBLQL == "1" //--bloqueado
		If lRet
			Help(,,"DCLEST_MSBLQL",,"O Produto "+AllTrim(cCod)+" esta bloqueado. O movimento não foi processado.",1,0)
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} EstornaDCL
Função para movimentos provisórios da PetroBahia

@author Douglas.Nunes
@since 29/07/2014
@version 1.0          

@param cBusca caractere, Código do Documento a ser Estornado 
@param nTipo, numérico,	1 - Exclusão do documento de entrada
							2 - Exclusão do documento de saída antes do 
								recebimento do documento de entrada

/*/
//-------------------------------------------------------------------
Function EstornaDCL(cBusca, nTipo)

Local cTipMov 		:= SuperGetMv('MV_TMPRV',,'')
Local aArea   		:= GetArea()
Local aRec			:= {}
Local aMov    		:= {}
Local aEstorna 		:= {}
Local lPos    		:= .F.
Local nX      		:= 0
Local lRet 			:= .T.

PRIVATE lMsErroAuto	:= .F.
	
If SuperGetMv("MV_DCLNEW",.F.,.F.)
	If nTipo == 1
		SD3->(DbSetOrder(13))//D3_FILIAL+D3_CHAVEF1
	Else
		SD3->(DbSetOrder(16))//D3_FILIAL+D3_CHAVEF2
	EndIf
	
	// Posiciona no primeiro Registro da chave de busca
	If SD3->(DbSeek(xFilial('SD3')+cBusca))
		If nTipo == 1
			lPos := .T.
		Else
			While Alltrim(xFilial('SD3')+cBusca) == Alltrim(If(nTipo == 1,SD3->(D3_FILIAL+D3_CHAVEF1),SD3->(D3_FILIAL+D3_CHAVEF2)))
				If Empty(SD3->D3_ESTORNO)
					lPos := .T.
					Exit
				EndIf
				SD3->(dbSkip())
			EndDo
		EndIf
	EndIf

	If lPos
		If nTipo == 1 // Devolução de NFS
			While AllTrim(SD3->D3_CHAVEF1) == cBusca 
				//guarda recno para mudar a chave depois
				aAdd(aRec,SD3->(Recno()))
				//Não deve processar Movimentos 999
				If SD3->D3_TM != cTipMov 					
					SD3->(DBSkip())
					Loop
				EndIf
				
				//Reincluir todos os encontrados.
				Aadd(aMov,{})
				aADD(aMov[Len(aMov)],{"D3_FILIAL" ,xFilial("SD3")	,NIL})
				aADD(aMov[Len(aMov)],{"D3_TM"	  ,cTipMov  		,NIL})
				aADD(aMov[Len(aMov)],{"D3_UM"	  ,SD3->D3_UM		,NIL})
				aADD(aMov[Len(aMov)],{"D3_COD"	  ,SD3->D3_COD		,NIL})
				aADD(aMov[Len(aMov)],{"D3_DOC"	  ,SD3->D3_DOC		,NIL})
				aADD(aMov[Len(aMov)],{"D3_QUANT"  ,SD3->D3_QUANT	,NIL})
				aADD(aMov[Len(aMov)],{"D3_LOCAL"  ,SD3->D3_LOCAL	,NIL})
				aADD(aMov[Len(aMov)],{"D3_EMISSAO",SD3->D3_EMISSAO	,NIL})
				aADD(aMov[Len(aMov)],{"D3_TPMOVAJ"  ,SD3->D3_TPMOVAJ  	,NIL})
				aADD(aMov[Len(aMov)],{"D3_CHAVEF2"  ,SD3->D3_CHAVEF2	,NIL})
				
				SD3->(DBSkip())	
			EndDo
			
			//Inclui os novos movimentos
			For nX := 1 to Len(aMov)
				MsExecAuto({|a,b| Mata240(a,b)},aMov[nX],3)
				If lMsErroAuto
					Exit
				EndIf
			Next nX
			
			//Marca os movimentos recriados, para não recriara novamente
			IF !lMsErroAuto
				For nX := 1 To Len(aRec)
					SD3->(DbGoto(aRec[nX]))
					RecLock('SD3',.F.)
					SD3->D3_CHAVEF1 := 'EX'+cBusca
					SD3->(MSUnlock())
				Next Nx
			EndIf	

		ElseIf nTipo == 2 .AND. Empty(SD3->D3_CHAVEF1) // Excluir NFS
			If SD3->D3_TM == cTipMov .AND. AllTrim(SD3->D3_ESTORNO) <> 'S'
				Aadd(aEstorna,{"D3_FILIAL"	,xFilial("SD3")	,NIL})
				Aadd(aEstorna,{"D3_NUMSEQ"	,SD3->D3_NUMSEQ	,NIL})
				Aadd(aEstorna,{"D3_CHAVE"	,SD3->D3_CHAVE	,NIL})
				Aadd(aEstorna,{"D3_COD"		,SD3->D3_COD	,NIL})
				Aadd(aEstorna,{"INDEX"		,4		 		,Nil})
					
				MsExecAuto({|a,b| Mata240(a,b)},aEstorna,5)//Realiza o Estorno do Documento
			EndIf
			
		ElseIf nTipo == 2 .AND. !Empty(SD3->D3_CHAVEF1) 
			Help(,,"EstornaDCL",,'Não é possível excluir o Documento de Saída pois há o Documento de Entrada associado: ' + Alltrim(SD3->D3_CHAVEF1),1,0)
			lRet := .F.
		EndIf
	Else
		If !MsgYesNo("Não foi possível localizar o movimento solicitado para efetuar o estorno. Deseja prosseguir e não fazer o estorno do movimento provisório?","EstornaDCL")
			lRet := .F.
		Endif
	EndIf
	
	If lMsErroAuto
		Mostraerro()
		lRet := .F.
	EndIf
EndIf
	
RestArea(aArea)	
	
Return lRet        

//-------------------------------------------------------------------
/*/{Protheus.doc} M330ApEst 
Função para controlar o apagamento dos pares de estornos somente de datas iguais nos
movimentos internos na execução do recalculo (mata330) PetroBahia

@author Nilton

@param cBusca caractere, Código do Documento a ser Estornado 
@param nTipo, numérico,	1 - Exclusão do documento de entrada
							2 - Exclusão do documento de saída antes do 
								recebimento do documento de entrada

/*/
//-------------------------------------------------------------------
Function M330ApEst(cCod,cLocal,nNumseq,dDtemi,nD3Recno)
Local lRet			:= .T.
Local cSeek		:= ""
Local cCompara	:= ""

If SuperGetMv("MV_DCLNEW",.F.,.F.)
	dbSelectArea("SD3")
	SD3->(dbSetOrder(3)) //D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ+D3_CF
	
	cSeek		:= xFilial("SD3") + cCod + cLocal + nNumseq
	cCompara	:= "D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ"
	
	SD3->(dbSeek(cSeek))
	
	While !Eof() .And. cSeek == &(cCompara)
		If D3_ESTORNO == "S" .and. D3_EMISSAO <> dDtemi .and. nD3Recno <> recno()
		   lRet:= .F.
		Endif   
		dbSkip()
	EndDo
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} M103VlBom 
Função para substituir o valid exist('SD3',M->D1_T_DPROV,14) com indice posicional 
para indice com nickname
@author Nilton
/*/
//-------------------------------------------------------------------
Function M103VlBom (cTDprov)
Local lRet			:= .F.
Local cSeek		:= ""
Local cCompara	:= ""
Local lMVC			:= Type("oModel") <> "U"
Local oModDH4		:= IIF(lMvc,oModel:GetModel("DH4DETAIL"),NIL)
Local nX			:= 0
Local nLinhaAtu	:= 0

If SuperGetMv("MV_DCLNEW",.F.,.F.)
	dbSelectArea("SD3")
	SD3->(dbSetOrder(16)) //D3_FILIAL+D3_NFORP+D3_TPMOVAJ+D3_ESTORNO+DTOS(D3_EMISSAO)+D3_COD+D3_LOCAL+D3_TANQUE
	
	cSeek		:= xFilial("SD3") + cTDprov
	cCompara	:= "D3_FILIAL+D3_NFORP"
	
	SD3->(dbSeek(cSeek))
	
	While !Eof() .And. cSeek == &(cCompara)
	   lRet:= .T.
	   Exit
	   dbSkip()
	EndDo
	
	If lMvc
		nLinhaAtu := oModDH4:GetLine()
		For nX := 1 To oModDH4:Length()
			oModDH4:GoLine(nX)
			If oModDH4:GetValue("DH4_DCPROV") == cTdProv
				Help(,,"M103VlBom",,'Nr. de ORP igual ao item ' + oModDH4:GetValue("DH4_ITEM") ,1,0,,,,,,{'Nao pode existir nr. de ORP repetido'})
				lRet := .F.
			EndIf
		Next nX
		oModDH4:GoLine(nLinhaAtu)
	EndIf
	
EndIf

Return lRet        

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLNomeMot 
Retorna o nome do Motorista
@author jose.eulalio
@since 09/03/2017
@return cRet
/*/
//-------------------------------------------------------------------
Function DCLNomeMot(cCodMot)
Local cRet			:= ""
Local aAreaDHB	:= DHB->(GetArea())

If !INCLUI
	DHB->(DbSetOrder(1))
	If DHB->(DbSeek(xFILIAL("DHB") + cCodMot))
		cRet := DHB->DHB_NOMMOT
	EndIf
EndIf

RestArea(aAreaDHB)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclMt410Vl 
Validação dos campos obrigatórios do MATV410 (Pedido de Vendas)
@author jose.eulalio
@since 30/03/2017
@return lRet
/*/
//-------------------------------------------------------------------
Function DclMt410Vl()
Local lRet := .T.

If Empty(M->C5_MODANP)
	lRet := .F.
	Help("",1,"410NoAnp1",,"Campo obrigatório não preenchido no cabeçalho.",1,0,,,,,,{"Preencha o campo Modal ANP"})
EndIf

If lRet .And. SC5->(FieldPos("C5_CLTRCLI")) > 0 .And. Empty(M->C5_CLTRCLI)
	lRet := .F.
	Help("",1,"410NoAnp2",,"Campo obrigatório não preenchido no cabeçalho.",1,0,,,,,,{"Preencha o campo Clas.Trib.Cliente"})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclValidCp 
Validação das empresas que podem utilizar o DCL produtizado
@author fsw.ses
@since 21/12/2020
@return lRet
/*/
//-------------------------------------------------------------------
Function DclValidCp()

    Local lRet      := .T.
    Local aCnpj     := {}
    Local aSM0Comp  := {}

    aAdd(aCnpj, "43588060000180") //Verquimica
    aAdd(aCnpj, "21802567000151") //Usegas
    aAdd(aCnpj, "11463963000148") //Brasil China
    aAdd(aCnpj, "47176755000105") //Helm
    aAdd(aCnpj, "33138223000179") //Transportadora Santa Isabel
    aAdd(aCnpj, "61531620000141") //Promax
    aAdd(aCnpj, "61531620001709") //Promax
    aAdd(aCnpj, "07454414000130") //Agro Industrial
    aAdd(aCnpj, "43633296000190") //Comexport
    aAdd(aCnpj, "62379037000120") //Mavalerio
    aAdd(aCnpj, "62379037000391") //Mavalerio
    aAdd(aCnpj, "81632093001060") //Agricopel
    aAdd(aCnpj, "81632093000764") //Agricopel

    aSM0Comp := FwLoadSM0()
    If aScan(aCnpj, aSM0Comp[1][18]) == 0
        lRet := .F.
    EndIf

    aSize(aSM0Comp, 0)
	aSM0Comp := Nil

    aSize(aCnpj, 0)
	aCnpj := Nil

Return lRet

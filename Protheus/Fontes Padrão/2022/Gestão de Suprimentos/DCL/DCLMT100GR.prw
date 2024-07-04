#INCLUDE 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMT100GR
Atualiza movimento provisório quando o parâmetro MV_ESTZERO 
está ativo e TES que atualiza estoque
@return   Nil

@author   José Eulálio
@since    30.04.2014
@version  P11
/*/
//-------------------------------------------------------------------
Static Function DCLMT100GR()
Local _lRet		:= .T.
Local lExclui		:= PARAMIXB[1]
Local cMensDados
Local nX
Local _nPosCod
Local _nPosTes
Local _nPosQtd
Local _nPosItem

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If (cTipo == 'N') 
	For nX := 1 to Len(aCols)
		cMensDados    :=""
		_nPosCod   	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
		_nPosTes   	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_TES"})
		_nPosQtd   	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_QUANT"})		
		_nPosItem   	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_ITEM"})
		IF ALLTRIM(aCols[nX,_nPosCod]) $ SUPERGETMV('MV_ESTZERO',.F.,'  ')  // Tratamento para produtos sem estoque.
			SF4->(DBSETORDER(1))
			IF SF4->(DBSEEK(XFILIAL('SF4')+aCols[nX,_nPosTes])) .AND. SF4->F4_ESTOQUE =='S'			
				IF Inclui .Or. Altera 
					_lRet := MT100est(aCols[nX,_nPosCod],aCols[nX,_nPosQtd],nX)
				ElseIf lExclui
					_lRet := EstornaDCL(SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+aCols[nX,_nPosItem], 1)// Estorna o registro
				ENDIF
			ENDIF
		EndIf
	Next
EndIf		

Return (_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} MT100est
Atualiza movimento provisório quando o parâmetro MV_ESTZERO está ativo e TES que atualiza estoque
@return   Nil

@author   José Eulálio
@since    28.04.2014
@version  P11
/*/
//-------------------------------------------------------------------
Static Function MT100est(cProduto,nQtde,nPosAcols)
Local oSize
Local aEstZero	:= {}
Local nValor		:= 0
Local nX			:= 1
Local lRet		:= .F.
Local nPosItem	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_ITEM"})
Local cItem		:= aCols[nX,nPosItem]
Local nPosLocal	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_LOCAL"})
Local cLocal		:= aCols[nX,nPosLocal]
Local cChave		:= xFilial("SD3")+cProduto+cLocal+DTOS(DDEMISSAO)
Local aChave		:= {}
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local aHeadSD3	:= {}
Local aColsSD3	:= {}

aHeadSD3 := {" ",RetTitle("D3_DOC"),RetTitle("D3_EMISSAO"),RetTitle("D3_COD"),RetTitle("D3_QUANT")}

SD3->(DbSetOrder(7))//D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_NUMSEQ
If SD3->(DbSeek(cChave))	
	While SD3->(!EoF())  .And. SD3->(D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)) == cChave
		If SD3->(D3_FILIAL+D3_COD+D3_TPMOVAJ+D3_TM) == xFilial("SD3")+cProduto+"PR"+SuperGetMv('MV_TMPRV',,'') .And. SD3->D3_ESTORNO <> "S"
			aAdd(aColsSD3,{.F.,SD3->D3_DOC,DToC(SD3->D3_EMISSAO),SD3->D3_COD,SD3->D3_QUANT})
			aAdd(aChave,SD3->D3_CHAVEF2)
		EndIf
		SD3->(DbSkip()) 
	End
EndiF		

If !Empty(aColsSD3)
		
	DEFINE MSDIALOG oDlg FROM 0,0 TO 400,600 TITLE 'Ajuste de Movimento Provisório' Of oMainWnd PIXEL //"Ajuste de Movimento Provisório"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.T.,,,oDlg)             
	//oSize:aWorkArea := {000,000, 250, 110 }
	oSize:AddObject( "CABECALHO",  100, 10, .T., .F. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel 
	oSize:AddObject( "RODAPE"   ,  100, 50, .T., .F. ) // Totalmente dimensionavel

	oSize:lProp 		:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() 	   // Dispara os calculos   


	@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI") SAY ALLTRIM(RetTitle("D1_ITEM"))+": "+ ALLTRIM(cItem)  OF oDlg PIXEL SIZE 50,09
	@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+80 SAY ALLTRIM(RetTitle("D1_COD"))+": "+ ALLTRIM(cProduto) OF oDlg PIXEL SIZE 50,09
	@ oSize:GetDimension("CABECALHO","LININI") ,oSize:GetDimension("CABECALHO","COLINI")+170 SAY ALLTRIM(RetTitle("D1_QUANT"))+": "+ AllTrim(Str(nQtde)) OF oDlg PIXEL SIZE 50,09
	  
   oBrowse := TWBrowse():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
   								 oSize:GetDimension("GETDADOS","COLEND"),oSize:GetDimension("GETDADOS","LINEND"),,aHeadSD3,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    		
   	oBrowse:SetArray(aColsSD3)
   	oBrowse:bLine := {|| {If(aColsSD3[oBrowse:nAt,1],oOk,oNo),aColsSD3[oBrowse:nAt,2],aColsSD3[oBrowse:nAt,3],aColsSD3[oBrowse:nAt,4],aColsSD3[oBrowse:nAt,5]}}
	oBrowse:bLDblClick := {|| aColsSD3[oBrowse:nAt,1] := !aColsSD3[oBrowse:nAt,1]}
 			
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(lRet := DcAjuMvPrv(aColsSD3,nPosAcols,aChave),(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,)

Else
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial('SB1')+cProduto)) .And. SB1->B1_TOLER == 100
		lRet := .T.
	Else
		Help(,,"DCLEST_Help",,'Não foi possível localizar o movimento associado.',1,0)
		lRet := .F.
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DcAjuMvPrv
Valida e atualização movimento provisório na SD3
@return   Nil

@author   José Eulálio
@since    29.04.2014
@version  P11
/*/
//-------------------------------------------------------------------
Function DcAjuMvPrv(aColsSD3,nPosAcols,aChave)
Local lRet := .T.
Local lResp := .T.
Local nX	:= 0
Local nTotal := 0
Local nToler := 0 
Local nDif		:= 0
Local nPosCod  := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_COD"})
Local nPosQnt	:= aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_QUANT"})
Local nPosLocal := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_LOCAL"})
Local nPosItem := aScan(aHeader,{|x| Upper(alltrim(x[2])) == "D1_ITEM"})
Local aEstorna := {}
Local nIndex	:= 0

For nX :=1 to Len(aColsSD3)
	If aColsSD3[nx][1] == .T.
		nTotal := nTotal + aColsSD3[nx][5]
	EndIf	
Next

If nTotal <> aCols[nPosAcols][nPosQnt]
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If (lRet := (SB1->(DbSeek(xFilial('SB1')+(aCols[nPosAcols][nPosCod])+(aCols[nPosAcols][nPosLocal])))))
		nToler := aCols[nPosAcols][nPosQnt]/100 * SB1->B1_TOLER
		If aCols[nPosAcols][nPosQnt] > nTotal
			nDif := aCols[nPosAcols][nPosQnt] - nTotal
		Else
			nDif := nTotal - aCols[nPosAcols][nPosQnt] 
		EndIf
		If nDif > nToler
			lRet := .F.
			Help(,,"DCLEST_Help",,'O somatório dos itens selecionados ('+ AllTrim(Str(nTotal)) +' '+ SB1->B1_UM +') ultrapassou a quantidade de tolerância permitida para este item. Tolerância: '+Alltrim(Str(SB1->B1_TOLER))+'%, Quantidade Original: ('+ AllTrim(Str(aCols[nPosAcols][nPosQnt])) +' '+ SB1->B1_UM +').',1,0)		
		EndIf	
	EndIf
EndIf

If lRet
	DbSelectArea('SD3')
	SD3->(DbSetOrder(16))
	nIndex := IndexOrd()
	For nX :=1 to Len(aColsSD3)
		If aColsSD3[nx][1] == .T. .And. SD3->(DbSeek(xFilial('SD3')+aChave[nx])) .And. SD3->D3_ESTORNO <> "S"
			RecLock("SD3",.F.)
				SD3->D3_CHAVEF1 := CA100FOR+CLOJA+CNFISCAL+CSERIE+aCols[nPosAcols][nPosItem]
			MsUnlock()
			aADD(aEstorna,{"D3_FILIAL"	,xFilial("SD3")	,NIL})
			aADD(aEstorna,{"D3_CHAVEF2"	,aChave[nx]		,NIL})
			aADD(aEstorna,{"INDEX"		,nIndex 			,Nil})
			lMsErroAuto := .F.
			MsExecAuto({|a,b| Mata240(a,b)},aEstorna,5)//Realiza o Estorno do Documento
			If lMsErroAuto
				MostraErro()
				lRet := .F.
			EndIf
			aEstorna := {}
		EndIf
	Next
EndIf

Return lRet

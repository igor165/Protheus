#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TMSXFUNP.ch"  

/*/-----------------------------------------------------------
{Protheus.doc} TMSIDPAM(cFilOri,cViagem,cTipPar)
Função para retornar o Cartão da Viagem com Operadora de Frotas
Pamcard.

Uso: TMSA250, TMNSA251

@sample
//(cFilOri,cViagem,cTipPar)

@author Katia 
@since 14/06/18
@version 1.0
-----------------------------------------------------------/*/
Function TMSIDPAM(cFilOri,cViagem,cTipPar,lVerDUP)

Local aArea     := GetArea()
Local lTabDLD   := AliasIndic('DLD')  //Pagamentos da Viagem
Local cAliasQry := ""
Local cQuery    := ""
Local cIdOper   := ""

Default cFilOri:= ""
Default cViagem:= ""
Default cTipPar:= ""
Default lVerDUP:= .F.  //Consulta somente a DUP independente de existir a DLD
    
DTR->(DbSetOrder(1))
If DTR->(dbSeek(xFilial('DTR') + cFilOri + cViagem ))
    cAliasQry := GetNextAlias()
	If !lTabDLD .Or. lVerDUP  //lVerDUP -> Consulta pelo DUP
		cQuery      := " SELECT DUP.DUP_CONDUT CONDUT, DUP.DUP_IDOPE IDCARTAO " 
		cQuery      += " FROM " + RetSqlName ("DUP") + " DUP " 
		cQuery      +=  " WHERE DUP.DUP_FILIAL = '" + xFilial ("DUP") + "' " 
		cQuery      +=    " AND DUP.DUP_FILORI = '" + cFilOri + "' "
		cQuery      +=    " AND DUP.DUP_VIAGEM = '" + cViagem+ "' "
		cQuery      +=    " AND DUP.DUP_CONDUT = '1' "  //Principal
		cQuery      +=    " AND DUP.D_E_L_E_T_ = ' ' " 
	Else	
		cQuery      := " SELECT DISTINCT DUP.DUP_IDOPE, DLD.DLD_IDOPE,  "
		cQuery      += " CASE WHEN DLD.DLD_IDOPE IS NULL THEN DUP.DUP_IDOPE ELSE DLD.DLD_IDOPE END AS IDCARTAO  "
		cQuery      += " FROM " + RetSqlName ("DUP") + " DUP " 
		cQuery      += " LEFT JOIN " + RetSqlName ("DLD") + " DLD " 
		cQuery      += " ON DLD.DLD_FILIAL = '" + xFilial ("DLD") + "' " 
		cQuery      += " AND DLD.DLD_FILORI = DUP.DUP_FILORI 
		cQuery      += " AND DLD.DLD_VIAGEM = DUP.DUP_VIAGEM 
		 If !Empty(cTipPar)
            cQuery  +=    " AND DLD.DLD_TIPPAR = '" + cTipPar  + "' "
        EndIf   
		cQuery      += " AND DLD.D_E_L_E_T_ = ' ' 
		cQuery      += " WHERE DUP.DUP_FILIAL = '" + xFilial ("DUP") + "' " 
		cQuery      += " AND DUP.DUP_FILORI = '" + cFilOri + "' " 
		cQuery      += " AND DUP.DUP_VIAGEM = '" + cViagem + "' " 
		cQuery      += " AND DUP.DUP_CONDUT = '1' "  //Principal
		cQuery      += " AND DUP.D_E_L_E_T_ = ' ' 
    EndIf

    cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
	If !(cAliasQry)->(Eof())          
        cIdOper:= (cAliasQry)->IDCARTAO
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aArea)	
Return cIdOper

/*/-----------------------------------------------------------
{Protheus.doc} TMSIDPAMST(CNPJ,cFilOri,cViagem,cIDOPE_DTQ,cIdOpe)
Função para validar o status do ID Pamcard

Uso: TMSA250, TMNSA251

@sample
//(aRetCNPJ,cFilOri,cViagem,cIDOPE_DTQ,cIdOpe)

@author Katia 
@since 19/06/18
@version 1.0
-----------------------------------------------------------/*/
Function TMSIDPAMST(aRetCNPJ, cFilOri, cViagem, cIdOpe, aConsCard, cStatus)

Local lRet         := .T.
Local aRetorn      := {}
Local nPos         := 0

Default aRetCNPJ   := {}
Default cFilOri    := ""
Default cViagem    := ""
Default cIdOpe     := ""
Default aConsCard  := {}
Default cStatus    := ""

If Len(aRetCNPJ) > 0
	//Pegar o status do cartao
	If cStatus == '3' //--Cancelado
		DTQ->(dbSetOrder(2))
		If DTQ->(dbSeek(xFilial('DTQ')+cFilOri+cViagem))

			aRetorn := PamGetParc(DTQ->DTQ_FILORI, AllTrim(DTQ->DTQ_VIAGEM), aRetCNPJ, DTQ->DTQ_IDOPE )

			nPos := Ascan(aConsCard ,{ | e | e[1] == 'viagem.cartao.numero' })
			If nPos > 0
				aDel(aConsCard ,nPos)
				aAdd(aConsCard, {'viagem.cartao.numero', aRetorn[1][nPos]})
			EndIf
		EndIf
		If cIdOpe <> aConsCard[nPos]
			Help("",1,"TMSXFUNP01",, + " : " + cIdOpe, 4, 1)  //-- O cartao atual nao esta cadastrado para o motorista/responsavel
			lRet := .F.
		EndIf
	EndIf
EndIf	

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSGATDLD()
Função de Gatilho para a Formas de Pagamento da Viagem (DLD)

Uso: TMSA240

@author Katia 
@since 25/06/18
@version 1.0
-----------------------------------------------------------/*/
Function TmsGatDLD(cAcao)
Local aCodFav	:= {}
Local cRet		:= ''
Local cCampo    := ReadVar()
Local aArea     := GetArea()
Local cCod      := ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local oModel    := Nil
Local oMdGridDTR:= Nil
Local nLi       := 0

Default cAcao   := ""
If lVgeMod3
	oModel     := FWModelActive()
	oMdGridDTR := oModel:GetModel('MdGridDTR')
	nLi        := oMdGridDTR:GetLine()
EndIf

If cCampo $ 'M->DLD_RECEB'  
	If M->DLD_RECEB == StrZero(1,Len(DLD->DLD_RECEB))  //1-Proprietario
		If !lVgeMod3
			cCod:= GdFieldGet('DLD_CODVEI',n)
		Else
			cCod:= oMdGridDTR:GetValue('DTR_CODVEI',nLi)
		EndIf
	EndIf
ElseIf cCampo $ 'M->DTR_CODVEI'  
	If !lVgeMod3
		cCod:= GdFieldGet('DTR_CODVEI',n)	
	Else
		cCod:= oMdGridDTR:GetValue('DTR_CODVEI',nLi)	
	EndIf
EndIf

If !Empty(cCod)
	DA3->(dbSetOrder(1))
	If DA3->(MsSeek( xFilial('DA3') + cCod )) .And. !Empty(DA3->DA3_CODFOR)
		aCodFav := T250BscFav(DA3->DA3_COD,DA3->DA3_CODFOR,DA3->DA3_LOJFOR,,)
		If Len(aCodFav) > 0 
			If cAcao == 'CODFAV'
				cRet:= aCodFav[1][1]   //Codigo Favorecido
			Else
				cRet:= aCodFav[1][2]   //Loja Favorecido
			EndIf	
		EndIf	
	EndIf	
EndIf

RestArea(aArea)
Return cRet

/*/-----------------------------------------------------------
{Protheus.doc} TmsForPag(cFilOri,cViagem,cTipPar)

Função para retornar as formas de pagamento da Viagem
@author Katia Bianchi

@since 19/06/2018
@version 1.0
-----------------------------------------------------------/*/
Function TmsForPag(cFilOri,cViagem,cTipPar)

Local aArea     := GetArea()
Local cAliasQry := ""
Local cQuery    := ""
Local aRet		:= {}

Default cFilOri:= ""
Default cViagem:= ""
Default cTipPar:= ""

DTR->(DbSetOrder(1))
If DTR->(dbSeek(xFilial('DTR') + cFilOri + cViagem ))
    cAliasQry := GetNextAlias()
    cQuery      += " SELECT * " 
	cQuery      += " FROM " + RetSqlName ("DLD") + " DLD " 
	cQuery      +=  " WHERE DLD.DLD_FILIAL = '" + xFilial ("DLD") + "' " 
	cQuery      +=    " AND DLD.DLD_FILORI = '" + cFilOri + "' "
	cQuery      +=    " AND DLD.DLD_VIAGEM = '" + cViagem+ "' "
	If !Empty(cTipPar)
		cQuery  +=    " AND DLD.DLD_TIPPAR = '" + StrZero(cTipPar,Len(DLD->DLD_TIPPAR))  + "' "
    EndIf    
    cQuery      +=    " AND DLD.D_E_L_E_T_ = ' ' " 
    cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->( !Eof() )
	       
		Aadd(aRet,{(cAliasQry)->DLD_FORPAG,;
	       	(cAliasQry)->DLD_TIPPAR,;
	       	(cAliasQry)->DLD_RECEB,;
	       	(cAliasQry)->DLD_IDOPE,;
	       	(cAliasQry)->DLD_CODFAV,;
	       	(cAliasQry)->DLD_LOJFAV})

	 	(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aArea)	
Return aRet 

/*/-----------------------------------------------------------
{Protheus.doc} TmsFavPar(aForPag,lExistFav,nQtdFav,cTipPar)

Função para retornar o favorecido da parcela
@author Katia Bianchi

@since 27/06/2018
@version 1.0
-----------------------------------------------------------/*/
Function TmsFavPar(aForPag,lExistFav,nQtdFav,cTipPar)

Local aArea		:= GetArea()
Local cRet		:= "1"	
Local cRecPar	:= ""
Local nPosPar	:= 0
Local lSalFrt   := .F.
Local lExpMot	:= Ascan(aForPag, {|x|  x[3] == "2"}) > 0 
Local lParcAdi	:= Ascan(aForPag, {|x|  x[2] == "1"}) > 0 

Default aForPag		:= {}
Default lExistFav	:= .F.
Default nQtdFav		:= 1
Default cTipPar		:= "2" //Saldo do Frete

If cTipPar == '2'
	lSalFrt   := .T.
EndIf

If Len(aForPag) > 0 //Regra utilizando as formas de pagamento da viagem
	nPosPar := Ascan(aForPag, {|x|  x[2] == cTipPar}) 
	If nPosPar == 0
		nPosPar := Ascan(aForPag, {|x|  x[2] == "2"}) //se não achar a  parcela utiliza o rececedor do saldo do frete
	EndIf
		
	cRecPar := aForPag[nPosPar,3]
	
	If lParcAdi  //Se existir parcela de adiantamento nas formas de pagamento da viagem
		If cRecPar == '2'  //Rececedor da Parcela Motorista
			If lExistFav  .Or. nQtdFav == 2  //Se existir favorecido campo DLD_CODFAV preenchido enviar a parcela para o favorecido tipo 3
				cRet := '3' 
			Else
				If nQtdFav > 2 .And. lSalFrt //Se no contrato na pamcard existir 3 favorecidos e for a parcela de saldo de frete o favorecido da parcela é tipo 3 caso contrário é o tipo 2
					cRet := '3'
				Else
					cRet := '2'
				Endif
			EndIf		
		Else //Recebedor da parcela o propietário
			If lExistFav //Se existir favorecido campo DLD_CODFAV preenchido
				If nQtdFav > 2 .And. lSalFrt .And. !lExpMot //Se no contrato na pamcard existir 3 favorecidos, for a parcela de saldo de frete e não existir parcela para o motorista o favorecido da parcela é tipo 3 caso contrário é o tipo 2
					cRet := '3'
				Else
					cRet := '2'
				Endif	
			Else //Sem não existir favorecidp 
				If nQtdFav > 1 .And. lSalFrt .And. !lExpMot //Se no contrato na pamcard existir 2 favorecidos, for a parcela de saldo de frete e não existir parcela para o motorista o favorecido da parcela é tipo 2 caso contrário é o tipo 1
					cRet := '2'
				Else 
					cRet := '1'
				Endif
			
			EndIf
		EndIf
	Else 
		If cRecPar == '2' //Rececedor da parcela motorista o favorecido da parcela é tipo 2
			cRet := '3'
		Else //Rece
			If lExistFav //Se existir favorecido campo DLD_CODFAV preenchifo o favorecido da parcela é tipo 2 caso contrario 1
				cRet := '2'
			Else
				cRet := '1'
			EndIf
		EndIf
	EndIf
Else //regra antiga para quando não existe a tabela DLD
	If nQtdFav > 1
		cRet := '2'
	Else
		cRet := '1'
	EndIf
EndIf
			
RestArea(aArea)	
Return cRet 

/*/-----------------------------------------------------------
{Protheus.doc} TmDUDIdOpe(cItemDTR,cCodVei)

Função para retornar o DUD_IDOPE
@author Katia 

@since 04/07/2018
@version 1.0
-----------------------------------------------------------/*/
Function TmDUDIdOpe(cItemDTR,cCodVei,lAtualiza)
Local nX		 := 0
Local nZ         := 0
Local nPosIdOpe	 := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_IDOPE" })
Local nPosCondut := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_CONDUT" })
Local nPosForPag := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORPAG" })
Local nPosForAdt := Ascan(aHeaderDUP, {|x| AllTrim(x[2]) == "DUP_FORADT" })
Local cRet       := ""

Default lAtualiza:= .F.

nX := aScan(aMotViag,{|x| x[1] == cItemDTR }) 
If nX > 0
	For nZ := 1 to Len(aMotViag[nX][2])
		If !aMotViag[nX][2][nZ][Len(aMotViag[nX][2][nZ])] .And. (aMotViag[nX][2][nZ][nPosCondut]) == '1' //-- Verifica se a linha esta deletada e Condutor Principal
			If lAtualiza
				aMotViag[nX][2][nZ][nPosIDOPE] := Space(Len(DUP->DUP_IDOPE))
				aMotViag[nX][2][nZ][nPosForPag]:= ""
				aMotViag[nX][2][nZ][nPosForAdt]:= ""
			Else
				cRet:= (aMotViag[nX][2][nZ][nPosIDOPE])
				Exit
			EndIf	
		EndIf
	Next nZ
EndIf

Return cRet

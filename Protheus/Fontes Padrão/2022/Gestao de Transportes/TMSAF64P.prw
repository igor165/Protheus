#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF64.CH'

#DEFINE CODIGO_REPOM	"01"
#DEFINE CODIGO_PAMCARD	"02"
#DEFINE CODIGO_PAGBEM   "03"

//-------------------------------------------------------------------
/*{Protheus.doc} TF64AOpFrt
Validação Operadoras de Frota
@type Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TF64AOpFrt( oModel )
Local aArea     := GetArea()
Local oMdlDM5   := Nil 
Local lRet      := .T.  
Local lPagBem 	:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Default oModel  := FwModelActive()       

oMdlDM5     := oModel:GetModel("MdFieldDM5")

If oMdlDM5:GetValue("DM5_CODOPE") == CODIGO_REPOM
    lRet    := TF64Repom( oModel , oMdlDM5:GetValue("DM5_CODOPE") )
ElseIf oMdlDM5:GetValue("DM5_CODOPE") == CODIGO_PAMCARD
    lRet    := TF64APamC( oModel , oMdlDM5:GetValue("DM5_CODOPE") )
ElseIf oMdlDM5:GetValue("DM5_CODOPE") == CODIGO_PAGBEM .And. lPagBem
	lRet 	:= TF64PagBem(oModel, oMdlDM5:GetValue("DM5_CODOPE"))
Else 
	lRet	:= IsDLDEmpty( oModel )	
EndIf 

RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64APamC
Validação PAMCARD
@type Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TF64APamC( oModel , cCodOpe  )
Local lRet		:= .T. 

Default oModel  := FwModelActive()  
Default cCodOpe	:= ""     

lRet    := VldPamDTR(oModel,cCodOpe)

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldPamDTR
Validação PAMCARD
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPamDTR( oModel, cCodOpe )
Local lRet      := .T. 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local aSaveLine	:= FWSaveRows()
Local oMdlDTR   := Nil
Local nCount    := 0 
Local cCodVei   := ""
Local nPerAdi	:= 0
Local cCodRBQ1	:= ""
Local cCodRBQ2	:= ""
Local cCodRBQ3	:= ""
Local cTipCrg	:= ""
Local nVlrPdg	:= 0 
Local cTpSpdg	:= ""
Local nVlrAdto  := 0
Local nOpc      := 0
Local nQtdEixo  := 0
Local nValFret  := 0

Default oModel      := FWModelActive()
Default cCodOpe		:= ""

oMdlDTR := oModel:GetModel("MdGridDTR")
nOpc    := oMdlDTR:GetOperation()

If nOpc == 3 .Or. nOpc == 4
	cTpSpdg		:= FwFldGet("DM5_TPSPDG")

	For nCount := 1 To oMdlDTR:Length()
		oMdlDTR:GoLine(nCount)
		If !oMdlDTR:IsDeleted()
		
			cCodVei     := oMdlDTR:GetValue("DTR_CODVEI")
			nPerAdi		:= oMdlDTR:GetValue("DTR_PERADI")
			cCodRBQ1	:= oMdlDTR:GetValue("DTR_CODRB1")
			cCodRBQ2	:= oMdlDTR:GetValue("DTR_CODRB2")
			cCodRBQ3	:= oMdlDTR:GetValue("DTR_CODRB3")
			nVlrPdg		:= oMdlDTR:GetValue("DTR_VALPDG")
			cTipCrg		:= oMdlDTR:GetValue("DTR_TIPCRG")
			nQtdEixo    := oMdlDTR:GetValue('DTR_QTDEIX')
			nValFret    := oMdlDTR:GetValue('DTR_VALFRE')
			
			lRet		:= TF64VlQtd( oMdlDTR:Length(.T.) )
			
			If lRet
				lRet	:= VldTpSPDG( cTpSpdg )
			EndIf

			If lRet
				lRet    := TF64VldVei(cCodVei)
			EndIf

			If lRet
				lRet    := TF64VldVei(cCodRBQ1)
			EndIf
			
			If lRet
				lRet    := TF64VldVei(cCodRBQ2)
			EndIf 
			
			If lRet
				lRet   	:= TF64VldVei(cCodRBQ3)
			EndIf 

			If lRet
				lRet	:= TF64PerAdi( cCodVei, nPerAdi )
			EndIf
			
			If lRet
				lRet	:= VldTipCrg( cTipCrg )
			EndIf
			
			If lRet
				lRet    := TF64PamSDG(oModel, cCodOpe, @nVlrAdto )  
			EndIf

			If lRet
				lRet	:= VldPamDLD(oModel,cCodVei,nVlrPdg, nVlrAdto)
			EndIf

			If lRet
				lRet	:= VldPamDUP(oModel,cCodVei)
			EndIf 

			If lRet
				lRet	:= VldPamDJL(cCodVei)
			EndIf

			If lRet		
				TF64FrtMin(M->DTQ_FILORI,M->DTQ_VIAGEM,M->DTQ_SERTMS,M->DTQ_ROTA,M->DTQ_TPOPVG,nQtdEixo,nValFret)        
			EndIf

			If !lRet
				Exit
			EndIf 
		EndIf
	Next nCount 
EndIf

FwRestRows(aSaveLine)
RestArea( aAreaDTR )
RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldTipCrg
Validação viagem de comboio para operadora de frete
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param cCodVei
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldTipCrg( cTipCrg )
Local lRet		:= .T. 

Default cTipCrg	:= ""

If Empty(cTipCrg)
	Help('', 1, "TMSA24066") //'Informe o Tipo de Carga,' '1=Lotacao; 2=Fracionada!!!'
	lRet := .F.
EndIf

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VlQtd
Validação viagem de comboio para operadora de frete
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param cCodVei
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VlQtd( nQtdDTR )
Local lRet		:= .T. 

Default nQtdDTR		:= 0 

If nQtdDTR > 1 
	lRet	:= .F. 
	Help('',1,'TMSA24086') //--Não é possível utilizar comboio quando a viagem for integrada com Operadora de Frete!
EndIf 

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64VldVei
Validação Veículo PamCard / PAGBEM 
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.130
@param cCodVei
@return lRet
*/
//-------------------------------------------------------------------
Function TF64VldVei(cCodVei)
Local lRet      	:= .T. 
Local aArea			:= GetArea()
Local lFrotaProp	:= .F.
Local lPagBem 		:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0 

Default cCodVei     := ""

lFrotaProp := IsFrotaPro(cCodVei)

If FwFldGet("DM5_CODOPE") == CODIGO_PAMCARD .And. !lFrotaProp .And. !Empty(cCodVei)
	lRet    := VldRNTNC( cCodVei )
Else
	If FwFldGet("DM5_CODOPE") == CODIGO_PAGBEM .And. !lFrotaProp .And. !Empty(cCodVei) .And. lPagBem
		lRet	:= VldVeiPgBE(cCodVei ) //--> Integração TMS x PAGBEM 
	EndIf 
EndIf

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldRNTNC
Valida RNTC
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRNTNC( cCodVei )
Local lRet			:= .T. 
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->( GetArea() )
Local aLojForDA3	:= {} 
Local cCodForn		:= ""
Local cLojForn		:= ""
Local lFrotaProp	:= .F.

Default cCodVei		:= ""

aLojForDA3	:= RetCodForn(cCodVei)

If Len(aLojForDA3) > 0 .And. !Empty(aLojForDA3[1]) .And. !Empty(aLojForDA3[2])
	cCodForn	:= aLojForDA3[1]
	cLojForn	:= aLojForDA3[2]
	lFrotaProp 	:= IsFrotaPro(cCodVei)
	
	SA2->( dbSetOrder(1) )
	If !lFrotaProp .And. SA2->( MsSeek( xFilial("SA2") + cCodForn + cLojForn ))
		lRet := PamFdRNTRC(cCodForn, cLojForn)

		If !lRet 
			Help("",1,"TMSA24065") //'RNTRC Inválido no Sistema Pamcard!!!'
		EndIf 
	Else 
		Help("",1,"TMSA24067" )//--O Proprietário do veículo não foi encontrado no cadastro de Fornecedores!
		lRet	:= .F. 
	EndIf 
Else
	Help("",1,"TMSA24067" )//--O Proprietário do veículo não foi encontrado no cadastro de Fornecedores!
	lRet	:= .F. 
EndIf 

FwFreeArray(aLojForDA3)
RestArea( aAreaSA2 )
RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} RetCodForn
Retorna código/loja do proprietario do veiculo
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//------------------------------------------------------------------
Static Function RetCodForn(cCodVei)
Local aAreaDA3	:= DA3->( GetArea() )
Local cCodForn	:= ""
Local cLojForn	:= ""

Default cCodVei	:= ""

DA3->( dbSetOrder(1) )
If DA3->( MsSeek( xFilial("DA3") + cCodVei ))
	cCodForn	:= DA3->DA3_CODFOR
	cLojForn	:= DA3->DA3_LOJFOR
EndIf 

RestArea( aAreaDA3 )
Return { cCodForn , cLojForn } 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64PerAdi
Valida percentual de adiantamento
@type Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Function TF64PerAdi( cCodVei , nPerAdi )
Local lRet			:= .T. 
Local cDesADF  		:= SuperGetMv("MV_DESADF",,"")

Default cCodVei		:= ""
Default nPerAdi		:= 0 

If nPerAdi > 0 

	If Empty(cDesADF)
		//-- "Fornecedor configurado com um percentual de adiantamento e o parâmetro MV_DESADF encontra-se sem preenchimento." 
		//-- "Preencher o parâmetro MV_DESADF com o código da despesa relativa ao Adiantamento de frete de Carreteiro."   
		lRet	:= .F. 
		Help('',1,'TMSAF6410') 
	EndIf 

	If lRet
		lRet	:= VldContr(cCodVei)
	EndIf

EndIf 

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldContr
Valida contrato do fornecedor
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldContr(cCodVei)
Local lRet			:= .T. 
Local aContrFor		:= {}
Local aLojForDA3	:= {}
Local cCodForn		:= ""
Local cLojForn		:= ""
Local cTipVei		:= ""
Local cSerTms		:= ""
Local cTipTra 		:= ""
Local cTipOpVg		:= ""

Default cCodVei	:= ""

aLojForDA3	:= RetCodForn(cCodVei)

If Len(aLojForDA3) > 0 .And. !Empty(aLojForDA3[1]) .And. !Empty(aLojForDA3[2])
	cSerTms		:= FwFldGet("DTQ_SERTMS")
	cTipTra		:= FwFldGet("DTQ_TIPTRA")
	cTipOpVg	:= FwFldGet("DTQ_TPOPVG")
	cCodForn	:= aLojForDA3[1]
	cLojForn	:= aLojForDA3[2]
	cTipVei		:= Posicione("DA3",1,xFilial("DA3") + cCodVei , "DA3_TIPVEI")

	aContrFor	:= TMSContrFor(cCodForn,cLojForn,,cSerTms,cTipTra,.F., cTipVei ,cTipOpVg)
	
	If Len(aContrFor) == 0 .Or. Empty(aContrFor)
		aContrFor	:= TMSContrFor(cCodForn,cLojForn,,cSerTms,cTipTra,.F., "" ,cTipOpVg)
	EndIf 

	If Len(aContrFor) == 0 .Or. Empty(aContrFor)
		lRet	:= .F. 

	//-- Momento Geração Adiantamento, somente permitido Fechamento e ou Geração CTC
	ElseIf Len(aContrFor) > 0 .And. (Empty(aContrFor[1][13]) .Or. aContrFor[1][13] == '0') 
		
		//-- 'Contrato do fornecedor configurado com o 'Momento da geração do adiantamneto' (DUJ_TITADI) invalido para calculo do percentual de adiantamento.
		//-- "No contrato do fornecedor, configure o campo com as opções 1 ou 2 para uso do percentual de adiantamento."
		lRet := .F.
		Help('',1,'TMSAF6411') 
	EndIf
Else
	lRet	:= .F. 
EndIf 

FwFreeArray( aContrFor )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldTpSPDG
Valida tipo pagamento pedagio
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldTpSPDG( cTpSpdg )
Local lRet		:= .T. 

Default cTpSpdg	:= ""

If Empty(cTpSpdg)
	lRet	:= .F. 
	Help(' ', 1, 'TMSA24069') //-- É necessário informar o Tipo do Pagto do Pedágio para integração com Pamcard.//--Informe o campo Tp Pgt Pedag
EndIf 

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldPamDLD
Valida DLD
@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPamDLD(oModel,cCodVei,nVlrPdg,nVlrAdto)
Local lRet		:= .T. 
Local aArea		:= GetARea()
Local aAreaDLD	:= DLD->(GetArea())
Local aSaveLine	:= FWSaveRows()
Local oMdlDLD	:= Nil
Local nAux		:= 1 
Local cIdOpe	:= ""
Local cForPag	:= ""
Local cRecebAdto:= ""
Local cForPgAdto:= ""
Local cIdOpAdto := ""
Local cRecebSld := ""
Local cForPgSld := ""
Local cIdOpSld  := ""
Local lTpParAdt := .F.
Local lTpParSld := .F.
Local lTpParPdg := .F.
Local cCodFav   := ""

Default oModel		:= FWModelActive()
Default cCodVei		:= ""
Default nVlrPdg		:= 0 
Default nVlrAdto    := 0

	oMdlDLD		:= oModel:GetModel("MdGridDLD")

	For nAux := 1 To oMdlDLD:Length()
		oMdlDLD:GoLine(nAux)
		If !oMdlDLD:IsDeleted()
	
			cIdOpe	:= oMdlDLD:GetValue("DLD_IDOPE")
			cForPag	:= oMdlDLD:GetValue("DLD_FORPAG")
			cReceb  := oMdlDLD:GetValue('DLD_RECEB')
			
			If lRet   
				If oMdlDLD:GetValue('DLD_TIPPAR') == "1"  //Adiantamento
					cRecebAdto:= cReceb
					cForPgAdto:= cForPag
					cIdOpAdto := cIdOpe
					lTpParAdt:= .T.
					lTpParPdg:= .F.
									
				ElseIf oMdlDLD:GetValue('DLD_TIPPAR') == "2"  //Saldo Frete
					cRecebSld:= cReceb
					cForPgSld:= cForPag
					cIdOpSld := cIdOpe
					lTpParSld:= .T.
					lTpParPdg:= .F.

				ElseIf oMdlDLD:GetValue('DLD_TIPPAR') == "3"  //Pedagio
					lTpParPdg:= .T.
					cCodFav := oMdlDLD:GetValue('DLD_CODFAV') 
				EndIf
			EndIf

			If nVlrPdg	> 0	 .And. lTpParPdg //Valida Parcela de Pedágio		
				cForPag	:= oMdlDLD:GetValue("DLD_FORPAG")  //1-Cartao,2-Deposito,3-TAG
				lRet	:= VldFormPg(cCodVei,cForPag,cReceb)
				
				If lRet
					lRet	:= VldIdOpe(cCodVei,cIdOpe,cForPag)
				EndIf

			EndIf
			If !lRet
				Exit
			EndIf

		EndIf
	Next nAux

	If lRet
	 	lRet:= VldTipPar(lTpParAdt,cRecebAdto,cForPgAdto,cIdOpAdto,lTpParSld,cRecebSld,cForPgSld,cIdOpSld,;
					lTpParPdg,cCodFav,nVlrAdto)
	EndIf
	

FWRestRows(aSaveLine)
RestArea(aAreaDLD)
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} VldFormPg
Valida forma de pagamento
@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldFormPg(cCodVei,cForPag,cReceb)
Local lRet		:= .T. 
Local lLotacao	:= .F. 

Default cCodVei	:= ""
Default cForPag := ""
Default cReceb  := ""

lLotacao	:= IsLotacao(cCodVei)

//-- Quando Lotacao, dados do cartao nao é Obrigatorio
If !lLotacao   
	If !(cForPag $ '13')  //1-Cartao, 3-TAG
		Help( ' ', 1, 'TMSAF6418') //-- A forma de pagamento da parcela de pedagio deve ser Cartão ou Tag.
		lRet	:= .F.
	EndIf
EndIf

If lRet
	If cForPag == '3' .And. cReceb <> '1' 
		Help( ' ', 1, 'TMSAF6419') //-- Recebedor inválido para  pagamento da parcela de Pedagio via TAG. Informe o recebedor como 'Proprietario'.
		lRet	:= .F.
	EndIf
EndIf

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldIdOpe
Valida cartão ID OPE
@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldIdOpe(cCodVei,cIdOpe,cForPag)
Local lRet		:= .T. 
Local lLotacao	:= .F. 

Default cCodVei	:= ""
Default cIdOpe	:= ""
Default cForPag := ""

lLotacao	:= IsLotacao(cCodVei)

If !lLotacao  
	If Empty(cIdOpe)  .And. !(cForPag = '3')
		Help('', 1, "TMSA24064") //'Viagem com valor de pedágio.', 'Informe um Cartão para o motorista!!'
		lRet := .F.
	EndIf
EndIf	

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} IsLotacao
Verifica se é uma viagem do tipo Lotação
@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function IsLotacao( cCodVei )
Local aArea			:= GetArea()
Local lLotacao 		:= .F. 
Local lUmDocVge		:= .F. 
Local lFrotaProp	:= .F. 

Default cCodVei		:= ""

If PamQtDocVg( FwFldGet("DTQ_FILORI") , FwFldGet("DTQ_VIAGEM") , FwFldGet("DTQ_SERTMS") ) == 1
	lUmDocVge:= .T.						
EndIf

lFrotaProp := IsFrotaPro(cCodVei)

If lFrotaProp .And. lUmDocVge
	lLotacao:= .T.						
EndIf

RestArea(aArea)
Return lLotacao 

//-------------------------------------------------------------------
/*{Protheus.doc} IsFrotaPro
Verifica se é frota propria
@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function IsFrotaPro(cCodVei)
Local lRet		:= .F. 
Local aAreaDA3	:= DA3->( GetArea() )

Default cCodVei		:= ""

DA3->( dbSetOrder(1) )
If DA3->( MsSeek( xFilial("DA3") + cCodVei )) .And. DA3->DA3_FROVEI == "1"
	lRet	:= .T. 
EndIf 

RestArea(aAreaDA3)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldPamDJL
Validações DJL

@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPamDJL(cCodVei)
Local aArea		:= GetArea()
Local aAreaDJL	:= DJL->(GetArea())
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local lRet		:= .T. 

Default cCodVei	:= ""

cQuery := " SELECT DJL_CIOT "
cQuery += " FROM " + RetSqlName("DJL") + " DJL "
cQuery += " WHERE   DJL_FILIAL = '"  + xFilial("DJL") +"'"
cQuery += " AND  	DJL_CODVEI = '"	 + cCodVei +"'" 
cQuery += " AND    	DJL_STATUS = '"	 + StrZero(1,Len(DJL->DJL_STATUS))+"'" 
cQuery += " AND    	DJL_DATINI <= '" + DtoS(dDataBase)+"'" 
cQuery += " AND    	DJL_DATFIM >= '" + DtoS(dDataBase)+"'" 
cQuery += " AND     DJL.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof() .And. !Empty((cAliasQry)->DJL_CIOT))
	Help('',1,"TMSA24089") //-- "O veículo possui CIOT por período em Aberto. Não é possível gerar CIOT por viagem"
	lRet:= .F.
EndIf
(cAliasQry)->(DbCloseArea())

RestArea(aAreaDJL)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64PamSDG
Validações SDG

@type Static Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Function TF64PamSDG( oModel, cCodOpe, nVlrAdto )
Local aArea		:= GetArea()
Local aAreaSDG	:= SDG->(GetArea())
Local aSaveLine	:= FWSaveRows()
Local lRet		:= .T. 
Local oMdlSDG	:= Nil 
Local nAux		:= 1 
Local nVlBaixa  := 0

Default oModel		:= FWModelActive()
Default cCodOpe		:= ""
Default nVlrAdto    := 0

oMdlSDG		:= oModel:GetModel("MdGridSDG")

For nAux := 1 To oMdlSDG:Length()
	oMdlSDG:Goline(nAux)

	If !oMdlSDG:IsDeleted()
		lRet	:= TF64SDGDeg( cCodOpe , oMdlSDG:GetValue("DG_BANCO"), oMdlSDG:GetValue("DG_AGENCIA"), oMdlSDG:GetValue("DG_NUMCON") )
		
		If lRet
			nVlBaixa:= oMdlSDG:GetValue("DG_VALCOB")  - oMdlSDG:GetValue("DG_SALDO")	
			nVlrAdto+= nVlBaixa
		Else
			Exit
		EndIf
	EndIf

Next nAux

FWRestRows(aSaveLine)
RestArea(aAreaSDG)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64SDGDeg
Validações SDG X DEG

@type Function
@author Caio Murakami
@since 17/08/2020
@version 12.1.30
@param  cCodOpe , cBanco, cAgencia, cNumCon 
@return lRet
*/
//------------------------------------------------------------------
Function TF64SDGDeg( cCodOpe , cBanco, cAgencia, cNumCon )
Local aAreaDEG		:= DEG->(GetArea())
Local lRet          := .T.

Default cCodOpe		:= ""
Default cBanco		:= ""
Default cAgencia	:= ""
Default cNumCon		:= ""

If !Empty(cBanco)
	DEG->(DbSetOrder(1)) //-- DEG_FILIAL+DEG_CODOPE
	If DEG->(MsSeek(xFilial('DEG') + cCodOpe ))
		If DEG->(DEG_BANCO+DEG_AGENCI+DEG_NUMCON) <> cBanco + cAgencia + cNumCon 
			lRet	:= .F. 
			Help("",1,"TMSA24084") //-- "Existe despesa apontada em Banco/Ag/Cta divergente ao da Operadora."
		EndIf
	EndIf
EndIf

RestArea(aAreaDEG)
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} IsDLDEmpty
Validações para verifricar se a DLD está preenchida

@type Function
@author Caio Murakami
@since 18/08/2020
@version 12.1.30
@param  cCodOpe , cBanco, cAgencia, cNumCon 
@return lRet
*/
//------------------------------------------------------------------
Static Function IsDLDEmpty( oModel )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local aSaveLine	:= FWSaveRows()
Local oMdlDLD	:= Nil 
Local cTMSOPdg  := SuperGetMV( 'MV_TMSOPDG',, '0' )
Local nAux		:= 0 

Default oModel		:= FWModelActive()

If cTMSOPdg <> "0"

	oMdlDLD		:= oModel:GetModel("MdGridDLD")

	For nAux := 1 to oMdlDLD:Length()
		oMdlDLD:GoLine(nAux)
		If !oMdlDLD:IsDeleted()
			If !Empty( oMdlDLD:GetValue("DLD_IDOPE") ) 
				Help('',1,'TMSAF6407') //-- A Forma de Pagamento só deve ser utilizada para viagens que estejam utilizando a operadora Pamcard.  
				lRet	:= .F. 
				Exit
			EndIf 
		EndIf
	Next nAux 

EndIf

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet	

/*{Protheus.doc} PamMotTOk
Valida a Tudo Ok do Motorista Pamcard
@type Function
@author Katia
@since 14/08/2020
@version 12.1.30
@return lRet
Função extraida do TMSA240 -  AMOTTUDOK()
*/
Function PamMotTOk(oModel,cCodVei,lValida) 
Local aAreas     := {DA3->(GetArea()),DA4->(GetArea()),SA2->(GetArea()),GetArea()}
Local cCodFor    := ""
Local cLojFor    := ""
Local lFavorec   := .T.
Local cTipoCGC   := ''
Local cRNTRC	 := ''
Local cQtdeDoc   := 0
Local lFrotaProp := .F.
Local aRetCNPJ   := {}
Local aConsCard  := {}
Local lRet       := .T.
Local lFindFav    := .T.
Local aFindFav    := {}
Local aInsFav     := {}

Default oModel   := FwModelActive() 
Default cCodVei  := FwFldGet("DTR_CODVEI")  
Default lValida  := .F.  //Funcionalidade do aMotTudOk(), com a validação do Favoredido e IdOpe

lFrotaProp := IsFrotaPro(cCodVei)

	If FwFldGet('DUP_CONDUT') == '1'  
		DA4->( DbSetOrder(1) )
		DA4->( DbSeek( xFilial('DA4')+FwFldGet('DUP_CODMOT') ) )  

		// Valida se existe um Favorecido para o proprietario do veiculo e ou no SA2
		DA3->(dbSetOrder(1))
		DA3->(DbSeek(xFilial('DA3') + cCodVei))
		If !Empty(DA3->DA3_CODFAV) .And. !Empty(DA3->DA3_LOJFAV)
			cCodFor := DA3->DA3_CODFAV
			cLojFor := DA3->DA3_LOJFAV
			lFavorec:= .F.
		Else
			cCodFor := DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
		EndIf

		//Posicionar na tabela de Fornecedores - SA2
		SA2->( DbSetOrder(1) )                      		
		If SA2->( !DbSeek(xFilial("SA2") + cCodFor + cLojFor ) )
			Help(' ', 1, 'TMSA24061') //'Não foi encontrado fornecedor', 'para este motorista.'
			lRet := .F.
		ElseIf lFavorec .And. !Empty(SA2->A2_CODFAV) .And. !Empty(SA2->A2_LOJFAV)
			If SA2->( !DbSeek(xFilial("SA2") + SA2->(A2_CODFAV+A2_LOJFAV) ) )                  
				Help(' ', 1, 'TMSA24061') //'Não foi encontrado fornecedor', 'para este motorista.'
				lRet := .F.			
			EndIf                                                                              
		EndIf

		If lRet
			If SA2->A2_TIPO == 'F'
				cTipoCGC := "2"
				cQtdeDoc := "3"
				cRNTRC   := "5"
			ElseIf SA2->A2_TIPO == 'J'
				cTipoCGC := "1"
				cQtdeDoc := "2"
				cRNTRC   := "6"
			Else
				Help(' ', 1, 'TMSA24062') //'O tipo do fornecedor está preenchido incorretamente na tabela de Fornecedores.'
				lRet := .F.
			EndIf
		EndIf

		//--- Funcionalidade existente no DUP_IDOPE
		If lValida .And. lRet
			If !lFrotaProp 
				aRetCNPJ := PamCNPJEmp('02', cFilAnt)

				AAdd (aFindFav,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
				AAdd (aFindFav,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
				AAdd (aFindFav,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
				AAdd (aFindFav,{'viagem.favorecido.documento.tipo', cTipoCGC} )
				AAdd (aFindFav,{'viagem.favorecido.documento.numero', AllTrim(SA2->A2_CGC) })

				If cTipoCGC == "1" .And. !Empty(DA4->DA4_CGC)
					AAdd (aFindFav,{'viagem.favorecido.documento.tipo', '2' } )
					AAdd (aFindFav,{'viagem.favorecido.documento.numero', AllTrim(DA4->DA4_CGC) })
				EndIf

				lFindFav := PamFindFav(aFindFav)

				If !lFindFav

					AAdd (aInsFav,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
					AAdd (aInsFav,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
					AAdd (aInsFav,{'viagem.unidade.documento.numero', aRetCNPJ[3]} )
					AAdd (aInsFav,{'viagem.favorecido.documento.qtde', cQtdeDoc } )
					AAdd (aInsFav,{'viagem.favorecido.documento1.tipo', cTipoCGC } )
					AAdd (aInsFav,{'viagem.favorecido.documento1.numero', AllTrim(SA2->A2_CGC) } )
					AAdd (aInsFav,{'viagem.favorecido.documento2.tipo', cRNTRC } )
					AAdd (aInsFav,{'viagem.favorecido.documento2.numero', AllTrim(SA2->A2_RNTRC) } )

					If cTipoCGC == "2"
						AAdd (aInsFav,{'viagem.favorecido.documento3.tipo', '3' } )
						AAdd (aInsFav,{'viagem.favorecido.documento3.numero', AllTrim(DA4->DA4_RG) })
						AAdd (aInsFav,{'viagem.favorecido.documento3.uf', AllTrim(DA4->DA4_RGEST) })
					EndIf

					AAdd (aInsFav,{'viagem.favorecido.nome', AllTrim(SA2->A2_NOME) } )
					AAdd (aInsFav,{'viagem.favorecido.data.nascimento', SubStr(DtoS(DA4->DA4_DATNAS),7,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),5,2) + '/' + SubStr(DtoS(DA4->DA4_DATNAS),1,4) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.logradouro', AllTrim(SA2->A2_END) })
					AAdd (aInsFav,{'viagem.favorecido.endereco.numero', '1'} )
					AAdd (aInsFav,{'viagem.favorecido.endereco.bairro', AllTrim(SA2->A2_BAIRRO) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.cidade.ibge', TMS120CDUF(SA2->A2_EST, '1') + AllTrim(SA2->A2_COD_MUN) } )
					AAdd (aInsFav,{'viagem.favorecido.endereco.cep', AllTrim(SA2->A2_CEP) } )
					AAdd (aInsFav,{'viagem.favorecido.telefone.ddd', StrZero(Val(SA2->A2_DDD),3) } )
					AAdd (aInsFav,{'viagem.favorecido.telefone.numero', AllTrim(StrTran(SA2->A2_TEL,"-","")) } )

					lRet := PamInsFav(aInsFav)
				EndIf
			EndIf
			
			If lRet
				lRet:= VldIdDLD(lFrotaProp,FwFldGet("DUP_CONDUT"),FwFldGet("DUP_TIPMOT"),FwFldGet("DUP_CODMOT"),;
				FwFldGet("DUP_NOMMOT"))
			EndIf
		
		EndIf
	EndIf	

FwFreeArray(aRetCNPJ)
FwFreeArray(aConsCard)
FwFreeArray(aRetCNPJ)
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet


/*{Protheus.doc} PamDLDLok
Valida a Linha Ok da DLD
@type Function
@author Katia
@since 14/08/2020
@version 12.1.30
@return lRet
Função extraida do TMSA240 -  TA240LLinOk()
*/
Function PamDLDLok()
Local lRet       := .T.
Local aRetCNPJ   := {}
Local cCodMot    := ""
Local cInValePdg := '4198'
Local aMotCiot   := {}
Local aConsCard  := {}
Local aConsTag   := {}
Local aSaveLine	 := FWSaveRows()
Local oModel     := FwModelActive()
Local oMdGridDUP := oModel:GetModel('MdGridDUP')
Local oMdGridDTR := oModel:GetModel('MdGridDTR')
Local nCount     := 0
Local aAreas     := {DA3->(GetArea()),DA4->(GetArea()),GetArea()}

If lRet 
	aRetCNPJ   := PamCNPJEmp(CODIGO_PAMCARD, M->DTQ_FILORI) //Função para obter CNPJ da contrante e filial de origem 
	//-- Montagem Array para Integração com PamCard
	AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
	AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
	AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
	AAdd(aConsCard,{'viagem.cartao.numero',AllTrim(FwFldGet("DLD_IDOPE"))} )
	
	If FwFldGet("DLD_RECEB") == '2' //Motorista	
		If oMdGridDTR:GetValue('DTR_TPCIOT') == '2' .Or. AllTrim(FwFldGet("DLD_FORPAG")) == '1' //Só valida se for CIOT por periodo ou pagamento com cartão

			For nCount:= 1 To oMdGridDUP:Length()
				oMdGridDUP:GoLine(nCount)
				If !oMdGridDUP:IsEmpty() .And. !oMdGridDUP:IsDeleted()
					cCodMot := oMdGridDUP:GetValue('DUP_CODMOT')
												
					If oMdGridDUP:GetValue('DUP_CONDUT') == "1" //Condutor principal
						cCiotPer := TmsCiotPer(oMdGridDTR:GetValue("DTR_CODVEI"))
						aMotCiot := TmsMotCiot(cCiotPer, cCodMot,FwFldGet("DLD_FORPAG"),FwFldGet("DLD_IDOPE"))
						If Len(aMotCiot) > 0 
							Help(' ', 1, 'TMSA24096') //-- Para viagens que possuem CIOT por período, por limitação da Operadora Pamcard, não é possível informar o Motorista como Recebedor.
							lRet := .F.
						EndIf											
								
						If lRet .And. AllTrim(FwFldGet("DLD_FORPAG")) == '1' //forma de pagamento cartão
							dbSelectArea("DA4")
							dbSetOrder(1)
							If MsSeek(xFilial("DA4")+cCodMot) .And. cInValePdg <> PADR(FwFldGet("DLD_IDOPE"),4)
								If !Empty(DA4->DA4_FORNEC)									
									lRet := PamFindCar(aConsCard,,.T.,,,DA4->DA4_FORNEC,DA4->DA4_LOJA)										
								Else
									lRet := PamFindCar(aConsCard, .T.)
								EndIf	
							EndIf							
						EndIf
					
						Exit
					EndIf				

				EndIf
			Next nCount			
			
		EndIf
	//Proprietario  //--Não fazer a chamada do método FindCard, quando o cartão for Vale Pedágio (4195)//--Já que este cartão não precisa estar cadastrado na Pamcard para ser utilizado.
    ElseIf AllTrim(FwFldGet("DLD_RECEB")) == '1' .And. AllTrim(FwFldGet("DLD_FORPAG")) == '1' .And. cInValePdg <> PADR(FwFldGet("DLD_IDOPE"),4) 
		If Empty(FwFldGet('DLD_CODFAV'))
			dbSelectArea("DA3")
			DA3->(dbSetOrder(1)) 
			If MsSeek(xFilial("DA3")+oMdGridDTR:GetValue('DTR_CODVEI')) .And. !Empty(DA3->DA3_CODFOR)
				lRet := PamFindCar(aConsCard,,.T.,,,DA3->DA3_CODFOR,DA3->DA3_LOJFOR)
			Endif
		Else
			lRet := PamFindCar(aConsCard,,.T.,,,FwFldGet('DLD_CODFAV'),FwFldGet('DLD_LOJFAV'))
		EndIf
	EndIf

	If AllTrim(FwFldGet("DLD_FORPAG")) == '3' 
		cIDTag     := PamIDTag( CODIGO_PAMCARD, oMdGridDTR:GetValue('DTR_CODVEI'))
		If !Empty(cIDTag) //Somente chama o FindTag se o Veiculo possuir TAG associada
			dbSelectArea("DA3")
			DA3->(dbSetOrder(1)) 
			If MsSeek(xFilial("DA3")+oMdGridDTR:GetValue('DTR_CODVEI')) 
				aRetCNPJ   := PamCNPJEmp( CODIGO_PAMCARD, M->DTQ_FILORI ) //Função para obter CNPJ da contrante e filial de origem 
					//-- Montagem Array para Integração com PamTag
					AAdd(aConsTag,{'tag.contratante.documento.numero', aRetCNPJ[1]})
					AAdd(aConsTag,{'tag.placa'                       , AllTrim(DA3->DA3_PLACA)})
					AAdd(aConsTag,{'tag.numero'    					 , }) 
					AAdd(aConsTag,{'favorecido.documento.tipo'       ,  } )
					AAdd(aConsTag,{'favorecido.documento.numero'     , } )
					AAdd(aConsTag,{'tag.emissor.id'                  , cIDTag} )

					FWMsgRun(, {|| lRet := PamFindTag(aConsTag) }, STR0008, STR0014 ) //"Processando a validação da TAG junto a PAMCARD..."	
			EndIf
		Else
			Help( ' ', 1, 'TMSAF6420')//Veículo principal da viagem não possui associação de TAG.Altere a forma de pagto pedagio através do campo 'Forma Pagto', tela Formas Pagto ou relacione uma TAG ao veículo através do cadastro de Veículos(OMSA060).
			lRet := .F.	
		EndIf
	EndIf
EndIf

If lRet
	If AllTrim(FwFldGet("DLD_TIPPAR")) == '3' .And.  !AllTrim(FwFldGet("DLD_FORPAG")) $ '13'    //1-Cartao , 3-TAG
		Help( ' ', 1, 'TMSA240A4') //A forma de pagamento da parcela de pedagio deve ser Cartão.
		lRet:= .F.
	EndIf
EndIf

FwRestRows(aSaveLine)
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet

/*{Protheus.doc} VldTipPar
Valida os Tipos de Parcelas do Pagamento (DLD)
@type Function
@author Katia
@since 18/08/2020
@version 12.1.30
@param 
@return lRet
Função extraida do TMSA240 -  TA240TudOk()
*/
Static Function VldTipPar(lTpParAdt,cRecebAdto,cForPgAdto,cIdOpAdto,lTpParSld,cRecebSld,cForPgSld,cIdOpSld,;
					lTpParPdg,cCodFav,nVlrAdto)

Local lRet:= .T.

Default lTpParAdt:= .F.
Default cRecebAdto:= ""
Default cForPgAdto:= ""
Default cIdOpAdto := ""
Default lTpParSld := .F.
Default cRecebSld := ""
Default cForPgSld := ""
Default cIdOpSld  := ""
Default lTpParPdg := .F.
Default cCodFav   := ""

If !lTpParSld
	Help(' ', 1, 'TMSA24094') //-- Nao foi informado tipo de parcela saldo de frete
	lRet:= .F.
EndIf
		
//--- Tipo de Parcela -  Adiantamento
If lRet .And. (nVlrAdto > 0 .And. !lTpParAdt)
	Help(' ', 1, 'TMSA24095') //-- Nao foi informado tipo de parcela adiantamento
	lRet:= .F.
EndIf
	
Return lRet

/*{Protheus.doc} TF64VlId
Valida o Id. do Motorista junto a Operadora de Frotas
@type Function
@author Katia
@since 14/08/2020
@version 12.1.30
@param cCodOpe, cIdOpe,  cTipMot, cCodMot
@return lRet
Função extraida do TMSA240 -  TMS240VlId()
*/
Function TF64VlId(cCodOpe, cIdOpe,  cTipMot, cCodMot)
Local aAreas      := {DA4->(GetArea()),GetArea()}
Local lRet      := .T.
Local aConsCard := {}
Local cCodFor 	 := ""
Local cLojFor	 := ""
Local lRespCart := .F.
Local cInValePdg:= '4198'

DEG->( DbSetOrder(1) )
If DEG->( MsSeek(xFilial('DEG') + cCodOpe) )
	aRetCNPJ := PamCNPJEmp(cCodOpe, cFilAnt) //Função para obter CNPJ da contrante e filial de origem
	
	//-- Montagem Array para Integração com PamCard
	AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
	AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
	AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
	AAdd(aConsCard,{'viagem.cartao.numero', cIdOpe } )
		
	//Verifica os dados do fornecedor portador do cartão(conceito novo) ou do fornecedor do motorista(conceito antigo)
	DDQ->(dbSetOrder(1))	
	If DDQ->(MsSeek(xFilial('DDQ')+cIdOpe))
		cCodFor   := DDQ->DDQ_CODFOR
		cLojFor   := DDQ->DDQ_LOJFOR
		lRespCart := .T.
    Else                                     
        DA4->( DbSetOrder(1) )
		If DA4->( MsSeek(xFilial("DA4") + cCodMot, .F. ))
            cCodFor := DA4->DA4_FORNEC
            cLojFor := DA4->DA4_LOJA
        EndIf	
	EndIf      
		
	lRet := PamVldFor(cCodFor, cLojFor, lRespCart) //Valida dados do contratado
	
    If !lRet .And. lRespCart
		Help('',1,'TMSA240A5',,,6,0) //"RNTRC não foi informado para o fornecedor"

	ElseIf !lRet
		Help('',1,'OMSA04009',,,6,0) //"Itens obrigatorios para inclusão não foram preenchidos na tabela de Fornecedores"

	ElseIf lRet .And. !Empty(cIdOpe) .And. cInValePdg <> Padr(cIdOpe,4)	 				
		If !PamFindCar(aConsCard, .T.) //-- Montagem Array Pamcard - Inserir Cartão Portador Frete - InsertCardFreight  
			lRet := PamInsCtPF(aRetCNPJ, cCodFor, cLojFor, cIdOpe, lRespCart)
		EndIf	
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return( lRet )


//-------------------------------------------------------------------
/*{Protheus.doc} VldPamDUP
Valida DUP
@type Static Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPamDUP(oModel,cCodVei)
Local lRet		:= .T. 
Local aArea		:= GetARea()
Local oMdlDUP	:= Nil
Local nOpc      := 0

Default oModel	 := FWModelActive()
Default cCodVei	 := ""

oMdlDUP:= oModel:GetModel("MdGridDUP")
nOpc   := oMdlDUP:GetOperation()

	If nOpc == 3 .Or. nOpc == 4	
		cCodMot:= TF64PMotor(oModel)

		If !Empty(cCodMot)	
			//Executa apenas para 1 Condutor Principal
			lRet:= PamMotTOk(oModel,cCodVei,.T.) 
		Else
			Help('', 1, "TMSAF6408") //Necessário informar um Condutor Principal para a viagem.
			lRet:= .F.
		EndIf
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} VldIdDLD
Validação do Id Motorista e Fornecedor (DUP_IDOPE antigo)
@type Static Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldIdDLD(lFrotaProp,cCondut,cTipMot,cCodMot,cNomMot,oModel)
Local nAux2    := 0
Local oMdlDLD  := Nil
Local lRet     := .T.
Local aRetCNPJ := {}
Local cTipoCGC := ""
Local aFindAcc := {}
Local lFindAcc := .T.
Local aArea	   := GetARea()
Local aSaveLine	:= FWSaveRows()

Default oModel:= FwModelActive()

oMdlDLD:= oModel:GetModel("MdGridDLD")

For nAux2:= 1 To oMdlDLD:Length()
	oMdlDLD:GoLine(nAux2)
	If !oMdlDLD:IsDeleted()
		
		If (lFrotaProp .And. AllTrim(FwFldGet('DLD_FORPAG')) <> '1')
			Help('', 1, 'TMSA24063') //'Veículos de Frota Própria só poderão', 'ter viagens com meio de pagamento', '1=Cartão!'
			lRet := .F.
		Else
			/*If AllTrim(FwFldGet('DLD_FORPAG')) == '1' 						
				If cCondut == '1' 
					FwMsgRun( ,{||lRet := TF64VlId(M->DM5_CODOPE,;
					AllTrim(FwFldGet('DLD_IDOPE')),;
					AllTrim(cTipMot),;
					AllTrim(cCodMot))} , STR0007  + cNomMot , STR0008 ) //"Validando Id do Motorista:"
				EndIf
			EndIf*/
						
			If lRet .And. AllTrim(FwFldGet('DLD_FORPAG')) == '2' 													
				If !Empty(SA2->A2_BANCO) .And. !Empty(SA2->A2_AGENCIA) .And. !Empty(SA2->A2_NUMCON) .And. !Empty(SA2->A2_TPCONTA)
					aRetCNPJ := PamCNPJEmp('02', cFilAnt)
								
					If SA2->A2_TIPO  == 'F'
						cTipoCGC := "2"
					Else
						cTipoCGC := "1"
					EndIf

					AAdd (aFindAcc,{'viagem.contratante.documento.numero',aRetCNPJ[1]} )
					AAdd (aFindAcc,{'viagem.unidade.documento.tipo', aRetCNPJ[2] })
					AAdd (aFindAcc,{'viagem.unidade.documento.numero', aRetCNPJ[3]} ) 
					AAdd (aFindAcc,{'viagem.favorecido.documento.tipo', cTipoCGC} )
					AAdd (aFindAcc,{'viagem.favorecido.documento.numero', AllTrim(SA2->A2_CGC) })
					AAdd (aFindAcc,{'viagem.favorecido.conta.banco', AllTrim(SA2->A2_BANCO) } )
					AAdd (aFindAcc,{'viagem.favorecido.conta.agencia', AllTrim(SA2->A2_AGENCIA) } )
					AAdd (aFindAcc,{'viagem.favorecido.conta.numero', AllTrim(SA2->A2_NUMCON) + AllTrim(SA2->A2_DVCTA) } )
					AAdd (aFindAcc,{'viagem.favorecido.conta.tipo', AllTrim(SA2->A2_TPCONTA) } )
								
					lFindAcc := PamFindAcc(aFindAcc)
								
					If !lFindAcc
						PamInsAcc(aFindAcc)
					EndIf	 
				Else
					Help(' ', 1, 'TMSA24060') //'Não foi encontrado Banco, Agência', 'e Conta Corrente para este motorista.'
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Next nAux2

RestArea(aArea)
FwRestRows(aSaveLine)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TM64PCard
Consulta F3( DDQDEL ) para obter os Cartoes atraves da tabela DEL e DDQ  
@type Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param 
@return 
Função retirada do fonte TMSA240.PRW (TM240Card)
*/
//-------------------------------------------------------------------
Function TM64PCard()

Local aArea     := GetArea()
Local aAreaDUP  := DUP->(GetArea())
Local aAreaDA3  := DA3->(GetArea())
Local aAreaDA4  := DA4->(GetArea())
Local cAliasQry := ''
Local cQuery    := ''
Local aCodFav	:= {}
Local aFornec   := {}
Local nCount    := 0  
Local aCartoes  := {}   
Local aTitulo	:= {}
Local aRet		:= {}
Local nPosID    := 0
Local cRecebedor:='2'
Local cCodMot	:= ""
Local cCampo	:= ReadVar()
Local cCodReceb := ""
Local cCodVei	:= ""
Local cCodOpe	:= ""
Local lRet 		:= .T.
Local cFilVgeDTR:= ""
Local cVgeDTR   := ""
Local aLojForDA3:= {}
Local aLojForDA4:= {}
Local cCdForDA3 := ""
Local cCdForDA4 := ""
Local cCodForn  := ""
Local cLojForn  := ""

If cCampo $ 'M->DLD_IDOPE'
	cCodReceb 	:= FwFldGet("DLD_RECEB")
	cCodVei 	:= FwFldGet("DTR_CODVEI")
	cCodOpe		:= FwFldGet("DM5_CODOPE")
	cFilVgeDTR  := FwFldGet("DM5_FILORI")
	cVgeDTR     := FwFldGet("DM5_VIAGEM")
	If Empty(cCodReceb)
		lRet := .F.
		Help( ' ', 1, 'TMSA240A3', , ,5 ,11) //-- Recebedor da parcela não informado
	EndIf

	If lRet
		If cCodReceb = '1'  //Proprietário   
			aLojForDA3:= RetCodForn(cCodVei)
			cRecebedor:= "1"
			
			If Len(aLojForDA3) > 0 .And. !Empty(aLojForDA3[1]) .And. !Empty(aLojForDA3[2])
				cCodForn:= aLojForDA3[1]
				cLojForn:= aLojForDA3[2]

				aCodFav := T250BscFav(cCodVei,cCodForn,cLojForn,cFilVgeDTR,cVgeDTR)
				If Len(aCodFav) > 0
					aAdd(aFornec, {aCodFav[1][1], aCodFav[1][2] })
				Else
					aAdd(aFornec, {cCodForn, cLojForn})
				EndIf
				cCdForDA3:= cCodForn+ cLojForn
			EndIf
		EndIf
        
		//-----
		cCodMot:= TF64PMotor()
		aLojForDA4:= RetForMot(cCodMot)
		If Len(aLojForDA4) > 0 .And. !Empty(aLojForDA4[1]) .And. !Empty(aLojForDA4[2])
			cCodForn:= aLojForDA4[1]
			cLojForn:= aLojForDA4[2]

			If cCodReceb = '2' //Motorista
				aAdd(aFornec, {cCodForn, cLojForn})
			EndIf	
			cCdForDA4:= cCodForn + cLojForn					
		EndIf

	EndIf
Else 
	cRecebedor:='2'
	cCodOpe:= M->DM5_CODOPE
	cCodMot:= TF64PMotor()
	
	aLojForDA3:= RetCodForn(cCodVei)			
	If Len(aLojForDA3) > 0 .And. !Empty(aLojForDA3[1]) .And. !Empty(aLojForDA3[2])
		cCodForn:= aLojForDA3[1]
		cLojForn:= aLojForDA3[2]

		aAdd(aFornec, {cCodForn, cLojForn })
	EndIf
EndIf

If lRet
	If Len(aFornec) > 0
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DDQ.DDQ_IDCART, DDQ.DDQ_STATUS, DDQ.DDQ_CODFOR, DDQ.DDQ_LOJFOR"
		cQuery += "	FROM " + RetSqlName("DDQ") + " DDQ "
		cQuery += "		WHERE "
		cQuery += "			DDQ.DDQ_FILIAL = '" + xFilial("DDQ") + "' AND "
		For nCount := 1 To Len(aFornec)
			If nCount > 1
				cQuery += " OR "
			EndIf
			cQuery += "		(DDQ.DDQ_CODFOR = '" + aFornec[nCount,1] + "' AND "
			cQuery += "		DDQ.DDQ_LOJFOR = '" + aFornec[nCount,2] +  "'	  ) "			
		Next
		cQuery += " 		AND DDQ.DDQ_STATUS IN ('1', '2') " 
		cQuery += " 	 	AND DDQ.D_E_L_E_T_ = ''"
			
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			
		While !(cAliasQry)->(EoF())	
			nPosID:= Ascan(aCartoes,{|x| AllTrim(x[3]) == Alltrim((cAliasQry)->DDQ_IDCART)})
			If nPosID = 0
				AAdd(aCartoes, {'02','POWERED BY PAMCARD',(cAliasQry)->DDQ_IDCART, (cAliasQry)->DDQ_STATUS,BSCXBOX('DEL_STATUS',(cAliasQry)->DDQ_STATUS),'','','',(cAliasQry)->DDQ_CODFOR,(cAliasQry)->DDQ_LOJFOR })
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		If !Empty(cCdForDA3) .And. !Empty(cCdForDA4)
			If cCdForDA3 == cCdForDA4
				cRecebedor:= "2"  //Lista os Motoristas quando Proprietario e Motorista sao iguais
			EndIf
		EndIf
	EndIf

	If cRecebedor == '2' 
		cAliasQry := GetNextAlias()
		cQuery := "SELECT DEL.DEL_CODMOT, DEL.DEL_IDOPE, DEL.DEL_STATUS, DEL_TIPOID, DEL_CODOPE"
		cQuery += "	FROM " + RetSqlName("DEL") + " DEL "
		cQuery += "		WHERE "
		cQuery += "			DEL.DEL_FILIAL = '" + xFilial("DEL") + "' AND "
		cQuery += "			DEL.DEL_CODMOT = '" + cCodMot + "' AND "
		cQuery += "			DEL.DEL_CODOPE = '" + cCodOpe + "'"
		If cCodOpe != "01"
			cQuery += "		AND DEL.DEL_STATUS IN ('1', '2') "
		EndIf 
		cQuery += "			AND  DEL.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		AAdd( aRet, {'01', 'REPOM TECNOLOGIA'   })
		AAdd( aRet, {'02', 'POWERED BY PAMCARD' })                                                                        

		While !(cAliasQry)->(EoF())	             
			nPos  := Ascan(aRet,{|x| AllTrim(x[1]) == (cAliasQry)->DEL_CODOPE})
			nPosID:= Ascan(aCartoes,{|x| AllTrim(x[3]) == Alltrim((cAliasQry)->DEL_IDOPE)})
			If nPosID = 0
				AAdd(aCartoes, {(cAliasQry)->DEL_CODOPE,aRet[nPos,2],(cAliasQry)->DEL_IDOPE, ;
					(cAliasQry)->DEL_STATUS,BSCXBOX('DEL_STATUS',(cAliasQry)->DEL_STATUS),(cAliasQry)->DEL_TIPOID,Tabela('ME', (cAliasQry)->DEL_TIPOID, .F.),(cAliasQry)->DEL_CODMOT,,})
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo		
	EndIf

	If Len(aCartoes) > 0        
		Aadd( aTitulo, RetTitle('DEL_CODOPE') )
		Aadd( aTitulo, RetTitle('DEL_NOMOPE') )
		Aadd( aTitulo, "Número do Cartão" ) //--'Numero Cartão'
		Aadd( aTitulo, RetTitle('DEL_STATUS') )
		Aadd( aTitulo, "Desc. Status") //--'Desc. Status '
		Aadd( aTitulo, RetTitle('DEL_TIPOID'))
		Aadd( aTitulo, "Desc. Tp. Id") //--'Desc. Tp. Id'
		Aadd( aTitulo, RetTitle('DEL_CODMOT'))
		Aadd( aTitulo, RetTitle('DDQ_CODFOR'))
		Aadd( aTitulo, RetTitle('DDQ_LOJFOR'))
		
		nItem := TmsF3Array( aTitulo, aCartoes, "Cartões Operadora de Frota", .T. ) //--'Cartoes Operadoras de Frota'
		
		If	nItem > 0
			//-- VAR_IXB eh utilizada como retorno da consulta F3
			VAR_IXB := aCartoes[ nItem, 3 ]
		EndIf                   
	Else
		Help( ' ', 1, 'TMSA24072', , ,5 ,11) //-- Não existe cartão para o motorista nem cartão para o proprietário do veículo
		VAR_IXB := Space(TamSX3('DLD_IDOPE')[1])
	EndIf
Else
	VAR_IXB := Space(TamSX3('DLD_IDOPE')[1])
EndIf

RestArea(aAreaDA3)
RestArea(aAreaDA4)
RestArea(aArea)
RestArea(aAreaDUP)
FwFreeArray(aLojForDA3)
FwFreeArray(aLojForDA4)

Return(.T.)


//-------------------------------------------------------------------
/*{Protheus.doc} TF64PReceb
Validação do campo DLD_RECEB
@type Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//-------------------------------------------------------------------
Function TF64PReceb(cReceb,cCodVei)
Local cCodMot   := ""
Local aForMot   := {}
Local aForVei   := {}
Local cForMot   := ""
Local cForVei   := ""
Local lRet      := .T.
Local oMdlDLD   := Nil
Local oModel    := Nil
Local cForPag   := ""

Default cReceb := ""
Default cCodVei:= ""

If AllTrim(cReceb) == '2'	
	
	oModel  := FwModelActive()
	oMdlDLD := oModel:GetModel("MdGridDLD")
	cForPag	:= oMdlDLD:GetValue("DLD_FORPAG")					

	If AllTrim(cForPag) <> "3"
		cCodMot:= TF64PMotor()	
		aForMot:= RetForMot(cCodMot)
		aForVei:= RetCodForn(cCodVei)
		
		If Len(aForMot) > 0 
			cForMot:= aForMot[1] + aForMot[2]
		EndIf
		If Len(aForVei) > 0 
			cForVei:= aForVei[1] + aForVei[2]
		EndIf

		If !Empty(cForMot) .And. !Empty(cForVei)
			If cForMot == cForVei
				Help(' ', 1, 'TMSA240A2') //-- "O motorista só pode ser informado, quando o mesmo não for o proprietário do veículo"
				lRet := .F.
			EndIf
		EndIf
	Else
		If AllTrim(cForPag) = "3"
			oMdlDLD:LoadValue("DLD_RECEB","1") 
		EndIf
	EndIf

EndIf

FwFreeArray(aForMot)
FwFreeArray(aForVei)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TF64PMotor
Retorna o Motorista Principal da Viagem
@type Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param oModel
@return cCodMot
*/
//-------------------------------------------------------------------
Function TF64PMotor(oModel)
Local nZ        := 0
Local cCodMot   := ""
Local aSaveLine	:= FWSaveRows()
Local oMdlDUP   := Nil

Default oModel := FwModelActive()

oMdlDUP:= oModel:GetModel("MdGridDUP")

For nZ:= 1 To oMdlDUP:Length()
	oMdlDUP:GoLine(nZ)
	If !oMdlDUP:IsEmpty() .And. !oMdlDUP:IsDeleted()		
		If oMdlDUP:GetValue("DUP_CONDUT") == "1"  //Principal
			cCodMot	:= oMdlDUP:GetValue("DUP_CODMOT")					
			Exit
		EndIf
	EndIf
Next nZ 

FwRestRows(aSaveLine)
Return cCodMot

//-------------------------------------------------------------------
/*{Protheus.doc} RetForMot
Retorna o Fornecedor/Loja do Motorista
@type Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param cCodMot
@return Cod.Fornecedor + Loja Fornecedor
*/
//-------------------------------------------------------------------
Function RetForMot(cCodMot)
Local cCodForn:= ""
Local cLojForn:= ""
Local aAreaDA4:= DA4->(GetArea())

Default cCodMot:= ""

dbSelectArea("DA4")
dbSetOrder(1)
If MsSeek(xFilial("DA4")+cCodMot) .And. !Empty(DA4->DA4_FORNEC)
	cCodForn:= DA4->DA4_FORNEC
	cLojForn:= DA4->DA4_LOJA
EndIf

RestArea(aAreaDA4)
FwFreeArray(aAreaDA4)
Return { cCodForn , cLojForn } 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64FrtMin
Valida o valor do Frete Minimo
@type Function
@author Katia
@since 28/08/2020
@version 12.1.30
@return lRet
*/
//-------------------------------------------------------------------
Function TF64FrtMin(cFilOri,cViagem,cServTms,cRota,cTpOpVg,nQtdEixo,nValFret)
Local cCatVei   := ""
Local aCEPeDist := {}
Local nKmDista  := 0
Local cCargaTipo:= ""
Local aArea     := GetArea()
Local aDoctoVge := {}

Default cFilOri := ""
Default cViagem := ""
Default cServTms:= ""
Default cRota   := ""
Default cTpOpVg := ""
Default nQtdEixo:= 0
Default nValFret:= 0

aDoctoVge:= TF64DocVge(cFilOri,cViagem)
If Len(aDoctoVge) > 0
	cCatVei  := cValToChar(PamCatVeic(nQtdEixo))
	If Len(aCEPeDist:= TMSCEOrDes(cFilOri,cViagem,cServTms,cRota, aDoctoVge)) > 0
		If Len(aCEPeDist) > 2						
			nKmDista := aCEPeDist[3]
		EndIf
	EndIf
	cCargaTipo := Posicione('DLO',1,FwxFilial('DLO')+cTpOpVg,'DLO_CODTPC')
	PamFrtMin(cCatVei, nKmDista, cCargaTipo, nValFret)
EndIf

RestArea(aArea)
FwFreeArray(aArea)
FwFreeArray(aDoctoVge)
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} TF64DocVge
Documentos da viagem para Calculo do Frete Minimo
@type Function
@author Katia
@since 28/08/2020
@version 12.1.30
@return lRet
*/
//-------------------------------------------------------------------
Function TF64DocVge(cFilOri,cViagem)
Local aDocVge   := {}
Local nCntFor   := 0
Local aSaveLine	:= FWSaveRows()
Local aArea     := GetArea()
Local oModel    := FwModelActive()
Local oModelDM3 := oModel:GetModel("MdGridDM3") 

For nCntFor := 1 To oModelDM3:Length()
	oModelDM3:GoLine(nCntFor)
	If !oModelDM3:IsDeleted(nCntFor) .And. !oModelDM3:IsEmpty(nCntFor)
		AAdd (aDocVge, {FwFldGet('DM3_FILDOC'), FwFldGet('DM3_DOC'), FwFldGet('DM3_SERIE') })	
	EndIf
Next nCntFor

FwRestRows(aSaveLine)
RestArea(aArea)
FwFreeArray(aArea)
Return aDocVge

/*{Protheus.doc} PamIDTag
@type Static Function
@author Fabio Marchiori Sampio
@since 07/04/2021
@version version
@param cCampo, char, Campo Origem
@return xRet, char, Retorno do gatilho
@example
(examples)
@see (links_or_references)
@type function
*/
Function PamIDTag( cCodOpe, cCodVei)
Local xRet		:= ""
Local cQuery    := ""
Local cAlias    := ""

Default cCodOpe	:= ""
Default cCodVei	:= ""

	If !Empty(cCodOpe) .And. !Empty(cCodVei)
		cQuery := " SELECT DMF.DMF_TAGID FROM " + RetSqlName("DMG") + " DMG "
		cQuery += "	INNER JOIN " + RetSqlName("DME") + " DME "  
		cQuery += "	ON DME_FILIAL = '" + xFilial("DME") + "'"
		cQuery += "		AND DME_CODTAG = DMG_CODTAG "
		cQuery += "		AND DME.D_E_L_E_T_ = ' ' "
		cQuery += "		INNER JOIN " + RetSqlName("DMF") + " DMF " 
		cQuery += "	ON DMF_FILIAL = '" + xFilial("DMF") + "'"
		cQuery += "		AND DMF_CODTAG = DME_CODTAG "
		cQuery += "		AND DMF_CODOPE = '" + cCodOpe + "'" 
		cQuery += "		AND DMF.D_E_L_E_T_  = ' ' "
		cQuery += "	WHERE DMG.DMG_FILIAL = '" + xFilial("DMG") + "' AND DMG.DMG_CODVEI = '" + cCodVei + "' "
		cQuery += "	 AND DMG.DMG_ATIVO = '1' AND DMG.D_E_L_E_T_ = ' '	"	

		cQuery := ChangeQuery(cQuery)
		cAlias := GetNextAlias()
		dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
	
		If (cAlias)->(!Eof())
			xRet := AllTrim((cAlias)->(DMF_TAGID))
		EndIf				

		(cAlias)->(dbCloseArea())
	EndIf

Return xRet 

//-------------------------------------------------------------------
/*{Protheus.doc} TF64PagBem
Validação PAGBEM 
@type Function
@author Rafael Souza
@since 18/01/2022
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TF64PagBem( oModel , cCodOpe  )
Local lRet		:= .T. 

Default oModel  := FwModelActive()  
Default cCodOpe	:= ""     

lRet    := VldPBemDTR(oModel,cCodOpe)

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldPBemDTR
Validação PAGBEM
@type Static Function
@author Rafael Souza
@since 18/01/2022
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPBemDTR( oModel, cCodOpe )
Local lRet      := .T. 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local aSaveLine	:= FWSaveRows()
Local oMdlDTR   := Nil
Local nCount    := 0 
Local cCodVei   := ""
Local cCodRBQ1	:= ""
Local cCodRBQ2	:= ""
Local cCodRBQ3	:= ""
Local nOpc      := 0

Default oModel      := FWModelActive()
Default cCodOpe		:= ""

oMdlDTR := oModel:GetModel("MdGridDTR")
nOpc    := oMdlDTR:GetOperation()

If nOpc == 3 .Or. nOpc == 4
	
	For nCount := 1 To oMdlDTR:Length()
		oMdlDTR:GoLine(nCount)
		If !oMdlDTR:IsDeleted()
		
			cCodVei     := oMdlDTR:GetValue("DTR_CODVEI")
			cCodRBQ1	:= oMdlDTR:GetValue("DTR_CODRB1")
			cCodRBQ2	:= oMdlDTR:GetValue("DTR_CODRB2")
			cCodRBQ3	:= oMdlDTR:GetValue("DTR_CODRB3")
								
			If lRet .And. !Empty(cCodVei)
				lRet    := TF64VldVei(cCodVei)
			EndIf

			If lRet .And. !Empty(cCodRBQ1)
				lRet    := TF64VldVei(cCodRBQ1)
			EndIf
			
			If lRet .And. !Empty(cCodRBQ2)
				lRet    := TF64VldVei(cCodRBQ2)
			EndIf 
			
			If lRet .And. !Empty(cCodRBQ3)
				lRet   	:= TF64VldVei(cCodRBQ3)
			EndIf 

			If lRet
				lRet	:= VldPBemDUP(oModel,cCodVei)
			EndIf 

		EndIf
	Next nCount 
EndIf

FwRestRows(aSaveLine)
RestArea( aAreaDTR )
RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldPBemDUP
Valida DUP
@type Static Function
@author Rafael
@since 24/01/2022
@version 12.1.30
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldPBemDUP(oModel,cCodVei)
Local lRet		:= .T. 
Local aArea		:= GetARea()
Local oMdlDUP	:= Nil
Local nOpc      := 0

Default oModel	 := FWModelActive()
Default cCodVei	 := ""

oMdlDUP:= oModel:GetModel("MdGridDUP")
nOpc   := oMdlDUP:GetOperation()

	If nOpc == 3 .Or. nOpc == 4	
		cCodMot	:= oMdlDUP:GetValue("DUP_CODMOT")

		If !Empty(cCodMot)	
			lRet:= VldMotPgBE(cCodMot)
		EndIf
	EndIf

RestArea(aArea)
Return lRet

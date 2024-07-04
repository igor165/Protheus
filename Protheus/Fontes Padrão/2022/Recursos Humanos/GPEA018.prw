#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "GPEA1010.CH"

Static aEfd 		:= If( cPaisLoc == 'BRA', If(Findfunction("fEFDSocial"), fEFDSocial(), {.F.,.F.,.F.,.F.,.F.}), {.F.,.F.,.F.,.F.,.F.} )	//Statics com carga devido ao acesso via outros modulos destas variaveis
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 ) //Integracao com TAF
Static cVerTrab		:= "2.4"	
Static cVerGPE		:= ""	
Static lDPrevPG		:= IIF (Select( "SV7" ) > 0 .AND. SV7->(ColumnPos( "V7_DPREVPG" )) > 0 , .T., .F.) 
Static lRegra		:= If(Select( "SV7" ) > 0 .AND. SV7->(ColumnPos( "V7_REGRA" )) > 0 , .T., .F.)  
Static lSeqTurn		:= If(Select( "SV7" ) > 0 .AND. SV7->(ColumnPos( "V7_SEQTURN" )) > 0 , .T., .F.)
Static lDescJor 	:= If(Select( "SV7" ) > 0 .AND. SV7->(ColumnPos( "V7_DESCJOR" )) > 0 , .T., .F.)

/*/{Protheus.doc} menudef
 menu por enquanto nao utilizado, tela sera acionada via acoes relacionadas do gpea010
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/

Static Function MenuDef()
Static cEfdAviso	:= SuperGetMv( "MV_EFDAVIS" ,NIL, "0" )
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,0)) >= 1 )
Static dCgIni		:= SuperGetMv( "MV_DTCGINI" ,NIL, DDATABASE )
Local aRotina 		:= {}

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GPEA018" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GPEA018" OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GPEA018" OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GPEA018" OPERATION 5 ACCESS 0  //"Excluir"

Return ( aRotina )

/*/{Protheus.doc} ModelDef
 ModelDef - model principal
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function ModelDef()
	
	Local oModel	 := Nil
	Local oSRAStruct := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|"})
	
	If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2260", .F.,,,@cVerTrab,@cVerGPE),)
	
	If Empty(cVerGPE)
		cVerGPE := cVerTrab
	EndIf
	
	oStruSV7 := FwFormStruct( 1, 'SV7' )
	
	oModel := MPFormModel():New("GPEA018", { |oModel| fVerSit(oModel) }, {||FazValid()} ,{|oModel|FazCommit(oModel)},/*Cancel*/)    
	
	osrastruct:afields[1][11] := {||SRA->RA_filial}
	osrastruct:afields[2][11] := {||SRA->RA_MAT}
	osrastruct:afields[3][11] := {||SRA->RA_nome}
	
	oModel:AddFields("SRAMdField", /*cOwner*/, oSRAStruct, /*Pre-Validacao*/,/*Pos-Validacao*/  {|oModel|FazValid(oModel)} ,/*Carga*/)
	
	If ((lIntTaf) .And. (cVerGPE < "9.0"))
		oStruSV7:SetProperty( "V7_CONVC", MODEL_FIELD_WHEN, { |oModel| fWhenConv(oModel) } )
	EndIf
	
	oStruSV7:SetProperty( "V7_CARG", MODEL_FIELD_OBRIGAT, .F. )
	oStruSV7:SetProperty( "V7_DEPTO", MODEL_FIELD_OBRIGAT, .F. )
	
	oModel:AddGrid("SV7MdGrid", "SRAMdField", oStruSV7,/*LinePre*/{ |oGrid, nLine, cAction, cField| PreLineOk(oGrid, nLine, cAction, cField) } ,/*bLinePost*/{ |oGrid, nLine, cAction, cField| PostLineOk(oGrid, nLine, cAction, cField) },/*bPre*/,/*bPost*/,/*Carga*/) 
	oModel:SetRelation("SV7MdGrid",{{"V7_FILIAL","xfilial('SV7')" } , {"V7_MAT",'RA_MAT' }  },SV7->(IndexKey(1)))
	oModel:GetModel("SV7MdGrid"):SetOptional(.T.)
	oModel:SetVldActivate( { |oModel| fVldModel(oModel) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
 ViewDef referente ao Model
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function ViewDef()
	
	Local oModel	
	Local oView	   
	Local oSRAStruct 
	Local oStruSV7	 := FWFormStruct(2,"SV7")
	
	oStruSV7 := FwFormStruct( 2, 'SV7')
	
	oView  := FWFormView():New()
	
	oModel := FWLoadModel("GPEA018")
	
	oView:SetModel(oModel)
	
	oSRAStruct := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "FILIAL|RA_MAT|RA_NOME|"})
	
	oSRAStruct:SetNoFolder()
	
	oStruSV7:RemoveField("V7_FILIAL")
	oStruSV7:RemoveField("V7_MAT")
	oStruSV7:RemoveField("V7_STAT")
	
	oView:AddField( 'SRAVwField' , oSRAStruct , 'SRAMdField')
	oView:AddGrid ('SV7VwGrid' , oStruSV7   , 'SV7MdGrid')
	
	oView:SetViewProperty("SRAVwField","OnlyView")
	
	oView:CreateHorizontalBox("SUPERIOR",15)//cabecalho
	oView:CreateHorizontalBox("INFERIOR",85)//grid  
	
	oView:SetOwnerView('SRAVwField',"SUPERIOR" )
	oView:SetOwnerView('SV7VwGrid' ,"INFERIOR")
	
	oView:AddIncrementField( 'SV7VwGrid', 'V7_COD' )
	
	oView:EnableTitleView('SRAVwField' ,oEmToAnsi(STR0354))
	oView:EnableTitleView('SV7VwGrid'  ,oEmToAnsi(STR0355))
	
Return oView  

/*/{Protheus.doc} FazValid
 Validações do browse - tudoOk
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function FazValid ()
Local oModel	:= FwModelActivate()
Local oSV7Model	:= oModel:GetModel("SV7MdGrid")
Local lRet      := .T.
Local nTamSV7   := oSV7Model:Length()
Local nX        := 0
Local aLstConvoc   := {}
Local nIndexConvoc := 0
Local nIndexDatas  := 0

DbselectArea("SV7")

for nx := 1 to nTamSV7
	oSV7Model:GoLine(nX)

	If !(oSV7Model:IsDeleted())
		nIndexConvoc := 0
		If !Empty(oSV7Model:GetValue("V7_CONVC"))
			nIndexConvoc  := aScan( aLstConvoc , { |x| x[2]  == oSV7Model:GetValue("V7_CONVC") } )
		EndIf
		nIndexDatas   := aScan( aLstConvoc , { |x| (x[3] <= oSV7Model:GetValue("V7_DTINI") .And. x[4] >= oSV7Model:GetValue("V7_DTINI")) .or. ;
											       (x[3] <= oSV7Model:GetValue("V7_DTFIM") .And. x[4] >= oSV7Model:GetValue("V7_DTFIM")) .or. ;
											       (x[3] >  oSV7Model:GetValue("V7_DTINI") .And. x[4] <  oSV7Model:GetValue("V7_DTFIM"))       } )
		
		If nIndexConvoc == 0
			Aadd ( aLstConvoc, {nx, oSV7Model:GetValue("V7_CONVC"), oSV7Model:GetValue("V7_DTINI"), oSV7Model:GetValue("V7_DTFIM") }  )
		Else
			Help("",1,"GPEA18CONVC")
			lRet := .F.
			exit
		EndIf
		
		If nIndexDatas > 0
			Help("",1,"GPEA18DTCOI")
			lRet := .F.
			exit
		EndIf
		
	EndIf
	
Next		

return lRet

/*/{Protheus.doc} Fazcommit
 Efetiva informações na Base de Dados. Obs: manter commit customizado por enquanto
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function FazCommit(oModel)

Local aPerAberto:= {}
Local aPerVld	:= {}
Local cMsgErro	:= ""
Local cStat		:= ""
Local dDtCorte 	:= SuperGetMV("MV_DTCGINI", nil, dDataBase)
Local nOpc	    := 0    
Local nPosPerAb := 0    
Local lHEInterm	:= SuperGetMv("MV_PONINTE", NIL, .F.)
Local lIsDel	:= .F.
Local lIsIns	:= .F.
Local lIsUpd	:= .F.
Local lRet      := .T.
Local lRetTaf   := .T.
Local oSV7Model	:= oModel:GetModel("SV7MdGrid")
Local nTamSV7   := oSV7Model:Length()
Local nX        := 0
Local lRetif	:= .F. 
Local lAltera   := .T.

If ((lIntTaf) .And. (cVerGPE < "9.0"))
	Private aCC		:= fGM23CTT()
	Private aEstb	:= fGM23SM0()
EndIf

nOpc := oSV7Model:GETOPERATION()

DbselectArea("SV7")
DbSetOrder(1)
		
Begin Transaction

If nOpc == 3 .OR. nOpc == 4 
	for nX := 1 to nTamSV7
		oSV7Model:GoLine(nX)
		lIsDel	:= oSV7Model:IsDeleted()
		lIsIns	:= oSV7Model:IsInserted()
		lIsUpd	:= oSV7Model:IsUpdated()

		If !lIsDel .AND. !lIsIns .AND. !lIsUpd
			Loop
		Else
			If !lIsDel
				If SV7->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + oSV7Model:GetValue("V7_COD") ))
					Reclock('SV7',.F.)
				Else
					Reclock('SV7',.T.)
					SV7->V7_FILIAL := SRA->RA_FILIAL
					SV7->V7_MAT    := SRA->RA_MAT
					SV7->V7_STAT   := "1"
				EndIf
				If nOpc == 4 
					lAltera := .F.
					If (SV7->V7_CONVC <> oSV7Model:GetValue("V7_CONVC") .Or. SV7->V7_DTINI <> oSV7Model:GetValue("V7_DTINI") .Or.;
						SV7->V7_DTFIM <> oSV7Model:GetValue("V7_DTFIM") .Or. SV7->V7_DPREVPG <> oSV7Model:GetValue("V7_DPREVPG") .Or.;
						SV7->V7_TURNO <> oSV7Model:GetValue("V7_TURNO") .Or. SV7->V7_TPLOC <> oSV7Model:GetValue("V7_TPLOC") .Or.;
						SV7->V7_LOCAL <> oSV7Model:GetValue("V7_LOCAL") )
						lAltera := .T.
					Endif	
				Endif
				SV7->V7_COD    := oSV7Model:GetValue("V7_COD")
				SV7->V7_CONVC  := oSV7Model:GetValue("V7_CONVC")
				SV7->V7_DTCON  := oSV7Model:GetValue("V7_DTCON")
				SV7->V7_ATIVI  := oSV7Model:GetValue("V7_ATIVI")
				SV7->V7_DTINI  := oSV7Model:GetValue("V7_DTINI")
				SV7->V7_DTFIM  := oSV7Model:GetValue("V7_DTFIM")
				SV7->V7_FUNC   := oSV7Model:GetValue("V7_FUNC")
				SV7->V7_CARG   := oSV7Model:GetValue("V7_CARG")
				SV7->V7_SALAR  := oSV7Model:GetValue("V7_SALAR")
				SV7->V7_TURNO  := oSV7Model:GetValue("V7_TURNO")
				SV7->V7_CCUS   := oSV7Model:GetValue("V7_CCUS")
				SV7->V7_DEPTO  := oSV7Model:GetValue("V7_DEPTO")
				SV7->V7_TPLOC  := oSV7Model:GetValue("V7_TPLOC")
				SV7->V7_LOCAL  := oSV7Model:GetValue("V7_LOCAL")
				SV7->V7_HRSDIA := oSV7Model:GetValue("V7_HRSDIA")
				SV7->V7_DPREVPG := oSV7Model:GetValue("V7_DPREVPG")
				
				If lRegra
					SV7->V7_REGRA := oSV7Model:GetValue("V7_REGRA")
				EndIf 
				If lSeqTurn
					SV7->V7_SEQTURN := oSV7Model:GetValue("V7_SEQTURN")
				EndIf 
				If lDescJor
					SV7->V7_DESCJOR := oSV7Model:GetValue("V7_DESCJOR")
				EndIf 
				MsUnLock()
				If (lIntTaf .And. cVerGPE < "9.0") .And. SV7->V7_DTINI >= dDtCorte .And. !Empty(oSV7Model:GetValue("V7_CONVC")) .And. lAltera
					cStat 	:= TAFGetStat( "S-2260", AllTrim(SRA->RA_CIC) + SRA->RA_CODUNIC + ";" + SV7->V7_CONVC )
					cMsgErro:= ""
					If (cStat == "4" .And. !lIsUpd .And. !lIsIns )
						Loop
					EndIf
					lRetif := (cStat == "4" .And. (lIsUpd .Or. lIsIns))
					lRetTaf := fInt2260( @cMsgErro, cVerTrab, lRetif)
					If !lRetTaf .And. !Empty(cMsgErro)
						Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0394 + SV7->V7_CONVC + CRLF + cMsgErro ), 1, 0 )//"Atenção"##"Ocorreu o erro abaixo na integração da convocação: "
						DisarmTransaction()
						return .F.
					EndIf
				EndIf
				If lHEInterm 
					aPerAberto := {}
					fRetPerComp(SubStr( AnoMes(SV7->V7_DTINI), 5, 2), SubStr( AnoMes(SV7->V7_DTINI), 1, 4), xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetRotOrdinar(), @aPerAberto, {})
					nPosPerAb := aScan( aPerAberto, { |x| x[9] == SV7->V7_DPREVPG } )
					If AnoMes(SV7->V7_DTFIM) > AnoMes(SV7->V7_DTINI)
						If nPosPerAb == 0 .Or. ( AnoMes(SV7->V7_DTINI) >= AnoMes(aPerAberto[nPosPerAb, 6]) )
							aAdd( aPerVld, { SV7->V7_DTINI, LastDate(SV7->V7_DTINI), SV7->V7_DPREVPG, AnoMes(SV7->V7_DTINI)  } )
						EndIf
						aAdd( aPerVld, { FirstDate(SV7->V7_DTFIM), SV7->V7_DTFIM, SV7->V7_DPREVPG, AnoMes(FirstDate(SV7->V7_DTFIM))  } )
					Else
						aAdd( aPerVld, { SV7->V7_DTINI, SV7->V7_DTFIM, SV7->V7_DPREVPG, AnoMes(SV7->V7_DTINI) } )
					EndIf
				EndIf
			Else
				If SV7->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + oSV7Model:GetValue("V7_COD") ))
					reclock('SV7',.F.)
					SV7->(DbDelete())
					MsUnLock()
				EndIf
				If ((lIntTaf) .And. (cVerGPE < "9.0")) .And. SV7->V7_DTINI >= dDtCorte .And. !Empty(oSV7Model:GetValue("V7_CONVC"))
					cStat 	:= TAFGetStat( "S-2260", AllTrim(SRA->RA_CIC) + SRA->RA_CODUNIC + ";" + SV7->V7_CONVC )
					cMsgErro:= ""
					If cStat != "-1"
						lRetTaf := fExc2260( @cMsgErro, cVerTrab )
						If !lRetTaf .And. !Empty(cMsgErro)
							Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0394 + SV7->V7_CONVC + CRLF + cMsgErro ), 1, 0 )//"Atenção"##"Ocorreu o erro abaixo na integração da convocação: "
							DisarmTransaction()
							return .F.
						EndIf					
					EndIf
				EndIf
			EndIf
		Endif
	Next
EndIf

End Transaction

If lRet .And. lHEInterm .And. !Empty(aPerVld)
	fVldPer( aPerVld )
EndIf

return lRet

/*/{Protheus.doc} V7GetCargo
Gatilho Busca descricao cargo
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetCargo()     
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local cFuncao 	
Local cCc		
Local cCargo	 
Local cCodCargo	 
Local cDesCargo	   

oModSV7     := oModel:GetModel("SV7MdGrid")

cFuncao 	:= oModSV7:GetValue("V7_FUNC")
cCc		    := oModSV7:GetValue("V7_CCUS")
cCargo	    := oModSV7:GetValue("V7_CARG") 
cCodCargo	:= Iif(Empty(cCargo),fDesc("SRJ",cFuncao,"RJ_CARGO"),cCargo) 
cDesCargo	:= fDesc("SQ3",cCodCargo+cCc,"Q3_DESCSUM")   
	
cDesCargo	:= If(Empty(cDesCargo),fDesc("SQ3",cCodCargo+Space(9),"Q3_DESCSUM"),cDesCargo) 

oModSV7:SetValue("V7_DCARG", cDesCargo)

Return ( cDesCargo )   

/*/{Protheus.doc} V7GetFunc
Gatilho Busca descricao funcao
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetFunc()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
oModSV7 := oModel:GetModel("SV7MdGrid")
oModSV7:SetValue("V7_DFUNC", SRJ->RJ_DESC)
                                                                
return SRJ->RJ_DESC

/*/{Protheus.doc} V7GetCcus
Gatilho  Busca descricao c.custos
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetCcus()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
oModSV7             := oModel:GetModel("SV7MdGrid")
oModSV7:SetValue("V7_DCCUS", CTT->CTT_DESC01)
                                                                      
return CTT->CTT_DESC01


/*/{Protheus.doc} V7GetLocal
Gatilho  Busca descricao do local
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetLocal ()
Local cRet    :=     Posicione("SV6", 1,Fwxfilial('SV6')+M->V7_LOCAL, "V6_DESC")                                        
Return cret

/*/{Protheus.doc} V7GetCLocal
Gatilho Busca descricao funcao
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetCLocal(nPar)
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local cRet          := ''
oModSV7             := oModel:GetModel("SV7MdGrid")

If nPar == 1
	cRet := oModSV7:GetValue("V7_LOCAL")
Else
	cRet := oModSV7:GetValue("V7_DLOC")
EndIf

If M->V7_TPLOC <> "1"
	cRet := ""
EndIf

return cRet


/*/{Protheus.doc} V7GetDturno
Gatilho  Busca descricao do turno
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetDturno ()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local cRet          := ''
oModSV7             := oModel:GetModel("SV7MdGrid")
oModSV7:SetValue("V7_DTUR", SR6->R6_DESC)

cRet := SR6->R6_DESC                                                                          
return cRet


/*/{Protheus.doc} V7GetDCarg
 Busca descricao do cargo
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Function V7GetDCarg()
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
oModSV7 := oModel:GetModel("SV7MdGrid")

cRet := FDESC("SQ3",SV7->V7_CARG+SV7->V7_CCUS,"Q3_DESCSUM",,SV7->V7_FILIAL)
If Empty(cret)
	cRet := FDESC("SQ3",SV7->V7_CARG,"Q3_DESCSUM",,SV7->V7_FILIAL)
Endif

RestArea(aArea)
Return cRet


/*/{Protheus.doc} PostLineOk
 Validacoes solcitadas ate o momento:
 - Validar data inicial e final da Atividade
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function PostLineOk(oGrid, nLine, cAction, cField)
Local lRet 			:= .T.
Local cMsg			:= ""
Local cMsg2			:= ""

If  oGrid:GetValue("V7_DTINI")  >  oGrid:GetValue("V7_DTFIM")  
	Help("",1,"GPEA18DATAS")  //'Data Inicio de Atividade deve ser menor ou igual a Data Final desta!'
	lRet := .F.
EndIf

If  oGrid:GetValue("V7_DTINI")  <  oGrid:GetValue("V7_DTCON")  
	Help("",1,"GPEA18DTINI")  //"Data de inicio de Atividade deve ser maior ou igual a Data de Convocação!"
	lRet := .F.
EndIf

If  oGrid:GetValue("V7_DTINI")  <  SRA->RA_ADMISSA  
	Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0412), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0413)}) //"Atenção"##"Data de início da atividade deve ser maior ou igual a data de admissão."
	lRet := .F.
EndIf

If oGrid:GetValue("V7_TPLOC") == "1"
	If Empty(oGrid:GetValue("V7_LOCAL"))
		Help("",1,"GPEA18LOCAL")//"Informe o Código do Local"
		lRet := .F.
	EndIf
EndIf

If ((lIntTaf) .And. (cVerGPE < "9.0")) .And. !Empty(oGrid:GetValue("V7_CONVC")) .And. Empty(oGrid:GetValue("V7_DPREVPG")) .And. dCgIni <= oGrid:GetValue("V7_DTCON")
	cMsg:= OemtoAnsi(STR0299)+CRLF			//"As seguintes regras deverao ser atendidas conforme leiaute eSocial."
	cMsg+= OemtoAnsi(STR0300)+ CRLF + CRLF	//"E conforme conteudo do parametro MV_EFDAVIS "
	
	cMsg2:= OemtoAnsi(STR0387) + CRLF 	//"O campo DtPrev.Pgto não poder estar vazio para convoções posteriores à data do parametro MV_DTCGINI"

	If cEFDAviso == "0"
		cMsg+= OemtoAnsi(STR0284) + CRLF + CRLF + cMsg2		//"mas nao sera impeditivo para a gravacao dos dados deste funcionario."
	ElseIf cEFDAviso == "1"
		cMsg+= OemtoAnsi(STR0285)+ CRLF + CRLF + cMsg2		//"e sera necessario o preenchimento dos mesmos para efetivar a gravacao dos dados deste funcionario."
		lRet := .F.
	EndIf
	
	Help( ,, OemToAnsi(STR0245),, OemToAnsi(cMsg), 1, 0 )
	
EndIf
/*
If lIntTAF
	If Empty(oGrid:GetValue("V7_TURNO")) .And. Empty(oGrid:GetValue("V7_DESCJOR"))
		lRet := .F.
		Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0396), 1, 0 )//"Atenção"##"O Turno e a Descrição da Jornada não foram preenchidos. É obrigatório o preenchimento de pelo menos um dos dois campos."
	EndIf
	
	If !Empty(oGrid:GetValue("V7_TURNO")) .And. (Empty(oGrid:GetValue("V7_REGRA")) .Or. Empty(oGrid:GetValue("V7_SEQTURN")))
		lRet := .F.
		Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0395), 1, 0 )//"Atenção"##"O Turno foi preenchido mas a Regra e/ou Sequência Início do Turno não foram preenchidos."
	EndIf
	
EndIf
*/

Return lRet



/*/{Protheus.doc} PreLineOk
 Pre-validacoes
 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static Function PreLineOk(oGrid, nLine, cAction, cField)
Local lRet 			:= .T.
Local aPerAtual		:= {}
Local cDataFimAnt	:= ""
Local dDataFim		:= CtoD("")
Local dDataIni		:= CtoD("")
Local dDataFimAnt	:= CtoD("")

If cAction == "CANSETVALUE" .or. cAction == "DELETE"
	If Gpea1809 (oGrid:GetValue("V7_COD"))
	 	lRet := .F.
	 	If cAction == "DELETE"
	 	//Mvc exige msg
	 		Help("",1,"GPEA1809DV7")//"Já existem lançamentos para este Funcionário!"
		ElseIf cField == "V7_DTFIM"
			MsgInfo(Ap5GetHelp("GPEA1809DV7"))
		EndIf
	EndIf
	If lRet .and. cAction == "CANSETVALUE" .and. cField == "V7_DTFIM"
		If Gpea1808 (oGrid:GetValue("V7_COD"),.T.)  
		 	lRet := .F.
	 		MsgInfo(Ap5GetHelp("GPEA1808DV7"))//"Já foi efetuado o cálculo de Folha (Tabelas SRD\SRC)"
		EndIf	
	ElseIf lRet .And. Gpea1808 (oGrid:GetValue("V7_COD"))  
	 	lRet := .F.
	 	If cAction == "DELETE" //Mvc exige msg
	 		Help("",1,"GPEA1808DV7")//"Já foi efetuado o cálculo de Folha (Tabelas SRD\SRC)"
		EndIf
	EndIf	
EndIf

If cAction == "SETVALUE" .and. cField == "V7_DTFIM" .and. !oGrid:IsInserted()
	dDataFim := M->V7_DTFIM
	dDataIni := oGrid:GetValue("V7_DTINI")
	If fGetPerAtual(@aPerAtual,xFilial("RCH"),SRA->RA_PROCES,fGetRotOrdinar())
		If dDataIni < aPerAtual[1,6] //Se convocação foi incluída no mês atual, não impede a edição dos campos. 
			dDataFimAnt := aPerAtual[1,6] - 1
			cDataFimAnt := DtoC(dDataFimAnt)
			If dDataFimAnt <> dDataFim
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	If !lRet
		//"Atenção" - "A data final só pode ser alterada para o último dia do último período fechado." ### Altere a data para
		Help( ,, OemToAnsi(STR0245),, STR0419, 1, 0,,,,,, If(!Empty(cDataFimAnt),{STR0420 + cDataFimAnt},"") )
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} Gpea1801
 Inic.Padrão descricao de func
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/                               
function Gpea1801()
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cret := FDESC('SRJ',SV7->V7_FUNC,'RJ_DESC',TAMSX3('RJ_DESC'),SV7->V7_FILIAL)

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet


/*/{Protheus.doc} Gpea1802
 Inic.Padrão descricao de cargo
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1802() 
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cRet := FDESC("SQ3",SV7->V7_CARG+SV7->V7_CCUS,"Q3_DESCSUM",,SV7->V7_FILIAL)
If Empty(cret)
	cRet := FDESC("SQ3",SV7->V7_CARG,"Q3_DESCSUM",,SV7->V7_FILIAL)
Endif

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet


/*/{Protheus.doc} Gpea1803
 Inic.Padrão descricao de c.custo
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1803()                                         
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cRet := FDESC("CTT",SV7->V7_CCUS,"CTT_DESC01",,SV7->V7_FILIAL)

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet


/*/{Protheus.doc} Gpea1804
 Inic.Padrão descricao de depto
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1804()                                                                                                     
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cRet := FDESC('SQB',SV7->V7_DEPTO,'QB_DESCRIC')

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet


/*/{Protheus.doc} Gpea1805
 Inic.Padrão descricao de Local
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1805()                                                                                                     
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cRet := Posicione("SV6", 1,fwxfilial('SV6')+SV7->V7_LOCAL, "V6_DESC") 

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet


/*/{Protheus.doc} Gpea1806
 Inic.Padrão descricao de Turno
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1806()                                                                                                     
Local aArea         := GetArea()
Local cRet	        := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil

oModSV7 := oModel:GetModel("SV7MdGrid")

cRet :=  FDESC("SR6",SV7->V7_TURNO,"R6_DESC")

If oModSV7 <> Nil
	If oModSV7:Length() > 0 
		If Empty(SV7->V7_MAT) .And. Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. !Empty(oModSV7:GetValue("V7_FILIAL")) .And. !Empty(oModSV7:GetValue("V7_MAT")) 
			cRet := ''
		EndIf
		
		If !Empty(SV7->V7_MAT) .And. !Empty(SV7->V7_COD) .And. !Empty(oModSV7:GetValue("V7_COD")) .And. Empty(oModSV7:GetValue("V7_FILIAL")) .And. Empty(oModSV7:GetValue("V7_MAT"))
			cRet := ''
		EndIf
	EndIf
Else
	cRet := ''
EndIf

RestArea(aArea)
return cRet

/*/{Protheus.doc} Gpea1807
 Habilitar campo cod local em tela
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1807() 
Local aArea         := GetArea()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local lWhenRet      := .F.
Local cTipo         := '' 
oModSV7 := oModel:GetModel("SV7MdGrid")

If oModSV7 <> Nil
	cTipo := oModSV7:GetValue("V7_TPLOC")

	If cTipo == "1"
		lWhenRet := .T.	
	EndIf
EndIf

RestArea(aArea)

return lWhenRet



/*/{Protheus.doc} Gpea1808
 Verifica se ja foi gerado SRD\SRC
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function Gpea1808 (cConvoc, lOnlySRC) 
Local cSRDSRC   := GetNextAlias()
Local lHaSrdSrc := .F.
Local cPeriodo  := StrZero(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2)

DEFAULT lOnlySRC := .F.

If !lOnlySRC 
	BeginSql Alias cSRDSRC
				SELECT  SRD.RD_CONVOC   FROM 	%table:SRD% SRD 
					   WHERE SRD.RD_FILIAL     = %Exp:(SRA->RA_FILIAL)%
						 AND SRD.RD_MAT        = %Exp:(SRA->RA_MAT)%
						 AND SRD.RD_CONVOC     = %Exp:(cConvoc)%
						 AND SRD.RD_EMPRESA    = %Exp:Space(TamSX3("RD_EMPRESA")[1])%
						 AND SRD.RD_PERIODO    = %Exp:(cPeriodo)%
						 AND SRD.%NotDel%  
	EndSql
			
	If (cSRDSRC)->(!Eof())
		lHaSrdSrc := .T.
	EndIf
	
	(cSRDSRC)->(DbCloseArea())
EndIf

If !lHaSrdSrc
	BeginSql Alias cSRDSRC
				SELECT  SRC.RC_CONVOC   FROM 	%table:SRC% SRC 
					   WHERE SRC.RC_FILIAL     = %Exp:(SRA->RA_FILIAL)%
						 AND SRC.RC_MAT        = %Exp:(SRA->RA_MAT)%
						 AND SRC.RC_CONVOC     = %Exp:(cConvoc)%
						 AND SRC.RC_PERIODO    = %Exp:(cPeriodo)%
						 AND SRC.%NotDel%  
	EndSql
			
	If (cSRDSRC)->(!Eof())
		lHaSrdSrc := .T.
	EndIf
	
	(cSRDSRC)->(DbCloseArea())
EndIf

return lHaSrdSrc


/*/{Protheus.doc} Gpea1809
 Verifica se ja foi gerado rgb
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
Static function Gpea1809 (cConvoc) 
Local cRGBAlias   := GetNextAlias()
Local lRGB := .F.
 
BeginSql Alias cRGBAlias
			SELECT  RGB.RGB_CONVOC   FROM 	%table:RGB% RGB 
				   WHERE RGB.RGB_FILIAL     = %Exp:(SRA->RA_FILIAL)%
					 AND RGB.RGB_MAT        = %Exp:(SRA->RA_MAT)%
					 AND RGB.RGB_CONVOC     = %Exp:(cConvoc)%
					 AND RGB.%NotDel%  
EndSql
		
If (cRGBAlias)->(!Eof())
	lRGB := .T.
EndIf

(cRGBAlias)->(DbCloseArea())

return lRGB




/*/{Protheus.doc} Gpea1810
 Horas Dia 
@author Oswaldo L
@since 12/12/2017
@version P12
@param cTipoAlt, caractere
@return lResult, resultado
/*/
function Gpea1810 () 
Local aArea         := GetArea()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local lRet          := .T.
Local nHrsDia       := 0 
 
oModSV7 := oModel:GetModel("SV7MdGrid")

If oModSV7 <> Nil
	nHrsDia := oModSV7:GetValue("V7_HRSDIA")

	If nHrsDia > 24.00
		lRet := .F.	
	EndIf
EndIf

RestArea(aArea)

return lRet

/*/{Protheus.doc} F3SV7Filtro
Constroi o filtro da consulta padrão de convicações utilizada nos lançamentos mensais - RGB
@author cicero.pereira
@since 15/12/2017
@version 12.1.17
/*/
Function F3SV7Filtro()

	Local cFiltro := ""

	If Type("cDataIni")  == "U"
		Private cDataIni := RCH->RCH_DTINI
		Private cDataFim := RCH->RCH_DTFIM

		If SRA->RA_TIPOPGT = 'S'
			cDataFim	:= cDataIni
		EndIf
	Endif
	
	cFiltro := "SV7->V7_FILIAL == SRA->RA_FILIAL "
	cFiltro += ".And. SV7->V7_MAT == SRA->RA_MAT"
	cFiltro += ".And. SV7->V7_STAT == '1' .And. ((dTos(SV7->V7_DTINI) <= '" + dTos(cDataFim) + "'"
	cFiltro += ".And. dTos(SV7->V7_DTFIM)  >= '"  +  dTos(cDataIni) + "')"
	cFiltro += ".Or. ( dTos(SV7->V7_DTINI) >= '"  +  dTos(cDataIni) + "' "
	cFiltro += ".And. dTos(SV7->V7_DTINI)  <= '"  +  dTos(cDataFim) + "'))"
	
	cFiltro := "@#" + cFiltro + "@#"

Return cFiltro


/*/{Protheus.doc} F3SV7SQ3
Constroi o filtro da consulta padrão de cargos
@author cicero.pereira
@since 15/12/2017
@version 12.1.17
/*/

Function F3SV7SQ3()
Local cFiltro := ""
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
  
oModSV7 := oModel:GetModel("SV7MdGrid")

cFiltro :=   "@#" + " SQ3->Q3_CC == '" + oModSV7:GetValue('V7_CCUS') + "' .or. SQ3->Q3_CC == Space(TAMSX3('Q3_CC')[1]) " + "@#" 

RETURN cFiltro 

/*/{Protheus.doc} FVldDPrvPg
Valid do campo V7_DPREVPG
Deve ser uma data válida e igual ou posterior à data de admissão do trabalhador 
(no caso de sucessão, igual ou posterior à data da transferência). 
@author paulo.inzonha
@since 29/03/2018
@version 12.1.17
/*/

Function FVldDPrvPg()
Local oModel		:= FwModelActivate()
Local oModSV7		:= Nil
Local dPrevPgto		:= StoD("")
Local lRet			:= .T.
Local aTrasf		:= {}
Local nPos			:= 0

oModSV7 	:= oModel:GetModel("SV7MdGrid")
dPrevPgto 	:= oModSV7:GetValue('V7_DPREVPG')

If !Empty(dPrevPgto)
	fTransf(@aTrasf,,.T.,.T.)
	nPos := aScan(aTrasf, {|X| X[5] == SRA->RA_FILIAL + SRA->RA_MAT })
	If SRA->RA_ADMISSA > dPrevPgto .OR. ( nPos > 0 .AND.aTrasf[nPos,7] > dPrevPgto )
		//"Atenção" - "Data de previsão de pagamento menor que data de Admissão/Transferência"
		Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0386 ), 1, 0 )
		lRet := .F.
	EndIf  
EndIf

RETURN lRet 

/*/{Protheus.doc} fVldModel
Validação da abertura do Model
@author allyson.mesashi
@since 06/08/2018
@version 12.1.17
@return lRet  - Indica se o model poderá ser aberto
/*/
Static Function fVldModel()

Local cCPF 		:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
Local cStat2100	:= ""
Local cStat2200	:= ""
Local lRet 		:= .T.

If ((lIntTaf) .And. (cVerGPE < "9.0"))
	cStat2100	:= TAFGetStat( "S-2100", cCPF )
	cStat2200	:= TAFGetStat( "S-2200", cCPF )

	If cStat2100  == "-1" .And. cStat2200 == "-1"
		Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0398), 1, 0 )//"Atenção"##"Não será possível efetuar o cadastro pois o registro de Admissão ou Carga Inicial deste funcionário ainda não foi efetivado no TAF"
		lRet := .F.
	EndIf


	If lRet .And. !lDPrevPG
		Help( ,, OemToAnsi(STR0245),, OemToAnsi(STR0405 + CRLF + STR0400), 1, 0 )//"Atenção"##"Não será possível efetuar o cadastro pois o dicionário de dados não está atualizado. A existência do campo V7_DPREVPG é obrigatória."                 
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} fWhenConv
Função que habilita edição do campo V7_CONVC
@author allyson.mesashi
@since 06/08/2018
@version 12.1.17
@param oModel	- Objeto do model
@return lRet  	- Indica o status do registro no TAF
/*/
Static Function fWhenConv(oModel)
	Local lRet 		:= .T.

	If !oModel:isInserted() .And. TAFGetStat( "S-2260", AllTrim(SRA->RA_CIC) + SRA->RA_CODUNIC + ";" + oModel:GetValue("V7_CONVC") ) != "-1"
		lRet := .F.
	EndIF

Return lRet  

/*/{Protheus.doc} fWhenDeJo
Função que habilita edição do campo V7_DESCJOR
@author allyson.mesashi
@since 06/08/2018
@version 12.1.17
@param oModel	- Objeto do model
@return lRet  	- Indica o status do registro no TAF
/*/
Static Function fWhenDeJo(oModel)
	Local lRet 		:= .F.

	If Empty(oModel:GetValue("V7_TURNO"))
		lRet := .T.
	EndIF

Return lRet  

/*/{Protheus.doc} fVldPer
Função que verifica os períodos que devem ser criados automaticamente
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fVldPer( aPer )

Local aPerAtu	:= {}
Local aPerNew	:= {}
Local aPerAtual := {}
Local aAreaRFQ	:= RFQ->( GetArea() )
Local aAreaRCH	:= RCH->( GetArea() )
Local aAreaRCF	:= RCF->( GetArea() )
Local aAreaRCG	:= RCG->( GetArea() )
Local cAnoMes	:= ""
Local cChavePes	:= "00"
Local cRoteir	:= fGetRotOrdinar()
Local dDtIni	:= cToD("//")
Local dDtFim	:= cToD("//")
Local dDtPgt	:= cToD("//")
Local lAchouRCH	:= .F.
Local nCont		:= 0
Local nPos		:= 0

fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, cRoteir )

RFQ->( dbSetOrder(1) )//RFQ_FILIAL+RFQ_PROCES+RFQ_PERIOD+RFQ_NUMPAG+DTOS(RFQ_DTINI)+DTOS(RFQ_DTFIM)+RFQ_MODULO
RCH->( dbSetOrder(4) )//RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG
RCF->( dbSetOrder(4) )//RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_ROTEIR+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO
RCG->( dbSetOrder(2) )//RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA+DTOS(RCG_DIAMES)

For nCont := 1 To Len(aPer)
	dDtIni		:= aPer[nCont, 1]
	dDtFim		:= aPer[nCont, 2]
	dDtPgt		:= If(Empty(aPer[nCont, 3]),LastDate(dDtFim),aPer[nCont, 3])
	cAnoMes		:= aPer[nCont, 4]
	cChavePes	:= xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cRoteir + cAnoMes

	If ( lAchouRCH := RCH->( DbSeek( cChavePes ) ) )
		While RCH->( !EoF() ) .And. RCH->RCH_FILIAL+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_PER == cChavePes
			If RCH->RCH_DTPAGO == dDtPgt .and. Empty(RCH->RCH_DTFECH)
				If dDtFim > RCH->RCH_DTFIM
					If ( nPos := aScan( aPerAtu, { |x| x[2] == dDtPgt .And. x[4] == cAnoMes } ) ) == 0
						aAdd( aPerAtu, { dDtFim, dDtPgt, RCH->( Recno() ), RCH->RCH_PER, RCH->RCH_NUMPAG, RCH->RCH_DTINI, RCH->RCH_DTFIM } )
					ElseIf dDtFim > aPerAtu[nPos, 2]
						aPerAtu[nPos, 1] := dDtFim
					EndIf
				EndIf
				lAchouRCH := .T.
				Exit
			Else
				lAchouRCH := .F.
			EndIf
			RCH->( dbSkip() )
		EndDo
	EndIf
	If !lAchouRCH .and. ( Empty(aPerAtual) .or. dDtIni > aPerAtual[1,6] ) //Cria período apenas se for posterior ao período ativo
		If ( nPos := aScan( aPerNew, { |x| x[3] == dDtPgt .And. x[4] == cAnoMes } ) ) == 0
			aAdd( aPerNew, { dDtIni, dDtFim, dDtPgt, cAnoMes } )
		ElseIf dDtFim > aPerNew[nPos, 2]
			aPerNew[nPos, 2] := dDtFim
		EndIf
	EndIf
Next nCont

fGrvPer( aPerNew )
fAtuPer( aPerAtu )

RestArea( aAreaRFQ )
RestArea( aAreaRCH )
RestArea( aAreaRCF )
RestArea( aAreaRCG )

Return

/*/{Protheus.doc} fGrvPer
Função que grava os períodos que devem ser criados automaticamente
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fGrvPer( aPerNew )

Local aSemAux	:= {}
Local cChavePes	:= ""
Local cSemana	:= ""
Local cRoteir	:= fGetRotOrdinar()
Local nCont 	:= 1
Local nPos 		:= 0
Local nSemana	:= 0
Local nTamSem	:= TamSx3("RFQ_NUMPAG")[1]

If !Empty(aPerNew)
	For nCont := 1 To Len(aPerNew)
		If aScan( aSemAux, { |x| AnoMes(x[1]) == AnoMes(aPerNew[nCont, 1]) } ) == 0
			cChavePes	:= xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cRoteir + AnoMes(aPerNew[nCont, 1])
			If RCH->( DbSeek( cChavePes ) )
				While RCH->( !EoF() ) .And. RCH->RCH_FILIAL+RCH->RCH_PROCES+RCH->RCH_ROTEIR+RCH->RCH_PER == cChavePes
					nSemana := Val( RCH->RCH_NUMPAG )
					RCH->( dbSkip() )
				EndDo
				aAdd( aSemAux, { aPerNew[nCont, 1], ++nSemana } )
			Else
				aAdd( aSemAux, { aPerNew[nCont, 1], 1 } )
			EndIf
		EndIf
	Next nCont
	For nCont := 1 To Len(aPerNew)
		If ( nPos := aScan( aSemAux, { |x| AnoMes(x[1]) == AnoMes(aPerNew[nCont, 1]) } ) ) > 0
			cSemana := StrZero(aSemAux[nPos, 2], nTamSem)  
			fGrvRFQ( aPerNew[nCont, 1], aPerNew[nCont, 2], cSemana )
			fGrvRCH( aPerNew[nCont, 1], aPerNew[nCont, 2], aPerNew[nCont, 3], cSemana )
			fGrvRCF( aPerNew[nCont, 1], aPerNew[nCont, 2], cSemana )
			fGrvRCG( aPerNew[nCont, 1], aPerNew[nCont, 2], cSemana )
			nSemana := Val(cSemana)
			aSemAux[nPos, 2] := ++nSemana
		EndIf
	Next nCont
EndIf

Return

/*/{Protheus.doc} fGrvRFQ
Função que grava novo período (tabela RFQ)
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fGrvRFQ( dDataIni, dDataFim, cSemana )

Local cAnoMes	:= AnoMes(dDataIni)
Local cAno		:= SubStr(cAnoMes, 1, 4)
Local cMes		:= SubStr(cAnoMes, 5, 2)
Local cChavePes	:= xFilial("RFQ", SRA->RA_FILIAL) + SRA->RA_PROCES + cAnoMes + cSemana + dToS(dDataIni) + dToS(dDataFim)

If !RFQ->( dbSeek( cChavePes ) ) .And. RFQ->( Reclock("RFQ", .T.) )
	RFQ->RFQ_FILIAL	:= xFilial("RFQ", SRA->RA_FILIAL)
	RFQ->RFQ_PROCES	:= SRA->RA_PROCES
	RFQ->RFQ_MES   	:= cMes
	RFQ->RFQ_ANO   	:= cAno
	RFQ->RFQ_PERIOD	:= cAnoMes
	RFQ->RFQ_NUMPAG	:= cSemana
	RFQ->RFQ_DTINI 	:= dDataIni
	RFQ->RFQ_DTFIM 	:= dDataFim
	RFQ->RFQ_MODULO	:= "GPE"
	RFQ->RFQ_STATUS := "1"
	RFQ->( MsUnlock() )
EndIf

Return

/*/{Protheus.doc} fGrvRCH
Função que grava novo período (tabela RCH)
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fGrvRCH( dDataIni, dDataFim, dDataPgt, cSemana )

Local cAnoMes	:= AnoMes(dDataIni)
Local cAno		:= SubStr(cAnoMes, 1, 4)
Local cMes		:= SubStr(cAnoMes, 5, 2)

If RCH->( Reclock("RCH", .T.) )
	RCH->RCH_FILIAL	:= xFilial("RCH", SRA->RA_FILIAL)
	RCH->RCH_PER	:= cAnoMes
	RCH->RCH_NUMPAG	:= cSemana
	RCH->RCH_PROCES	:= SRA->RA_PROCES
	RCH->RCH_ROTEIR	:= fGetRotOrdinar()
	RCH->RCH_MES   	:= cMes
	RCH->RCH_ANO   	:= cAno
	RCH->RCH_DTINI 	:= dDataIni
	RCH->RCH_DTFIM 	:= dDataFim
	RCH->RCH_DTPAGO	:= dDataPgt
	RCH->RCH_PERSEL	:= "2"
	RCH->RCH_STATUS	:= "0"
	RCH->RCH_MODULO	:= "GPE"
	RCH->RCH_COMPL	:= "2"
	RCH->( MsUnlock() )
EndIf

Return

/*/{Protheus.doc} fGrvRCF
Função que grava novo período (tabela RCF)
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fGrvRCF( dDataIni, dDataFim, cSemana )

Local cAnoMes	:= AnoMes(dDataIni)
Local cAno		:= SubStr(cAnoMes, 1, 4)
Local cMes		:= SubStr(cAnoMes, 5, 2)
Local cChavePes	:= xFilial("RCF", SRA->RA_FILIAL) + cAnoMes + cSemana + cAno + cMes + SRA->RA_PROCES + Space(3) + "@@@" + dToS(dDataIni) + dToS(dDataFim) + "GPE"
Local nUltDia   := f_UltDia(dDataIni)
Local nDiasCal  := IIf(GetMvRH("MV_DIASPER",,"1") == "1", nUltDia, 30)
Local nDiaTrab  := DateWorkDay(dDataIni, dDataFim)
Local nDiaNoTr  := ( dDataFim - dDataIni + 1 ) - nDiaTrab

If !RCF->( dbSeek( cChavePes ) ) .And. RCF->( Reclock("RCF", .T.) )
	RCF->RCF_FILIAL	:= xFilial("RCF", SRA->RA_FILIAL)
	RCF->RCF_MES   	:= cMes
	RCF->RCF_ANO   	:= cAno
	RCF->RCF_PER	:= cAnoMes
	RCF->RCF_PROCES	:= SRA->RA_PROCES
	RCF->RCF_TNOTRA	:= "@@@"
	RCF->RCF_SEMANA	:= cSemana
	RCF->RCF_DTINI 	:= dDataIni
	RCF->RCF_DTFIM 	:= dDataFim
	RCF->RCF_DCALCM	:= nDiasCal
	RCF->RCF_DPERIO	:= Iif(dDataFim - dDataIni + 1 == f_UltDia(dDataIni), nDiasCal, dDataFim - dDataIni + 1)
	RCF->RCF_HRSDIA	:= 8
	RCF->RCF_DIADSR	:= nDiaNoTr / 2
	RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
	RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
	RCF->RCF_DIATRA	:= nDiaTrab
	RCF->RCF_HRSTRA	:= nDiaTrab * 8
	RCF->RCF_DNTRAB	:= nDiaNoTr / 2
	RCF->RCF_DUTILT	:= nDiaTrab
	RCF->RCF_DREFEI	:= nDiaTrab
	RCF->RCF_DALIM	:= nDiaTrab
	RCF->RCF_MODULO	:= "GPE"
	RCF->( MsUnlock() )
EndIf

Return

/*/{Protheus.doc} fGrvRCG
Função que grava novo período (tabela RCG)
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fGrvRCG( dDataIni, dDataFim, cSemana )

Local aColsRCG	:= fMontaRCG( dDataIni, dDataFim )
Local cAnoMes	:= AnoMes(dDataIni)
Local cAno		:= SubStr(cAnoMes, 1, 4)
Local cMes		:= SubStr(cAnoMes, 5, 2)
Local cChavePes	:= ""
Local nCont		:= 0

For nCont := 1 To Len(aColsRCG)
	cChavePes	:= xFilial("RCG", SRA->RA_FILIAL) + SRA->RA_PROCES + cAnoMes + cSemana + Space(3) + "@@@" + dToS(aColsRCG[nCont, 1])
	If !RCG->( dbSeek( cChavePes ) ) .And. RCG->( Reclock("RCG", .T.) )
		RCG->RCG_FILIAL	:= xFilial("RCG", SRA->RA_FILIAL)  
		RCG->RCG_MES	:= cMes
		RCG->RCG_ANO	:= cAno 
		RCG->RCG_PER	:= cAnoMes
		RCG->RCG_PROCES	:= SRA->RA_PROCES
		RCG->RCG_TNOTRA := "@@@" 
		RCG->RCG_SEMANA := cSemana		
		RCG->RCG_DIAMES := aColsRCG[nCont, 1]
		RCG->RCG_TIPDIA := aColsRCG[nCont, 2]
		RCG->RCG_VTRANS := aColsRCG[nCont, 3]
		RCG->RCG_DIFTRA := aColsRCG[nCont, 4]
		RCG->RCG_VREFEI := aColsRCG[nCont, 5]
		RCG->RCG_VALIM  := aColsRCG[nCont, 6]
		RCG->RCG_HRSTRA := aColsRCG[nCont, 7]
		RCG->RCG_HRSDSR := aColsRCG[nCont, 8]		
		RCG->RCG_DTINI	:= dDataIni
		RCG->RCG_DTFIM	:= dDataFim
		RCG->RCG_MODULO	:= "GPE"    
		RCG->( MsUnlock() )
	EndIf
Next nCont

Return

/*/{Protheus.doc} fMontaRCG
Função que monta os registros da tabela RCG (adaptação fNewAcols())
@author allyson.mesashi
@since 22/02/2021
@version 12.1.27
/*/
Static Function fMontaRCG( dDataIni, dDataFim )

Local aColsRCG	:= {}
Local dData		:= cToD("//") 	
Local nCnt		:= 0
Local nDias		:= Max( (dDataFim  - dDataIni ) + 1, 0 )
                         		
aColsRCG 	:= Array(nDias, 8)

For nCnt := 1 To nDias
	If nCnt == 1
		dData		:= dDataIni
	Else
		dData		:= dData + 1
	EndIf
	
	aColsRCG[nCnt, 1] := dData
	aColsRCG[nCnt, 2] := RetTipoDia(dData)  
	If aColsRCG[nCnt, 2] == "4"
		aColsRCG[nCnt, 7]	:= 0
		aColsRCG[nCnt, 8]	:= 8
	EndIf
	aColsRCG[nCnt, 3] := Iif( Alltrim(Upper(Cdow(dData))) == "SATURDAY" .Or. Alltrim(Upper(Cdow(dData))) == "SUNDAY" .Or. RetTipoDia(dData) == "4", "2", "1"  )
	aColsRCG[nCnt, 4] := "2"
	aColsRCG[nCnt, 5] := aColsRCG[nCnt, 4]
	aColsRCG[nCnt, 6] := aColsRCG[nCnt, 4]
	If aColsRCG[nCnt, 2] != "4"
		aColsRCG[nCnt, 7] := Iif( Alltrim(Upper(Cdow(dData))) == "SATURDAY" .Or. Alltrim(Upper(Cdow(dData))) == "SUNDAY", 0, 8 )
		aColsRCG[nCnt, 8] := Iif( Alltrim(Upper(Cdow(dData))) == "SUNDAY", 8, 0 )
	EndIf
Next nCnt   

Return aColsRCG

/*/{Protheus.doc} fAtuPer
Função que grava os períodos que atualiza os períodos devido extensão da data final
@author allyson.mesashi
@since 23/02/2021
@version 12.1.27
/*/
Static Function fAtuPer( aPerAtu )

Local aColsRCG	:= {}
Local aRecRCG	:= {}
Local cChavePes	:= ""
Local cAnoMes	:= ""
Local cAno		:= ""
Local cMes		:= ""
Local cSemana	:= ""
Local dDtIni	:= cToD("//")
Local dDtFimNew	:= cToD("//")
Local dDtFimOld	:= cToD("//")
Local nCont 	:= 1
Local nUltDia   := 0
Local nDiasCal  := 0
Local nDiaTrab  := 0
Local nDiaNoTr  := 0

If !Empty(aPerAtu) .And. MsgYesNo( OemToAnsi( STR0469 + CRLF + STR0470 ), OemToAnsi( STR0076 ) )//"Deseja confirmar a atualização automática em período(s) pré-existente(s) para atualização da data final?"##'Clique em "Sim" para confirmar a atualização ou "Não" para desprezar a alteração. Note que ao negar a atualização, posteriormente deverá ser efetuado ajuste manual do período para compreender o período da convocação'##"Atenção"
	For nCont := 1 To Len(aPerAtu)
		aColsRCG	:= {}
		aRecRCG		:= {}
		cAnoMes		:= aPerAtu[nCont, 4]
		cAno		:= SubStr(cAnoMes, 1, 4)
		cMes		:= SubStr(cAnoMes, 5, 2)		
		cSemana		:= aPerAtu[nCont, 5]	
		dDtIni		:= aPerAtu[nCont, 6]
		dDtFimNew	:= aPerAtu[nCont, 1]
		dDtFimOld	:= aPerAtu[nCont, 7]
		
		//Atualização RCH
		RCH->( dbGoTo(aPerAtu[nCont, 3]) )
		If RCH->( Reclock("RCH", .F.) )
			RCH->RCH_DTFIM := dDtFimNew
			RCH->( Msunlock("RCH") )
		EndIf

		//Atualização RFQ
		cChavePes 	:= xFilial("RFQ", SRA->RA_FILIAL) + SRA->RA_PROCES + cAnoMes + cSemana + dToS(dDtIni) + dToS(dDtFimOld) + "GPE"
		If RFQ->( dbSeek( cChavePes ) ) .And. RFQ->( Reclock("RFQ", .F.) )
			RFQ->RFQ_DTFIM 	:= dDtFimNew
			RFQ->( MsUnlock() )
		EndIf

		//Atualização RCF
		nUltDia   	:= f_UltDia(dDtIni)
		nDiasCal  	:= IIf(GetMvRH("MV_DIASPER",,"1") == "1", nUltDia, 30)
		nDiaTrab  	:= DateWorkDay(dDtIni, dDtFimNew)
		nDiaNoTr  	:= ( dDtFimNew - dDtIni + 1 ) - nDiaTrab
		cChavePes 	:= xFilial("RCF", SRA->RA_FILIAL) + cAnoMes + cSemana + cAno + cMes + SRA->RA_PROCES + Space(3) + "@@@" + dToS(dDtIni) + dToS(dDtFimOld) + "GPE"
		If RCF->( dbSeek( cChavePes ) ) .And. RCF->( Reclock("RCF", .F.) )
			RCF->RCF_DTFIM 	:= dDtFimNew
			RCF->RCF_DCALCM	:= nDiasCal
			RCF->RCF_DPERIO	:= Iif(dDtFimNew - dDtIni + 1 == f_UltDia(dDtIni), nDiasCal, dDtFimNew - dDtIni + 1)
			RCF->RCF_HRSDIA	:= 8
			RCF->RCF_DIADSR	:= nDiaNoTr / 2
			RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
			RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
			RCF->RCF_DIATRA	:= nDiaTrab
			RCF->RCF_HRSTRA	:= nDiaTrab * 8
			RCF->RCF_DNTRAB	:= nDiaNoTr / 2
			RCF->RCF_DUTILT	:= nDiaTrab
			RCF->RCF_DREFEI	:= nDiaTrab
			RCF->RCF_DALIM	:= nDiaTrab
			RCF->( MsUnlock() )
		EndIf

		//Atualização RCG
		RCG->( dbSetOrder(5) )//RCG_FILIAL+RCG_PER+RCG_SEMANA+RCG_ANO+RCG_MES+RCG_PROCES+RCG_TNOTRA+DTOS(RCG_DTINI)+DTOS(RCG_DTFIM)+RCG_MODULO
		cChavePes	:= xFilial("RCG", SRA->RA_FILIAL) + cAnoMes + cSemana + cAno + cMes + SRA->RA_PROCES + "@@@" + dToS(dDtIni) + dToS(dDtFimOld) + "GPE"
		If RCG->( dbSeek( cChavePes ) )
			While RCG->( !EoF() ) .And. RCG->RCG_FILIAL+RCG->RCG_PER+RCG->RCG_SEMANA+RCG->RCG_ANO+RCG->RCG_MES+RCG->RCG_PROCES+RCG->RCG_TNOTRA+dToS(RCG->RCG_DTINI)+dToS(RCG->RCG_DTFIM)+RCG->RCG_MODULO == cChavePes
				aAdd( aRecRCG, RCG->( Recno() ) )
				RCG->( dbSkip() )
			EndDo
		EndIf
		For nCont := 1 To Len(aRecRCG)
			RCG->( dbGoTo(aRecRCG[nCont]) )
			If RCG->( Reclock("RCG", .F.) )
				RCG->RCG_DTFIM	:= dDtFimNew
				RCG->( Msunlock("RCG") )
			EndIf
		Next nCont
		RCG->( dbSetOrder(2) )//RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA+DTOS(RCG_DIAMES)
		aColsRCG	:= fMontaRCG( dDtFimOld+1, dDtFimNew )
		For nCont := 1 To Len(aColsRCG)
			cChavePes	:= xFilial("RCG", SRA->RA_FILIAL) + SRA->RA_PROCES + cAnoMes + cSemana + Space(3) + "@@@" + dToS(aColsRCG[nCont, 1])
			If !RCG->( dbSeek( cChavePes ) ) .And. RCG->( Reclock("RCG", .T.) )
				RCG->RCG_FILIAL	:= xFilial("RCG", SRA->RA_FILIAL)  
				RCG->RCG_MES	:= cMes
				RCG->RCG_ANO	:= cAno 
				RCG->RCG_PER	:= cAnoMes
				RCG->RCG_PROCES	:= SRA->RA_PROCES
				RCG->RCG_TNOTRA := "@@@" 
				RCG->RCG_SEMANA := cSemana		
				RCG->RCG_DIAMES := aColsRCG[nCont, 1]
				RCG->RCG_TIPDIA := aColsRCG[nCont, 2]
				RCG->RCG_VTRANS := aColsRCG[nCont, 3]
				RCG->RCG_DIFTRA := aColsRCG[nCont, 4]
				RCG->RCG_VREFEI := aColsRCG[nCont, 5]
				RCG->RCG_VALIM  := aColsRCG[nCont, 6]
				RCG->RCG_HRSTRA := aColsRCG[nCont, 7]
				RCG->RCG_HRSDSR := aColsRCG[nCont, 8]		
				RCG->RCG_DTINI	:= dDtIni
				RCG->RCG_DTFIM	:= dDtFimNew
				RCG->RCG_MODULO	:= "GPE"    
				RCG->( MsUnlock() )
			EndIf
		Next nCont
	Next nCont
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerSit()
Função que verifica a situação de folha
@author  Allyson Luiz Mesashi
@since   29/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVerSit( oModel )

Local lRet		:= .T.
Local nOper 	:= 0
Local oSV7Model	:= oModel:GetModel("SV7MdGrid")

nOper := oSV7Model:GetOperation()

If (nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE) .And. SRA->RA_SITFOLH == "D"
	Help( " ", 1, OemToAnsi(STR0245), Nil, OemToAnsi(STR0489)+CRLF+OemToAnsi(STR0490), 1, 0 )//"Atenção"##"Não é possível realizar convocações para funcionário com situação desligado."##"Obs.: o cadastro será aberto no modo visualização."
	lRet := .F.
EndIf

Return lRet

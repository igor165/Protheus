#INCLUDE "FINA023.ch"
#Include "PROTHEUS.CH"
#Include 'FWMVCDef.ch'

 
//Fonte meramente para reserva do nome
Function FINA023()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FW1' )
oBrowse:SetDescription(STR0001)  //"Processos de Bloqueio - Contas a Receber"
oBrowse:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pelo menu da rotina 

@author pequim
@since 18/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.FINA023"	OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Visualizar" //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.FINA023"	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir" //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FINA023"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar" //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.FINA023"	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir" //"Excluir"
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pequim

@since 28/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'FW1')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetModel(ModelDef())
oView:AddField('FW1FORM' , oStr1,'FW1MASTER' ) 
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FW1FORM','BOXFORM1')
oView:EnableTitleView('FW1FORM' , STR0001)  //"Processos de Bloqueio - Contas a Receber" 


Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pequim

@since 28/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel:= MPFormModel():New('FINA023')
Local oStruFW1 := FWFormStruct( 1, 'FW1', /*bAvalCampo*/, /*lViewUsado*/ )
 
oModel:addFields('FW1MASTER',,oStruFW1)
oModel:SetVldActivate( {|oModel| AF023VLMod(oModel) } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Validação do carregamento do Model

@author pequim

@since 28/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AF023VLMod(oModel)
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If (nOperation == MODEL_OPERATION_UPDATE ) .And. FW1->FW1_CODIGO <= "1000"
	Help(" ",1,"AF023ALT",,STR0007  ,1,0) //"Não é possivel realizar manutenção nos processos padrões do sistema."
	lRet := .F.
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .And. FW1->FW1_CODIGO <= "1000"
	Help(" ",1,"AF023DEL1",,STR0008  ,1,0) //"Não é possivel excluir processos padrões do sistema."
	lRet := .F.
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .And. FW1->FW1_CODIGO > "1000"
	FW2->(DbSetOrder(2))	//FW2_FILIAL+FW2_CODIGO
	If FW2->(MsSeek(xFilial("FW2")+FW1->FW1_CODIGO))
		Help(" ",1,"AF023DEL2",,STR0009+CRLF+; //"Não é possivel excluir processos de bloqueio que estejam relacionados a uma situação de cobrança."
								STR0010  ,1,0) //"Verifique o cadastro de situações de cobrança."
		lRet := .F.
	Endif
EndIf

Return lRet


//-------------------------------------------------------------------
/*/
{Protheus.doc} Fa023Cod
Realiza a Validação do campo FW1_CODIGO     

@author pequim

@since 26/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fa023Cod()

Local oModel		:= FWModelActive()
Local cCodigo 		:= oModel:GetValue("FW1MASTER","FW1_CODIGO")
Local lRet := .T.
Local nCodigo := 0

nCodigo := Val(cCodigo) 

If !ExistChav("FW1") .or. !FreeForUse("FW1",cCodigo) .or. nCodigo <= 1000
	If nCodigo <= 1000
		Help( " ", 1, "F023CODIGO",,STR0011+CRLF+; //"Os códigos menores que 1000 são reservados para processos padrões do sistema."
									STR0012, 1, 0 ) //"Utilize um código superior a 1000 para rotinas personalizadas."
	Endif
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} Fa023Cod
Realiza a Validação do campo FW1_CODIGO     

@author pequim

@param	Tipo de retorno ((obrigatório):	“1” = Lógico ou  “2” = Expressão para filtro
@param	Código do processo a ser verificado (obrigatório)
@param	Código da situação de cobrança a ser verificada (obrigatório apenas para processo com tipo de retorno 1 (lógico))
@param	Variável lógica (lHelp) informando se deve ser apresentado mensagem ao usuário (opcional, tendo efeito apenas para processo com tipo de retorno 1 (lógico))
 
@since 26/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F023VerBlq(cTipo,cCodProc,cSituaca,lHelp)

	Local uRet 		 := ""
	Local cQuery	 := ""
	Local cAliasQry  := "" 
	Local aArea 	 := {}
	Local cAlias 	 := Alias()
	Local nTamSx3    := TamSX3("E1_SITUACA")[1]
	Local cCartTecF	 := PadR(SuperGetMV("MV_CARTECF",, ""), nTamSx3) 
	Local cDevTecF   := PadR(SuperGetMV("MV_DEVTECF",, ""), nTamSx3)
	Local cTechFin   := ""
	Local lFin136	 := FwIsInCallStack('FINI136O')
	Local lRskJobCom := FwIsInCallStack('RSKJobCommand')
	
	DEFAULT cTipo 		:= "1"
	DEFAULT cCodProc	:= ""
	DEFAULT cSituaca	:= ""
	DEFAULT	lHelp		:= .F.

	cTechFin := cCartTecF + "|" + cDevTecF

	If !Empty(cTipo) .and. !Empty(cCodProc)
		If cTipo == "1"	//Retorno Lógico - validação unitária
			If (!Empty(cCartTecF) .Or. !Empty(cDevTecF) ) .And. !lFin136 .And. (!Empty(cSituaca) .And. cSituaca $ cTechFin) //Validação TechFin
				uRet := .F.
				Help("", 1, "F23CARTECF", , STR0015 /*"Títulos em carteira TECHFIN só podem ser movimentados pelo TOTVS Antecipa."*/, 1,,,,,,, {STR0014 /*"Acesse a plataforma TOTVS Antecipa e execute a operação."*/})
			Else
				uRet := .T.
				If !Empty(cSituaca) .And. !lFin136 .And. !lRskJobCom //Validação TECHFIN, movimentação pelo TOTVS antecipa / risk não valida bloqueio.
					//Verifico se a situação de cobrança controla bloqueio de movimentos CR
					FRV->(dbSetorder(1)) //FRV_FILIAL+FRV_CODIGO
					If FRV->(MsSeek(xFilial("FRV")+cSituaca)) .and. FRV->FRV_BLQMOV == '1' //Controla bloqueio de movimento CR
						FW2->(DbSetOrder(1))	//FW2_FILIAL+FW2_SITUAC+FW2_CODIGO
						If FW2->(MsSeek(xFilial("FW2")+cSituaca+cCodproc)) //Controla bloqueio de movimento CR para determinado processo
							If lHelp
								Help( " ", 1, "F023BLQMOV",,STR0013+CRLF+; //"A situação de cobrança deste título não permite a realização deste processo. "
															STR0010, 1, 0 ) //"Verifique o cadastro de situações de cobrança."
							Endif
							uRet := .F.
						Endif
					Endif  
				Endif
			EndIf
		ElseIf cTipo == "2"		//Retorna expressão de filtro					
			aArea	:= GetArea()
			uRet := ""
			cAliasQry	:= GetNextAlias()
					
			cQuery := "SELECT FW2_SITUAC " 
			cQuery += "FROM " + RetSQLTab('FW2')
			cQuery += " JOIN " + RetSQLTab('FRV') + " ON "
			cQuery += 		"FRV_CODIGO = FW2_SITUAC "
			cQuery += " WHERE "
			cQuery += 		"FRV_BLQMOV = '1' AND "				//Apenas as situações de cobrança que controlam bloqueio de movto CR
			cQuery +=		"FW2_CODIGO = '"+cCodProc+"' AND "  //Considera apenas as que possuem controle para o processo a ser verificado
			cQuery += RetSqlCond("FW2") + " AND "
			cQuery += RetSqlCond("FRV")
			cQuery += "ORDER BY FW2_SITUAC"

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
			dbSelectArea(cAliasQry)

			DbGotop()

			If !EOF() .AND. !BOF()
				While !(cAliasQry)->(Eof())
					uRet += IIF(Empty(uRet),"","|") + (cAliasQry)->FW2_SITUAC
					(cAliasQry)->(dbSkip())
				Enddo
			Endif

			If !Empty(cCartTecF) .and. !(cCartTecF $ uRet)
				uRet += IIF(Empty(uRet),"","|") + cCartTecF
			EndIf

			If !Empty(cDevTecF) .and. !(cDevTecF $ uRet)
				uRet += IIF(Empty(uRet),"","|") + cDevTecF
			EndIf

			dbSelectArea(cAliasQry)
			dbCloseArea()
			fErase(cAliasQry + OrdBagExt())
			fErase(cAliasQry + GetDbExtension())
			dbSelectArea(cAlias)
			RestArea(aArea)
		Endif
	Endif

Return uRet

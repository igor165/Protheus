#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPC300G.CH'

/*/{Protheus.doc} GTPC300G
Rotina responsavel pela Finalização/Reabertura da Viagem
@type function
@author jacomo.fernandes
@since 04/02/2019
@version 1.0
@param cTipo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300G(cTipo)
Local lMonitor	:= GC300GetMVC('IsActive')
Local oMolGYN	:= Nil
Local cTipGyn   := ''
Local cApuCon   := ''
Local nOpc 		:= 0
Local cTitulo	:= I18n(STR0023,{If(cTipo == '1',STR0018,STR0022)})//'#1 Viagem'#"Finalizar","Reabrir"
Local cAviso	:= I18n(STR0024,{If(cTipo =='1',STR0018,STR0022)})//'Deseja #1 a viagem posicionada ou todas ?'#"Finalizar","Reabrir"

Default cTipo	:= "1" //Finaliza Viagem

If lMonitor
	oMolGYN	:= GC300GetMVC('M'):GetModel("GYNDETAIL")
	cTipGyn := oMolGYN:GetValue('GYN_TIPO')
	cApuCon := oMolGYN:GetValue('GYN_APUCON')

	nOpc := Aviso( cTitulo,	cAviso, { STR0003, STR0004,STR0005},1)  //Posicionada  //Todas // Cancelar 

	if nOpc = 1
		if cTipo == '2' .and. cTipGyn == '3' .and. !Empty(cApuCon)
			MsgAlert(STR0027, STR0026) //'Esta viagem não pode ser reaberta.', 'Viagem Apurada'
			Return
		endif
	endif
	
	If nOpc <> 3 //Se não cancelar o aviso, executa a função
		AtualizaViagem(cTipo,nOpc)
	Endif
	
Else
	FwAlertHelp(cTitulo,STR0006) //"Finalizar Viagens" //"Esta rotina só funciona com monitor ativo"
EndIf
	
Return


/*/{Protheus.doc} AtualizaViagem
Função responsavel pela Finalização/Reabertura da Viagem
@type function
@author jacomo.fernandes
@since 04/02/2019
@version 1.0
@param cTipo, character, (Descrição do parâmetro)
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualizaViagem(cTipo,nOpc)
Local lRet			:= .T.
Local oViewMonitor	:= GC300GetMVC('V')
Local oModelMonitor	:= GC300GetMVC('M')
Local oModelGYN 	:= oModelMonitor:GetModel("GYNDETAIL")
Local nLinGYN		:= oModelGYN:GetLine()
Local oGTPLog		:= GTPLog():New(I18n(STR0023,{If(cTipo == '1',STR0018,STR0022)}))//'#1 Viagem'#"Finalizar","Reabrir"
Local n1			:= 0
Local nIni			:= 0
Local nFim			:= 0

If nOpc == 1 // Posicionada
	nIni	:= nLinGYN
	nFim	:= nLinGYN
ElseIf nOpc == 2 //Todas
	nIni	:= 1
	nFim	:= oModelGYN:Length()
Else
	lRet := .F.
Endif

For n1 := nIni to nFim
	oModelGYN:GoLine(n1)

	If !VldOG56(oModelGYN,cTipo) 
		If VldViagem(oModelGYN,cTipo,oGTPLog)
			oModelGYN:LoadValue("GYN_FINAL",cTipo)

			If oModelGYN:GetValue("GYN_CANCEL") == '1' 
				oModelGYN:LoadValue("GYN_KMREAL", 0 )
			ElseIf Empty( oModelGYN:GetValue("GYN_KMREAL") )
				oModelGYN:LoadValue("GYN_KMREAL",oModelGYN:GetValue("GYN_KMPROV") )
			EndIF

			If cTipo == '1'
				If AtuaOcorr(oModelGYN:GetValue("GYN_FILIAL"),oModelGYN:GetValue("GYN_CODIGO"))
					oModelGYN:LoadValue("GYN_STSOCR",'1' )
				EndIf
			EndIf

			GC300SetLegenda(oModelGYN)
		Endif
	Else 
		VldViagem(oModelGYN,cTipo,oGTPLog)
		Loop
	Endif
Next

If oGTPLog:HasInfo()
	oGTPLog:ShowLog()
Endif

oGTPLog:Destroy()

oModelGYN:GoLine(nIni) //Caso Posicionada, volta pelo registro posicionado, se não, volta pro primeiro registro
oViewMonitor:Refresh("GYNDETAIL")
oViewMonitor:Refresh("G55DETAIL")
oViewMonitor:Refresh("GQEDETAIL")

GTPDestroy(oGTPLog)

Return

/*/{Protheus.doc} VldViagem
(long_description)
@type function
@author jacomo.fernandes
@since 04/02/2019
@version 1.0
@param oModelGYN, objeto, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param oGTPLog, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldViagem(oModelGYN,cTipo,oGTPLog)
Local lRet		:= .T.
Local cViagem	:= oModelGYN:GetValue("GYN_CODIGO")
Local cMsgErro	:= ""

If lRet .and. oModelGYN:GetValue("GYN_FINAL") == cTipo
	lRet		:= .F.
	cMsgErro	:= STR0017 + If(cTipo == '1',STR0018,STR0019) //"encontra-se "#"Finalizada"#"Aberta"
Endif

If lRet .and. cTipo == '1' .and. oModelGYN:GetValue("GYN_CONF") <> "1"
	lRet := .F.
	cMsgErro	:= STR0014 //"não foi confirmada. Confirme primeiramente a viagem para depois finaliza-la"
Endif

If lRet .and. cTipo == '2' .and. !VldConfRec(cViagem)
	lRet := .F.
	cMsgErro	:= STR0015 //"possui colaboradores com horarios confirmados na apuração"
Endif

If lRet .and. cTipo == '2' .and. oModelGYN:GetValue("GYN_TIPO") == '2' .and. !VldAlocExt(cViagem)
	lRet := .F.
	cMsgErro	:= STR0016 //"possui colaboradores com horarios de alocação extraordinária cadastrado. Exclua primeiramente às alocações antes de reabrir a viagem"
Endif

If lRet .and. cTipo == '1' .and. oModelGYN:GetValue('GYN_STSOCR') == '2'
	lRet := .F.
	cMsgErro	:= STR0025 //"não pode ser finalizada, ocorrência do tipo operacional em andamento"
Endif

If lRet .and. !Empty(oModelGYN:GetValue("GYN_APUCON"))
	lRet		:= .F.
	cMsgErro	:= STR0017 + If(cTipo == '1',STR0018, STR0028) //"encontra-se "#"Finalizada"#"Aberta"
Endif

If !lRet 
	oGTPLog:SetText(I18n(STR0020,{cViagem,cMsgErro}) )//"A Viagem: #1 #2"
Else
	oGTPLog:SetText(I18n(STR0021,{cViagem}) )//"A Viagem: #1 foi atualizada com sucesso"
Endif

Return lRet


/*/{Protheus.doc} VldConfRec
(long_description)
@type function
@author jacomo.fernandes
@since 04/02/2019
@version 1.0
@param cCodVia, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldConfRec(cViagem)

	Local lRet		:= .T.
	Local cAliasGQE	:= GetNextAlias()

	BeginSQL Alias cAliasGQE
						
		select COUNT(GYN.GYN_CODIGO) AS TOTAL 
		From %Table:GYN% GYN
		WHERE
			GYN.GYN_FILIAL = %xFilial:GYN%
			AND GYN.GYN_CODIGO = %Exp:cViagem%
			AND GYN.%NotDel%
			AND EXISTS (Select 1 AS TOTAL
						From %Table:GQE% GQE
						Where 
							GQE_FILIAL 		= GYN.GYN_FILIAL
							AND GQE.GQE_VIACOD	= GYN.GYN_CODIGO
							AND GQE.GQE_TRECUR  	= '1' 			
							AND GQE_CONF 			= '1' 			
							AND GQE.%NotDel% 
							
						UNION ALL
						 
						Select  1 AS TOTAL
						From %Table:GQK% GQK
						Where
							GQK.GQK_FILIAL = GYN.GYN_FILIAL
							AND GQK.GQK_CODVIA = GYN.GYN_CODIGO
							AND GQK.GQK_CONF = '1'
							AND GQK.%NotDel%
						)
	EndSQL
	
	lRet	:= (cAliasGQE)->TOTAL == 0
	
	(cAliasGQE)->(DbCloseArea())

Return(lRet)

/*/{Protheus.doc} VldAlocExt
(long_description)
@type function
@author jacomo.fernandes
@since 04/02/2019
@version 1.0
@param cViagem, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldAlocExt(cViagem)
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()

	BeginSQL Alias cAliasTmp
		Select COUNT(GQK_CODVIA) AS TOTAL
		From %Table:GQK% GQK
		Where
			GQK.GQK_FILIAL = %xFilial:GQK%
			AND GQK.GQK_CODVIA = %Exp:cViagem%
			AND GQK.%NotDel%				
		
	EndSQL
	
	lRet := (cAliasTmp)->TOTAL == 0
	
	(cAliasTmp)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} AtuaOcorr
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 16/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodFil, characters, descricao
@param cCodVia, characters, descricao
@type function
/*/
Static Function AtuaOcorr(cCodFil, cCodVia)
Local aArea     := GetArea()
Local cAliasTmp	:= GetNextAlias()
Local lRet      := .F.

BeginSQL Alias cAliasTmp
	Select R_E_C_N_O_ AS RECNOG56
	From %Table:G56% G56
	Where
		G56.G56_FILIAL = %Exp:cCodFil%
		AND G56.G56_VIAGEM = %Exp:cCodVia%
		AND G56.%NotDel%				
	
EndSQL

While (cAliasTmp)->(!(EOF()))
	G56->(DbGoTo((cAliasTmp)->RECNOG56))
	RecLock("G56",.F.)
	G56->G56_STSOCR := "1"
	G56->(MsUnlock())
	(cAliasTmp)->(DbSkip())
	lRet := .T.
End
(cAliasTmp)->(DbCloseArea())


If lRet .AND. GYN->(DbSeek(XFILIAL("GYN") + cCodVia))
	RecLock("GYN",.F.)
	GYN->GYN_STSOCR := "1"
	GYN->(MsUnlock())
EndIf

RestArea(aArea)
Return lRet

/*/
 * {Protheus.doc} VldOG56()
 * Retorna .T. se existir ocorrencia do tipo Operacional na viagem.
 * type  Static Function
 * author Eduardo Ferreira
 * since 28/02/2020
 * version  12.1.30
 * param oMdl,cTipo
 * return lRet
/*/
Static Function VldOG56(oMdl,cTipo)
local cCodgyn := oMdl:GetValue('GYN_CODIGO')
Local cAlias  := GetNextAlias()
Local lRet    := .F.

If cTipo == '1'
	DbSelectArea('G56')
	G56->(DbSetOrder(3)) //G56_FILIAL+G56_VIAGEM                                                                                                                                                                                                                                                                                     

	If G56->(dbSeek(xFilial("G56")+cCodgyn))
		BeginSql Alias cAlias 
			SELECT
				G6Q.G6Q_OPERAC
			FROM
				%Table:G56% G56 JOIN %Table:G6Q% G6Q
				ON  G6Q.G6Q_FILIAL = G56.G56_FILIAL
				AND G6Q.G6Q_CODIGO = G56.G56_TPOCOR
				AND G6Q.%NotDel%
			WHERE 
				G56.G56_FILIAL = %xFilial:G56%
				AND G56.G56_VIAGEM = %Exp:cCodgyn%
				AND G6Q.G6Q_OPERAC = 'T'
				AND G56.%NotDel%
		EndSql

		lRet := !(cAlias)->(Eof()) 

		(cAlias)->(DbCloseArea())
	EndIf  
EndIf 

Return lRet

#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'GTPA008X.CH' 

Function GTPA008X(lJob)
Local cAliasTmp	:= Nil
Local lRet		:= .T.
Local aAreaGYG	:= GYG->( GetArea() )

Local oMdl008	:= FwLoadModel('GTPA008')
Local oMdlGYG	:= oMdl008:GetModel('GYGMASTER')
Local oStrGYG	:= oMdlGYG:GetStruct()
Local nOpc		:= 0

Local oGTPLog	:= GTPLog():New(STR0001,lJob/*lSalva*/,!lJob/*lShow*/)//"Integracao Colaborador RH"
Local cFilOld	:= cFilAnt

Local cFilSRA	:= ""
Local cMatric	:= ""
Local cCPF		:= ""
Local cNome		:= ""

Local nImpOk	:= 0
Local nImpErro	:= 0


Default lJob	:= Iif(Select("SX6")==0,.T.,.F.)

oStrGYG:SetProperty('*', MODEL_FIELD_WHEN, {||.T.})

If Pergunte('GTPA008I',!lJob)
	cAliasTmp := BuscaFuncionarios(lJob)
	
	oGTPLog:SetText(STR0002             )//'Iniciado processo de importação'
    oGTPLog:SetText("")
	oGTPLog:SetText(STR0003             )//"Dados utilizados para busca:"
    oGTPLog:SetText(STR0004 + MV_PAR01  )//"Cargo de:"
    oGTPLog:SetText(STR0005 + MV_PAR02  )//"Cargo até:"
    oGTPLog:SetText(STR0006 + MV_PAR03  )//"Função de:"
    oGTPLog:SetText(STR0007 + MV_PAR04  )//"Função até:"
    oGTPLog:SetText(STR0008 + IF(MV_PAR05==1, STR0009,STR0010) )//"Filtrar Matriculas sem Colaborador:"##"Sim"##"Não"
    oGTPLog:SetText("")

	GYG->(DbSetOrder(2)) //GYG_FILIAL+GYG_FUNCIO+GYG_CPF+GYG_FILSRA
	While (cAliasTmp)->(!EoF())
		cFilSRA	:= (cAliasTmp)->RA_FILIAL
		cMatric	:= (cAliasTmp)->RA_MAT
		cCPF	:= (cAliasTmp)->RA_CIC
		cNome	:= AllTrim((cAliasTmp)->RA_NOME)
		
		cFilAnt := cFilSRA 
		
		If !GYG->(DbSeek(xFilial('GYG')+cMatric+Padr(cCPF,TamSx3('GYG_CPF')[1])))
			nOpc	:= MODEL_OPERATION_INSERT
			lRet	:= .T.
		ElseIf GYG->GYG_FILSRA <> cFilSRA
			nOpc	:= MODEL_OPERATION_UPDATE
			lRet	:= .T.
		Else
			lRet	:= .F.
		Endif
		
		If lRet
			oMdl008:SetOperation(nOpc)
			If oMdl008:Activate()
				If nOpc == MODEL_OPERATION_INSERT .and. Empty(oMdlGYG:GetValue('GYG_CODIGO')) 
					lRet := oMdlGYG:SetValue('GYG_CODIGO',GtpXeNum('GYG','GYG_CODIGO'))
				Endif
				
				lRet := lRet ;
						.and. oMdlGYG:SetValue('GYG_FUNCIO'	,cMatric);
						.and. oMdlGYG:SetValue('GYG_FILSRA'	,cFilSRA);
						.and. oMdlGYG:SetValue('GYG_NOME'	,cNome);
						.and. oMdlGYG:SetValue('GYG_CPF'	,cCPF);
						.and. oMdlGYG:SetValue('GYG_RECCOD'	,'01')
						
				If lRet .and. oMdl008:VldData() .and. oMdl008:CommitData()
					nImpOk++
					oGTPLog:SetText(I18n(STR0011,{cFilSRA,cMatric,cNome}))//'Colaborador filial: #1, matricula #2, nome: #3 importado com sucesso'
				Else
					nImpErro++
					oGTPLog:SetText(I18n(STR0012,{cFilSRA,cMatric,cNome})) //'Colaborador filial: #1, matricula #2, nome: #3 importado com erro'
					oGTPLog:SetText(I18n(STR0013,{JurShowErro( oMdl008:GetErrorMessage(), , , .F.)}))//'Erro: #1'
				Endif
				 			
				oMdl008:DeActivate()
			Endif
		Else
			oGTPLog:SetText(I18n(STR0013,{cFilSRA,cMatric,cNome}))//'Colaborador filial: #1, matricula #2, nome: #3 já cadastrado, sem necessidade de mudanças'
		Endif
		(cAliasTmp)->(DbSkip())
	End
	
	oGTPLog:SetText(STR0015                             )//"Finalizado processo de importação"
	oGTPLog:SetText(STR0016+ cValToChar(nImpOk+nImpErro))//"Total de Funcionários importados/alterados: "
	oGTPLog:SetText(STR0017+ cValToChar(nImpOk)         )//"Importações com Sucesso: "
	oGTPLog:SetText(STR0018+ cValToChar(nImpErro)       )//"Importações com Erro: "
	
	
	oGTPLog:ShowLog()
	oGTPLog:Destroy()
Endif

oMdl008:Destroy()

cFilAnt := cFilOld 

RestArea( aAreaGYG )
	
GTPDestroy(oMdl008)
GTPDestroy(aAreaGYG)
GTPDestroy(oGTPLog)

Return

/*/{Protheus.doc} BuscaFuncionarios
(long_description)
@type function
@author jacomo.fernandes
@since 11/02/2019
@version 1.0
@param lJob, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function BuscaFuncionarios(lJob)
Local cAliasTmp	:= GetNextAlias()

Local cJoinGYG	:= "%%"
Local cQryFunc	:= ""
Local cQryCarg	:= ""
Local cWhere	:= ""

Local lOnlyNew	:= .T.

If lJob
	cQryCarg :=	" AND SRA.RA_CARGO IN "+FormatIn(GTPGetRules("LISTACARGO",.F.),";") + " "
	cQryFunc := " AND SRA.RA_CODFUNC IN "+ FormatIn(GTPGetRules("LISTAFUNCA",.F.),";") + " "
Else
	cQryCarg :=	" AND SRA.RA_CARGO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQryFunc := " AND SRA.RA_CODFUNC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	lOnlyNew := MV_PAR05 == 1
Endif

cWhere += cQryCarg
cWhere += cQryFunc

If lOnlyNew
	cJoinGYG := "%"
	cJoinGYG += " Left Join "+RetSqlName("GYG")+" GYG ON "
	cJoinGYG += 	" GYG.GYG_FILSRA = SRA.RA_FILIAL "
	cJoinGYG += 	" AND GYG.GYG_FUNCIO = SRA.RA_MAT "
	cJoinGYG += 	" AND GYG.D_E_L_E_T_ = ' ' "
	cJoinGYG += "%"
	cWhere	+= " AND GYG.GYG_CODIGO IS NULL "
Endif

cWhere := '%'+cWhere+'%'

BeginSql Alias cAliasTmp
	
	Select 
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_CIC,
		SRA.RA_NOME
	From %Table:SRA% SRA
		%Exp:cJoinGYG%
	Where
		SRA.RA_FILIAL LIKE %Exp:AllTrim(xFilial('GYG'))% || '%'
		AND SRA.RA_SITFOLH NOT IN ('D','T')
		%Exp:cWhere%
		and SRA.%NotDel%
	Order By
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_CIC,
		SRA.RA_NOME
EndSql

Return cAliasTmp

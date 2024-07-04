#Include "GTPC300I.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'


/*/{Protheus.doc} GTPC300I
Rotina responsavel pela remoção do recurso da viagem
@type function
@author jacomo.fernandes
@since 01/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300I()
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0001 },{.T., STR0002 },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }	//"Salvar Simulação"### //"Confirmar" //"Fechar"
	FWExecView( STR0003, 'VIEWDEF.GTPC300I', MODEL_OPERATION_INSERT, , { || .T. },,,aButtons,/*{|| GC300EFech()} */)//"Alocação de Recursos" //"Remover"

Return()

/*/{Protheus.doc} ViewDef
Definição da View do MVC
@type function
@author Fernando Radu Muscalu
@since 18/08/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

Local oView			:= FwLoadView('GTPC300E')
Local oModel		:= oView:GetModel() 
	GC300IStruc(oView)
	oModel:SetCommit({|oMdl| Gc300IGrv(oMdl) })
	
	oView:AddUserButton( "Marque/Desmarque todos", "", {|oView|G300iCMkAll(oView)}) //"Marque/Desmarque todos"
	
Return(oView)


/*/{Protheus.doc} G300iCMkAll
(long_description)
@type function
@author jacom
@since 18/04/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G300iCMkAll(oView)
Local oModel	:= oView:GetModel()
Local oMdlVia	:= oModel:GetModel('G55DETAIL') 
Local n1		:= 0
Local lCheck	:= If(!oMdlVia:GetValue('G55_MARK'),.T.,.F.) 

For n1 := 1 To oMdlVia:Length()
	oMdlVia:GoLine(n1)
	oMdlVia:SetValue('G55_MARK',lCheck)
	oModel:GetErrorMessage(.T.)	
Next 
oMdlVia:GoLine(1)

Return


/*/{Protheus.doc} GC300IStruc
(long_description)
@type function
@author jacomo.fernandes
@since 01/02/2019
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300IStruc(oView)
Local oStrGrdView	:= oView:GetViewStruct('VW_G55DETAIL')
Local oStrGrdMdl	:= oView:GetModel():GetModel('G55DETAIL'):GetStruct()
Local bFldVld		:= {|oMdl,cField,cNewValue,cOldValue|GTPc300iVld(oMdl,cField,cNewValue,cOldValue) }

oStrGrdMdl:SetProperty("G55_MARK",MODEL_FIELD_VALID,bFldVld)


oStrGrdView:AddField(	"G55_MARK",;				// [01]  C   Nome do Campo
				"00",;						// [02]  C   Ordem
				"",;						// [03]  C   Titulo do campo
				"",;						// [04]  C   Descricao do campo
				{STR0004},;					// [05]  A   Array com Help // STR0004 //"Selecionar"
				"CHECK",;					// [06]  C   Tipo do campo
				"",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.T.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo


Return

/*/{Protheus.doc} GTPc300iVld
(long_description)
@type function
@author jacomo.fernandes
@since 01/02/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param cNewValue, character, (Descrição do parâmetro)
@param cOldValue, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static function GTPc300iVld(oMdl,cField,cNewValue,cOldValue)
Local lRet			:= .T.
Local oModel		:= oMdl:GetModel()
Local aAreaGYN		:= GYN->(GetArea())

GYN->(DbSetOrder(1))
GQK->(DbSetOrder(1))
			
Do Case
	Case cField == 'G55_MARK'
		If oMdl:GetValue("GYN_FINAL") == "1"
			lRet  := .F.
			oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GTPc300iVld", "Viagem se encontra finalizada","Selecione outra seção ou reabra a viagem")
		Endif

		If lRet .and. oMdl:GetValue('TABELA') == 'GQE' 
			If GYN->(DbSeek(xFilial('GYN')+oMdl:GetValue('G55_CODVIA'))) .and. GYN->GYN_FINAL == '1'
				lRet := .F.
				oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GTPc300iVld", STR0005,STR0006) //"Viagem selecionada se encontra finalizada" //"Selecione outra seção"
			Endif
		ElseIf lRet .and. GQK->(DbSeek(xFilial('GQK')+oMdl:GetValue('G55_CODVIA'))) 
			If GQK->GQK_MARCAD == '1'
				lRet := .F.
				oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GTPc300iVld", "Alocação Extraordinária já enviada para o RH","Selecione outra seção")
			ElseIf !Empty(GQK->GQK_CODVIA) 
				lRet := .F.
				oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GTPc300iVld", "Essa alocação pertence à uma viagem extraordinária","Realize a operação de remoção na rotina de Alocação de Viagem Especial")
			Endif
		Endif
EndCase


RestArea(aAreaGYN)

Return lRet 

/*/{Protheus.doc} Gc300IGrv
(long_description)
@type function
@author jacomo.fernandes
@since 01/02/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300IGrv(oMdl)

Local lRet		:= .T.

Local oMdlRec	:= oMdl:GetModel( 'GQEMASTER' )
Local oMdlVia	:= oMdl:GetModel( 'G55DETAIL' )

Local cTpRecur	:= oMdlRec:GetValue("GQE_TRECUR")
Local cRecurs	:= oMdlRec:GetValue("GQE_RECURS")
Local cTerceiro	:= oMdlRec:GetValue("GQE_TERC")
Local nPosViag	:= 0
Local aViagens	:= {}
Local aExtraor	:= {}

Local nX		 := 0
Local aErro		:= {}

For nX := 1 To oMdlVia:Length()

	If oMdlVia:GetValue('G55_MARK',nX)
		If oMdlVia:GetValue('TABELA',nX) == "GQE"//Alocação de viagem
			If (nPosViag := aScan(aViagens,{|x| x[1] == oMdlVia:GetValue( 'G55_CODVIA',nX ) })) == 0
				aAdd(aViagens,{oMdlVia:GetValue( 'G55_CODVIA',nX ),{oMdlVia:GetValue("G55_SEQ",nX)} })
			Else
				aAdd(aViagens[nPosViag][2],oMdlVia:GetValue("G55_SEQ",nX) )			
			Endif
		Else //Alocação de Escalas extraordinárias
			aAdd(aExtraor,oMdlVia:GetValue( 'G55_CODVIA',nX ) )
		Endif
		
	Endif
	
Next nX

Begin Transaction 
	If !RmvAlcViag(cTpRecur,cRecurs,cTerceiro,aViagens,aErro)
		lRet:= .F.
	Endif
	
	If lRet .and. !RmvAlcExtr(aExtraor,aErro)
		lRet:= .F.
	Endif
	
	If !lRet
		DisarmTransaction()
	Endif
End Transaction

If !lRet .and. Len(aErro) > 0
	JurShowError(aErro)
Endif

GTPDestroy(aViagens)
GTPDestroy(aExtraor)
GTPDestroy(aErro)

Return(lRet)


/*/{Protheus.doc} RmvAlcViag
(long_description)
@type function
@author jacomo.fernandes
@since 28/02/2019
@version 1.0
@param cRecurs, character, (Descrição do parâmetro)
@param cTerceiro, character, (Descrição do parâmetro)
@param aViagens, array, (Descrição do parâmetro)
@param aErro, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function RmvAlcViag(cTpRecur,cRecurs,cTerceiro,aViagens,aErro)

Local lRet			:= .T.
Local oMdl300		:= FwLoadModel('GTPA300')
Local lMntAtive		:= GC300GetMVC('IsActive')
Local oViewMonitor	:= Nil

Local n1		:= 0


For n1 := 1 To Len(aViagens)

	If !GravaBase(oMdl300,aViagens[n1][1],cTpRecur,cRecurs,cTerceiro,aViagens[n1][2],aErro)
		lRet := .F.
		Exit
	Endif 
	
	If lRet .and. lMntAtive .and. !GravaMonitor(aViagens[n1][1],cTpRecur,cRecurs,cTerceiro,aViagens[n1][2],aErro) 
		lRet := .F.
		Exit
	Endif
	
Next


oMdl300:Destroy()


If lRet .and. lMntAtive
	oViewMonitor:= GC300GetMVC('V')
	oViewMonitor:Refresh("G55DETAIL")
	oViewMonitor:Refresh("GQEDETAIL")
EndIf

Return lRet


/*/{Protheus.doc} GravaBase
(long_description)
@type function
@author jacomo.fernandes
@since 28/02/2019
@version 1.0
@param oMdl300, objeto, (Descrição do parâmetro)
@param cViagem, character, (Descrição do parâmetro)
@param cRecurs, character, (Descrição do parâmetro)
@param cTerceiro, character, (Descrição do parâmetro)
@param aSequencia, array, (Descrição do parâmetro)
@param aErro, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GravaBase(oMdl300,cViagem,cTpRecur,cRecurs,cTerceiro,aSequencia,aErro)
Local lRet		:= .T.
Local aAreaGYN	:= GYN->(GetArea())

GYN->(DbSetOrder(1))
If GYN->(DbSeek(xFilial('GYN')+cViagem)) 
	oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
	If oMdl300:Activate()
		If DeleteAlocViag(oMdl300,cTpRecur,cRecurs,cTerceiro,aSequencia)
			lRet := oMdl300:VldData() .and. oMdl300:CommitData()	
		Else
			lRet	:= .F.	
			aErro	:= oMdl300:GetErrorMessage()
			
		Endif
		oMdl300:DeActivate()
	Else
		lRet := .F.
		aErro := oMdl300:GetErrorMessage()
	Endif	
	
Endif

RestArea(aAreaGYN)

Return lRet

/*/{Protheus.doc} GravaMonitor
(long_description)
@type function
@author jacomo.fernandes
@since 28/02/2019
@version 1.0
@param cViagem, character, (Descrição do parâmetro)
@param cRecurs, character, (Descrição do parâmetro)
@param cTerceiro, character, (Descrição do parâmetro)
@param aSequencia, array, (Descrição do parâmetro)
@param aErro, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GravaMonitor(cViagem,cTpRecur,cRecurs,cTerceiro,aSequencia,aErro)
Local lRet			:= .T.
Local oMldMonitor 	:= GC300GetMVC('M')
Local oMdlGYN	 	:= oMldMonitor:GetModel( 'GYNDETAIL' )

If oMdlGYN:SeekLine({{'GYN_CODIGO',cViagem}})
	If !DeleteAlocViag(oMldMonitor,cTpRecur,cRecurs,cTerceiro,aSequencia)
		lRet := .F.
		aErro := oMldMonitor:GetErrorMessage()
	Endif
Endif
	
Return lRet

/*/{Protheus.doc} DeleteAlocViag
(long_description)
@type function
@author jacomo.fernandes
@since 28/02/2019
@version 1.0
@param oMdlGYN, objeto, (Descrição do parâmetro)
@param cTpRecur, character, (Descrição do parâmetro)
@param cRecurs, character, (Descrição do parâmetro)
@param cTerceiro, character, (Descrição do parâmetro)
@param aSequencia, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DeleteAlocViag(oModel,cTpRecur,cRecurs,cTerceiro,aSequencia)
Local lRet	:= .T.
Local oMdlG55	:= oModel:GetModel("G55DETAIL")
Local oMdlGQE	:= oModel:GetModel("GQEDETAIL")

Local lUpdG55	:= !oMdlG55:CanUpdateLine()

Local lInsGQE	:= !oMdlGQE:CanUpdateLine()
Local lUpdGQE	:= !oMdlGQE:CanUpdateLine()
Local lDelGQE	:= !oMdlGQE:CanUpdateLine()


Local n1		:= 0



oMdlGQE:SetNoInsertLine(.F.)
oMdlGQE:SetNoUpdateLine(.F.)
oMdlGQE:SetNoDeleteLine(.F.)


For n1 := 1 to Len(aSequencia)
	If oMdlG55:SeekLine({{'G55_SEQ',aSequencia[n1]}})
		If oMdlGQE:SeekLine({{'GQE_TRECUR',cTpRecur},{'GQE_RECURS',cRecurs},{'GQE_TERC',cTerceiro} } )
			
			If oMdlGQE:DeleteLine()
				oMdlG55:SetNoUpdateLine(.F.)
				oMdlG55:SetValue('G55_CONF','2')
			Else
				lRet := .F.
				Exit
			Endif
		Endif
	Endif
Next

oMdlG55:SetNoUpdateLine(lUpdG55)

oMdlGQE:SetNoInsertLine(lInsGQE)
oMdlGQE:SetNoUpdateLine(lUpdGQE)
oMdlGQE:SetNoDeleteLine(lDelGQE)


Return lRet


/*/{Protheus.doc} RmvAlcExtr
(long_description)
@type function
@author jacomo.fernandes
@since 28/02/2019
@version 1.0
@param aExtraor, array, (Descrição do parâmetro)
@param aErro, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function RmvAlcExtr(aExtraor,aErro)
Local lRet		:= .T.
Local oMdl313	:= FwLoadModel('GTPA313')

Local n1	:= 0

oMdl313:SetOperation(MODEL_OPERATION_DELETE)

GQK->(DbSetOrder(1))//GQK_FILIAL, GQK_CODIGO, GQK_RECURS, GQK_TCOLAB, GQK_DTREF, GQK_DTINI, GQK_HRINI

For n1	:= 1 To Len(aExtraor)
	If GQK->(DbSeek(xFilial('GYG')+aExtraor[n1] )) 
		If oMdl313:Activate()
			If !(oMdl313:VldData() .and. oMdl313:CommitData())
				lRet	:= .F.
				aErro	:= oMdl313:GetErrorMessage()
				Exit 
			Endif 
			oMdl313:DeActivate()
		Endif
	Endif
Next

oMdl313:Destroy()

Return lRet


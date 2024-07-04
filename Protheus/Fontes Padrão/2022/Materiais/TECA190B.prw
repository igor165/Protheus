#INCLUDE 'TECA190B.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'

#DEFINE FIL_ATENDE 1
#DEFINE FIL_LOCAL  2
#DEFINE FIL_REGIAO 3
#DEFINE FIL_EQUIPE 4
#DEFINE FIL_HABILI 5
#DEFINE FIL_SUPERV 6

Static dDtAgIni := dDatabase-15
Static dDtAgFim := dDatabase+15
Static nMark	:= 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190B

   Rotina para mesa operacional - chama a rotina que constrói com mensagem para o usuário aguardar

@sample TECA190B
@since	29/04/2014
@version P12
/*/
//------------------------------------------------------------------------------
Function TECA190B()

 TECA190D() // Nova mesa Operacional

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At19ShowCk
	Mostra painel com dados do check-in\out

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At19ShowCk(cCodABB,cFilABB)  // Chamada function TECA190d

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwLoadModel('TECA190C')
Local oSubView		:= FwFormView():New(oModel)
Local lRet			:= .T.
Local cTemp			:= GetNextAlias()
Local aButtons	:= {	{.F.,Nil},;			//- Copiar
							{.F.,Nil},;			//- Recortar
							{.F.,Nil},;			//- Colar
							{.F.,Nil},;			//- Calculadora
							{.F.,Nil},;			//- Spool
							{.F.,Nil},;			//- Imprimir
							{.F.,"Confirmar"},;			//- Confirmar
							{.T.,"Fechar"},;	//- Cancelar
							{.F.,Nil},;			//- WalkThrough
							{.F.,Nil},;			//- Ambiente
							{.F.,Nil},;			//- Mashup
							{.F.,Nil},;			//- Help
							{.F.,Nil},;			//- Formulário HTML
							{.F.,Nil}			}	//- ECM

Default cFilABB := XFilial("ABB") 

ABB->(dbSetOrder(8))
If ABB->(DbSeek(cFilABB+ cCodABB))

	BeginSQL Alias cTemp

		SELECT
			1
		FROM
			%Table:T48% T48
		WHERE
			T48.T48_FILIAL = %Exp:xFilial("T48")% AND
			T48.T48_CODABB = %Exp:cCodABB% AND
			T48.T48_TIPO IN ('1','3') AND
			T48.%NotDel%
	 EndSql


	If ( cTemp )->( !Eof() )
		oModel:Activate()
		FWExecView( STR0057,"TECA190C", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,, 20, aButtons, /*bCancel*/ )
	Else
		MsgAlert(STR0058)
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return

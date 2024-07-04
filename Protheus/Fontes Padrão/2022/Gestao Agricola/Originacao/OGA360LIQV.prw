#Include "OGA360.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} OG360LQVND
Função para realizar a liquidação dos títulos de venda
@type function
@version 
@author rafael.voltz
@since 14/08/2020
/*/
Function OG360LQVND ( cLqdGerada, cCond, cCliLqdDe,cCliLjaDe,cCliLqd,cljaLqd, cTp, cNaturez, nMoedaOR, cPrefix,cBco,cAg,cConta,dDtVencto,cEmit,nVrOpg,nAcrescLq,nDecrescLq,cQuery,oGridNKK, nRecLiquid)

// -- Variaveis Local --
Local nX		:= 1
Local lContinua	:= .t.
Local nVrLqdAux	:= 0

Local aRecTit	:= {}
Local aLiq := {}
Local aCpoUser := {}
Local lContabiliza  := .F.
Local lAglutina   := .F.
Local lDigita   := .F.
Local aParam := {}
Local cAliasQry := ""

    aParam := {lContabiliza,lAglutina,lDigita,.F.,.F.,.F.}
    
    aSaveLines := FWSaveRows() 		// Salva a posição de todos os Grids
	For nX:= 1 To oGridNKK:Length() Step 1
	
		oGridNKK:GoLine( nX )
		
	    IF oGridNKK:IsDeleted()
	       Loop
	    EndIF
	    // Vr. do Titulo a Liquidar = Vr. fixado a Liquidar + Vr. do Frete + Vr. Seguro + Vr. Despesa //
		nVrLqdAux := oGridNKK:GetValue('NKK_VRLQDF') + oGridNKK:GetValue('NKK_FRELQD') + oGridNKK:GetValue('NKK_SEGLQD') + oGridNKK:GetValue('NKK_DSPLQD')
		
		//Como n. Posso Acrescer ou decrescer no titulo e somente na Liquidação entao o vr. a liquidar entao:
		// Se tenho q decrescer -> Tenho q Adicionar no Vr. a Liquidar para no final lançar o decrescimo na liquidação de forma acumulada um unico
		// 		decrescimo de todos os titulos;
		// Se tenho q Acrescer	-> Tenho q Decrescer no Vr. a Liquidar para no Final Lancar o acrescimo  na Liquidacao de forma acumulada um unico
		//      Acrescimo.
		nVrLqdAux += oGridNKK:GetValue('NKK_DECRES') - oGridNKK:GetValue('NKK_ACRESC')
		//Encontrando o Recno do Titulo
		nRecnoTIT := 0
		nRecnoTIT := OG360RgTIT( oGridNKK:GetValue('NKK_TABLQD'), oGridNKK:GetValue('NKK_CPOTIT'),oGridNKK:GetValue('NKK_CHVTIT')  )
			
			IF SE1->(DbGoto( nRecnoTIT ) )
			    cMensagem := STR0101 + '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + ']' //'TÍtulo não encontrado. O título selecionado pode ter sido exlcuido por outro processo. Titulo/Parcela:'
				lContinua:= .f.
				Exit
		    EndIF
			IF lContinua .and.  SE1->E1_SALDO <  nVrLqdAux			
				cAux := '[' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_PREFIXO + '/' + SE1->E1_CLIENTE + '-' + SE1->E1_LOJA + ']'
				cMensagem := STR0102 //'Saldo do Titulo está menor do que o Vr. a ser Liquidado pela OP/OR informado na Aba Entregas. Titulo pode ter sido baixado por outro processo. Clique em Refresh TitS/Entregas. em ações do Browse de Entregas e tente confirmar novamente.Pref/Tít/Parc/Forn: '
				cMensagem += cAux
				lContinua := .f. 
				Exit
			EndIF
			
			If lContinua    // Se titulo foi encontrado e o Vr. é suficiente para Baixar o q preciso marco para liquidar
				aadd(aRecTit,nRecnoTIT)
			EndIF
		IF !lContinua
			Exit
		EndIF
	nExt NX
	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(E1_NUM) AS NUM"
	cQuery += " FROM " + RetSQLName("SE1") + " SE1"
	cQuery += " WHERE E1_PREFIXO = '"+cPrefix+"' "
	cQuery += " AND E1_TIPO = '"+cTp+"' "
	cQuery += " AND D_E_L_E_T_ = '' "
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
	If !(cAliasQry)->(Eof()) .AND. !EMPTY((cAliasQry)->NUM)
		cLqdGerada := SOMA1( AllTrim((cAliasQry)->NUM))
	Else
		cLqdGerada := SOMA1("0")
		cLqdGerada := Alltrim(PADL(cLqdGerada,TamSx3("E1_NUMLIQ")[1] ,"0"))
	EndIf
	(cAliasQry)->(dbCloseArea())	

	aadd(aLiq,{cPrefix,cBco,cAg,cConta,cLqdGerada,dDtVencto,nVrOpg,cTp,cNaturez,nMoedaOR})

	aadd(aCpoUser,{})
	aadd(aCpoUser[LEN(aCpoUser)],{"E1_EMITCHQ","** Liqd. Originação **"})
	aadd(aCpoUser[LEN(aCpoUser)],{"E1_ACRESC",nAcrescLq})
	aadd(aCpoUser[LEN(aCpoUser)],{"E1_DECRESC",nDecrescLq})

	lOk := .f.
	
	lOk := MaIntBxCR(2,aRecTit,Nil,Nil,aLiq,aParam, , , , , ,aCpoUser, , , , , )
	
    If lOk
		
		//conferencia do titulo liquidado
		cAliasQry := GetNextAlias()
		cQuery := " SELECT SE1.R_E_C_N_O_ AS RECNO, E1_NUM AS NUM, E1_NUMLIQ AS NUMLIQ "		
		cQuery += " FROM " + RetSQLName("SE1") + " SE1"
		cQuery += " INNER JOIN "+ RetSQLName("SE5")+" SE5 ON SE5.D_E_L_E_T_='' AND SE5.E5_FILIAL = SE1.E1_FILIAL "
		cQuery += " AND SE5.E5_DOCUMEN = SE1.E1_NUMLIQ "
		cQuery += " AND SE5.E5_CLIENTE=SE1.E1_CLIENTE AND SE5.E5_LOJA = SE1.E1_LOJA "
		cQuery += " WHERE SE1.D_E_L_E_T_ = '' AND E1_PREFIXO = '"+cPrefix+"' AND E1_TIPO='"+cTp+"' "
		cQuery += " AND E1_CLIENTE='"+cCliLqdDe+"' AND E1_LOJA='"+cCliLjaDe+"' AND E1_NUM='"+cLqdGerada+"' "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
		If !(cAliasQry)->(Eof()) .and. aLLTRIM((cAliasQry)->(NUM)) == cLqdGerada
			nRecLiquid := (cAliasQry)->(RECNO)                        
		Else
			AgrHelp(STR0013, STR0099,STR0100)  //"Houve um erro na identificação do registro da liquidação do título."          //"Por favor, configura os dados do título a ser liquidado."
			lOk := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())	
	Else
		Return .F.
	EndIf

Return lOk

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA560.CH"

Static TMKA560Grupo  := ""		// guarda o ultimo grupo utilizado na funcao de regras
Static TMKA560Assunto:= ""		// guarda o ultimo assunto utilizado na funcao de regras
Static TMKA560Regra  := {}		// guarda as ultimas regras processadas

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA560   บAutor  ณVendas CRM          บ Data ณ  19/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Regras de Transferencia Automatica				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA560                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TMKA560()

Private cCadastro := STR0006 // "Cadastro de Regras de Transferencia Automatica"

aRotina	:= MenuDef()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AxCadastro("AAV",cCadastro) //,,,,,,,,,,,{Nil,Nil,Nil,Nil,3})

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK560VLD  บAutor  ณVendas CRM          บ Data ณ  19/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de campos da tabela AAV                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA560                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TK560VLD(cCampo)
Local aArea := { AAV->( GetArea("AAV")), SX5->( GetArea("SX5")), SU0->( GetArea("SU0")), SU7->( GetArea("SU7")), GetArea() }
Local lRetorno := .T.
Local nTamOp	:= TamSX3("U7_COD")[1]
Local nA

if cCampo == "AAV_ASSUNT"
	if ! Empty(M->AAV_ASSUNT)
		lRetorno := ExistCpo("SX5","T1"+M->AAV_ASSUNT)
		M->ADE_DESASS := Posicione("SX5",1,xFilial("SX5")+"T1"+M->AAV_ASSUNT,"SX5->X5_DESCRI")
	Endif

Elseif cCampo == "AAV_GRUPO"
	if ! Empty(M->AAV_GRUPO)
		lRetorno := ( ExistCpo("SU0",M->AAV_GRUPO) .And. TK510VldGrupo(M->AAV_GRUPO,M->AAV_ASSUNTO,,) )
		M->AAV_DESGRP := Posicione("SU0",1,xFilial("SU0")+M->AAV_GRUPO,"SU0->U0_NOME")
		M->AAV_OPERAD := Space(nTamOp)
		M->AAV_DESOPE := ""
	EndIf

Elseif cCampo == "AAV_OPERAD"
	if ! Empty(M->AAV_OPERAD)
		lRetorno :=	ExistCpo("SU7",M->AAV_OPERAD,1)
		if lRetorno
		   lRetorno := TK510VldUser(M->AAV_GRUPO,M->AAV_OPERAD,@M->AAV_DESOPE)
		Endif
	Endif

Elseif cCampo == "AAV_REGRA"
	if ! Empty(M->AAV_REGRA)
		lRetorno := TK560AVALIA(M->AAV_REGRA,.F.)
		if ! lRetorno
			Aviso(STR0007, STR0008+Posicione("SX3",2,cCampo,"SX3->X3_TITULO")+STR0009,{STR0010}) // "Aten็ใo"###"Dado informado no campo "###" invแlido ou nใo foi informado"###"OK"
		Endif
	Endif

Elseif cCampo == "AAV_PRIORI"
	lRetorno := ( Val(M->AAV_PRIORI) >= 0 .and. Val(M->AAV_PRIORI) <= 999 )
	if ! lRetorno
		Aviso(STR0007, STR0008+Posicione("SX3",2,cCampo,"SX3->X3_TITULO")+STR0009, {STR0010}) // "Aten็ใo"###"Dado informado no campo "###" invแlido ou nใo foi informado"###"OK"
	Endif
Endif

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next	

Return( lRetorno )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChekBug   บAutor  ณVendas CRM          บ Data ณ  19/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de campos da tabela AAV                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA560                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Chekbug(e)
IF e:gencode > 0
    HELP(" ",1,"ERR_MSG",,e:Description,1,1)
    lRet:=.F.
Endif
Break
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK560REGRAบAutor  ณVendas CRM          บ Data ณ  19/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvaliacao das regras na tabela AAV                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA560                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TK560REGRA(cAssunto, cGrupo)
Local aArea := {AAV->( GetArea("AAV")),SU7->( GetArea("SU7")),GetArea()}
Local nA

Default cAssunto := ""
Default cGrupo   := ""

TMKA560Regra  := {}	// limpa as ultimas regras processadas
TMKA560Grupo  := cGrupo
TMKA560Assunto:= cAssunto

cQuery := "SELECT AAV_CODIGO, AAV_GRUPO, AAV_OPERAD, AAV_REGRA, AAV_DESREG, AAV_PRIORI "
cQuery += " FROM "+RetSqlName("AAV") + " AAV "
cQuery += " WHERE AAV_FILIAL = '"+xFilial("AAV")+"' "
cQuery += "   AND AAV_STATUS = '1' "
cQuery += "   AND AAV.D_E_L_E_T_ <> '*' "
if !Empty(cAssunto)
	cQuery += " AND AAV_ASSUNT = '"+cAssunto+"' "
Endif
cQuery += " ORDER BY AAV_PRIORI, AAV_CODIGO DESC "

cQuery := ChangeQuery(cQuery)
cAlias :=	GetNextAlias()
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

// Avalia todas as regras ativas
(cAlias)->( Dbgotop())
Do While (cAlias)->( ! Eof())
	if TK560AVALIA((cAlias)->AAV_REGRA)
		// estando as regras em ordem de prioridade e codigo, ao localizar a primeira regra valida,
		// podemos cancelar o restante do processo para tornar o processamento mais rapido
     	AAdd(TMKA560Regra,{(cAlias)->AAV_CODIGO, (cAlias)->AAV_GRUPO, (cAlias)->AAV_OPERAD, (cAlias)->AAV_REGRA, (cAlias)->AAV_DESREG, (cAlias)->AAV_PRIORI})
		Exit
	Endif

	(cAlias)->( Dbskip())
Enddo

(cAlias)->( DbCloseArea())
if Len(TMKA560Regra) > 1
	// ordena por prioridade e codigo
	aSort( TMKA560Regra,,, { |x,y| x[6]+x[1] > y[6]+y[1]} )
Endif
TMKA560Grupo  := cGrupo
TMKA560Assunto:= cAssunto

For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
Next

Return( TMKA560Regra )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK560VLD  บAutor  ณVendas CRM          บ Data ณ  19/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de campos da tabela AAV                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA560                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function TK560AVALIA(cRegra, lModo)
// cRegra - regra a ser avaliada
// lModo  - .T. - Avaliacao
//          .F. - Validacao de campo em tela
Local aArea := {GetArea()}
Local lRetorno := .F.
Local lRegraOk := .T.
Local bBlock
Local bErro
Local nA

Default cRegra := ""
Default lModo  := .T.

if ! Empty(cRegra)
	// controle de erros
	bBlock:= ErrorBlock()
	bErro := ErrorBlock( { |e| Chekbug(e) } )

	Begin Sequence
		// analisa as regras e apresenta mensagens na tela
		if ! lModo
			Processa( {|| 	lRetorno := lRegraOk := A370VerFor(Nil,.T.,cRegra) }, STR0012, STR0013 ) // "Analisando Regra"###"Aguarde..."

			if Valtype(lRetorno) <> "L"
				HELP(" ",1,"ERR_MSG",,STR0011,1,1) // "Conteudo da Regra de Transferencia automแtica deve retornar conteudo l๓gico"
				lRetorno := lRegraOk := .F.
			Endif
		Endif

		// apenas executa a regra sem apresentar mensagens
		if lModo .and. lRegraOk
			lRetorno := &(cRegra)
		Endif
	End Sequence

	ErrorBlock(bBlock)

//	For nA := Len(aArea) to 1 Step -1
//		RestArea( aArea[nA] )
//	Next
Endif

Return( lRetorno )




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef   ณ Autor ณ Vendas Clientes       ณ Data ณ14/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ TMKA560                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Local aRotina := {{ STR0001,"AxPesqui"	, 0 , 1 , , .F. },;  //"Pesquisar"
						{ STR0002,"AxVisual"	, 0 , 2 , , .T. },;  //"Visualizar"
						{ STR0003,"AxInclui"	, 0 , 3 , , .T. },;  //"Incluir"
						{ STR0004,"AxAltera"	, 0 , 4 , , .T. },;  //"Alterar"
                	{ STR0005,"AxDeleta"	, 0 , 5 , , .T. }}   //"Excluir"

Return(aRotina)


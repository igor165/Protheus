// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 25     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX011.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX011 º Autor ³ Rafael/Andre lap   º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Entradas                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    º±±
±±º          ³ aParEnt (Parametros do Consorcio)                          º±±
±±º          ³ aParEnt[1] Nro do Atendimento                              º±±
±±º          ³ aParEnt[2] Valor (saldo restante)                          º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º          ³       aVS9[1] aHeader VS9                                  º±±
±±º          ³       aVS9[2] aCols VS9                                    º±±
±±º          ³ aVSE (Observacoes Pagamento)                               º±±
±±º          ³	      aVSE[1] a4er VSE                                     º±±
±±º          ³       aVSE[2] aCols VSE                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX011(nOpc, aParEnt, aVS9, aVSE, pXX011Auto, aAutoVS9)

Local aObjects   := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nValorEnt  := IIf(aParEnt[2]>0,aParEnt[2],0)
Local nCont      := 0
Local ni         := 0
Local nj         := 0
Local nVS9Cust   := 0
Local nOpcao     := 0
Local dDatIni    := dDataBase
Local cForPagto  := space(len(VV0->VV0_FORPAG))
Local lLimpar    := .f.
Local lRet       := .f.
Local lDP        := .f.
Local aBkpCols   := aClone(aCols)
Local aCamposVSE := {"","VSE_NUMIDE","VSE_TIPOPE","VSE_TIPPAG","VSE_DESCCP","VSE_NOMECP","VSE_TIPOCP","VSE_TAMACP","VSE_DECICP","VSE_PICTCP","VSE_VALDIG","VSE_SEQUEN",""}
Local lVS9OBSPAR := ( VS9->(ColumnPos("VS9_OBSPAR")) > 0 )
//
Local lIntLoja     := ( Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S" )
Local lVS9_PARCVD  := ( VS9->(ColumnPos("VS9_PARCVD")) > 0 )
Local cPARCVD      := ""
Local aPARCVD      := {"","0="+STR0025,"1="+STR0026,"2="+STR0027} // Apenas as Entradas A VISTA / Todas as Entradas / Nenhuma das Entradas
//
Default pXX011Auto := .f.
Default aAutoVS9 := {}
//
Private lCPagPad   := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985
Private nValTotal  := 0
Private aHeader    := {}
Private aHeaderVS9 := aClone(aVS9[1])
Private aHeaderVSE := aClone(aVSE[1])
Private aGravaEnt  := {}
Private aVS9aCols  := {}
Private aVS9Cust   := {}
Private cCadastro  := STR0001 // Entradas ( Alterar TITULO da tela )

If lCPagPad // Condicao de Pagamento Padrao ERP
	lLimpar  := .t. // SEMPRE Refazer as Parcelas
	lIntLoja := .f. // Nao INTREGADO com o Venda Direta
EndIf

Private lXX011Auto := pXX011Auto


If !Empty(aParEnt[1])
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(xFilial("VV9")+aParEnt[1])
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek(xFilial("VV0")+aParEnt[1])
EndIf
If (lCPagPad .and. nopc <> 3) .or. lXX011Auto // Padrão do ERP
	cForPagto := IIf( lXX011Auto , M->VV0_FORPAG , VV0->VV0_FORPAG )
	lLimpar  := .t. // SEMPRE Refazer as Parcelas
	If !FS_VALPAG(cForPagto,.f.)
		cForPagto := space(len(VV0->VV0_FORPAG))
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")
aHeader:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Trim(SX3->X3_CAMPO) $ "VS9_NATSRV/VS9_FILIAL/VS9_NUMIDE/VS9_TIPOPE/VS9_DATBAI/VS9_TIPFEC/VS9_TIPTIT/VS9_SEQPRO/VS9_ENTRAD/VS9_CARTEI/VS9_SEQTAR/VS9_TIPTEM/VS9_OBSERV/VS9_OBSMEM/"+IIf(lCPagPad.or.!lIntLoja,"VS9_PARCVD/",""))
		If alltrim(x3_campo) == "VS9_TIPPAG" // Alterar F3
			aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, "SAVX", x3_context, x3cbox(), x3_relacao } )

	 	ElseIf alltrim(x3_campo) == "VS9_VALPAG" // Alterar VALID
			aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal,"VX11VALTOT(1)", x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )

		ElseIf alltrim(x3_campo) == "VS9_PORTAD" // Alterar VALID
			aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal,"VX11VLPORT()", x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )

		Else
			aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal, x3_valid, x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
	 	EndIf
		// Campos de Usuario
		If GetSx3Cache(X3_CAMPO,"X3_PROPRI") == "U"
			aadd(aVS9Cust,X3_CAMPO)
		Endif

		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

M->VS9_NUMIDE := PadR(aParEnt[1],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ")
M->VS9_TIPOPE := "V"

aCols := {}

cAliasGetD    := "VS9"
cLinOk        := "VX11OBRGT(oGetDadVS9:nAt, aCols ,aHeader)"
cTudOk        := "AllwaysTrue()"
cFieldOk 	  := "FS_DADOSENT(if(ReadVar()=='M->VS9_REFPAG' .or. ReadVar()=='M->VS9_NATURE',.f.,.t.),oGetDadVS9:nAt)"
nLinhas       := 9999

VSA->(dbSetOrder(1))
If VSA->(dbSeek(xFilial("VSA")+"DP")) .and. VSA->VSA_TIPO == "5"
	lDP := .t. // Possui 'DP' cadastrada com  VSA_TIPO='5' -> Entradas
EndIf

If ! lXX011Auto
	// Configura os tamanhos dos objetos
	aObjects := {}
	If lDP
		AAdd( aObjects, { 05, 27 , .T. , .F. } ) 	// COM cabecalho -> DP
	Else
		AAdd( aObjects, { 05,  0 , .T. , .F. } ) 	// SEM cabecalho -> DP
	EndIf
	AAdd( aObjects, { 01, 10 , .T. , .T. } )  	// GetDados das Parcelas
	AAdd( aObjects, { 05, 23 , .T. , .F. } )  	// Rodape Totalizador das Parcelas

	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
EndIf
For ni := 1 to len(aVS9[2])
	If !aVS9[2,ni,len(aVS9[2,ni])]
		VSA->(DbSetOrder(1))
		VSA->(DbSeek(xFilial("VSA")+aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]))

		If VSA->VSA_TIPO == "5"
			aAdd(aCols,Array(len(aHeader)+1))
			For nCont:=1 to len(aHeader)
				aCols[len(aCols),FG_POSVAR(aHeader[nCont,2],"aHeader")] := aVS9[2,ni,FG_POSVAR(aHeader[nCont,2],"aHeaderVS9")]
			Next
			aCols[len(aCols),FG_POSVAR("VS9_DESPAG","aHeader")] := VSA->VSA_DESPAG
			aCols[len(aCols),len(aHeader)+1] := .f.

			aAdd(aVS9aCols,ni)

			nValTotal += aCols[len(aCols),FG_POSVAR("VS9_VALPAG","aHeader")]
			cAux := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] + aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]

			// Trazer Observacoes do VSE //
			For nj := 1 to len(aVSETotal[2])
				If !aVSETotal[2,nj,len(aVSETotal[2,nj])]
					If aVSETotal[2,nj,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] + aVSETotal[2,nj,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] == cAux

						aadd(aGravaEnt,{ ;
							len(aCols),;
							aVS9[ 2 , ni, FG_POSVAR("VS9_NUMIDE","aHeaderVS9")],;
							aVS9[ 2 , ni, FG_POSVAR("VS9_TIPOPE","aHeaderVS9")],;
							aVS9[ 2 , ni, FG_POSVAR("VS9_TIPPAG","aHeaderVS9")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_DESCCP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_NOMECP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_TIPOCP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_TAMACP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_DECICP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_PICTCP","aHeaderVSE")],;
							aVSETotal[ 2 ,nj ,FG_POSVAR("VSE_VALDIG","aHeaderVSE")],;
							aVS9[ 2 , ni , FG_POSVAR("VS9_SEQUEN","aHeaderVS9")],;
							.f.})

					EndIf
	        	EndIf
			Next
		EndIf
	EndIf
Next

If ! lXX011Auto

	DEFINE MSDIALOG oTelaEnt TITLE STR0001 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL // Entradas

	If lDP // Possui 'DP' cadastrada com  VSA_TIPO='5' -> Entradas

		@ aPosObj[1,1] + 05,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL STR0002 OF oTelaEnt PIXEL // Compor parcelas tipo DP

		@ aPosObj[1,1] + 14 , aPosObj[1,2] + 010 SAY (STR0003+": ") OF oTelaEnt PIXEL // Valor
		@ aPosObj[1,1] + 13 , aPosObj[1,2] + 040 MSGET oValorEnt VAR nValorEnt VALID (nValorEnt>=0) PICTURE "@E 9,999,999.99" SIZE 50,1 OF oTelaEnt WHEN ( nOpc==3 .or. nOpc==4 ) PIXEL HASBUTTON

		@ aPosObj[1,1] + 14 , aPosObj[1,2] + 101 SAY (STR0004+": ") OF oTelaEnt PIXEL // Cond. Pagto.
		@ aPosObj[1,1] + 13 , aPosObj[1,2] + 136 MSGET oForPagto VAR cForPagto VALID FS_VALPAG(cForPagto,.t.) PICTURE "@!" F3 "SE4" SIZE 20,1 OF oTelaEnt WHEN ( nOpc==3 .or. nOpc==4 ) PIXEL HASBUTTON

		@ aPosObj[1,1] + 14 , aPosObj[1,2] + 178 SAY (STR0005+": ") OF oTelaEnt PIXEL // Data Inicial
		@ aPosObj[1,1] + 13 , aPosObj[1,2] + 210 MSGET oDatIni VAR dDatIni VALID (dDatIni>=dDataBase) PICTURE "@D" SIZE 44,08 OF oTelaEnt WHEN ( ( nOpc==3 .or. nOpc==4 ) .and. !lCPagPad ) PIXEL HASBUTTON
		@ aPosObj[1,1] + 13 , aPosObj[1,2] + 265 BUTTON oCompParc PROMPT STR0006 OF oTelaEnt SIZE 45,10 PIXEL ACTION FS_ADDPGTO(@nValorEnt , @cForPagto , @dDatIni , @lLimpar , aParEnt ) WHEN ( nOpc==3 .or. nOpc==4 ) // Compor Parcelas

		@ aPosObj[1,1] + 14 , aPosObj[1,2] + 320 CHECKBOX oLimpar VAR lLimpar PROMPT STR0007 OF oTelaEnt SIZE 100,10 WHEN ( ( nOpc==3 .or. nOpc==4 ) .and. !lCPagPad ) PIXEL // Refazer parcelas DP

	EndIf

	oGetDadVS9:= MsNewGetDados():New(aPosObj[2,1]+002,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],IIf(nopc==2.or.lCPagPad,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oTelaEnt,aHeader,aCols )

	If nOpc == 3 .Or. nOpc == 4
		If nopc <> 2 .And. !lCPagPad // Se NAO é Visualizar e NAO é Condicao Padrao ERP
			oGetDadVS9:oBrowse:bDelete := {|| VX0110016_ValidandoExclusaoDaLinha(oGetDadVS9:nAt) }
		EndIf

		oGetDadVS9:oBrowse:bChange := {|| FS_BAIXADO(oGetDadVS9:nAt, .t.), FG_MEMVAR(oGetDadVS9:aHeader, oGetDadVS9:aCols, oGetDadVS9:nAt) }
	EndIf

	If lVS9_PARCVD .and. !lCPagPad .and. lIntLoja // Se EXISTE o campo VS9_PARCVD  e  NAO trabalha com Condicao Padrao ERP  e  esta integrado com o Venda Direta
		@ aPosObj[3,1] + 00 , aPosObj[3,2] + 00 TO aPosObj[3,3],aPosObj[3,4]-110 LABEL STR0029 OF oTelaEnt PIXEL // Selecionar as Entradas a receber no Venda Direta
		@ aPosObj[3,1] + 09 , aPosObj[3,2] + 05 MSCOMBOBOX oPARCVD VAR cPARCVD SIZE aPosObj[3,4]-120,08 COLOR CLR_BLACK ITEMS aPARCVD OF oTelaEnt ON CHANGE VX0110021_ParcelasVendaDireta(cPARCVD) PIXEL
	EndIf

	@ aPosObj[3,1] + 00 , aPosObj[3,4] - 105 TO aPosObj[3,3],aPosObj[3,4] LABEL STR0008 OF oTelaEnt PIXEL // Valor Total Entradas

	@ aPosObj[3,1] + 09 , aPosObj[3,4] - 100 MSGET oValTotal VAR nValTotal PICTURE "@E 9,999,999,999.99" SIZE 95,08 OF oTelaEnt WHEN .f. PIXEL HASBUTTON

	oGetDadVS9:oBrowse:SetFocus()
	ACTIVATE MSDIALOG oTelaEnt ON INIT EnchoiceBar(oTelaEnt,{|| IIf(VX0110011_ValidTudoOK(),(nOpcao:=1,oTelaEnt:End()),.f.)},{ || oTelaEnt:End()},,)
Else

	oGetDadVS9 := DMS_GetDAuto():Create()
	oGetDadVS9:aHeader := aClone(aHeader)
	oGetDadVS9:aCols := aClone(aCols)

	If Len(aAutoVS9) > 0

		For ni := 1 to Len(aAutoVS9)
			nAuxPos := aScan( aAutoVS9[ni] , { |x| x[1] == "VS9_VALPAG" })
			If nAuxPos > 0
				aAutoVS9[ni,nAuxPos,3] := "VX11VALTOT(1)"
			EndIf
		Next ni

		cLinOk := "VX11OBRGT(n, aCols ,aHeader)"
		
		aCols := {}
		If MsGetDAuto( aAutoVS9 , cLinOK , cTudOk , {} /* [ aEnchAuto ] */ , nOpc , .t. /* lClear */ )
			oGetDadVS9:aCols := aClone(aCols)
			nOpcao := 1
		Else
			lMsErroAuto := .t.
			lRet := .f.
		EndIf
	Else//If lCPagPad
		FS_ADDPGTO(@nValorEnt , @cForPagto , @dDatIni , @lLimpar , aParEnt )
		nOpcao := 1
	EndIf

EndIf

If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aVSE[2] := {}

		// ------------------//
		// Deletar VS9 / VSE //
		// ------------------//
		For ni := 1 to len(aVS9[2])
			If !aVS9[2,ni,len(aVS9[2,ni])]
				VSA->(DbSetOrder(1))
				VSA->(DbSeek(xFilial("VSA")+aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]))

				If VSA->VSA_TIPO == "5"
					// Deletar todos os VS9 do Tipo ENTRADA
					aVS9[2,ni,len(aVS9[2,ni])] := .t.
					// Deletar todos os VSE referente ao VS9
					aAdd(aVSE[2],Array(len(aVSE[1])+1))

					nPos := len(aVSE[2])
					aVSE[2,nPos,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")]
					aVSE[2,nPos,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")]
					aVSE[2,nPos,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]
					aVSE[2,nPos,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]
					aVSE[2,nPos,len(aVSE[2,nPos])] := .t.
				EndIf
			EndIf
		Next

		// ----------- //
		// Incluir VS9 //
		// ----------- //
		For ni := 1 to len(oGetDadVS9:aCols)
			If !oGetDadVS9:aCols[ni,len(oGetDadVS9:aCols[ni])] .and. !Empty(oGetDadVS9:aCols[ni,FG_POSVAR("VS9_TIPPAG","aHeader")])
				If len(aVS9aCols) >= ni
					nPos := aVS9aCols[ni]
				Else
					aAdd(aVS9[2],Array(len(aVS9[1])+1))
					nPos := len(aVS9[2])
				EndIf
				aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParEnt[1],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
				aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
				aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_TIPPAG","aHeader")]
				aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_DATPAG","aHeader")]
				aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_VALPAG","aHeader")]
				If FG_POSVAR("VS9_PARCVD","aHeader") > 0
					aVS9[2,nPos,FG_POSVAR("VS9_PARCVD","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_PARCVD","aHeader")]
				EndIf
				aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_REFPAG","aHeader")]
				aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_SEQUEN","aHeader")]
				aVS9[2,nPos,FG_POSVAR("VS9_PORTAD","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_PORTAD","aHeader")]
				aVS9[2,nPos,FG_POSVAR("VS9_NATURE","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_NATURE","aHeader")]
				If lVS9OBSPAR
					aVS9[2,nPos,FG_POSVAR("VS9_OBSPAR","aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR("VS9_OBSPAR","aHeader")]
				EndIf
				aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
				For nVS9Cust := 1 to len(aVS9Cust)
					aVS9[2,nPos,FG_POSVAR(aVS9Cust[nVS9Cust],"aHeaderVS9")] := oGetDadVS9:aCols[ni,FG_POSVAR(aVS9Cust[nVS9Cust],"aHeader")]
				Next
			EndIf
		Next

		// ----------- //
		// Incluir VSE //
		// ----------- //
		For ni := 1 to len(aGravaEnt)
			If aGravaEnt[ni,1] > 0 .and. len(oGetDadVS9:aCols) >= aGravaEnt[ni,1]

				aGravaEnt[ni,12] := oGetDadVS9:aCols[aGravaEnt[ni,1],FG_POSVAR("VS9_SEQUEN","aHeader")] // Altera SEQUEN do VSE com VS9

				If !aGravaEnt[ni,len(aGravaEnt[ni])]
					aAdd(aVSE[2],Array(len(aVSE[1])+1))
					nPos := len(aVSE[2])
					For nCont := 1 to len(aCamposVSE)
						If !Empty(aCamposVSE[nCont])
							aVSE[2,nPos,FG_POSVAR(aCamposVSE[nCont],"aHeaderVSE")] := aGravaEnt[ni,nCont]
						EndIf
					Next
					aVSE[2,nPos,len(aVSE[2,nPos])] := .f.
				EndIf
			EndIf
		Next
	EndIf
	If lCPagPad // Condicao de Pagamento Padrao ERP
		M->VV0_FORPAG := cForPagto
	Endif
EndIf

aCols := aClone(aBkpCols)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VALPAGº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da forma de pagamento                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALPAG(cForPagto,lMsg)
Default lMsg := .t.
dbSelectArea("SE4")
dbSetOrder(1)
If !Empty(cForPagto) .and. ( !dbSeek(xFilial("SE4")+cForPagto) .or. SE4->E4_TIPO == "A" .or. SE4->E4_TIPO == "9" )
	If lMsg
		MsgStop(STR0010,STR0009) // Condicao de Pagamento invalida! / Atencao
	EndIf
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ADDPGTO  ³ Autor ³ Rafael Goncalves    ³ Data ³ 26/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³adicona automaticamente os valores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nValTot   -> Valor total do pagamento                       ³±±
±±³          |cCond     -> Condicao do pagamento                          ³±±
±±³          |dDatIni   -> Data Inicial para formar pagamentos            ³±±
±±³          |lLimpar   -> Limpar pagamentos anteriores                   ³±±
±±³          |aParEnt[1]-> Nro do Atendimento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADDPGTO( nValTot, cCond , dDatIni , lLimpar , aParEnt )
Local aValPar    := {}
Local cont       := 1
Local _ni, ni_   := 1
Local wy         := 0
Local xy         := 0
Local cTipIte    := ""
Local cSeqIte    := ""
Local nDocument  := 0
Local cTpFix  	  := "DP"
Default nValTot  := 0
Default cCond    := space(len(VV0->VV0_FORPAG))
Default dDatIni  := dDataBase
Default lLimpar  := .f.

If nValTot <= 0
	FMX_HELP("VX011ERR",STR0011) // Valor informado menor ou igual a zero! / Atencao
	If ! lXX011Auto
		oValorEnt:SetFocus()
	EndIf
	Return .f.
EndIf

If Empty(cCond)
	FMX_HELP("VX011ERR",STR0012) // Condicao de Pagamento nao informada! / Atencao
	If ! lXX011Auto
		oForPagto:SetFocus()
	EndIf
	Return .f.
EndIf

// Verifica se Existe a Condicao de Pagamento do Tipo DP
VSA->(dbSetOrder(1))
If !VSA->(dbSeek(xFilial("VSA")+"DP"))
	FMX_HELP("VX011ERR",STR0013) // Condicao de Pagamento do Tipo 'DP' nao esta cadastrada! / Atencao
	Return .f.
EndIf

//////////////////////////////////////////////////////
// PE para gravar a Condicao de Pagamento escolhida //
//////////////////////////////////////////////////////
If ExistBlock("VXX11CON")
	ExecBlock("VXX11CON",.f.,.f.,{nValTot,cCond,dDatIni})
EndIf

aValPar := condicao(nValTot,cCond,,dDatIni)
/*Condicao - Tipo: Processamento
Esta funcao permite avaliar uma condicao de pagamento, retornando um array multidimensional com informacoes referentes ao valor e vencimento de cada parcela,
de acordo com a condicao de pagamento.
chamada - Condicao(nValTot,cCond,nVIPI,dData,nVSol)
	Parametros
		nValTot - Valor total a ser parcelado
		cCond - Código da condição de pagamento
		nVIPI - Valor do IPI, destacado para condição que obrigue o pagamento do IPI na 1ª parcela
		dData - Data inicial para considerar
Retorna
aRet - Array de retorno ( { {VALOR,VENCTO} , ... } )
*/

IF lLimpar //apagar os regsitros incluidos anteriormentes.
	For ni_ := 1 to len(oGetDadVS9:aCols)
		If oGetDadVS9:aCols[ni_,FG_POSVAR("VS9_TIPPAG","aHeader")] == "DP" .and. !FS_BAIXADO(ni_,.f.)
			oGetDadVS9:aCols[ni_,len(aHeader)+1] := .t.
		EndIF
	Next
EndIF

IF len(oGetDadVS9:aCols) == 1 .and. Empty(oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_TIPPAG","aHeader")])
	oGetDadVS9:aCols := {}
EndIF

SE4->(DbSetOrder(1))
If SE4->(DbSeek(xFilial("SE4")+cCond))
	If !Empty(SE4->E4_FORMA)
		cTpFix := SE4->E4_FORMA
	Endif
Endif

For cont := 1 to Len(aValPar)

	aAdd(oGetDadVS9:aCols,Array(len(aHeader)+1))
	For _ni:=1 to len(aHeader)
		oGetDadVS9:aCols[Len(oGetDadVS9:aCols),_ni] := CriaVar(aHeader[_ni,2],.t.)
	Next

	oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_TIPPAG","aHeader")] := cTpFix
	DbSelectArea("VSA")
	DbSetOrder(1)
	DbSeek(xFilial("VSA")+oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_TIPPAG","aHeader")] )
	oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DESPAG","aHeader")] := VSA->VSA_DESPAG
	oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DATPAG","aHeader")] := aValPar[cont,1]
	oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_VALPAG","aHeader")] := aValPar[cont,2]
	if val(oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")]) > 0
		nDocument := oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")]
		If cont == 1
			oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := alltrim(Str(nDocument))+space(15-Len(alltrim(Str(nDocument))))
		Else
			oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := alltrim(Str(nDocument+(cont-1)))+space(15-Len(alltrim(Str(nDocument))))
		EndIf
	Else
		oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := space(10)
	Endif
	oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_SEQUEN","aHeader")] := StrZero(cont,2)
	oGetDadVS9:aCols[len(oGetDadVS9:aCols),len(aHeader)+1] := .f.

Next

For xy:=1 to Len(oGetDadVS9:aCols)
	cTipIte := Alltrim(oGetDadVS9:aCols[xy,FG_POSVAR("VS9_TIPPAG","aHeader")])
	cSeqIte := Alltrim(oGetDadVS9:aCols[xy,FG_POSVAR("VS9_SEQUEN","aHeader")])
	For wy:=xy to Len(oGetDadVS9:aCols)
		If wy == xy
			Loop
		EndIf
		If Alltrim(oGetDadVS9:aCols[wy,FG_POSVAR("VS9_TIPPAG","aHeader")]) == cTipIte
			oGetDadVS9:aCols[wy,FG_POSVAR("VS9_SEQUEN","aHeader")] := StrZero(Val(cSeqIte)+1,2)
			cSeqIte := Alltrim(oGetDadVS9:aCols[wy,FG_POSVAR("VS9_SEQUEN","aHeader")])
		EndIf
	Next
Next

If ! lXX011Auto
	oGetDadVS9:oBrowse:Refresh()
EndIf
//adiciona os valores no total
VX11VALTOT(2)

//apaga os valores informados.  
If !lCPagPad // NAO é Condicao de Pagamento Padrao ERP
	nValTot := 0
	dDatIni := dDataBase 
	cCond := space(len(VV0->VV0_FORPAG))
	lLimpar := .f.
Endif

DbSelectArea("VS9")
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DADOSENT ³ Autor ³ Rafael Goncalves    ³ Data ³ 26/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Digita Dados da entrada do Pagamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lPriDig   -> Se .t. o de Pagamento para Saida   de Veiculos ³±±
±±³          |nPosC     -> Se lPriDig = .f. este parametro e Obrigatorio  ³±±
±±³          |             e a posicao da lunha do aColsC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DADOSENT(lPriDig,nPosC)
Local aCamposTRB := {}
Local cCadastro  := STR0014 // Registro da Entrada
Local nDif       := 0
Local i			 := 0
Local nPosT		 := 0
Local wy		 := 0
Local x			 := 0
Local j			 := 0
Local xy		 := 0
Local dDataCal   := dDataBase
Private wVar05
Private oScroll, Lin

if lPriDig == Nil
   lPriDig := .t.
Endif

wAlias := alias()

//Array contendo os Campos do Arquivo de Trabalho.

Lin := nPosC

if oGetDadVS9:aCols[Lin,Len(oGetDadVS9:aCols[Lin])] == .t.
   Return .t.
Endif

If GetSx3Cache(subs(readvar(),4,10),"X3_PROPRI") == "U" // não valida campo de usuário
   Return .t.
Endif


if Lin <= Len(oGetDadVS9:aCols) .and. !Empty(oGetDadVS9:aCols[Lin,FG_POSVAR("VS9_TIPPAG","aHeader")])
	If ReadVar() == "M->VS9_DATPAG"
		Return .t.
	ElseIf !ReadVar() $ "M->VS9_REFPAG/M->VS9_VALPAG/M->VS9_PORTAD/M->VS9_NATURE/M->VS9_PARCVD/"
		Return .f.
	Endif
Endif

if !Readvar() = "M->VS9_TIPPAG"
	Return .t.
Endif

aColsCSlv := aClone(oGetDadVS9:aCols)

//valida se tipo de pagamento eh igual a 5
DbSelectarea("VSA")
If DbSeek(xFilial("VSA")+M->VS9_TIPPAG)
   If VSA->VSA_TIPO <> "5"
   		MsgStop(STR0015,STR0009) // Tipo de pagamento informado nao e' valido! / Atencao
   		Return .f.
   EndIf
EndIf

If oGetDadVS9:aCols[Lin,FG_POSVAR("VS9_TIPPAG","aHeader")] == "CD"
   MsgStop(STR0016,STR0009) // Codigo de pagamento para referencia interna... / Atencao
   Return .f.
EndIf

If lPriDig
   aadd(aCamposTRB,{"QTDEPARC","2",03,0,STR0017,"999"              ,".t."}) // Qtdade Parcelas
   aadd(aCamposTRB,{"INTERVAL","2",02,0,STR0018,"99"               ,".t."}) // Intervalo
   aadd(aCamposTRB,{"PRIMPARC","2",02,0,STR0019,"999"              ,".t."}) // Dias 1. Parcela
   aadd(aCamposTRB,{"NUMDOCTO","2",10,0,STR0020,"9999999999"       ,".t."}) // Nro do Docto
   aadd(aCamposTRB,{"VALDOCTO","2",10,0,STR0021,"@E 999,999,999.99",".t."}) // Valor do Docto
Endif

DbSelectarea("VSA")
if DbSeek(xFilial("VSA")+M->VS9_TIPPAG)
   DbSelectarea("VSB")
   if DbSeek(xFilial("VSB")+M->VS9_TIPPAG)
      Do While !EOF() .and. VSB_TIPPAG == VSA->VSA_TIPPAG
         if !Empty(VSB_NOMECP) .and. !Empty(VSB_TIPOCP)
            aadd(aCamposTRB,{VSB_NOMECP,VSB_TIPOCP,VSB_TAMACP,VSB_DECICP,VSB_DESCCP,VSB_PICTCP,VSB_VALICP})
         Endif
         DbSkip()
      Enddo
   Endif
Else
   Return .f.
Endif

aTela := {}
aGets := {}

For i:=1 to Len(aCamposTRB)
    if Empty(aCamposTRB[i,7])
       aCamposTRB[i,7] := ".t."
    Endif
    if aCamposTRB[i,2] == [1]
       wSpa  := aCamposTRB[i,3]
       wVar  := "wVar"+StrZero(i,2)
       wPic  := "wPic"+StrZero(i,2)
       wSiz  := "wSiz"+StrZero(i,2)
       wVal  := "wVal"+StrZero(i,2)
       &wSiz := if(wSpa*8>90,90,wSpa*8)
       &wPic := aCamposTRB[i,6]
       &wVal := aCamposTRB[i,7]
       &wVar := Space(wSpa)
    Elseif aCamposTRB[i,2] == [2]
       wSpa  := aCamposTRB[i,3]
       wVar  := "wVar"+StrZero(i,2)
       wPic  := "wPic"+StrZero(i,2)
       wSiz  := "wSiz"+StrZero(i,2)
       wVal  := "wVal"+StrZero(i,2)
       &wSiz := if(wSpa*8>90,90,wSpa*8)
       &wPic := aCamposTRB[i,6]
       &wVal := aCamposTRB[i,7]
       &wVar := 0
    Else
       wSpa  := aCamposTRB[i,3]
       wVar  := "wVar"+StrZero(i,2)
       wPic  := "wPic"+StrZero(i,2)
       wSiz  := "wSiz"+StrZero(i,2)
       wVal  := "wVal"+StrZero(i,2)
       &wSiz := if(wSpa*8>90,90,wSpa*8)
       &wPic := aCamposTRB[i,6]
       &wVal := aCamposTRB[i,7]
       &wVar := ctod('')
    Endif
    if !Empty(&wVal)
       if !"(" $ &wVal
          if Type(&WVal) $ "UE/UI"
             MsgStop(STR0022+" "+aCamposTRB[i,5]+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0023,STR0009) // Campo: / A validacao do campo esta incorreta, verifique! / Atencao
             &wVal := ".t."
          Endif
       Endif
    Endif
Next

zOpca := 1

DEFINE MSDIALOG oDlgEPar FROM  06,12 TO 29,90 TITLE cCadastro OF oMainWnd

Lin := 15

o011Scroll := TScrollBox():New( oDlgEPar, 001 , 004 , 075 , 170 , .t. , , .t. )
o011Scroll:Align := CONTROL_ALIGN_ALLCLIENT

If Len(aCamposTRB) > 0
	@ Lin, 005 say aCamposTRB[1,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar01 PICTURE wPic01 VALID &wVal01 SIZE wSiz01,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 1
	@ Lin, 005 say aCamposTRB[2,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar02 PICTURE wPic02 VALID &wVal02 SIZE wSiz02,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 2
	@ Lin, 005 say aCamposTRB[3,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar03 PICTURE wPic03 VALID &wVal03 SIZE wSiz03,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 3
	@ Lin, 005 say aCamposTRB[4,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar04 PICTURE wPic04 VALID &wVal04 SIZE wSiz04,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 4
	@ Lin, 005 say aCamposTRB[5,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar05 PICTURE wPic05 VALID &wVal05 SIZE wSiz05,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 5
	@ Lin, 005 say aCamposTRB[6,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar06 PICTURE wPic06 VALID &wVal06 SIZE wSiz06,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 6
	@ Lin, 005 say aCamposTRB[7,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar07 PICTURE wPic07 VALID &wVal07 SIZE wSiz07,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 7
	@ Lin, 005 say aCamposTRB[8,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar08 PICTURE wPic08 VALID &wVal08 SIZE wSiz08,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 8
	@ Lin, 005 say aCamposTRB[9,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar09 PICTURE wPic09 VALID &wVal09 SIZE wSiz09,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 9
	@ Lin, 005 say aCamposTRB[10,5] OF o011Scroll Pixel
	@ Lin, 050 MSGET wVar10 PICTURE wPic10 VALID &wVal10 SIZE wSiz10,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

Lin := 15

If Len(aCamposTRB) > 10
	@ Lin, 150 say aCamposTRB[11,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar11 PICTURE wPic11 VALID &wVal11 SIZE wSiz11,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 11
	@ Lin, 150 say aCamposTRB[12,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar12 PICTURE wPic12 VALID &wVal12 SIZE wSiz12,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 12
	@ Lin, 150 say aCamposTRB[13,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar13 PICTURE wPic13 VALID &wVal13 SIZE wSiz13,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 13
	@ Lin, 150 say aCamposTRB[14,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar14 PICTURE wPic14 VALID &wVal14 SIZE wSiz14,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 14
	@ Lin, 150 say aCamposTRB[15,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar15 PICTURE wPic15 VALID &wVal15 SIZE wSiz15,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 15
	@ Lin, 150 say aCamposTRB[16,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar16 PICTURE wPic16 VALID &wVal16 SIZE wSiz16,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 16
	@ Lin, 150 say aCamposTRB[17,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar17 PICTURE wPic17 VALID &wVal17 SIZE wSiz17,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 17
	@ Lin, 150 say aCamposTRB[18,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar18 PICTURE wPic18 VALID &wVal18 SIZE wSiz18,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 18
	@ Lin, 150 say aCamposTRB[19,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar19 PICTURE wPic19 VALID &wVal19 SIZE wSiz19,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

If Len(aCamposTRB) > 19
	@ Lin, 150 say aCamposTRB[20,5] OF o011Scroll Pixel
	@ Lin, 205 MSGET wVar20 PICTURE wPic20 VALID &wVal20 SIZE wSiz20,10 OF o011Scroll PIXEL COLOR CLR_BLACK
	Lin := Lin + 15
EndIf

ACTIVATE MSDIALOG oDlgEPar CENTER ON INIT (EnchoiceBar(oDlgEPar,{|| zOpca := 1, oDlgEPar:End()},{|| zOpca := 2,oDlgEPar:End()}) )

If zOpca == 1
	If lPriDig
		dDataCal := dDataBase+wVar03
		//////////////////////////////////////////////////////////////////////
		// Verificar divergencia nos Valores das Parcelas com o Valor Total //
		//////////////////////////////////////////////////////////////////////
		nDif := 0
		i := round((wVar05/wVar01),2)
		If (i*wVar01) <> wVar05
			nDif := ( wVar05 - (i*wVar01) )
		EndIf
		//////////////////////////////////////////////////////////////////////
		For i := 1 to wVar01
			If i == 1
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_TIPPAG","aHeader")] := M->VS9_TIPPAG
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DESPAG","aHeader")] := Posicione("VSA",1,xFilial("VSA")+M->VS9_TIPPAG,"VSA_DESPAG")
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DATPAG","aHeader")] := dDataCal
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_VALPAG","aHeader")] := round((wVar05/wVar01),2)+nDif
				if wVar04 > 0
					oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := alltrim(Str(wVar04))+space(15-Len(alltrim(Str(wVar04))))
				Else
					oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := space(10)
				Endif
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_SEQUEN","aHeader")] := StrZero(i,2)
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_NATURE","aHeader")] := space(10)
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),Len(oGetDadVS9:aCols[i])] := .f.
			Else
				aAdd(oGetDadVS9:aCols,Array(len(aHeader)+1))
				//aadd(oGetDadVS9:aCols,array(nUsadoC+1))
				For xy:=1 to Len(aHeader)
					oGetDadVS9:aCols[Len(oGetDadVS9:aCols),xy] := CriaVar(aHeader[xy,2])
				Next
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_TIPPAG","aHeader")] := M->VS9_TIPPAG
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DESPAG","aHeader")] := Posicione("VSA",1,xFilial("VSA")+M->VS9_TIPPAG,"VSA_DESPAG")
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_DATPAG","aHeader")] := dDataCal
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_VALPAG","aHeader")] := round((wVar05/wVar01),2)
				if wVar04 > 0
	   				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := alltrim(Str(wVar04+(i-1)))+space(15-Len(alltrim(Str(wVar04))))
	   			Else
	   				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_REFPAG","aHeader")] := space(10)
	   			Endif
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_SEQUEN","aHeader")] := StrZero(i,2)
				oGetDadVS9:aCols[len(oGetDadVS9:aCols),FG_POSVAR("VS9_NATURE","aHeader")] := space(10)

				oGetDadVS9:aCols[len(oGetDadVS9:aCols),Len(oGetDadVS9:aCols[i])] := .f.
			EndIf
			dDataCal := dDataCal+wVar02
		Next
	EndIf

	//Ajusta os tipos de pagamentos iguais e com a mesma sequencia
	cTipIte := ""
	cSeqIte := ""
	For xy:=1 to Len(oGetDadVS9:aCols)
		cTipIte := Alltrim(oGetDadVS9:aCols[xy,FG_POSVAR("VS9_TIPPAG","aHeader")])
		cSeqIte := Alltrim(oGetDadVS9:aCols[xy,FG_POSVAR("VS9_SEQUEN","aHeader")])
		For wy:=xy to Len(oGetDadVS9:aCols)
			If wy == xy
				Loop
			EndIf
			If Alltrim(oGetDadVS9:aCols[wy,FG_POSVAR("VS9_TIPPAG","aHeader")]) == cTipIte
				oGetDadVS9:aCols[wy,FG_POSVAR("VS9_SEQUEN","aHeader")] := StrZero(Val(cSeqIte)+1,2)
				cSeqIte := Alltrim(oGetDadVS9:aCols[wy,FG_POSVAR("VS9_SEQUEN","aHeader")])
			EndIf
		Next
	Next

	// Array com dados dos Tipos de Pagamentos p/ gravar no Arquivo "VSE"
	// aGravaEnt[n,1]  == Posicao do aCols
	// aGravaEnt[n,2]  == NUMIDE
	// aGravaEnt[n,3]  == Tipo da Operacao
	// aGravaEnt[n,4]  == Tipo de Pagamento
	// aGravaEnt[n,5]  == Descricao do Campo
	// aGravaEnt[n,6]  == Nome do Campo
	// aGravaEnt[n,7]  == Tipo de Campo "C/N/D"
	// aGravaEnt[n,8]  == Tamanho do Campo
	// aGravaEnt[n,9]  == Decimal do Campo
	// aGravaEnt[n,10] == Picture do Campo
	// aGravaEnt[n,11] == Valor Digitado
	// aGravaEnt[n,12] == Sequencia
	// aGravaEnt[n,13] == Se o registro esta valido(.t.) na VS9 ou Nao(.f.)

	If lPriDig
		nPos := n
		For j:=1 to wVar01
			For x:=6 to len(aCamposTRB)
				If aCamposTRB[x,2] == "1"
					cConteudo := &("wVar"+Strzero(x,2))
				ElseIf aCamposTRB[x,2] == "2"
					cConteudo := Transform(&("wVar"+Strzero(x,2)),aCamposTRB[x,6])
				Else
					cConteudo := dToc(&("wVar"+Strzero(x,2)))
				EndIf
				aadd(aGravaEnt,{nPos,M->VS9_NUMIDE,M->VS9_TIPOPE,M->VS9_TIPPAG,(aCamposTRB[x,5]),aCamposTRB[x,1],aCamposTRB[x,2],aCamposTRB[x,3],aCamposTRB[x,4],aCamposTRB[x,6],cConteudo,M->VS9_SEQUEN,.f.})
			Next
			nPos++
		Next
	Else
		For nPosT := 1 to Len(aGravaEnt)
			If aGravaEnt[nPosT,1] == nPosC
				For x := 1 to Len(aCamposTRB)
					aGravaEnt[nPosT,1] := nPosC
					aGravaEnt[nPosT,2] := M->VS9_NUMIDE
					aGravaEnt[nPosT,3] := M->VS9_TIPOPE
					aGravaEnt[nPosT,4] := oGetDadVS9:aCols[nPosC,FG_POSVAR("VS9_TIPPAG","aHeader")]
					aGravaEnt[nPosT,5] := aCamposTRB[x,5]
					aGravaEnt[nPosT,6] := aCamposTRB[x,1]
					aGravaEnt[nPosT,7] := aCamposTRB[x,2]
					aGravaEnt[nPosT,8] := aCamposTRB[x,3]
					aGravaEnt[nPosT,9] := aCamposTRB[x,4]
					aGravaEnt[nPosT,10] := aCamposTRB[x,6]
					If aCamposTRB[x,2] == "1"
						cConteudo := &("wVar"+Strzero(x,2))
					ElseIf aCamposTRB[x,2] == "2"
						cConteudo := Transform(&("wVar"+Strzero(x,2)),aCamposTRB[x,6])
					Else
						cConteudo := dToc(&("wVar"+Strzero(x,2)))
					EndIf
					aGravaEnt[nPosT,11] := cConteudo
					aGravaEnt[nPosT,12] := M->VS9_SEQUEN
					nPosT++
				Next
			EndIf
		Next
	EndIf

	If lPriDig
		n := Len(oGetDadVS9:aCols)
	EndIf

Else
	aCols := aClone(aColsCSlv)
	aCols[n,FG_POSVAR("VS9_TIPPAG","aHeader")] := "  "
	aCols[n,FG_POSVAR("VS9_DESPAG","aHeader")] := ""
	M->VS9_TIPPAG := "  "
EndIf

//adiciona os valores no total
VX11VALTOT(2)

If !Empty(wAlias)
	DbSelectarea(wAlias)
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX11VALTOTº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MANUTENCAO NO VALOR TOTAL DOS PAGAMENTOS                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX11VALTOT(nTp)
Local ni_ := 1
Local lRet := .t.
If nTp == 1
	If M->VS9_VALPAG < 0
		Return .f.
	EndIf
EndIf
nValTotal:=0
For ni_:=1 to Len(oGetDadVS9:aCols)
	if !oGetDadVS9:aCols[ni_,len(aHeader)+1]
		if oGetDadVS9:nAt == ni_ .and. nTp == 1
			nValTotal += M->VS9_VALPAG
		else
			nValTotal += oGetDadVS9:aCols[ni_,FG_POSVAR("VS9_VALPAG","aHeader")]
		EndIF
	endif
Next
If ! lXX011Auto
	oValTotal:Refresh()
	oGetDadVS9:oBrowse:Refresh()
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX11OBRGTº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ VALIDA SE CAMPOS OBRIGATORIOS FORAM INFORMADOS             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX11OBRGT(nLiAtu, aCols , aHeader)
Local ni_ := 0
For ni_:=1 to Len(aHeader)
	If X3Obrigat(aHeader[ni_,2]) .and. Empty(aCols[nLiAtu,FG_POSVAR(aHeader[ni_,2],"aHeader")])
  		If aHeader[ni_,2] <> "VS9_REFPAG"
			Help(" ",1,"OBRIGAT2",,aHeader[ni_,2],4,1 )
			Return
		EndIf
	EndIf
Next
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_DELVSEº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ REALIZA MANUTENCAO NO ARRAY DO VSE P/COLOCAR COMO DELETADO º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELVSE(nLinAtu)
Local nj_ := 1
For nj_:= 1 to len(aGravaEnt)
	If aGravaEnt[nj_,1] == nLinAtu
		aGravaEnt[nj_,13]:= !aGravaEnt[nj_,13]
	EndIF
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX11VLPORTº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ VALIDA SE PORTADOR EXISTE                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX11VLPORT()
Local lRet := .f.
DbSelectArea("SA6")
DbsetOrder(1)
if DbSeek(xFilial("SA6")+M->VS9_PORTAD)
	oGetDadVS9:aCols[oGetDadVS9:nAt,FG_POSVAR("VS9_DESPOR","aHeader")] := alltrim(SA6->A6_NOME)
	lRet := .t.
EndIF
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_BAIXADOº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ VERIFICA SE O TITULO ESTA BAIXADO                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BAIXADO(nLinVS9,lMsg)
Local nRecSE1   := 0
Local aVetaAlt  := {}
Local ni        := 0
Local lRet      := .f.
Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Local cNumTit   := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI   := VV0->VV0_NUMNFI
Local cQuery    := ""
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
Default nLinVS9 := oGetDadVS9:nAt
Default lMsg    := .t.
If left(GetNewPar("MV_TITATEN","0"),1) == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
	cQuery += "OR SE1.E1_NUM='"+cNumNFI+"'"
EndIf
cQuery += " ) AND SE1.E1_TIPO='"+oGetDadVS9:aCols[nLinVS9,FG_POSVAR("VS9_TIPPAG","aHeader")]+"' AND "
If oGetDadVS9:aCols[nLinVS9,FG_POSVAR("VS9_PARCEL","aHeader")] <> NIL
	cQuery += "SE1.E1_PARCELA='"+oGetDadVS9:aCols[nLinVS9,FG_POSVAR("VS9_PARCEL","aHeader")]+"' AND "
Else
	cQuery += "SE1.E1_PARCELA=' ' AND "
EndIf
cQuery += "SE1.E1_PREFORI='"+cPrefOri+"' AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR )"
cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
nRecSE1 := FM_SQL(cQuery)
If nRecSE1 > 0
	lRet := .t.
	SE1->(DbGoTo(nRecSE1))
	If lMsg
		MsgStop(STR0024+space(30)+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
			Alltrim(RetTitle("E1_PREFIXO"))+": "+SE1->E1_PREFIXO+CHR(13)+CHR(10)+;
			Alltrim(RetTitle("E1_NUM"))+": "+SE1->E1_NUM+CHR(13)+CHR(10)+;
			Alltrim(RetTitle("E1_PARCELA"))+": "+SE1->E1_PARCELA+CHR(13)+CHR(10)+;
			Alltrim(RetTitle("E1_TIPO"))+": "+SE1->E1_TIPO,STR0009) // Titulo ja esta baixado! / Atencao
	EndIf
Else // Titulo pode sofrer alteracoes
	For ni := 1 to len(aHeader)
		aadd(aVetaAlt,aHeader[ni,2])
	Next
EndIf
If ! lXX011Auto
	oGetDadVS9:aAlter := oGetDadVS9:oBrowse:aAlter := aClone(aVetaAlt)
EndIf
Return(lRet)

/*/{Protheus.doc} VX0110016_ValidandoExclusaoDaLinha
Função para validações customizadas antes da exclusão da linha
@author Fernando Vitor Cavani
@since 14/01/2019
@version 1.0
@param nLinVS9, numérico, Linha da GetDados
@return lógico
@type function
/*/
Static Function VX0110016_ValidandoExclusaoDaLinha(nLinVS9)
Local lRet := .t.

Default nLinVS9 := oGetDadVS9:nAt

// Ponto de Entrada para validações customizadas antes da exclusão da linha
If ExistBlock("VXX11VEX")
	lRet := ExecBlock("VXX11VEX", .f., .f., {!oGetDadVS9:aCols[nLinVS9, Len(oGetDadVS9:aCols[nLinVS9])], nLinVS9}) // linha deletada (.t. ou .f.) e número da linha
EndIf

If lRet
	lRet := FS_BAIXADO(nLinVS9, .t.)
	If !(lRet)
		oGetDadVS9:aCols[oGetDadVS9:nAt, Len(aHeader) + 1] := !oGetDadVS9:aCols[oGetDadVS9:nAt, Len(aHeader) + 1]
		VX11VALTOT(1)
		FS_DELVSE(nLinVS9)
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} VX0110011_ValidTudoOK
Validacao Tudo OK

@author Andre Luis Almeida
@since 12/12/2018
@version undefined

@type function
/*/
Static Function VX0110011_ValidTudoOK()
Local nCntFor     := 0
Local lRet        := .t.
Local nVS9_PARCVD := FG_POSVAR("VS9_PARCVD","aHeader")
Local nVS9_VALPAG := FG_POSVAR("VS9_VALPAG","aHeader")
For nCntFor := 1 to len(oGetDadVS9:aCols)
	If !oGetDadVS9:aCols[nCntFor,len(oGetDadVS9:aCols[nCntFor])]
		If nVS9_PARCVD > 0 .and. Empty(oGetDadVS9:aCols[nCntFor,nVS9_PARCVD])
			MsgStop(STR0028,STR0009) // Necessário informar se a Entrada vai ser recebida no Venda Direta. / Atencao
			lRet := .f.
			Exit
		EndIf
		If oGetDadVS9:aCols[nCntFor,nVS9_VALPAG] <= 0
			MsgStop(STR0011,STR0009) // Valor informado menor ou igual a zero! / Atencao
			lRet := .f.
			Exit
		EndIf
	EndIf
Next
Return lRet

/*/{Protheus.doc} VX0110021_ParcelasVendaDireta()
Preencher se a parcela vai ser Recebida no Venda Direta

@author Andre Luis Almeida
@since 12/12/2018
@version undefined

@type function
/*/
Static Function VX0110021_ParcelasVendaDireta(cPARCVD)
Local nVS9_PARCVD := FG_POSVAR("VS9_PARCVD","aHeader")
Local nVS9_DATPAG := FG_POSVAR("VS9_DATPAG","aHeader")
Local nCntFor := 0
If nVS9_PARCVD > 0
	For nCntFor := 1 to len(oGetDadVS9:aCols)
		Do Case
			Case Empty(cPARCVD) // Branco
				oGetDadVS9:aCols[nCntFor,nVS9_PARCVD] := " "
			Case cPARCVD == "0" // Apenas as Entradas A VISTA
				If dDataBase >= oGetDadVS9:aCols[nCntFor,nVS9_DATPAG]
					oGetDadVS9:aCols[nCntFor,nVS9_PARCVD] := "1" // SIM
				Else
					oGetDadVS9:aCols[nCntFor,nVS9_PARCVD] := "0" // NAO
				EndIf
			Case cPARCVD == "1" // Todas as Entradas
				oGetDadVS9:aCols[nCntFor,nVS9_PARCVD] := "1" // SIM
			Case cPARCVD == "2" // Nenhuma das Entradas
				oGetDadVS9:aCols[nCntFor,nVS9_PARCVD] := "0" // NAO
		EndCase
	Next
	oGetDadVS9:oBrowse:Refresh()
EndIf
Return

// ษออออออออหออออออออป
// บ Versao บ 09     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIXX003.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXX003 บ Autor ณ Andre Luis Almeida บ Data ณ  31/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acao de Venda VZ7 (Troco/Cortesia/Redutor/VendaAgregada)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpc    (2-Visualizar/4-Alterar/3-Incluir)                 บฑฑ
ฑฑบ          ณ lTela   (Mostra Tela com Modelo 3)                         บฑฑ
ฑฑบ          ณ aParVZ7 (Vetor de Veiculos)                                บฑฑ
ฑฑบ			 ณ	 aParVZ7[n,01] = Nro Atendimento                          บฑฑ
ฑฑบ          ณ   aParVZ7[n,02] = Chassi Interno (CHAINT) *                บฑฑ
ฑฑบ          ณ   aParVZ7[n,03] = Marca                                    บฑฑ
ฑฑบ          ณ   aParVZ7[n,04] = Modelo                                   บฑฑ
ฑฑบ          ณ   aParVZ7[n,05] = Grupo do Modelo                          บฑฑ
ฑฑบ          ณ   aParVZ7[n,06] = Chassi                                   บฑฑ
ฑฑบ          ณ   aParVZ7[n,07] = ESTVEI (Novo/Usado)                      บฑฑ
ฑฑบ          ณ   aParVZ7[n,08] = Opcionais Fabrica                        บฑฑ
ฑฑบ          ณ   aParVZ7[n,09] = Ano Fab/Mod                              บฑฑ
ฑฑบ          ณ   aParVZ7[n,10] = Item do Atendimento                      บฑฑ
ฑฑบ          ณ cTipo   ( 0=Troco 1=Cortesia 2=Redutor 3=Venda Agregada )  บฑฑ
ฑฑบ          ณ aVZ7    (Vetor de Retorno)                                 บฑฑ
ฑฑบ			 ณ	 aVZ7[1] = aHeader                                        บฑฑ
ฑฑบ          ณ   aVZ7[2] = aCols                                          บฑฑ
ฑฑบ          ณ cIteTra = Item do Atendimento                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos -> Novo Atendimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXX003(nOpc,lTela,aParVZ7,cTipo,aVZ7,cIteTra,lXX003Auto)
Local bCampo       := { |nCPO| Field(nCPO) }
Local nCntFor      := 0
Local cGetDNView   := ""
Local lRet         := .f.
Local lVai         := .t.
Local nTtLen       := 0
Local nPos         := 0
Local _ni          := 0
Local nj 	       := 0
Local aAcaoHd      := {}
Local cOpcion      := ""
Local lOk          := .f.
Local lChassi      := .f.
Local dDatAcao     := dDataBase
Local lJaIncIC     := .f.
Local nUsadoIC     := 0
Local nOpcao       := 0
Local cTitulo      := ""
Local cCodMar      := ""
Local lManut       := FM_PILHA("VEIXX019") // Esta na TELA de Manutencao do Atendimento
Local lFazLev      := .t.
Local nPosItem     := 1
Local lVZ7ITETRA   := ( VZ7->(FieldPos("VZ7_ITETRA")) > 0 )
Local cVeiculo     := ""
Private aVZ7Exist  := {} // Vetor utilizado para Validar existencia de uma ACAO DE VENDA de outro tipo na DIGITACAO.
Private aHeaderVZ7 := aClone(aVZ7[1])
Private oAuxGetDados
Private oDlgVZ7
Private cTipAva    := ""
Default cTipo      := ""
Default cIteTra    := ""
Default lXX003Auto := .f.
If !Empty(cIteTra)
	nPosItem := aScan(aParVZ7,{|x| x[10] == cIteTra })
EndIf
cTipAva := cTipo//variavel utilizada no F3 VZX
If !Empty(aParVZ7[nPosItem,02])

	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+aParVZ7[nPosItem,02]))

	cVeiculo := Alltrim(VV1->VV1_CHASSI)+" - "

	aParVZ7[nPosItem,03] := VV1->VV1_CODMAR
	aParVZ7[nPosItem,04] := VV1->VV1_MODVEI
	aParVZ7[nPosItem,06] := VV1->VV1_CHASSI
	aParVZ7[nPosItem,07] := VV1->VV1_ESTVEI
	aParVZ7[nPosItem,08] := VV1->VV1_OPCFAB
	aParVZ7[nPosItem,09] := VV1->VV1_FABMOD

	VVF->(DbSetOrder(1))
	VVF->(DbSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA))

	dDatAcao := VVF->VVF_DATEMI
EndIf
VV2->(DbSetOrder(1))
VV2->(DbSeek(xFilial("VV2")+aParVZ7[nPosItem,03]+aParVZ7[nPosItem,04]))
cVeiculo += Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)
aParVZ7[nPosItem,05] := VV2->VV2_GRUMOD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VZ7",.t.) // .t. para carregar campos virtuais
nOpcG   := nOpc

If Empty(cTipo)
	cGetDNView := ""
	cTitulo    := STR0001 // Acao de Venda
Else
	If cTipo == "0" // Troco
		cGetDNView := "VZ7_CODACV,VZ7_AGRVLR,VZ7_COMPAG,VZ7_TIPTIT,"
		cTitulo    := STR0002 // Troco
	ElseIf cTipo == "1" // Cortesias
		cGetDNView := "VZ7_AGRVLR,VZ7_COMPAG,VZ7_GERORC,VZ7_TIPTIT,"
		cTitulo    := STR0003 // Cortesias
	ElseIf cTipo == "2" // Redutores
		cGetDNView := "VZ7_AGRVLR,VZ7_COMPAG,VZ7_GERORC,VZ7_TIPTIT,"
		cTitulo    := STR0004 // Redutores
	ElseIf cTipo == "3" // Vendas Agregadas
		cGetDNView := "VZ7_CODACV,VZ7_AGRVLR,"
		cTitulo    := STR0005 // Vendas Agregadas
	EndIf
EndIf
cGetDNView += "VZ7_NUMTRA,VZ7_ITETRA,VZ7_TIPORC,VZ7_TIPTEM,VZ7_GRUITE,VZ7_CODITE,VZ7_TIPSER,VZ7_GRUSER,VZ7_CODSER,VZ7_CODSEC,VZ7_DEPINT,VZ7_QTDENT"

cAliasGetD := "VZ7"
cLinOk     := ""
cFieldOk   := ""

For nj:=1 to Len(aVZ7[1])
	If !aVZ7[1,nj,2] $ cGetDNView
		aAdd(aAcaoHd,aClone(aVZ7[1,nj]))
	EndIf
Next

If lXX003Auto
	oAuxGetDados := DMS_GetDAuto():Create()
EndIf

FM_Mod3(cTitulo+" - "+cVeiculo,,cAliasGetD,,,@aAcaoHd,,,"VEIXX003VAL('2','"+cTipo+"')",,,,nOpcG,,oMainWnd,@oDlgVZ7,,@oAuxGetDados,,cGetDNView,1,,,,IIf(lTela,80,20),0,,,lXX003Auto)

If lXX003Auto
	oAuxGetDados:aHeader := aAcaoHd
EndIf

If !Empty(cTipo)
	M->VZ7_AGRVLR := cTipo
EndIf

oAuxGetDados:aCols := {}
nUsadoIC := len(oAuxGetDados:aHeader)

If lManut // Esta na TELA de Manutencao do Atendimento
	For nj:=1 to Len(aVZ7[2])
		If aVZ7[2,nj,FG_POSVAR("VZ7_AGRVLR","aHeaderVZ7")] == cTipo .and. !Empty(aVZ7[2,nj,FG_POSVAR("VZ7_ITECAM","aHeaderVZ7")])
			AADD(oAuxGetDados:aCols,Array(nUsadoIC+1))
			For _ni:=1 to nUsadoIC
				oAuxGetDados:aCols[Len(oAuxGetDados:aCols),_ni] := aVZ7[2,nj,FG_POSVAR(oAuxGetDados:aHeader[_ni,2],"aHeaderVZ7")]
			Next
			oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nUsadoIC+1] := aVZ7[2,nj,len(aVZ7[1])+1]
			lFazLev := .f.
		EndIf
	Next
EndIf

DbSelectArea("VZ7")
DbSetOrder(1)
If dbSeek(xFilial("VZ7")+aParVZ7[nPosItem,01]) .and. !Empty(cTipo)
	
	While !eof() .and. xFilial("VZ7") == VZ7->VZ7_FILIAL .and. VZ7->VZ7_NUMTRA == aParVZ7[nPosItem,01] 
		If !lVZ7ITETRA .or. VZ7->VZ7_ITETRA == aParVZ7[nPosItem,10]
			If VZ7->VZ7_AGRVLR == cTipo
				If lFazLev
					AADD(oAuxGetDados:aCols,Array(nUsadoIC+1))
					For _ni := 1 to nUsadoIC
						If oAuxGetDados:aHeader[_ni,10] # "V"
							oAuxGetDados:aCols[Len(oAuxGetDados:aCols),_ni] := FieldGet(FieldPos(oAuxGetDados:aHeader[_ni,2]))
						Else
							oAuxGetDados:aCols[Len(oAuxGetDados:aCols),_ni] := CriaVar(oAuxGetDados:aHeader[_ni,2])
						EndIf
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),_ni] := IIf(oAuxGetDados:aHeader[_ni,10] # "V",FieldGet(FieldPos(oAuxGetDados:aHeader[_ni,2])),CriaVar(oAuxGetDados:aHeader[_ni,2]))
					Next
					oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nUsadoIC+1] := .f.
				EndIf
			Else
				aAdd(aVZ7Exist,{VZ7->VZ7_ITECAM,VZ7->VZ7_AGRVLR,VZ7->VZ7_VALITE}) // Vetor utilizado para Validar existencia de uma ACAO DE VENDA de outro tipo na DIGITACAO.
			EndIf
		EndIf
		VZ7->(dbskip())
	Enddo
	
ElseIf ( nOpc == 3 .or. nOpc == 4 ) .and. lFazLev // Criar pelo VZ5 e Inclui ou Altera
	
	If Empty(cTipo)
		DbSelectArea("VZ5")
		dbSetOrder(1)
		dbSeek(xFilial("VZ5"))
		while !eof() .and. xFilial("VZ5") == VZ5->VZ5_FILIAL
			lOk := .f.
			Do Case
				Case !Empty(VZ5->VZ5_CHASSI) // Chassi
					If !Empty(aParVZ7[nPosItem,06]) .and. ( VZ5->VZ5_CHASSI == aParVZ7[nPosItem,06] )
						lOk := .t.
						lChassi := .t.
					EndIf
				Case !Empty(VZ5->VZ5_MODVEI) // Modelo
					If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD + VZ5->VZ5_MODVEI ) == ( aParVZ7[nPosItem,03] + aParVZ7[nPosItem,05] + aParVZ7[nPosItem,04] )
						lOk := .t.
					EndIf
				Case !Empty(VZ5->VZ5_GRUMOD) // Grupo do Modelo
					If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD ) == ( aParVZ7[nPosItem,03] + aParVZ7[nPosItem,05] )
						lOk := .t.
					EndIf
				Case !Empty(VZ5->VZ5_CODMAR) // Marca
					If VZ5->VZ5_CODMAR == aParVZ7[nPosItem,03]
						lOk := .t.
					EndIf
				OtherWise
					lOk := .t.
			EndCase
			If lOk
				If !Empty(VZ5->VZ5_ESTVEI) .and. VZ5->VZ5_ESTVEI <> "2" // Estado do Veiculo: 0-Novos/1-Usados/2-Ambos
					If !Empty(aParVZ7[nPosItem,07]) .and. VZ5->VZ5_ESTVEI <> aParVZ7[nPosItem,07]
						lOk := .f.
					EndIf
				EndIf
			EndIf
			If !lOk
				DbSelectArea("VZ5")
				DbSkip()
				Loop
			EndIf
			lVai := .t.
			nTtLen := Len(Alltrim(VZ5->VZ5_OPCION))
			For _ni := 1 to nTtLen
				cOpcion := subs(VZ5->VZ5_OPCION,_ni*3-2,3)
				If at(cOpcion,aParVZ7[nPosItem,08]) == 0
					lVai := .f.
				Endif
			Next
			If VZ5->VZ5_DATVER <> "1" // diferente da data de emissao na Fabrica
				dDatAcao := dDataBase
			EndIf
			If dDatAcao >= VZ5->VZ5_DATINI .and. dDatAcao <= VZ5->VZ5_DATFIN .and. If(Empty(VZ5->VZ5_FABMOD),.t.,Alltrim(aParVZ7[nPosItem,09]) == Alltrim(VZ5->VZ5_FABMOD)) .and. lVai .and. If(lChassi,!Empty(VZ5->VZ5_CHASSI),Empty(VZ5->VZ5_CHASSI))
				DbSelectArea("VZ6")
				DbSetOrder(1)
				DbSeek(xFilial("VZ6")+VZ5->VZ5_CODACV)
				While !eof() .and. xFilial("VZ6") == VZ6->VZ6_FILIAL .and. VZ6->VZ6_CODACV == VZ5->VZ5_CODACV
					If !Empty(cTipo)
						If VZ6->VZ6_AGRVLR <> cTipo
							DbSelectArea("VZ6")
							DbSkip()
							Loop
						EndIf
					EndIf
					If Empty(VZ6->VZ6_ITECAM)
						DbSelectArea("VZ6")
						DbSkip()
						Loop
					EndIf
					//// Valida se ja incluiu na aCols do VZ7  ////
					lJaIncIC := .f.
					For _ni:=1 to len(oAuxGetDados:aCols)
						If oAuxGetDados:aCols[_ni,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")] == VZ6->VZ6_ITECAM
							lJaIncIC := .t.
							Exit
						EndIf
					Next
					///////////////////////////////////////////////
					If !lJaIncIC
						AADD(oAuxGetDados:aCols,Array(nUsadoIC+1))
						For _ni := 1 to nUsadoIC
							oAuxGetDados:aCols[Len(oAuxGetDados:aCols),_ni] := IIf(oAuxGetDados:aHeader[_ni,10] # "V",FieldGet(FieldPos(oAuxGetDados:aHeader[_ni,2])),CriaVar(oAuxGetDados:aHeader[_ni,2]))
						Next
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR("VZ7_CODACV","oAuxGetDados:aHeader")] := VZ6->VZ6_CODACV
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")] := VZ6->VZ6_ITECAM
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR("VZ7_DESCAM","oAuxGetDados:aHeader")] := Posicione("VZX",1,xFilial("VZX")+VZ6->VZ6_ITECAM,"VZX_DESCAM")
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR("VZ7_VALITE","oAuxGetDados:aHeader")] := VZ6->VZ6_VALITE
						If Empty(cTipo) .or. cTipo == "3" // Todas Acoes de Venda ou Venda Agregada
							oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR('VZ7_COMPAG',"oAuxGetDados:aHeader")] := VZ6->VZ6_COMPAG
						EndIf
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR('VZ7_ALTVLR',"oAuxGetDados:aHeader")] := VZ6->VZ6_ALTVLR
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR('VZ7_OBRIGA',"oAuxGetDados:aHeader")] := VZ6->VZ6_OBRIGA
						If Empty(cTipo) // Todas Acoes de Venda
							oAuxGetDados:aCols[Len(oAuxGetDados:aCols),FG_POSVAR('VZ7_AGRVLR',"oAuxGetDados:aHeader")] := VZ6->VZ6_AGRVLR
						EndIf
						oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nUsadoIC+1] := .f.
					EndIf
					DbSelectArea("VZ6")
					DbSkip()
				EndDo
			EndIf
			DbSelectArea("VZ5")
			DbSkip()
		EndDo
	EndIf
	
EndIf

// Quando nao houver cadastro no VZ7 criar registro em branco na aCols //
If Len(oAuxGetDados:aCols) <= 0
	AADD(oAuxGetDados:aCols,Array(Len(oAuxGetDados:aHeader)+1))
	For nCntFor:=1 to len(oAuxGetDados:aHeader)
		oAuxGetDados:aCols[Len(oAuxGetDados:aCols),nCntFor] := CriaVar(oAuxGetDados:aHeader[nCntFor,2],.t.)
	Next
	oAuxGetDados:aCols[Len(oAuxGetDados:aCols),Len(oAuxGetDados:aHeader)+1]:=.F.
EndIf

If ! lXX003Auto
	If lTela // Mostra TELA
		
		// ENCHOICEBAR com BOTOES de OK e CANCELAR //
		oAuxGetDados:oBrowse:bDelete := {|| VEIXX003DEL(nOpc,cTipo) }
		oAuxGetDados:oBrowse:bChange := {|| FS_AALTER(cTipo) }
		
		ACTIVATE MSDIALOG oDlgVZ7 CENTER ON INIT EnchoiceBar(oDlgVZ7,{ || IIf(VEIXX003VAL('3',cTipo),(nOpcao := 1 , oDlgVZ7:End()),.f.) }, { || oDlgVZ7:End() },,)
		
	Else
		
		oAuxGetDados:oBrowse:nWidth  := 0
		oAuxGetDados:oBrowse:nHeight := 0
		
		@ 010 , 010 SAY STR0006 OF oDlgVZ7 PIXEL COLOR CLR_HBLUE // Aguarde...
		@ 023 , 010 SAY STR0007 OF oDlgVZ7 PIXEL COLOR CLR_HBLUE // Realizando levantamento...
		
		// Mesmo sem mostrar TELA e' necessario a chamada do ACTIVATE para nao parar de funcionar a EnchoiceBar da Tela anterior (FM_MOD3) //
		ACTIVATE MSDIALOG oDlgVZ7 CENTER ON INIT (nOpcao := 1 , oDlgVZ7:End() )
		
	EndIf
EndIf

If nOpcao == 1
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aVZ7[2] := {}
		// Criar registro na aCols do VZ7 para poder apagar todas Acoes de Venda relacionadas ao Atendimento //
		If Empty(cTipo)
			aAdd(aVZ7[2],Array(len(aVZ7[1])+1))
			nPos := len(aVZ7[2])
			aVZ7[2,nPos,1] := "DELALL"
			If lVZ7ITETRA
				aVZ7[2,nPos,FG_POSVAR("VZ7_ITETRA","aHeaderVZ7")] := cIteTra // Nro do Item do Atendimento
			EndIf
			aVZ7[2,nPos,len(aVZ7[1])+1] := .t.
		EndIf
		///////////////////////////////////////////////////////////////////////////////////////////////////////
		For _ni := 1 to len(oAuxGetDados:aCols)
			aAdd(aVZ7[2],Array(len(aVZ7[1])+1))
			nPos := len(aVZ7[2])
			aVZ7[2,nPos,FG_POSVAR("VZ7_NUMTRA","aHeaderVZ7")] := PadR(aParVZ7[nPosItem,01],aVZ7[1,FG_POSVAR("VZ7_NUMTRA","aHeaderVZ7"),4]," ") // Nro do Atendimento
			If lVZ7ITETRA
				aVZ7[2,nPos,FG_POSVAR("VZ7_ITETRA","aHeaderVZ7")] := cIteTra // Nro do Item do Atendimento
			EndIf
			aVZ7[2,nPos,FG_POSVAR("VZ7_CODACV","aHeaderVZ7")] := PadR(" ",aVZ7[1,FG_POSVAR("VZ7_CODACV","aHeaderVZ7"),4]," ") // Codigo Acao de venda
			For nj := 1 to len(oAuxGetDados:aHeader)
				aVZ7[2,nPos,FG_POSVAR(oAuxGetDados:aHeader[nj,2],"aHeaderVZ7")] := oAuxGetDados:aCols[_ni,FG_POSVAR(oAuxGetDados:aHeader[nj,2],"oAuxGetDados:aHeader")]
			Next
			If !Empty(cTipo)
				aVZ7[2,nPos,FG_POSVAR("VZ7_AGRVLR","aHeaderVZ7")] := cTipo
				If FG_POSVAR("VZ7_COMPAG","aHeaderVZ7") > 0
					If cTipo == "0" // Troco
						aVZ7[2,nPos,FG_POSVAR("VZ7_COMPAG","aHeaderVZ7")] := "2" // Incluir no Atendimento
					ElseIf cTipo == "1" // Cortesia
						aVZ7[2,nPos,FG_POSVAR("VZ7_COMPAG","aHeaderVZ7")] := " " // Nao Faz Nada
					ElseIf cTipo == "2" // Redutor
						aVZ7[2,nPos,FG_POSVAR("VZ7_COMPAG","aHeaderVZ7")] := " " // Nao Faz Nada
					EndIf
				EndIf
				If FG_POSVAR("VZ7_TIPTIT","aHeaderVZ7") > 0
					If cTipo == "0" // Troco
						aVZ7[2,nPos,FG_POSVAR("VZ7_TIPTIT","aHeaderVZ7")] := "  " // Nao Faz Nada
					ElseIf cTipo == "1" // Cortesia
						aVZ7[2,nPos,FG_POSVAR("VZ7_TIPTIT","aHeaderVZ7")] := "  " // Nao Faz Nada
					ElseIf cTipo == "2" // Redutor
						aVZ7[2,nPos,FG_POSVAR("VZ7_TIPTIT","aHeaderVZ7")] := "  " // Nao Faz Nada
					EndIf
				EndIf
			EndIf
			aVZ7[2,nPos,len(aVZ7[1])+1] := oAuxGetDados:aCols[_ni,len(oAuxGetDados:aCols[_ni])]
		Next
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXX003VALบ Autor ณ Andre Luis Almeida บ Data ณ 31/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Valida aCols VZ7                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXX003VAL(cTp,cTipo)
Local ni     := 0
Local cObs   := ""
Default cTp  := "1"
If cTp == "1" // Campo
	If ReadVar() == "M->VZ7_ITECAM"
		DbSelectArea("VZX")
		DbSetOrder(1)
		If !DbSeek( xFilial("VZX") + M->VZ7_ITECAM )
			Return .f.
		EndIf
		If !(cTipAva $ VZX->VZX_TIPACA)
			Return .f.
		EndIF
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_DESCAM","oAuxGetDados:aHeader")] := VZX->VZX_DESCAM
		oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_VALITE","oAuxGetDados:aHeader")] := VZX->VZX_VALOR
		For ni := 1 to len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. ni <> oAuxGetDados:nAt // Verificar se a Duplicidade entre as Linhas do aCols
				If oAuxGetDados:aCols[ni,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")] == M->VZ7_ITECAM
					MsgStop(STR0008,STR0009) // Item ja digitado! / Atencao
					Return .f.
				EndIf
			EndIf
		Next
		ni := aScan(aVZ7Exist,{|x| x[1] == M->VZ7_ITECAM })
		If ni > 0
			If aVZ7Exist[ni,2] == "0" // 0=Troco
				cObs := STR0010 // Item ja existente no Troco!
			ElseIf aVZ7Exist[ni,2] == "1" // 1=Cortesia
				cObs := STR0011 // Item ja existente na Cortesia!
			ElseIf aVZ7Exist[ni,2] == "2" // 2=Redutor
				cObs := STR0012 // Item ja existente no Redutor!
			ElseIf aVZ7Exist[ni,2] == "3" // 3=Venda Agregada
				cObs := STR0013 // Item ja existente na Venda Agregada!
			EndIf
			If MsgYesNo(cObs+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0014,STR0009) // Confirma alteracao? / Atencao
				oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_VALITE","oAuxGetDados:aHeader")] := aVZ7Exist[ni,3]
			Else
				Return .f.
			EndIf
		EndIf
	ElseIf ReadVar() $ "M->VZ7_VALITE"
		If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_ALTVLR","oAuxGetDados:aHeader")] == "0"
			Return .f.
		EndIf
		If M->VZ7_VALITE <= 0
			MsgStop(STR0015,STR0009) // Favor Informar o Valor do Item! / Atencao
			Return .f.
		Endif
	ElseIf ReadVar() $ "M->VZ7_COMPAG"
		If M->VZ7_COMPAG == "1"
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_GERORC","oAuxGetDados:aHeader")] := M->VZ7_GERORC := "0" // 0 = Nao gerar Orcamento
		ElseIf M->VZ7_COMPAG == "3"
			oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_GERORC","oAuxGetDados:aHeader")] := M->VZ7_GERORC := "1" // 1 = Gerar Orcamento
		EndIf
		If M->VZ7_COMPAG <> "1"
			If FG_POSVAR("VZ7_TIPTIT","oAuxGetDados:aHeader") > 0
				oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_TIPTIT","oAuxGetDados:aHeader")] := M->VZ7_TIPTIT := "  " // Limpar o campo Tipo de Titulo
			EndIf
		EndIf
	EndIf
ElseIf cTp == "2" .or. cTp == "3" // Linha OK / Tudo OK
	For ni := 1 to len(oAuxGetDados:aCols)
		If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. !Empty(oAuxGetDados:aCols[ni,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")]) // Verificar Valores nas Linhas do aCols
			If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_ALTVLR","oAuxGetDados:aHeader")] <> "0" .and. oAuxGetDados:aCols[ni,FG_POSVAR("VZ7_VALITE","oAuxGetDados:aHeader")] <= 0
				MsgStop(STR0017,STR0009) // Item sem valor digitado! / Atencao
				Return .f.
			EndIf
			If FG_POSVAR("VZ7_COMPAG","oAuxGetDados:aHeader") > 0
				If Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_COMPAG","oAuxGetDados:aHeader")])
					MsgStop(STR0018,STR0009) // Item sem Como Pagar! / Atencao
					Return .f.
				Else
					If oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_COMPAG","oAuxGetDados:aHeader")] == "1"
						If FG_POSVAR("VZ7_TIPTIT","oAuxGetDados:aHeader") > 0
							If Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_TIPTIT","oAuxGetDados:aHeader")])
								MsgStop(STR0021,STR0009) // Item sem Tipo de Titulo! / Atencao
								Return .f.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			If cTp == "2" // LinhaOK
				If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])]
					MsgStop(STR0019,STR0009) // Favor preencher corretamente o Item digitado! / Atencao
					Return .f.
				EndIf
			ElseIf cTp == "3" // TudoOK
				oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] := .t.
			EndIf
		EndIf
	Next
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXX003DELบ Autor ณ Andre Luis Almeida บ Data ณ 31/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Deleta aCols VZ7                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXX003DEL(nOpc,cTipo)
Local ni := 0
If nOpc <> 3 .and. nOpc <> 4 // Nao for Inclusao e Alteracao
	Return .t.
EndIf
oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
For ni := 1 to len(oAuxGetDados:aCols)
	If !oAuxGetDados:aCols[ni,len(oAuxGetDados:aCols[ni])] .and. ni <> oAuxGetDados:nAt // Verificar se a Duplicidade entre as Linhas do aCols
		If oAuxGetDados:aCols[ni,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")] == oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")]
			MsgStop(STR0008,STR0009) // Item ja digitado! / Atencao
			oAuxGetDados:aCols[oAuxGetDados:nAt,len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := .t.
		EndIf
	EndIf
Next
oAuxGetDados:oBrowse:Refresh()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FS_AALTER  บ Autor ณ Andre Luis Almeida บ Data ณ 31/03/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Monta vetor com os campos que poderao dar manutencao       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AALTER(cTipo)
Local ni := 0
Local aVetaAlt := {}
FG_MEMVAR(oAuxGetDados:aHeader,oAuxGetDados:aCols,oAuxGetDados:nAt)
If Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_ITECAM","oAuxGetDados:aHeader")]) .and. FG_POSVAR("VZ7_COMPAG","oAuxGetDados:aHeader") > 0
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VZ7_COMPAG","oAuxGetDados:aHeader")] := M->VZ7_COMPAG := " "
EndIf
For ni := 1 to len(oAuxGetDados:aHeader)
	aadd(aVetaAlt,oAuxGetDados:aHeader[ni,2])
Next
oAuxGetDados:aAlter := oAuxGetDados:oBrowse:aAlter := aClone(aVetaAlt)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVX003TOTALบ Autor ณ Andre Luis Almeida บ Data ณ  30/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Totalizar Acao de Vendas VZ7                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNroAte ( Nro do Atendimento )                             บฑฑ
ฑฑบ          ณ cIteTra ( Nro do Item do Atendimento )                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos -> Novo Atendimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VX003TOTAL(cNroAte,cIteTra)
Local nColuna   := 0
Local aTotal    := {0,0,0,0,0} // { SOMA NO TOTAL DO ATENDIMENTO , 0=TROCO , 1=CORTESIA , 2=REDUTOR , 3=VENDA AGREGADA }
Local cQuery    := ""
Local cQAlVZ7   := "SQLVZ7"
Local aArea := GetArea()
Default cIteTra := ""
cQuery :="SELECT VZ7.VZ7_AGRVLR , VZ7.VZ7_COMPAG , SUM(VZ7.VZ7_VALITE) AS VLR FROM "+RetSQLName("VZ7")+" VZ7 WHERE VZ7.VZ7_FILIAL='"+xFilial("VZ7")+"' AND "
cQuery += "VZ7.VZ7_NUMTRA='"+cNroAte+"' AND "
If !Empty(cIteTra)
	cQuery += "VZ7.VZ7_ITETRA='"+cIteTra+"' AND "
EndIf
cQuery += "VZ7.VZ7_AGRVLR IN ('0','1','2','3') AND VZ7.D_E_L_E_T_=' ' GROUP BY VZ7.VZ7_AGRVLR , VZ7.VZ7_COMPAG"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVZ7, .F., .T. )
Do While !( cQAlVZ7 )->( Eof() )
	If ( cQAlVZ7 )->( VZ7_AGRVLR ) == "0" .or. ( ( cQAlVZ7 )->( VZ7_AGRVLR ) == "3" .and.  ( cQAlVZ7 )->( VZ7_COMPAG ) == "2" ) // Troco ou Venda Agregada que Inclui no Atendimento
		aTotal[1] += ( cQAlVZ7 )->( VLR ) // Totalizar no Valor Total do Atendimento
	EndIf
	nColuna := val(( cQAlVZ7 )->( VZ7_AGRVLR ))+2
	aTotal[nColuna] += ( cQAlVZ7 )->( VLR ) // Valores individuais ( Troco / Cortesia / Redutor / Venda Agregada )
	If ( ( cQAlVZ7 )->( VZ7_AGRVLR ) == "3" .and.  ( cQAlVZ7 )->( VZ7_COMPAG ) == "2" ) // Venda Agregada que Inclui no Atendimento
		aTotal[4] += ( cQAlVZ7 )->( VLR ) // Somar no Redutor ( Venda Agregada )
	EndIf
	( cQAlVZ7 )->( DbSkip() )
EndDo
( cQAlVZ7 )->( dbCloseArea() )
RestArea( aArea )
Return(aClone(aTotal))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ VXX003WHEN บ Autor ณ Andre Luis Almeida บ Data ณ 26/05/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ WHEN do campo VZ7_GERORC                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VXX003WHEN()
Local lRet := .f.
If M->VZ7_AGRVLR="0" .or. ( M->VZ7_AGRVLR="3" .and. M->VZ7_COMPAG="2" ) // Troco ou Venda Agregada no Atendimento
	lRet := .t.
EndIf
Return(lRet)
#INCLUDE "veicc560.ch"
#Include "fileio.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEICC560 ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Frota do Cliente                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEICC560
//variaveis controle de janela
Local aObjects := {} , aPos := {} , aPosObjApon := {} , aInfo := {}
Local nCntFor := 1
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Private oDlg
Private oDlgPend,oLbTexto,aVetor:={}

If PERGUNTE("VCC560",.t.)
	
	DbSelectArea("VC3")
	DbSetOrder(1)
	DbSeek(xFilial("VC3")+MV_PAR01+MV_PAR02)
	Do While !Eof() .And. VC3->VC3_CODCLI == MV_PAR01 .And. VC3->VC3_LOJA == MV_PAR02
		Aadd(aVetor, {;
			VC3->VC3_CODMAR,; // Marca
			VC3->VC3_MODVEI,; // Modelo
			Posicione("VV2",1,xFilial("VV2")+VC3->VC3_CODMAR+VC3->VC3_MODVEI,"VV2_DESMOD"),; // Descrição Modelo
			VC3->VC3_FABMOD,; // Ano Fabricação
			VC3->VC3_QTDFRO,; // Quantidade
			VC3->VC3_CHASSI;  // Chassi
		})
		DbSelectArea("VC3")
		DbSkip()
	EndDo
	
	If Len(aVetor) <= 0
		Help(" ",1,"VEICC560")
		Return
	EndIf
	
	Asort(aVetor,,,{|x,y|x[1]+x[2] > y[1]+y[2]})
	
	cTitulo := STR0001+" "+MV_PAR01+" "+MV_PAR02+" "+MV_PAR03 //"Frota do Cliente "
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 1, .T., .T. } )  //Cabecalho
	// Fator de reducao de 0.8
	for nCntFor := 1 to Len(aSizeAut)
		aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	next
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos := MsObjSize (aInfo, aObjects,.F.)
	
	oDlgPend := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cTitulo,,,,128,,,,,.t.)
	
	@ aPos[1,1]+002,aPos[1,2]+001 LISTBOX oLbTexto FIELDS HEADER OemToAnsi(STR0002),; //"Marca"
	OemToAnsi(STR0003),; // "Modelo"
	OemToAnsi(STR0004),; // "Descricao"
	OemToAnsi(STR0005),; // "Ano Fabricacao"
	OemToAnsi(STR0006),; // "Quantidade"
	OemToAnsi(STR0007);  // "Chassi"
	COLSIZES 30,60,60,60;
	SIZE aPos[1,4]-aPos[1,2], aPos[1,3]-aPos[1,1]-12 OF oDlgPend PIXEL
	
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || {;
		aVetor[oLbTexto:nAt, 1],;
		aVetor[oLbTexto:nAt, 2],;
		aVetor[oLbTexto:nAt, 3],;
		Transform(Val(aVetor[oLbTexto:nAt, 4]), "9999/9999"),;
		Str(aVetor[oLbTexto:nAt, 5]),;
		aVetor[oLbTexto:nAt, 6],;
	}}
	
	oDlgPend:bInit := {|| EnchoiceBar(oDlgPend,{|| nOpca := 1,(oDlgPend:End())},{|| nOpca := 0,(oDlgPend:End())}) }
	oDlgPend:lCentered := .T.
	oDlgPend:Activate()
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALC560³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação dos Parâmetros                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALC560()

return(FG_VALIDA(NIL,"SA1TMV_PAR01+MV_PAR02*","MV_PAR03 := SA1->A1_NREDUZ"))
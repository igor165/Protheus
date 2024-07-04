#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA050.CH"
/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA050   º Autor ³ VENDAS CRM         º Data ³  07/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Cadastro de tipos de ocorrencias                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA050()

Private aRotina		:= MenuDef()  
Private cCadastro	:= STR0003 //"Tipos de ocorrência"

mBrowse(,,,,"SUX")

Return                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³VENDAS CRM          º Data ³  07/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao das rotinas do browse                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef() 

Local aRotina:=	{{STR0004	,"AxPesqui",0,1},;	//"Pesquisar"
	             {STR0005	,"Tk050Mnt",0,2},;	//"Visualizar"
	             {STR0006	,"Tk050Mnt",0,3},;	//"Incluir"
	             {STR0007	,"Tk050Mnt",0,4},;	//"Alterar"
	             {STR0008	,"Tk050Mnt",0,5}}	//"Excluir"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk050Mnt  ºAutor  ³VENDAS CRM          º Data ³  13/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de manutencao do cadastro de tipos de ocorrencias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk050Mnt(cAlias,nReg,nOpc)

Local aSize	:= MsAdvSize()
Local oDlg		:= Nil
Local oEnch	:= Nil
Local nOpcA	:= 0
Local nForI	:= 0
Local aObjects:= {}
Local aInfo	:= {}
Local aOcorr	:= {} 
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local nLenSX8	:= GetSx8Len()
Local bDblClck:= NIL

AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )

aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

RegToMemory(cAlias, INCLUI)  

//Carrega ListBox
DbSelectArea("SUX")
DbSetOrder(1)
DbSeek(xFilial("SUX"))

While !SUX->(Eof()) .AND. SUX->UX_FILIAL == xFilial("SUX")
	If SUX->UX_CODTPO <> M->UX_CODTPO
		DbSelectArea("SUY")
		DbSetOrder(1)
		If DbSeek(xFilial("SUY") + M->UX_CODTPO + SUX->UX_CODTPO)
			AAdd(aOcorr,{.T., SUX->UX_CODTPO, SUX->UX_DESTOC })
		Else
			AAdd(aOcorr,{.F., SUX->UX_CODTPO, SUX->UX_DESTOC })
		EndIF
	EndIF
	SUX->(DbSkip())
End

bDblClck := {|nRow,nCol,nFlags| If(nOpc == 3 .OR. nOpc ==4, (aOcorr[oLbx:nAt,1] := !aOcorr[oLbx:nAt,1], oLbx:Refresh()),NIL)}
If Len(aOcorr)==0
	aAdd(aOcorr,{.F., "", "" })
	bDblClck:= {||.T.}
EndIf

//Tela

DEFINE MSDIALOG oDlg FROM aSize[7], 0 TO aSize[6],aSize[5] TITLE cCadastro PIXEL OF oMainWnd

oEnch	:= MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg,,.T.,.T.)                                         
oLbx	:= TWBrowse():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],Int(aPosObj[2,3] /1.7),;
      /*[\{|| \{<Flds> \} \}]*/, ;
      {" ",STR0009,STR0010}/*[\{<aHeaders>\}]*/, /*[\{<aColSizes>\}]*/, ; //"Codigo"### //"Ocorrência Predecessora"
      oDlg, /*<(cField)>*/, /*<uValue1>*/, /*<uValue2>*/,;
      /*[<{uChange}>]*/,;
      bDblClck,; //Duplo Clique
      /*[\{|nRow,nCol,nFlags|<uRClick>\}]*/,;
      /*<oFont>*/, /*<oCursor>*/, /*<nClrFore>*/, /*<nClrBack>*/, /*<cMsg>*/,;
      /*<.update.>*/, /*<cAlias>*/, .T. )  

oLbx:SetArray( aOcorr )
if len(aOcorr) > 0
	oLbx:bLine := {|| {Iif(aOcorr[oLbx:nAt,1],oOk,oNo),;
    	               aOcorr[oLbx:nAt,2],;
        	           aOcorr[oLbx:nAt,3]}}
 EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1, If(Obrigatorio(oEnch:aGets,oEnch:aTela), oDlg:End(), nOpcA:=0) },{||(nOpcA:=2, oDlg:End())})
If nOpcA == 1
	//Confirmou
	//Insere/Altera Tipo de ocorrencia
	DbSelectArea("SUX")
	DbSetOrder(1)
	If !DbSeek(xFilial("SUX") + M->UX_CODTPO)
		//Carregar os campos da tabela SUX
		SX3->(DbSelectArea("SX3"))
		SX3->(DBSetOrder(1))
		If SX3->(DbSeek("SUX"))
			RecLock("SUX",.T.)
			While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SUX"
				If ( AllTrim(SX3->X3_CAMPO) =="UX_FILIAL" )
					SUX->UX_FILIAL := xFilial("SUX")
				ElseIf SX3->X3_CONTEXT <> "V"
					SUX->&(SX3->X3_CAMPO) := M->&(SX3->X3_CAMPO)
				EndIf  
				SX3->(DbSkip())
			EndDo  
			SUX->(MsUnLock())
			ConfirmSX8() 
		EndIf
	Else
		If nOpc <> 5
			DbSelectArea("SUX")
			DbSetOrder(1)
			If DbSeek(xFilial("SUX") + M->UX_CODTPO)
				//Carregar os campos da tabela SUX
				SX3->(DbSelectArea("SX3"))
				SX3->(DBSetOrder(1))
				If SX3->(DbSeek("SUX"))
					RecLock("SUX",.F.)
					While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SUX"
						If SX3->X3_CONTEXT <> "V"
							SUX->&(SX3->X3_CAMPO) := M->&(SX3->X3_CAMPO)
						EndIf  
						SX3->(DbSkip())
					EndDo  
					SUX->(MsUnLock())
				EndIf
			EndIf
		Else
			DbSelectArea("SU9")
			DbSetOrder(3)
			If DbSeek(xFilial("SU9") + M->UX_CODTPO)
				msgalert(STR0001)
				Return Nil
			Else
				//verifica se alguém depende dele
				DbSelectArea("SUY")
				DbSetOrder(2)
				If DbSeek(xFilial("SUY") + M->UX_CODTPO)
					msgalert(STR0002)
					Return Nil
				Else
					RecLock("SUX",.F.)
					DbDelete()
					MsUnLock()
				EndIF
			EndIf
		EndIF
	EndIf
	
	//Insere/Remove Associação de dependência
	DbSelectArea("SUY")
	If nOpc <> 5 //Incluir ou Alterar
		DbSetOrder(1)
		For nForI = 1 To Len(aOcorr)
			If aOcorr[nForI,1] == .T. //Se não existia associação, insere
				if !DbSeek(xFilial("SUY") + M->UX_CODTPO + aOcorr[nForI,2])
					RecLock("SUY",.T.)
					SUY->UY_FILIAL := xFilial("SUY")
					SUY->UY_CODOCO := M->UX_CODTPO
					SUY->UY_CODDEP := aOcorr[nForI,2]
					MsUnlock()
				EndIF
			Else //Se ja existia uma associação, remove
				if DbSeek(xFilial("SUY") + M->UX_CODTPO + aOcorr[nForI,2])
					RecLock("SUY",.F.)
					DbDelete()
					MsUnlock()
				EndIF
			EndIf
		Next
	Else // Excluir
         DbSetOrder(1)
		 DbSeek(xFilial("SUY") + M->UX_CODTPO)
         While !SUY->(EOF()) .AND. SUY->UY_FILIAL == xFilial("SUY")
         	RecLock("SUY",.F.)
         	DbDelete()
         	MsUnLock()
         	SUY->(DbSkip())
         End
	EndIF
Else
	//Fechou
	While GetSx8Len() > nLenSX8
		RollBackSX8()
	End
EndIF

Return Nil

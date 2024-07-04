#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA968.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |MATA968   ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gerenciamento dos lancamentos fiscais da Apuracao³±±
±±³          ³ de ICMS.                                                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA968()

Local	oFontB
Local	oFont
Local	oDlgCheck
Local	oDlg
Local	oGrp1
Local	oGrp2
Local	oGrp3
Local	oMsNewG1
Local 	aSize     	:= 	MsAdvSize() 
Local	aHeadCDA	:=	{}
Local	aColsCDA1	:=	{}
Local	aColsCDA2	:=	{}
Local 	aInfo     	:= 	{} 
Local 	aObjects  	:= 	{} 
Local 	aObj      	:= 	{}
Local	aAlter		:=	{}
Local	aReproc		:=	{"S=Sim", "N=Não"}
Local 	cCadastro	:=	STR0001	//"Gerenciamento dos Lançamentis Fiscais da Apuração de ICMS"
Local 	cGrp1		:=	STR0002	//"Informações sobre o documento fiscal"
Local 	cGrp2		:=	STR0003	//"Lançamentos calculados pelo sistema"
Local 	cGrp3		:=	STR0004	//"Lançamentos inseridos pelo usuário"
Local	cTipoMov	:=	Iif(Left(SF3->F3_CFO,1)<"5","E","S")
Local	cTxtTpMov	:=	Iif(Left(SF3->F3_CFO,1)<"5",STR0005,STR0006)	//"Entrada"###"Saída"
Local	cFormul		:= Iif(Empty(SF3->F3_FORMUL),Iif(cTipoMov == "S","S"," "),SF3->F3_FORMUL)
Local	cEspecie	:=	SF3->F3_ESPECIE
Local	cTxtFormul	:=	Iif(Empty(SF3->F3_FORMUL),STR0007,STR0008)	//"Não"###"Sim"
Local	cNFiscal	:=	SF3->F3_NFISCAL
Local	cSerie		:=	SF3->F3_SERIE
Local	cCliefor	:=	SF3->F3_CLIEFOR
Local	cLoja		:=	SF3->F3_LOJA
Local	cTipo		:=	SF3->F3_TIPO
Local	cReproc		:=	If(Empty(SF3->F3_REPROC),"S",SF3->F3_REPROC)
Local	cChvCDA		:=	xFilial("CDA")+cTipoMov+cEspecie+cFormul+cNFiscal+cSerie+cCliefor+cLoja
Local	cNomCliFor	:=	""
Local	cSay1		:=	OemToAnsi("Tipo Movimentação: ")
Local	cSay2		:=	OemToAnsi("Espécie:")
Local	cSay3		:=	OemToAnsi("Formulário próprio:")
Local	cSay4		:=	OemToAnsi("Tipo:")
Local	cSay5		:=	OemToAnsi("Nota Fiscal:")
Local	cSay6		:=	OemToAnsi("Série:")
Local	cSay7		:=	Iif(cTipoMov=="E",Iif(cTipo$"DB", "Cliente", "Fornecedor"),Iif(cTipo$"DB", "Fornecedor", "Cliente"))+" \ Loja :"
Local	cSay8		:=	OemToAnsi("Considerar no")
Local	cSay9		:=	OemToAnsi("reprocessamento ?")
Local	cNCmps		:=	"CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/CDA_ORIGEM/CDA_GUIA/CDA_CODREF/"
Local	nOpcao		:=	0
Local	nOpcX		:=	0
Local 	nX			:= 	0
Local 	nPosVL197	:=  0
Local 	nPosCLANC	:=  0
Local	aPosGet 	:= 	{}
Local	lInclui 	:=	.F.
Local   cTexto	    :=	""
Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)


If !FisChkDt(SF3->F3_ENTRADA)
	Return (.T.)
EndIf

Private	oMsNewG2

If lVerpesssen
	Define FONT oFontB NAME "Arial" SIZE 0, -11 BOLD
	Define FONT oFont  NAME "Arial" SIZE 0, -11

	cTexto	:=	OemToAnsi(STR0009)
	cTexto	+=	OemToAnsi(STR0010)+" "
	cTexto	+=	OemToAnsi(STR0011)+" "
	cTexto	+=	OemToAnsi(STR0012)+" "
	cTexto	+=	OemToAnsi(STR0013)+" "
	cTexto	+=	OemToAnsi(STR0014)+" "
	cTexto	+=	OemToAnsi(STR0015)+" "
	cTexto	+=	OemToAnsi(STR0016)+" "
	cTexto	+=	OemToAnsi(STR0017)

	nOpcX	:= Aviso("Atencao",cTexto,{"Sim","Nao"},3)

	If nOpcX==1
		aHeadCDA	:=	MT968aH(cNCmps,@aAlter)
		aColsCDA1	:=	MT968aC(1,aHeadCDA,cChvCDA)
		aColsCDA2	:=	MT968aC(2,aHeadCDA,cChvCDA,aColsCDA1)
		
		If (cTipoMov=="E" .And. cTipo$"DB") .Or.;
			(cTipoMov=="S" .And. !cTipo$"DB")
			cNomCliFor	:=	Posicione("SA1",1,xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA),"A1_NOME")
		
		ElseIf (cTipoMov=="E" .And. !cTipo$"DB") .Or.;
			(cTipoMov=="S" .And. cTipo$"DB")
			cNomCliFor	:=	Posicione("SA2",1,xFilial("SA2")+SF3->(F3_CLIEFOR+F3_LOJA),"A2_NOME")
		EndIf

		AAdd( aObjects, { 100, 045, .T., .F. } )
		AAdd( aObjects, { 100, 080, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
		aObj  := MsObjSize( aInfo, aObjects, .T. )
		aPosGet := msObjGetPos(aSize[3] - aSize[1], 396, {{10,68,110,135,180,235,267,282,307,365},;
															{10,43,95,115,150,195,235,255}})
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		
		oGrp1	:=	TGroup():New(aObj[1,1],aObj[1,2],aObj[1,3],aObj[1,4],cGrp1,oDlg,,,.T.,.T.)

		TSay():New(aObj[1,1]+12,aPosGet[1][1],{||cSay1},oGrp1,,oFontB,,,,.T.,,,60,10,.T.,,,,,)
		TGet():New(aObj[1,1]+10,aPosGet[1][2],{|u|If(PCount()==0,cTxtTpMov,cTxtTpMov := u)},oGrp1, 10, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		TSay():New(aObj[1,1]+12,aPosGet[1][3],{||cSay2},oGrp1,,oFontB,,,,.T.,,,60,10,.T.,,,,,)
		TGet():New(aObj[1,1]+10,aPosGet[1][4],{|u|If(PCount()==0,cEspecie,cEspecie := u)},oGrp1, 10, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		TSay():New(aObj[1,1]+12,aPosGet[1][5],{||cSay3},oGrp1,,oFontB,,,,.T.,,,90,10,.T.,,,,,)
		TGet():New(aObj[1,1]+10,aPosGet[1][6],{|u|If(PCount()==0,cTxtFormul,cTxtFormul := u)},oGrp1, 10, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		TSay():New(aObj[1,1]+12,aPosGet[1][7],{||cSay4},oGrp1,,oFontB,,,,.T.,,,90,10,.T.,,,,,)
		TGet():New(aObj[1,1]+10,aPosGet[1][8],{|u|If(PCount()==0,cTipo,cTipo := u)},oGrp1, 10, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		

		TSay():New(aObj[1,1]+10,aPosGet[1][9],{||cSay8},oGrp1,,oFontB,,,,.T.,,,90,10,.T.,,,,,)
		TSay():New(aObj[1,1]+16,aPosGet[1][9],{||cSay9},oGrp1,,oFontB,,,,.T.,,,90,10,.T.,,,,,)
		TCombobox():New(aObj[1,1]+12,aPosGet[1][10], {|u| Iif (PCount ()>0, cReproc := u, cReproc )}, aReproc, 25, 10, oGrp1,,,,,,.T.,oFont)
		
		TSay():New(aObj[1,1]+30,aPosGet[2][1],{||cSay5},oGrp1,,oFontB,,,,.T.,,,60,10,.T.,,,,,)
		TGet():New(aObj[1,1]+28,aPosGet[2][2],{|u|If(PCount()==0,cNFiscal,cNFiscal := u)},oGrp1, 20, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		TSay():New(aObj[1,1]+30,aPosGet[2][3],{||cSay6},oGrp1,,oFontB,,,,.T.,,,60,10,.T.,,,,,)
		TGet():New(aObj[1,1]+28,aPosGet[2][4],{|u|If(PCount()==0,SerieNfId("SF3",2,"F3_SERIE"),SerieNfId("SF3",2,"F3_SERIE") := u)},oGrp1, 10, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		TSay():New(aObj[1,1]+30,aPosGet[2][5],{||cSay7},oGrp1,,oFontB,,,,.T.,,,60,10,.T.,,,,,)
		TGet():New(aObj[1,1]+28,aPosGet[2][6],{|u|If(PCount()==0,cCliefor,cCliefor := u)},oGrp1, 40, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		TGet():New(aObj[1,1]+28,aPosGet[2][7],{|u|If(PCount()==0,cLoja,cLoja := u)},oGrp1, 20, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		TGet():New(aObj[1,1]+28,aPosGet[2][8],{|u|If(PCount()==0,cNomCliFor,cNomCliFor := u)},oGrp1, 130, 10,,,,,oFont,.T.,,.T.,,,,,,,.T.,,,,,,)
		
		oGrp2		:=	TGroup():New(aObj[2,1],aObj[2,2],aObj[2,3],aObj[2,4],cGrp2,oDlg,,,.T.,.T.)
		oMsNewG1	:=	MsNewGetDados():New(aObj[2,1]+10,aObj[2,2]+5,aObj[2,3]-5,aObj[2,4]-5,GD_DELETE,"AllwaysTrue","AllwaysTrue","+CDA_SEQ",{},/*freeze*/,Len(aColsCDA1),/*fieldok*/,/*superdel*/,/*delok*/,oGrp2,aHeadCDA,aColsCDA1)
		
		oGrp3		:=	TGroup():New(aObj[3,1],aObj[3,2],aObj[3,3],aObj[3,4],cGrp3,oDlg,,,.T.,.T.)
		oMsNewG2	:=	MsNewGetDados():New(aObj[3,1]+10,aObj[3,2]+5,aObj[3,3]-5,aObj[3,4]-5,GD_INSERT+GD_UPDATE+GD_DELETE,"a968linOK()","a968TdOK()","+CDA_SEQ",aAlter,/*freeze*/,999,/*fieldok*/,/*superdel*/,/*delok*/,oGrp3,aHeadCDA,aColsCDA2)
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(a968TdOK(),(nOpcao := 1,oDlg:End()),) },{||nOpcao := 2,oDlg:End()})
		
		If nOpcao == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ao confirmar, efetua gravacao dos lancamentos do usuario no CDA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColsCDA2 := AClone(oMsNewG2:aCols)
			aColsCDA1 := AClone(oMsNewG1:aCols)
			dbSelectArea("CDA")
			dbSetOrder(01)

			nPosVL197 	:= aScan(oMsNewG2:aHeader,{|aX|aX[2]=="CDA_VL197"})			
			nPosCLANC 	:= aScan(oMsNewG2:aHeader,{|aX|aX[2]=="CDA_CLANC"})

			//permite a exclusão de lançamentos automáticos
			For nX := 1 To Len(aColsCDA1)

				If dbSeek(cChvCDA+aColsCDA1[nX][1]+aColsCDA1[nX][2]);
					.And. aColsCDA1[nX,Len(aColsCDA1[nX])]
					
					RecLock("CDA",.F.)
					CDA->(dbDelete())
					MsUnLock()
					CDA->(FkCommit())
				EndIf

			Next

			For nX := 1 To Len(aColsCDA2)
			
				If dbSeek(cChvCDA+aColsCDA2[nX][1]+aColsCDA2[nX][2])
					lInclui := .F.
					If CDA->CDA_CALPRO == "2"
						If aColsCDA2[nX,Len(aColsCDA2[nX])] // Exclui
							RecLock("CDA",.F.)
							CDA->(dbDelete())
							MsUnLock()
							CDA->(FkCommit())						
						Else								// Altera
							If CDA->CDA_TPREG == "NA" .And. !dbSeek(cChvCDA+aColsCDA2[nX][1]+aColsCDA2[nX][2]+aColsCDA2[nX][3])
								//Lancamentos inativos nao devem ser alterados
								lInclui := .T.
							Else
								RecLock("CDA",.F.)
								CDA->CDA_CODLAN	:=	aColsCDA2[nX][3]
								CDA->CDA_BASE	:=	aColsCDA2[nX][5]
								CDA->CDA_ALIQ	:=	aColsCDA2[nX][6]
								CDA->CDA_VALOR	:=	aColsCDA2[nX][7]
								CDA->CDA_IFCOMP	:=	aColsCDA2[nX][8]
								CDA->CDA_TPLANC	:=	aColsCDA2[nX][9]

								If nPosVL197 > 0
									CDA->CDA_VL197 	 := aColsCDA2[nX][nPosVL197]
								Endif								

								If nPosCLANC > 0
									CDA->CDA_CLANC 	 := aColsCDA2[nX][nPosCLANC]
								Endif								

								MsUnLock()
								CDA->(FkCommit())
							EndIf
						EndIf
					EndIf
				Else
					lInclui := .T.
				EndIf
				If lInclui									// Inclui
					RecLock("CDA",.T.)
					CDA->CDA_FILIAL	:=	xFilial("CDA")
					CDA->CDA_TPMOVI	:=	cTipoMov
					CDA->CDA_ESPECI	:=	cEspecie
					CDA->CDA_FORMUL	:=	cFormul
					CDA->CDA_NUMERO	:=	cNFiscal
					If CDA->( FieldPos("CDA_TPNOTA") ) > 0
						CDA->CDA_TPNOTA :=  cTipo
					EndIf
					SerieNfId("CDA",1,"CDA_SERIE",,,,cSerie)
					CDA->CDA_CLIFOR	:=	cCliefor
					CDA->CDA_LOJA	:=	cLoja
					CDA->CDA_NUMITE	:=	aColsCDA2[nX][1]
					CDA->CDA_SEQ	:=	aColsCDA2[nX][2]
					CDA->CDA_CODLAN	:=	aColsCDA2[nX][3]
					CDA->CDA_CALPRO	:=	"2"
					CDA->CDA_BASE	:=	aColsCDA2[nX][5]
					CDA->CDA_ALIQ	:=	aColsCDA2[nX][6]
					CDA->CDA_VALOR	:=	aColsCDA2[nX][7]
					CDA->CDA_IFCOMP	:=	aColsCDA2[nX][8]
					CDA->CDA_TPLANC	:=	aColsCDA2[nX][9]

					If nPosVL197 > 0
						CDA->CDA_VL197 	 := aColsCDA2[nX][nPosVL197]
					Endif								

					If nPosCLANC > 0
						CDA->CDA_CLANC 	 := aColsCDA2[nX][nPosCLANC]
					Endif

					MsUnLock()
					CDA->(FkCommit())
				EndIf			
			Next

			//Atualiza campo REPROC
			DbSelectArea("SF3")
			SF3->(DbSetOrder(5))
			If SF3->(DbSeek(xFilial("SF3")+cSerie+cNFiscal+cCliefor+cLoja))
				While SF3->(!EOF()) .And. xFilial("SF3")+cSerie+cNFiscal+cCliefor+cLoja==;
					SF3->(F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA)
					
					RecLock ("SF3", .F.)
					SF3->F3_REPROC := cReproc
					MsUnlock()
					SF3->(FKCommit())
					
					SF3->(dbSkip())
				EndDo
			EndIf
			
		EndIf	
	EndIf
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT968aH   ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do HEADER do GETDADOS                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³cNCmps -> Campos que nao serao considerados no HEADER       ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MT968aH(cNCmps,aAlter)
Local	aH		:=	{}
Local	cValid	:=	""

Default	cNCmps	:=	""

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("CDA")
While !Eof() .And. (X3_ARQUIVO=="CDA")
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO)+"/"$cNCmps)
		
		cValid	:=	AllTrim(X3_VALID)
		If AllTrim(X3_CAMPO)=="CDA_NUMITE"
			cValid	:=	AllTrim(X3_VALID)+Iif(Empty(AllTrim(X3_VALID)),"",".And.")+"MT986CpIt()"
		EndIf
		
		AADD(aH,{ Trim(X3Titulo()), ;
			AllTrim(X3_CAMPO),;
			X3_PICTURE,;
			X3_TAMANHO,;
			X3_DECIMAL,;
			cValid,;
			X3_USADO,;
			X3_TIPO,;
			X3_F3,;
			X3_CONTEXT,;
			X3_CBOX,;
			X3_RELACAO})
			
		If !AllTrim(X3_CAMPO)$"/CDA_SEQ/CDA_CALPRO/"
			aAdd(aAlter,AllTrim(X3_CAMPO))
		EndIf
	Endif
	dbSkip()
Enddo


Return aH
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT968aC   ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do ACOLS do GETDADOS                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc -> Opcao do AROTINA                                    ³±±
±±³          ³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³aC -> array no qual o ACOLS serah montado                   ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³bCond -> Condicao de loop do while                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MT968aC(nOpc,aH,cChvCDA,aColsCDA1)
Local	nI		:=	0
Local	aC		:=	{}
Local	nPosSeq	:=	0
Local	aBkpCDA	:=	{}

dbSelectArea("CDA")
dbSetOrder(1)
If dbSeek(cChvCDA)
	While !Eof() .And. cChvCDA==;
		CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA
		
		If CDA->CDA_TPREG == "NA"
			dbSkip()
			Loop
		EndIf
		
		If (nOpc==1 .And. CDA_CALPRO=="1") .Or. (nOpc==2 .And. CDA_CALPRO=="2")
			aAdd(aC,Array(Len(aH)+1))
			For nI := 1 To Len(aH)
				aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
			Next
			aC[Len(aC),Len(aH)+1] := .F.
		EndIf
		
		dbSkip()
	End
	
	If nOpc==2 .And. Len(aC)==0 .And. Len(aColsCDA1)>0		
		nPosSeq	:=	aScan(aH,{|aX|aX[2]=="CDA_SEQ"})
		aAdd(aC,Array(Len(aH)+1))
		For nI := 1 To Len(aH)
			aC[Len(aC),nI] 		:= CriaVar(aH[nI,2])
		Next
		aBkpCDA	:=	aClone(aColsCDA1)
		aC[len(aC),nPosSeq]		:=	Soma1(aColsCDA1[len(aColsCDA1),nPosSeq])
		aColsCDA1	:=	aClone(aBkpCDA)
		aC[len(aC),len(aH)+1]	:=	.F.
	EndIf
EndIf
Return aC
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LancCpIt  ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar o item digitado no lancamento fiscal com³±±
±±³          ³ os itens do documento fiscal.                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MT986CpIt()
Local	lRet		:=	.F.
Local	cTipoMov	:=	Iif(Left(SF3->F3_CFO,1)<"5","E","S")

If cTipoMov$"S"
	dbSelectArea("SD2")
	dbSetOrder(3)
	If dbSeek(xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)
		While !SD2->(Eof()) .And. xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		    If PADR(SD2->D2_ITEM,TAMSX3("CDA_NUMITE")[1])==M->CDA_NUMITE
		    	lRet	:=	.T.
		    	Exit
		    EndIf
			SD2->(dbSkip())
		End
	EndIf
ElseIf cTipoMov$"E"
	dbSelectArea("SD1")
	dbSetOrder(1)
	If dbSeek(xFilial("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)
		While !SD1->(Eof()) .And. xFilial("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If PADR(SD1->D1_ITEM,TAMSX3("CDA_NUMITE")[1])==M->CDA_NUMITE
				lRet	:=	.T.
		    	Exit
		    EndIf
			SD1->(dbSkip())
		End
	EndIf
EndIf

If !lRet
	//Número do item é inválido para este lançamento fiscal.
	//Deve-se informar um número de item existente no respectivo documento fiscal.
	Help("  ",1,"LAICMSCMP1")
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a968linOK ³ Autor ³ Liber De Esteban      ³ Data ³19/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar a linha no aCols                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a968linOK(nPosAtu)
Local	lRet	:=	.T.
Local	nPosLanc:=	aScan(oMsNewG2:aHeader,{|aX|aX[2]=="CDA_CODLAN"})
Local	nPosVlr	:=	aScan(oMsNewG2:aHeader,{|aX|aX[2]=="CDA_VALOR"})
Local	nPosIte :=	aScan(oMsNewG2:aHeader,{|aX|aX[2]=="CDA_NUMITE"})

DEFAULT nPosAtu	:=	oMsNewG2:nAT

If Type("oMsNewG2")=="O"
	
	If !oMsNewG2:aCols[nPosAtu,Len(oMsNewG2:aCols[nPosAtu])]
		If nPosLanc>0 .And. Empty(oMsNewG2:aCols[nPosAtu,nPosLanc])
			Help(1," ","OBRIGAT",,"CDA_CODLAN"+Space(30),3,0)
			lRet	:=	.F.
		EndIf
		If lRet .And. nPosLanc>0 .And. Empty(oMsNewG2:aCols[nPosAtu,nPosVlr])
			Help(1," ","OBRIGAT",,"CDA_VALOR"+Space(30),3,0)
			lRet	:=	.F.
		EndIf
		If lRet .And. nPosIte>0 .And. Empty(oMsNewG2:aCols[nPosAtu,nPosIte])
			Help(1," ","OBRIGAT",,"CDA_NUMITE"+Space(30),3,0)
			lRet	:=	.F.
		EndIf
	EndIf
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ a968TdOK ³ Autor ³ Liber De Esteban      ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar valores da GetDados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a968TdOK()
Local	lRet	:=	.T.
Local	nX		:=	0

For nX := 1 to len(oMsNewG2:aCols)
	lRet := a968linOK(nX)
	If !lRet
		Exit
	EndIf
Next

Return lRet
